import random
import string
from werkzeug.security import generate_password_hash

from flaskr.services.emails import *
from flaskr.database import PasswordRequestDataHandler, EmailValidationDataHandler, UserDataHandler
from flaskr.utils.time import time_now_to_string, string_to_time
from datetime import datetime, timedelta

class AccountService:
    @staticmethod
    def reset_password(email: str, lang: str = 'fr') -> bool:
        code = AccountService._generate_code()

        lost_password_email = EmailDrafter.create_reset_password_email(email, code, lang)
        EmailSender.send_email(lost_password_email)

        return PasswordRequestDataHandler.create_request(email, code, time_now_to_string())

    @staticmethod
    def is_password_code_valid(email: str, code: str):
        date = string_to_time(PasswordRequestDataHandler.get_date(email, code))
        if date is None: return False

        timespan = datetime.now() - date
        duration = timedelta(minutes=15)
        return timespan < duration

    @staticmethod
    def verify_email(email: str, lang: str = 'fr') -> bool:
        code = AccountService._generate_code()

        verify_email_email = EmailDrafter.create_verify_email_email(email, code, lang)
        EmailSender.send_email(verify_email_email)

        return EmailValidationDataHandler.create_request(email, code, time_now_to_string())

    @staticmethod
    def is_email_code_valid(email: str, code: str):
        date = string_to_time(EmailValidationDataHandler.get_date(email, code))
        if date is None: return False

        timespan = datetime.now() - date
        duration = timedelta(minutes=15)
        return timespan < duration

    
    @staticmethod
    def update_password(email: str, newPassword):
        UserDataHandler.update_user_password(email, generate_password_hash(newPassword))

    @staticmethod
    def mark_email_as_verified(email: str):
        UserDataHandler.mark_email_as_verified(email)

    @staticmethod
    def _generate_code():
        letters_and_digits = string.ascii_letters + string.digits
        return "".join([random.choice(letters_and_digits) for _ in range(6)])
