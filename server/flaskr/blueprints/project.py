from flask import Blueprint, jsonify, request
from flaskr.database import ProjectDataHandler
from flaskr.database import ValueUpdater
from flaskr.utils import verify_missing_inputs, StringValidator

projects_bp = Blueprint("projects", __name__, url_prefix="/projects")


@projects_bp.route("", methods=["POST"])
def create_project():
    data = request.get_json()
    required_fields = [StringValidator("title"), StringValidator("description")]
    missings = verify_missing_inputs(data, required_fields)
    if missings:
        return jsonify({"error": f'Missing fields: {", ".join(missings)}'}), 400

    objectId, acknowledged = ProjectDataHandler.create_project(
        title=data["title"],
        description=data.get("description", ""),
    )

    if not acknowledged:
        return "Could not create the new project", 400
    
    return jsonify({'id': str(objectId), 'title':data['title'], 'description': data['description']}), 201

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
    
    