from ..postgres import read_query, write_query, get_db_access
from flaskr.models import Project


class ProjectDataHandler:
    @classmethod
    def create_project(cls, title: str, goals: str, supervisorId: int) -> Project | None:
        try:
            with get_db_access() as conn:
                cur = conn.cursor()
                query = f"INSERT INTO projects (title, goals, supervisorId) values (%s, %s, %s) RETURNING id, nb"
                params = (title, goals, supervisorId)
                cur.execute(query, params)
                if (result := cur.fetchone()) is None: return
                id, nb = result
                return Project(id, nb, *params)
        except:
            pass
        return None


    @classmethod
    def update_project(
        cls, id: int, number: int, title: str, goals: str, supervisorId: int
    ):
        query = f"UPDATE projects SET title = %s, goals = %s, supervisorId = %s WHERE id = %s;"
        params = (title, goals, supervisorId, id)
        write_query(query, params)

    @classmethod
    def get_projects(cls):
        query = f"SELECT * from projects;"
        return [Project(*item) for item in read_query(query)]

    @classmethod
    def get_project_by_id(cls, id: int):
        query = f"SELECT * from projects WHERE id = %s LIMIT 1;"
        projects = read_query(query, (id,))
        return Project(*projects[0]) if projects else None
