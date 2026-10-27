import json

from flaskr.services.emails import EmailSender

from tests.api.utils import get_default_headers


def test_request_email_verification(monkeypatch, client):
    captured = {}

    def fake_send(email):
        captured["recipient"] = email.recipient
        captured["subject"] = email.subject
        return True

    monkeypatch.setattr(EmailSender, "send_email", fake_send)

    response = client.post(
        "/auth/email-verification/request-code",
        json={"email": "alice@example.com"},
        headers=get_default_headers()
    )

    assert response.status_code == 200
    assert response.get_json() == {"bypass": False}
    assert captured["recipient"] == "alice@example.com"

def test_validate_email_verification_code_success(monkeypatch, client):
    from flaskr.services.account_service import AccountService

    def fake_send(email):
        return True

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(AccountService, "_generate_code", lambda: "ABC123")

    request_response = client.post(
        "/auth/email-verification/request-code",
        json={"email": "alice@example.com"},
        headers=get_default_headers()
    )
    assert request_response.status_code == 200

    validate_response = client.post(
        "/auth/email-verification/validate-code",
        json={"email": "alice@example.com", "code": "ABC123"},
        headers=get_default_headers()
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
        json={"email": "alice@example.com"},
        headers=get_default_headers()
    )
    assert request_response.status_code == 200

    validate_response = client.post(
        "/auth/email-verification/validate-code",
        json={"email": "alice@example.com", "code": "WRONG1"},
        headers=get_default_headers()
    )

    assert validate_response.status_code == 400
    assert json.loads(validate_response.text) == {"error": -1}
