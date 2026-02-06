from flaskr.database import UserDataHandler
from flaskr.models import User

def test_create_user(app_ctx):
    user = UserDataHandler.create_user(
        'user1', 'user1@gmail.com', '12345'
    )

    user = UserDataHandler.get_user_by_id(user.id)
    assert isinstance(user, User) == True
    
    assert user.id == 5
    assert user.username == 'user1'
    assert user.email == 'user1@gmail.com'
    assert user.passwordHash == '12345'

def test_create_user_invalid_email(app_ctx):
    user = UserDataHandler.create_user(
        'alice', 'alice@example.com', '12345'
    )

    assert user is None
