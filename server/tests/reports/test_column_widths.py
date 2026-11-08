import pytest

from flaskr.reports.report_columns import (
    MEETING_REPORT_DECISION_COLUMNS,
    MEETING_REVIEW_COLUMNS,
    PARTICIPANT_REPORT_COLUMNS,
    PARTICIPANTS_REPORT_COLUMNS,
    PROJECT_REPORT_DECISION_COLUMNS,
    calculate_column_widths,
)


def test_calculate_column_widths_allocates_remaining_width_to_flexible_column():
    assert calculate_column_widths([5, None, 12, 20, 12]) == [
        "5%",
        "51%",
        "12%",
        "20%",
        "12%",
    ]


def test_calculate_column_widths_splits_remaining_width_between_flexible_columns():
    assert calculate_column_widths([10, None, 20, None]) == [
        "10%",
        "35%",
        "20%",
        "35%",
    ]


def test_calculate_column_widths_converts_all_fixed_widths():
    assert calculate_column_widths([25, 75]) == ["25%", "75%"]


@pytest.mark.parametrize(
    "columns",
    [
        PARTICIPANT_REPORT_COLUMNS,
        PARTICIPANTS_REPORT_COLUMNS,
        MEETING_REPORT_DECISION_COLUMNS,
        PROJECT_REPORT_DECISION_COLUMNS,
        MEETING_REVIEW_COLUMNS,
    ],
)
def test_report_column_widths_total_100_percent(columns):
    total = sum(float(width.removesuffix("%")) for width in columns)
    assert total == pytest.approx(100)


def test_participant_reports_share_the_same_column_widths():
    assert PARTICIPANT_REPORT_COLUMNS is PARTICIPANTS_REPORT_COLUMNS
