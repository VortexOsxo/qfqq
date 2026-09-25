from tests.api.utils import get_auth_headers
from flaskr.database.handlers import OrganizationDataHandler
from flaskr.services.emails import EmailSender
from threading import Event


def test_get_organization(client):
    headers = get_auth_headers(client)

    response = client.get("/organizations/", headers=headers)

    assert response.status_code == 200
    assert response.json == {"orgName": "Test"}

def test_get_organization_not_found(client):
    headers = get_auth_headers(client, user_id=1, org_id=1000)

    response = client.get("/organizations/", headers=headers)

    assert response.status_code == 404


def test_invite_with_invalid_role_id(client):
    headers = get_auth_headers(client)

    response = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "invalid-role@example.com",
            "roleId": 999999,
        },
    )

    invite = OrganizationDataHandler.get_invites(orgId=1)
    assert len(invite) == 0


def test_invite_does_not_wait_for_email(client, monkeypatch):
    email_started = Event()
    release_email = Event()

    def blocking_send(_email):
        email_started.set()
        release_email.wait(timeout=5)
        return False

    monkeypatch.setattr(EmailSender, "send_email", blocking_send)

    response = client.post(
        "/organizations/invitations",
        headers=get_auth_headers(client),
        json={
            "email": "background-email@example.com",
            "roleId": 2,
        },
    )

    assert response.status_code == 201
    assert email_started.wait(timeout=1)
    assert len(OrganizationDataHandler.get_invites(orgId=1)) == 1
    release_email.set()
