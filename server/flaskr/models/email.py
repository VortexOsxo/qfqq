from dataclasses import dataclass, field
from typing import Dict

@dataclass
class Email:
    subject: str
    recipient: str
    body: str
    attachments: Dict[str, bytes] = field(default_factory=dict)
