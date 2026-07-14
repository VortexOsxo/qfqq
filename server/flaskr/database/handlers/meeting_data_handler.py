from flaskr.models import MeetingAgendaStatus, MeetingAgenda, MeetingReview
from ..postgres import get_db_access, read_query, write_query
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
        previousMeetingId: int = -1
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

                if previousMeetingId != -1:
                    query = "UPDATE meetings SET nextMeetingId = %s WHERE id = %s;"
                    params = (meetingId, previousMeetingId)
                    cur.execute(query, params)

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
        meetingId: int,
        title: str,
        goals: str,
        status: MeetingAgendaStatus,
        redactionDate: datetime,
        meetingDate: datetime,
        meetingLocation: str,
        animatorId: int,
        participantsIds: list[int],
        themes: list[str],
        projectId: int,
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
    def update_meeting_status(cls, meetingId: int, status: str):
        query = "UPDATE meetings SET status = %s WHERE id = %s;"
        params = (status, meetingId)
        try:
            write_query(query, params)
            return True
        except Exception as e:
            return False

    @classmethod
    def get_meeting_agendas(cls) -> list[MeetingAgenda]:
        query = "SELECT id, nb, title, goals, status, redactionDate, meetingDate, meetingLocation, animatorId, projectId, participantsIds, themes FROM meetingsComplete;"

        meetings = read_query(query)
        return [MeetingAgenda(*m) for m in meetings]

    @classmethod
    def get_meeting_agenda(cls, id: int) -> MeetingAgenda | None:
        query = "SELECT id, nb, title, goals, status, redactionDate, meetingDate, meetingLocation, animatorId, projectId, participantsIds, themes FROM meetingsComplete WHERE id = %s;"

        meetings = read_query(query, (id,))
        return MeetingAgenda(*meetings[0]) if meetings else None

    @classmethod
    def get_meeting_with_participants(cls, id: int) -> tuple[MeetingAgenda, list[str]] | None:
        query = """
        SELECT
        mc.id, mc.nb, mc.title, mc.goals, mc.status, mc.redactionDate, mc.meetingDate, mc.meetingLocation, mc.animatorId, mc.projectId, mc.participantsIds, mc.themes,
        COALESCE(p.participantsNames, '{}') AS participantsNames
        FROM meetingsComplete mc
        LEFT JOIN LATERAL (
        SELECT array_agg(u.firstName || ' ' || u.lastName ORDER BY u.lastName, u.firstName) AS participantsNames
        FROM users u
        WHERE u.id = ANY(mc.participantsIds)
        ) p ON TRUE
        WHERE mc.id = %s;
        """
        meetings = read_query(query, (id,))
        if not meetings: return None, []

        meeting = meetings[0]
        return MeetingAgenda(*meeting[:-1]), meeting[-1]

    @classmethod
    def get_meetings_by_participant(cls, participantId: int) -> list[MeetingAgenda]:
        query = "SELECT id, nb, title, goals, status, redactionDate, meetingDate, meetingLocation, animatorId, projectId, participantsIds, themes FROM meetingsComplete WHERE %s = ANY(participantsIds);"

        meetings = read_query(query, (participantId,))
        return [MeetingAgenda(*m) for m in meetings]

    @classmethod
    def delete_meeting(cls, id: int):
        query = "DELETE FROM meetings WHERE id = %s;"
        params = (id,)
        write_query(query, params)

    @classmethod
    def get_next_meeting(cls, currentMeetingId: int):
        with get_db_access() as conn:
            cur = conn.cursor()

            query = "SELECT nextMeetingId FROM meetings WHERE id = %s;"
            params = (currentMeetingId,)

            cur.execute(query, params)
            nextId = cur.fetchone()[0]

        if nextId is None or nextId == -1:
            return None
        return cls.get_meeting_agenda(nextId)

    @classmethod
    def get_meeting_users(cls, meetingId):
        """Return all users involved in the meeting"""
        query = "SELECT animatorId, participantsIds FROM meetingsComplete WHERE id = %s;"
        params = (meetingId,)
        result = read_query(query, params)
        if not result: return []
        animatorId, participantsIds = result[0]
        return participantsIds + [animatorId] # TODO: Handle duplicate ?
        # Or maybe it shouldnt be possible to have a participants that is the animator
        # Another option is to have all users be participants and then we can tag role onto them
        # this could allow to support more than the animator role.

    @classmethod
    def create_review(cls, meetingId, userId, objective, smoothRunning, preparation, length, respect, comments, isAnonymous=False):
        query = """
        INSERT INTO meetingsReviews
        (meetingId, userId, isAnonymous, objective, smoothRunning, preparation, length, respect, comments)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
        """

        params = (meetingId, userId, isAnonymous, objective, smoothRunning, preparation, length, respect, comments)
        write_query(query, params)
    
    @classmethod
    def get_meeting_reviews(cls, meetingId):
        query = """
        SELECT meetingId, userId, isAnonymous, objective, smoothRunning, preparation, length, respect, comments
        FROM meetingsReviews WHERE meetingId = %s;
        """
        params = (meetingId,)

        results = read_query(query, params)
        return [MeetingReview(*result) for result in results]