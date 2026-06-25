import click

from .postgres import (
    create_db,
    close_db,
    fill_test_db,
    UserDataHandler,
    ProjectDataHandler,
    DecisionDataHandler,
    MeetingDataHandler,
    RoleDataHandler,
    OrganizationDataHandler,
)


@click.command("create-db")
def create_db_command():
    create_db()


def init_db(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(create_db_command)
