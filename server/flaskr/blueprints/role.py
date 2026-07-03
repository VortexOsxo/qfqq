from flask import Blueprint, jsonify, g

from flaskr.database import RoleDataHandler, UserDataHandler
from flaskr.blueprints.before_request import login_required
from flaskr.blueprints.middlewares import permission_middleware, Permission
from flaskr.services.inputs import input_middleware, LambdaBuilder, PermissionValidator, BooleanValidator, StringValidator
from flaskr.errors.input_error import InputError

roles_bp = Blueprint("roles", __name__, url_prefix="/roles")
roles_bp.before_request(login_required)


@roles_bp.get("")
@permission_middleware(Permission.ManageTeam)
def get_roles():
    roles = RoleDataHandler.get_roles()
    return jsonify([role.to_dict() for role in roles]), 200


@roles_bp.get("/<int:id>")
@permission_middleware(Permission.ManageTeam)
def get_role(id: int):
    role = RoleDataHandler.get_role(id)
    if not role:
        return "", 404
    return role.to_dict(), 200


@roles_bp.post("")
@permission_middleware(Permission.ManageTeam)
@input_middleware(
    LambdaBuilder(
        ("name", StringValidator()),
        ("contribute", BooleanValidator()),
        ("deleteContent", BooleanValidator()),
        ("manageTeam", BooleanValidator()),
    )
)
def create_role(name: str, contribute: bool, deleteContent: bool, manageTeam: bool):
    role = RoleDataHandler.create_role(name.lower(), contribute, deleteContent, manageTeam)
    if role is None: return jsonify({"name": InputError.MustBeUnique}), 400

    return role.to_dict(), 201


@roles_bp.patch("/<int:roleId>")
@permission_middleware(Permission.ManageTeam)
@input_middleware(
    LambdaBuilder(
        ("permission_name", PermissionValidator()),
        ("permission_value", BooleanValidator()),
    )
)
def update_role(roleId: str, permission_name, permission_value):
    if permission_name == "manageTeam" and not permission_value:
        if UserDataHandler.get_user_role_id(g.user_id) == roleId:
            return jsonify({"error": "self_lockout"}), 403

    RoleDataHandler.update_role(roleId, permission_name, permission_value)
    return "", 204

@roles_bp.delete("/<int:id>")
@permission_middleware(Permission.ManageTeam)
def delete_role(id: int):
    result = RoleDataHandler.delete_role(id)
    if result:
        return "", 204
    return jsonify({"error": "role_in_use"}), 400