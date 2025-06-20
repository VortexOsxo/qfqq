from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from flaskr.models import MeetingAgendaStatus, MeetingAgenda
from datetime import datetime
from bson import ObjectId

class MeetingAgendaDataHandler:
    @staticmethod
    def create_meeting_agenda(
        title: str,
        reunionGoals: str,
        status: MeetingAgendaStatus,
        redactionDate: datetime,
        meetingDate: datetime,
        meetingLocation: str,
        animatorId: str,
        participantsIds: list[str],
        themes: list[str],
        project: str,
    ):
        meeting_agenda_collection = get_collection("meeting_agendas")
        try:
            meeting_agenda_collection.insert_one(
                {
                    "title": title,
                    "reunionGoals": reunionGoals,
                    "status": status,
                    "redactionDate": redactionDate,
                    "meetingDate": meetingDate,
                    "meetingLocation": meetingLocation,
                    "animatorId": animatorId,
                    "participantsIds": participantsIds,
                    "themes": themes,
                    "project": project,
                }
            )
        except DuplicateKeyError:
            return False
        return True

    @staticmethod
    def get_meeting_agendas():
        meeting_agenda_collection = get_collection("meeting_agendas")
        meeting_agendas = meeting_agenda_collection.find()
        return [
            MeetingAgenda(
                str(meeting_agenda["_id"]),
                meeting_agenda["title"],
                meeting_agenda["reunionGoals"],
                meeting_agenda["status"],
                meeting_agenda["redactionDate"],
                meeting_agenda["meetingDate"],
                meeting_agenda["meetingLocation"],
                meeting_agenda["animatorId"],
                meeting_agenda["participantsIds"],
                meeting_agenda["themes"],
                meeting_agenda["project"],
            )
            for meeting_agenda in meeting_agendas
        ]

    @staticmethod
    def get_meeting_agenda(id: str) -> MeetingAgenda | None:
        meeting_agenda_collection = get_collection("meeting_agendas")
        meeting_agenda = meeting_agenda_collection.find_one({"_id": ObjectId(id)})
        return (
            MeetingAgenda(
                str(meeting_agenda["_id"]),
                meeting_agenda["title"],
                meeting_agenda["reunionGoals"],
                meeting_agenda["status"],
                meeting_agenda["redactionDate"],
                meeting_agenda["meetingDate"],
                meeting_agenda["meetingLocation"],
                meeting_agenda["animatorId"],
                meeting_agenda["participantsIds"],
                meeting_agenda["themes"],
                meeting_agenda["project"],
            )
            if meeting_agenda
            else None
        )
