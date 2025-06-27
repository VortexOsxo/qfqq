from dataclasses import dataclass

@dataclass(slots=True)
class User:
    id: str | int
    username: str
    passwordHash: str
    email: str