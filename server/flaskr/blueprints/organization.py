from flask import Blueprint, jsonify, g

from flaskr.errors.input_error import InputError
from flaskr.services.inputs import input_middleware, LambdaBuilder, RoleIdValidator, StringValidator,EmailValidator
from flaskr.database import OrganizationDataHandler, UserDataHandler
from flaskr.utils import create_auth_response, create_tokens 
from flaskr.blueprints.before_request import check_auth_decorator, AuthRequirement
from flaskr.blueprints.middlewares import permission_middleware
from flaskr.models import Permission, Invitation
from flaskr.services.emails import EmailDrafter, EmailSender
from flaskr.database.tenant_context import set_tenant
from threading import Thread

organizations_bp = Blueprint("organizations", __name__, url_prefix="/organizations")

@organizations_bp.post("/")
@check_auth_decorator(AuthRequirement.LoggedIn)
@input_middleware(LambdaBuilder(("organizationName", StringValidator())))
def create_organization(organizationName: str):
    orgId = OrganizationDataHandler.create_organization(organizationName)
    if orgId is None:
        return "", 400
    
    userId = g.user_id
    result = UserDataHandler.add_user_to_org(userId, orgId, 2)
    assert result, "Should not fail to join a just created org"

    tokens = create_tokens(userId, orgId)

    user = UserDataHandler.get_user_by_id(userId)
    set_tenant(orgId)
    permissions = UserDataHandler.get_user_permissions(userId)
    orgStatus = OrganizationDataHandler.get_access_status(orgId)

    return (
        create_auth_response(*tokens, user, orgStatus, permissions),
        201
    )

@organizations_bp.get("/")
@check_auth_decorator(AuthRequirement.HasOrg)
def get_organization():
    org = OrganizationDataHandler.get_org(g.org_id)
    return jsonify({'orgName': org[2]}), 200


@organizations_bp.get("/status")
@check_auth_decorator(AuthRequirement.HasOrg)
def get_organization_status():
    status, trialEndsAt = OrganizationDataHandler.get_access_info(g.org_id)
    return jsonify({
        "status": status,
        "trialEndsAt": trialEndsAt.isoformat() if trialEndsAt is not None else None,
    }), 200


@organizations_bp.post("/subscription-request")
@check_auth_decorator(AuthRequirement.HasOrg)
def request_organization_subscription():
    org = OrganizationDataHandler.get_org(g.org_id)
    user = UserDataHandler.get_user_by_id(g.user_id)

    email_obj = EmailDrafter.create_organization_subscription_request_email(
        g.org_id, org[2], user.email
    )
    EmailSender.send_email(email_obj)
    return "", 202


@organizations_bp.post("invitations")
@input_middleware(LambdaBuilder(
    ("email", EmailValidator()),
    ("roleId", RoleIdValidator())
))
@check_auth_decorator(AuthRequirement.HasOrgWithAccess)
@permission_middleware(Permission.ManageTeam)
def invite_to_organization(email, roleId):
    orgId = g.org_id
    org = OrganizationDataHandler.get_org(orgId)

    org_name = org[2]
    lang = g.language
    
    success = False

    user = UserDataHandler.get_user_by_email(email)
    if user is None:
        invited_org_id = OrganizationDataHandler.get_invite_org_id(email)
        if orgId == invited_org_id:
            return jsonify({"email": InputError.UserAlreadyInvitedToOurOrganization}), 400
        if invited_org_id is not None:
            return jsonify({"email": InputError.UserAlreadyInvitedToOtherOrganization}), 400

        OrganizationDataHandler.add_invite(orgId=orgId, email=email, roleId=roleId)

        email_obj = EmailDrafter.create_organization_invitation_email(email, org_name, lang)
        Thread(target=EmailSender.send_email, args=(email_obj,), daemon=True).start()
        invitation = Invitation(orgId=orgId, email=email, roleId=roleId)
        success = True
    else:
        user_org_id = OrganizationDataHandler.get_user_org_id(user.id)
        if orgId == user_org_id:
            return jsonify({"email": InputError.UserAlreadyInOurOrganization}), 400
        if user_org_id is not None:
            return jsonify({"email": InputError.UserAlreadyInOtherOrganization}), 400

        success = UserDataHandler.add_user_to_org(user.id, orgId, roleId)
        invitation = None
    
    if success:
        return jsonify(invitation.to_dict()) if invitation is not None else "", 201
    else:
        return "", 500
    
@organizations_bp.get("invitations")
@check_auth_decorator(AuthRequirement.HasOrgWithAccess)
@permission_middleware(Permission.ManageTeam)
def get_invites():
    invitations = OrganizationDataHandler.get_invites(g.org_id)
    return jsonify([i.to_dict() for i in invitations]), 200

@organizations_bp.delete("invitations/<email>")
@check_auth_decorator(AuthRequirement.HasOrgWithAccess)
@permission_middleware(Permission.ManageTeam)
def delete_invite(email):
    OrganizationDataHandler.remove_invite(orgId=g.org_id, email=email)
    return "", 200