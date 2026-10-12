from datetime import timedelta

from flaskr.database.handlers.notification_offset_data_handler import NotificationOffsetDataHandler

from flaskr.database.postgres import read_query
from flaskr.services.notifications.notification_type import NotificationType, DEFAULT_NOTIFICATION_OFFSETS

def test_every_notification_type_as_a_default_offset():
    assert len(DEFAULT_NOTIFICATION_OFFSETS) == len(NotificationType), "Every notification type should have a default offset"

def test_create_notification_offset_accepts_valid_duration_string(app):
    result = NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="meeting_start",
        offset="15 minutes",
    )

    assert result is True
    rows = read_query(
        'SELECT userId, type, nOffset FROM public.notificationOffsets '
        "WHERE userId = %s AND type = %s;",
        (1, "meeting_start"),
    )
    assert rows == [(1, "meeting_start", timedelta(seconds=900))]


def test_create_notification_offset_rejects_invalid_duration_string(app):
    result = NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="meeting_end",
        offset="not-a-duration",
    )

    assert result is False


def test_get_notification_offser_returns_existing_offset(app):
    NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="meeting_start",
        offset="15 minutes",
    )

    result = NotificationOffsetDataHandler.get_notification_offset(
        userId=1,
        type="meeting_start",
    )

    assert result == timedelta(minutes=15)


def test_get_notification_offser_returns_empty_when_offset_does_not_exist(app):
    result = NotificationOffsetDataHandler.get_notification_offset(
        userId=1,
        type="meeting_end",
    )

    assert result is None


def test_create_notification_offset_upserts_existing_offset(app):
    result = NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="upsert_test",
        offset="10 minutes",
    )

    assert result is True
    assert NotificationOffsetDataHandler.get_notification_offset(
        userId=1,
        type="upsert_test",
    ) == timedelta(minutes=10)

    result = NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="upsert_test",
        offset="30 minutes",
    )

    assert result is True
    assert NotificationOffsetDataHandler.get_notification_offset(
        userId=1,
        type="upsert_test",
    ) == timedelta(minutes=30)


def test_create_notification_offset_allows_same_user_with_different_type(app):
    first_result = NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="first_type",
        offset="15 minutes",
    )
    second_result = NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="second_type",
        offset="30 minutes",
    )

    assert first_result is True
    assert second_result is True
    assert NotificationOffsetDataHandler.get_notification_offset(
        userId=1,
        type="first_type",
    ) == timedelta(minutes=15)
    assert NotificationOffsetDataHandler.get_notification_offset(
        userId=1,
        type="second_type",
    ) == timedelta(minutes=30)


def test_get_notification_offsets_returns_all_user_offsets(app):
    NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="meeting_start",
        offset="15 minutes",
    )
    NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type="meeting_end",
        offset="30 minutes",
    )

    NotificationOffsetDataHandler.create_notification_offset(
        userId=2,
        type="meeting_end",
        offset="20 minutes",
    )
    NotificationOffsetDataHandler.create_notification_offset(
        userId=1,
        type=NotificationType.MeetingStart.value,
        offset="30 minutes",
    )

    result = NotificationOffsetDataHandler.get_notification_offsets(userId=1)

    assert dict(result) == {
        **DEFAULT_NOTIFICATION_OFFSETS,
        "meeting_start": timedelta(minutes=15),
        "meeting_end": timedelta(minutes=30),
        NotificationType.MeetingStart.value: timedelta(minutes=30),
    }


def test_get_notification_offsets_returns_defaults_for_user_without_offsets(app):
    result = NotificationOffsetDataHandler.get_notification_offsets(userId=1)

    assert dict(result) == {
        NotificationType.DecisionDue.value: timedelta(days=1),
        NotificationType.MeetingStarted.value: timedelta(0),
        NotificationType.MeetingStart.value: timedelta(minutes=15),
    }

def test_get_notification_offset_return_default_value(app):
    result = NotificationOffsetDataHandler.get_notification_offset(userId=1, type = NotificationType.MeetingStart.value)
    assert result == DEFAULT_NOTIFICATION_OFFSETS[NotificationType.MeetingStart.value]
