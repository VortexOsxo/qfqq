from flaskr.models import Notification, NotificationTarget, ScheduledNotification

from flaskr.database import MeetingDataHandler, set_tenant
from flaskr.database.handlers import UserDataHandler

from ..notification_type import NotificationType

from datetime import datetime, timedelta

_STRINGS = {
    'en': {
        'title': 'Meeting Started',
        'body': "Your meeting has started. You can now join it!",
    },
    'fr': {
        'title': 'Réunion commencée',
        'body': "Votre réunion a commencé, vous pouvez maintenant la rejoindre !",
    },
}


class MeetingStartedNotificationHandler:
    def create(self, orgId, meetingId: int) -> tuple[NotificationTarget, list[ScheduledNotification]]:
        target = NotificationTarget(
            id=0, orgId=orgId, targetId=meetingId, type=NotificationType.MeetingStarted.value, eventAt=datetime.now()
        )

        set_tenant(target.orgId)
        meeting = MeetingDataHandler.get_meeting_agenda(target.targetId)

        notifications = [
            ScheduledNotification(
                id=0, userId=userId, targetId=target.id, nOffset=timedelta()
            )
            for userId in set(meeting.participantsIds + [meeting.animatorId])
        ]
        return target, notifications

    def get_notification(self, target: NotificationTarget, scheduled: ScheduledNotification):
        set_tenant(target.orgId)
        userId = scheduled.userId

        token, locale = UserDataHandler.get_user_fcm(userId)
        if token is None:
            return None
        strings = _STRINGS.get(locale, _STRINGS["fr"])
        return Notification(
            token,
            strings["title"],
            strings["body"],
            data={"type": "MeetingStarted", "id": str(target.targetId)},
        )
