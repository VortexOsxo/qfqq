from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from flaskr.models import User
from bson import ObjectId
from datetime import datetime

class DecisionDataHandler:
    @staticmethod
    def create_decision(
        description,
        status,
        dueDate,
        responsibleId,
        initialDate = None,
        assistantsId = None,
        projectId = None,
    ):
        if initialDate is None: initialDate = datetime.now()
        if assistantsId is None: assistantsId = []
        if projectId is None: projectId = ''

        decisions_collection = get_collection("decisions")
        try:
            decisions_collection.insert_one(
                {
                    "description": description,
                    "status": status,
                    "initialDate": initialDate,
                    "dueDate": dueDate,
                    "responsibleId": responsibleId,
                    "assistantsId": assistantsId,
                    "projectId": projectId,
                }
            )
        except DuplicateKeyError:
            return False
        return True

    @staticmethod
    def get_decision(id: str):
        users_collection = get_collection("decisions")
        user = users_collection.find_one({"_id": ObjectId(id)})
        return User(
            str(user["_id"]), user["username"], user["passwordHash"], user["email"]
        )
