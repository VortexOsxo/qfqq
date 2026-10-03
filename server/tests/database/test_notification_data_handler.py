from datetime import datetime, timedelta, timezone

from flaskr.database.handlers.notification_data_handler import NotificationDataHandler
from flaskr.database.postgres import read_query
from flaskr.models import NotificationTarget, ScheduledNotification


def create_target(event_at=None):
    return NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=42,
            type="meeting_start",
            eventAt=event_at or datetime(2026, 9, 28, tzinfo=timezone.utc),
        )
    )


def test_create_notification_target_persists_target(app):
    target_id = create_target()

    assert target_id is not None
    assert read_query(
        "SELECT orgId, targetId, type FROM public.notificationsTarget WHERE id = %s;",
        (target_id,),
    ) == [(1, 42, "meeting_start")]


def test_get_notification_targets_returns_only_matching_target(app):
    event_at = datetime(2026, 10, 2, tzinfo=timezone.utc)
    target_id = NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=42,
            type="meeting_start",
            eventAt=event_at,
        )
    )
    NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=42,
            type="meeting_end",
            eventAt=event_at,
        )
    )
    NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=43,
            type="meeting_start",
            eventAt=event_at,
        )
    )
    NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=2,
            targetId=42,
            type="meeting_start",
            eventAt=event_at,
        )
    )

    assert NotificationDataHandler.get_notification_targets(
        orgId=1,
        targetId=42,
        type="meeting_start",
    ) == [
        NotificationTarget(
            id=target_id,
            orgId=1,
            targetId=42,
            type="meeting_start",
            eventAt=event_at,
        )
    ]
    assert NotificationDataHandler.get_notification_targets(
        orgId=1,
        targetId=99,
        type="meeting_start",
    ) == []


def test_update_notification_target_changes_event_time(app):
    target_id = create_target()
    updated_at = datetime(2026, 10, 1, tzinfo=timezone.utc)

    result = NotificationDataHandler.update_notification_target(
        orgId=1,
        targetId=42,
        type="meeting_start",
        eventAt=updated_at,
    )

    assert result is True
    assert read_query(
        "SELECT eventAt FROM public.notificationsTarget WHERE id = %s;",
        (target_id,),
    ) == [(updated_at,)]


def test_replace_notification_target_preserves_id_and_replaces_event_and_schedules(app):
    target_id = create_target()
    NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(
            id=0,
            userId=1,
            targetId=target_id,
            nOffset=timedelta(minutes=15),
        )
    )
    NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(
            id=0,
            userId=2,
            targetId=target_id,
            nOffset=timedelta(minutes=30),
        )
    )
    updated_at = datetime(2026, 10, 5, 14, 30, tzinfo=timezone.utc)
    updated_notifications = [
        ScheduledNotification(
            id=0,
            userId=2,
            targetId=0,
            nOffset=timedelta(hours=1),
        ),
        ScheduledNotification(
            id=0,
            userId=3,
            targetId=0,
            nOffset=timedelta(days=1),
        ),
        ScheduledNotification(
            id=0,
            userId=4,
            targetId=0,
            nOffset=timedelta(days=1),
        ),
    ]

    returned_target_id = NotificationDataHandler.replace_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=42,
            type="meeting_start",
            eventAt=updated_at,
        ),
        updated_notifications,
    )

    assert returned_target_id == target_id
    assert read_query(
        """
        SELECT id, eventAt FROM public.notificationsTarget
        WHERE orgId = %s AND targetId = %s AND type = %s;
        """,
        (1, 42, "meeting_start"),
    ) == [(target_id, updated_at)]
    assert read_query(
        """
        SELECT userId, targetId, nOffset FROM public.notifications
        WHERE targetId = %s ORDER BY userId;
        """,
        (target_id,),
    ) == [
        (2, target_id, timedelta(hours=1)),
        (3, target_id, timedelta(days=1)),
        (4, target_id, timedelta(days=1)),
    ]


def test_remove_notification_target_deletes_target_and_cascades_notifications(app):
    target_id = create_target()
    notification_id = NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(id=0, userId=1, targetId=target_id, nOffset=timedelta(minutes=15))
    )

    NotificationDataHandler.remove_notification_target(1, 42, "meeting_start")

    assert read_query("SELECT id FROM public.notificationsTarget WHERE id = %s;", (target_id,)) == []
    assert read_query("SELECT id FROM public.notifications WHERE id = %s;", (notification_id,)) == []


def test_remove_empty_notification_targets_preserves_targets_with_notifications(app):
    empty_target_id = create_target()
    referenced_target_id = NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=43,
            type="meeting_end",
            eventAt=datetime(2026, 9, 28, tzinfo=timezone.utc),
        )
    )
    NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(
            id=0,
            userId=1,
            targetId=referenced_target_id,
            nOffset=timedelta(minutes=15),
        )
    )

    NotificationDataHandler.remove_empty_notification_targets()

    assert read_query(
        "SELECT id FROM public.notificationsTarget WHERE id = ANY(%s);",
        ([empty_target_id, referenced_target_id],),
    ) == [(referenced_target_id,)]


def test_create_and_remove_scheduled_notification(app):
    target_id = create_target()
    notification_id = NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(id=0, userId=1, targetId=target_id, nOffset=timedelta(minutes=30))
    )

    assert notification_id is not None
    assert read_query(
        "SELECT userId, targetId, nOffset FROM public.notifications WHERE id = %s;",
        (notification_id,),
    ) == [(1, target_id, timedelta(minutes=30))]

    NotificationDataHandler.remove_notifications([notification_id])

    assert read_query("SELECT id FROM public.notifications WHERE id = %s;", (notification_id,)) == []


def test_remove_notifications_accepts_empty_list(app):
    NotificationDataHandler.remove_notifications([])


def test_get_pending_notifications_returns_due_target_and_schedule_pairs(app):
    now = datetime.now(timezone.utc)
    due_target_id = NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=44,
            type="meeting_start",
            eventAt=now - timedelta(minutes=30),
        )
    )
    future_target_id = NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=45,
            type="meeting_start",
            eventAt=now + timedelta(days=1),
        )
    )
    due_notification_id = NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(
            id=0,
            userId=1,
            targetId=due_target_id,
            nOffset=timedelta(minutes=15),
        )
    )
    NotificationDataHandler.create_scheduled_notification(
        ScheduledNotification(
            id=0,
            userId=1,
            targetId=future_target_id,
            nOffset=timedelta(minutes=15),
        )
    )

    pending = NotificationDataHandler.get_pending_notifications()

    assert len(pending) == 1
    target, notification = pending[0]
    assert target == NotificationTarget(
        id=due_target_id,
        orgId=1,
        targetId=44,
        type="meeting_start",
        eventAt=now - timedelta(minutes=30),
    )
    assert notification == ScheduledNotification(
        id=due_notification_id,
        userId=1,
        targetId=due_target_id,
        nOffset=timedelta(minutes=15),
    )


def test_get_pending_notifications_returns_multiple_schedules_for_same_target(app):
    now = datetime.now(timezone.utc)
    target_id = NotificationDataHandler.create_notification_target(
        NotificationTarget(
            id=0,
            orgId=1,
            targetId=46,
            type="meeting_start",
            eventAt=now - timedelta(hours=1),
        )
    )
    schedules = [
        (1, timedelta(minutes=15)),
        (2, timedelta(minutes=30)),
    ]
    notification_ids = [
        NotificationDataHandler.create_scheduled_notification(
            ScheduledNotification(
                id=0,
                userId=user_id,
                targetId=target_id,
                nOffset=offset,
            )
        )
        for user_id, offset in schedules
    ]

    pending = NotificationDataHandler.get_pending_notifications()
    target_pairs = [
        (target, notification)
        for target, notification in pending
        if target.id == target_id
    ]

    assert len(target_pairs) == 2
    assert {target.targetId for target, _ in target_pairs} == {46}
    assert {
        (notification.id, notification.userId, notification.nOffset)
        for _, notification in target_pairs
    } == {
        (notification_ids[0], 1, timedelta(minutes=15)),
        (notification_ids[1], 2, timedelta(minutes=30)),
    }