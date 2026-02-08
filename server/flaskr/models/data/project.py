from dataclasses import dataclass


@dataclass(slots=True)
class Project:
    id: int
    number: int
    title: str
    goals: str
    supervisorId: int

    def to_dict(self) -> dict[str, str | int]:
        return {
            "id": self.id,
            "number": self.number,
            "title": self.title,
            "goals": self.goals,
            "supervisorId": self.supervisorId,
        }
