from .report_builder import ReportBuilder
from flaskr.models import Decision, MeetingAgenda, User
from io import BytesIO

def format_meeting_date(date, lang='en'):
    months_en = ['January', 'February', 'March', 'April', 'May', 'June',
                 'July', 'August', 'September', 'October', 'November', 'December']
    months_fr = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
                 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre']
    
    months = months_fr if lang == 'fr' else months_en
    month_name = months[date.month - 1]

    time_str = date.strftime('%H:%M')
    
    if lang == 'fr':
        return f"{date.day} {month_name} {date.year} à {time_str}"
    else:
        return f"{month_name} {date.day}, {date.year} at {time_str}"

class MeetingReportBuilder:

    def __init__(
        self,
        meeting: MeetingAgenda,
        author: User,
        participants: list[str],
        decisions: list[tuple[Decision, str]],
        nextMeeting: MeetingAgenda | None,
        lang: str = "fr",
    ):
        self.meeting = meeting
        self.author = author
        self.participants = participants
        self.decisions = decisions
        self.nextMeeting = nextMeeting
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

        col2 = builder.text_row('Compte rendu fait par' if self.lang == 'fr' else 'Meeting minutes done by', [self.author.firstName + ' ' + self.author.lastName])
        builder.add_element(col2)
        
        if self.nextMeeting is not None:
            date = self.nextMeeting.meetingDate
            label = 'Date et heure de la prochaine réunion' if self.lang == 'fr' else 'Next meeting date and time'
    
            col3 = builder.text_row(label, [format_meeting_date(date)])
            builder.add_element(col3)

        builder.division()
        builder.spacer(10)

        builder.decisions_table(self.decisions, self.lang)

        builder.build()
        buffer.seek(0)
        return buffer
