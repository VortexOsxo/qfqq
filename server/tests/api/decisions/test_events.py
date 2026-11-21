from datetime import datetime

import pytest

from flaskr.database import DecisionDataHandler, DecisionEventDataHandler
from flaskr.database.postgres import write_query
from tests.api.utils import get_auth_headers


def test_decision_events_route_returns_only_requested_decision(client):
    headers = get_auth_headers(client)
    response = client.post(
        "/decisions",
        headers=headers,
        json={
            "description": "Decision with history",
            "responsibleId": 1,
            "meetingId": 1,
            "dueDate": "2030-01-01",
        },
    )
    assert response.status_code == 201
    decision_id = response.get_json()["id"]

    response = client.patch(
        f"/decisions/{decision_id}/status",
        headers=get_auth_headers(client, user_id=2),
        json={"status": "pending"},
    )
    assert response.status_code == 204
    DecisionEventDataHandler.create_decision_created(1, 1)

    response = client.get(f"/decisions/{decision_id}/events", headers=headers)
    assert response.status_code == 200
    events = response.get_json()
    assert len(events) == 2
    assert [event["type"] for event in events] == ["decisionCreated", "statusUpdated"]
    assert all(event["decisionId"] == decision_id for event in events)
    assert events[0]["data"] is None
    assert events[1]["data"] == {"decisionStatus": "pending"}
    assert [event["userId"] for event in events] == [1, 2]
    assert all(datetime.fromisoformat(event["date"]).tzinfo is not None for event in events)


def test_decision_events_route_returns_empty_list(client):
    response = client.get("/decisions/999/events", headers=get_auth_headers(client))
    assert response.status_code == 200
    assert response.get_json() == []


def test_decision_events_route_requires_authentication(client):
    response = client.get("/decisions/1/events")
    assert response.status_code == 401


@pytest.mark.parametrize("status", ["pending", "completed", "cancelled"])
def test_status_update_records_event(client, status):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/1/status", headers=headers, json={"status": status})
    assert response.status_code == 204

    events = client.get("/decisions/1/events", headers=headers).get_json()
    assert len(events) == 1
    assert events[0]["type"] == "statusUpdated"
    assert events[0]["data"] == {"decisionStatus": status}
    assert events[0]["userId"] == 1


def test_missing_decision_does_not_record_event(client):
    response = client.patch(
        "/decisions/999/status", headers=get_auth_headers(client), json={"status": "pending"}
    )
    assert response.status_code == 404
    assert DecisionEventDataHandler.get_decision_events_by_id(999) == []


def test_multiple_status_updates_return_history_in_order(client):
    headers = get_auth_headers(client)
    for status in ("pending", "completed", "cancelled"):
        response = client.patch(
            "/decisions/1/status", headers=headers, json={"status": status}
        )
        assert response.status_code == 204

    response = client.get("/decisions/1/events", headers=headers)
    assert response.status_code == 200
    events = response.get_json()
    assert [event["data"]["decisionStatus"] for event in events] == [
        "pending", "completed", "cancelled"
    ]
    dates = [datetime.fromisoformat(event["date"]) for event in events]
    assert dates == sorted(dates)


def test_invalid_status_does_not_record_event(client):
    headers = get_auth_headers(client)
    response = client.patch(
        "/decisions/1/status", headers=headers, json={"status": "invalid"}
    )
    assert response.status_code == 400
    assert client.get("/decisions/1/events", headers=headers).get_json() == []


def test_deleting_decision_removes_events(client):
    headers = get_auth_headers(client)
    response = client.patch(
        "/decisions/1/status", headers=headers, json={"status": "pending"}
    )
    assert response.status_code == 204

    response = client.delete("/decisions/1", headers=headers)
    assert response.status_code == 204
    assert client.get("/decisions/1/events", headers=headers).get_json() == []


def test_status_event_failure_returns_error(client):
    write_query(
        "ALTER TABLE decisionEvents ADD CONSTRAINT reject_status "
        "CHECK (type <> 'statusUpdated');"
    )
    response = client.patch(
        "/decisions/1/status", headers=get_auth_headers(client), json={"status": "pending"}
    )

    assert response.status_code == 500
    assert DecisionDataHandler.get_decision(1).status == "pending"
    assert DecisionEventDataHandler.get_decision_events_by_id(1) == []


def test_creation_event_failure_returns_error(client):
    write_query(
        "ALTER TABLE decisionEvents ADD CONSTRAINT reject_creation "
        "CHECK (type <> 'decisionCreated');"
    )
    response = client.post(
        "/decisions",
        headers=get_auth_headers(client),
        json={
            "description": "Event write failure",
            "responsibleId": 1,
            "meetingId": 1,
            "dueDate": "2030-01-01",
        },
    )

    assert response.status_code == 500
    assert any(d.description == "Event write failure" for d in DecisionDataHandler.get_decisions())
    assert DecisionEventDataHandler.get_decision_events_by_id(2) == []
