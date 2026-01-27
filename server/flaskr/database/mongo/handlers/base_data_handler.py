from abc import ABC, abstractmethod
from ..mongo import get_collection
from pymongo.errors import DuplicateKeyError
from bson import ObjectId

from ..filters.default_filter import IdFilter

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

        items = collection.find(query)
        return [cls._from_mongo_dict(item) for item in items]
    
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
    def get_item_by_id(cls, id: str):
        return cls.get_first_item([IdFilter(id)])

    @classmethod
    def attempt_create_item(cls, item_dict) -> tuple[bool, str]:
        collection = cls.get_collection()
        try:
            result = collection.insert_one(item_dict)
            return result.inserted_id, result.acknowledged
        except DuplicateKeyError:
            return None, False
        
    @classmethod
    def _get_id_from_mongo_entry(cls, id):
        return str(id) if id is not None else None
