from datetime import datetime
from bson import ObjectId
from flask import Blueprint, request, jsonify, g

from flaskr.models import MeetingAgendaStatus
from flaskr.database import MeetingAgendaDataHandler, ListContainsValueFilter
from flaskr.utils import (
    StringValidator,
    EnumValidator,
    UserIdValidator,
    ListValidator,
    ProjectIdValidator,
    verify_missing_inputs,
)

meeting_agendas_bp = Blueprint(
    "meeting_agendas", __name__, url_prefix="/meeting-agendas"
)

# TODO: Have a unified way to get and object such as a method agenda from the query body, we can then pass that object to the different method, instead
# of having to pass each parameter separatedly

@meeting_agendas_bp.route("", methods=["POST", "PUT"])
def create_meeting_agenda():
    data = request.get_json()

    status = (
        MeetingAgendaStatus.planned
        if data.get("status", "") == MeetingAgendaStatus.planned.value
        else MeetingAgendaStatus.draft
    )

    required_fields = [
        StringValidator("title"),
        StringValidator("redactionDate"), # TODO: DateValidator ?
    ]

    if status == MeetingAgendaStatus.planned:
        required_fields.extend([
            StringValidator("reunionGoals"),
            EnumValidator("status", MeetingAgendaStatus),
            StringValidator("meetingDate"),
            StringValidator("meetingLocation"),
            UserIdValidator("animatorId"),
            ListValidator("participantsIds"),
            ListValidator("themes"),
            ProjectIdValidator("projectId")
        ])

    missings = verify_missing_inputs(data, required_fields)
    if missings:
        return jsonify({"error": f'Missing/Invalid fields: {", ".join(missings)}'}), 400

    try:
        redactionDate = datetime.fromisoformat(data["redactionDate"])
        meetingDate = (
            datetime.fromisoformat(data["meetingDate"])
            if "meetingDate" in data
            else None
        )
    except Exception as e:
        return jsonify({"error": f"Invalid data format: {str(e)}"}), 400

    kwargs = {
        'title': data["title"],
        'reunionGoals': data["reunionGoals"],
        'status': status,
        'redactionDate': redactionDate,
        'meetingDate': meetingDate,
        'meetingLocation': data["meetingLocation"] if "meetingLocation" in data else None,
        'animatorId': data["animatorId"] if "animatorId" in data else None,
        'participantsIds': data["participantsIds"] if "participantsIds" in data else [],
        'themes': data["themes"] if "themes" in data else [],
        'projectId': data["projectId"] if "projectId" in data else None,
    }

    if request.method == "POST":
        MeetingAgendaDataHandler.create_meeting_agenda(**kwargs)
        return "", 201
    elif request.method == "PUT":
        # TODO: Handle concurrent update reflects that could cause conflicts ?
        if not "id" in data:
            return jsonify({"error": "Missing/Invalid fields: id"}), 400
        MeetingAgendaDataHandler.update_meeting_agenda(id=data["id"], **kwargs)
        return "", 204
    return "", 405

@meeting_agendas_bp.route("/", methods=["GET"])
def get_meeting_agendas():
    filters = []

    participantId = request.args.get("participantId")
    if participantId:
        filters.append(ListContainsValueFilter("participantsIds", ObjectId(g.user_id if participantId == 'me' else participantId)))

    meeting_agendas = MeetingAgendaDataHandler.get_meeting_agendas_by_filters(filters)
    return jsonify([meeting_agenda.to_dict() for meeting_agenda in meeting_agendas]), 200

@meeting_agendas_bp.route("/<string:id>", methods=["GET"])
def get_meeting_agenda(id: str):
    meeting_agenda = MeetingAgendaDataHandler.get_meeting_agenda(id)
    if not meeting_agenda:
        return jsonify({"error": "Meeting agenda not found"}), 404
    return jsonify(meeting_agenda.to_dict()), 200
