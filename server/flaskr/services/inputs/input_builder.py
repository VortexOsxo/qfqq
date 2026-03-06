from abc import ABC, abstractmethod

from flaskr.errors import InputError
from flaskr.services.inputs.input_validator import *


class InputBuilder(ABC):
    @abstractmethod
    def get_fields_validators(self):
        pass

    def build(self, data):
        errors = {}
        values = {}
        for field, validator in self.get_fields_validators():
            value = data.get(field)
            error = validator.validate(value)
            if error != InputError.NoError:
                errors[field] = error
            else:
                values[field] = value

        if len(errors) > 0:
            return False, errors
        return True, values


class LambdaBuilder(InputBuilder):
    def __init__(self, *fields_validators):
        self.fields_validators = fields_validators

    def get_fields_validators(self):
        return self.fields_validators


class SignupBuilder(InputBuilder):
    # TODO: Add proper password validator
    def get_fields_validators(self):
        return (
            ("username", StringValidator()),
            ("password", StringValidator()),
            ("email", EmailValidator()),
        )


class LoginBuilder(InputBuilder):
    def get_fields_validators(self):
        return (("email", StringValidator()), ("password", StringValidator()))


class CreateProjectBuilder(InputBuilder):
    def get_fields_validators(self):
        return (
            ("title", StringValidator()),
            ("goals", StringValidator()),
            ("supervisorId", UserIdValidator()),
        )


class CreateDecisionBuilder(InputBuilder):
    def get_fields_validators(self):
        return (
            ("description", StringValidator()),
            ("responsibleId", UserIdValidator()),
            ("meetingId", MeetingIdValidator()),
            ("dueDate", DateValidator()),
        )


class CreateMeetingAgendaBuilder(InputBuilder):
    def __init__(self):
        self.is_draft = True

    def build(self, data):
        from flaskr.models import MeetingAgendaStatus

        self.is_draft = data.get("status") == MeetingAgendaStatus.planned.value
        super().build(data)

    def get_fields_validators(self):
        from flaskr.models import MeetingAgendaStatus

        validators = [
            ("title", StringValidator()),
            ("redactionDate", StringValidator()),  # TODO: DateValidator ?
        ]
        if not self.is_draft:
            validators.extend(
                [
                    ("goals", StringValidator()),
                    ("status", EnumValidator(MeetingAgendaStatus)),
                    ("meetingDate", StringValidator()),
                    ("meetingLocation", StringValidator()),
                    ("animatorId", UserIdValidator()),
                    ("participantsIds", ListValidator()),
                    ("themes", ListValidator()),
                    ("projectId", ProjectIdValidator()),
                ]
            )
        return validators
