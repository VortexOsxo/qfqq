from datetime import timedelta

from ..postgres import write_query, read_query
from flaskr.services.notifications.notification_type import DEFAULT_NOTIFICATION_OFFSETS


class NotificationOffsetDataHandler:

    @classmethod
    def create_notification_offset(cls, userId, type, offset) -> bool:
        query = 'INSERT INTO public.notificationOffsets (userId, type, nOffset, isActive) VALUES (%s, %s, %s, %s)' \
        ' ON CONFLICT (userId, type) DO UPDATE SET nOffset = EXCLUDED.nOffset, isActive = EXCLUDED.isActive;'
        params = (userId, type, offset, True)
        try:
            write_query(query, params)
            return True
        except Exception:
            return False

    @classmethod
    def get_notification_offset(cls, userId, type) -> tuple[timedelta, bool]:
        query = "SELECT nOffset, isActive from public.notificationOffsets WHERE userId = %s and type = %s;"
        params = (userId, type)
        results = read_query(query, params)
        return results[0] if results else DEFAULT_NOTIFICATION_OFFSETS.get(type, (None, None))

    @classmethod
    def get_notification_offsets(cls, userId) -> list[tuple[str, timedelta, bool]]:
        query = "SELECT type, nOffset, isActive from public.notificationOffsets WHERE userId = %s;"
        results = read_query(query, (userId,))

        custom_offsets = {}
        for notification_type, nOffset, isActive in results:
            custom_offsets[notification_type] = (nOffset, isActive)

        offsets = dict(DEFAULT_NOTIFICATION_OFFSETS)
        offsets.update(custom_offsets)
        return list(offsets.items())

    @classmethod
    def update_is_active(cls, userId, type, isActive):
        if type in DEFAULT_NOTIFICATION_OFFSETS:
            query = "INSERT INTO public.notificationOffsets (userId, type, nOffset, isActive) VALUES (%s, %s, %s, %s) " \
            "ON CONFLICT (userId, type) DO UPDATE SET isActive = EXCLUDED.isActive;"
            default_offset = DEFAULT_NOTIFICATION_OFFSETS[type][0]
            write_query(query, (userId, type, default_offset, isActive))
        else:
            query = "UPDATE public.notificationOffsets SET isActive = %s WHERE userId = %s and type = %s;"
            write_query(query, (isActive, userId, type))