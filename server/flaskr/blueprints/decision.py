from datetime import datetime
from flask import Blueprint, jsonify, request, g

from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler
from flaskr.services.inputs import input_middleware, CreateDecisionBuilder
from flaskr.blueprints.before_request import login_required

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")
decisions_bp.before_request(login_required)

@decisions_bp.route("", methods=["POST"])
@input_middleware(CreateDecisionBuilder())
def create_decision(description, responsibleId, meetingId, dueDate):
    data = request.get_json()

    # TODO: Refactor those status
    if "status" not in data:
        data["status"] = DecisionStatus.toBeValidated
    elif data["status"] not in DecisionStatus.__members__:
        data["status"] = DecisionStatus.inProgress

    dueDate = datetime.fromisoformat(dueDate) if dueDate is not None else None

    DecisionDataHandler.create_decision(
        description=description,
        status=data["status"],
        dueDate=dueDate,
        responsibleId=responsibleId,
        initialDate=datetime.now(),
        assistantsIds=data.get("assistantsIds", None),
        meetingId=meetingId,
    )
    return "", 201


@decisions_bp.route("/", methods=["GET"])
def get_decisions():
    responsibleId = request.args.get("responsibleId")

    if responsibleId:
        responsibleId = g.user_id if responsibleId == 'me' else responsibleId
        decisions = DecisionDataHandler.get_decision_by_responsible(responsibleId)
    else:
        decisions = DecisionDataHandler.get_decisions()

    return jsonify([decision.to_dict() for decision in decisions]), 200
