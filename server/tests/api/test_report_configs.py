from tests.api.utils import get_auth_headers


def test_create_and_get_report_configs(client):
    headers = get_auth_headers(client)
    query_params = {
        "name": "Finished tasks",
        "columns": "{1, 3}",
        "status": "completed",
        "responsibleId": "3",
        "showComments": "true",
    }

    create_response = client.post(
        "/reports/configs",
        query_string=query_params,
        headers=headers,
    )

    assert create_response.status_code == 201
    created_config = create_response.get_json()
    assert created_config["name"] == query_params["name"]
    assert created_config["columns"] == [1, 3]
    assert created_config["filters"] == {
        "status": "completed",
        "responsibleId": 3,
    }
    assert created_config["showReviews"] is True

    get_response = client.get("/reports/configs", headers=headers)

    assert get_response.status_code == 200
    assert created_config in get_response.get_json()


def test_create_report_config_defaults_show_reviews_to_false(client):
    headers = get_auth_headers(client)
    response = client.post(
        "/reports/configs",
        query_string={"name": "Basic report"},
        headers=headers,
    )

    assert response.status_code == 201
    assert response.get_json()["showReviews"] is False


def test_delete_report_config(client):
    headers = get_auth_headers(client)
    create_response = client.post(
        "/reports/configs",
        query_string={"name": "Config to delete"},
        headers=headers,
    )
    config_id = create_response.get_json()["id"]

    response = client.delete(f"/reports/configs/{config_id}", headers=headers)

    assert response.status_code == 204
    configs_response = client.get("/reports/configs", headers=headers)
    assert all(config["id"] != config_id for config in configs_response.get_json())
