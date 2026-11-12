from .report_builder import ReportBuilder
from flaskr.models import Decision, Project
from io import BytesIO


class ProjectReportBuilder:
    def __init__(
        self,
        project: Project,
        decisions: list[tuple[Decision, str]],
        lang: str = "fr",
        selected_columns: set[str] | None = None,
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

        builder.decisions_table_with_meeting_id(
            self.decisions, self.lang, self.selected_columns
        )

        builder.build()
        buffer.seek(0)
        return buffer
