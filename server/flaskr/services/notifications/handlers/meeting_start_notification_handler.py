from flaskr.models import Notification, NotificationTarget, ScheduledNotification, MeetingAgenda
from flaskr.database import set_tenant
from flaskr.database.handlers import UserDataHandler

from ..notification_type import NotificationType

from datetime import timedelta

_STRINGS = {
    'en': {
        'title': 'Meeting Starting Soon',
        'body': "Your meeting is starting in 15 minutes, don't forget to join!",
    },
    'fr': {
        'title': 'Réunion bientôt',
        'body': "Votre réunion commence dans 15 minutes, n'oubliez pas de la rejoindre !",
    },
}


class MeetingStartNotificationHandler:
    def create(self, orgId, meeting: MeetingAgenda) -> tuple[NotificationTarget, list[ScheduledNotification]]:
        target = NotificationTarget(
            id=0,
            orgId=orgId,
            targetId=meeting.id,
            type=NotificationType.MeetingStart.value,
            eventAt=meeting.meetingDate,
        )

        notifications = [
            ScheduledNotification(
                id=0, userId=responsibleId, targetId=target.id, nOffset=timedelta(days=1)
            )
            for responsibleId in set(meeting.participantsIds+[meeting.animatorId])
        ]
        return target, notifications

    def get_notification(self, target: NotificationTarget, scheduled: ScheduledNotification):
        set_tenant(target.orgId)

        userId = scheduled.userId

        token, locale = UserDataHandler.get_user_fcm(userId)
        if token is None:
            None

        strings = _STRINGS.get(locale, _STRINGS["fr"])
        return Notification(
            token,
            strings["title"],
            strings["body"],
            data={"type": "MeetingStart", "id": str(target.targetId)},
        )
