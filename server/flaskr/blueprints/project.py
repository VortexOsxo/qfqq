from flask import Blueprint, jsonify, request
from flaskr.database import ProjectDataHandler
from flaskr.utils import verify_missing_inputs, StringValidator, UserIdValidator

projects_bp = Blueprint("projects", __name__, url_prefix="/projects")


@projects_bp.route("", methods=["POST", "PUT"])
def create_project():
    data = request.get_json()
    required_fields = [StringValidator("title"), StringValidator("goals"), UserIdValidator("supervisorId")]
    missings = verify_missing_inputs(data, required_fields)
    if missings:
        return jsonify({"error": f'Missing fields: {", ".join(missings)}'}), 400

    kwargs = {
        "title": data["title"],
        "goals": data.get("goals", ""),
        "supervisorId": data["supervisorId"],
    }

    if request.method == 'POST':
        objectId, acknowledged = ProjectDataHandler.create_project(**kwargs)
        if not acknowledged:
            return "Could not create the new project", 400

        return (jsonify({
            "id": str(objectId),
            "title": data["title"],
            "goals": data["goals"],
            "supervisorId": data["supervisorId"],
        }), 201,)

    elif request.method == 'PUT':
        # TODO: Handle concurrent update reflects that could cause conflicts ?
        if not "id" in data or not "number" in data:
            return jsonify({"error": "Missing/Invalid fields: id or number"}), 400
        ProjectDataHandler.update_project(data['id'], data['number'], **kwargs)
        return "", 204

@projects_bp.route("", methods=['GET'])
def get_projects():
    projects = ProjectDataHandler.get_projects()
    return jsonify([project.to_dict() for project in projects])

