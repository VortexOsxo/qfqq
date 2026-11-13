from flask import Blueprint, request

from flaskr.services.reports.report_endpoint_service import *
from flaskr.blueprints.before_request import login_required

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
