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
            id=cls._get_id_from_mongo_entry(decision_dict["_id"]),
            number=int(decision_dict.get('decisionNb')),
            description=decision_dict["description"],
            status=decision_dict["status"],
            initialDate=decision_dict["initialDate"].isoformat(),
            dueDate=decision_dict["dueDate"].isoformat() if decision_dict["dueDate"] else None,
            completedDate=decision_dict["completedDate"].isoformat() if decision_dict["dueDate"] else None,
            responsibleId=cls._get_id_from_mongo_entry(decision_dict["responsibleId"]),
            assistantsId=[str(a_id) for a_id in decision_dict["assistantsId"]],
            projectId=cls._get_id_from_mongo_entry(decision_dict["projectId"]),
        )
