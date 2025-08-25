from flask import Blueprint, jsonify, request
from flaskr.database import ProjectDataHandler
from flaskr.database import ValueUpdater

projects_bp = Blueprint("projects", __name__, url_prefix="/projects")


@projects_bp.route("", methods=["POST"])
def create_project():
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

@projects_bp.route("/<string:id>", methods=["PATCH"])
def update_project(id: str):
    data = request.get_json()

    updaters = []
    title = data.get("title")
    if title:
        updaters.append(ValueUpdater("title", title))
    
    description = data.get("description")
    if description:
        updaters.append(ValueUpdater("description", description))
    
    ProjectDataHandler.update_project(id, updaters)
    
    