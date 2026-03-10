import pytest
from flaskr.services.inputs.input_validator import PasswordValidator
from flaskr.errors import InputError

@pytest.fixture
def validator():
    return PasswordValidator()

def test_password_valid(validator):
    assert validator.validate("StrongPass1!") == InputError.NoError
    assert validator.validate("V3ry$ecureP@ssword") == InputError.NoError

def test_password_below_minimum_size(validator):
    assert validator.validate("Pass1!") == InputError.MinLengthExceeded
    assert validator.validate("A1@") == InputError.MinLengthExceeded

def test_password_above_maximum_size(validator):
    long_pass = "A1@" + "a" * 98
    assert validator.validate(long_pass) == InputError.MaxLengthExceeded

def test_password_without_special_character(validator):
    assert validator.validate("Password123") == InputError.InvalidFormat
    assert validator.validate("Password123~") == InputError.InvalidFormat
    assert validator.validate("Password123.") == InputError.InvalidFormat

def test_password_without_number(validator):
    assert validator.validate("Password!@#") == InputError.InvalidFormat
    assert validator.validate("StrongPassword!") == InputError.InvalidFormat

def test_password_without_letter(validator):
    assert validator.validate("12345678!@#") == InputError.InvalidFormat

def test_password_with_weird_unallowed_special_character(validator):
    assert validator.validate("StrongPass1!~`") == InputError.InvalidFormat

def test_password_empty_or_none(validator):
    assert validator.validate("") == InputError.RequiredField
    assert validator.validate(None) == InputError.RequiredField
    assert validator.validate("      ") == InputError.RequiredField

def test_password_only_spaces_with_valid_chars(validator):
    assert validator.validate(" a B 1 ! ") == InputError.InvalidFormat
    assert validator.validate(" aaaaaaaaaaa B 1 ! ") == InputError.InvalidFormat
