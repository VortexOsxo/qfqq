from functools import wraps
from flask import g

from flaskr.database import UserDataHandler
from flaskr.models.permission import Permission

def permission_middleware(required_permission: Permission):
    def validate(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if g.user_id is None:
                return "", 403

            user_permissions = UserDataHandler.get_user_permissions(g.user_id)
            if not user_permissions[required_permission.value]:
                return "", 403

            return f(*args, **kwargs)
        return decorated
    return validate