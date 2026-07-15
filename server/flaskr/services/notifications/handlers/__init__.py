from ..notification_type import NotificationType

from .decision_deadline_notification_handler import DecisionDueNotificationHandler
from .meeting_start_notification_handler import MeetingStartNotificationHandler
from .meeting_started_notification_handler import MeetingStartedNotificationHandler

handlers = {
    NotificationType.DecisionDue.value: DecisionDueNotificationHandler(),
    NotificationType.MeetingStart.value: MeetingStartNotificationHandler(),
    NotificationType.MeetingStarted.value: MeetingStartedNotificationHandler(),
}