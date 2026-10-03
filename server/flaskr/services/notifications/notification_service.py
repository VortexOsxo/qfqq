import time

import firebase_admin
from firebase_admin import credentials, messaging

from .handlers import handlers
from flaskr.database.handlers import NotificationDataHandler

class NotificationService:
    @classmethod
    def init(cls):
        cred = credentials.Certificate("qfqq-firebase-key.json")
        firebase_admin.initialize_app(cred)

    @classmethod
    def add_notification(cls, type, orgId, *arg, **kwarg):
        handler = handlers.get(type)
        assert handler is not None

        target, scheduledNotifs = handler.create(orgId, *arg, **kwarg)

        # TODO: Batch insert
        targetId = NotificationDataHandler.create_notification_target(target)
        assert targetId is not None, "Should be able to create notification target"

        for scheduledNotif in scheduledNotifs:
            scheduledNotif.targetId = targetId
            NotificationDataHandler.create_scheduled_notification(scheduledNotif)

    @classmethod
    def update_notification(cls, type, orgId, targetId, *arg, **kwarg):
        handler = handlers.get(type)
        assert handler is not None

        target, scheduledNotifs = handler.create(orgId, *arg, **kwarg)
        if target.orgId != orgId or target.targetId != targetId or target.type != type:
            raise ValueError("Notification handler returned a mismatched target")

        NotificationDataHandler.replace_notification_target(target, scheduledNotifs)

    @classmethod
    def remove_notification(cls, type, orgId, targetId):
        NotificationDataHandler.remove_notification_target(orgId, targetId, type)

    @classmethod
    def send_loop(cls):
        while True:
            try:
                pending = NotificationDataHandler.get_pending_notifications()
                targets = [target for target, _ in pending]
                if targets: print(f'Found targets: {targets}')
                for target, scheduled in pending:
                    handler = handlers.get(target.type)
                    assert handler is not None

                    notif = handler.get_notification(target, scheduled)
                    if notif is None:
                        continue
                    cls._send_notif(notif)

                NotificationDataHandler.remove_notifications(
                    [scheduled.id for _, scheduled in pending]
                )
                NotificationDataHandler.remove_empty_notification_targets()
            finally:
                time.sleep(15)

    @classmethod
    def _send_notif(cls, notif):
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
