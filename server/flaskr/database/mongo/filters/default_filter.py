from ...data_filter import DataFilter
from bson import ObjectId

class ValueFilter(DataFilter):
    def __init__(self, field, value):
        self.field: str = field
        self.value = value

    def update_query(self, query):
        query[self.field] = self.value
        return query

class IdFilter(ValueFilter):
    def __init__(self, id: str):
        super().__init__('_id', ObjectId(id))