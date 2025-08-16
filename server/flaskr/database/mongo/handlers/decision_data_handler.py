from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from datetime import datetime
from flaskr.models import Decision
from ..filters.default_filter import IdFilter
from .base_data_handler import BaseDataHandler


class DecisionDataHandler(BaseDataHandler):
    @classmethod
    def create_decision(
        cls,
        description,
        status,
        dueDate,
        responsibleId,
        reporterId,
        initialDate=None,
        assistantsId=None,
        projectId=None,
    ):
        if initialDate is None:
            initialDate = datetime.now()
        if assistantsId is None:
            assistantsId = []
        if projectId is None:
            projectId = ""

        decisions_collection = cls.get_collection()
        try:
            decisions_collection.insert_one(
                {
                    "description": description,
                    "status": status,
                    "initialDate": initialDate,
                    "dueDate": dueDate,
                    "responsibleId": responsibleId,
                    "reporterId": reporterId,
                    "assistantsId": assistantsId,
                    "projectId": projectId,
                }
            )
        except DuplicateKeyError:
            return False
        return True

    @classmethod
    def get_collection_name(cls):
        return "decisions"

    @classmethod
    def get_decision(cls, decision_id: str):
        return cls.get_items(
            [IdFilter("_id", decision_id)]
        )

    @classmethod
    def get_decisions(cls):
        return cls.get_items([])

    @classmethod
    def _from_mongo_dict(cls, decision_dict):
        return Decision(
            str(decision_dict["_id"]),
            decision_dict["description"],
            decision_dict["status"],
            decision_dict["initialDate"].isoformat(),
            decision_dict["dueDate"].isoformat() if decision_dict["dueDate"] else None,
            decision_dict["responsibleId"],
            decision_dict["reporterId"],
            decision_dict["assistantsId"],
            decision_dict["projectId"],
        )
