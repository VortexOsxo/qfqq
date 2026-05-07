from ..postgres import read_query, write_query, get_db_access
from flaskr.models import Role


class RoleDataHandler:
    @classmethod
    def get_roles(cls):
        query = "SELECT id, name, canWrite, canDelete, canUpdatePermissions FROM roles;"
        results = read_query(query)
        return [Role(*result) for result in results] 

    @classmethod
    def create_role(
        cls, name: str, canWrite=False, canDelete=False, canUpdatePermissions=False
    ) -> Role | None:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()

                query = f"INSERT INTO roles (name, canWrite, canDelete, canUpdatePermissions) values (%s, %s, %s, %s) RETURNING id;"
                params = (name, canWrite, canDelete, canUpdatePermissions)
                cur.execute(query, params)
                roleId = cur.fetchone()[0]

                return Role(roleId, *params)
        except Exception as e:
            # TODO: Logging
            pass
        return None

    @classmethod
    def get_role(cls, roleId: int) -> Role | None:
        query = "SELECT id, name, canWrite, canDelete, canUpdatePermissions FROM roles WHERE id = %s;"
        params = (roleId,)
        results = read_query(query, params)
        return Role(*results[0]) if results else None

    @classmethod
    def update_role(cls, roleId: int, permission_name: str, permission_value: bool):
        query = f"UPDATE roles SET {permission_name} = %s WHERE id = %s;"
        params = (permission_value, roleId)
        write_query(query, params)

    @classmethod
    def delete_role(cls, roleId: int):
        if roleId == 1: return False
        try:
            query = f"DELETE FROM roles WHERE id = %s;"
            params = (roleId,)
            write_query(query, params)
            return True
        except:
            return False