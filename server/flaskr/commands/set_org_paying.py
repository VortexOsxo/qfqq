import click
from flask.cli import with_appcontext

from flaskr.database import OrganizationDataHandler


@click.command("set-org-paying")
@click.argument("org_id", type=click.IntRange(min=1))
@click.argument(
    "is_paying",
    type=click.Choice(("true", "false"), case_sensitive=False),
)
@with_appcontext
def set_org_paying_command(org_id: int, is_paying: str):
    organization = OrganizationDataHandler.get_org(org_id)
    if organization is None:
        raise click.ClickException(f"Organization {org_id} was not found.")

    is_paying_value = is_paying.lower() == "true"
    OrganizationDataHandler.set_is_paying(org_id, is_paying_value)
    click.echo(
        f"Organization {org_id} paying status set to {str(is_paying_value).lower()}."
    )
