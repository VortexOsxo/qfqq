from flask import Blueprint, jsonify, request

from flaskr.database import ProjectDataHandler
from flaskr.blueprints.before_request import login_required
from flaskr.blueprints.middlewares import permission_middleware, Permission
from flaskr.services.inputs import input_middleware, CreateProjectBuilder

projects_bp = Blueprint("projects", __name__, url_prefix="/projects")
projects_bp.before_request(login_required)

@projects_bp.route("", methods=["POST", "PUT"])
@input_middleware(CreateProjectBuilder())
def create_project(**kwargs):
    if request.method == 'POST':
        project = ProjectDataHandler.create_project(**kwargs)
        if project is None:
            return "Could not create the new project", 400

        return jsonify(project.to_dict()), 201

    elif request.method == 'PUT':
        # TODO: Handle concurrent update reflects that could cause conflicts ?
        data = request.get_json()
        if not "id" in data or not "number" in data:
            return jsonify({"error": "Missing/Invalid fields: id or number"}), 400
        ProjectDataHandler.update_project(data['id'], data['number'], **kwargs)
        return "", 204

@projects_bp.route("", methods=['GET'])
def get_projects():
    projects = ProjectDataHandler.get_projects()
    return jsonify([project.to_dict() for project in projects])


@projects_bp.delete("/<int:id>")
@permission_middleware(Permission.DeleteContent)
def delete_project(id):
    try:
        ProjectDataHandler.delete_project_cascade(id)
        return "", 204
    except:
        return "", 500

