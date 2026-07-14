from ..notification_type import NotificationType

from .decision_deadline_notification_handler import DecisionDueNotificationHandler
from .meeting_start_notification_handler import MeetingStartNotificationHandler

handlers = {
    NotificationType.DecisionDue.value: DecisionDueNotificationHandler(),
    NotificationType.MeetingStart.value: MeetingStartNotificationHandler()
}