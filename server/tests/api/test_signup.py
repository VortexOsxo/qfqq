from flaskr.errors import InputError

VALID_SIGNUP_PAYLOAD = {
    "firstName": "John",
    "lastName": "Doe",
    "email": "newuser@example.com",
    "password": "securepassword123",
}


def signup(client, **overrides):
    payload = {**VALID_SIGNUP_PAYLOAD, **overrides}
    return client.post("/auth/signup", json=payload, headers={"QfqqVersion": "beta"})


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
