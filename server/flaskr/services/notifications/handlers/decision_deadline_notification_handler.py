from flaskr.models import NotificationJob, Notification, Decision
from flaskr.database import DecisionDataHandler, set_tenant

from ..notification_type import NotificationType

from datetime import timedelta


class DecisionDueNotificationHandler:
    def create(self, orgId, decision: Decision):
        return NotificationJob(
            -1,
            orgId,
            decision.id,
            NotificationType.DecisionDue.value,
            "",
            decision.dueDate - timedelta(days=1),
            None,
        )

    def get_notifications_from_job(self, job: NotificationJob):
        title = "Decision to respect"
        body = "A decision due for tomorrow as not been completed yet."

        set_tenant(job.orgId)
        decision = DecisionDataHandler.get_decision(job.targetId)
        if decision.status == "inProgress":
            return [Notification(decision.responsibleId, title, body)]
        return []

    def update(self, job: NotificationJob):
        pass
