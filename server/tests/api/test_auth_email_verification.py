import json

from flaskr.services.emails import EmailSender

from tests.api.utils import get_auth_headers, get_default_headers


def test_cant_request_email_verification_code_if_not_logged_in(client):
    response = client.post("/auth/email-verification/request-code", json={}, headers=get_default_headers())

    assert response.status_code == 401
    assert json.loads(response.text) == {"auth": 1003}


def test_cant_validate_email_verification_code_if_not_logged_in(client):
    response = client.post("/auth/email-verification/validate-code", json={'code': '123456'}, headers=get_default_headers())

    assert response.status_code == 401
    assert json.loads(response.text) == {"auth": 1003}



def test_request_email_verification(monkeypatch, client):
    captured = {}

    def fake_send(email):
        captured["recipient"] = email.recipient
        captured["subject"] = email.subject
        return True

    monkeypatch.setattr(EmailSender, "send_email", fake_send)

    response = client.post(
        "/auth/email-verification/request-code",
        json={},
        headers=get_auth_headers(client)
    )

    assert response.status_code == 204
    assert captured["recipient"] == "alice@example.com"

def test_validate_email_verification_code_success(monkeypatch, client):
    from flaskr.services.account_service import AccountService

    def fake_send(email):
        return True

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(AccountService, "_generate_code", lambda: "ABC123")

    request_response = client.post(
        "/auth/email-verification/request-code",
        json={},
        headers=get_auth_headers(client)
    )
    assert request_response.status_code == 204

    validate_response = client.post(
        "/auth/email-verification/validate-code",
        json={"code": "ABC123"},
        headers=get_auth_headers(client)
    )

    assert validate_response.status_code == 204


def test_validate_email_verification_code_fails_with_wrong_code(monkeypatch, client):
    from flaskr.services.account_service import AccountService

    def fake_send(email):
        return True

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(AccountService, "_generate_code", lambda: "ABC123")

    request_response = client.post(
        "/auth/email-verification/request-code",
        json={},
        headers=get_auth_headers(client)
    )
    assert request_response.status_code == 204

    validate_response = client.post(
        "/auth/email-verification/validate-code",
        json={"code": "WRONG1"},
        headers=get_auth_headers(client)
    )

    assert validate_response.status_code == 400
    assert json.loads(validate_response.text) == {"error": -1}


def test_validate_email_verification_code_fails_when_expired(monkeypatch, client):
    import datetime
    import flaskr.utils.time as time_module
    from flaskr.services.account_service import AccountService

    def fake_send(email):
        return True

    current_time = datetime.datetime.now()

    class FakeDateTime:
        @classmethod
        def now(cls):
            return current_time

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(AccountService, "_generate_code", lambda: "ABC123")
    monkeypatch.setattr(time_module, "datetime", FakeDateTime)

    request_response = client.post(
        "/auth/email-verification/request-code",
        json={},
        headers=get_auth_headers(client)
    )
    assert request_response.status_code == 204

    current_time += datetime.timedelta(minutes=16)

    validate_response = client.post(
        "/auth/email-verification/validate-code",
        json={"code": "ABC123"},
        headers=get_auth_headers(client)
    )

    assert validate_response.status_code == 400
    assert json.loads(validate_response.text) == {"error": -1}

