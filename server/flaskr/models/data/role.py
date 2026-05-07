from dataclasses import dataclass


@dataclass(slots=True)
class Role:
    id: int
    name: str
    canWrite: bool
    canDelete: bool
    canUpdatePermissions: bool

    def to_dict(self) -> dict[str, int | bool]:
        return {
            "id": self.id,
            "name": self.name,
            "canWrite": self.canWrite,
            "canDelete": self.canDelete,
            "canUpdatePermissions": self.canUpdatePermissions,
        }
