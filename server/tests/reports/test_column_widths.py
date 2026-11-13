from types import SimpleNamespace

import pytest

from flaskr.reports.report_columns import (
    ReportLineManager,
    get_column_id_from_name,
)


def test_column_widths_allocate_remaining_space_to_flexible_column():
    assert ReportLineManager.get_column_widths([5, None, 12, 20, 12]) == [
        "5%",
        "51%",
        "12%",
        "20%",
        "12%",
    ]


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
    assert widths == ["12%"]


def test_unknown_column_name_defaults_to_number_column():
    assert get_column_id_from_name("unknown") == 1
