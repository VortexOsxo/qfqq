from flaskr.utils.report import *
from werkzeug.datastructures import ImmutableMultiDict


def test_get_report_name_happy_path():
    args = ImmutableMultiDict({"name": "Default Config"})
    assert get_report_name(args=args) == "Default Config"

def test_get_report_name_empty():
    args = ImmutableMultiDict({"name": ""})
    assert get_report_name(args=args) == "unnamed"

def test_get_report_name_none():
    args = ImmutableMultiDict()
    assert get_report_name(args=args) == "unnamed"

def test_get_report_name_max_length():
    args = ImmutableMultiDict({"name": "This is very very very very long name"})
    assert get_report_name(args=args) == "This is very very very very lo"


DEFAULT_COLUMNS = {1, 3, 5, 6, 7}

def test_get_report_column_params_happy_path():
    args = ImmutableMultiDict({"columns": "{1, 2, 3, 5}"})
    assert get_report_column(args=args, default={1}) == {1, 2, 3, 5}

def test_get_report_column_params_none_returns_default():
    args = ImmutableMultiDict({"columns": ""})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

    args = ImmutableMultiDict({"columns": None})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

    args = None
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

def test_get_report_column_params_no_columns_returns_default():
    args = ImmutableMultiDict({"random": "value"})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

def test_get_report_column_params_invalid_columns_returns_default():
    args = ImmutableMultiDict({"columns": "invalid"})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

    args = ImmutableMultiDict({"columns": "{'1', '2', '3', '5'}"})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

def test_get_report_columns_params_no_columns_returns_default():
    args = ImmutableMultiDict({"columns": "{}"})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == DEFAULT_COLUMNS

def test_get_report_columns_params_single_column():
    args = ImmutableMultiDict({"columns": "{3}"})
    assert get_report_column(args=args, default=DEFAULT_COLUMNS) == {3}

def test_get_report_filter_params_happy_path():
    args = ImmutableMultiDict({
        "projectId": "4",
        "responsibleId": "9",
        "status": "completed",
    })
    assert get_report_filter(args) == {
        "projectId": 4,
        "responsibleId": 9,
        "status": "completed",
    }

def test_get_report_filter_params_none_returns_empty():
    assert get_report_filter(None) == {}
    assert get_report_filter(ImmutableMultiDict()) == {}

def test_get_report_filter_params_no_filters_returns_empty():
    args = ImmutableMultiDict({"random": "value"})
    assert get_report_filter(args) == {}

def test_get_report_filter_params_invalid_values_are_ignored():
    args = ImmutableMultiDict({
        "projectId": "invalid",
        "responsibleId": "also-invalid",
        "status": "completed",
    })
    assert get_report_filter(args) == {"status": "completed"}

def test_get_report_filter_params_empty_values_are_ignored():
    args = ImmutableMultiDict({
        "projectId": "0",
        "responsibleId": "0",
        "status": "",
    })
    assert get_report_filter(args) == {}

def test_get_report_filter_params_single_filter():
    args = ImmutableMultiDict({"projectId": "3"})
    assert get_report_filter(args) == {"projectId": 3}

def test_get_report_show_reviews_true():
    args = ImmutableMultiDict({"showComments": "true"})
    assert get_report_show_reviews(args) is True

def test_get_report_show_reviews_case_insensitive():
    args = ImmutableMultiDict({"showComments": "TRUE"})
    assert get_report_show_reviews(args) is True

def test_get_report_show_reviews_defaults_to_false():
    assert get_report_show_reviews(ImmutableMultiDict()) is False

def test_get_report_show_reviews_false():
    args = ImmutableMultiDict({"showComments": "false"})
    assert get_report_show_reviews(args) is False
