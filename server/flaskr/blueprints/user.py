from flask import Blueprint, jsonify

from flaskr.database import UserDataHandler
from flaskr.blueprints.before_request import login_required
from flaskr.services.inputs import input_middleware, LambdaBuilder, PermissionValidator, BooleanValidator

users_bp = Blueprint('users', __name__, url_prefix='/users')
users_bp.before_request(login_required)

@users_bp.route('', methods=['GET'])
def get_users():
    users = UserDataHandler.get_users()
    return jsonify([user.to_dict() for user in users]), 200


@users_bp.get("/permissions")
def get_users_permissions():
    return UserDataHandler.get_users_permissions(), 200

@users_bp.get("/<string:id>/permissions")
def get_user_permissions(id: str):
    # Returns [False,] * n, if not found
    return list(UserDataHandler.get_user_permissions(id)), 200

@users_bp.patch("/<string:id>/permissions")
@input_middleware(
    LambdaBuilder(
        ("permission_name", PermissionValidator()),
        ("permission_value", BooleanValidator()),
    )
)
def update_permissions(id: str, permission_name, permission_value):
    UserDataHandler.update_user_permissions(id, permission_name, permission_value)
    return "", 204
