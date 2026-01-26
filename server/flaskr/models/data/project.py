from dataclasses import dataclass


@dataclass(slots=True)
class Project:
    id: str | int
    number: int
    title: str
    goals: str
    supervisorId: str

    def to_dict(self):
        return {
            "id": self.id,
            "number": self.number,
            "title": self.title,
            "goals": self.goals,
            "supervisorId": self.supervisorId,
        }
