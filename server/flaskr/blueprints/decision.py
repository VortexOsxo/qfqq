from flask import Blueprint, jsonify, request, g
from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler
from flaskr.blueprints.auth import login_required
from datetime import datetime

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")


@decisions_bp.route("", methods=["POST"])
@login_required
def create_decision():
    data = request.get_json()
    required_fields = ["description", "responsibleId"]
    missing = [field for field in required_fields if field not in data]
    if missing:
        return jsonify({"error": f'Missing fields: {", ".join(missing)}'}), 400

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
    decisions = DecisionDataHandler.get_decisions()
    return jsonify([decision for decision in decisions]), 200
