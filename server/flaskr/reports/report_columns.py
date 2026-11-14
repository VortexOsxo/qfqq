from dataclasses import dataclass
from collections.abc import Callable

from flaskr.models import decision_status_as_string

@dataclass(frozen=True)
class Column:
    id: int
    titles: tuple[str]
    width: int | None
    get_value: Callable

get_column_definitions = lambda lang: [
    Column(1, ("N", "N"), 5, lambda line: str(line.number)),
    Column(2, ("R", "M"), 5, lambda line: str(line.meetingId)), # Should it be the number ?
    Column(3, ("Action", "Action"), None, lambda line: line.description),
    Column(4, ("Responsable", "Responsible"), 15, lambda line: line.responsibleName),
    Column(5, ("Échéance", "Due Date"), 12, lambda line: (line.dueDate.strftime("%Y-%m-%d") if line.dueDate else " ")),
    Column(6, ("Statut", "Status"), 12, lambda line: decision_status_as_string(line.status, lang)),
    Column(7, ("Date de fin", "Completed Date"), 12, lambda line: (line.completedDate.strftime("%Y-%m-%d") if line.completedDate else " "))
]

def get_column_id_from_name(name):
    ids = {
        "number": 1,
        "meetingId": 2,
        "description": 3,
        "responsible": 4,
        "dueDate": 5,
        "status": 6,
        "completedDate": 7,
    }
    return ids.get(name, 1)


class ReportLineManager:
    @staticmethod
    def process(lines, column_ids, lang):
        columns = [col for col in get_column_definitions(lang) if col.id in column_ids]

        values = ReportLineManager.get_column_values(lines, columns)
        headers = ReportLineManager.get_column_headers(columns, lang)
        widths = ReportLineManager.get_column_widths([col.width for col in columns])
        return values, headers, widths

    @staticmethod
    def get_column_values(lines, columns):
        values = []
        for line in lines:
            line_values = []
            for column in columns:
                line_values.append(column.get_value(line))
            values.append(line_values)
        return values

    @staticmethod
    def get_column_headers(columns, lang):
        lang_index = 0 if lang == "fr" else 1
        return [col.titles[lang_index] for col in columns]

    @staticmethod
    def get_column_widths(widths):
        if not widths:
            return []

        fixed_widths = [width for width in widths if width is not None]
        flexible_count = len(widths) - len(fixed_widths)
        if not flexible_count:
            total_fixed_width = sum(fixed_widths)
            if total_fixed_width:
                widths = [
                    width * 100 / total_fixed_width for width in fixed_widths
                ]
            else:
                widths = [100 / len(fixed_widths)] * len(fixed_widths)
            return [f"{width:g}%" for width in widths]

        flexible_width = (100 - sum(fixed_widths)) / flexible_count
        return [
            f"{flexible_width if width is None else width:g}%"
            for width in widths
        ]


PARTICIPANT_REPORT_COLUMNS = {1, 3, 5, 6, 7}
PARTICIPANTS_REPORT_COLUMNS = PARTICIPANT_REPORT_COLUMNS
MEETING_REPORT_DECISION_COLUMNS = {1, 3, 4, 5, 6, 7}
PROJECT_REPORT_DECISION_COLUMNS = {1, 2, 3, 4, 5, 6, 7}

MEETING_REVIEW_COLUMNS = ReportLineManager.get_column_widths([None, 14, 14, 14, 14, 14])
