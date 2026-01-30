from .report_builder import ReportBuilder
from flaskr.models import Decision, Project
from io import BytesIO

class ProjectReportBuilder:
    def __init__(self, project: Project, decisions: list[Decision]):
        self.project = project
        self.decisions = decisions

    def build(self):
        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header('Projet', self.project.title,)
        builder.division()
        builder.spacer(10)

        cols = ['5%','15%', '30%', '15%', '20%', '15%']
        builder.table_header([
            'N', 'Decision', 'Responsable', 'Date due', 'Statut', 'Date de fin'
        ], cols)

        values = [
            [str(decision.number), decision.description, decision.responsibleId, ' ', decision.status, ' '] for decision in self.decisions
        ]
        builder.table_content(values, cols)

        builder.build()
        buffer.seek(0)
        return buffer