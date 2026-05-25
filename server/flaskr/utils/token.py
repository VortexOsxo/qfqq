from flask import current_app
from datetime import datetime, timedelta
import jwt

def create_token(userId, orgId):
    return jwt.encode(
        {
            "user_id": userId,
            "org_id": orgId,
            "exp": datetime.utcnow() + timedelta(hours=3),
        },
        current_app.config["SECRET_KEY"],
        algorithm="HS256",
    )