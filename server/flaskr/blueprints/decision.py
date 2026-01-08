from datetime import datetime
from flask import Blueprint, jsonify, request, g
from bson import ObjectId

from flaskr.models import DecisionStatus
from flaskr.blueprints.auth import login_required
from flaskr.database import DecisionDataHandler, ValueFilter
from flaskr.utils import verify_missing_inputs, UserIdValidator, StringValidator

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")


@decisions_bp.route("", methods=["POST"])
@login_required
def create_decision():
    data = request.get_json()
    required_fields = [StringValidator("description"), UserIdValidator("responsibleId")]

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
        status=data["status"].as_int(),
        dueDate=dueDate,
        responsibleId=data["responsibleId"],
        reporterId=g.user_id,
        initialDate=initialDate,
        assistantsId=data["assistantsId"] if "assistantsId" in data else None,
        projectId=data["projectId"] if "projectId" in data else None,
    )
    return jsonify({"message": "Meeting agenda created successfully"}), 201


@decisions_bp.route("/", methods=["GET"])
def get_decisions():
    filters = []

    responsibleId = request.args.get("responsibleId")
    if responsibleId:
        filters.append(ValueFilter("responsibleId", ObjectId(g.user_id if responsibleId == 'me' else responsibleId)))

    decisions = DecisionDataHandler.get_decisions_by_filters(filters)
    return jsonify([decision for decision in decisions]), 200
