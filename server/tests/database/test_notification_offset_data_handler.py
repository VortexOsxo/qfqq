from datetime import timedelta

from flaskr.database.handlers.notification_offset_data_handler import NotificationOffsetDataHandler
from flaskr.database.postgres import read_query

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

    result = NotificationOffsetDataHandler.get_notification_offsets(userId=1)

    assert set(result) == {
        ("meeting_start", timedelta(minutes=15)),
        ("meeting_end", timedelta(minutes=30)),
    }


def test_get_notification_offsets_returns_empty_for_user_without_offsets(app):
    result = NotificationOffsetDataHandler.get_notification_offsets(userId=1)

    assert result == []