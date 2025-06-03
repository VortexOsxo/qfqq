import sqlite3
import os
from flask import current_app, g

def init_db(app):
    app.teardown_appcontext(close_db)

def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()

def get_db_access():
    if 'db' not in g:
        g.db = _get_db()
    return g.db

def create_db():
    db = _get_db()

    with current_app.open_resource(os.path.join('database', 'sqlite', 'schema.sql')) as f:
        db.executescript(f.read().decode('utf8'))

def _get_db():
    return sqlite3.connect(current_app.config['DATABASE'])


