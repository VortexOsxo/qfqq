from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from flaskr.models import User

class UserDataHandler:
    @staticmethod
    def create_user(username: str, email: str, passwordHash: str):
        users_collection = get_collection('users')
        try:
            users_collection.insert_one({
                'username': username,
                'email': email,
                'passwordHash': passwordHash
            })
        except DuplicateKeyError:
            return False
        return True

    @staticmethod
    def get_user(email: str):
        users_collection = get_collection('users')
        user = users_collection.find_one({'email': email})
        return User(str(user['_id']), user['username'], user['passwordHash'], user['email'])

    @staticmethod
    def get_users():
        users_collection = get_collection('users')
        users = users_collection.find()
        return [User(str(user['_id']), user['username'], user['passwordHash'], user['email']) for user in users]
