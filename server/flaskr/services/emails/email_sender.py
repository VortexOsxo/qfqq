import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

from flaskr.models.email import Email


class EmailSender:
    @staticmethod
    def send_email(email: Email) -> bool:
        msg = MIMEMultipart()
        msg["From"] = email.sender
        msg["To"] = email.recipient
        msg["Subject"] = email.subject

        body = email.body
        msg.attach(MIMEText(body, "plain"))

        try:
            with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
                server.login(os.getenv('MAIL_USER'), os.getenv('MAIL_PASSWORD'))
                server.sendmail(email.sender, email.recipient, msg.as_string())
            return True
        except Exception as e:
            return False
