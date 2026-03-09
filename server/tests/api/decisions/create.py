import jwt
from flaskr.utils.time import time_now_to_string

def get_auth_headers(client, user_id=1):
    app = client.application
    token = jwt.encode({"user_id": user_id}, app.config["SECRET_KEY"], algorithm="HS256")
    return {
        "Authorization": f"Bearer {token}",
        "QfqqVersion": "beta"
    }

def test_create_decision_success(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "responsibleId": 1,
        "meetingId": 1,
        "dueDate": time_now_to_string()
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 201

def test_create_decision_missing_description(client):
    headers = get_auth_headers(client)
    payload = {
        "responsibleId": 1,
        "meetingId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "description" in response.get_json()

def test_create_decision_empty_description(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "   ",
        "responsibleId": 1,
        "meetingId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "description" in response.get_json()

def test_create_decision_invalid_type_description(client):
    headers = get_auth_headers(client)
    payload = {
        "description": 123,
        "responsibleId": 1,
        "meetingId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "description" in response.get_json()

def test_create_decision_missing_due_date(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "hello",
        "responsibleId": 1,
        "meetingId": 1,
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "dueDate" in response.get_json() 

def test_create_decision_invalid_type_due_date(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "hello",
        "responsibleId": 1,
        "meetingId": 1,
        "dueDate": -1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "dueDate" in response.get_json()

def test_create_decision_invalid_format_due_date(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "hello",
        "responsibleId": 1,
        "meetingId": 1,
        "dueDate": "29-05-2025"
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "dueDate" in response.get_json()

def test_create_decision_missing_responsible(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "meetingId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "responsibleId" in response.get_json()

def test_create_decision_invalid_type_responsible(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "responsibleId": "1",
        "meetingId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "responsibleId" in response.get_json()

def test_create_decision_missing_responsible_not_found(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "responsibleId": 999,
        "meetingId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "responsibleId" in response.get_json()

def test_create_decision_missing_meeting(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "responsibleId": 1
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "meetingId" in response.get_json()

def test_create_decision_invalid_type_meeting(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "responsibleId": 1,
        "meetingId": "1"
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "meetingId" in response.get_json()

def test_create_decision_missing_meeting_not_found(client):
    headers = get_auth_headers(client)
    payload = {
        "description": "Test Decision",
        "responsibleId": 1,
        "meetingId": 999
    }
    response = client.post("/decisions", json=payload, headers=headers)
    assert response.status_code == 400
    assert "meetingId" in response.get_json()
