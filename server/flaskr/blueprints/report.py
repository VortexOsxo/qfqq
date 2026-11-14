from flask import Blueprint, jsonify, request

from flaskr.services.reports.report_endpoint_service import *
from flaskr.blueprints.before_request import login_required
from flaskr.database.handlers.report_config_data_handler import ReportConfigDataHandler
from flaskr.reports.report_columns import ALL_REPORT_COLUMNS
from flaskr.utils.report import get_report_column, get_report_filter

reports_bp = Blueprint("reports", __name__, url_prefix="/reports")
reports_bp.before_request(login_required)


def _get_participant_service():
    if (respId := request.args.get("responsibleId")) is not None:
        return ParticipantReportEndpointService(respId)
    return ParticipantsReportEndpointService()

@reports_bp.route("/participants")
def get_participants_report():
    return _get_participant_service().get_report()

@reports_bp.route("/participants/send", methods=["POST"])
def send_participants_report():
    return _get_participant_service().send_report()

@reports_bp.route("/projects/<int:id>")
def get_project_report(id: int):
    return ProjectReportEndpointService(id).get_report()

@reports_bp.route("/projects/<int:id>/send", methods=["POST"])
def send_project_report(id: int):
    return ProjectReportEndpointService(id).send_report()

@reports_bp.route("/meeting-agendas/<int:id>")
def get_meeting_report(id: int):
    return MeetingReportEndpointService(id).get_report()

@reports_bp.route("/meeting-agendas/<int:id>/send", methods=["POST"])
def send_meeting_report(id: int):
    return MeetingReportEndpointService(id).send_report()


configs_bp = Blueprint("configs", __name__, url_prefix="/configs")

@configs_bp.get("")
def get_report_configs():
    configs = ReportConfigDataHandler.get_report_configs()
    return jsonify([config.to_dict() for config in configs]), 200

@configs_bp.post("")
def create_report_config():
    name = get_report_name(request.args)
    columns = get_report_column(request.args, default=ALL_REPORT_COLUMNS)
    filters = get_report_filter(request.args)
    showReviews = get_report_show_reviews(request.args)

    config = ReportConfigDataHandler.create_report_config(name, columns, filters, showReviews)
    return jsonify(config.to_dict()), 201

reports_bp.register_blueprint(configs_bp)
