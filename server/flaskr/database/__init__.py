import click
import os

database = os.environ.get("database")
if database == "sqlite":
    from .sqlite import create_db, close_db, UserDataHandler
elif database == "mongo":
    from .mongo import (
        create_db,
        close_db,
        UserDataHandler,
        DecisionDataHandler,
        MeetingAgendaDataHandler,
        ProjectDataHandler,
        ValueFilter,
        IdFilter,
        ValueUpdater,
        ListContainsValueFilter,
    )
elif database == "postgres":
    from .postgres import (
        create_db,
        close_db,
        UserDataHandler,
        ProjectDataHandler,
        DecisionDataHandler,
        MeetingDataHandler,
    )
    MeetingAgendaDataHandler = ...
    ValueFilter = ...
    IdFilter = ...
    ValueUpdater  =...
    ListContainsValueFilter = ...
else:
    raise ValueError("Invalid database type")


@click.command("create-db")
def create_db_command():
    create_db()


def init_db(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(create_db_command)
