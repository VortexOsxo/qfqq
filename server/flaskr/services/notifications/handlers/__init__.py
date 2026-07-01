from ..notification_type import NotificationType

from .meeting_start_notification_handler import MeetingStartNotificationHandler

handlers = {
    NotificationType.MeetingStart.value: MeetingStartNotificationHandler()
}