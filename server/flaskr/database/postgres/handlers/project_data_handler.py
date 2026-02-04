from ..postgres import read_query, write_query
from flaskr.models import Project


class ProjectDataHandler:
    @classmethod
    def create_project(cls, title: str, goals: str, supervisorId: int) -> bool:
        query = f"INSERT INTO projects (title, goals, supervisorId) values (%s, %s, %s)"
        params = (title, goals, supervisorId)
        write_query(query, params)

    @classmethod
    def update_project(
        cls, id: str, number: int, title: str, goals: str, supervisorId: str
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
        params = (id,)
        return Project(*(read_query(query, params)[0]))
