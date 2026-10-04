from dataclasses import replace
from datetime import datetime, timedelta, timezone

from flaskr.database.postgres import read_query
from flaskr.database import DecisionDataHandler
from flaskr.database.handlers import UserDataHandler
from flaskr.models import MeetingAgenda, MeetingAgendaStatus
from flaskr.services.notifications.notification_service import NotificationService
from flaskr.services.notifications.notification_type import NotificationType
import flaskr.services.notifications.notification_service as notification_service_module


def test_add_notification_persists_target_and_scheduled_notifications(app):
    meeting = MeetingAgenda(
        id=42,
        number=1,
        title="Test meeting",
        goals="Discuss the test",
        status=MeetingAgendaStatus.planned,
        redactionDate=datetime(2026, 10, 1, tzinfo=timezone.utc),
        meetingDate=datetime(2026, 10, 3, tzinfo=timezone.utc),
        meetingLocation="Room A",
        animatorId=1,
        projectId=1,
        participantsIds=[2, 3],
        themes=[],
    )

    NotificationService.add_notification(
        NotificationType.MeetingStart.value,
        1,
        meeting,
    )

    rows = read_query(
        """
        SELECT target.orgId, target.targetId, target.type, target.eventAt,
               notification.userId, notification.targetId, notification.nOffset
        FROM public.notificationsTarget AS target
        JOIN public.notifications AS notification ON notification.targetId = target.id
        WHERE target.orgId = %s AND target.targetId = %s;
        """,
        (1, meeting.id),
    )

    assert len(rows) == 3
    assert {
        (row[0], row[1], row[2], row[3]) for row in rows
    } == {
        (
            1,
            meeting.id,
            NotificationType.MeetingStart.value,
            meeting.meetingDate,
        )
    }
    target_ids = {row[5] for row in rows}
    assert len(target_ids) == 1
    assert {(row[4], row[6]) for row in rows} == {
        (user_id, timedelta(days=1)) for user_id in (1, 2, 3)
    }


def test_update_notification_replaces_event_time_and_scheduled_recipients(app):
    meeting = MeetingAgenda(
        id=46,
        number=5,
        title="Meeting notification update",
        goals="Verify notification update",
        status=MeetingAgendaStatus.planned,
        redactionDate=datetime(2026, 10, 1, tzinfo=timezone.utc),
        meetingDate=datetime(2026, 10, 3, tzinfo=timezone.utc),
        meetingLocation="Room E",
        animatorId=1,
        projectId=1,
        participantsIds=[2, 3],
        themes=[],
    )
    notification_type = NotificationType.MeetingStart.value
    NotificationService.add_notification(notification_type, 1, meeting)

    original_target_id = read_query(
        """
        SELECT id FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, meeting.id, notification_type),
    )[0][0]
    updated_meeting = replace(
        meeting,
        meetingDate=datetime(2026, 10, 5, tzinfo=timezone.utc),
        participantsIds=[3, 4],
    )

    NotificationService.update_notification(
        notification_type,
        1,
        updated_meeting.id,
        updated_meeting,
    )

    target_rows = read_query(
        """
        SELECT id, eventAt FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, meeting.id, notification_type),
    )
    assert target_rows == [(original_target_id, updated_meeting.meetingDate)]
    assert read_query(
        """
        SELECT userId, nOffset FROM public.notifications
        WHERE targetId = %s ORDER BY userId;
        """,
        (original_target_id,),
    ) == [
        (1, timedelta(days=1)),
        (3, timedelta(days=1)),
        (4, timedelta(days=1)),
    ]


def test_update_notification_keeps_schedules_only_for_current_participants(app):
    meeting = MeetingAgenda(
        id=47,
        number=6,
        title="Meeting participant update",
        goals="Verify scheduled recipients",
        status=MeetingAgendaStatus.planned,
        redactionDate=datetime(2026, 10, 1, tzinfo=timezone.utc),
        meetingDate=datetime(2026, 10, 6, tzinfo=timezone.utc),
        meetingLocation="Room F",
        animatorId=1,
        projectId=1,
        participantsIds=[2, 3],
        themes=[],
    )
    notification_type = NotificationType.MeetingStart.value
    NotificationService.add_notification(notification_type, 1, meeting)

    target_id = read_query(
        """
        SELECT id FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, meeting.id, notification_type),
    )[0][0]
    assert read_query(
        "SELECT userId FROM public.notifications WHERE targetId = %s ORDER BY userId;",
        (target_id,),
    ) == [(1,), (2,), (3,)]

    updated_meeting = replace(meeting, participantsIds=[2, 4])
    NotificationService.update_notification(
        notification_type,
        1,
        updated_meeting.id,
        updated_meeting,
    )

    assert read_query(
        "SELECT userId FROM public.notifications WHERE targetId = %s ORDER BY userId;",
        (target_id,),
    ) == [(1,), (2,), (4,)]


def test_remove_notification_deletes_target_and_scheduled_notifications(app):
    meeting = MeetingAgenda(
        id=43,
        number=2,
        title="Notification removal test",
        goals="Verify notification cleanup",
        status=MeetingAgendaStatus.planned,
        redactionDate=datetime(2026, 10, 1, tzinfo=timezone.utc),
        meetingDate=datetime(2026, 10, 3, tzinfo=timezone.utc),
        meetingLocation="Room B",
        animatorId=1,
        projectId=1,
        participantsIds=[2, 3],
        themes=[],
    )
    notification_type = NotificationType.MeetingStart.value

    NotificationService.add_notification(notification_type, 1, meeting)

    target_rows = read_query(
        """
        SELECT id FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, meeting.id, notification_type),
    )
    assert len(target_rows) == 1
    target_id = target_rows[0][0]
    scheduled_rows = read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    )
    assert len(scheduled_rows) == 3

    NotificationService.remove_notification(notification_type, 1, meeting.id)

    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = %s;",
        (target_id,),
    ) == []
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    ) == []


def test_remove_notification_preserves_other_targets_and_scheduled_notifications(app):
    notification_type = NotificationType.MeetingStart.value
    meetings = [
        MeetingAgenda(
            id=44,
            number=3,
            title="Meeting to remove",
            goals="Verify selective removal",
            status=MeetingAgendaStatus.planned,
            redactionDate=datetime(2026, 10, 1, tzinfo=timezone.utc),
            meetingDate=datetime(2026, 10, 3, tzinfo=timezone.utc),
            meetingLocation="Room C",
            animatorId=1,
            projectId=1,
            participantsIds=[2, 3],
            themes=[],
        ),
        MeetingAgenda(
            id=45,
            number=4,
            title="Meeting to preserve",
            goals="Verify unrelated notification remains",
            status=MeetingAgendaStatus.planned,
            redactionDate=datetime(2026, 10, 1, tzinfo=timezone.utc),
            meetingDate=datetime(2026, 10, 4, tzinfo=timezone.utc),
            meetingLocation="Room D",
            animatorId=1,
            projectId=1,
            participantsIds=[2, 3],
            themes=[],
        ),
    ]

    for meeting in meetings:
        NotificationService.add_notification(notification_type, 1, meeting)

    target_ids = {
        target_id: read_query(
            """
            SELECT id FROM public.notificationsTarget
            WHERE orgId = %s AND targetId = %s AND type = %s;
            """,
            (1, target_id, notification_type),
        )[0][0]
        for target_id in (44, 45)
    }
    scheduled_ids = {
        target_id: read_query(
            "SELECT id FROM public.notifications WHERE targetId = %s ORDER BY id;",
            (database_target_id,),
        )
        for target_id, database_target_id in target_ids.items()
    }
    assert all(len(ids) == 3 for ids in scheduled_ids.values())

    NotificationService.remove_notification(notification_type, 1, 44)

    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = %s;",
        (target_ids[44],),
    ) == []
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_ids[44],),
    ) == []
    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = %s;",
        (target_ids[45],),
    ) == [(target_ids[45],)]
    assert read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s ORDER BY id;",
        (target_ids[45],),
    ) == scheduled_ids[45]


def test_send_loop_sends_pending_notification_and_deletes_records(app, monkeypatch):
    decision = DecisionDataHandler.get_decision(1)
    assert decision is not None
    UserDataHandler.upsert_user_fcm(decision.responsibleId, "test-fcm-token", "en")

    NotificationService.add_notification(
        NotificationType.DecisionDue.value,
        1,
        decision,
    )

    target_id = read_query(
        "SELECT id FROM public.notificationsTarget WHERE orgId = %s AND targetId = %s AND type = %s;",
        (1, decision.id, NotificationType.DecisionDue.value),
    )[0][0]
    scheduled_id = read_query(
        "SELECT id FROM public.notifications WHERE targetId = %s;",
        (target_id,),
    )[0][0]
    sent_notifications = []

    class StopAfterOneIteration(Exception):
        pass

    def stop_after_iteration(_):
        raise StopAfterOneIteration

    monkeypatch.setattr(
        NotificationService,
        "_send_notif",
        staticmethod(sent_notifications.append),
    )
    monkeypatch.setattr(
        notification_service_module.time,
        "sleep",
        stop_after_iteration,
    )

    try:
        NotificationService.send_loop()
    except StopAfterOneIteration:
        pass

    assert len(sent_notifications) == 1
    notification = sent_notifications[0]
    assert notification.token == "test-fcm-token"
    assert notification.title == "Decision Due Tomorrow"
    assert notification.body == "A decision due tomorrow has not been completed yet."
    assert notification.data == {
        "type": NotificationType.DecisionDue.value,
        "id": str(decision.id),
    }

    assert read_query(
        "SELECT id FROM public.notifications WHERE id = %s;",
        (scheduled_id,),
    ) == []
    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = %s;",
        (target_id,),
    ) == []
