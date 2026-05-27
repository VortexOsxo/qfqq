from flask import Blueprint, jsonify, g
from werkzeug.security import check_password_hash, generate_password_hash

from flaskr.database import UserDataHandler, OrganizationDataHandler
from flaskr.services.reset_password_service import ResetPasswordService
from flaskr.services.inputs import input_middleware, SignupBuilder, LoginBuilder, LambdaBuilder, StringValidator, EmailValidator, PasswordValidator
from flaskr.errors import InputError
from flaskr.utils import create_auth_response, create_token
from flaskr.database.postgres.tenant_context import set_tenant

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.route("/signup", methods=(["POST"]))
@input_middleware(SignupBuilder())
def signup(firstName, lastName, email, password):
    user = UserDataHandler.create_user(
        firstName, lastName, email, generate_password_hash(password)
    )
    if user is None:
        return jsonify({"email": InputError.EmailMustBeUnique}), 400

    return (
        create_auth_response(create_token(user.id, None), user),
        201,
    )


@auth_bp.route("/login", methods=(["POST"]))
@input_middleware(LoginBuilder())
def login(email, password):
    user = UserDataHandler.get_user_by_email(email)

    if user is None or not check_password_hash(user.passwordHash, password):
        return jsonify({"auth": InputError.InvalidLogin}), 401

    orgId = OrganizationDataHandler.get_user_org_id(user.id)
    if orgId is None:
        return (
            create_auth_response(create_token(user.id, None), user),
            200,
        )

    token = create_token(user.id, orgId)
    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId=user.id)

    return (
        create_auth_response(create_token(user.id, orgId), user, True, permissions),
        200,
    )


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
        ("password", PasswordValidator()),
    )
)
def update(email, code, password):
    result = ResetPasswordService.is_code_valid(email, code)
    if not result:
        return jsonify({"error": InputError.UnknownError}), 400

    ResetPasswordService.update_password(email, password)
    return "", 204
