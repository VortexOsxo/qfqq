from flaskr.database import DecisionDataHandler
from tests.api.utils import get_auth_headers
from flaskr.database.postgres import read_query
from flaskr.services.notifications.notification_service import NotificationService
from flaskr.services.notifications.notification_type import NotificationType

def test_delete_decision_success(client):
    headers = get_auth_headers(client)

    response = client.delete("/decisions/1", headers=headers, json={"status": "completed"})
    assert response.status_code == 204

    decision = DecisionDataHandler.get_decision(1)
    assert decision is None




def test_delete_decision_removes_notification_target_and_schedules(client):
    headers = get_auth_headers(client)
    decision = DecisionDataHandler.get_decision(1)
    assert decision is not None

    NotificationService.add_notification(
        NotificationType.DecisionDue.value,
        1,
        decision,
    )
    target_rows = read_query(
        """
        SELECT id FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, decision.id, NotificationType.DecisionDue.value),
    )
    assert len(target_rows) == 1
    target_id = target_rows[0][0]
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    )

    response = client.delete(f"/decisions/{decision.id}", headers=headers)

    assert response.status_code == 204
    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = %s;",
        (target_id,),
    ) == []
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    ) == []
    assert DecisionDataHandler.get_decision(decision.id) is None
