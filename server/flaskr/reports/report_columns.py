def calculate_column_widths(widths: list[float | None]) -> list[str]:
    fixed_widths = [width for width in widths if width is not None]
    flexible_count = len(widths) - len(fixed_widths)
    flexible_width = (
        (100 - sum(fixed_widths)) / flexible_count if flexible_count else 0
    )
    return [
        f"{flexible_width if width is None else width:g}%"
        for width in widths
    ]


NUMBER_PERCENT = 5
DATE_PERCENT = 12
STATUS_PERCENT = 12


PARTICIPANT_REPORT_COLUMNS = calculate_column_widths([NUMBER_PERCENT, None, DATE_PERCENT, STATUS_PERCENT, DATE_PERCENT])

PARTICIPANTS_REPORT_COLUMNS = PARTICIPANT_REPORT_COLUMNS

MEETING_REPORT_DECISION_COLUMNS = calculate_column_widths([NUMBER_PERCENT, None, 15, DATE_PERCENT, STATUS_PERCENT, DATE_PERCENT])

PROJECT_REPORT_DECISION_COLUMNS = calculate_column_widths([NUMBER_PERCENT, NUMBER_PERCENT, None, 15, DATE_PERCENT, STATUS_PERCENT, DATE_PERCENT])

MEETING_REVIEW_COLUMNS = calculate_column_widths([None, 14, 14, 14, 14, 14])
