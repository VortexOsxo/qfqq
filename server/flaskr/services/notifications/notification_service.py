import time

import firebase_admin
from firebase_admin import credentials, messaging

from .handlers import handlers
from flaskr.database.handlers import NotificationJobDataHandler

class NotificationService:
    @classmethod
    def init(cls):
        cred = credentials.Certificate("qfqq-firebase-key.json")
        firebase_admin.initialize_app(cred)

    @classmethod
    def add_notification(cls, type, orgId, *arg, **kwarg):
        handler = handlers.get(type)
        assert handler is not None

        job = handler.create(orgId, *arg, **kwarg)
        NotificationJobDataHandler.create_notification_job(job)

    @classmethod
    def send_loop(cls):
        while True:
            try:
                jobs = NotificationJobDataHandler.get_pending_jobs()
                if jobs: print(f'Found jobs: {jobs}')
                for job in jobs:
                    handler = handlers.get(job.type)
                    assert handler is not None

                    notifs = handler.get_notifications_from_job(job)
                    cls._send_notifs(notifs)

                    NotificationJobDataHandler.mark_as_sent(job.id)
            finally:
                time.sleep(15)
    
    @classmethod
    def _send_notifs(cls, notifs):
        for notif in notifs:
            print(f"Sending notification to {notif.token}: {notif.title}")

            message = messaging.Message(
                token=notif.token,
                notification=messaging.Notification(
                    title=notif.title,
                    body=notif.body,
                ),
                data=notif.data or {},
            )

            messaging.send(message)


NotificationService.init()
