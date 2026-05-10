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


def test_get_users_roles(client):
    headers = get_auth_headers(client, user_id=1)
    response = client.get("/users/roles", headers=headers)
    assert response.status_code == 200

    roles = response.get_json()
    assert roles == [
        {"roleId": 2, "roleName": "Admin", "userId": 1},
        {"roleId": 3, "roleName": "Manager", "userId": 2},
        {"roleId": 4, "roleName": "Contributor", "userId": 3},
        {"roleId": 5, "roleName": "Viewer", "userId": 4},
    ]
