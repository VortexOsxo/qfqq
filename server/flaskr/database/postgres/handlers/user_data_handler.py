from ..postgres import read_query, write_query, get_db_access
from flaskr.models import User


class UserDataHandler:
    @classmethod
    def create_user(cls, firstName: str, lastName: str, email: str, passwordHash: str) -> User:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = f"INSERT INTO users (firstName, lastName, passwordHash, email) values (%s, %s, %s, %s) RETURNING id;"
                params = (firstName, lastName, passwordHash, email)
                cur.execute(query, params)
                userId = cur.fetchone()[0]

                query = f"INSERT INTO usersPermissions (userId, canDelete, canWrite, canUpdatePermissions) VALUES (%s, %s, %s, %s);"
                cur.execute(query, (userId, False, False, False))

                return User(userId, *params)
        except Exception as e:
            # TODO: Logging
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
        return User(*users[0]) if users else None

    @classmethod
    def get_user_by_email(cls, email: str):
        query = f"SELECT * from users WHERE email = %s LIMIT 1;"
        params = (email,)
        users = read_query(query, params)
        return User(*users[0]) if users else None

    @classmethod
    def update_user_password(cls, email: str, newPasswordHash: str):
        query = "UPDATE users SET passwordHash = %s WHERE email = %s"
        params = (newPasswordHash, email)
        write_query(query, params)

    @classmethod
    def get_users_permissions(cls):
        query = "SELECT userId, canWrite, canDelete, canUpdatePermissions FROM usersPermissions;"
        return read_query(query)

    @classmethod
    def get_user_permissions(cls, userId: int):
        query = f"SELECT canWrite, canDelete, canUpdatePermissions FROM usersPermissions WHERE userId = %s;"
        permissions = read_query(query, (userId,))
        return permissions[0] if permissions else ((False,) * 3) 

    @classmethod
    def update_user_permissions(cls, userId: int, permission_name: str, permission_value: bool):
        query = f"UPDATE usersPermissions SET {permission_name} = %s WHERE userId = %s;"
        params = (permission_value, userId)
        write_query(query, params)