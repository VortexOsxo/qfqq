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


def test_update_user_notification_offset(client):
    headers = get_auth_headers(client, user_id=1)
    response = client.post(
        "/users/settings/notifications-offset",
        json={"type": "meeting_start", "offset": "15 minutes"},
        headers=headers,
    )

    assert response.status_code == 204


def test_get_user_notification_offset(client):
    headers = get_auth_headers(client, user_id=1)
    client.post(
        "/users/settings/notifications-offset",
        json={"type": "meeting_start", "offset": "15 minutes"},
        headers=headers,
    )

    response = client.get(
        "/users/settings/notifications-offset/meeting_start",
        headers=headers,
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body['type'] == 'meeting_start'
    assert body['offset'] == 15*60


def test_get_user_notifications_offset(client):
    headers = get_auth_headers(client, user_id=1)
    client.post(
        "/users/settings/notifications-offset",
        json={"type": "meeting_start", "offset": "15 minutes"},
        headers=headers,
    )

    client.post(
        "/users/settings/notifications-offset",
        json={"type": "meeting_end", "offset": "10 minutes"},
        headers=headers,
    )

    response = client.get(
        "/users/settings/notifications-offset",
        headers=headers,
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body[0]['type'] == 'meeting_start'
    assert body[0]['offset'] == 15*60
    assert body[1]['type'] == 'meeting_end'
    assert body[1]['offset'] == 10*60
