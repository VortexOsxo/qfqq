from tests.api.utils import get_auth_headers


def test_get_roles_success(client):
    headers = get_auth_headers(client, user_id=1)
    response = client.get("/roles", headers=headers)

    assert response.status_code == 200
    roles = response.get_json()
    assert isinstance(roles, list)
    assert len(roles) >= 5

    assert roles[1]["name"] == "Admin"
    assert roles[1]["canWrite"]
    assert roles[1]["canDelete"]
    assert roles[1]["canUpdatePermissions"]


def test_get_roles_forbidden(client):
    headers = get_auth_headers(client, user_id=2)
    response = client.get("/roles", headers=headers)
    assert response.status_code == 403


def test_get_role_success(client):
    headers = get_auth_headers(client, user_id=1)
    response = client.get("/roles/3", headers=headers)

    assert response.status_code == 200
    role = response.get_json()

    assert role["name"] == "Manager"
    assert role["canWrite"]
    assert role["canDelete"]
    assert not role["canUpdatePermissions"]


def test_get_role_not_found(client):
    headers = get_auth_headers(client, user_id=1)
    response = client.get("/roles/999", headers=headers)
    assert response.status_code == 404


def test_get_role_forbidden(client):
    headers = get_auth_headers(client, user_id=2)
    response = client.get("/roles/2", headers=headers)
    assert response.status_code == 403


def test_create_role_success(client):
    headers = get_auth_headers(client, user_id=1)
    payload = {
        "name": "NewRole",
        "canWrite": True,
        "canDelete": False,
        "canUpdatePermissions": False,
    }
    response = client.post("/roles", json=payload, headers=headers)
    assert response.status_code == 201
    role = response.get_json()
    assert role["name"] == "newrole"
    assert role["canWrite"] is True


def test_create_role_forbidden(client):
    headers = get_auth_headers(client, user_id=2)
    payload = {
        "name": "NewRole",
        "canWrite": True,
        "canDelete": False,
        "canUpdatePermissions": False,
    }
    response = client.post("/roles", json=payload, headers=headers)
    assert response.status_code == 403


def test_create_role_invalid_data(client):
    headers = get_auth_headers(client, user_id=1)
    payload = {
        "name": "NewRole",
        "canWrite": "not-a-bool",
        "canDelete": False,
        "canUpdatePermissions": False,
    }
    response = client.post("/roles", json=payload, headers=headers)
    assert response.status_code == 400


def test_update_role_success(client):
    headers = get_auth_headers(client, user_id=1)
    payload = {"permission_name": "canWrite", "permission_value": False}
    response = client.patch("/roles/3", json=payload, headers=headers)
    assert response.status_code == 204

    get_res = client.get("/roles/3", headers=headers)
    assert get_res.status_code == 200
    assert not get_res.get_json()["canWrite"]


def test_update_role_forbidden(client):
    headers = get_auth_headers(client, user_id=2)
    payload = {"permission_name": "canWrite", "permission_value": False}
    response = client.patch("/roles/3", json=payload, headers=headers)
    assert response.status_code == 403


def test_update_role_invalid_permission_name(client):
    headers = get_auth_headers(client, user_id=1)
    payload = {"permission_name": "invalidPermission", "permission_value": False}
    response = client.patch("/roles/3", json=payload, headers=headers)
    assert response.status_code == 400
    assert response.json["permission_name"] == 2


def test_delete_role_success(client):
    headers = get_auth_headers(client, user_id=1)
    role_id = 6

    response = client.delete(f"/roles/{role_id}", headers=headers)
    assert response.status_code == 204

    get_res = client.get(f"/roles/{role_id}", headers=headers)
    assert get_res.status_code == 404


def test_delete_used_role(client):
    headers = get_auth_headers(client, user_id=1)
    role_id = 2

    response = client.delete(f"/roles/{role_id}", headers=headers)
    assert response.status_code == 400


def test_delete_role_forbidden(client):
    headers = get_auth_headers(client, user_id=2)
    response = client.delete("/roles/4", headers=headers)
    assert response.status_code == 403
