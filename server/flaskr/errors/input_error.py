from enum import Enum

class InputError(Enum):
    UnknownError = -1
    NoError = 0
    RequiredField = 1
    EmailFormatInvalid = 2
    ObjectIdNotFound = 3
    EnumMemberNotFound = 4
    ValueMustBeAList = 5
    ListMustBeNonEmpty = 6
    InvalidType = 7
    EmailMustBeUnique = 8
    InvalidLogin = 9
    EmailNotFound = 10
    InvalidDateFormat = 11
