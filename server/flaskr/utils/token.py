from flask import current_app
from datetime import datetime, timedelta, timezone
import jwt

# TODO: Add token type field

def create_tokens(userId, orgId):
    return create_auth_token(userId, orgId), create_refresh_token(userId)

def create_auth_token(userId, orgId):
    return jwt.encode(
        {
            "user_id": userId,
            "org_id": orgId,
            "exp": datetime.now(timezone.utc) + timedelta(hours=24),
        },
        current_app.config["SECRET_KEY"],
        algorithm="HS256",
    )

def create_refresh_token(userId):
    return jwt.encode(
        {
            "user_id": userId,
            "exp": datetime.now(timezone.utc) + timedelta(hours=2400),
        },
        current_app.config["SECRET_KEY"],
        algorithm="HS256",
    )
