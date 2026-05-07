from tests.api.utils import get_auth_headers


def test_get_users_permissions(client):
    headers = get_auth_headers(client)
    response = client.get("/users/permissions", headers=headers)
    assert response.status_code == 200

    body = response.json
    assert body == [
        [1, True, True, True],
        [2, True, True, False],
        [3, True, False, False],
        [4, False, False, False],
    ]


def test_get_user_permissions(client):
    headers = get_auth_headers(client)
    response = client.get("/users/1/permissions", headers=headers)
    assert response.status_code == 200

    body = response.json
    assert body == [True, True, True]


def test_update_permissions(client):
    headers = get_auth_headers(client)

    payload = {"permission_name": "canWrite", "permission_value": True}

    response = client.patch(
        "/users/4/permissions",
        json=payload,
        headers=headers,
    )
    assert response.status_code == 204

    response = client.get("/users/4/permissions", headers=headers)
    assert response.status_code == 200

    body = response.json
    assert body == [True, False, False]


def test_reject_unknown_permissions(client):
    headers = get_auth_headers(client)

    payload = {"permission_name": "canFly", "permission_value": True}

    response = client.patch(
        "/users/4/permissions",
        json=payload,
        headers=headers,
    )
    assert response.status_code == 400
    assert response.json["permission_name"] == 2


# Blocking user without permission
def test_reject_no_update_permissions_permission(client):
    headers = get_auth_headers(client, 2)
    response = client.get("/users/permissions", headers=headers)
    assert response.status_code == 403
