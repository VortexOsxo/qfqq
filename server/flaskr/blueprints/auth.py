from flask import Blueprint, jsonify, g, request, current_app

from werkzeug.security import check_password_hash, generate_password_hash
import jwt

from flaskr.database import UserDataHandler, OrganizationDataHandler
from flaskr.services.account_service import AccountService
from flaskr.services.inputs import input_middleware, SignupBuilder, LoginBuilder, LambdaBuilder, StringValidator, EmailValidator, PasswordValidator
from flaskr.errors import InputError
from flaskr.utils import create_auth_response, create_tokens
from flaskr.blueprints.before_request import login_required
from flaskr.database.tenant_context import set_tenant

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.route("/signup", methods=(["POST"]))
@input_middleware(SignupBuilder())
def signup(firstName, lastName, email, password):
    user = UserDataHandler.create_user(
        firstName, lastName, email, generate_password_hash(password)
    )
    if user is None:
        return jsonify({"email": InputError.EmailMustBeUnique}), 400

    orgId, roleId = OrganizationDataHandler.check_invite(email)
    if orgId:
        result = UserDataHandler.add_user_to_org(user.id, orgId, roleId)
        assert result, "Should be able to join a org when invited"
        set_tenant(orgId)
        permissions = UserDataHandler.get_user_permissions(userId=user.id)
        return (
            create_auth_response(*create_tokens(user.id, orgId), user, True, permissions),
            201,
        )

    return (
        create_auth_response(*create_tokens(user.id, None), user),
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
            create_auth_response(*create_tokens(user.id, None), user),
            200,
        )

    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId=user.id)

    return (
        create_auth_response(*create_tokens(user.id, orgId), user, True, permissions),
        200,
    )


@auth_bp.post("/refresh")
def refresh():
    if "Refresh" in request.headers:
        token = request.headers.get("Refresh", "")

    try:
        data = jwt.decode(token, current_app.config["SECRET_KEY"], algorithms=["HS256"])
    except Exception:
        return "", 401
    
    userId = data.get("user_id")
    if userId is None:
        return "", 401

    orgId = OrganizationDataHandler.get_user_org_id(userId)

    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId=userId)
    user = UserDataHandler.get_user_by_id(userId)

    return (
        create_auth_response(*create_tokens(userId, orgId), user, True, permissions),
        200,
    )


@auth_bp.post("forgotten-password/request-code")
@input_middleware(LambdaBuilder(("email", EmailValidator())))
def request_code(email):
    user = UserDataHandler.get_user_by_email(email)
    if user is None:
        return jsonify({"email": InputError.EmailNotFound})

    result = AccountService.reset_password(email, g.language)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@auth_bp.post("forgotten-password/validate-code")
@input_middleware(
    LambdaBuilder(("email", EmailValidator()), ("code", StringValidator()))
)
def validate_password_code(email, code):
    result = AccountService.is_password_code_valid(email, code)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@auth_bp.post("forgotten-password/update")
@input_middleware(
    LambdaBuilder(
        ("email", EmailValidator()),
        ("code", StringValidator()),
        ("password", PasswordValidator()),
    )
)
def update_password(email, code, password):
    result = AccountService.is_password_code_valid(email, code)
    if not result:
        return jsonify({"error": InputError.UnknownError}), 400

    AccountService.update_password(email, password)
    return "", 204


email_verification_bp = Blueprint("email_verification", __name__, url_prefix="/email-verification")
email_verification_bp.before_request(login_required)

@email_verification_bp.post("/request-code")
def request_email_validation():
    user = UserDataHandler.get_user_by_id(g.user_id)
    if user is None:
        return "", 404

    result = AccountService.verify_email(user.email, g.language)
    return ("", 204) if result else (jsonify({"error": InputError.UnknownError}), 400)


@email_verification_bp.post("/validate-code")
@input_middleware(LambdaBuilder(("code", StringValidator())))
def validate_email_code(code):
    user = UserDataHandler.get_user_by_id(g.user_id)
    if user is None:
        return "", 404

    result = AccountService.is_email_code_valid(user.email, code)
    if not result:
        return jsonify({"error": InputError.UnknownError}), 400

    AccountService.mark_email_as_verified(user.email)
    return "", 204


auth_bp.register_blueprint(email_verification_bp)
