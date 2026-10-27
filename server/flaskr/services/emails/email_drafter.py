import os
from html import escape

from flaskr.models.email import Email


class EmailDrafter:
    @staticmethod
    def _format_email_card(content: str) -> str:
        return f"""\
<!DOCTYPE html>
<html>
<body style="margin:0; padding:0; background-color:#f3f5f9; font-family:Arial,Helvetica,sans-serif; color:#333333; font-size:15px; line-height:1.6;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:#f3f5f9; padding:32px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:560px; background-color:#ffffff; border-radius:8px;">
                    <tr>
                        <td style="padding:24px 28px; border-bottom:3px solid #0175C2;">
                            <p style="margin:0; color:#0175C2; font-size:18px; font-weight:bold;">QuiFaitQuoiQuand</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:28px;">
                            {content}
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"""

    @staticmethod
    def create_reset_password_email(email: str, reset_code: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = "Password Reset - QuiFaitQuoiQuand"
            greeting = 'Hello,'
            message = (
                'A request to reset your password has been made for your account.'
            )
            ignore_message = (
                'If you did not initiate this request, you can safely ignore '
                'this message.'
            )
            code_message = 'Otherwise, use the code below to reset your password:'
            sign_off = 'Thank you,<br>The QuiFaitQuoiQuand Team'
        else:
            subject = "Réinitialisation de votre mot de passe - QuiFaitQuoiQuand"
            greeting = 'Bonjour,'
            message = (
                'Une demande de réinitialisation de votre mot de passe a été '
                'effectuée pour votre compte.'
            )
            ignore_message = (
                "Si vous n'êtes pas à l'origine de cette demande, vous pouvez "
                'ignorer ce message en toute sécurité.'
            )
            code_message = (
                'Sinon, utilisez le code ci-dessous pour réinitialiser votre '
                'mot de passe :'
            )
            sign_off = 'Merci,<br>L’équipe QuiFaitQuoiQuand'

        body = EmailDrafter._format_email_card(
            f"""\
<p style="margin:0 0 16px;">{greeting}</p>
<p style="margin:0 0 16px;">{message}</p>
<p style="margin:0 0 20px;">{ignore_message}</p>
<p style="margin:0 0 12px;">{code_message}</p>
<p style="margin:0 0 24px; padding:14px 18px; background-color:#f3f5f9; color:#0175C2; font-size:22px; font-weight:bold; letter-spacing:2px; text-align:center;">{escape(reset_code)}</p>
<p style="margin:0;">{sign_off}</p>"""
        )

        return Email(subject=subject, recipient=email, body=body)

    @staticmethod
    def create_verify_email_email(email: str, verification_code: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = "Verify your email address - QuiFaitQuoiQuand"
            greeting = 'Hello,'
            message = 'To verify your email address, please use the code below:'
            ignore_message = (
                'If you did not create this account, you can safely ignore '
                'this email.'
            )
            sign_off = 'Thank you,<br>The QuiFaitQuoiQuand Team'
        else:
            subject = "Vérifiez votre adresse e-mail - QuiFaitQuoiQuand"
            greeting = 'Bonjour,'
            message = (
                'Pour vérifier votre adresse e-mail, veuillez utiliser le '
                'code ci-dessous :'
            )
            ignore_message = (
                "Si vous n'avez pas créé ce compte, vous pouvez ignorer cet "
                'e-mail en toute sécurité.'
            )
            sign_off = 'Merci,<br>L’équipe QuiFaitQuoiQuand'

        body = EmailDrafter._format_email_card(
            f"""\
<p style="margin:0 0 16px;">{greeting}</p>
<p style="margin:0 0 20px;">{message}</p>
<p style="margin:0 0 20px;">{ignore_message}</p>
<p style="margin:0 0 24px; padding:14px 18px; background-color:#f3f5f9; color:#0175C2; font-size:22px; font-weight:bold; letter-spacing:2px; text-align:center;">{escape(verification_code)}</p>
<p style="margin:0;">{sign_off}</p>"""
        )

        return Email(subject=subject, recipient=email, body=body)

    @staticmethod
    def create_participant_report_email(
        recipient: str, report_bytes: bytes, name: str = '', lang: str = 'fr'
    ) -> Email:
        if lang == 'en':
            subject = (
                "Participant Report - QuiFaitQuoiQuand"
                if name else "Participants Report - QuiFaitQuoiQuand"
            )
            greeting = 'Hello,'
            if name:
                message = (
                    'Please find attached the report containing the tasks '
                    f'assigned to {escape(name)}.'
                )
            else:
                message = (
                    'Please find attached the report containing the tasks '
                    'assigned to each participant.'
                )
            sign_off = 'Thank you,<br>The QuiFaitQuoiQuand Team'
            filename = "participants_report.pdf"
        else:
            subject = (
                "Rapport de participant - QuiFaitQuoiQuand"
                if name else "Rapport des participants - QuiFaitQuoiQuand"
            )
            greeting = 'Bonjour,'
            if name:
                message = (
                    'Veuillez trouver en pièce jointe le rapport contenant '
                    f'les tâches assignées à {escape(name)}.'
                )
            else:
                message = (
                    'Veuillez trouver en pièce jointe le rapport contenant '
                    'les tâches assignées à chaque participant.'
                )
            sign_off = 'Merci,<br>L’équipe QuiFaitQuoiQuand'
            filename = "rapport_participants.pdf"

        body = EmailDrafter._format_email_card(
            f'<p style="margin:0 0 16px;">{greeting}</p>'
            f'<p style="margin:0 0 24px;">{message}</p>'
            f'<p style="margin:0;">{sign_off}</p>'
        )

        return Email(
            subject=subject,
            recipient=recipient,
            body=body,
            attachments={filename: report_bytes},
        )

    @staticmethod
    def create_project_report_email(recipient: str, report_bytes: bytes, project_name: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = f"Project Report: {project_name} - QuiFaitQuoiQuand"
            greeting = 'Hello,'
            message = (
                'Please find attached the detailed report for the project '
                f"'{escape(project_name)}'."
            )
            sign_off = 'Thank you,<br>The QuiFaitQuoiQuand Team'
            filename = "project_report.pdf"
        else:
            subject = f"Rapport de projet : {project_name} - QuiFaitQuoiQuand"
            greeting = 'Bonjour,'
            message = (
                'Veuillez trouver en pièce jointe le rapport détaillé pour le '
                f"projet '{escape(project_name)}'."
            )
            sign_off = 'Merci,<br>L’équipe QuiFaitQuoiQuand'
            filename = "rapport_projet.pdf"

        body = EmailDrafter._format_email_card(
            f'<p style="margin:0 0 16px;">{greeting}</p>'
            f'<p style="margin:0 0 24px;">{message}</p>'
            f'<p style="margin:0;">{sign_off}</p>'
        )

        return Email(
            subject=subject,
            recipient=recipient,
            body=body,
            attachments={filename: report_bytes}
        )

    @staticmethod
    def create_meeting_report_email(recipient: str, report_bytes: bytes, meeting_title: str, lang: str = 'fr') -> Email:
        if lang == 'en':
            subject = f"Meeting Report: {meeting_title} - QuiFaitQuoiQuand"
            greeting = 'Hello,'
            message = (
                'Please find attached the report and agenda for the meeting '
                f"'{escape(meeting_title)}'."
            )
            sign_off = 'Thank you,<br>The QuiFaitQuoiQuand Team'
            filename = "meeting_report.pdf"
        else:
            subject = f"Rapport de réunion : {meeting_title} - QuiFaitQuoiQuand"
            greeting = 'Bonjour,'
            message = (
                "Veuillez trouver en pièce jointe le rapport et l'ordre du "
                f"jour de la réunion '{escape(meeting_title)}'."
            )
            sign_off = 'Merci,<br>L’équipe QuiFaitQuoiQuand'
            filename = "rapport_reunion.pdf"

        body = EmailDrafter._format_email_card(
            f'<p style="margin:0 0 16px;">{greeting}</p>'
            f'<p style="margin:0 0 24px;">{message}</p>'
            f'<p style="margin:0;">{sign_off}</p>'
        )

        return Email(
            subject=subject,
            recipient=recipient,
            body=body,
            attachments={filename: report_bytes}
        )

    @staticmethod
    def create_organization_invitation_email(
        recipient: str, org_name: str, lang: str = 'fr'
    ) -> Email:
        windows_link = os.getenv('WINDOWS_STORE_PRODUCT_LINK')
        safe_org_name = escape(org_name)

        if lang == 'en':
            subject = f"Invitation to join '{org_name}' - QuiFaitQuoiQuand"
            invitation_prefix = 'You’re invited to join'
            account_message = (
                'You’ll automatically join this organization when you create '
                'an account in the application.'
            )
            download_message = 'Get the application to get started:'
            download_label = 'Download QFQQ for Windows'
            sign_off = 'Thank you,<br>The QuiFaitQuoiQuand Team'
        else:
            subject = f"Invitation à rejoindre '{org_name}' - QuiFaitQuoiQuand"
            invitation_prefix = 'Vous êtes invité(e) à rejoindre l’organisation'
            account_message = (
                'Vous rejoindrez automatiquement cette organisation lors de '
                'la création de votre compte dans l’application.'
            )
            download_message = 'Téléchargez l’application pour commencer :'
            download_label = 'Télécharger QFQQ pour Windows'
            sign_off = 'Merci,<br>L’équipe QuiFaitQuoiQuand'

        body = EmailDrafter._format_email_card(
            f"""\
<p style="margin:0 0 20px;">{invitation_prefix} <strong style="color:#0175C2;">{safe_org_name}</strong>.</p>
<p style="margin:0 0 20px;">{account_message}</p>
<p style="margin:0 0 12px;">{download_message}</p>
<table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin:0 0 24px;">
    <tr>
        <td bgcolor="#0175C2" style="border-radius:4px;">
            <a href="{windows_link}" style="display:inline-block; padding:12px 20px; color:#ffffff; font-weight:bold; text-decoration:none;">{download_label}</a>
        </td>
    </tr>
</table>
<p style="margin:0;">{sign_off}</p>"""
        )

        return Email(subject=subject, recipient=recipient, body=body)
