import os
from dotenv import load_dotenv

from flaskr.database.database import Database
from flaskr.services.notifications.notification_service import NotificationService

if __name__ == '__main__':
    load_dotenv()
    Database.init_pool(os.environ.get("DB_URL"))

    NotificationService.send_loop()