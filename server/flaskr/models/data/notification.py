from dataclasses import dataclass
from datetime import datetime


@dataclass(slots=True)
class Notification:
    token: str
    title: str
    body: str
    data: str | None = None


@dataclass(slots=True)
class NotificationJob:
    id: int
    orgId: int
    targetId: int
    type: str
    payload: str
    scheduledAt: datetime
    sentAt: datetime | None = None

    def to_dict(self):
        return {
            "id": self.id,
            "orgId": self.orgId,
            "targetId": self.targetId,
            "type": self.type,
            "payload": self.payload,
            "scheduledAt": self.scheduledAt.isoformat(),
            "sentAt": self.sentAt.isoformat() if self.sentAt else None,
        }
