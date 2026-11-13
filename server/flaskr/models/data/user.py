from dataclasses import dataclass


@dataclass(slots=True)
class User:
    id: int
    firstName: str
    lastName: str
    passwordHash: str
    email: str

    @property
    def displayName(self):
        return f"{self.firstName} {self.lastName}"

    def to_dict(self):
        return {"id": self.id, "firstName": self.firstName, "lastName": self.lastName, "email": self.email}
