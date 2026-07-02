import os
from contextlib import contextmanager

import psycopg
from psycopg import sql
from psycopg_pool import ConnectionPool

from .tenant_context import get_current_tenant


def _reset_connection(conn: psycopg.Connection) -> None:
    """Reset search_path to public before returning a connection to the pool.

    This is the critical multi-tenant safety valve: it ensures that a
    connection that was scoped to Tenant A cannot accidentally serve
    Tenant B's data on its next checkout from the pool.
    """
    conn.execute("SET search_path TO public;")
    conn.commit()


class Database:
    _pool: ConnectionPool | None = None

    @classmethod
    def init_pool(cls, uri: str, min_size: int = 2, max_size: int = 10) -> None:
        """Create the shared connection pool.  Call once at app startup."""
        cls._pool = ConnectionPool(
            conninfo=uri,
            min_size=min_size,
            max_size=max_size,
            reset=_reset_connection,
            open=True,
        )

    @classmethod
    def close_pool(cls) -> None:
        """Drain and close the pool.  Call on app teardown."""
        if cls._pool is not None:
            cls._pool.close()
            cls._pool = None

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @classmethod
    def _get_db(cls):
        """Return the pool's connection context manager (use with `with`)."""
        if cls._pool is None:
            raise RuntimeError("Database pool is not initialised. Call Database.init_pool() first.")
        return cls._pool.connection()

    @classmethod
    @contextmanager
    def get_db_access(cls):
        """Borrow a connection from the pool and scope it to the current tenant's schema.

        Usage:
            with Database.get_db_access() as conn:
                conn.execute(...)
        """
        with cls._get_db() as conn:
            org_id = get_current_tenant()
            if org_id:
                conn.execute(
                    sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(str(org_id)))
                )
            yield conn

    # ------------------------------------------------------------------
    # Query helpers
    # ------------------------------------------------------------------

    @classmethod
    def read_query(cls, query, params=None):
        with cls.get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            return cur.fetchall()

    @classmethod
    def write_query(cls, query, params=None):
        with cls.get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)

    @classmethod
    def run_sql_file(cls, filename: str):
        with cls._get_db() as conn:
            cursor = conn.cursor()
            path = os.path.join("flaskr", "database", "sql", f"{filename}.sql")
            with open(path, "r", encoding="utf-8") as f:
                cursor.execute(f.read())
