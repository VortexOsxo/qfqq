def test_accept_no_version(client):
    response = client.get("/users")
    assert response.get_json() != {"error": "Unsuported API Version"}


def test_refuse_incorrect_version(client):
    headers = {"QfqqVersion": "fake-version"}
    response = client.get("/users", headers=headers)
    assert response.status_code == 400
    assert response.get_json() == {"error": "Unsuported API Version"}


def test_accept_correct_version(client):
    headers = {"QfqqVersion": "0.0.1"}
    response = client.get("/users", headers=headers)
    assert response.get_json() != {"error": "Unsuported API Version"}
