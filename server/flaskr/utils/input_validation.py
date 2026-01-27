from abc import ABC, abstractmethod
import re

from flaskr.database import UserDataHandler, ProjectDataHandler


class InputValidator(ABC):
    """The InputValidator class represent the logic to define a type of input, such as name, email, string, etc. and the logic to validate said input."""

    def __init__(self, field_name: str):
        self.field_name = field_name

    @abstractmethod
    def validate(self, data: dict) -> bool:
        pass


def verify_missing_inputs(data: dict, validators: list[InputValidator]) -> list[str]:
    """
    Verify that the data has all the needed fields and their validity.
    Return the list of missings/invalid field.
    """
    return [
        validator.field_name for validator in validators if not validator.validate(data)
    ]


class StringValidator(InputValidator):
    def validate(self, data) -> bool:
        value = data.get(self.field_name, "")
        return bool(value and value.strip() != "")


# TODO: Improve email validation
class EmailValidator(StringValidator):
    EmailRegex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    def validate(self, data) -> bool:
        if not super().validate(data):
            return False
        value = data.get(self.field_name, "")
        return re.match(self.EmailRegex, value) is not None

class _ObjectIdValidator(InputValidator):
    @property
    @abstractmethod
    def dataHandler(self):
        pass

    def validate(self, data) -> bool:
        id = data.get(self.field_name, None)
        if id is None:
            return False

        obj = self.dataHandler.get_item_by_id(id)
        return obj is not None

# TODO: Test it :)
class UserIdValidator(_ObjectIdValidator):
    dataHandler = UserDataHandler

class ProjectIdValidator(_ObjectIdValidator):
    dataHandler = ProjectDataHandler

# TODO: Test it :)
class EnumValidator(InputValidator):
    def __init__(self, field_name, enum):
        super().__init__(field_name)
        self.enum = enum

    def validate(self, data) -> bool:
        value = data.get(self.field_name)
        return value in self.enum.__members__
