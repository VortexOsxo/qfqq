from flaskr.models import NotificationJob, Notification, Decision
from flaskr.database import DecisionDataHandler, set_tenant
from flaskr.database.handlers import UserDataHandler

from ..notification_type import NotificationType

from datetime import timedelta

_STRINGS = {
    'en': {
        'title': 'Decision Due Tomorrow',
        'body': 'A decision due tomorrow has not been completed yet.',
    },
    'fr': {
        'title': 'Décision à respecter',
        'body': "Une décision due demain n'a pas encore été complétée.",
    },
}


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
        set_tenant(job.orgId)
        decision = DecisionDataHandler.get_decision(job.targetId)
        if decision.status != "inProgress":
            return []

        token, locale = UserDataHandler.get_user_fcm(decision.responsibleId)
        if token is None:
            return []
        strings = _STRINGS.get(locale, _STRINGS['fr'])
        return [
            Notification(
                token,
                strings['title'],
                strings['body'],
                data={"type": "DecisionDue", "id": str(job.targetId)},
            )
        ]

    def update(self, job: NotificationJob):
        pass

