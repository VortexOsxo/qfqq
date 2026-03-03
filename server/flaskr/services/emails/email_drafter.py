import os

from flaskr.models.email import Email


class EmailDrafter:
    @staticmethod
    def create_reset_password_email(email: str, reset_code: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = "Password Reset - QuiFaitQuoiQuand"
            body = (
                "Hello,\n"
                "A request to reset your password has been made for your account.\n"
                "If you did not initiate this request, you can safely ignore this message.\n"
                "Otherwise, use the code below to reset your password:\n\n"
                f"{reset_code}\n\n"
                "Thank you,\n"
                "The QuiFaitQuoiQuand Team"
            )
        else:
            subject = "Réinitialisation de votre mot de passe - QuiFaitQuoiQuand"
            body = (
                "Bonjour,\n"
                "Une demande de réinitialisation de votre mot de passe a été effectuée pour votre compte.\n"
                "Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer ce message en toute sécurité.\n"
                "Sinon, utilisez le code ci-dessous pour réinitialiser votre mot de passe :\n\n"
                f"{reset_code}\n\n"
                "Merci,\n"
                "L'équipe QuiFaitQuoiQuand"
            )

        email = Email(
            subject=subject,
            recipient=email,
            sender=os.getenv('MAIL_USER'),
            body=body
        )

        return email
