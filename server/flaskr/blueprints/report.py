from flask import Blueprint, g, send_file, request, jsonify
import threading
from flaskr.services.emails.email_sender import EmailSender
from flaskr.services.emails.email_drafter import EmailDrafter

from flaskr.database import DecisionDataHandler, ProjectDataHandler, MeetingDataHandler, UserDataHandler
from flaskr.reports import ParticipantsReportBuilder, ProjectReportBuilder, MeetingReportBuilder
from flaskr.blueprints.before_request import login_required

reports_bp = Blueprint("reports", __name__, url_prefix="/reports")
reports_bp.before_request(login_required)


def _send_participants_async(emails: list[str], report_bytes: bytes, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_participants_report_email(email_addr, report_bytes, lang)
        EmailSender.send_email(email)

def _send_project_async(emails: list[str], report_bytes: bytes, project_title: str, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_project_report_email(email_addr, report_bytes, project_title, lang)
        EmailSender.send_email(email)

def _send_meeting_async(emails: list[str], report_bytes: bytes, meeting_title: str, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_meeting_report_email(email_addr, report_bytes, meeting_title, lang)
        EmailSender.send_email(email)


def _get_participants_buffer():
    decisions = DecisionDataHandler.get_decisions_and_responsible()
    return ParticipantsReportBuilder(decisions, g.language).build()

def _get_project_buffer(id: int):
    project = ProjectDataHandler.get_project_by_id(id)
    if project is None: return None, None
    decisions = DecisionDataHandler.get_decisions_and_responsible_by_project(project.id)
    buffer = ProjectReportBuilder(project, decisions, g.language).build()
    return buffer, project.title

def _get_meeting_buffer(id: int):
    meeting, participants = MeetingDataHandler.get_meeting_with_participants(id)
    if meeting is None: return None, None
    user = UserDataHandler.get_user_by_id(g.user_id)
    if user is None: return None, None
    decisions = DecisionDataHandler.get_decisions_and_responsible_by_meeting(meeting.id)
    nextMeeting = MeetingDataHandler.get_next_meeting(meeting.id)
    buffer = MeetingReportBuilder(meeting, user, participants, decisions, nextMeeting, g.language).build()
    return buffer, meeting.title


@reports_bp.route("/participants")
def get_participants_report():
    return send_file(
        _get_participants_buffer(),
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )

@reports_bp.route("/participants/send", methods=["POST"])
def send_participants_report():
    emails = request.json.get("emails", [])
    threading.Thread(target=_send_participants_async, args=(emails, _get_participants_buffer().getvalue(), g.language)).start()
    return jsonify({"success": True})


@reports_bp.route("/projects/<int:id>")
def get_project_report(id: int):
    buffer, _ = _get_project_buffer(id)
    if not buffer: return "Not found", 404
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )

@reports_bp.route("/projects/<int:id>/send", methods=["POST"])
def send_project_report(id: int):
    emails = request.json.get("emails", [])
    buffer, project_title = _get_project_buffer(id)
    if not buffer: return "Not found", 404
    threading.Thread(target=_send_project_async, args=(emails, buffer.getvalue(), project_title, g.language)).start()
    return jsonify({"success": True})


@reports_bp.route("/meeting-agendas/<int:id>")
def get_meeting_report(id: int):
    buffer, _ = _get_meeting_buffer(id)
    if not buffer: return "Not found", 404
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
        download_name="report.pdf",
    )

@reports_bp.route("/meeting-agendas/<int:id>/send", methods=["POST"])
def send_meeting_report(id: int):
    emails = request.json.get("emails", [])
    buffer, meeting_title = _get_meeting_buffer(id)
    if not buffer: return "Not found", 404
    threading.Thread(target=_send_meeting_async, args=(emails, buffer.getvalue(), meeting_title, g.language)).start()
    return jsonify({"success": True})
