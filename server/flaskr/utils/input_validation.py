from abc import ABC, abstractmethod
from enum import Enum
import re

from flaskr.database import UserDataHandler, ProjectDataHandler


class InputError(Enum):
    NoError = 0
    RequiredField = 1
    EmailFormatInvalid = 2
    ObjectIdNotFound = 3
    EnumMemberNotFound = 4
    ValueMustBeAList = 5
    ListMustBeNonEmpty = 6


class InputValidator(ABC):
    """The InputValidator class represent the logic to define a type of input, such as name, email, string, etc. and the logic to validate said input."""

    def __init__(self, field_name: str):
        self.field_name = field_name

    @abstractmethod
    def validate(self, data: dict) -> InputError:
        pass


def verify_missing_inputs(data: dict, validators: list[InputValidator]) -> list[str]:
    """
    Verify that the data has all the needed fields and their validity.
    Return the list of missings/invalid field.
    """
    return [
        validator.field_name for validator in validators if validator.validate(data) != InputError.NoError
    ]

def get_inputs_errors(data: dict, validators: list[InputValidator]) -> dict[str, InputError]:
    results = [
        (validator.field_name, validator.validate(data)) for validator in validators
    ]
    return { field_name : error.value for (field_name, error) in results if error != InputError.NoError }

class StringValidator(InputValidator):
    def validate(self, data) -> InputError:
        value = data.get(self.field_name, "")
        return (
            InputError.NoError
            if value and value.strip() != ""
            else InputError.RequiredField
        )


# TODO: Improve email validation
class EmailValidator(StringValidator):
    EmailRegex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    def validate(self, data) -> InputError:
        if not super().validate(data):
            return InputError.RequiredField
        value = data.get(self.field_name, "")
        return (
            InputError.NoError
            if re.match(self.EmailRegex, value) is not None
            else InputError.EmailFormatInvalid
        )


class _ObjectIdValidator(InputValidator):
    @property
    @abstractmethod
    def dataHandler(self):
        pass

    def validate(self, data) -> InputError:
        id = data.get(self.field_name, None)
        if id is None or id == "":
            return InputError.RequiredField
        try:
            obj = self.dataHandler.get_item_by_id(id)
        except:
            return InputError.ObjectIdNotFound
        return InputError.NoError if obj is not None else InputError.ObjectIdNotFound


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
        value = data.get(self.field_name, "")
        if value is None:
            return InputError.RequiredField

        return (
            InputError.NoError
            if value in self.enum.__members__
            else InputError.EnumMemberNotFound
        )


class ListValidator(InputValidator):
    def __init__(self, field_name, can_be_empty=True):
        super().__init__(field_name)
        self.can_be_empty = can_be_empty

    def validate(self, data):
        l = data.get(self.field_name, [])
        if not isinstance(list, l):
            return InputError.ValueMustBeAList

        if not self.can_be_empty and len(l) == 0:
            return InputError.ListMustBeNonEmpty

        return InputError.NoError
