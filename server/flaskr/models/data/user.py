from dataclasses import dataclass


@dataclass(slots=True)
class User:
    id: int
    username: str
    passwordHash: str
    email: str

    def to_dict(self):
        return {"id": self.id, "username": self.username, "email": self.email}
