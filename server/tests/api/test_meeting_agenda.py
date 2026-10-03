from flaskr.services.notifications import NotificationType
from flaskr.database.handlers import NotificationDataHandler
from flaskr.database.postgres import read_query
from tests.api.utils import get_auth_headers


def test_create_meeting_draft_success(client):
    headers = get_auth_headers(client)
    payload = {"title": "Test Meeting", "status": "draft"}
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201


def test_create_meeting_draft_missing_title(client):
    headers = get_auth_headers(client)
    payload = {"status": "draft"}
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "title" in response.get_json()


def test_create_meeting_cancelled_success(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Canceled Meeting",
        "status": "canceled",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201


def test_put_planned_meeting_updates_notification_time_and_recipients(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Planned Meeting",
        "status": "planned",
        "goals": "Discuss X",
        "meetingDate": "2026-10-20T15:00:00",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [2, 3],
        "themes": [],
        "projectId": 1,
    }
    create_response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert create_response.status_code == 201
    meeting_id = create_response.get_json()["id"]

    updated_payload = {
        **payload,
        "id": meeting_id,
        "meetingDate": "2026-10-22T16:30:00",
        "participantsIds": [3, 4],
    }
    update_response = client.put(
        "/meeting-agendas",
        json=updated_payload,
        headers=headers,
    )

    assert update_response.status_code == 204
    target_rows = read_query(
        """
        SELECT id, eventAt::date FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, meeting_id, NotificationType.MeetingStart.value),
    )
    assert len(target_rows) == 1
    target_id, event_date = target_rows[0]
    assert event_date.isoformat() == "2026-10-22"
    assert read_query(
        "SELECT userId FROM public.notifications WHERE targetId = %s ORDER BY userId;",
        (target_id,),
    ) == [(1,), (3,), (4,)]


def test_patch_meeting_status_to_ongoing_removes_meeting_start_notification(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Planned Meeting",
        "status": "planned",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
        "projectId": 1,
    }

    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201

    meeting = response.get_json()
    meeting_id = meeting["id"]

    jobs = NotificationDataHandler.get_notification_targets(1, meeting_id, NotificationType.MeetingStart.value)
    assert len(jobs) == 1

    patch_response = client.patch(
        f"/meeting-agendas/{meeting_id}/status",
        json={"status": "ongoing"},
        headers=headers,
    )
    assert patch_response.status_code == 204

    jobs_after = NotificationDataHandler.get_notification_targets(1, meeting_id, NotificationType.MeetingStart.value)
    assert len(jobs_after) == 0


def test_patch_meeting_status_to_canceled_removes_meeting_start_notification(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Planned Meeting",
        "status": "planned",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
        "projectId": 1,
    }

    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201

    meeting = response.get_json()
    meeting_id = meeting["id"]

    # jobs = NotificationJobDataHandler.get_jobs_by_target(1, meeting_id, NotificationType.MeetingStart.value)
    # assert len(jobs) == 1

    patch_response = client.patch(
        f"/meeting-agendas/{meeting_id}/status",
        json={"status": "canceled"},
        headers=headers,
    )
    assert patch_response.status_code == 204

    # jobs_after = NotificationJobDataHandler.get_jobs_by_target(1, meeting_id, NotificationType.MeetingStart.value)
    # assert len(jobs_after) == 0


def test_create_meeting_ongoing_success(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201


def test_create_meeting_ongoing_no_project_success(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": [],
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 201


def test_create_meeting_ongoing_missing_goals(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1, 2],
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "goals" in response.get_json()


def test_create_meeting_ongoing_missing_animator(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "animatorId" in response.get_json()


def test_create_meeting_ongoing_invalid_participants(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": "not_a_list",
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "participantsIds" in response.get_json()


def test_create_meeting_ongoing_invalid_project(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": "not_an_id",
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "projectId" in response.get_json()


def test_create_meeting_ongoing_not_found_project(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "ongoing",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": 125,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "projectId" in response.get_json()


def test_create_meeting_invalid_status(client):
    headers = get_auth_headers(client)
    payload = {
        "title": "Test Meeting",
        "status": "invalid_status",
        "goals": "Discuss X",
        "meetingDate": "2026-03-07T15:37:06",
        "meetingLocation": "Room A",
        "animatorId": 1,
        "participantsIds": [1],
        "themes": ["Tech"],
        "projectId": 1,
    }
    response = client.post("/meeting-agendas", json=payload, headers=headers)
    assert response.status_code == 400
    assert "status" in response.get_json()


def test_create_meeting_review(client):
    headers = get_auth_headers(client, user_id=2)
    payload = {
        "objective": 4,
        "smoothRunning": 5,
        "preparation": 3,
        "length": 4,
        "respect": 5,
        "comments": "Strong teamwork and clear follow-up",
        "isAnonymous": True
    }

    response = client.post("/meeting-agendas/3/reviews", json=payload, headers=headers)
    assert response.status_code == 201

    response = client.get("/meeting-agendas/3/reviews", headers=headers)
    assert response.status_code == 200
    reviews = response.get_json()

    assert len(reviews) == 1
    review = reviews[0]
    assert review["meetingId"] == 3
    assert review["userId"] == 2
    assert review["objective"] == 4
    assert review["smoothRunning"] == 5
    assert review["preparation"] == 3
    assert review["length"] == 4
    assert review["respect"] == 5
    assert review["comments"] == "Strong teamwork and clear follow-up"


def test_get_meeting_reviews_empty(client):
    headers = get_auth_headers(client)
    response = client.get("/meeting-agendas/1/reviews", headers=headers)

    assert response.status_code == 200
    assert response.get_json() == []
