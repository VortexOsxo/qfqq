from dataclasses import dataclass
from enum import Enum
from datetime import datetime


class DecisionStatus(Enum):
    inProgress = 0
    cancelled = 1
    pending = 2
    completed = 3
    taskDescription = 4
    approved = 5
    toBeValidated = 6


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

    responsibleId: str
    assistantsId: list[str]

    projectId: str

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
            "reporterId": self.reporterId,
            "assistantsId": self.assistantsId,
            "projectId": self.projectId,
        }
