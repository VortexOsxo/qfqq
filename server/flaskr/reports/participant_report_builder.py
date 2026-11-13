from .report_builder import ReportBuilder
from .report_columns import PARTICIPANT_REPORT_COLUMNS, select_report_columns
from flaskr.models import Decision, decision_status_as_string
from io import BytesIO


class ParticipantReportBuilder:

    def __init__(
        self,
        decisions: list[Decision],
        name: str,
        lang: str = "fr",
        selected_columns: set[str] | None = None,
    ):
        self.decisions = decisions
        self.name = name.title()
        self.lang = lang
        self.selected_columns = selected_columns

    def build(self):
        title = f"Activités" if self.lang == "fr" else "Tasks"
        subtitle = f"Pour {self.name}" if self.lang == "fr" else f"For {self.name}"

        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header(title=title, subtitle=subtitle)

        builder.division()

        cols = PARTICIPANT_REPORT_COLUMNS
        headers = (
            ["N", "Action", "Échéance", "Statut", "Date de fin"]
            if self.lang == "fr"
            else ["N", "Action", "Due Date", "Status", "Completed Date"]
        )
        values = [
            [
                str(decision.number),
                decision.description,
                decision.dueDate.strftime("%Y-%m-%d") if decision.dueDate else " ",
                decision_status_as_string(decision.status, self.lang),
                (
                    decision.completedDate.strftime("%Y-%m-%d")
                    if decision.completedDate
                    else " "
                ),
            ]
            for decision in self.decisions
        ]
        headers, values, cols = select_report_columns(
            ["number", "description", "dueDate", "status", "completedDate"],
            headers,
            values,
            cols,
            self.selected_columns,
            {"description"},
        )
        if headers:
            builder.table_header(headers, cols)
            builder.table_content(values, cols)

        builder.build()
        buffer.seek(0)
        return buffer
