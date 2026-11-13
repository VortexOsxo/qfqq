from .report_builder import ReportBuilder
from .report_columns import PARTICIPANT_REPORT_COLUMNS as columns
from flaskr.models import Decision
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

        builder.decisions_table(self.decisions, self.lang, columns, self.selected_columns)

        builder.build()
        buffer.seek(0)
        return buffer
