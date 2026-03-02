from flask import request, jsonify, g, current_app
import jwt

from flaskr.errors import AuthError


def login_required():
    if request.method == "OPTIONS":
        return

    token = None
    if "Authorization" in request.headers:
        header_parts = request.headers.get("Authorization", "").split(" ")
        token = (
            header_parts[1]
            if len(header_parts) == 2 and header_parts[0] == "Bearer"
            else None
        )

    if token is None:
        return jsonify({"error": AuthError.mustBeLoggedIn}), 401

    try:
        data = jwt.decode(token, current_app.config["SECRET_KEY"], algorithms=["HS256"])
    except Exception:
        return jsonify({"error": AuthError.mustBeLoggedIn}), 401

    g.user_id = data["user_id"]

SUPPORTED_VERSIONS = ['beta']

def get_api_version():
    if request.method == "OPTIONS":
        return
    
    version = request.headers.get("QfqqVersion", "")
    if version not in SUPPORTED_VERSIONS:
        return jsonify({"error": "Unsuported API Version"}), 400
    
    g.version = version