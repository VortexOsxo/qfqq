from .report_builder import ReportBuilder
from flaskr.models import Decision
from io import BytesIO
from .report_columns import PARTICIPANTS_REPORT_COLUMNS, get_column_id_from_name, ReportLineManager


class ParticipantsReportBuilder:

    def __init__(
        self,
        decisions: list[tuple[Decision, str]],
        lang: str = "fr",
        selected_columns: set[str] | None = None,
    ):
        self.decisions_by_participant = {}
        # TODO: Handle name collision
        for decision in decisions:
            if decision.responsibleName not in self.decisions_by_participant:
                self.decisions_by_participant[decision.responsibleName] = [] 
            self.decisions_by_participant[decision.responsibleName].append(decision)

        self.lang = lang
        self.selected_columns = selected_columns

    def build(self):
        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header("Activités par participant" if self.lang == "fr" else "Participant tasks")

        builder.division()

        columns_id = PARTICIPANTS_REPORT_COLUMNS
        if self.selected_columns is not None:
            columns_id = columns_id & {
                get_column_id_from_name(name) for name in self.selected_columns
            }

        _, headers, widths = ReportLineManager.process([], columns_id, self.lang)
        if headers:
            builder.table_header(headers, widths)
            for participant, decisions in self.decisions_by_participant.items():
                values, _, _ = ReportLineManager.process(
                    decisions, columns_id, self.lang
                )
                builder.table_section(participant)
                builder.table_content(values, widths)

        builder.build()
        buffer.seek(0)
        return buffer
