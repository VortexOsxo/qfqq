from datetime import datetime
from flask import Blueprint, jsonify, request, g

from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler
from flaskr.services.inputs import input_middleware, CreateDecisionBuilder, LambdaBuilder, EnumValidator
from flaskr.blueprints.before_request import login_required

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")
decisions_bp.before_request(login_required)

@decisions_bp.route("", methods=["POST"])
@input_middleware(CreateDecisionBuilder())
def create_decision(description, responsibleId, meetingId, dueDate):
    data = request.get_json()
    data["status"] = DecisionStatus.inProgress

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
    return (jsonify(decision.to_dict()), 201) if decision is not None else ("", 400)


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

