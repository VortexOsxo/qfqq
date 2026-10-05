from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass(slots=True)
class Notification:
    token: str
    title: str
    body: str
    data: dict[str, str] | None = None


@dataclass(slots=True)
class NotificationTarget:
    id: int
    orgId: int
    targetId: int
    type: str
    eventAt: datetime


@dataclass(slots=True)
class ScheduledNotification:
    id: int
    userId: int
    targetId: int
    nOffset: timedelta