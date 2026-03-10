from abc import ABC, abstractmethod

from flaskr.errors import InputError
from flaskr.services.inputs.input_validator import *

# TODO: pass facotries instead of instances so each request as its own unique instance instead of sharing it with other request

class InputBuilder(ABC):
    @abstractmethod
    def get_fields_validators(self):
        pass

    def build(self, data, *args):
        errors = {}
        values = {}
        for field, validator in self.get_fields_validators(*args):
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
            ("firstName", StringValidator(max_length=50)),
            ("lastName", StringValidator(max_length=50)),
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
    def build(self, data):
        from flaskr.models import MeetingAgendaStatus

        is_draft = data.get("status") == MeetingAgendaStatus.draft.value
        return super().build(data, is_draft)

    def get_fields_validators(self, is_draft):
        from flaskr.models import MeetingAgendaStatus

        validators = [
            ("title", StringValidator()),
            ("status", EnumValidator(MeetingAgendaStatus)),
        ]
        if not is_draft:
            validators.extend(
                [
                    ("goals", StringValidator()),
                    ("meetingDate", DateValidator()),
                    ("meetingLocation", StringValidator()),
                    ("animatorId", UserIdValidator()),
                    ("participantsIds", ListValidator()),
                    ("themes", ListValidator(can_be_empty=True)),
                    ("projectId", OptionalInputValidator(ProjectIdValidator())),
                ]
            )
        return validators
