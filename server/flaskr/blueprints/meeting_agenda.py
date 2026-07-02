from datetime import datetime
from flask import Blueprint, request, jsonify, g

from flaskr.models import MeetingAgendaStatus
from flaskr.database import MeetingDataHandler, UserDataHandler
from flaskr.services.inputs import (
    input_middleware,
    LambdaBuilder,
    CreateMeetingAgendaBuilder,
    EnumValidator,
    IntValidator,
    StringValidator,
)
from flaskr.services.notifications import NotificationService, NotificationType
from flaskr.blueprints.before_request import login_required
from flaskr.blueprints.middlewares import permission_middleware, Permission

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
    status = data.get('status')

    kwargs = {
        'title': data["title"],
        'goals': data.get("goals", ""),
        'status': status,
        'redactionDate': datetime.now(),
        'meetingDate': meetingDate,
        'meetingLocation': data["meetingLocation"] if "meetingLocation" in data else None,
        'animatorId': data["animatorId"] if "animatorId" in data else None,
        'participantsIds': data["participantsIds"] if "participantsIds" in data else [],
        'themes': data["themes"] if "themes" in data else [],
        'projectId': data["projectId"] if "projectId" in data else None,
    }

    if request.method == "POST":
        previousMeetingId = data.get("previousMeetingId", -1)
        meeting = MeetingDataHandler.create_meeting_agenda(previousMeetingId=previousMeetingId, **kwargs)

        if status == "planned":
            NotificationService.add_notification(NotificationType.MeetingStart.value, g.org_id, meeting)

        return (jsonify(meeting.to_dict()), 201) if meeting is not None else ("", 400)

    elif request.method == "PUT":
        # TODO: Handle concurrent update reflects that could cause conflicts ?
        if not "id" in data:
            return jsonify({"error": "Missing/Invalid fields: id"}), 400
        id = data.get("id")

        meeting = MeetingDataHandler.get_meeting_agenda(id)
        MeetingDataHandler.update_meeting_agenda(meetingId=id, **kwargs)

        if meeting.status != "planned" and status == "planned":
            meeting = MeetingDataHandler.get_meeting_agenda(id)
            NotificationService.add_notification(NotificationType.MeetingStart.value, g.org_id, meeting)
        elif meeting.status == "planned" and data.get('meetingDate') is not None and meeting.meetingDate != datetime.fromisoformat(data.get('meetingDate')):
            NotificationService.update_notification(NotificationType.MeetingStart.value, g.org_id, meeting.id, meeting)

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


@meeting_agendas_bp.get("/<int:id>/reviews")
def get_meeting_reviews(id: int):
    reviews = MeetingDataHandler.get_meeting_reviews(id)
    return jsonify([review.to_dict() for review in reviews]), 200


@meeting_agendas_bp.post("/<int:id>/reviews")
@input_middleware(
    LambdaBuilder(
        ("objective", IntValidator(1,5)),
        ("smoothRunning", IntValidator(1,5)),
        ("preparation", IntValidator(1,5)),
        ("length", IntValidator(1,5)),
        ("respect", IntValidator(1,5)),
        ("comments", StringValidator(allow_empty=True)),
    )
)
def create_meeting_review(objective, smoothRunning, preparation, length, respect, comments, id: int):
    try:
        MeetingDataHandler.create_review(
            meetingId=id,
            userId=g.user_id,
            objective=objective,
            smoothRunning=smoothRunning,
            preparation=preparation,
            length=length,
            respect=respect,
            comments=comments,
        )
        return "", 201
    except Exception:
        return jsonify({"error": "Unable to create meeting review"}), 400


@meeting_agendas_bp.patch("/<string:id>/status")
@input_middleware(LambdaBuilder(("status", EnumValidator(MeetingAgendaStatus))))
def patch_meeting_agenda_status(status, id: str):
    result = MeetingDataHandler.update_meeting_status(id, status)
    if not result:
        return jsonify({"error": "Meeting agenda not found"}), 404
    if status=="planned":
        meeting = MeetingDataHandler.get_meeting_agenda(id)
        NotificationService.add_notification(NotificationType.MeetingStart.value, g.org_id, meeting)
    elif status == "ongoing":
        # TODO: remove meetingstart notification and add meeting started notification
        pass
    return '', 204


@meeting_agendas_bp.delete("/<int:id>")
@permission_middleware(Permission.CanDelete)
def delete_meeting(id):
    try:
        MeetingDataHandler.delete_meeting(id)
        return "", 204
    except:
        return "", 500
    
@meeting_agendas_bp.route("/<int:id>/code", methods=["GET"])
def get_meeting_code(id):
    # TODO: Obfuscate
    return f"{g.org_id}-{id}", 200