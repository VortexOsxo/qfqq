import pytest
from flaskr.database import OrganizationDataHandler, UserDataHandler
from flaskr.errors import InputError
from flaskr.services.account_service import AccountService

VALID_SIGNUP_PAYLOAD = {
    "firstName": "John",
    "lastName": "Doe",
    "email": "newuser@example.com",
    "password": "securepassword123!",
    "code": "123456",
}


@pytest.fixture(autouse=True)
def mock_email_validation(monkeypatch):
    monkeypatch.setattr(
        AccountService, "is_email_code_valid", lambda email, code: code == "123456"
    )


def signup(client, **overrides):
    payload = {**VALID_SIGNUP_PAYLOAD, **overrides}
    return client.post("/auth/signup", json=payload, headers={"QfqqVersion": "0.0.1"})


def signup_with_invitation(client, email):
    OrganizationDataHandler.add_invite(orgId=1, email=email, roleId=2)
    return signup(client, firstName="Invited", lastName="User", email=email)


# ── firstName length tests ──────────────────────────────────────────────


def test_signup_first_name_empty(client):
    response = signup(client, firstName="", email="empty_fn@example.com")
    assert response.status_code == 400
    body = response.get_json()
    assert "firstName" in body
    assert body["firstName"] == InputError.RequiredField.value


def test_signup_first_name_medium_length(client):
    name = "A" * 25
    response = signup(client, firstName=name, email="med_fn@example.com")
    assert response.status_code == 201
    body = response.get_json()
    assert body["firstName"] == name


def test_signup_first_name_at_limit(client):
    name = "A" * 50
    response = signup(client, firstName=name, email="limit_fn@example.com")
    assert response.status_code == 201
    body = response.get_json()
    assert body["firstName"] == name


def test_signup_first_name_past_limit(client):
    name = "A" * 51
    response = signup(client, firstName=name, email="over_fn@example.com")
    assert response.status_code == 400
    body = response.get_json()
    assert "firstName" in body
    assert body["firstName"] == InputError.MaxLengthExceeded.value


# ── lastName length tests ───────────────────────────────────────────────


def test_signup_last_name_empty(client):
    response = signup(client, lastName="", email="empty_ln@example.com")
    assert response.status_code == 400
    body = response.get_json()
    assert "lastName" in body
    assert body["lastName"] == InputError.RequiredField.value


def test_signup_last_name_medium_length(client):
    name = "B" * 25
    response = signup(client, lastName=name, email="med_ln@example.com")
    assert response.status_code == 201
    body = response.get_json()
    assert body["lastName"] == name


def test_signup_last_name_at_limit(client):
    name = "B" * 50
    response = signup(client, lastName=name, email="limit_ln@example.com")
    assert response.status_code == 201
    body = response.get_json()
    assert body["lastName"] == name


def test_signup_last_name_past_limit(client):
    name = "B" * 51
    response = signup(client, lastName=name, email="over_ln@example.com")
    assert response.status_code == 400
    body = response.get_json()
    assert "lastName" in body
    assert body["lastName"] == InputError.MaxLengthExceeded.value

def test_signup_default(client):
    response = signup(client, firstName='Salut', lastName='Joe', email='salut@gmail.com', password='League028!')
    assert response.status_code == 201

    body = response.get_json()
    assert body["firstName"] == 'Salut'
    assert body["lastName"] == 'Joe'
    assert body["email"] == 'salut@gmail.com'


def test_signup_with_invitation_joins_organization(client):
    email = "invited-member@example.com"

    response = signup_with_invitation(client, email)

    assert response.status_code == 201
    assert response.get_json()["hasOrg"] is True
    user = UserDataHandler.get_user_by_email(email)
    assert user is not None
    assert OrganizationDataHandler.get_user_org_id(user.id) == 1
    assert UserDataHandler.get_user_role_id(user.id) == 2


def test_signup_with_invitation_revokes_invite(client):
    email = "invited-member@example.com"
    OrganizationDataHandler.add_invite(orgId=1, email=email, roleId=2)

    response = signup(client, firstName="Invited", lastName="User", email=email)

    assert response.status_code == 201
    assert OrganizationDataHandler.check_invite(email) == (None, None)


def test_signup_invalid_code(client):
    response = signup(client, email="invalid_code@example.com", code="WRONG_CODE")
    assert response.status_code == 400
    body = response.get_json()
    assert "code" in body


def test_signup_missing_code(client):
    payload = {**VALID_SIGNUP_PAYLOAD, "email": "missing_code@example.com"}
    payload.pop("code")
    response = client.post("/auth/signup", json=payload, headers={"QfqqVersion": "0.0.1"})
    assert response.status_code == 400
    body = response.get_json()
    assert "code" in body
    assert body["code"] == InputError.RequiredField.value
