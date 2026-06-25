from dataclasses import dataclass


@dataclass(slots=True)
class Invitation:
    orgId: int
    email: str
    roleId: int

    def to_dict(self) -> dict[str, str | int]:
        return {"orgId": self.orgId, "email": self.email, "roleId": self.roleId}
