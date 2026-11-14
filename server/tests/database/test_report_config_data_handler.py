from flaskr.database.handlers.report_config_data_handler import ReportConfigDataHandler
from flaskr.models import ReportConfig


def test_create_report_config(app):
    columns = {1, 3}
    filters = {"status": "completed", "responsibleId": 3}

    config = ReportConfigDataHandler.create_report_config(
        "Booby's finished tasks", columns, filters, showReviews=True
    )

    assert isinstance(config, ReportConfig)
    assert config.name == "Booby's finished tasks"
    assert config.columns == columns
    assert config.filters == filters
    assert config.showReviews


def test_create_report_config_defaults_show_reviews_to_false(app):
    config = ReportConfigDataHandler.create_report_config("Basic", {2}, {})
    assert config.showReviews is False


def test_get_report_configs(app):
    quarterly = ReportConfigDataHandler.create_report_config(
        "Quarterly",
        {1, 4},
        {"status": "inProgress"},
        showReviews=True,
    )
    basic = ReportConfigDataHandler.create_report_config("Basic", set(), {})

    configs = ReportConfigDataHandler.get_report_configs()
    configs_by_id = {config.id: config for config in configs}

    assert configs_by_id[quarterly.id] == quarterly
    assert configs_by_id[basic.id] == basic
