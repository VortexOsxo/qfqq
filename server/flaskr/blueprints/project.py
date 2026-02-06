from flask import Blueprint, jsonify, request, send_file

from flaskr.database import ProjectDataHandler, DecisionDataHandler
from flaskr.utils import get_inputs_errors, StringValidator, UserIdValidator
from flaskr.reports import ProjectReportBuilder


projects_bp = Blueprint("projects", __name__, url_prefix="/projects")


@projects_bp.route("", methods=["POST", "PUT"])
def create_project():
    data = request.get_json()
    required_fields = [StringValidator("title"), StringValidator("goals"), UserIdValidator("supervisorId")]
    errors = get_inputs_errors(data, required_fields)
    if len(errors):
        return jsonify(errors), 400

    kwargs = {
        "title": data["title"],
        "goals": data.get("goals", ""),
        "supervisorId": data["supervisorId"],
    }

    if request.method == 'POST':
        project = ProjectDataHandler.create_project(**kwargs)
        if project is None:
            return "Could not create the new project", 400

        return jsonify(project.to_dict()), 201

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

@projects_bp.route("/<id>/reports")
def get_project_report(id: str):
    project = ProjectDataHandler.get_item_by_id(id)
    if project is None: return "No project found", 404

    decisions = DecisionDataHandler.get_decision_by_project('projectId')

    buffer = ProjectReportBuilder(project, decisions).build()
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,          # True → download, False → inline
        download_name="report.pdf",
    )
