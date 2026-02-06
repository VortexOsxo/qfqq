from dataclasses import dataclass
from enum import Enum
from datetime import datetime


class MeetingAgendaStatus(Enum):
    draft = 'draft'
    planned = 'planned'
    completed = 'completed'

@dataclass(slots=True)
class MeetingAgenda:
    id: str
    number: int
    title: str
    goals: str
    status: MeetingAgendaStatus

    redactionDate: datetime
    meetingDate: datetime
    meetingLocation: str

    animatorId: str
    projectId: str

    participantsIds: list[str]
    themes: list[str]

    def to_dict(self):
        return {
            "id": self.id,
            "number": self.number,
            "title": self.title,
            "goals": self.goals,
            "status": self.status,
            "redactionDate": self.redactionDate.isoformat(),
            "meetingDate": self.meetingDate.isoformat() if self.meetingDate else None,
            "meetingLocation": self.meetingLocation,
            "animatorId": self.animatorId,
            "participantsIds": self.participantsIds or [],
            "themes": self.themes or [],
            "projectId": self.projectId,
        }
