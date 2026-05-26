from psycopg import sql

from ..postgres import read_query, write_query, get_db_access
from flaskr.models import User


class UserDataHandler:
    @classmethod
    def create_user(cls, firstName: str, lastName: str, email: str, passwordHash: str) -> User:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = f"INSERT INTO public.users (firstName, lastName, passwordHash, email) values (%s, %s, %s, %s) RETURNING id;"
                params = (firstName, lastName, passwordHash, email)
                cur.execute(query, params)
                userId = cur.fetchone()[0]

                return User(userId, *params)
        except Exception as e:
            # TODO: Logging
            pass
        return None

    @classmethod
    def add_user_to_org(cls, userId, orgId):
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = "INSERT INTO public.memberships (userId, orgId) values (%s, %s);"
                params = (userId, orgId)
                cur.execute(query, params)

                cur.execute(
                    sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(str(orgId)))
                )

                query = f"INSERT INTO usersRoles (userId, roleId) VALUES (%s, %s);"
                cur.execute(query, (userId, 1))

                return True
        except Exception as e:
            pass
        return False

    @classmethod
    def get_users(cls, orgId: int):
        query = """
            SELECT u.* FROM public.users u
            JOIN public.memberships m ON u.id = m.userId
            WHERE m.orgId = %s;
        """
        users = read_query(query, (orgId,))
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
    def get_users_role(cls):
        query = """
            SELECT ur.userId as userId, r.id as id, r.name FROM roles r
            JOIN usersRoles ur ON ur.roleId = r.id;
        """
        return [
            {"userId": r[0], "roleId": r[1], "roleName": r[2]}
            for r in read_query(query)
        ]

    @classmethod
    def update_user_role(cls, userId, roleId):
        query = "UPDATE usersRoles SET roleId = %s WHERE userId = %s;"
        try:
            write_query(query, (roleId, userId))
            return True
        except:
            return False

    @classmethod
    def get_user_role(cls, userId: int):
        query = """
            SELECT r.canWrite, r.canDelete, r.canUpdatePermissions 
            FROM roles r
            JOIN usersRoles ur ON ur.roleId = r.id
            WHERE ur.userId = %s;
        """
        permissions = read_query(query, (userId,))
        return permissions[0] if permissions else ((False,) * 3) 

    @classmethod
    def get_users_permissions(cls):
        query = """
            SELECT ur.userId, r.canWrite, r.canDelete, r.canUpdatePermissions FROM roles r
            JOIN usersRoles ur ON ur.roleId = r.id;
        """
        return read_query(query)

    @classmethod
    def get_user_permissions(cls, userId: int):
        query = """
            SELECT r.canWrite, r.canDelete, r.canUpdatePermissions FROM roles r
            JOIN usersRoles ur ON ur.roleId = r.id WHERE userId = %s;
        """
        permissions = read_query(query, (userId,))
        return permissions[0] if permissions else ((False,) * 3) 
