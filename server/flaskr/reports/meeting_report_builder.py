from .report_builder import ReportBuilder
from flaskr.models import Decision, MeetingAgenda
from io import BytesIO


class MeetingReportBuilder:
    def __init__(
        self, meeting: MeetingAgenda, participants: list[str], decisions: list[tuple[Decision, str]], lang: str = "fr"
    ):
        self.meeting = meeting
        self.participants = participants
        self.decisions = decisions
        self.lang = lang

    def build(self):
        buffer = BytesIO()

        builder = ReportBuilder().start(buffer)
        builder.header(
            "Compte rendu de réunion" if self.lang == "fr" else "Meeting minutes",
            f"{'Réunion' if self.lang == 'fr' else 'Meeting'}: {self.meeting.number}",
        )
        builder.division()

        col1 = builder.text_row('Participants', self.participants)
        builder.add_element(col1)

        builder.division()
        builder.spacer(10)

        builder.decisions_table(self.decisions, self.lang)

        builder.build()
        buffer.seek(0)
        return buffer
