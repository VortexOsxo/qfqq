from .report_builder import ReportBuilder
from flaskr.models import Decision, DecisionStatus
from io import BytesIO


class ParticipantsReportBuilder:

    def __init__(self, decisions: list[tuple[Decision, str]], lang: str = "fr"):
        self.decisions_by_participant = {}
        # TODO: Handle name collision
        for decision, responsible_name in decisions:
            if responsible_name not in self.decisions_by_participant:
                self.decisions_by_participant[responsible_name] = [] 
            self.decisions_by_participant[responsible_name].append(decision)

        self.lang = lang

    def build(self):
        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header("Activités par participant" if self.lang == "fr" else "Participant tasks")

        builder.division()

        cols = ["5%", "45%", "15%", "20%", "15%"]
        headers = (
            ["N", "Action", "Échéance", "Statut", "Date de fin"]
            if self.lang == "fr"
            else ["N", "Action", "Due Date", "Status", "Completed Date"]
        )
        builder.table_header(headers, cols)

        for participant, decisions in self.decisions_by_participant.items():
            builder.table_section(participant)

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
                for decision in decisions
            ]
            builder.table_content(values, cols)

        builder.build()
        buffer.seek(0)
        return buffer
