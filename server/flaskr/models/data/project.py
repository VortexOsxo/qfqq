from dataclasses import dataclass


@dataclass(slots=True)
class Project:
    id: str | int
    title: str
    description: str

    def to_dict(self):
        return {"id": self.id, "title": self.title, "description": self.description}
