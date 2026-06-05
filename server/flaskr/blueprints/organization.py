from flask import Blueprint, jsonify, g

from flaskr.errors.input_error import InputError
from flaskr.services.inputs import input_middleware, LambdaBuilder, StringValidator, EmailValidator, TypedListValidator
from flaskr.database import OrganizationDataHandler, UserDataHandler
from flaskr.utils import create_auth_response, create_token 
from flaskr.blueprints.before_request import login_optionnal
from flaskr.blueprints.middlewares import permission_middleware
from flaskr.models.permission import Permission
from flaskr.services.emails import EmailDrafter, EmailSender
from flaskr.database.postgres.tenant_context import set_tenant

organizations_bp = Blueprint("organizations", __name__, url_prefix="/organizations")
organizations_bp.before_request(login_optionnal)

@organizations_bp.post("/")
@input_middleware(LambdaBuilder(("organizationName", StringValidator())))
def create_organization(organizationName: str):
    orgId = OrganizationDataHandler.create_organization(organizationName)
    if orgId is None:
        return "", 400
    
    userId = g.user_id
    if userId is None:
        return jsonify({"orgId": orgId}), 201
    
    result = UserDataHandler.add_user_to_org(userId, orgId)
    assert result, "Should not fail to join a just created org"

    token = create_token(userId, orgId)

    user = UserDataHandler.get_user_by_id(userId)
    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId)

    return (
        create_auth_response(token, user, True, permissions),
        201
    )

@organizations_bp.post("<int:orgId>/join")
def join_organization(orgId):
    userId = g.user_id

    if userId is None:
        return jsonify({"userId": InputError.RequiredField}), 401
    
    if orgId is None:
        return jsonify({"orgId": InputError.RequiredField}), 401

    result = UserDataHandler.add_user_to_org(userId, orgId)
    if not result:
        return jsonify({"orgId": InputError.InvalidField}), 401
    
    token = create_token(userId, orgId)

    user = UserDataHandler.get_user_by_id(userId)
    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId)

    return (
        create_auth_response(token, user, True, permissions),
        200
    )

@organizations_bp.post("invite")
@input_middleware(LambdaBuilder(("emails", TypedListValidator(EmailValidator(), can_be_empty=False))))
@permission_middleware(Permission.CanUpdatePermissions)
def invite_to_organization(emails):
    orgId = g.org_id
    org = OrganizationDataHandler.get_org(orgId)
    if not org:
        return jsonify({"orgId": InputError.ObjectIdNotFound}), 404

    org_name = org[2]
    lang = g.language
    
    success = True
    for email in set(emails):
        user = UserDataHandler.get_user_by_email(email)
        if user is None:
            OrganizationDataHandler.add_invite(orgId=orgId, email=email)

            email_obj = EmailDrafter.create_organization_invitation_email(email, orgId, org_name, lang)
            success &= EmailSender.send_email(email_obj)
        else:
            success &= UserDataHandler.add_user_to_org(user.id, orgId)
    
    if success:
        return "", 200
    else:
        return "", 500