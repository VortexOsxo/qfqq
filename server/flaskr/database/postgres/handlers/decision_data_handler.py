from datetime import datetime
from flaskr.models import Decision
from ..postgres import read_query, get_db_access


class DecisionDataHandler:
    @classmethod
    def create_decision(
        cls,
        description,
        status,
        dueDate,
        responsibleId,
        initialDate=None,
        assistantsIds=None,
        meetingId=None,
    ):
        initialDate = initialDate or datetime.now()
        assistantsIds = assistantsIds or []
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = (
                    "INSERT INTO decisions (description, status, initialDate, dueDate, completedDate, responsibleId, meetingId) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id, nb;"
                )
                params = (
                    description,
                    status,
                    initialDate,
                    dueDate,
                    None,
                    responsibleId,
                    meetingId,
                )

                cur.execute(query, params)

                decisionId, decisionNb = cur.fetchone()
                query = "INSERT INTO decisionsAssistants (decisionId, userId) VALUES (%s, %s)"
                params = [(decisionId, assistantId) for assistantId in assistantsIds]
                cur.executemany(query, params)

            return cls.get_decision(decisionId)

        except Exception as e:
            pass
        return None

    @classmethod
    def get_decisions(cls):
        query = "SELECT * from decisionsComplete;"
        decisions = read_query(query)
        return [Decision(*d) for d in decisions]

    @classmethod
    def get_decision(cls, decisionId: int):
        query = "SELECT * from decisionsComplete WHERE id = %s;"
        params = (decisionId,)
        decisions = read_query(query, params)
        return Decision(*decisions[0]) if decisions else None

    @classmethod
    def get_decisions_by_project(cls, projectId: int):
        query = "SELECT * from decisionsComplete WHERE projectId = %s;"

        decisions = read_query(query, (projectId,))
        return [Decision(*d) for d in decisions]
    
    @classmethod
    def get_decisions_and_responsible_by_project(cls, projectId: int):
        query = "SELECT dc.*, u.username from decisionsComplete dc JOIN users u ON u.id = dc.responsibleId WHERE projectId = %s"

        decisions = read_query(query, (projectId,))
        return [(Decision(*d[:-1]), d[-1]) for d in decisions]

    @classmethod
    def get_decision_by_responsible(cls, responsibleId: int):
        query = "SELECT * from decisionsComplete WHERE responsibleId = %s;"
        decisions = read_query(query, (responsibleId,))
        return [Decision(*d) for d in decisions]
    
    @classmethod
    def get_decisions_and_responsible_by_meeting(cls, meetingId: int):
        query = "SELECT dc.*, u.username from decisionsComplete dc JOIN users u ON u.id = dc.responsibleId WHERE dc.meetingId = %s"

        decisions = read_query(query, (meetingId,))
        return [(Decision(*d[:-1]), d[-1]) for d in decisions]