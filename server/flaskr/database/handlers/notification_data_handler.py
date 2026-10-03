from datetime import datetime

from ..postgres import get_db_access, read_query, write_query
from flaskr.models import NotificationTarget, ScheduledNotification


class NotificationDataHandler:

    # NotificationsTarget
    @classmethod
    def create_notification_target(cls, target: NotificationTarget) -> int | None:
        query = (
            "INSERT INTO public.notificationsTarget (orgId, targetId, type, eventAt) "
            "VALUES (%s, %s, %s, %s) RETURNING id;"
        )
        try:
            with get_db_access() as conn:
                row = conn.execute(query, (target.orgId, target.targetId, target.type, target.eventAt)).fetchone()
                return row[0]
        except Exception:
            return None

    @classmethod
    def get_notification_targets(cls, orgId, targetId, type):
        query = """
            SELECT id, orgId, targetId, type, eventAt FROM public.notificationsTarget 
            WHERE orgId = %s AND targetId = %s AND type = %s;
        """
        params = (orgId, targetId, type)
        results = read_query(query, params)
        return [NotificationTarget(*n) for n in results]

    @classmethod
    def update_notification_target(cls, orgId, targetId, type, eventAt: datetime) -> bool:
        query = "UPDATE public.notificationsTarget SET eventAt = %s WHERE orgId = %s AND targetId = %s AND type = %s;"
        try:
            write_query(query, (eventAt, orgId, targetId, type))
            return True
        except Exception:
            return False

    @classmethod
    def replace_notification_target(
        cls,
        target: NotificationTarget,
        notifications: list[ScheduledNotification],
    ) -> int | None:
        with get_db_access() as conn:
            row = conn.execute(
                """
                INSERT INTO public.notificationsTarget (orgId, targetId, type, eventAt)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (orgId, targetId, type)
                DO UPDATE SET eventAt = EXCLUDED.eventAt
                RETURNING id;
                """,
                (target.orgId, target.targetId, target.type, target.eventAt),
            ).fetchone()
            target_id = row[0]

            conn.execute(
                "DELETE FROM public.notifications WHERE targetId = %s;",
                (target_id,),
            )

            conn.cursor().executemany(
                """
                INSERT INTO public.notifications (userId, targetId, nOffset)
                VALUES (%s, %s, %s);
                """,
                [
                    (notification.userId, target_id, notification.nOffset)
                    for notification in notifications
                ],
            )

            return target_id

    @classmethod
    def remove_notification_target(cls, orgId: int, targetId: int, type: str) -> None:
        write_query(
            "DELETE FROM public.notificationsTarget WHERE orgId = %s AND targetId = %s AND type = %s;",
            (orgId, targetId, type)
        )

    @classmethod
    def remove_empty_notification_targets(cls) -> None:
        query = (
            "DELETE FROM public.notificationsTarget AS target "
            "WHERE NOT EXISTS ("
            "   SELECT 1 FROM public.notifications AS notification "
            "   WHERE notification.targetId = target.id"
            ");"
        )
        write_query(query)

    # Notifications
    @classmethod
    def create_scheduled_notification(cls, notification: ScheduledNotification) -> int | None:
        query = (
            "INSERT INTO public.notifications "
            "(userId, targetId, nOffset) "
            "VALUES (%s, %s, %s) RETURNING id;"
        )
        try:
            with get_db_access() as conn:
                params = (notification.userId, notification.targetId, notification.nOffset)
                row = conn.execute(query, params).fetchone()
                return row[0]
        except Exception:
            return None

    @classmethod
    def remove_notifications(cls, notificationIds: list[int]) -> None:
        if not notificationIds:
            return

        query = "DELETE FROM public.notifications WHERE id = ANY(%s);"
        write_query(query, (notificationIds,))
        
    @classmethod
    def get_pending_notifications(cls):
        query = """
            SELECT
                target.id, target.orgId, target.targetId, target.type, target.eventAt,
                notification.id, notification.userId, notification.targetId, notification.nOffset
            FROM public.notifications AS notification
            JOIN public.notificationsTarget AS target
                ON notification.targetId = target.id
            WHERE target.eventAt - notification.nOffset <= NOW();
        """
        rows = read_query(query)
        return [
            (NotificationTarget(*row[:5]), ScheduledNotification(*row[5:]))
            for row in rows
        ]
