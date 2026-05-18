from flask import Blueprint, g, send_file

from flaskr.database import DecisionDataHandler
from flaskr.reports import ParticipantsReportBuilder
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

