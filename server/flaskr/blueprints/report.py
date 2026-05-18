from flask import Blueprint, g, send_file

from flaskr.database import DecisionDataHandler, ProjectDataHandler, MeetingDataHandler, UserDataHandler
from flaskr.reports import ParticipantsReportBuilder, ProjectReportBuilder, MeetingReportBuilder
from flaskr.blueprints.before_request import login_required

reports_bp = Blueprint("reports", __name__, url_prefix="/reports")
reports_bp.before_request(login_required)


@reports_bp.route("/participants")
def get_participants_report():

    decisions = DecisionDataHandler.get_decisions_and_responsible()
    buffer = ParticipantsReportBuilder(decisions, g.language).build()
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )

@reports_bp.route("/projects/<int:id>")
def get_project_report(id: int):
    project = ProjectDataHandler.get_project_by_id(id)
    if project is None: return "No project found", 404

    decisions = DecisionDataHandler.get_decisions_and_responsible_by_project(project.id)

    buffer = ProjectReportBuilder(project, decisions, g.language).build()
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )

@reports_bp.route("/meeting-agendas/<int:id>")
def get_meeting_report(id: int):
    meeting, participants = MeetingDataHandler.get_meeting_with_participants(id)
    if meeting is None:
        return "No meeting found", 404
    
    user = UserDataHandler.get_user_by_id(g.user_id)
    if user is None:
        return "Author not found", 400
    
    decisions = DecisionDataHandler.get_decisions_and_responsible_by_meeting(meeting.id)
    nextMeeting = MeetingDataHandler.get_next_meeting(meeting.id)
    
    buffer = MeetingReportBuilder(meeting, user, participants, decisions, nextMeeting, g.language).build()
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )
