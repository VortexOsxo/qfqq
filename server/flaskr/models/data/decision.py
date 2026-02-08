from dataclasses import dataclass
from enum import Enum
from datetime import datetime


class DecisionStatus(Enum):
    inProgress = "inProgress"
    cancelled = "cancelled"
    pending = "pending"
    completed = "completed"
    taskDescription = "taskDescription"
    approved = "approved"
    toBeValidated = "toBeValidated"

    @staticmethod
    def as_string(value: str, lang="fr"):
        fr_reprs = {
            "inProgress": "En cours",
            "cancelled": "Annulé",
            "pending": "En attente",
            "completed": "Terminé",
            "taskDescription": "Description de la tâche",
            "approved": "Approuvé",
            "toBeValidated": "À valider",
        }

        en_reprs = {
            "inProgress": "In progress",
            "cancelled": "Cancelled",
            "pending": "Pending",
            "completed": "Completed",
            "taskDescription": "Task description",
            "approved": "Approved",
            "toBeValidated": "To be validated",
        }

        if lang == "fr":
            return fr_reprs.get(value, value)
        elif lang == "en":
            return en_reprs.get(value, value)
        return value


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
            "completedDate": (
                self.completedDate.isoformat() if self.completedDate else None
            ),
            "responsibleId": self.responsibleId,
            "meetingId": self.meetingId,
            "assistantsIds": self.assistantsIds or [],
            "projectId": self.projectId,
        }
