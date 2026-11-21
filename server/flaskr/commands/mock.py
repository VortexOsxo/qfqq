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
    return {"Authorization": f"Bearer {token}", "QfqqVersion": "1.0.0"}


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
        raise click.ClickException(f"Failed to create project {title}: {result.get_json()}")
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
    themes=None,
):
    body = {
        "title": title,
        "goals": goals,
        "status": status,
        "projectId": projectId,
        "meetingLocation": meetingLocation,
        "animatorId": animatorId,
        "participantsIds": participantsIds or [],
        "themes": themes or []
    }

    if meetingDate is not None:
        body["meetingDate"] = meetingDate

    if animatorId is not None:
        body["animatorId"] = animatorId
    

    result = client.post("/meeting-agendas", headers=headers, json=body)
    if result.status_code != 201:
        raise click.ClickException(f"Failed to create meeting {title}: {result.get_json()}")
    else:
        click.echo(f"Created {title}")
        return result.get_json()["id"]


def add_decision(
    client, headers, description, responsibleId, meetingId, dueDate,
    assistantsIds=None, status="inProgress", completionMessage=None,
):
    result = client.post(
        "/decisions",
        headers=headers,
        json={
            "description": description,
            "responsibleId": responsibleId,
            "meetingId": meetingId,
            "dueDate": dueDate,
            "assistantsIds": assistantsIds or [],
        },
    )
    if result.status_code != 201:
        raise click.ClickException(f"Failed to create decision {description}: {result.get_json()}")

    decision_id = result.get_json()["id"]
    if status != "inProgress":
        result = client.patch(
            f"/decisions/{decision_id}/status", headers=headers, json={"status": status}
        )
        if result.status_code != 204:
            raise click.ClickException(f"Failed to set status for decision {description}: {result.get_json()}")
    if completionMessage is not None:
        result = client.patch(
            f"/decisions/{decision_id}/completion-message",
            headers=headers,
            json={"message": completionMessage},
        )
        if result.status_code != 204:
            raise click.ClickException(f"Failed to set completion message for decision {description}: {result.get_json()}")
    click.echo(f"Created decision: {description}")
    return decision_id


def add_decision_comment(client, headers, decision_id, comment):
    result = client.post(
        f"/decisions/{decision_id}/comment",
        headers=headers,
        json={"commentContent": comment},
    )
    if result.status_code != 201:
        raise click.ClickException(
            f"Failed to add comment to decision {decision_id}: {result.get_json()}"
        )
    click.echo(f"Added comment to decision {decision_id}")


def add_review(client, headers, meeting_id, ratings, comments, is_anonymous):
    result = client.post(
        f"/meeting-agendas/{meeting_id}/reviews",
        headers=headers,
        json={
            "objective": ratings[0],
            "smoothRunning": ratings[1],
            "preparation": ratings[2],
            "length": ratings[3],
            "respect": ratings[4],
            "comments": comments,
            "isAnonymous": is_anonymous,
        },
    )
    if result.status_code != 201:
        raise click.ClickException(f"Failed to create review for meeting {meeting_id}: {result.get_json()}")
    click.echo(f"Created review for meeting {meeting_id}")


def create_user(client, firstname, lastname, email):
    signup_resp = client.post(
        "/auth/signup",
        headers={"QfqqVersion": "1.0.0"},
        json={
            "firstName": firstname,
            "lastName": lastname,
            "email": email,
            "password": "Password1234!",
            "code": "",
        },
    )

    if signup_resp.status_code == 201:
        click.echo(f"Created user: {email}")
        return signup_resp.get_json()["id"]
    else:
        click.echo(f"Failed to create user {email}: {signup_resp.get_json()}")
        login_resp = client.post(
            "/auth/login",
            headers={"QfqqVersion": "1.0.0"},
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
            "camille.roy@rivemont.example": create_user(
                client, "Camille", "Roy", "camille.roy@rivemont.example"
            ),
            "alexandre.gagnon@rivemont.example": create_user(
                client, "Alexandre", "Gagnon", "alexandre.gagnon@rivemont.example"
            ),
            "sophie.tremblay@rivemont.example": create_user(
                client, "Sophie", "Tremblay", "sophie.tremblay@rivemont.example"
            ),
        }
        if any(user_id is None for user_id in user_ids.values()):
            click.echo("Could not resolve all seed user IDs")
            return

        owner_email = "camille.roy@rivemont.example"
        alexandre_email = "alexandre.gagnon@rivemont.example"
        sophie_email = "sophie.tremblay@rivemont.example"
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
            "QfqqVersion": "1.0.0",
        }
        org_id = jwt.decode(
            org_resp.get_json()["session_token"],
            client.application.config["SECRET_KEY"],
            algorithms=["HS256"],
        )["org_id"]

        for email in (alexandre_email, sophie_email):
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
            {"title": "Cadrage du reamenagement de l'avenue des Forges", "goals": "Definir les objectifs, le perimetre et les contraintes du projet.", "status": "draft", "projectId": project_ids[0], "themes": ["Perimetre", "Accessibilite"]},
            {"title": "Revue des options de conception de l'avenue des Forges", "goals": "Comparer les scenarios d'amenagement et leurs impacts sur les commerces.", "status": "planned", "projectId": project_ids[0], "meetingDate": (now + timedelta(days=7)).isoformat(), "meetingLocation": "Hotel de ville de Rivemont", "themes": ["Amenagement", "Commerces"]},
            {"title": "Atelier de conception de l'avenue des Forges", "goals": "Finaliser les priorites de conception avec les equipes municipales.", "status": "ongoing", "projectId": project_ids[0], "meetingDate": now.isoformat(), "meetingLocation": "Mediatheque Louise-Morin", "themes": ["Conception", "Accessibilite"]},
            {"title": "Diagnostic de securite routiere du boulevard du Canal", "goals": "Examiner les collisions et les besoins des pietons et cyclistes.", "status": "completed", "projectId": project_ids[2], "meetingDate": (now - timedelta(days=14)).isoformat(), "meetingLocation": "Hotel de ville de Rivemont", "themes": ["Securite routiere", "Traversees pietonnes"]},
            {"title": "Consultation sur les berges de la riviere Claire", "goals": "Recueillir les commentaires sur les acces et la restauration des habitats.", "status": "planned", "projectId": project_ids[3], "meetingDate": (now + timedelta(days=14)).isoformat(), "meetingLocation": "Centre communautaire des Forges", "themes": ["Environnement", "Acces public"]},
            {"title": "Scenarios de deplacements du quartier des Jardins", "goals": "Comparer les options de transport actif et collectif.", "status": "planned", "projectId": project_ids[4], "meetingDate": (now + timedelta(days=21)).isoformat(), "meetingLocation": "Centre communautaire des Jardins", "themes": ["Transport actif", "Transport collectif"]},
            {"title": "Cadrage de la place publique", "goals": "Definir les besoins d'accessibilite et les usages du site.", "status": "draft", "projectId": project_ids[5], "themes": ["Accessibilite", "Usages"]},
            {"title": "Bilan de la consultation sur les berges", "goals": "Prioriser les propositions et confirmer les prochaines etapes.", "status": "completed", "projectId": project_ids[3], "meetingDate": (now - timedelta(days=7)).isoformat(), "meetingLocation": "Centre communautaire Saint-Roch", "themes": ["Consultation", "Environnement"]},
            {"title": "Visite du reseau cyclable des Tilleuls", "goals": "Observer les liens cyclables existants.", "status": "canceled", "projectId": project_ids[1], "meetingDate": (now - timedelta(days=3)).isoformat(), "meetingLocation": "Parc des Tilleuls", "themes": ["Mobilite", "Securite"]},
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
            ("Confirmer les criteres d'accessibilite universelle", 2, alexandre_id, 7, [sophie_id], "inProgress", None),
            ("Preparer un calendrier de travaux compatible avec les commerces", 2, sophie_id, 5, [owner_id], "pending", None),
            ("Faire valider le scenario prefere par les services municipaux", 2, owner_id, 14, [], "inProgress", None),
            ("Verifier les normes de securite des traversees pietonnes", 3, sophie_id, -3, [alexandre_id], "completed", "Normes verifiees avec le service de la circulation."),
            ("Relever les collisions aux intersections du boulevard", 3, alexandre_id, -1, [], "inProgress", None),
            ("Rediger la synthese des commentaires sur les berges", 7, sophie_id, 7, [owner_id], "inProgress", None),
            ("Obtenir l'avis du service de l'environnement sur les berges", 7, alexandre_id, 21, [], "pending", None),
            ("Organiser une deuxieme consultation sur les berges", 7, owner_id, 30, [], "cancelled", None),
        ]
        decision_ids = []
        for description, meeting_index, responsible_id, days_until_due, assistants, status, message in decisions:
            decision_ids.append(add_decision(
                client,
                headers,
                description,
                responsible_id,
                meeting_ids[meeting_index],
                (now + timedelta(days=days_until_due)).isoformat(),
                assistantsIds=assistants,
                status=status,
                completionMessage=message,
            ))

        add_decision_comment(
            client,
            get_auth_headers(client, user_id=sophie_id, org_id=org_id),
            decision_ids[0],
            "J'ai confirme les principales options d'accessibilite avec les equipes concernes.",
        )
        add_decision_comment(
            client,
            get_auth_headers(client, user_id=alexandre_id, org_id=org_id),
            decision_ids[3],
            "Les normes ont ete verifiees sur le troncon concerne.",
        )

        reviews = [
            (3, owner_id, (5, 4, 5, 4, 5), "Diagnostic clair et prochaines etapes bien definies.", False),
            (3, sophie_id, (4, 3, 4, 3, 5), "Prevoir plus de temps pour discuter des intersections.", True),
            (7, alexandre_id, (4, 5, 4, 4, 5), "Les commentaires des residents ont bien ete pris en compte.", False),
            (7, sophie_id, (5, 4, 3, 4, 5), "Partager les documents de consultation plus tot.", True),
        ]
        for meeting_index, user_id, ratings, comments, is_anonymous in reviews:
            add_review(
                client,
                get_auth_headers(client, user_id=user_id, org_id=org_id),
                meeting_ids[meeting_index],
                ratings,
                comments,
                is_anonymous,
            )
