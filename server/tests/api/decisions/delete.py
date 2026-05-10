from flaskr.database import DecisionDataHandler
from tests.api.utils import get_auth_headers

def test_delete_decision_success(client):
    headers = get_auth_headers(client)

    response = client.delete("/decisions/1", headers=headers, json={"status": "completed"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision is None