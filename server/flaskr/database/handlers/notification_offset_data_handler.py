from datetime import timedelta

from ..postgres import write_query, read_query
from flaskr.services.notifications.notification_type import DEFAULT_NOTIFICATION_OFFSETS


class NotificationOffsetDataHandler:

    @classmethod
    def create_notification_offset(cls, userId, type, offset) -> bool:
        query = 'INSERT INTO public.notificationOffsets (userId, type, nOffset) VALUES (%s, %s, %s)' \
        ' ON CONFLICT (userId, type) DO UPDATE SET nOffset = EXCLUDED.nOffset;'
        params = (userId, type, offset)
        try:
            write_query(query, params)
            return True
        except Exception:
            return False

    @classmethod
    def get_notification_offset(cls, userId, type) -> timedelta:
        query = "SELECT nOffset from public.notificationOffsets WHERE userId = %s and type = %s;"
        params = (userId, type)
        results = read_query(query, params)
        return results[0][0] if results else DEFAULT_NOTIFICATION_OFFSETS.get(type)

    @classmethod
    def get_notification_offsets(cls, userId) -> list[tuple[str, timedelta]]:
        query = "SELECT type, nOffset from public.notificationOffsets WHERE userId = %s;"
        result = read_query(query, (userId,))
        offsets = dict(DEFAULT_NOTIFICATION_OFFSETS)
        offsets.update(result)
        return list(offsets.items())