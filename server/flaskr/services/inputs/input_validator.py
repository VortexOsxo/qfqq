from abc import ABC, abstractmethod
from typing import Callable, Optional
import re

from flaskr.errors import InputError
from flaskr.database import UserDataHandler, ProjectDataHandler, MeetingDataHandler, RoleDataHandler, OrganizationDataHandler


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
    def __init__(self, min_length=0, max_length=float('inf'), allow_empty=False):
        self.min_length=min_length
        self.max_length=max_length
        self.allow_empty=allow_empty

    def validate(self, value) -> InputError:
        if value is None:
            return InputError.RequiredField
        
        if not isinstance(value, str):
            return InputError.InvalidType
        
        if value.strip() == "" and not self.allow_empty:
            return InputError.RequiredField
        
        if len(value) > self.max_length:
            return InputError.MaxLengthExceeded
        
        if len(value) < self.min_length:
            return InputError.MinLengthExceeded
        
        return InputError.NoError

class BooleanValidator(InputValidator):
    def validate(self, value):
        return InputError.NoError if isinstance(value, bool) else InputError.InvalidType

class IntValidator(InputValidator):
    def __init__(self, min_value = None, max_value = None):
        self.min_value = min_value
        self.max_value = max_value

    def validate(self, value):
        if value is None:
            return InputError.RequiredField
        if not isinstance(value, int):
            return InputError.InvalidType
        if self.min_value is not None and value < self.min_value:
            return InputError.OutOfRange
        if self.max_value is not None and value > self.max_value:
            return InputError.OutOfRange
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
            else InputError.InvalidFormat
        )

class PasswordValidator(StringValidator):
    PasswordRegex = r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[^\w\s])\S+$"

    def __init__(self):
        super().__init__(min_length=8, max_length=100)

    def validate(self, value) -> InputError:
        if (error := super().validate(value)) != InputError.NoError:
            return error

        return (
            InputError.NoError
            if re.match(self.PasswordRegex, value) is not None
            else InputError.InvalidFormat
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

class RoleIdValidator(_ObjectIdValidator):
    dataHandler = RoleDataHandler.get_role

class OrganizationIdValidator(_ObjectIdValidator):
    dataHandler = OrganizationDataHandler.get_org

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


class TypedListValidator(InputValidator):
    def __init__(self, element_validator: InputValidator, can_be_empty: bool = True):
        self.element_validator = element_validator
        self.can_be_empty = can_be_empty

    def validate(self, l) -> InputError:
        if not isinstance(l, list):
            return InputError.ValueMustBeAList

        if not self.can_be_empty and len(l) == 0:
            return InputError.ListMustBeNonEmpty

        for item in l:
            error = self.element_validator.validate(item)
            if error != InputError.NoError:
                return error

        return InputError.NoError

class PermissionValidator(StringValidator):
    def validate(self, value):
        if (error := super().validate(value)) != InputError.NoError:
            return error

        return (
            InputError.NoError
            if value in ['canDelete', 'canWrite', 'canUpdatePermissions']
            else InputError.InvalidFormat
        )

class SlugValidator(StringValidator):
    def validate(self, value) -> InputError:
        if (error := super().validate(value)) != InputError.NoError:
            return error
        
        if value not in OrganizationDataHandler.get_existing_slugs():
            return InputError.ObjectIdNotFound
        
        return InputError.NoError
