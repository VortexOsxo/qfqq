from functools import wraps
from flask import g, jsonify

from flaskr.database.postgres.handlers import UserDataHandler, OrganizationDataHandler
from flaskr.database.postgres.tenant_context import set_tenant
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

def tenant_middleware(error_response, status_code=404):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            email = kwargs.get("email")
            if not email:
                return jsonify({"error": "Email required"}), 400

            slug_res = OrganizationDataHandler.get_user_org_slug(email)
            if slug_res is None:
                return jsonify(error_response), status_code

            slug = slug_res[0]
            set_tenant(slug)
            g.org_slug = slug

            return f(*args, **kwargs)
        return decorated
    return decorator