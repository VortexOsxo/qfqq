from .report_builder import ReportBuilder
from flaskr.models import Decision, DecisionStatus
from io import BytesIO


class ParticipantReportBuilder:

    def __init__(self, decisions: list[Decision], name: str, lang: str = "fr"):
        self.decisions = decisions
        self.name = name.title()
        self.lang = lang

    def build(self):
        title = f"Activités" if self.lang == "fr" else "Tasks"
        subtitle = f"Pour {self.name}" if self.lang == "fr" else f"For {self.name}"

        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header(title=title, subtitle=subtitle)

        builder.division()

        cols = ["5%", "45%", "15%", "20%", "15%"]
        headers = (
            ["N", "Action", "Échéance", "Statut", "Date de fin"]
            if self.lang == "fr"
            else ["N", "Action", "Due Date", "Status", "Completed Date"]
        )
        builder.table_header(headers, cols)

        values = [
            [
                str(decision.number),
                decision.description,
                decision.dueDate.strftime("%Y-%m-%d") if decision.dueDate else " ",
                DecisionStatus.as_string(decision.status, self.lang),
                (
                    decision.completedDate.strftime("%Y-%m-%d")
                    if decision.completedDate
                    else " "
                ),
            ]
            for decision in self.decisions
        ]
        builder.table_content(values, cols)

        builder.build()
        buffer.seek(0)
        return buffer
