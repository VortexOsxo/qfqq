from enum import Enum, auto

class AuthError(Enum):
    def _generate_next_value_(name, start, count, last_values):
        return 1000 + count

    emailAlreadyExists = auto()
    userNotFound = auto()
    wrongPassword = auto()
    mustBeLoggedIn = auto()