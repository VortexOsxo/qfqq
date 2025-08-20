from flask import Blueprint, request, jsonify
from flaskr.models import MeetingAgendaStatus
from flaskr.database.mongo.handlers.meeting_agenda_data_handler import (
    MeetingAgendaDataHandler,
)
from datetime import datetime

meeting_agendas_bp = Blueprint(
    "meeting_agendas", __name__, url_prefix="/meeting-agendas"
)


@meeting_agendas_bp.route("", methods=["POST"])
def create_meeting_agenda():
    data = request.get_json()
    required_fields = ["title", "reunionGoals", "status", "redactionDate"]
    missing = [field for field in required_fields if field not in data]
    if missing:
        return jsonify({"error": f'Missing fields: {", ".join(missing)}'}), 400

    if data["status"] not in MeetingAgendaStatus.__members__:
        return jsonify({"error": "Invalid status"}), 400

    try:
        redactionDate = datetime.fromisoformat(data["redactionDate"])
        meetingDate = (
            datetime.fromisoformat(data["meetingDate"])
            if "meetingDate" in data
            else None
        )
    except Exception as e:
        return jsonify({"error": f"Invalid data format: {str(e)}"}), 400

    MeetingAgendaDataHandler.create_meeting_agenda(
        title=data["title"],
        reunionGoals=data["reunionGoals"],
        status=data["status"],
        redactionDate=redactionDate,
        meetingDate=meetingDate,
        meetingLocation=data["meetingLocation"] if "meetingLocation" in data else None,
        animatorId=data["animatorId"] if "animatorId" in data else None,
        participantsIds=data["participantsIds"] if "participantsIds" in data else [],
        themes=data["themes"] if "themes" in data else [],
        project=data["projectId"] if "projectId" in data else None,
    )
    return jsonify({"message": "Meeting agenda created successfully"}), 201

@meeting_agendas_bp.route("", methods=["GET"])
def get_meeting_agendas():
    meeting_agendas = MeetingAgendaDataHandler.get_meeting_agendas()
    return jsonify([meeting_agenda.to_dict() for meeting_agenda in meeting_agendas]), 200

@meeting_agendas_bp.route("/<string:id>", methods=["GET"])
def get_meeting_agenda(id: str):
    meeting_agenda = MeetingAgendaDataHandler.get_meeting_agenda(id)
    if not meeting_agenda:
        return jsonify({"error": "Meeting agenda not found"}), 404
    return jsonify(meeting_agenda.to_dict()), 200