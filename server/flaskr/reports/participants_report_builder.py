from .report_builder import ReportBuilder
from .report_columns import PARTICIPANTS_REPORT_COLUMNS, select_report_columns
from flaskr.models import Decision, decision_status_as_string
from io import BytesIO


class ParticipantsReportBuilder:

    def __init__(
        self,
        decisions: list[tuple[Decision, str]],
        lang: str = "fr",
        selected_columns: set[str] | None = None,
    ):
        self.decisions_by_participant = {}
        # TODO: Handle name collision
        for decision, responsible_name in decisions:
            if responsible_name not in self.decisions_by_participant:
                self.decisions_by_participant[responsible_name] = [] 
            self.decisions_by_participant[responsible_name].append(decision)

        self.lang = lang
        self.selected_columns = selected_columns

    def build(self):
        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header("Activités par participant" if self.lang == "fr" else "Participant tasks")

        builder.division()

        cols = PARTICIPANTS_REPORT_COLUMNS
        headers = (
            ["Numéro de décision", "Action", "Échéance", "Statut", "Date de fin"]
            if self.lang == "fr"
            else ["N", "Action", "Due Date", "Status", "Completed Date"]
        )
        participants_values = []
        for participant, decisions in self.decisions_by_participant.items():
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
                for decision in decisions
            ]
            participants_values.append((participant, values))

        all_values = [
            row for _, participant_rows in participants_values for row in participant_rows
        ]
        headers, all_values, cols = select_report_columns(
            ["number", "description", "dueDate", "status", "completedDate"],
            headers,
            all_values,
            cols,
            self.selected_columns,
            {"description"},
        )
        if headers:
            builder.table_header(headers, cols)
            offset = 0
            for participant, participant_rows in participants_values:
                builder.table_section(participant)
                selected_rows = all_values[offset : offset + len(participant_rows)]
                builder.table_content(selected_rows, cols)
                offset += len(participant_rows)

        builder.build()
        buffer.seek(0)
        return buffer
