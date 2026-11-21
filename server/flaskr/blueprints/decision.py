from datetime import datetime
from flask import Blueprint, jsonify, request, g

from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler, DecisionEventDataHandler
from flaskr.services.inputs import input_middleware, CreateDecisionBuilder, LambdaBuilder, LiteralValidator, StringValidator
from flaskr.blueprints.before_request import login_required, on_exception
from flaskr.blueprints.middlewares import permission_middleware, Permission

from flaskr.services.notifications.notification_service import NotificationService
from flaskr.services.notifications.notification_type import NotificationType

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")
decisions_bp.before_request(login_required)

@decisions_bp.route("", methods=["POST"])
@input_middleware(CreateDecisionBuilder())
@permission_middleware(Permission.Contribute)
def create_decision(description, responsibleId, meetingId, dueDate):
    data = request.get_json()
    dueDate = datetime.fromisoformat(dueDate) if dueDate is not None else None

    decision = DecisionDataHandler.create_decision(
        description=description,
        status="inProgress",
        dueDate=dueDate,
        responsibleId=responsibleId,
        initialDate=datetime.now(),
        assistantsIds=data.get("assistantsIds", None),
        meetingId=meetingId,
    )
    if decision is not None:
        DecisionEventDataHandler.create_decision_created(int(decision.id), g.user_id)
        NotificationService.add_notification(NotificationType.DecisionDue.value, g.org_id, decision)
        return jsonify(decision.to_dict()), 201
    
    return "", 400


@decisions_bp.route("/", methods=["GET"])
def get_decisions():
    responsibleId = request.args.get("responsibleId")

    if responsibleId:
        responsibleId = g.user_id if responsibleId == 'me' else responsibleId
        decisions = DecisionDataHandler.get_decision_by_responsible(responsibleId)
    else:
        decisions = DecisionDataHandler.get_decisions()

    return jsonify([decision.to_dict() for decision in decisions]), 200

@decisions_bp.get("/<int:id>/events")
def get_decision_events(id: int):
    events = DecisionEventDataHandler.get_decision_events_by_id(id)
    return jsonify([event.to_dict() for event in events]), 200


@decisions_bp.patch("/<int:id>/status")
@input_middleware(LambdaBuilder(("status", LiteralValidator(DecisionStatus))))
@on_exception(statusCode=404)
def patch_meeting_agenda_status(status, id: int):
    result = False
    if status == 'completed':
        result = DecisionDataHandler.complete_decision(id)
    elif status == 'pending':
        result = DecisionDataHandler.pending_decision(id)
    elif status == 'cancelled':
        result = DecisionDataHandler.cancel_decision(id)
        
    if not result:
        return '', 404

    DecisionEventDataHandler.create_decision_status_updated(id, g.user_id, status)
    NotificationService.remove_notification(NotificationType.DecisionDue.value, g.org_id, id)
    return '', 204

@decisions_bp.patch("/<string:id>/completion-message")
@input_middleware(LambdaBuilder(("message", StringValidator())))
@on_exception(statusCode=404)
def patch_decision_completion_message(message, id: str):
    result = DecisionDataHandler.set_completion_message(id, message)
    return ('', 204) if result else ('', 404)

@decisions_bp.delete("/<int:id>")
@permission_middleware(Permission.DeleteContent)
@on_exception(statusCode=500)
def delete_decision(id):
    DecisionDataHandler.delete_decision(id)
    NotificationService.remove_notification(NotificationType.DecisionDue.value, g.org_id, id)
    return "", 204
