from flaskr.database import EmailValidationDataHandler


def test_create_request_success(app):
    email = "alice@example.com"
    code = "123456"
    date_str = "2026-09-12 12:00:00"

    success = EmailValidationDataHandler.create_request(email, code, date_str)
    assert success is True

    stored_date = EmailValidationDataHandler.get_date(email, code)
    assert stored_date == date_str


def test_create_request_overwrites_existing(app):
    email = "alice@example.com"
    old_code = "111111"
    old_date = "2026-09-12 10:00:00"
    new_code = "222222"
    new_date = "2026-09-12 11:00:00"

    assert EmailValidationDataHandler.create_request(email, old_code, old_date) is True
    assert EmailValidationDataHandler.create_request(email, new_code, new_date) is True

    assert EmailValidationDataHandler.get_date(email, old_code) is None
    assert EmailValidationDataHandler.get_date(email, new_code) == new_date


def test_create_request_nonexistent_user(app):
    email = "nonexistent@example.com"
    code = "123456"
    date_str = "2026-09-12 12:00:00"

    success = EmailValidationDataHandler.create_request(email, code, date_str)
    assert success is False

    assert EmailValidationDataHandler.get_date(email, code) is None


def test_get_date_wrong_code(app):
    email = "alice@example.com"
    code = "123456"
    date_str = "2026-09-12 12:00:00"

    EmailValidationDataHandler.create_request(email, code, date_str)
    assert EmailValidationDataHandler.get_date(email, "wrong_code") is None


def test_get_date_when_no_request_exists(app):
    assert EmailValidationDataHandler.get_date("bob@example.com", "123456") is None


def test_get_date_wrong_email_for_code(app):
    EmailValidationDataHandler.create_request("alice@example.com", "123456", "2026-09-12 12:00:00")

    assert EmailValidationDataHandler.get_date("bob@example.com", "123456") is None
