from tests.api.utils import get_auth_headers


def test_get_users_permissions(client):
    headers = get_auth_headers(client)
    response = client.get("/users/permissions", headers=headers)
    assert response.status_code == 200

    body = response.json
    print(body)
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
