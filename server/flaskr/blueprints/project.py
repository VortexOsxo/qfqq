from flask import Blueprint, jsonify, request
from flaskr.database import ProjectDataHandler

projects_bp = Blueprint("projects", __name__, url_prefix="/projects")


@projects_bp.route("", methods=["POST"])
def create_decision():
    data = request.get_json()
    required_fields = ["title", "description"]
    missing = [field for field in required_fields if field not in data]
    if missing:
        return jsonify({"error": f'Missing fields: {", ".join(missing)}'}), 400

    ProjectDataHandler.create_project(
        title=data["title"],
        description=data["description"],
    )
    return jsonify({"message": "Meeting agenda created successfully"}), 201

@projects_bp.route("", methods=['GET'])
def get_projects():
    projects = ProjectDataHandler.get_projects()
    return jsonify([project.to_dict() for project in projects])