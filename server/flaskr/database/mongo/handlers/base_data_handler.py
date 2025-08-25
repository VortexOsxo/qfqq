from abc import ABC, abstractmethod
from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from bson import ObjectId

class BaseDataHandler(ABC):
    def __init__(self, collection_name):
        self.collection_name = collection_name

    @classmethod
    @abstractmethod
    def get_collection_name(cls):
        pass

    @classmethod
    @abstractmethod
    def _from_mongo_dict(self, mongo_dict):
        pass

    @classmethod
    def get_collection(cls):
        return get_collection(cls.get_collection_name())

    @classmethod
    def get_items(cls, filters):
        collection = cls.get_collection()

        query = {}
        for filter in filters:
            filter.update_query(query)
        decisions = collection.find(query)
        return [cls._from_mongo_dict(decision) for decision in decisions]
    
    @classmethod
    def update_item(cls, id, updaters):
        collection = cls.get_collection()
        update_query = {}
        for updater in updaters:
            updater.update_query(update_query)
        collection.update_one({"_id": ObjectId(id), "$set": update_query})
    
    @classmethod
    def get_first_item(cls, filters):
        items = cls.get_items(filters)
        return items[0] if items else None

    @classmethod
    def attempt_create_item(cls, item_dict):
        collection = cls.get_collection()
        try:
            collection.insert_one(item_dict)
        except DuplicateKeyError:
            return False
        return True