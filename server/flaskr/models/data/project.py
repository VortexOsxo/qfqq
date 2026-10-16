from dataclasses import dataclass
from enum import Enum


class ProjectStatusEnum(Enum):
    inProgress = "inProgress"
    completed = "completed"


@dataclass(slots=True)
class Project:
    id: int
    number: int
    title: str
    goals: str
    status: ProjectStatusEnum
    supervisorId: int

    def to_dict(self) -> dict[str, str | int]:
        return {
            "id": self.id,
            "number": self.number,
            "title": self.title,
            "goals": self.goals,
            "status": self.status,
            "supervisorId": self.supervisorId,
        }
