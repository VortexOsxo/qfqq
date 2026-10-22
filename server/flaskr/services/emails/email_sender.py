import base64
import os

from flaskr.models.email import Email

from brevo import Brevo
from brevo.transactional_emails import (
    SendTransacEmailRequestAttachmentItem,
    SendTransacEmailRequestSender,
    SendTransacEmailRequestToItem,
)
from brevo.core.api_error import ApiError

api_key = os.getenv('BREVO_API_KEY')
client = Brevo(api_key=api_key)
print(f"Brevo api key: {api_key}")


class EmailSender:
    @staticmethod
    def send_email(email: Email) -> bool:
        try:
            attachments = [
                SendTransacEmailRequestAttachmentItem(
                    name=filename,
                    content=base64.b64encode(content).decode("ascii"),
                )
                for filename, content in email.attachments.items()
            ]
            result = client.transactional_emails.send_transac_email(
                subject=email.subject,
                html_content=email.body,
                sender=SendTransacEmailRequestSender(
                    name="QuiFaitQuoiQuand",
                    email="noreply@quifaitquoiquand.com",
                ),
                to=[SendTransacEmailRequestToItem(email=email.recipient)],
                attachment=attachments,
            )
            print("Email sent successfully! Message ID:", result.message_id)
            return True
        except ApiError as e:
            print(f"Error sending email: {e.status_code} - {e.body}")
        return False
