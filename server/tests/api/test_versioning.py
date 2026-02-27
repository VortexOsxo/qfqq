def test_refuse_no_version(client):
    response = client.get("/users")
    assert response.status_code == 400
    assert response.get_json() == {"error": "Unsuported API Version"}


def test_refuse_incorrect_version(client):
    headers = {"QfqqVersion": "fake-version"}
    response = client.get("/users", headers=headers)
    assert response.status_code == 400
    assert response.get_json() == {"error": "Unsuported API Version"}


def test_refuse_correct_version(client):
    headers = {"QfqqVersion": "beta"}
    response = client.get("/users", headers=headers)
    assert response.get_json() != {"error": "Unsuported API Version"}
