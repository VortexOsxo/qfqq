from dataclasses import dataclass
from enum import Enum
from datetime import datetime

class MeetingAgendaStatus(Enum):
    created = 0
    saved = 1
    validated = 2

@dataclass(slots=True)
class MeetingAgenda:
    id: str | int
    title: str
    reunionGoals: str
    status: MeetingAgendaStatus
    
    redactionDate: datetime
    meetingDate: datetime
    meetingLocation: str

    animatorId: str
    participantsIds: list[str]

    themes: list[str]
    project: str

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "reunionGoals": self.reunionGoals,
            "status": self.status,
            "redactionDate": self.redactionDate.isoformat(),
            "meetingDate": self.meetingDate.isoformat() if self.meetingDate else None,
            "meetingLocation": self.meetingLocation,
            "animatorId": self.animatorId,
            "participantsIds": self.participantsIds,
            "themes": self.themes,
            "project": self.project,
        }