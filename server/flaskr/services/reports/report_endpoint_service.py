from abc import abstractmethod, ABC
from flask import request, g, send_file, jsonify
import threading

from flaskr.database.handlers import DecisionDataHandler, ProjectDataHandler, MeetingDataHandler, UserDataHandler
from flaskr.services.emails import EmailSender, EmailDrafter
from flaskr.reports import ParticipantReportBuilder, ParticipantsReportBuilder, ProjectReportBuilder, MeetingReportBuilder

class ReportEndpointService(ABC):
    def __init__(self, id=None):
        self.id = id
        self._init()

    def get_report(self):
        if not self._is_valid():
            return "Not found", 404
        return send_file(self.get_buffer(), mimetype="application/pdf", as_attachment=False)

    def send_report(self):
        if not self._is_valid():
            return "Not found", 404

        emails = request.json.get("emails", [])
        bytes = self.get_buffer().getvalue()
        threading.Thread(target=self._send_emails, args=(emails, bytes)).start()
        return jsonify({"success": True})

    def _init(self):
        pass

    def _is_valid(self):
        return True

    @abstractmethod
    def get_buffer():
        pass

    def _send_emails(self, emails: list[str], report_bytes: bytes):
        for email_addr in emails:
            EmailSender.send_email(self._get_email(email_addr, report_bytes))

    @abstractmethod
    def _get_email(self, email_addr, report_bytes):
        pass


class ParticipantsReportEndpointService(ReportEndpointService):
    def _get_decisions(self):
        decisions = DecisionDataHandler.get_decisions_report_lines()
        return _filter_decisions(decisions)

    def _get_email(self, email_addr, report_bytes):
        return EmailDrafter.create_participant_report_email(email_addr, report_bytes, lang=g.language)

    def get_buffer(self):
        return ParticipantsReportBuilder(
            self._get_decisions(), g.language, _get_report_column_params()
        ).build()


class ParticipantReportEndpointService(ReportEndpointService):
    def _init(self):
        user = UserDataHandler.get_user_by_id(self.id)
        self.name = user.displayName if user is not None else None

    def _is_valid(self): return self.name is not None

    def _get_decisions(self):
        decisions = DecisionDataHandler.get_decision_report_lines_by_responsible(self.id)
        return _filter_decisions(decisions)

    def _get_email(self, email_addr, report_bytes):
        return EmailDrafter.create_participant_report_email(email_addr, report_bytes, self.name, g.language)

    def get_buffer(self):
        return ParticipantReportBuilder(
            self._get_decisions(), self.name, g.language, _get_report_column_params()
        ).build()


class ProjectReportEndpointService(ReportEndpointService):
    def _init(self):
        self.project = ProjectDataHandler.get_project_by_id(self.id)

    def _is_valid(self): return self.project is not None

    def _get_decisions(self):
        decisions = DecisionDataHandler.get_decisions_report_lines_by_project(self.id)
        return _filter_decisions(decisions)

    def _get_email(self, email_addr, report_bytes):
        return EmailDrafter.create_project_report_email(email_addr, report_bytes, self.project.title, g.language)

    def get_buffer(self):
        return ProjectReportBuilder(
            self.project, self._get_decisions(), g.language, _get_report_column_params()
        ).build()


class MeetingReportEndpointService(ReportEndpointService):
    def _init(self):
        self.show_comments = request.args.get("showComments", "false").lower() == "true"

        self.meeting, self.participants = MeetingDataHandler.get_meeting_with_participants(self.id)
        self.user = UserDataHandler.get_user_by_id(g.user_id)

    def _is_valid(self): return self.meeting is not None and self.user is not None

    def _get_decisions(self):
        decisions = DecisionDataHandler.get_decision_report_lines_by_meeting(self.id)
        return _filter_decisions(decisions)

    def _get_email(self, email_addr, report_bytes):
        return EmailDrafter.create_meeting_report_email(email_addr, report_bytes, self.meeting.title, g.language)

    def get_buffer(self):
        nextMeeting = MeetingDataHandler.get_next_meeting(self.meeting.id)
        reviews = MeetingDataHandler.get_meeting_reviews(self.meeting.id) if self.show_comments else []
        return MeetingReportBuilder(
            self.meeting,
            self.user,
            self.participants,
            self._get_decisions(),
            nextMeeting,
            g.language,
            reviews=reviews,
            selected_columns=_get_report_column_params(),
        ).build()

def _filter_decisions(decisions):
        filters = request.args
        try:
            projectId = filters.get("projectId", None, type=int)
            responsibleId = filters.get("responsibleId", None, type=int)
            status = filters.get("status", None, type=str)
        except:
            return decisions

        filtered = decisions
        if projectId is not None:
            filtered = [d for d in filtered if d.projectId == projectId]

        if responsibleId is not None:
            filtered = [d for d in filtered if d.responsibleId == responsibleId]

        if status is not None:
            filtered = [d for d in filtered if d.status == status]
        return filtered

def _get_report_column_params() -> set[str] | None:
        value = request.args.get("columns")
        if value is None:
            return None
        return {column for column in value.split(",") if column}