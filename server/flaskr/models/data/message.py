from dataclasses import dataclass
from datetime import datetime


@dataclass(slots=True)
class Message:
    id: int
    chatId: int
    senderId: int
    content: str
    sentAt: datetime

    def to_dict(self):
        return {
            "id": self.id,
            "chatId": self.chatId,
            "senderId": self.senderId,
            "content": self.content,
            "sentAt": self.sentAt.isoformat(),
        }
