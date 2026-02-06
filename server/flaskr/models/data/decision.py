from dataclasses import dataclass
from enum import Enum
from datetime import datetime


class DecisionStatus(Enum):
    inProgress = 'inProgress'
    cancelled = 'cancelled'
    pending = 'pending'
    completed = 'completed'
    taskDescription = 'taskDescription'
    approved = 'approved'
    toBeValidated = 'toBeValidated'


    def as_int(self):
        return self.value


@dataclass(slots=True)
class Decision:
    id: str | int
    number: int
    description: str
    status: DecisionStatus

    initialDate: datetime
    dueDate: datetime | None
    completedDate: datetime | None

    responsibleId: int
    meetingId: int

    assistantsIds: list[int]
    projectId: int

    def to_dict(self):
        return {
            "id": self.id,
            "number": self.number,
            "description": self.description,
            "status": self.status,
            "initialDate": self.initialDate.isoformat(),
            "dueDate": self.dueDate.isoformat() if self.dueDate else None,
            "completedDate": self.completedDate.isoformat() if self.completedDate else None,
            "responsibleId": self.responsibleId,
            "meetingId": self.meetingId,
            "assistantsIds": self.assistantsIds or [],
            "projectId": self.projectId,
        }
