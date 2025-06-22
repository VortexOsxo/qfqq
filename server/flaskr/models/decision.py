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

@dataclass
class Decision:
    id: str | int
    description: str
    status: DecisionStatus
    
    initialDate: datetime
    dueDate: datetime

    responsibleId: str
    assistantsId: list[str]

    projectId: str

    def to_dict(self):
        return {
            "id": self.id,
            "description": self.description,
            "status": self.status,
            "initialDate": self.initialDate.isoformat(),
            "dueDate": self.dueDate.isoformat(),
            "responsibleId": self.responsibleId,
            "assistantsId": self.assistantsId,
            "projectId": self.projectId,
        }