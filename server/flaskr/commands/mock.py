import click

from werkzeug.security import check_password_hash, generate_password_hash
from flaskr.database.postgres.handlers import *

@click.command("mock-db")
def mock_command():
    passwordHash = generate_password_hash('League0328!')

    UserDataHandler.create_user('Salut', 'Hi', 'salut@gmail.com', passwordHash)
    UserDataHandler.create_user('Bobby', 'Ho', 'bobby@gmail.com', passwordHash)
    UserDataHandler.create_user('Greg', 'Ha', 'greg@gmail.com', passwordHash)
