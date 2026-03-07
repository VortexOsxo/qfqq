import jwt


def get_auth_headers(client, user_id=1):
    app = client.application
    token = jwt.encode(
        {"user_id": user_id}, app.config["SECRET_KEY"], algorithm="HS256"
    )
    return {"Authorization": f"Bearer {token}", "QfqqVersion": "beta"}


def test_create_meeting_draft_success(client):
    headers = get_auth_headers(client)
    payload = {"title": "Test Meeting", "status": "draft"}
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201


def test_create_meeting_draft_missing_title(client):
    headers = get_auth_headers(client)
    payload = {"status": "draft"}
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "title" in response.get_json()


def test_create_meeting_ongoing_success(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201

def test_create_meeting_ongoing_no_project_success(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201

def test_create_meeting_ongoing_missing_goals(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "goals" in response.get_json()


def test_create_meeting_ongoing_missing_animator(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "animatorId" in response.get_json()


def test_create_meeting_ongoing_invalid_participants(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": "not_a_list",
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "participantsIds" in response.get_json()


def test_create_meeting_ongoing_invalid_project(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": "not_an_id",
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "projectId" in response.get_json()

def test_create_meeting_ongoing_not_found_project(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": 125,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "projectId" in response.get_json()

def test_create_meeting_invalid_status(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "invalid_status",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "status" in response.get_json()
