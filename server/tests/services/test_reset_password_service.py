from flaskr.services.reset_password_service import ResetPasswordService

def test_reset_password_create_and_send_email(monkeypatch):
    from flaskr.services.emails import EmailSender, EmailDrafter

    def fake_send(_):
        return True

    
    def fake_draft(email, _):
        assert email == "bob@example.com"

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(EmailDrafter, "create_reset_password_email", fake_draft)

    ResetPasswordService.reset_password('bob@example.com')

def test_reset_password_create_different_codes(monkeypatch):
    from flaskr.services.emails import EmailSender, EmailDrafter

    def fake_send(_):
        return True

    codes = set()
    def fake_draft(_, code):
        codes.add(code)

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(EmailDrafter, "create_reset_password_email", fake_draft)

    ResetPasswordService.reset_password('bob@example.com')
    ResetPasswordService.reset_password('bob@example.com')
    ResetPasswordService.reset_password('bob@example.com')

    assert len(codes) == 3

def test_reset_password_create_valid_code_for_proper_email(monkeypatch):
    from flaskr.services.emails import EmailSender, EmailDrafter

    def fake_send(_):
        return True

    codes = []
    def fake_draft(_, code):
        codes.append(code)

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(EmailDrafter, "create_reset_password_email", fake_draft)

    ResetPasswordService.reset_password('bob@example.com')
    
    assert len(codes) == 1

    assert ResetPasswordService.is_code_valid('bob@example.com', codes[0])
    assert not ResetPasswordService.is_code_valid('wrong@email.com', codes[0])

def test_reset_password_should_not_work_for_unknown_email(monkeypatch):
    from flaskr.services.emails import EmailSender, EmailDrafter

    def fake_send(_):
        return True

    codes = []
    def fake_draft(_, code):
        codes.append(code)

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(EmailDrafter, "create_reset_password_email", fake_draft)

    ResetPasswordService.reset_password('test@example.com')
    
    assert len(codes) == 1
    assert not ResetPasswordService.is_code_valid('test@example.com', codes[0])

def test_reset_password_random_code_should_not_work():
    assert not ResetPasswordService.is_code_valid('carol@example.com', '123456')

def test_reset_password_old_code_should_become_invalid(monkeypatch):
    from flaskr.services.emails import EmailSender, EmailDrafter

    def fake_send(_):
        return True

    codes = []
    def fake_draft(_, code):
        codes.append(code)

    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(EmailDrafter, "create_reset_password_email", fake_draft)

    ResetPasswordService.reset_password('bob@example.com')
    ResetPasswordService.reset_password('bob@example.com')
    
    assert len(codes) == 2

    assert ResetPasswordService.is_code_valid('bob@example.com', codes[1])
    assert not ResetPasswordService.is_code_valid('bob@example.com', codes[0])

def test_reset_password_should_invalidate_code_after_15_mins(monkeypatch):
    import datetime
    import flaskr.utils.time as time
    real_now = datetime.datetime.now()
    fake_now = real_now - datetime.timedelta(minutes=16)

    class FakeDateTime:
        @classmethod
        def now(cls):
            return fake_now

    def fake_send(_):
        return True

    codes = []
    def fake_draft(_, code):
        codes.append(code)

    from flaskr.services.emails import EmailSender, EmailDrafter
    monkeypatch.setattr(EmailSender, "send_email", fake_send)
    monkeypatch.setattr(EmailDrafter, "create_reset_password_email", fake_draft)
    
    monkeypatch.setattr(time, "datetime", FakeDateTime)

    ResetPasswordService.reset_password('bob@example.com')

    assert not ResetPasswordService.is_code_valid('bob@example.com', codes[0])