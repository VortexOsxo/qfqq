from enum import Enum

class NotificationType(Enum):
    MeetingStart = 'MeetingStart' # Should be called MeetingRemainder
    MeetingStarted = 'MeetingStarted' # Called when the meeting is started
    DecisionDue = 'DecisionDue'