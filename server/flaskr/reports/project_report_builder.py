from .report_builder import ReportBuilder
from flaskr.models import Decision, Project
from .report_columns import PROJECT_REPORT_DECISION_COLUMNS as columns
from io import BytesIO


class ProjectReportBuilder:
    def __init__(
        self,
        project: Project,
        decisions: list[tuple[Decision, str]],
        selected_columns: set[int],
        lang: str = "fr",
    ):
        self.project = project
        self.decisions = decisions
        self.lang = lang
        self.selected_columns = selected_columns

    def build(self):
        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header(
            "Projet" if self.lang == "fr" else "Project",
            self.project.title,
        )
        builder.division()
        builder.spacer(10)

        builder.decisions_table(self.decisions, self.lang, columns, self.selected_columns)

        builder.build()
        buffer.seek(0)
        return buffer
