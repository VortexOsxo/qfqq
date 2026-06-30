from flask import Blueprint, jsonify, g

from flaskr.database import UserDataHandler
from flaskr.blueprints.before_request import login_required
from flaskr.blueprints.middlewares import permission_middleware, Permission
from flaskr.services.inputs import input_middleware, LambdaBuilder, RoleIdValidator, StringValidator

users_bp = Blueprint('users', __name__, url_prefix='/users')
users_bp.before_request(login_required)

@users_bp.route('', methods=['GET'])
def get_users():
    users = UserDataHandler.get_users(g.org_id)
    return jsonify([user.to_dict() for user in users]), 200


@users_bp.get("/permissions")
@permission_middleware(Permission.CanUpdatePermissions)
def get_users_permissions():
    return UserDataHandler.get_users_permissions(), 200

@users_bp.get("/roles")
@permission_middleware(Permission.CanUpdatePermissions)
def get_users_roles():
    return UserDataHandler.get_users_role(), 200

@users_bp.get("/<string:id>/permissions")
@permission_middleware(Permission.CanUpdatePermissions)
def get_user_permissions(id: str):
    return list(UserDataHandler.get_user_permissions(id)), 200


@users_bp.patch("/<int:userId>/role")
@permission_middleware(Permission.CanUpdatePermissions)
@input_middleware(LambdaBuilder(("roleId", RoleIdValidator())))
def update_permissions(userId: int, roleId: int): 
    UserDataHandler.update_user_role(userId, roleId)
    return "", 204

@users_bp.post('/<int:userId>/fcm')
@input_middleware(LambdaBuilder(("fcm", StringValidator())))
def update_fcm(userId:int, fcm: str):
    UserDataHandler.upsert_user_fcm(userId, fcm)
    return "", 204