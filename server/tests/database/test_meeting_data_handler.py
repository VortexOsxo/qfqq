from datetime import datetime
from flaskr.database import MeetingDataHandler
from flaskr.models import MeetingAgenda


def test_get_all_meeting_agendas(app_ctx):
    meetings = MeetingDataHandler.get_meeting_agendas()

    assert len(meetings) == 3
    assert all(isinstance(m, MeetingAgenda) for m in meetings)


def test_get_meeting_agenda_by_id(app_ctx):
    meeting = MeetingDataHandler.get_meeting_agenda(1)

    assert isinstance(meeting, MeetingAgenda)
    assert meeting.id == 1
    assert meeting.title == "Apollo Kickoff"
    assert meeting.goals == "Discuss scope and milestones"
    assert meeting.status == "planned"

    assert str(meeting.redactionDate) == "2025-11-01"
    assert str(meeting.meetingDate) == "2025-11-10"
    assert str(meeting.meetingLocation) == "Room 101"

    assert meeting.animatorId == 1
    assert meeting.projectId == 1

    assert meeting.participantsIds == [1, 3]


def test_get_meeting_agenda_with_themes(app_ctx):
    meeting = MeetingDataHandler.get_meeting_agenda(1)

    assert meeting.themes is not None
    assert "Scope" in meeting.themes
    assert "Timeline" in meeting.themes


def test_get_meetings_by_participant_alice(app_ctx):
    meetings = MeetingDataHandler.get_meetings_by_participant(1)

    assert len(meetings) == 2
    assert all(isinstance(m, MeetingAgenda) for m in meetings)

    titles = [m.title for m in meetings]
    assert "Apollo Kickoff" in titles
    assert "Design Sync" in titles


def test_create_meeting_with_participants_and_themes(app_ctx):
    meeting = MeetingDataHandler.create_meeting_agenda(
        title="Q1 Planning",
        goals="Plan Q1 initiatives",
        status="draft",
        redactionDate=datetime(2026, 1, 15),
        meetingDate=datetime(2026, 1, 20),
        meetingLocation="Room 301",
        animatorId=1,
        participantsIds=[1, 2],
        themes=["Budget", "Timeline"],
        projectId=1,
    )

    assert meeting is not None
    assert meeting.title == "Q1 Planning"
    assert meeting.status == "draft"
    assert meeting.participantsIds == [1, 2]
    assert meeting.themes == ["Budget", "Timeline"]


def test_get_newly_created_meeting(app_ctx):
    created_meeting = MeetingDataHandler.create_meeting_agenda(
        title="Retrospective",
        goals="Discuss what went well and what to improve",
        status="planned",
        redactionDate=datetime(2026, 2, 1),
        meetingDate=datetime(2026, 2, 5),
        meetingLocation="Zoom",
        animatorId=2,
        participantsIds=[1, 2, 3],
        themes=["Process", "Team Dynamics"],
        projectId=1,
    )

    assert created_meeting is not None

    fetched_meeting = MeetingDataHandler.get_meeting_agenda(created_meeting.id)

    assert fetched_meeting.title == "Retrospective"
    assert fetched_meeting.animatorId == 2
    assert len(fetched_meeting.participantsIds) == 3

def test_get_not_found_meeting(app_ctx):
    meeting = MeetingDataHandler.get_meeting_agenda(5)
    assert meeting is None

def test_get_not_found_meeting_by_participant(app_ctx):
    meetings = MeetingDataHandler.get_meetings_by_participant(10)
    assert len(meetings) == 0