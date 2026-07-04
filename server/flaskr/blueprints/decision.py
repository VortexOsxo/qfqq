from datetime import datetime
from flask import Blueprint, jsonify, request, g

from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler
from flaskr.services.inputs import input_middleware, CreateDecisionBuilder, LambdaBuilder, EnumValidator
from flaskr.blueprints.before_request import login_required
from flaskr.blueprints.middlewares import permission_middleware, Permission

from flaskr.services.notifications import NotificationService, NotificationType

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
        status=DecisionStatus.inProgress,
        dueDate=dueDate,
        responsibleId=responsibleId,
        initialDate=datetime.now(),
        assistantsIds=data.get("assistantsIds", None),
        meetingId=meetingId,
    )
    if decision is not None:
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

@decisions_bp.patch("/<string:id>/status")
@input_middleware(LambdaBuilder(("status", EnumValidator(DecisionStatus))))
def patch_meeting_agenda_status(status, id: str):
    try:
        result = False
        if status == 'completed':
            result = DecisionDataHandler.complete_decision(id)
        elif status == 'cancelled':
            result = DecisionDataHandler.cancel_decision(id)
        if not result:
            return '', 404
        return '', 204
    except: pass
    return '', 404

@decisions_bp.delete("/<int:id>")
@permission_middleware(Permission.DeleteContent)
def delete_decision(id):
    try:
        DecisionDataHandler.delete_decision(id)
        return "", 204
    except:
        return "", 500