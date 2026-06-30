import firebase_admin
from firebase_admin import credentials, messaging


class PushNotificationService:
    @classmethod
    def init(cls):
        cred = credentials.Certificate("qfqq-firebase-key.json")
        firebase_admin.initialize_app(cred)

    @classmethod
    def meeting_started_notification(cls, meetingId):
        pass

    @classmethod
    def send(cls, token, title, body, data=None) -> str:
        message = messaging.Message(
            token=token,
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={k: str(v) for k, v in (data or {}).items()},
        )

        return messaging.send(message)


PushNotificationService.init()
