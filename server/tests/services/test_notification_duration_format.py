from datetime import timedelta

import pytest

from flaskr.services.notifications.handlers.duration_format import format_duration


@pytest.mark.parametrize(
    ("duration", "locale", "expected"),
    [
        (timedelta(days=1), "en", "1 day"),
        (timedelta(days=2, hours=3), "en", "2 days 3 hours"),
        (timedelta(minutes=15), "en", "15 minutes"),
        (timedelta(seconds=1), "en", "1 second"),
        (timedelta(days=1), "fr", "1 jour"),
        (timedelta(days=2, hours=1), "fr", "2 jours 1 heure"),
        (timedelta(minutes=15), "fr", "15 minutes"),
        (timedelta(0), "fr", "0 seconde"),
    ],
)
def test_format_duration(duration, locale, expected):
    assert format_duration(duration, locale) == expected
