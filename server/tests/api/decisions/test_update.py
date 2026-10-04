from flaskr.database import DecisionDataHandler
from flaskr.database.postgres import read_query
from flaskr.services.notifications import NotificationService, NotificationType
from tests.api.utils import get_auth_headers


def test_complete_decision_success(client):
    headers = get_auth_headers(client)

    response = client.patch("/decisions/1/status", headers=headers, json={"status": "completed"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision.status == "completed"
    assert decision.completedDate is not None


def test_updating_decision_status_removes_due_notification(client):
    headers = get_auth_headers(client)
    decision = DecisionDataHandler.get_decision(1)
    assert decision is not None
    notification_type = NotificationType.DecisionDue.value

    NotificationService.add_notification(notification_type, 1, decision)
    target_id = read_query(
        """
        SELECT id FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, decision.id, notification_type),
    )[0][0]
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    )

    response = client.patch(
        f"/decisions/{decision.id}/status",
        headers=headers,
        json={"status": "completed"},
    )

    assert response.status_code == 204
    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = %s;",
        (target_id,),
    ) == []
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    ) == []


def test_complete_decision_nonexistent_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/999/status", headers=headers, json={"status": "completed"})
    assert response.status_code == 404


def test_complete_decision_non_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/abc/status", headers=headers, json={"status": "completed"})
    assert response.status_code == 404


def test_pending_decision_success(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/1/status", headers=headers, json={"status": "pending"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision.status == "pending"


def test_set_completion_message_success(client):
    headers = get_auth_headers(client)
    response = client.patch(
        "/decisions/1/completion-message",
        headers=headers,
        json={"message": "Delivered during the sprint review"},
    )
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision.completionMessage == "Delivered during the sprint review"


def test_cancel_decision_success(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/1/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision.status == "cancelled"


def test_cancel_decision_already_cancelled(client):
    headers = get_auth_headers(client)

    response = client.patch("/decisions/3/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 204


def test_cancel_decision_nonexistent_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/999/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 404


def test_cancel_decision_non_numeric_id(client):
    headers = get_auth_headers(client)
    response = client.patch("/decisions/xyz/status", headers=headers, json={"status": "cancelled"})
    assert response.status_code == 404
