from flaskr.models import NotificationJob, Notification, MeetingAgenda
from flaskr.database import MeetingDataHandler, set_tenant
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
    def create(self, orgId, meeting: MeetingAgenda):
        return NotificationJob(
            -1,
            orgId,
            meeting.id,
            NotificationType.MeetingStart.value,
            "",
            meeting.meetingDate - timedelta(minutes=15),
            None,
        )

    # TODO: Do we need to verify the targetId ? I don't think so
    def update(self, jobs: list[NotificationJob], meeting: MeetingAgenda):
        newJobs = []
        for job in jobs:
            if job.targetId != meeting.id:
                continue
            job.scheduledAt = meeting.meetingDate - timedelta(minutes=15)
            newJobs.append(job)
        return newJobs

    def remove(self, jobs: list[NotificationJob], meeting: MeetingAgenda):
        return [job for job in jobs if job.targetId == meeting.id]

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
                    data={"type": "MeetingStart", "id": str(job.targetId)},
                )
            )
        return notifications

