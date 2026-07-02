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
    fill_test_db,
)

from .tenant_context import set_tenant


@click.command("create-db")
def create_db_command():
    create_db()


def init_db(app, uri):
    Database.init_pool(uri)

    app.teardown_appcontext(lambda e: Database.close_pool())
    app.cli.add_command(create_db_command)
