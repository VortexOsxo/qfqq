from datetime import datetime
from flaskr.models import Decision, DecisionStatus, DecisionReportLine
from ..postgres import read_query, write_query, get_db_access
from flaskr.utils.time import time_now_to_string

class DecisionDataHandler:
    @classmethod
    def create_decision(
        cls,
        description: str,
        status: DecisionStatus,
        dueDate: datetime | None,
        responsibleId: int,
        initialDate: datetime | None = None,
        assistantsIds: list[int] | None = None,
        meetingId: int | None = None,
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
    def get_decisions_report_lines_by_project(cls, projectId: int) -> list[DecisionReportLine]:
        query = "SELECT dc.*, u.firstName, u.lastName from decisionsComplete dc JOIN users u ON u.id = dc.responsibleId WHERE projectId = %s"

        decisions = read_query(query, (projectId,))
        return [DecisionReportLine(*d[:-2], d[-2] + ' ' + d[-1]) for d in decisions]

    @classmethod
    def get_decision_by_responsible(cls, responsibleId: int):
        query = "SELECT * from decisionsComplete WHERE responsibleId = %s;"
        decisions = read_query(query, (responsibleId,))
        return [Decision(*d) for d in decisions]
    
    @classmethod
    def get_decisions_report_lines(cls) -> list[DecisionReportLine]:
        query = "SELECT dc.*, u.firstName, u.lastName from decisionsComplete dc JOIN users u ON u.id = dc.responsibleId;"
        decisions = read_query(query)
        return [DecisionReportLine(*d[:-2], d[-2] + ' ' + d[-1]) for d in decisions]

    @classmethod
    def get_decision_report_lines_by_responsible(cls, responsibleId: int) -> list[DecisionReportLine]:
        nameResult = read_query("SELECT u.firstName, u.lastName FROM users u WHERE u.id = %s;", (responsibleId,))
        if len(nameResult) == 0:
            return []
        
        name = nameResult[0][0] + ' ' + nameResult[0][1]

        query = "SELECT dc.* from decisionsComplete dc WHERE dc.responsibleId = %s;"
        decisions = read_query(query, (responsibleId,))
        return [DecisionReportLine(*d, name) for d in decisions]

    @classmethod
    def get_decision_report_lines_by_meeting(cls, meetingId: int) -> list[DecisionReportLine]:
        query = "SELECT dc.*, u.firstName, u.lastName from decisionsComplete dc JOIN users u ON u.id = dc.responsibleId WHERE dc.meetingId = %s"

        decisions = read_query(query, (meetingId,))
        return [DecisionReportLine(*d[:-2], d[-2] + ' ' + d[-1]) for d in decisions]
    
    @classmethod
    def complete_decision(cls, id: int):
        query = "UPDATE decisions SET status = %s, completedDate = %s WHERE id = %s;"
        params = ('completed',time_now_to_string(), id)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            return cur.rowcount == 1

    @classmethod
    def pending_decision(cls, id: int):
        query = "UPDATE decisions SET status = %s WHERE id = %s;"
        params = ('pending', id)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            return cur.rowcount == 1

    @classmethod
    def set_completion_message(cls, id: int, message: str):
        query = "UPDATE decisions SET completionMessage = %s WHERE id = %s;"
        params = (message, id)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            return cur.rowcount == 1

    @classmethod
    def cancel_decision(cls, id: int):
        query = "UPDATE decisions SET status = %s WHERE id = %s;"
        params = ('cancelled', id)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute(query, params)
            return cur.rowcount == 1

    @classmethod
    def delete_decision(cls, id: int):
        query = "DELETE FROM decisions WHERE id = %s;"
        params = (id,)
        write_query(query, params)