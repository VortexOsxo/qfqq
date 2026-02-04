import psycopg
import os
from flask import current_app


def init_db(app):
    app.teardown_appcontext(close_db)


def close_db(e=None):
    pass


def get_db_access():
    return _get_db()


def create_db():
    with _get_db() as conn:
        cursor = conn.cursor()

        with current_app.open_resource(
            os.path.join("database", "postgres", "schema.sql")
        ) as f:
            cursor.execute(f.read().decode("utf8"))


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


def _get_db():
    return psycopg.connect(
        host="localhost",
        dbname="qfqq",
        user="postgres",
        password="user",
        port=5432,
        autocommit=False,
    )
