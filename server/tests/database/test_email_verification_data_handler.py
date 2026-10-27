from flaskr.database import EmailValidationDataHandler


def test_create_request_success(app):
    email = "alice@example.com"
    code = "123456"

    success = EmailValidationDataHandler.create_request(email, code)
    assert success

    result = EmailValidationDataHandler.validate_request(email, code)
    assert result


def test_validate_request_right_code(app):
    email = "alice@example.com"
    code = "123456"

    EmailValidationDataHandler.create_request(email, code)
    assert EmailValidationDataHandler.validate_request(email, "123456")


def test_create_request_overwrites_existing(app):
    email = "alice@example.com"
    old_code = "111111"
    new_code = "222222"

    assert EmailValidationDataHandler.create_request(email, old_code)
    assert EmailValidationDataHandler.create_request(email, new_code)

    assert not EmailValidationDataHandler.validate_request(email, old_code)
    assert EmailValidationDataHandler.validate_request(email, new_code)


def test_create_request_new_user(app):
    email = "nonexistent@example.com"
    code = "123456"

    success = EmailValidationDataHandler.create_request(email, code)
    assert success

    assert EmailValidationDataHandler.validate_request(email, code)


def test_delete_request(app):
    email = "alice@example.com"
    code = "123456"

    EmailValidationDataHandler.create_request(email, code)
    assert EmailValidationDataHandler.validate_request(email, code)

    EmailValidationDataHandler.delete_request(email)
    
    assert not EmailValidationDataHandler.validate_request(email, code)


def test_validate_request_wrong_code(app):
    email = "alice@example.com"
    code = "123456"

    EmailValidationDataHandler.create_request(email, code)
    assert not EmailValidationDataHandler.validate_request(email, "wrong_code")


def test_validate_request_when_no_request_exists(app):
    assert not EmailValidationDataHandler.validate_request("bob@example.com", "123456")


def test_validate_request_wrong_email_for_code(app):
    EmailValidationDataHandler.create_request("alice@example.com", "123456")

    assert not EmailValidationDataHandler.validate_request("bob@example.com", "123456")