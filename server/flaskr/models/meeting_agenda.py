from dataclasses import dataclass
from enum import Enum
from datetime import datetime
from .user import User

class MeetingAgendaStatus(Enum):
    created = 0
    saved = 1
    validated = 2


@dataclass
class MeetingAgenda:
    id: str | int
    title: str
    reunionGoals: str
    status: MeetingAgendaStatus
    
    redactionDate: datetime
    meetingDate: datetime
    meetingLocation: str

    animator: User
    participants: list[User]

    themes: list[str]
    project: str