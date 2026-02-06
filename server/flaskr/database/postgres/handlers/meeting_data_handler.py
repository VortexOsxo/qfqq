from flaskr.models import MeetingAgendaStatus, MeetingAgenda
from ..postgres import get_db_access, read_query
from datetime import datetime


class MeetingDataHandler:

    @classmethod
    def create_meeting_agenda(
        cls,
        title: str,
        goals: str,
        status: MeetingAgendaStatus,
        redactionDate: datetime,
        meetingDate: datetime,
        meetingLocation: str,
        animatorId: str,
        participantsIds: list[str],
        themes: list[str],
        projectId: str,
    ):
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = (
                    "INSERT INTO meetings (title, goals, status, redactionDate, meetingDate, meetingLocation, animatorId, projectId) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s, %s) RETURNING id, nb;"
                )
                params = (
                    title,
                    goals,
                    status,
                    redactionDate,
                    meetingDate,
                    meetingLocation,
                    animatorId,
                    projectId,
                )

                cur.execute(query, params)

                meetingId, meetingNb = cur.fetchone()

                query = "INSERT INTO meetingsParticipants (meetingId, userId) VALUES (%s, %s)"
                params = [
                    (meetingId, participantId) for participantId in participantsIds
                ]
                cur.executemany(query, params)

                query = "INSERT INTO meetingsThemes (meetingId, theme) VALUES (%s, %s)"
                params = [(meetingId, theme) for theme in themes]
                cur.executemany(query, params)
            return MeetingAgenda(
                meetingId,
                meetingNb,
                title,
                goals,
                status,
                redactionDate,
                meetingDate,
                meetingLocation,
                animatorId,
                projectId,
                participantsIds,
                themes,
            )
        except Exception as e:
            pass
        return None

    @classmethod
    def update_meeting_agenda(
        cls,
        meetingId: str,
        title: str,
        goals: str,
        status: MeetingAgendaStatus,
        redactionDate: datetime,
        meetingDate: datetime,
        meetingLocation: str,
        animatorId: str,
        participantsIds: list[str],
        themes: list[str],
        projectId: str,
    ):
        with get_db_access() as conn:
            cur = conn.cursor()

            query = (
                "UPDATE meetings SET title = %s, goals = %s, status = %s, "
                "redactionDate = %s, meetingDate = %s, meetingLocation = %s, animatorId = %s, projectId = %s "
                "WHERE id = %s;"
            )
            params = (
                title,
                goals,
                status,
                redactionDate,
                meetingDate,
                meetingLocation,
                animatorId,
                projectId,
                meetingId,
            )

            cur.execute(query, params)

            query = "DELETE FROM meetingsThemes WHERE meetingId = %s;"
            cur.execute(query, (meetingId,))

            query = "DELETE FROM meetingsParticipants WHERE meetingId = %s;"
            cur.execute(query, (meetingId,))

            query = (
                "INSERT INTO meetingsParticipants (meetingId, userId) VALUES (%s, %s)"
            )
            params = [(meetingId, participantId) for participantId in participantsIds]
            cur.executemany(query, params)

            query = "INSERT INTO meetingsThemes (meetingId, theme) VALUES (%s, %s)"
            params = [(meetingId, theme) for theme in themes]
            cur.executemany(query, params)

    @classmethod
    def get_meeting_agendas(cls) -> list[MeetingAgenda]:
        query = "SELECT * FROM meetingsComplete;"

        meetings = read_query(query)
        return [MeetingAgenda(*m) for m in meetings]

    @classmethod
    def get_meeting_agenda(cls, id: int) -> MeetingAgenda | None:
        query = "SELECT * FROM meetingsComplete WHERE id = %s;"

        meeting = read_query(query, (id,))[0]
        return MeetingAgenda(*meeting)

    @classmethod
    def get_meetings_by_participant(cls, participantId: int) -> MeetingAgenda | None:
        query = "SELECT * FROM meetingsComplete WHERE %s = ANY(participantsIds);"

        meetings = read_query(query, (participantId,))
        return [MeetingAgenda(*m) for m in meetings]
