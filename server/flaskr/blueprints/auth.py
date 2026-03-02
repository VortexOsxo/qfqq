from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime, timedelta
import jwt

from flaskr.database import UserDataHandler
from flaskr.utils import get_inputs_errors, InputError, StringValidator, EmailValidator
from flaskr.services.reset_password_service import ResetPasswordService

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.route("/signup", methods=(["POST"]))
def signup():
    data = request.get_json()

    required_fields = [
        StringValidator("username"),
        # TODO: Add proper password validator
        StringValidator("password"),
        EmailValidator("email"),
    ]
    errors = get_inputs_errors(data, required_fields)
    if errors:
        return jsonify(errors), 400

    username = data.get("username")
    email = data.get("email")
    password = data.get("password")

    user = UserDataHandler.create_user(
        username, email, generate_password_hash(password)
    )
    if user is None:
        return jsonify({"email": InputError.EmailMustBeUnique}), 400

    token = jwt.encode(
        {"user_id": str(user.id), "exp": datetime.utcnow() + timedelta(hours=3)},
        current_app.config["SECRET_KEY"],
        algorithm="HS256",
    )

    return jsonify({"session_token": token} | user.to_dict()), 201


@auth_bp.route("/login", methods=(["POST"]))
def login():
    data = request.get_json()

    required_fields = [
        # TODO: Add proper password validator
        StringValidator("password"),
        EmailValidator("email"),
    ]
    errors = get_inputs_errors(data, required_fields)
    if errors:
        return jsonify(errors), 400

    email = data.get("email")
    password = data.get("password")

    user = UserDataHandler.get_user_by_email(email)

    if user is None or not check_password_hash(user.passwordHash, password):
        return jsonify({"auth": InputError.InvalidLogin}), 401

    token = jwt.encode(
        {"user_id": str(user.id), "exp": datetime.utcnow() + timedelta(hours=3)},
        current_app.config["SECRET_KEY"],
        algorithm="HS256",
    )

    return jsonify({"session_token": token} | user.to_dict()), 200


@auth_bp.post("forgotten-password/request-code")
def request_code():
    data = request.get_json()

    validator = EmailValidator("email")

    email_error = validator.validate(data)
    if email_error != InputError.NoError:
        return jsonify({"email": email_error.value}), 400

    email = data["email"]
    user = UserDataHandler.get_user_by_email(email)
    if user is None:
        return jsonify({"email": InputError.EmailNotFound})

    result = ResetPasswordService.reset_password(email)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@auth_bp.post("forgotten-password/validate-code")
def validate_code():
    data = request.get_json()

    required_fields = [EmailValidator("email"), StringValidator("code")]
    errors = get_inputs_errors(data, required_fields)
    if errors:
        return jsonify(errors), 400

    email, code = data["email"], data["code"]

    result = ResetPasswordService.is_code_valid(email, code)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@auth_bp.post("forgotten-password/update")
def update():
    data = request.get_json()

    required_fields = [
        EmailValidator("email"),
        StringValidator("code"),
        StringValidator("password"),
    ]
    errors = get_inputs_errors(data, required_fields)
    if errors:
        return jsonify(errors), 400

    email, code, password = data["email"], data["code"], data["password"]

    result = ResetPasswordService.is_code_valid(email, code)
    if not result:
        return jsonify({"error": InputError.UnknownError}), 400

    ResetPasswordService.update_password(email, password)
    return "", 204
