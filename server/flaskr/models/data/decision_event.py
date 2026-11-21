from dataclasses import dataclass
from datetime import datetime
from typing import Literal, TypeAlias


DecisionEventType: TypeAlias = Literal["decisionCreated", "statusUpdated"]


@dataclass(slots=True)
class DecisionEvent:
    decisionId: int
    userId: int
    date: datetime
    type: DecisionEventType
    data: dict | None

    def to_dict(self):
        return {
            "decisionId": self.decisionId,
            "userId": self.userId,
            "date": self.date.isoformat(),
            "type": self.type,
            "data": self.data,
        }
