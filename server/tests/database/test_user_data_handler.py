from flaskr.database import UserDataHandler
from flaskr.models import User


def test_create_user(app):
    user_created = UserDataHandler.create_user("user1", "user1@gmail.com", "12345")

    user = UserDataHandler.get_user_by_id(user_created.id)
    assert user == user_created

    assert isinstance(user, User)

    assert user.id == 5
    assert user.username == "user1"
    assert user.email == "user1@gmail.com"
    assert user.passwordHash == "12345"


def test_create_user_invalid_email(app):
    user = UserDataHandler.create_user("alice", "alice@example.com", "12345")

    assert user is None


def test_get_not_found_user_by_id(app):
    user = UserDataHandler.get_user_by_id(5)
    assert user is None


def test_get_not_found_user_by_email(app):
    user = UserDataHandler.get_user_by_email("hi@gmail.com")
    assert user is None
