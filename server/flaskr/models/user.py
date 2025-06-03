from dataclasses import dataclass

@dataclass
class User:
    id: str | int
    username: str
    passwordHash: str
    email: str