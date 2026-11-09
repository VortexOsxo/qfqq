from tests.api.utils import get_auth_headers
from flaskr.database.handlers import OrganizationDataHandler, UserDataHandler
from flaskr.database.postgres import write_query
from flaskr.services.emails import EmailSender
from flaskr.errors import InputError
from threading import Event


def test_get_organization(client):
    headers = get_auth_headers(client)

    response = client.get("/organizations/", headers=headers)

    assert response.status_code == 200
    assert response.json == {"orgName": "Test"}


def test_get_organization_status_during_free_trial(client):
    response = client.get("/organizations/status", headers=get_auth_headers(client))

    assert response.status_code == 200
    assert response.json['status'] == "freeTrialAccess"
    assert 'trialEndsAt' in response.json


def test_get_organization_status_for_paying_organization(client):
    headers = get_auth_headers(client)
    OrganizationDataHandler.set_is_paying(1, True)

    response = client.get("/organizations/status", headers=headers)

    assert response.status_code == 200
    assert response.json["status"] == "paidAccess"
    assert response.json["trialEndsAt"] is not None


def test_get_organization_status_after_trial(client):
    headers = get_auth_headers(client)
    write_query(
        "UPDATE public.organizations SET createdAt = NOW() - INTERVAL '31 days' "
        "WHERE id = %s;",
        (1,),
    )

    response = client.get("/organizations/status", headers=headers)

    assert response.status_code == 200
    assert response.json["status"] == "noAccess"
    assert response.json["trialEndsAt"] is not None


def test_get_organization_status_returns_no_access_for_unknown_organization(client):
    headers = get_auth_headers(client, user_id=1, org_id=1000)

    response = client.get("/organizations/status", headers=headers)

    assert response.status_code == 200
    assert response.json == {"status": "noAccess", "trialEndsAt": None}


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


def test_invite_user_already_in_our_organization(client):
    headers = get_auth_headers(client, user_id=1, org_id=1)

    response = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "bob@example.com",
            "roleId": 2,
        },
    )

    assert response.status_code == 400
    assert response.json == {"email": InputError.UserAlreadyInOurOrganization.value}


def test_invite_user_already_in_other_organization(client):
    headers = get_auth_headers(client, user_id=1, org_id=1)

    other_org_id = OrganizationDataHandler.create_organization("OtherOrg")
    assert other_org_id is not None
    user = UserDataHandler.create_user("Other", "User", "other_org_user@example.com", "hash123")
    assert user is not None
    success = UserDataHandler.add_user_to_org(user.id, other_org_id, 2)
    assert success is True

    response = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "other_org_user@example.com",
            "roleId": 2,
        },
    )

    assert response.status_code == 400
    assert response.json == {"email": InputError.UserAlreadyInOtherOrganization.value}


def test_invite_existing_user_without_organization(client):
    headers = get_auth_headers(client, user_id=1, org_id=1)

    user = UserDataHandler.create_user("Solo", "User", "solo_user@example.com", "hash123")
    assert user is not None

    response = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "solo_user@example.com",
            "roleId": 2,
        },
    )

    assert response.status_code == 201
    assert 1 == OrganizationDataHandler.get_user_org_id(user.id)


def test_invite_user_already_invited_to_our_organization(client):
    headers = get_auth_headers(client, user_id=1, org_id=1)

    response = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "already_invited_our@example.com",
            "roleId": 2,
        },
    )
    assert response.status_code == 201

    response2 = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "already_invited_our@example.com",
            "roleId": 2,
        },
    )
    assert response2.status_code == 400
    assert response2.json == {"email": InputError.UserAlreadyInvitedToOurOrganization.value}


def test_invite_user_already_invited_to_other_organization(client):
    headers = get_auth_headers(client, user_id=1, org_id=1)

    OrganizationDataHandler.add_invite(2, "already_invited_other@example.com", 2)

    response = client.post(
        "/organizations/invitations",
        headers=headers,
        json={
            "email": "already_invited_other@example.com",
            "roleId": 2,
        },
    )
    assert response.status_code == 400
    assert response.json == {"email": InputError.UserAlreadyInvitedToOtherOrganization.value}
