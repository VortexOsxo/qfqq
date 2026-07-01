from flaskr.models import NotificationJob, Notification, MeetingAgenda
from flaskr.database import MeetingDataHandler, set_tenant

from ..notification_type import NotificationType

from datetime import timedelta


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

    def get_notifications_from_job(self, job: NotificationJob):
        title = "Meeting Started"
        body = "Your meeting in starting in 15 minutes, don't forget to join it"

        set_tenant(job.orgId)
        usersIds = MeetingDataHandler.get_meeting_users(job.targetId)
        return [Notification(userId, title, body) for userId in usersIds]

    def update(self, job: NotificationJob, meeting: MeetingAgenda):
        # TODO: Dead code for now :(
        if job.targetId != meeting.id:
            return False, None
        job.scheduledAt = meeting.meetingDate - timedelta(minutes=15)
        return True, job
