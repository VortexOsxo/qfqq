from flaskr.models import User
from ..filters.default_filter import ValueFilter, IdFilter
from .base_data_handler import BaseDataHandler

class UserDataHandler(BaseDataHandler):
    @classmethod
    def get_collection_name(cls):
        return 'users'

    @classmethod
    def create_user(cls, username: str, email: str, passwordHash: str) -> bool:
        objectId, acknowledged = cls.attempt_create_item({"username": username, "email": email, "passwordHash": passwordHash})
        return acknowledged

    @classmethod
    def get_user(cls, email: str) -> User | None:
        users = cls.get_items([ValueFilter("email", email)])
        return users[0] if users else None

    @classmethod
    def get_users(cls) -> list[User]:
        return cls.get_items([])
    
    @classmethod
    def get_user_by_id(cls, id: str) -> User | None:
        return cls.get_first_item([IdFilter(id)])

    @classmethod
    def _from_mongo_dict(cls, user_dict):
        return User(
            str(user_dict["_id"]),
            user_dict["username"],
            user_dict["passwordHash"],
            user_dict["email"],
        )
