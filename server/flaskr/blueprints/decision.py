from flask import Blueprint, jsonify, request
from flaskr.models import DecisionStatus
from flaskr.database import DecisionDataHandler
from datetime import datetime

decisions_bp = Blueprint("decisions", __name__, url_prefix="/decisions")


@decisions_bp.route("", methods=["POST"])
def create_decision():
    data = request.get_json()
    required_fields = ["description", "status", "dueDate", "responsibleId"]
    missing = [field for field in required_fields if field not in data]
    if missing:
        return jsonify({"error": f'Missing fields: {", ".join(missing)}'}), 400

    if data["status"] not in DecisionStatus.__members__:
        return jsonify({"error": "Invalid status"}), 400

    try:
        dueDate = datetime.fromisoformat(data["dueDate"])
        initialDate = (
            datetime.fromisoformat(data["initialDate"])
            if "initialDate" in data
            else None
        )
    except Exception as e:
        return jsonify({"error": f"Invalid data format: {str(e)}"}), 400

    DecisionDataHandler.create_decision(
        description=data["description"],
        status=data["status"],
        dueDate=dueDate,
        responsibleId=data["responsibleId"],
        initialDate=initialDate,
        assistantsId=data["assistantsId"] if "assistantsId" in data else None,
        projectId=data["projectId"] if "projectId" in data else None,
    )
    return jsonify({"message": "Meeting agenda created successfully"}), 201
