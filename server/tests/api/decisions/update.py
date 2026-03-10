import jwt
from flaskr.database import DecisionDataHandler


def get_auth_headers(client, user_id=1):
    app = client.application
    token = jwt.encode(
        {"user_id": user_id}, app.config["SECRET_KEY"], algorithm="HS256"
    )
    return {"Authorization": f"Bearer {token}", "QfqqVersion": "beta"}


def test_complete_decision_success(client):
    headers = get_auth_headers(client)

    response = client.patch("/decisions/1/status", headers=headers, json={"status": "completed"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision.status == "completed"
    assert decision.completedDate is not None


def test_complete_decision_nonexistent_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/999/status", headers=headers, json={"status": "completed"})
    assert response.status_code == 404


def test_complete_decision_non_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/abc/status", headers=headers, json={"status": "completed"})
    assert response.status_code == 404


def test_cancel_decision_success(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/1/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision.status == "cancelled"


def test_cancel_decision_already_cancelled(client):
    headers = get_auth_headers(client)

    response = client.patch("/decisions/3/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 204


def test_cancel_decision_nonexistent_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/999/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 404


def test_cancel_decision_non_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/xyz/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 404
