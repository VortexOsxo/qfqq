from flaskr.models import NotificationJob, Notification, MeetingAgenda
from flaskr.database import MeetingDataHandler, set_tenant
from flaskr.database.handlers import UserDataHandler

from ..notification_type import NotificationType

from datetime import datetime

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
    def create(self, orgId, meetingId: int):
        return NotificationJob(
            -1,
            orgId,
            meetingId,
            NotificationType.MeetingStarted.value,
            "",
            datetime.now(),
            None,
        )

    def update(self, _: list[NotificationJob]):
        assert False, "Can't update instant notifications"

    def remove(self, _: list[NotificationJob]):
        assert False, "Can't remove instant notifications"

    def get_notifications_from_job(self, job: NotificationJob):
        set_tenant(job.orgId)
        usersIds = MeetingDataHandler.get_meeting_users(job.targetId)

        notifications = []
        for userId in usersIds:
            token, locale = UserDataHandler.get_user_fcm(userId)
            if token is None: continue
            strings = _STRINGS.get(locale, _STRINGS['fr'])
            notifications.append(
                Notification(
                    token,
                    strings['title'],
                    strings['body'],
                    data={"type": "MeetingStarted", "id": str(job.targetId)},
                )
            )
        return notifications

