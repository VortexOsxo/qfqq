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


def select_report_columns(
    column_keys: list[str],
    headers: list[str],
    rows: list[list[str]],
    widths: list[str],
    selected_columns: set[str] | None,
    flexible_column_keys: set[str] | None = None,
) -> tuple[list[str], list[list[str]], list[str]]:
    if selected_columns is None:
        return headers, rows, widths

    indices = [
        index for index, key in enumerate(column_keys) if key in selected_columns
    ]
    if not indices:
        return [], [], []

    flexible_column_keys = flexible_column_keys or set()
    fixed_widths = {
        index: float(widths[index].removesuffix("%"))
        for index in indices
        if column_keys[index] not in flexible_column_keys
    }
    flexible_indices = [
        index
        for index in indices
        if column_keys[index] in flexible_column_keys
    ]
    flexible_width = (
        (100 - sum(fixed_widths.values())) / len(flexible_indices)
        if flexible_indices
        else 0
    )
    selected_widths = [
        f"{fixed_widths[index] if index in fixed_widths else flexible_width:g}%"
        for index in indices
    ]
    return (
        [headers[index] for index in indices],
        [[row[index] for index in indices] for row in rows],
        selected_widths,
    )
