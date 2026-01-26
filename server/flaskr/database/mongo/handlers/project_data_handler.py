from bson import ObjectId
from flaskr.models import Project
from .base_data_handler import BaseDataHandler
from ..filters.default_filter import IdFilter


class ProjectDataHandler(BaseDataHandler):
    @classmethod
    def get_collection_name(cls):
        return "projects"

    @classmethod
    def create_project(cls, title: str, goals: str, supervisorId: str):
        return cls.attempt_create_item(
            {
                "title": title,
                "goals": goals,
                "supervisorId": ObjectId(supervisorId),
            }
        )

    @classmethod
    def get_project(cls, id: str):
        return cls.get_items([IdFilter(id)])

    @classmethod
    def update_project(cls, id: str, number: int, title: str, goals: str, supervisorId: str):
        collection = cls.get_collection()
        collection.update_one(
            {"_id": ObjectId(id)},
            {
                "$set": {
                    "title": title,
                    "goals": goals,
                    "supervisorId": ObjectId(supervisorId),
                }
            },
        )

    @classmethod
    def get_projects(cls):
        return cls.get_items([])

    @classmethod
    def _from_mongo_dict(cls, project_dict):
        return Project(
            cls._get_id_from_mongo_entry(project_dict["_id"]),
            int(project_dict["projectNb"]),
            project_dict["title"],
            project_dict["goals"],
            str(project_dict["supervisorId"]),
        )
