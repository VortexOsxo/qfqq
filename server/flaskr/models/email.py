from dataclasses import dataclass

@dataclass
class Email:
    subject: str
    recipient: str
    sender: str
    body: str



