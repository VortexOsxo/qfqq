from tests.api.utils import get_auth_headers


def test_create_project_success(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Project",
        "goals": "Testing goals",
        "supervisorId": 1
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 201

def test_create_project_missing_title(client):
    headers = get_auth_headers(client)
    payload = {
        "goals": "Testing goals",
        "supervisorId": 1
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "title" in response.get_json()

def test_create_project_empty_title(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "   ",
        "goals": "Testing goals",
        "supervisorId": 1
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "title" in response.get_json()

def test_create_project_invalid_type_title(client):
    headers = get_auth_headers(client)
    payload = {
        "title": 123,
        "goals": "Testing goals",
        "supervisorId": 1
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "title" in response.get_json()

def test_create_project_missing_goals(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Project",
        "supervisorId": 1
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "goals" in response.get_json()

def test_create_project_empty_goals(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Project",
        "goald": "   ",
        "supervisorId": 1
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "goals" in response.get_json()

def test_create_project_missing_supervisor(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Project",
        "goals": "Testing goals"
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "supervisorId" in response.get_json()

def test_create_project_invalid_type_supervisor(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Project",
        "goals": "Testing goals",
        "supervisorId": "1"
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "supervisorId" in response.get_json()

def test_create_project_missing_supervisor_not_found(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Project",
        "goals": "Testing goals",
        "supervisorId": 999
    }
    response = client.post("/projects", json=payload, headers=headers)
    assert response.status_code == 400
    assert "supervisorId" in response.get_json()
