import click
import jwt

from flask.cli import with_appcontext
from flask import current_app

def get_auth_headers(client, user_id=1, org_id=1):
    app = client.application
    token = jwt.encode(
        {"user_id": user_id, "org_id": org_id}, app.config["SECRET_KEY"], algorithm="HS256"
    )
    return {"Authorization": f"Bearer {token}", "QfqqVersion": "beta"}


def add_project(client, headers, title, goals, supervisorId):
    result = client.post(
        "/projects",
        headers=headers,
        json={
            "title": title,
            "goals": goals,
            "supervisorId": supervisorId,
        },
    )
    if result.status_code != 201:
        click.echo(f"Failed to create {title}")
    else:
        click.echo(f"Created {title}")


@click.command("mock-db")
@with_appcontext
def mock_command():
    with current_app.test_client() as client:
        org_resp = client.post(
            "/organizations/",
            headers={"QfqqVersion": "beta"},
            json={"organizationName": "Organization1"},
        )
        if org_resp.status_code != 201:
            click.echo(f"Failed to create organization: {org_resp.get_json()}")
            return

        orgId = org_resp.get_json()["orgId"]
        click.echo(f"Created organization with slug: {orgId}")

        # Create Users
        users = [
            ("Salut", "Hi", "salut@gmail.com"),
            ("Bobby", "Ho", "bobby@gmail.com"),
            ("Greg", "Ha", "greg@gmail.com"),
            ("Lyne", "Dahan", "lyne@gmail.com")
        ]

        password = "Password1234!"

        index = 1
        for first, last, email in users:
            signup_resp = client.post(
                "/auth/signup",
                headers={"QfqqVersion": "beta"},
                json={
                    "firstName": first,
                    "lastName": last,
                    "email": email,
                    "password": password,
                },
            )

            if signup_resp.status_code == 201:
                click.echo(f"Created user: {email}")
            else:
                click.echo(f"Failed to create user {email}: {signup_resp.get_json()}")

            join_resp = client.post(
                "/organizations/1/join",
                headers = get_auth_headers(client, user_id=index)
            )

            if join_resp.status_code == 201:
                click.echo(f"User: {email} joined Organization1")
            else:
                click.echo(f"User: {email} failed to join Organization1: {join_resp.get_json()}")
            index += 1

        # Create project
        headers = get_auth_headers(client)

        add_project(
            client=client,
            headers=headers,
            title="Projet1",
            goals="Objectif du projet1",
            supervisorId=1,
        )

        add_project(
            client=client,
            headers=headers,
            title="Projet2",
            goals="Objectif du projet2",
            supervisorId=1,
        )

        add_project(
            client=client,
            headers=headers,
            title = "Troisieme lien",
            goals = "Developement d'un troisieme pont pour la ville de quebec",
            supervisorId = 2,
        )
