from types import SimpleNamespace

import pytest

from flaskr.reports.report_columns import ReportLineManager


def test_column_widths_allocate_remaining_space_to_flexible_column():
    assert ReportLineManager.get_column_widths([5, None, 12, 20, 12]) == [
        "5%",
        "51%",
        "12%",
        "20%",
        "12%",
    ]


def test_column_widths_scale_fixed_columns_to_fill_table():
    widths = ReportLineManager.get_column_widths([5, 15, 12, 12, 12])

    assert sum(float(width[:-1]) for width in widths) == pytest.approx(100)


@pytest.mark.parametrize(
    ("lang", "expected_title", "expected_value"),
    [
        ("fr", "Statut", "Terminé"),
        ("en", "Status", "Completed"),
    ],
)
def test_process_uses_language_for_status_value(lang, expected_title, expected_value):
    values, headers, widths = ReportLineManager.process(
        [SimpleNamespace(status="completed")], {6}, lang
    )

    assert values == [[expected_value]]
    assert headers == [expected_title]
    assert widths == ["100%"]
