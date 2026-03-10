from abc import ABC, abstractmethod
from typing import Callable, Optional
import re

from flaskr.errors import InputError
from flaskr.database import UserDataHandler, ProjectDataHandler, MeetingDataHandler


class InputValidator(ABC):
    """The InputValidator class represent the logic to define a type of input, such as name, email, string, etc. and the logic to validate said input."""

    @abstractmethod
    def validate(self, value) -> InputError:
        pass


class OptionalInputValidator(InputValidator):
    def __init__(self, validator):
        self.validator = validator

    def validate(self, value):
        if value is None:
            return InputError.NoError
        return self.validator.validate(value)


class StringValidator(InputValidator):
    def __init__(self, max_length=float('inf')):
        self.max_length=max_length

    def validate(self, value) -> InputError:
        if value is None:
            return InputError.RequiredField
        
        if not isinstance(value, str):
            return InputError.InvalidType
        
        if value.strip() == "":
            return InputError.RequiredField
        
        if len(value) > self.max_length:
            return InputError.MaxLengthExceeded 
        
        return InputError.NoError


# TODO: Improve email validation
class EmailValidator(StringValidator):
    EmailRegex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    def validate(self, value) -> InputError:
        if (error := super().validate(value)) != InputError.NoError:
            return error

        return (
            InputError.NoError
            if re.match(self.EmailRegex, value) is not None
            else InputError.EmailFormatInvalid
        )


class DateValidator(InputValidator):
    def validate(self, value) -> InputError:
        from flaskr.utils.time import string_to_time

        return (
            InputError.InvalidDateFormat
            if string_to_time(value) is None
            else InputError.NoError
        )


class _ObjectIdValidator(InputValidator):
    dataHandler: Callable[[int], Optional[object]]

    def validate(self, id) -> InputError:
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
    def __init__(self, enum):
        self.enum = enum

    def validate(self, value) -> InputError:
        if value is None or value == "":
            return InputError.RequiredField

        return (
            InputError.NoError
            if value in self.enum.__members__
            else InputError.EnumMemberNotFound
        )


class ListValidator(InputValidator):
    def __init__(self, can_be_empty: bool = True):
        self.can_be_empty = can_be_empty

    def validate(self, l) -> InputError:
        if not isinstance(l, list):
            return InputError.ValueMustBeAList

        if not self.can_be_empty and len(l) == 0:
            return InputError.ListMustBeNonEmpty

        return InputError.NoError
