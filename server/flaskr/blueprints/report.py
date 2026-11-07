from flask import Blueprint, g, send_file, request, jsonify
import threading
from flaskr.services.emails.email_sender import EmailSender
from flaskr.services.emails.email_drafter import EmailDrafter

from flaskr.models import Decision
from flaskr.database import DecisionDataHandler, ProjectDataHandler, MeetingDataHandler, UserDataHandler
from flaskr.reports import ParticipantReportBuilder, ParticipantsReportBuilder, ProjectReportBuilder, MeetingReportBuilder
from flaskr.blueprints.before_request import login_required

reports_bp = Blueprint("reports", __name__, url_prefix="/reports")
reports_bp.before_request(login_required)


def _get_decision_item(item) -> Decision:
    if isinstance(item, tuple):
        return item[0]
    return item


def filter_decisions(decisions, filters):
    if not decisions or not filters:
        return decisions

    filtered = decisions

    if "projectId" in filters and filters["projectId"] not in (None, ""):
        try:
            target_project_id = int(filters["projectId"])
            filtered = [
                d for d in filtered if _get_decision_item(d).projectId == target_project_id
            ]
        except (ValueError, TypeError):
            pass

    if "responsibleId" in filters and filters["responsibleId"] not in (None, ""):
        try:
            target_resp_id = int(filters["responsibleId"])
            filtered = [
                d for d in filtered if _get_decision_item(d).responsibleId == target_resp_id
            ]
        except (ValueError, TypeError):
            pass

    if "status" in filters and filters["status"] not in (None, ""):
        target_status = str(filters["status"]).strip()
        filtered = [
            d for d in filtered if _get_decision_item(d).status == target_status
        ]

    return filtered


def get_report_filter_params() -> dict[str, str]:
    params = {}
    for name in ("projectId", "responsibleId", "status"):
        value = request.args.get(name)
        if value is not None:
            params[name] = value
    return params


def _send_participants_async(emails: list[str], report_bytes: bytes, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_participant_report_email(email_addr, report_bytes, lang=lang)
        EmailSender.send_email(email)

def _send_participant_async(emails: list[str], report_bytes: bytes, name: str, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_participant_report_email(email_addr, report_bytes, name, lang)
        EmailSender.send_email(email)

def _send_project_async(emails: list[str], report_bytes: bytes, project_title: str, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_project_report_email(email_addr, report_bytes, project_title, lang)
        EmailSender.send_email(email)

def _send_meeting_async(emails: list[str], report_bytes: bytes, meeting_title: str, lang: str):
    for email_addr in emails:
        email = EmailDrafter.create_meeting_report_email(email_addr, report_bytes, meeting_title, lang)
        EmailSender.send_email(email)


def _get_participants_buffer(filters: dict[str, str] | None = None):
    decisions = DecisionDataHandler.get_decisions_and_responsible()
    if filters:
        decisions = filter_decisions(decisions, filters)
    return ParticipantsReportBuilder(decisions, g.language).build()

def _get_participant_buffer(participantId: int | str, filters: dict[str, str] | None = None):
    try:
        p_id = int(participantId)
    except (ValueError, TypeError):
        return None, None
    decisions, name = DecisionDataHandler.get_decisions_and_responsible_by_responsible(p_id)
    if decisions is None:
        return None, None
    if filters:
        decisions = filter_decisions(decisions, filters)
    return ParticipantReportBuilder(decisions, name, g.language).build(), name

def _get_project_buffer(id: int, filters: dict[str, str] | None = None):
    project = ProjectDataHandler.get_project_by_id(id)
    if project is None: return None, None
    decisions = DecisionDataHandler.get_decisions_and_responsible_by_project(project.id)
    if filters:
        decisions = filter_decisions(decisions, filters)
    buffer = ProjectReportBuilder(project, decisions, g.language).build()
    return buffer, project.title

def _get_meeting_buffer(
    id: int,
    filters: dict[str, str] | None = None,
    show_comments: bool = False,
):
    meeting, participants = MeetingDataHandler.get_meeting_with_participants(id)
    if meeting is None: return None, None
    user = UserDataHandler.get_user_by_id(g.user_id)
    if user is None: return None, None
    decisions = DecisionDataHandler.get_decisions_and_responsible_by_meeting(meeting.id)
    if filters:
        decisions = filter_decisions(decisions, filters)
    nextMeeting = MeetingDataHandler.get_next_meeting(meeting.id)
    reviews = MeetingDataHandler.get_meeting_reviews(meeting.id) if show_comments else []
    buffer = MeetingReportBuilder(
        meeting,
        user,
        participants,
        decisions,
        nextMeeting,
        g.language,
        reviews=reviews,
    ).build()
    return buffer, meeting.title


@reports_bp.route("/participants")
def get_participants_report():
    filters = get_report_filter_params()
    responsible_id = filters.get("responsibleId")

    if responsible_id:
        buffer, _ = _get_participant_buffer(responsible_id, filters)
        if buffer is None:
            return "Participant not found", 404
        return send_file(
            buffer,
            mimetype="application/pdf",
            as_attachment=False,
        )

    return send_file(
        _get_participants_buffer(filters),
        mimetype="application/pdf",
        as_attachment=False,
    )

@reports_bp.route("/participants/send", methods=["POST"])
def send_participants_report():
    filters = get_report_filter_params()
    emails = request.json.get("emails", [])
    responsible_id = filters.get("responsibleId")

    if responsible_id:
        buffer, name = _get_participant_buffer(responsible_id, filters)
        if buffer is None:
            return "Participant not found", 404
        threading.Thread(
            target=_send_participant_async,
            args=(emails, buffer.getvalue(), name, g.language),
        ).start()
        return jsonify({"success": True})

    threading.Thread(
        target=_send_participants_async,
        args=(emails, _get_participants_buffer(filters).getvalue(), g.language),
    ).start()
    return jsonify({"success": True})

@reports_bp.route("/projects/<int:id>")
def get_project_report(id: int):
    filters = get_report_filter_params()
    buffer, _ = _get_project_buffer(id, filters)
    if not buffer: return "Not found", 404
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
    )

@reports_bp.route("/projects/<int:id>/send", methods=["POST"])
def send_project_report(id: int):
    filters = get_report_filter_params()
    emails = request.json.get("emails", [])
    buffer, project_title = _get_project_buffer(id, filters)
    if not buffer: return "Not found", 404
    threading.Thread(target=_send_project_async, args=(emails, buffer.getvalue(), project_title, g.language)).start()
    return jsonify({"success": True})


@reports_bp.route("/meeting-agendas/<int:id>")
def get_meeting_report(id: int):
    show_comments = request.args.get("showComments", "false").lower() == "true"
    filters = get_report_filter_params()
    buffer, _ = _get_meeting_buffer(id, filters, show_comments)
    if not buffer: return "Not found", 404
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=False,
    )

@reports_bp.route("/meeting-agendas/<int:id>/send", methods=["POST"])
def send_meeting_report(id: int):
    show_comments = request.args.get("showComments", "false").lower() == "true"
    filters = get_report_filter_params()
    emails = request.json.get("emails", [])
    buffer, meeting_title = _get_meeting_buffer(id, filters, show_comments)
    if not buffer: return "Not found", 404
    threading.Thread(target=_send_meeting_async, args=(emails, buffer.getvalue(), meeting_title, g.language)).start()
    return jsonify({"success": True})
