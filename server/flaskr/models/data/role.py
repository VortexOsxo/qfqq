from dataclasses import dataclass


@dataclass(slots=True)
class Role:
    id: int
    name: str
    contribute: bool
    deleteContent: bool
    manageTeam: bool

    def to_dict(self) -> dict[str, int | bool]:
        return {
            "id": self.id,
            "name": self.name,
            "contribute": self.contribute,
            "deleteContent": self.deleteContent,
            "manageTeam": self.manageTeam,
        }
