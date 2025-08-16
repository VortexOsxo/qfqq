from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from flaskr.models import User


class UserDataHandler:
    @staticmethod
    def create_user(username: str, email: str, passwordHash: str) -> bool:
        users_collection = get_collection("users")
        try:
            users_collection.insert_one(
                {"username": username, "email": email, "passwordHash": passwordHash}
            )
        except DuplicateKeyError:
            return False
        return True

    @staticmethod
    def get_user(email: str) -> User:
        users_collection = get_collection("users")
        user = users_collection.find_one({"email": email})
        return UserDataHandler._from_mongo_dict(user)

    @staticmethod
    def get_users() -> list[User]:
        users_collection = get_collection("users")
        users = users_collection.find()
        return [UserDataHandler._from_mongo_dict(user) for user in users]

    @staticmethod
    def _from_mongo_dict(user_dict):
        return User(
            str(user_dict["_id"]),
            user_dict["username"],
            user_dict["passwordHash"],
            user_dict["email"],
        )
