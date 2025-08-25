from ...data_updater import DataUpdater

class ValueUpdater(DataUpdater):
    def __init__(self, field, value):
        self.field: str = field
        self.value = value

    def update_query(self, query):
        query[self.field] = self.value
        return query
