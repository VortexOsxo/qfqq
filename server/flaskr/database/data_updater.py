from abc import ABC, abstractmethod

class DataUpdater(ABC):
    @abstractmethod
    def update_query(self, query: object) -> object:
        """ Add the update of the field to the db query"""
        pass