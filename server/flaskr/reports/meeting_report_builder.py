from .report_builder import ReportBuilder
from .report_columns import MEETING_REVIEW_COLUMNS
from flaskr.models import Decision, MeetingAgenda, MeetingReview, User
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
        reviews: list[MeetingReview] | None = None,
    ):
        self.meeting = meeting
        self.author = author
        self.participants = participants
        self.decisions = decisions
        self.nextMeeting = nextMeeting
        self.lang = lang
        self.reviews = reviews or []

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

        if self.reviews:
            builder.spacer(10)
            builder.table_header(
                ["Retours de réunion" if self.lang == "fr" else "Meeting reviews"],
                ["100%"],
            )
            headers = (
                ["Commentaire", "Objectif", "Déroulement", "Préparation", "Durée", "Respect"]
                if self.lang == "fr"
                else ["Comment", "Objective", "Smooth running", "Preparation", "Length", "Respect"]
            )
            col_widths = MEETING_REVIEW_COLUMNS
            builder.table_header(headers, col_widths)
            for review in self.reviews:
                comments = (review.comments or "").replace("\r\n", "\n")
                comments = comments.replace("\n", "<br/>")
                builder.table_content(
                    [[
                        comments,
                        f"{review.objective}/5",
                        f"{review.smoothRunning}/5",
                        f"{review.preparation}/5",
                        f"{review.length}/5",
                        f"{review.respect}/5",
                    ]],
                    col_widths,
                )

        builder.build()
        buffer.seek(0)
        return buffer
