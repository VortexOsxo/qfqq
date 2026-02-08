from abc import ABC, abstractmethod
from enum import Enum
import re

from flaskr.database import UserDataHandler, ProjectDataHandler, MeetingDataHandler
from typing import TypeAlias, Callable, Optional, Type

Input: TypeAlias = dict[str, (str | int)]


class InputError(Enum):
    NoError = 0
    RequiredField = 1
    EmailFormatInvalid = 2
    ObjectIdNotFound = 3
    EnumMemberNotFound = 4
    ValueMustBeAList = 5
    ListMustBeNonEmpty = 6
    InvalidType = 7


class InputValidator(ABC):
    """The InputValidator class represent the logic to define a type of input, such as name, email, string, etc. and the logic to validate said input."""

    def __init__(self, field_name: str):
        self.field_name = field_name

    @abstractmethod
    def validate(self, data: Input) -> InputError:
        pass


def verify_missing_inputs(data: Input, validators: list[InputValidator]) -> list[str]:
    """
    Verify that the data has all the needed fields and their validity.
    Return the list of missings/invalid field.
    """
    return [
        validator.field_name
        for validator in validators
        if validator.validate(data) != InputError.NoError
    ]


def get_inputs_errors(data: Input, validators: list[InputValidator]) -> dict[str, int]:
    results = [
        (validator.field_name, validator.validate(data)) for validator in validators
    ]
    return {
        field_name: error.value
        for (field_name, error) in results
        if error != InputError.NoError
    }


class StringValidator(InputValidator):
    def validate(self, data: Input) -> InputError:
        value = data.get(self.field_name, "")
        if not isinstance(value, str):
            return InputError.InvalidType
        return (
            InputError.NoError
            if value and value.strip() != ""
            else InputError.RequiredField
        )


# TODO: Improve email validation
class EmailValidator(StringValidator):
    EmailRegex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    def validate(self, data: Input) -> InputError:
        if (error := super().validate(data)) != InputError.NoError:
            return error
        value = str(data.get(self.field_name, ""))
        return (
            InputError.NoError
            if re.match(self.EmailRegex, value) is not None
            else InputError.EmailFormatInvalid
        )


class _ObjectIdValidator(InputValidator):
    dataHandler: Callable[[int], Optional[object]]

    def validate(self, data: Input) -> InputError:
        id = data.get(self.field_name, None)
        if not isinstance(id, int):
            return InputError.InvalidType
        if id <= 0:
            return InputError.RequiredField
        try:
            obj = self.dataHandler(id)
        except:
            return InputError.ObjectIdNotFound
        return InputError.NoError if obj is not None else InputError.ObjectIdNotFound


# TODO: Test it :)
class UserIdValidator(_ObjectIdValidator):
    dataHandler = UserDataHandler.get_user_by_id


class ProjectIdValidator(_ObjectIdValidator):
    dataHandler = ProjectDataHandler.get_project_by_id


class MeetingIdValidator(_ObjectIdValidator):
    dataHandler = MeetingDataHandler.get_meeting_agenda


# TODO: Test it :)
class EnumValidator(InputValidator):
    def __init__(self, field_name: str, enum: Type[Enum]):
        super().__init__(field_name)
        self.enum = enum

    def validate(self, data: Input) -> InputError:
        value = data.get(self.field_name, "")
        if value == "":
            return InputError.RequiredField

        return (
            InputError.NoError
            if value in self.enum.__members__
            else InputError.EnumMemberNotFound
        )


class ListValidator(InputValidator):
    def __init__(self, field_name: str, can_be_empty: bool = True):
        super().__init__(field_name)
        self.can_be_empty = can_be_empty

    def validate(self, data: Input) -> InputError:
        l = data.get(self.field_name, [])
        if not isinstance(l, list):
            return InputError.ValueMustBeAList

        if not self.can_be_empty and len(l) == 0:
            return InputError.ListMustBeNonEmpty

        return InputError.NoError
