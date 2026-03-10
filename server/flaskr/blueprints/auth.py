from flask import Blueprint, jsonify, current_app, g
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime, timedelta
import jwt

from flaskr.database import UserDataHandler
from flaskr.services.reset_password_service import ResetPasswordService
from flaskr.services.inputs import input_middleware, SignupBuilder, LoginBuilder, LambdaBuilder, StringValidator, EmailValidator
from flaskr.errors import InputError

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.route("/signup", methods=(["POST"]))
@input_middleware(SignupBuilder())
def signup(firstName, lastName, email, password):
    user = UserDataHandler.create_user(
        firstName, lastName, email, generate_password_hash(password)
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
@input_middleware(LoginBuilder())
def login(email, password):
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
@input_middleware(LambdaBuilder(("email", EmailValidator())))
def request_code(email):
    user = UserDataHandler.get_user_by_email(email)
    if user is None:
        return jsonify({"email": InputError.EmailNotFound})

    result = ResetPasswordService.reset_password(email, g.language)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@auth_bp.post("forgotten-password/validate-code")
@input_middleware(
    LambdaBuilder(("email", EmailValidator()), ("code", StringValidator()))
)
def validate_code(email, code):
    result = ResetPasswordService.is_code_valid(email, code)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@auth_bp.post("forgotten-password/update")
@input_middleware(
    LambdaBuilder(
        ("email", EmailValidator()),
        ("code", StringValidator()),
        ("password", StringValidator()),
    )
)
def update(email, code, password):
    result = ResetPasswordService.is_code_valid(email, code)
    if not result:
        return jsonify({"error": InputError.UnknownError}), 400

    ResetPasswordService.update_password(email, password)
    return "", 204
