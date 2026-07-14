from flask import Blueprint, jsonify, g

from flaskr.errors.input_error import InputError
from flaskr.services.inputs import input_middleware, LambdaBuilder, RoleIdValidator, StringValidator,EmailValidator
from flaskr.database import OrganizationDataHandler, UserDataHandler
from flaskr.utils import create_auth_response, create_tokens 
from flaskr.blueprints.before_request import login_optionnal
from flaskr.blueprints.middlewares import permission_middleware
from flaskr.models import Permission, Invitation
from flaskr.services.emails import EmailDrafter, EmailSender
from flaskr.database.tenant_context import set_tenant

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
    
    result = UserDataHandler.add_user_to_org(userId, orgId, 2)
    assert result, "Should not fail to join a just created org"

    tokens = create_tokens(userId, orgId)

    user = UserDataHandler.get_user_by_id(userId)
    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId)

    return (
        create_auth_response(*tokens, user, True, permissions),
        201
    )

@organizations_bp.post("<int:orgId>/join")
def join_organization(orgId):
    userId = g.user_id

    if userId is None:
        return jsonify({"userId": InputError.RequiredField}), 400
    
    if orgId is None:
        return jsonify({"orgId": InputError.RequiredField}), 400

    result = UserDataHandler.add_user_to_org(userId, orgId)
    if not result:
        return jsonify({"orgId": InputError.InvalidField}), 400
    
    tokens = create_tokens(userId, orgId)

    user = UserDataHandler.get_user_by_id(userId)
    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId)

    return (
        create_auth_response(*tokens, user, True, permissions),
        200
    )

@organizations_bp.post("invitations")
@input_middleware(LambdaBuilder(
    ("email", EmailValidator()),
    ("roleId", RoleIdValidator())
))
@permission_middleware(Permission.ManageTeam)
def invite_to_organization(email, roleId):
    orgId = g.org_id
    org = OrganizationDataHandler.get_org(orgId)
    if not org:
        return jsonify({"orgId": InputError.ObjectIdNotFound}), 404

    org_name = org[2]
    lang = g.language
    
    success = False

    user = UserDataHandler.get_user_by_email(email)
    if user is None:
        OrganizationDataHandler.add_invite(orgId=orgId, email=email, roleId=roleId)

        email_obj = EmailDrafter.create_organization_invitation_email(email, orgId, org_name, lang)
        success = EmailSender.send_email(email_obj)
        invitation = Invitation(orgId=orgId, email=email, roleId=roleId)
    else:
        success = UserDataHandler.add_user_to_org(user.id, orgId, roleId)
        invitation = None
    
    if success:
        return jsonify(invitation.to_dict()) if invitation is not None else "", 201
    else:
        return "", 500
    
@organizations_bp.get("invitations")
@permission_middleware(Permission.ManageTeam)
def get_invites():
    orgId = g.org_id
    if orgId is None:
        return "", 400

    invitations = OrganizationDataHandler.get_invites(orgId)
    return jsonify([i.to_dict() for i in invitations]), 200

@organizations_bp.delete("invitations/<email>")
@permission_middleware(Permission.ManageTeam)
def delete_invite(email):
    orgId = g.org_id
    if orgId is None:
        return "", 400

    OrganizationDataHandler.revoke_invite(orgId=orgId, email=email)
    return "", 200