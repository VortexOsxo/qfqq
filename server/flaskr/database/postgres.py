from psycopg import sql
import os
from flask import current_app
from .tenant_context import get_current_tenant
from .database import Database


def close_db(e=None):
    pass


def create_db():
    Database.run_sql_file("default")


def fill_test_db():
    Database.run_sql_file("default")

    orgId = get_current_tenant() or "1"

    with Database.get_db_access() as conn:
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

    Database.run_sql_file("test_mock_data")


def write_query(query, params=None):
    Database.write_query(query, params)


def read_query(query, params=None):
    return Database.read_query(query, params)

def get_db_access():
    return Database.get_db_access()