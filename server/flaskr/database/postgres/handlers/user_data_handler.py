from ..postgres import read_query, write_query
from flaskr.models import User


class UserDataHandler:
    @classmethod
    def create_user(cls, username: str, email: str, passwordHash: str) -> bool:
        query = f"INSERT INTO users (username, email, passwordHash) values (%s, %s, %s)"
        params = (username, email, passwordHash)
        write_query(query, params)

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
