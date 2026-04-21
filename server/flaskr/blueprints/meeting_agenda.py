from datetime import datetime
from flask import Blueprint, request, jsonify, g, send_file

from flaskr.models import MeetingAgendaStatus
from flaskr.database import MeetingDataHandler, DecisionDataHandler, UserDataHandler
from flaskr.services.inputs import input_middleware, LambdaBuilder, CreateMeetingAgendaBuilder, EnumValidator
from flaskr.reports import MeetingReportBuilder
from flaskr.blueprints.before_request import login_required

meeting_agendas_bp = Blueprint(
    "meeting_agendas", __name__, url_prefix="/meeting-agendas"
)
meeting_agendas_bp.before_request(login_required)


@meeting_agendas_bp.route("", methods=["POST", "PUT"])
@input_middleware(CreateMeetingAgendaBuilder())
def create_meeting_agenda(**obj):
    data = request.get_json()

    meetingDate = (
        datetime.fromisoformat(data["meetingDate"]) if "meetingDate" in data else None
    )

    kwargs = {
        'title': data["title"],
        'goals': data.get("goals", ""),
        'status': data.get("status"),
        'redactionDate': datetime.now(),
        'meetingDate': meetingDate,
        'meetingLocation': data["meetingLocation"] if "meetingLocation" in data else None,
        'animatorId': data["animatorId"] if "animatorId" in data else None,
        'participantsIds': data["participantsIds"] if "participantsIds" in data else [],
        'themes': data["themes"] if "themes" in data else [],
        'projectId': data["projectId"] if "projectId" in data else None,
    }

    if request.method == "POST":
        meeting = MeetingDataHandler.create_meeting_agenda(**kwargs)
        return (jsonify(meeting.to_dict()), 201) if meeting is not None else ("", 400)

    elif request.method == "PUT":
        # TODO: Handle concurrent update reflects that could cause conflicts ?
        if not "id" in data:
            return jsonify({"error": "Missing/Invalid fields: id"}), 400
        MeetingDataHandler.update_meeting_agenda(meetingId=data["id"], **kwargs)
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

@meeting_agendas_bp.patch("/<string:id>/status")
@input_middleware(LambdaBuilder(("status", EnumValidator(MeetingAgendaStatus))))
def patch_meeting_agenda_status(status, id: str):
    result = MeetingDataHandler.update_meeting_status(id, status)
    if not result:
        return jsonify({"error": "Meeting agenda not found"}), 404
    return '', 204

@meeting_agendas_bp.route("/<int:id>/reports")
def get_meeting_report(id: int):
    meeting, participants = MeetingDataHandler.get_meeting_with_participants(id)
    if meeting is None:
        return "No meeting found", 404
    
    user = UserDataHandler.get_user_by_id(g.user_id)
    if user is None:
        return "Author not found", 400

    decisions = DecisionDataHandler.get_decisions_and_responsible_by_meeting(meeting.id)
    buffer = MeetingReportBuilder(meeting, user, participants, decisions, g.language).build()
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )
