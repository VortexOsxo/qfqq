from flask import Blueprint, jsonify

from flaskr.database import UserDataHandler

users_bp = Blueprint('users', __name__, url_prefix='/users')

@users_bp.route('', methods=(['GET']))
def get_users():
    users = UserDataHandler.get_users()
    return jsonify([user.to_dict() for user in users]), 200
