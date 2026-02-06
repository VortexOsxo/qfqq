from datetime import datetime
from flask import Blueprint, jsonify, request, g

from flaskr.models import DecisionStatus
from flaskr.blueprints.auth import login_required
from flaskr.database import DecisionDataHandler
from flaskr.utils import verify_missing_inputs, UserIdValidator, StringValidator, MeetingIdValidator

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")


@decisions_bp.route("", methods=["POST"])
@login_required
def create_decision():
    data = request.get_json()
    required_fields = [StringValidator("description"), UserIdValidator("responsibleId"), MeetingIdValidator("meetingId")]

    missings = verify_missing_inputs(data, required_fields)
    if missings:
        return jsonify({"error": f'Missing fields: {", ".join(missings)}'}), 400

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
        description=data["description"],
        status=data["status"],
        dueDate=dueDate,
        responsibleId=data["responsibleId"],
        initialDate=initialDate,
        assistantsIds=data.get("assistantsIds", None),
        meetingId=data.get("meetingId", None),
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
