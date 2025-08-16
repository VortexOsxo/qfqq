from abc import ABC, abstractmethod

class DataFilter(ABC):
    @abstractmethod
    def update_query(self, query: object) -> object:
        """ Add the filter to the db query"""
        pass