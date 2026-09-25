from flaskr.utils import create_refresh_token


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


def test_refresh_for_user_without_organization(client):
    signup_response = client.post(
        "/auth/signup",
        json={
            "firstName": "Unaffiliated",
            "lastName": "User",
            "email": "unaffiliated@example.com",
            "password": "securepassword123!",
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