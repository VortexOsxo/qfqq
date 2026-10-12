from flaskr.models import Notification, NotificationTarget, ScheduledNotification, Decision
from flaskr.database import DecisionDataHandler, set_tenant
from flaskr.database.handlers import UserDataHandler

from ..notification_type import NotificationType
from .duration_format import format_duration

from datetime import timedelta

_STRINGS = {
    'en': {
        'title': 'Decision Due Soon',
        'body': 'A decision due in {duration} has not been completed yet.',
    },
    'fr': {
        'title': 'Décision bientôt due',
        'body': "Une décision due dans {duration} n'a pas encore été complétée.",
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

    def get_notification(self, target: NotificationTarget, scheduled: ScheduledNotification):
        set_tenant(target.orgId)
        decision = DecisionDataHandler.get_decision(target.targetId)
        if decision is None or decision.status != "inProgress":
            return None

        token, locale = UserDataHandler.get_user_fcm(decision.responsibleId)
        if token is None:
            return None
        strings = _STRINGS.get(locale, _STRINGS["fr"])
        duration = format_duration(scheduled.nOffset, locale)
        return Notification(
            token,
            strings["title"],
            strings["body"].format(duration=duration),
            data={"type": "DecisionDue", "id": str(target.targetId)},
        )
