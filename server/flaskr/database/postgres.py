import psycopg
from psycopg import sql
import os
from flask import current_app
from .tenant_context import get_current_tenant


def init_db(app):
    app.teardown_appcontext(close_db)


def close_db(e=None):
    pass


def get_db_access():
    conn = _get_db()
    orgId = get_current_tenant()
    if orgId:
        cur = conn.cursor()
        cur.execute(
            sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(str(orgId)))
        )
    return conn


def create_db():
    _run_sql_file("default")


def fill_test_db():
    _run_sql_file("default")

    orgId = get_current_tenant() or "1"

    with get_db_access() as conn:
        cur = conn.cursor()

        query = "INSERT INTO public.organizations (slug, name) values (%s, %s);"
        params = ("test", "Test")
        cur.execute(query, params)

        cur.execute(
            sql.SQL("CREATE SCHEMA IF NOT EXISTS {}; ").format(sql.Identifier(str(orgId)))
        )
        cur.execute(
            sql.SQL("SET search_path TO {}, public; ").format(sql.Identifier(str(orgId)))
        )

        with current_app.open_resource(
            os.path.join("database", "sql", f"schema.sql")
        ) as f:
            cur.execute(f.read().decode("utf8"))

    _run_sql_file("test_mock_data")


def write_query(query, params=None):
    with get_db_access() as conn:
        cur = conn.cursor()
        cur.execute(query, params)


def read_query(query, params=None):
    with get_db_access() as conn:
        cur = conn.cursor()
        cur.execute(query, params)
        items = cur.fetchall()

    return items

def _run_sql_file(filename: str):
    with _get_db() as conn:
        cursor = conn.cursor()

        with current_app.open_resource(
            os.path.join("database", "sql", f"{filename}.sql")
        ) as f:
            cursor.execute(f.read().decode("utf8"))


def _get_db():
    uri = current_app.config['DATABASE_URL']
    return psycopg.connect(uri, autocommit=False)
