from ..sqlite import get_db_access
from flaskr.models import User

class UserDataHandler:
    @staticmethod
    def create_user(username: str, email: str, passwordHash: str):
        db = get_db_access()
        try:
            db.execute(
                "INSERT INTO users (username, email, passwordHash) VALUES (?, ?, ?)",
                (username, email, passwordHash)
            )
            db.commit()
        except Exception as e:
            print(e)
            return False
        return True

    @staticmethod
    def get_user(email: str):
        db = get_db_access()
        user = db.execute(
            "SELECT * FROM users WHERE email = ?",
            (email,)
        ).fetchone()
        return User(user[0], user[1], user[2], user[3])
