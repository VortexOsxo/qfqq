from flask import request, jsonify, g, current_app
import jwt

from flaskr.errors import AuthError
from flaskr.database.postgres.tenant_context import set_tenant

def get_authorization():
    token = None
    if "Authorization" in request.headers:
        header_parts = request.headers.get("Authorization", "").split(" ")
        token = (
            header_parts[1]
            if len(header_parts) == 2 and header_parts[0] == "Bearer"
            else None
        )

    if token is None:
        return None, None

    try:
        data = jwt.decode(token, current_app.config["SECRET_KEY"], algorithms=["HS256"])
    except Exception:
        return None, None

    return data.get("user_id"), data.get("org_id")

def login_required():
    if request.method == "OPTIONS":
        return

    userId, orgId = get_authorization()
    if userId is None or orgId is None:
        return jsonify({"error": AuthError.mustBeLoggedIn}), 401

    g.user_id = userId
    g.org_id = orgId
    set_tenant(g.org_id)

def login_optionnal():
    if request.method == "OPTIONS":
        return

    g.user_id, g.org_id = get_authorization()
    if g.org_id is not None:
        set_tenant(g.org_id)

SUPPORTED_VERSIONS = ['beta']

def get_api_version():
    if request.method == "OPTIONS":
        return
    
    version = request.headers.get("QfqqVersion", "")
    if version not in SUPPORTED_VERSIONS:
        return jsonify({"error": "Unsuported API Version"}), 400
    
    g.version = version

def get_language():
    g.language = request.headers.get("Accept-Language", "fr")