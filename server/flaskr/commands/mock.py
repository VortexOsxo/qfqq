import click
import jwt

from flask.cli import with_appcontext
from flask import current_app
from datetime import datetime, timedelta

def get_auth_headers(client, user_id=1, org_id=1):
    app = client.application
    token = jwt.encode(
        {"user_id": user_id, "org_id": org_id}, app.config["SECRET_KEY"], algorithm="HS256"
    )
    return {"Authorization": f"Bearer {token}", "QfqqVersion": "0.0.1"}


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
        return None
    else:
        click.echo(f"Created {title}")
        return result.get_json()["id"]


def add_meeting(
    client,
    headers,
    title,
    goals,
    status,
    projectId,
    meetingLocation=None,
    meetingDate=None,
    animatorId=None,
    participantsIds=None,
):
    body = {
        "title": title,
        "goals": goals,
        "status": status,
        "projectId": projectId,
        "meetingLocation": meetingLocation,
        "animatorId": animatorId,
        "participantsIds": participantsIds or [],
        "themes": []
    }

    if meetingDate is not None:
        body["meetingDate"] = meetingDate

    if animatorId is not None:
        body["animatorId"] = animatorId
    

    result = client.post("/meeting-agendas", headers=headers, json=body)
    if result.status_code != 201:
        click.echo(f"Failed to create {title}")
        print(result.json)
        return None
    else:
        click.echo(f"Created {title}")
        return result.get_json()["id"]


def add_decision(client, headers, description, responsibleId, meetingId, dueDate):
    result = client.post(
        "/decisions",
        headers=headers,
        json={
            "description": description,
            "responsibleId": responsibleId,
            "meetingId": meetingId,
            "dueDate": dueDate,
        },
    )
    if result.status_code != 201:
        print(result)
        click.echo(f"Failed to create decision: {description}")
        print(result.get_json())
    else:
        click.echo(f"Created decision: {description}")


def create_user(client, firstname, lastname, email):
    signup_resp = client.post(
        "/auth/signup",
        headers={"QfqqVersion": "0.0.1"},
        json={
            "firstName": firstname,
            "lastName": lastname,
            "email": email,
            "password": "Password1234!",
        },
    )

    if signup_resp.status_code == 201:
        click.echo(f"Created user: {email}")
        return signup_resp.get_json()["id"]
    else:
        click.echo(f"Failed to create user {email}: {signup_resp.get_json()}")
        login_resp = client.post(
            "/auth/login",
            headers={"QfqqVersion": "0.0.1"},
            json={"email": email, "password": "Password1234!"},
        )
        if login_resp.status_code == 200:
            return login_resp.get_json()["id"]
        return None


@click.command("mock-db")
@with_appcontext
def mock_command():
    with current_app.test_client() as client:
        user_ids = {
            "camille.roy@ville-rivemont.example": create_user(
                client, "Camille", "Roy", "camille.roy@ville-rivemont.example"
            ),
            "alexandre.gagnon@ville-rivemont.example": create_user(
                client, "Alexandre", "Gagnon", "alexandre.gagnon@ville-rivemont.example"
            ),
            "sophie.tremblay@ville-rivemont.example": create_user(
                client, "Sophie", "Tremblay", "sophie.tremblay@ville-rivemont.example"
            ),
            "salut@example.com": create_user(
                client, "salut", "example", "salut@example.com"
            ),
        }
        if any(user_id is None for user_id in user_ids.values()):
            click.echo("Could not resolve all seed user IDs")
            return

        owner_email = "camille.roy@ville-rivemont.example"
        alexandre_email = "alexandre.gagnon@ville-rivemont.example"
        sophie_email = "sophie.tremblay@ville-rivemont.example"
        salut_email = "salut@example.com"
        owner_id = user_ids[owner_email]
        alexandre_id = user_ids[alexandre_email]
        sophie_id = user_ids[sophie_email]

        org_resp = client.post(
            "/organizations/",
            headers=get_auth_headers(client, user_id=owner_id, org_id=None),
            json={"organizationName": "Ville de Rivemont"},
        )
        if org_resp.status_code != 201:
            click.echo(f"Failed to create organization: {org_resp.get_json()}")
            return

        headers = {
            "Authorization": f"Bearer {org_resp.get_json()['session_token']}",
            "QfqqVersion": "0.0.1",
        }

        for email in (alexandre_email, sophie_email, salut_email):
            invite_resp = client.post(
                "/organizations/invitations",
                headers=headers,
                json={"email": email, "roleId": 1},
            )
            if invite_resp.status_code != 201:
                click.echo(f"Failed to add {email} to Ville de Rivemont: {invite_resp.get_json()}")
                return
            click.echo(f"Added {email} to Ville de Rivemont")

        projects = [
            (
                "Reamenagement de l'avenue des Forges",
                "Rendre la rue plus sure et accessible avec des trottoirs elargis et des arbres.",
                owner_id,
            ),
            (
                "Reseau cyclable du quartier des Tilleuls",
                "Relier les pistes cyclables du quartier au reseau principal de la ville.",
                owner_id,
            ),
            (
                "Traverses pietonnes du boulevard du Canal",
                "Ameliorer la securite des traversees pres des commerces et des arrets d'autobus.",
                alexandre_id,
            ),
            (
                "Renaturalisation des berges de la riviere Claire",
                "Restaurer les habitats riverains et amenager un acces public au sentier.",
                alexandre_id,
            ),
            (
                "Plan de deplacements du quartier des Jardins",
                "Evaluer les options de transport actif et collectif avec les residents.",
                sophie_id,
            ),
            (
                "Place publique du Vieux-Rivemont",
                "Creer un espace public accessible pour les residents et les visiteurs.",
                owner_id,
            ),
        ]
        project_ids = [
            add_project(client, headers, title, goals, supervisor_id)
            for title, goals, supervisor_id in projects
        ]

        now = datetime.now()
        meetings = [
            {"title": "Cadrage du reamenagement de l'avenue des Forges", "goals": "Definir les objectifs, le perimetre et les contraintes du projet.", "status": "draft", "projectId": project_ids[0]},
            {"title": "Revue des options de conception de l'avenue des Forges", "goals": "Comparer les scenarios d'amenagement et leurs impacts sur les commerces.", "status": "planned", "projectId": project_ids[0], "meetingDate": (now + timedelta(days=7)).isoformat(), "meetingLocation": "Hotel de ville de Rivemont"},
            {"title": "Atelier de conception de l'avenue des Forges", "goals": "Finaliser les priorites de conception avec les equipes municipales.", "status": "ongoing", "projectId": project_ids[0], "meetingDate": now.isoformat(), "meetingLocation": "Mediatheque Louise-Morin"},
            {"title": "Diagnostic de securite routiere du boulevard du Canal", "goals": "Examiner les collisions et les besoins des pietons et cyclistes.", "status": "completed", "projectId": project_ids[0], "meetingDate": (now - timedelta(days=14)).isoformat(), "meetingLocation": "Hotel de ville de Rivemont"},
            {"title": "Consultation sur les berges de la riviere Claire", "goals": "Recueillir les commentaires sur les acces et la restauration des habitats.", "status": "planned", "projectId": project_ids[3], "meetingDate": (now + timedelta(days=14)).isoformat(), "meetingLocation": "Centre communautaire des Forges"},
            {"title": "Scenarios de deplacements du quartier des Jardins", "goals": "Comparer les options de transport actif et collectif.", "status": "planned", "projectId": project_ids[4], "meetingDate": (now + timedelta(days=21)).isoformat(), "meetingLocation": "Centre communautaire des Jardins"},
            {"title": "Cadrage de la place publique", "goals": "Definir les besoins d'accessibilite et les usages du site.", "status": "draft", "projectId": project_ids[5]},
            {"title": "Bilan de la consultation de quartier", "goals": "Prioriser les propositions et confirmer les prochaines etapes.", "status": "completed", "projectId": project_ids[3], "meetingDate": (now - timedelta(days=7)).isoformat(), "meetingLocation": "Centre communautaire Saint-Roch"},
        ]
        meeting_ids = []
        for meeting in meetings:
            if meeting["status"] != "draft":
                meeting.update(
                    {
                        "animatorId": owner_id,
                        "participantsIds": [owner_id, alexandre_id, sophie_id],
                    }
                )
            meeting_ids.append(add_meeting(client, headers, **meeting))

        decisions = [
            ("Confirmer les criteres d'accessibilite universelle", 1, alexandre_id, 7),
            ("Preparer un calendrier de travaux compatible avec les commerces", 1, sophie_id, 5),
            ("Faire valider le scenario prefere par les services municipaux", 2, owner_id, 14),
            ("Verifier les normes de securite des traversees pietonnes", 2, sophie_id, 10),
            ("Obtenir l'avis du service de l'environnement sur les berges", 3, alexandre_id, 21),
            ("Rediger la synthese des commentaires des residents", 4, sophie_id, 7),
            ("Comparer les couts des options de transport collectif", 5, alexandre_id, 14),
            ("Proposer les prochaines etapes pour la place publique", 7, owner_id, 30),
        ]
        for description, meeting_index, responsible_id, days_until_due in decisions:
            add_decision(
                client,
                headers,
                description,
                responsible_id,
                meeting_ids[meeting_index],
                (datetime.now() + timedelta(days=days_until_due)).isoformat(),
            )
