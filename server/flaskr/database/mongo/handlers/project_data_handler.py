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
        return Project(str(project["_id"]), project["title"], project["description"])

    @staticmethod
    def get_projects():
        projects_collection = get_collection("projects")
        projects = projects_collection.find()
        return [
            Project(str(project["_id"]), project["title"], project["description"])
            for project in projects
        ]
