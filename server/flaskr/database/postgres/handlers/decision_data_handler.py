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
        assistantsId=None,
        meetingId=None,
    ):
        initialDate = initialDate or datetime.now()
        assistantsId = assistantsId or []

        with get_db_access() as conn:
            cur = conn.cursor()

            query = (
                "INSERT INTO decisions (description, status, initialDate, dueDate, completedDate, responsibleId, meetingId) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;"
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

            decisionId = cur.fetchone()[0]
            query = (
                "INSERT INTO decisionsAssistants (decisionId, userId) VALUES (%s, %s)"
            )
            params = [(decisionId, assistantId) for assistantId in assistantsId]
            cur.executemany(query, params)

    @classmethod
    def get_decisions(cls):
        query = (
            "SELECT d.*, da.assistantsIds FROM decisions d "
            "LEFT JOIN ("
            "   SELECT decisionId, array_agg(userId) AS assistantsIds "
            "   FROM decisionsAssistants GROUP BY decisionId"
            ") da ON da.decisionId = d.id;"
        )
        decisions = read_query(query)
        return [Decision(*d) for d in decisions]

    @classmethod
    def get_decision(cls, decisionId: str):
        query = (
            "SELECT d.*, da.assistantsIds FROM decisions d "
            "LEFT JOIN ( "
            "   SELECT decisionId, array_agg(userId) AS assistantsIds "
            "   FROM decisionsAssistants GROUP BY decisionId"
            ") da ON d.id = da.decisionId "
            "WHERE d.id = %s;"
        )
        params = (decisionId,)
        decision = read_query(query, params)[0]
        return Decision(*decision)

    @classmethod
    def get_decision_by_project(cls, projectId: int):
        query = (
            "SELECT d.*, da.assistantsIds FROM decisions d "
            "LEFT JOIN ( "
            "   SELECT decisionId, array_agg(userId) AS assistantsIds "
            "   FROM decisionsAssistants GROUP BY decisionId"
            ") da ON d.id = da.decisionId " \
            "LEFT JOIN (" \
            "   SELECT id, projectId FROM meetings" \
            ") p ON p.id = d.id "
            "WHERE p.projectId = %s;"
        )
        decisions = read_query(query, (projectId,))
        return [Decision(*d) for d in decisions]
    
    @classmethod
    def get_decision_by_responsible(cls, responsibleId: int):
        query = (
            "SELECT d.*, da.assistantsIds FROM decisions d "
            "LEFT JOIN ( "
            "   SELECT decisionId, array_agg(userId) AS assistantsIds "
            "   FROM decisionsAssistants GROUP BY decisionId"
            ") da ON d.id = da.decisionId "
            "WHERE d.responsibleId = %s;"
        )
        decisions = read_query(query, (responsibleId,))
        return [Decision(*d) for d in decisions]

