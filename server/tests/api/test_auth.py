from werkzeug.security import generate_password_hash

from flaskr.database import UserDataHandler
from flaskr.database.postgres import get_db_access
from flaskr.utils import create_refresh_token
from tests.api.utils import get_auth_headers


def test_account_deletion_page_loads_javascript(client):
    response = client.get(
        "/auth/account/delete", headers={"Accept-Language": "en"}
    )

    assert response.status_code == 200
    assert response.mimetype == "text/html"
    assert b'<html lang="en">' in response.data
    assert b"Delete your account" in response.data
    assert b"your personal account data and organization memberships are removed" in response.data
    assert b"/static/account_deletion.js" in response.data
    assert b"/static/pages.css" in response.data
    assert client.get("/static/account_deletion.js").status_code == 200
    assert client.get("/static/pages.css").status_code == 200

    french_response = client.get(
        "/auth/account/delete", headers={"Accept-Language": "fr"}
    )
    assert french_response.status_code == 200
    assert b'<html lang="fr">' in french_response.data
    assert "Supprimer votre compte".encode() in french_response.data
    assert "vos données personnelles et vos appartenances aux organisations sont supprimées".encode() in french_response.data

    default_response = client.get("/auth/account/delete")
    assert b'<html lang="fr">' in default_response.data

    privacy_response = client.get(
        "/privacy-policy", headers={"Accept-Language": "en"}
    )
    assert privacy_response.status_code == 200
    assert b"/static/pages.css" in privacy_response.data
    assert (
        b'<a href="/auth/account/delete">/auth/account/delete</a>'
    ) in privacy_response.data
    english_link_index = privacy_response.data.index(b"You can delete your account at")
    english_notice_index = privacy_response.data.index(b"When an account is deleted")
    assert english_link_index < english_notice_index

    french_privacy_response = client.get(
        "/privacy-policy", headers={"Accept-Language": "fr"}
    )
    assert french_privacy_response.status_code == 200
    assert "Vous pouvez supprimer votre compte à l’adresse".encode() in french_privacy_response.data
    assert (
        b'<a href="/auth/account/delete">/auth/account/delete</a>'
    ) in french_privacy_response.data
    french_link_index = french_privacy_response.data.index(
        "Vous pouvez supprimer votre compte".encode()
    )
    french_notice_index = french_privacy_response.data.index(
        "compte est supprimé".encode()
    )
    assert french_link_index < french_notice_index


def test_refresh_for_user_with_organization(client):
    response = client.post(
        "/auth/refresh",
        headers={"Refresh": create_refresh_token(1), "QfqqVersion": "0.0.1"},
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body["id"] == 1
    assert body["hasOrg"] is True
    assert body["contribute"] is True
    assert body["deleteContent"] is True
    assert body["manageTeam"] is True
    assert body["session_token"]
    assert body["refresh_token"]


from flaskr.database import EmailValidationDataHandler


def test_login_required_rejects_token_for_deleted_user(client):
    user = UserDataHandler.create_user(
        "Deleted", "User", "deleted-token@example.com", generate_password_hash("password")
    )
    assert user is not None
    headers = get_auth_headers(client, user_id=user.id)

    assert client.get("/users", headers=headers).status_code == 200

    assert UserDataHandler.delete_user(user.id)

    assert client.get("/users", headers=headers).status_code == 401


def test_refresh_for_user_without_organization(client):
    EmailValidationDataHandler.create_request("unaffiliated@example.com", "123456")
    signup_response = client.post(
        "/auth/signup",
        json={
            "firstName": "Unaffiliated",
            "lastName": "User",
            "email": "unaffiliated@example.com",
            "password": "securepassword123!",
            "code": "123456",
        },
        headers={"QfqqVersion": "0.0.1"},
    )

    assert signup_response.status_code == 201
    refresh_token = signup_response.get_json()["refresh_token"]

    response = client.post(
        "/auth/refresh",
        headers={"Refresh": refresh_token, "QfqqVersion": "0.0.1"},
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body["email"] == "unaffiliated@example.com"
    assert body["hasOrg"] is False
    assert "contribute" not in body
    assert "deleteContent" not in body
    assert "manageTeam" not in body
    assert body["session_token"]
    assert body["refresh_token"]


def test_delete_account_cascades_and_invalidates_tokens(client):
    password = "securepassword123!"
    user = UserDataHandler.create_user(
        "Delete", "Me", "delete-me@example.com", generate_password_hash(password)
    )
    assert user is not None

    with get_db_access() as conn:
        conn.execute(
            "INSERT INTO public.memberships (userId, orgId) VALUES (%s, 1);",
            (user.id,),
        )
        project_id = conn.execute(
            """
            INSERT INTO projects (title, goals, supervisorId)
            VALUES ('Delete account project', 'Test cascade', %s)
            RETURNING id;
            """,
            (user.id,),
        ).fetchone()[0]
        meeting_id = conn.execute(
            """
            INSERT INTO meetings (title, status, redactionDate, animatorId, projectId)
            VALUES ('Delete account meeting', 'planned', '2026-10-25', %s, %s)
            RETURNING id;
            """,
            (user.id, project_id),
        ).fetchone()[0]
        conn.execute(
            "INSERT INTO meetingsParticipants (meetingId, userId) VALUES (1, %s);",
            (user.id,),
        )

    headers = get_auth_headers(client, user_id=user.id)
    invalid_body = client.delete("/auth/account", json=[])
    assert invalid_body.status_code == 400

    unauthorized = client.delete(
        "/auth/account",
        json={"email": user.email, "password": "not-the-password"},
    )
    assert unauthorized.status_code == 401
    assert UserDataHandler.get_user_by_id(user.id) is not None

    response = client.delete(
        "/auth/account", json={"email": user.email, "password": password}
    )
    assert response.status_code == 204
    assert UserDataHandler.get_user_by_id(user.id) is None

    with get_db_access() as conn:
        assert conn.execute(
            "SELECT id FROM projects WHERE id = %s;", (project_id,)
        ).fetchone() is None
        assert conn.execute(
            "SELECT id FROM meetings WHERE id = %s;", (meeting_id,)
        ).fetchone() is None
        assert conn.execute(
            "SELECT userId FROM meetingsParticipants WHERE userId = %s;",
            (user.id,),
        ).fetchone() is None
        assert conn.execute(
            "SELECT userId FROM public.memberships WHERE userId = %s;",
            (user.id,),
        ).fetchone() is None

    assert client.get("/users", headers=headers).status_code == 401
    assert client.post(
        "/auth/refresh",
        headers={
            "Refresh": create_refresh_token(user.id),
            "QfqqVersion": "0.0.1",
        },
    ).status_code == 401


def test_delete_account_without_organization(client):
    password = "securepassword123!"
    user = UserDataHandler.create_user(
        "No", "Organization", "no-org-delete@example.com", generate_password_hash(password)
    )
    assert user is not None

    response = client.delete(
        "/auth/account",
        json={"email": user.email, "password": password},
    )

    assert response.status_code == 204
    assert UserDataHandler.get_user_by_id(user.id) is None