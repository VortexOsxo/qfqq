import pytest

from flaskr.errors import InputError
from flaskr.models import ProjectStatus
from flaskr.services.inputs.input_validator import IntValidator, LiteralValidator, PasswordValidator, TypedListValidator

@pytest.fixture
def validator():
    return PasswordValidator()

def test_password_valid(validator):
    assert validator.validate("StrongPass1!") == InputError.NoError
    assert validator.validate("V3ry$ecureP@ssword") == InputError.NoError
    assert validator.validate("StrongPassword1~") == InputError.NoError
    assert validator.validate("[Strong,.Password1~]}{") == InputError.NoError
    assert validator.validate("StrongPass1!😍") == InputError.NoError
    assert validator.validate("StrongPass1!ط") == InputError.NoError

def test_password_below_minimum_size(validator):
    assert validator.validate("Pass1!") == InputError.MinLengthExceeded
    assert validator.validate("A1@") == InputError.MinLengthExceeded

def test_password_above_maximum_size(validator):
    long_pass = "A1@" + "a" * 98
    assert validator.validate(long_pass) == InputError.MaxLengthExceeded

def test_password_without_special_character(validator):
    assert validator.validate("Password123") == InputError.InvalidFormat

def test_password_without_number(validator):
    assert validator.validate("Password!@#") == InputError.InvalidFormat
    assert validator.validate("StrongPassword!") == InputError.InvalidFormat

def test_password_without_letter(validator):
    assert validator.validate("12345678!@#") == InputError.InvalidFormat

def test_password_empty_or_none(validator):
    assert validator.validate("") == InputError.RequiredField
    assert validator.validate(None) == InputError.RequiredField
    assert validator.validate("      ") == InputError.RequiredField

def test_password_only_spaces_with_valid_chars(validator):
    assert validator.validate(" a B 1 ! ") == InputError.InvalidFormat
    assert validator.validate(" aaaaaaaaaaa B 1 ! ") == InputError.InvalidFormat


def test_literal_validator_accepts_values_and_rejects_invalid_types():
    validator = LiteralValidator(ProjectStatus)

    assert validator.validate("completed") == InputError.NoError
    assert validator.validate("fake") == InputError.EnumMemberNotFound
    assert validator.validate(["completed"]) == InputError.InvalidType
    assert validator.validate({"status": "completed"}) == InputError.InvalidType


def test_typed_list_validator_requires_unique_values():
    validator = TypedListValidator(IntValidator(), unique_element=True)

    assert validator.validate([1, 2, 3]) == InputError.NoError
    assert validator.validate([1, 2, 1]) == InputError.MustBeUnique


def test_int_validator_for_bool():
    validator = IntValidator()

    assert validator.validate(True) == InputError.InvalidType
    assert validator.validate(False) == InputError.InvalidType


def test_int_validator_for_0_1():
    validator = IntValidator()

    assert validator.validate(1) == InputError.NoError
    assert validator.validate(0) == InputError.NoError