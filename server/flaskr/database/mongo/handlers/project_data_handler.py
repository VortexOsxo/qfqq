from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from flaskr.models import Project
from bson import ObjectId


class ProjectDataHandler:
    @staticmethod
    def create_project(title: str, description: str):
        projects_collection = get_collection("projects")
        try:
            projects_collection.insert_one(
                {
                    "title": title,
                    "description": description,
                }
            )
        except DuplicateKeyError:
            return False
        return True

    @staticmethod
    def get_project(id: str):
        projects_collection = get_collection("projects")
        project = projects_collection.find_one({"_id": ObjectId(id)})
        return ProjectDataHandler._from_dict(project)

    @staticmethod
    def get_projects():
        projects_collection = get_collection("projects")
        projects = projects_collection.find()
        return [ProjectDataHandler._from_dict(project) for project in projects]

    @staticmethod
    def _from_dict(project_dict):
        return Project(
            str(project_dict["_id"]),
            project_dict["title"],
            project_dict["description"],
        )
