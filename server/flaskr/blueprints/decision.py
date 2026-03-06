from datetime import datetime
from flask import Blueprint, jsonify, request, g

from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler
from flaskr.services.inputs import input_middleware, CreateProjectBuilder
from flaskr.blueprints.before_request import login_required

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")
decisions_bp.before_request(login_required)

@decisions_bp.route("", methods=["POST"])
@input_middleware(CreateProjectBuilder())
def create_decision(description, responsibleId, meetingId):
    data = request.get_json()

    # TODO: Refactor those status
    if "status" not in data:
        data["status"] = DecisionStatus.toBeValidated
    elif data["status"] not in DecisionStatus.__members__:
        data["status"] = DecisionStatus.inProgress

    try:
        dueDate = datetime.fromisoformat(data["dueDate"]) if "dueDate" in data else None
        initialDate = (
            datetime.fromisoformat(data["initialDate"])
            if "initialDate" in data
            else datetime.now()
        )
    except Exception as e:
        return jsonify({"error": f"Invalid data format: {str(e)}"}), 400

    DecisionDataHandler.create_decision(
        description=description,
        status=data["status"],
        dueDate=dueDate,
        responsibleId=responsibleId,
        initialDate=initialDate,
        assistantsIds=data.get("assistantsIds", None),
        meetingId=meetingId,
    )
    return jsonify({"message": "Meeting agenda created successfully"}), 201


@decisions_bp.route("/", methods=["GET"])
def get_decisions():
    responsibleId = request.args.get("responsibleId")

    if responsibleId:
        responsibleId = g.user_id if responsibleId == 'me' else responsibleId
        decisions = DecisionDataHandler.get_decision_by_responsible(responsibleId)
    else:
        decisions = DecisionDataHandler.get_decisions()

    return jsonify([decision.to_dict() for decision in decisions]), 200
