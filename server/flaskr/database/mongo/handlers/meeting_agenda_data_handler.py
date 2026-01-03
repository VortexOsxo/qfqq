from flaskr.models import MeetingAgendaStatus, MeetingAgenda
from datetime import datetime
from .base_data_handler import BaseDataHandler
from ..filters.default_filter import IdFilter
from bson import ObjectId

class MeetingAgendaDataHandler(BaseDataHandler):
    @classmethod
    def get_collection_name(cls):
        return "meeting_agendas"

    @classmethod
    def create_meeting_agenda(
        cls,
        title: str,
        reunionGoals: str,
        status: MeetingAgendaStatus,
        redactionDate: datetime,
        meetingDate: datetime,
        meetingLocation: str,
        animatorId: str,
        participantsIds: list[str],
        themes: list[str],
        projectId: str,
    ):
        objectId, acknowledged = cls.attempt_create_item(
            {
                "title": title,
                "reunionGoals": reunionGoals,
                "status": status,
                "redactionDate": redactionDate,
                "meetingDate": meetingDate,
                "meetingLocation": meetingLocation,
                "animatorId": ObjectId(animatorId) if animatorId else None,
                "participantsIds": [ObjectId(id_a) for id_a in participantsIds],
                "themes": themes,
                "projectId": ObjectId(projectId) if projectId else None,
            }
        )
        return acknowledged

    @classmethod
    def get_meeting_agendas(cls):
        return cls.get_items([])

    @classmethod
    def get_meeting_agenda(cls, id: str) -> MeetingAgenda | None:
        return cls.get_items([IdFilter(id)])

    @classmethod
    def _from_mongo_dict(cls, meeting_agenda):
        return MeetingAgenda(
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
            meeting_agenda["projectId"],
        )
