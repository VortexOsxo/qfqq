import random
import string
from werkzeug.security import generate_password_hash

from flaskr.services.emails import *
from flaskr.database.postgres import PasswordRequestDataHandler, UserDataHandler
from flaskr.utils.time import time_now_to_string, string_to_time
from datetime import datetime, timedelta

class ResetPasswordService:
    @staticmethod
    def reset_password(email: str) -> bool:
        letters_and_digits = string.ascii_letters + string.digits
        code = "".join([random.choice(letters_and_digits) for _ in range(6)])

        lost_password_email = EmailDrafter.create_reset_password_email(email, code)
        result = EmailSender.send_email(lost_password_email)
        if not result:
            return False

        PasswordRequestDataHandler.create_request(email, code, time_now_to_string())
        return True

    @staticmethod
    def is_code_valid(email: str, code: str):
        date = string_to_time(PasswordRequestDataHandler.get_date(email, code))
        if date is None: return False

        timespan = datetime.now() - date
        duration = timedelta(minutes=15)
        return timespan < duration
    
    @staticmethod
    def update_password(email: str, newPassword):
        UserDataHandler.update_user_password(email, generate_password_hash(newPassword))


