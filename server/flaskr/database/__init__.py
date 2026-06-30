import click

from .handlers import (
    UserDataHandler,
    ProjectDataHandler,
    DecisionDataHandler,
    MeetingDataHandler,
    RoleDataHandler,
    OrganizationDataHandler,
    PasswordRequestDataHandler,
    NotificationJobDataHandler
)

from .database import Database

from .postgres import (
    create_db,
    close_db,
    fill_test_db,
)


@click.command("create-db")
def create_db_command():
    create_db()


def init_db(app, uri):
    Database.set_uri(uri)
    
    app.teardown_appcontext(close_db)
    app.cli.add_command(create_db_command)
