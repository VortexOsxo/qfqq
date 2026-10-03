from flaskr.models import Notification, NotificationTarget, ScheduledNotification, Decision
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
    def create(self, orgId, decision: Decision) -> tuple[NotificationTarget, list[ScheduledNotification]]:
        target = NotificationTarget(
            id=0, orgId=orgId, targetId=decision.id, type=NotificationType.DecisionDue.value, eventAt=decision.dueDate
        )

        notifications = [
            ScheduledNotification(
                id=0, userId=decision.responsibleId, targetId=target.id, nOffset=timedelta(days=1)
            )            
        ]
        return target, notifications

    def get_notification(self, target: NotificationTarget, _: ScheduledNotification):
        set_tenant(target.orgId)
        decision = DecisionDataHandler.get_decision(target.targetId)
        if decision.status != "inProgress":
            return None

        token, locale = UserDataHandler.get_user_fcm(decision.responsibleId)
        if token is None:
            return None
        strings = _STRINGS.get(locale, _STRINGS["fr"])
        return Notification(
            token,
            strings["title"],
            strings["body"],
            data={"type": "DecisionDue", "id": str(target.targetId)},
        )
