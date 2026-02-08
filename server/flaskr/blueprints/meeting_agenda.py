from datetime import datetime
from flask import Blueprint, request, jsonify, g, send_file

from flaskr.models import MeetingAgendaStatus
from flaskr.database import MeetingDataHandler, DecisionDataHandler
from flaskr.utils import (
    StringValidator,
    EnumValidator,
    UserIdValidator,
    ListValidator,
    ProjectIdValidator,
    verify_missing_inputs,
)
from flaskr.reports import MeetingReportBuilder

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
            StringValidator("goals"),
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
        'goals': data.get("goals", ""),
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
        MeetingDataHandler.create_meeting_agenda(**kwargs)
        return "", 201
    elif request.method == "PUT":
        # TODO: Handle concurrent update reflects that could cause conflicts ?
        if not "id" in data:
            return jsonify({"error": "Missing/Invalid fields: id"}), 400
        MeetingDataHandler.update_meeting_agenda(id=data["id"], **kwargs)
        return "", 204
    return "", 405

@meeting_agendas_bp.route("/", methods=["GET"])
def get_meeting_agendas():
    participantId = request.args.get("participantId")

    if participantId:
        participantId = g.user_id if participantId == 'me' else participantId
        meeting_agendas = MeetingDataHandler.get_meetings_by_participant(participantId)
    else:
        meeting_agendas = MeetingDataHandler.get_meeting_agendas()

    return jsonify([meeting_agenda.to_dict() for meeting_agenda in meeting_agendas]), 200

@meeting_agendas_bp.route("/<string:id>", methods=["GET"])
def get_meeting_agenda(id: str):
    meeting_agenda = MeetingDataHandler.get_meeting_agenda(id)
    if not meeting_agenda:
        return jsonify({"error": "Meeting agenda not found"}), 404
    return jsonify(meeting_agenda.to_dict()), 200

@meeting_agendas_bp.route("/<int:id>/reports")
def get_meeting_report(id: int):
    meeting, participants = MeetingDataHandler.get_meeting_with_participants(id)
    if meeting is None:
        return "No meeting found", 404

    lang = request.args.get('lang', 'fr')
    decisions = DecisionDataHandler.get_decisions_and_responsible_by_meeting(meeting.id)
    buffer = MeetingReportBuilder(meeting, participants, decisions, lang).build()
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )
