from flaskr.models import NotificationJob
from ..postgres import get_db_access, read_query, write_query
from datetime import datetime


class NotificationJobDataHandler:

    @classmethod
    def create_notification_job(
        cls,
        orgId: int,
        targetId: int,
        type: str,
        payload: str,
        scheduledAt: datetime,
    ) -> NotificationJob | None:
        query = (
            "INSERT INTO public.notificationJobs (orgId, targetId, type, payload, scheduledAt) "
            "VALUES (%s, %s, %s, %s, %s) RETURNING id;"
        )
        params = (orgId, targetId, type, payload, scheduledAt)
        try:
            with get_db_access() as conn:
                cur = conn.cursor()
                cur.execute(query, params)
                row = cur.fetchone()
                if not row:
                    return None
                jobId = row[0]
            return NotificationJob(
                id=jobId,
                orgId=orgId,
                targetId=targetId,
                type=type,
                payload=payload,
                scheduledAt=scheduledAt,
                sentAt=None,
            )
        except Exception:
            return None

    @classmethod
    def get_pending_jobs(cls) -> list[NotificationJob]:
        query = (
            "SELECT id, orgId, targetId, type, payload, scheduledAt, sentAt "
            "FROM public.notificationJobs WHERE sentAt IS NULL AND scheduledAt <= NOW() "
            "ORDER BY scheduledAt ASC;"
        )
        rows = read_query(query)
        return [NotificationJob(*row) for row in rows]

    @classmethod
    def get_jobs_by_target(cls, orgId: int, targetId: int, type: str) -> list[NotificationJob]:
        query = (
            "SELECT id, orgId, targetId, type, payload, scheduledAt, sentAt "
            "FROM public.notificationJobs WHERE orgId = %s AND targetId = %s AND type = %s "
            "ORDER BY scheduledAt ASC;"
        )
        rows = read_query(query, (orgId, targetId, type))
        return [NotificationJob(*row) for row in rows]

    @classmethod
    def update_job(cls, jobId: int, job: NotificationJob) -> bool:
        """Replace the data of an existing notification job by its ID."""
        query = (
            "UPDATE public.notificationJobs "
            "SET orgId = %s, targetId = %s, type = %s, payload = %s, scheduledAt = %s "
            "WHERE id = %s;"
        )
        params = (job.orgId, job.targetId, job.type, job.payload, job.scheduledAt, jobId)
        try:
            write_query(query, params)
            return True
        except Exception:
            return False

    @classmethod
    def mark_as_sent(cls, jobId: int, sentAt: datetime = None) -> bool:
        timestamp = sentAt or datetime.utcnow()
        query = "UPDATE public.notificationJobs SET sentAt = %s WHERE id = %s;"
        params = (timestamp, jobId)
        write_query(query, params)

    @classmethod
    def mark_many_as_sent(cls, jobIds: list[int], sentAt: datetime = None) -> bool:
        if not jobIds: return

        timestamp = sentAt or datetime.utcnow()
        query = "UPDATE public.notificationJobs SET sentAt = %s WHERE id = ANY(%s);"
        params = (timestamp, jobIds)
        write_query(query, params)
