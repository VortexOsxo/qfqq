from flask import Blueprint, jsonify

from flaskr.database import UserDataHandler

users_bp = Blueprint('users', __name__, url_prefix='/users')

@users_bp.route('/', methods=(['GET']))
def get_users():
    return jsonify(UserDataHandler.get_users()), 200
