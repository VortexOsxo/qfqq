import functools
import jwt
from flask import Blueprint, g, request, jsonify, current_app
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime, timedelta

from flaskr.database import UserDataHandler
from flaskr.errors import AuthError

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.before_app_request
def load_logged_in_user():
    token = None
    g.user_id = None

    if 'Authorization' in request.headers:
        token = request.headers['Authorization'].split(" ")[1] 
        
    if not token: return

    try:
        data = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
    except Exception:
        return

    g.user_id = data['user_id']

@auth_bp.route('/signup', methods=(['POST']))
def signup():
    data = request.get_json()

    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if not UserDataHandler.create_user(username, email, generate_password_hash(password)):
        return jsonify({'emailError': AuthError.emailAlreadyExists.value}), 400 
    return jsonify({}), 201

@auth_bp.route('/login', methods=(['POST']))
def login():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    user = UserDataHandler.get_user(email)

    if user is None:
        return jsonify({'error': AuthError.userNotFound.value}), 401
    elif not check_password_hash(user.passwordHash, password):
        return jsonify({'error': AuthError.wrongPassword.value}), 401
    
    token = jwt.encode({
        'user_id': str(user.id),
        'exp': datetime.utcnow() + timedelta(hours=3)
    }, current_app.config['SECRET_KEY'], algorithm='HS256')

    return jsonify({'token': token}), 200

def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if request.method != "OPTIONS" and g.user_id is None:
            return jsonify({'error': AuthError.mustBeLoggedIn.value}), 401
        return view(**kwargs)

    return wrapped_view