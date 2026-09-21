from datetime import timedelta

from ..postgres import write_query, read_query


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
        return results[0][0] if results else None

    @classmethod
    def get_notification_offsets(cls, userId) -> list[tuple[str, timedelta]]:
        query = "SELECT type, nOffset from public.notificationOffsets WHERE userId = %s;"
        return read_query(query, (userId,))