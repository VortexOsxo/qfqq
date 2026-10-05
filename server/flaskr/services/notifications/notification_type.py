from enum import Enum
from datetime import timedelta

class NotificationType(Enum):
    MeetingStart = 'MeetingStart' # Should be called MeetingRemainder
    MeetingStarted = 'MeetingStarted' # Called when the meeting is started
    DecisionDue = 'DecisionDue'

DEFAULT_NOTIFICATION_OFFSETS = {
    NotificationType.DecisionDue.value: timedelta(days=1),
    NotificationType.MeetingStarted.value: timedelta(0),
    NotificationType.MeetingStart.value: timedelta(minutes=15),
}