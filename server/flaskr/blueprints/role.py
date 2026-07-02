from flask import Blueprint, jsonify

from flaskr.database import RoleDataHandler
from flaskr.blueprints.before_request import login_required
from flaskr.blueprints.middlewares import permission_middleware, Permission
from flaskr.services.inputs import input_middleware, LambdaBuilder, PermissionValidator, BooleanValidator, StringValidator
from flaskr.errors.input_error import InputError

roles_bp = Blueprint("roles", __name__, url_prefix="/roles")
roles_bp.before_request(login_required)


@roles_bp.get("")
@permission_middleware(Permission.CanUpdatePermissions)
def get_roles():
    roles = RoleDataHandler.get_roles()
    return jsonify([role.to_dict() for role in roles]), 200


@roles_bp.get("/<int:id>")
@permission_middleware(Permission.CanUpdatePermissions)
def get_role(id: int):
    role = RoleDataHandler.get_role(id)
    if not role:
        return "", 404
    return role.to_dict(), 200


@roles_bp.post("")
@permission_middleware(Permission.CanUpdatePermissions)
@input_middleware(
    LambdaBuilder(
        ("name", StringValidator()),
        ("canWrite", BooleanValidator()),
        ("canDelete", BooleanValidator()),
        ("canUpdatePermissions", BooleanValidator()),
    )
)
def create_role(name: str, canWrite: bool, canDelete: bool, canUpdatePermissions: bool):
    role = RoleDataHandler.create_role(name.lower(), canWrite, canDelete, canUpdatePermissions)
    if role is None: return jsonify({"name": InputError.MustBeUnique}), 400

    return role.to_dict(), 201


@roles_bp.patch("/<int:id>")
@permission_middleware(Permission.CanUpdatePermissions)
@input_middleware(
    LambdaBuilder(
        ("permission_name", PermissionValidator()),
        ("permission_value", BooleanValidator()),
    )
)
def update_role(id: str, permission_name, permission_value):
    RoleDataHandler.update_role(id, permission_name, permission_value)
    return "", 204

@roles_bp.delete("/<int:id>")
@permission_middleware(Permission.CanUpdatePermissions)
def delete_role(id: int):
    result = RoleDataHandler.delete_role(id)
    if result:
        return "", 204
    return jsonify({"error": "role_in_use"}), 400