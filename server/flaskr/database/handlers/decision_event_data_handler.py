from psycopg.types.json import Jsonb

from flaskr.models import DecisionEvent
from ..postgres import read_query, write_query


class DecisionEventDataHandler:
    @classmethod
    def create_decision_created(cls, decisionId: int, userId: int):
        cls._insert(decisionId, userId, "decisionCreated")

    @classmethod
    def create_decision_status_updated(cls, decisionId, userId, decisionStatus):
        cls._insert(decisionId, userId, "statusUpdated", {"decisionStatus": decisionStatus})

    @classmethod
    def create_decision_commented(cls, decisionId, userId, commentContent):
        cls._insert(decisionId, userId, "commented", {"commentContent": commentContent})

    @classmethod
    def _insert(cls, decisionId, userId, type, data=None):
        write_query(
            "INSERT INTO decisionEvents (decisionId, userId, type, data) VALUES (%s, %s, %s, %s);",
            (decisionId, userId, type, Jsonb(data) if data else None),
        )

    @classmethod
    def get_decision_events_by_id(cls, decisionId: int) -> list[DecisionEvent]:
        rows = read_query(
            "SELECT decisionId, userId, date, type, data FROM decisionEvents "
            "WHERE decisionId = %s ORDER BY date;",
            (decisionId,),
        )
        return [DecisionEvent(*row) for row in rows]
