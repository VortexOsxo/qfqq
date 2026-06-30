import os

import psycopg
from psycopg import sql

from .tenant_context import get_current_tenant

class Database:
    uri = None

    @classmethod
    def set_uri(cls, uri):
        cls.uri = uri
    
    @classmethod
    def get_db_access(cls):
        conn = cls._get_db()
        orgId = get_current_tenant()
        if orgId:
            cur = conn.cursor()
            cur.execute(
                sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(str(orgId)))
            )
        return conn
    
    @classmethod
    def read_query(cls, query, params=None):
        with cls.get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            items = cur.fetchall()

        return items
    
    @classmethod
    def write_query(cls, query, params=None):
        with Database.get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)

    @classmethod
    def run_sql_file(cls, filename: str):
        with cls._get_db() as conn:
            cursor = conn.cursor()
            path = os.path.join("flaskr", "database", "sql", f"{filename}.sql")

            with open(path, "r", encoding="utf-8") as f:
                cursor.execute(f.read())

    @classmethod
    def _get_db(cls):
        return psycopg.connect(cls.uri, autocommit=False)
    
