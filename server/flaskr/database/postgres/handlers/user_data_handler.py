from ..postgres import read_query, get_db_access
from flaskr.models import User


class UserDataHandler:
    @classmethod
    def create_user(cls, username: str, email: str, passwordHash: str) -> User:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = f"INSERT INTO users (username, email, passwordHash) values (%s, %s, %s) RETURNING id;"
                params = (username, email, passwordHash)
                cur.execute(query, params)
                userId = cur.fetchone()[0]
            
                return User(userId, *params)
        except:
            pass
        return None

    @classmethod
    def get_users(cls):
        query = f"SELECT * from users;"
        users = read_query(query)
        return [User(*user) for user in users]

    @classmethod
    def get_user_by_id(cls, id: int):
        query = f"SELECT * from users WHERE id = %s LIMIT 1;"
        params = (id,)
        users = read_query(query, params)
        return User(*users[0])

    @classmethod
    def get_user_by_email(cls, email: str):
        query = f"SELECT * from users WHERE email = %s LIMIT 1;"
        params = (email,)
        users = read_query(query, params)
        return User(*users[0])
