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

        return Email(
            subject=subject,
            recipient=email,
            sender=os.getenv('MAIL_USER'),
            body=body
        )

    @staticmethod
    def create_participants_report_email(recipient: str, report_bytes: bytes, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = "Participants Report - QuiFaitQuoiQuand"
            body = (
                "Hello,\n"
                "Please find attached the report containing the tasks assigned to each participant.\n\n"
                "Thank you,\n"
                "The QuiFaitQuoiQuand Team"
            )
            filename = "participants_report.pdf"
        else:
            subject = "Rapport des participants - QuiFaitQuoiQuand"
            body = (
                "Bonjour,\n"
                "Veuillez trouver en pièce jointe le rapport contenant les tâches assignées à chaque participant.\n\n"
                "Merci,\n"
                "L'équipe QuiFaitQuoiQuand"
            )
            filename = "rapport_participants.pdf"

        return Email(
            subject=subject,
            recipient=recipient,
            sender=os.getenv('MAIL_USER'),
            body=body,
            attachments={filename: report_bytes}
        )

    @staticmethod
    def create_project_report_email(recipient: str, report_bytes: bytes, project_name: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = f"Project Report: {project_name} - QuiFaitQuoiQuand"
            body = (
                "Hello,\n"
                f"Please find attached the detailed report for the project '{project_name}'.\n\n"
                "Thank you,\n"
                "The QuiFaitQuoiQuand Team"
            )
            filename = "project_report.pdf"
        else:
            subject = f"Rapport de projet : {project_name} - QuiFaitQuoiQuand"
            body = (
                "Bonjour,\n"
                f"Veuillez trouver en pièce jointe le rapport détaillé pour le projet '{project_name}'.\n\n"
                "Merci,\n"
                "L'équipe QuiFaitQuoiQuand"
            )
            filename = "rapport_projet.pdf"

        return Email(
            subject=subject,
            recipient=recipient,
            sender=os.getenv('MAIL_USER'),
            body=body,
            attachments={filename: report_bytes}
        )

    @staticmethod
    def create_meeting_report_email(recipient: str, report_bytes: bytes, meeting_title: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = f"Meeting Report: {meeting_title} - QuiFaitQuoiQuand"
            body = (
                "Hello,\n"
                f"Please find attached the report and agenda for the meeting '{meeting_title}'.\n\n"
                "Thank you,\n"
                "The QuiFaitQuoiQuand Team"
            )
            filename = "meeting_report.pdf"
        else:
            subject = f"Rapport de réunion : {meeting_title} - QuiFaitQuoiQuand"
            body = (
                "Bonjour,\n"
                f"Veuillez trouver en pièce jointe le rapport et l'ordre du jour de la réunion '{meeting_title}'.\n\n"
                "Merci,\n"
                "L'équipe QuiFaitQuoiQuand"
            )
            filename = "rapport_reunion.pdf"

        return Email(
            subject=subject,
            recipient=recipient,
            sender=os.getenv('MAIL_USER'),
            body=body,
            attachments={filename: report_bytes}
        )

    @staticmethod
    def create_organization_invitation_email(recipient: str, org_id: int, org_name: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = f"Invitation to join '{org_name}' - QuiFaitQuoiQuand"
            body = (
                "Hello,\n"
                f"You have been invited to join the organization '{org_name}'.\n"
                f"The organization ID is: {org_id}\n\n"
                "Thank you,\n"
                "The QuiFaitQuoiQuand Team"
            )
        else:
            subject = f"Invitation à rejoindre '{org_name}' - QuiFaitQuoiQuand"
            body = (
                "Bonjour,\n"
                f"Vous avez été invité(e) à rejoindre l'organisation '{org_name}'.\n"
                f"L'ID de l'organisation est : {org_id}\n\n"
                "Merci,\n"
                "L'équipe QuiFaitQuoiQuand"
            )

        return Email(
            subject=subject,
            recipient=recipient,
            sender=os.getenv('MAIL_USER'),
            body=body
        )
