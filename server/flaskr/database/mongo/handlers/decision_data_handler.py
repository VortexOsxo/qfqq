from datetime import datetime
from flaskr.models import Decision
from ..filters.default_filter import IdFilter
from .base_data_handler import BaseDataHandler
from bson import ObjectId

class DecisionDataHandler(BaseDataHandler):
    @classmethod
    def get_collection_name(cls):
        return "decisions"

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

        objectId, acknowledged = cls.attempt_create_item(
            {
                "description": description,
                "status": status,
                "initialDate": initialDate,
                "dueDate": dueDate,
                "responsibleId": ObjectId(responsibleId) if responsibleId else None,
                "reporterId": ObjectId(reporterId) if reporterId else None,
                "assistantsId": [ObjectId(a_id) for a_id in assistantsId],
                "projectId": ObjectId(projectId) if projectId else None,
            }
        )
        return acknowledged

    @classmethod
    def get_decision(cls, decision_id: str):
        return cls.get_first_item([IdFilter("_id", decision_id)])

    @classmethod
    def get_decisions(cls):
        return cls.get_items([])
    
    @classmethod
    def get_decisions_by_filters(cls, filters):
        return cls.get_items(filters)

    @classmethod
    def _from_mongo_dict(cls, decision_dict):
        return Decision(
            cls._get_id_from_mongo_entry(decision_dict["_id"]),
            decision_dict["description"],
            decision_dict["status"],
            decision_dict["initialDate"].isoformat(),
            decision_dict["dueDate"].isoformat() if decision_dict["dueDate"] else None,
            cls._get_id_from_mongo_entry(decision_dict["responsibleId"]),
            cls._get_id_from_mongo_entry(decision_dict["reporterId"]),
            [str(a_id) for a_id in decision_dict["assistantsId"]],
            cls._get_id_from_mongo_entry(decision_dict["projectId"]),
        )
