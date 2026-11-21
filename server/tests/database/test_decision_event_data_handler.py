import psycopg
import pytest

from flaskr.database import DecisionDataHandler, DecisionEventDataHandler, UserDataHandler
from flaskr.database.database import Database
from flaskr.database.postgres import get_db_access, write_query
from flaskr.models import DecisionEvent


def test_get_decision_events_when_empty(app):
    assert DecisionEventDataHandler.get_decision_events_by_id(1) == []


def test_create_decision_created(app):
    DecisionEventDataHandler.create_decision_created(1, 2)

    events = DecisionEventDataHandler.get_decision_events_by_id(1)
    assert len(events) == 1
    assert isinstance(events[0], DecisionEvent)
    assert events[0].decisionId == 1
    assert events[0].userId == 2
    assert events[0].type == "decisionCreated"
    assert events[0].data is None
    assert events[0].date.tzinfo is not None


def test_create_decision_status_updated(app):
    DecisionEventDataHandler.create_decision_status_updated(2, 3, "completed")

    events = DecisionEventDataHandler.get_decision_events_by_id(2)
    assert len(events) == 1
    assert events[0].decisionId == 2
    assert events[0].userId == 3
    assert events[0].type == "statusUpdated"
    assert events[0].data == {"decisionStatus": "completed"}
    assert events[0].date.tzinfo is not None


def test_create_commented(app):
    DecisionEventDataHandler.create_decision_commented(2, 3, "This is a user comment.")

    events = DecisionEventDataHandler.get_decision_events_by_id(2)
    assert len(events) == 1
    assert events[0].decisionId == 2
    assert events[0].userId == 3
    assert events[0].type == "commented"
    assert events[0].data == {"commentContent": "This is a user comment."}
    assert events[0].date.tzinfo is not None


def test_get_decision_events_by_id(app):
    DecisionEventDataHandler.create_decision_created(1, 1)
    DecisionEventDataHandler.create_decision_status_updated(1, 2, "completed")
    DecisionEventDataHandler.create_decision_status_updated(2, 1, "pending")

    events = DecisionEventDataHandler.get_decision_events_by_id(1)
    assert len(events) == 2
    assert all(event.decisionId == 1 for event in events)
    assert [event.date for event in events] == sorted(event.date for event in events)
    assert len(DecisionEventDataHandler.get_decision_events_by_id(2)) == 1


def test_decision_events_are_deleted_with_decision(app):
    DecisionEventDataHandler.create_decision_created(1, 1)
    DecisionEventDataHandler.create_decision_created(2, 1)
    DecisionDataHandler.delete_decision(1)

    assert DecisionEventDataHandler.get_decision_events_by_id(1) == []
    assert len(DecisionEventDataHandler.get_decision_events_by_id(2)) == 1


def test_decision_events_require_existing_decision(app):
    with pytest.raises(psycopg.errors.ForeignKeyViolation):
        DecisionEventDataHandler.create_decision_created(999, 1)


def test_decision_events_require_existing_user(app):
    with pytest.raises(psycopg.errors.ForeignKeyViolation):
        DecisionEventDataHandler.create_decision_created(1, 999)


def test_decision_events_require_user_id(app):
    with pytest.raises(psycopg.errors.NotNullViolation):
        write_query(
            "INSERT INTO decisionEvents (decisionId, type, userId) VALUES (%s, %s, %s);",
            (1, "decisionCreated", None),
        )


def test_deleting_user_deletes_only_their_events(app):
    DecisionEventDataHandler.create_decision_created(1, 1)
    DecisionEventDataHandler.create_decision_status_updated(1, 2, "pending")

    assert UserDataHandler.delete_user(2)
    events = DecisionEventDataHandler.get_decision_events_by_id(1)
    assert len(events) == 1
    assert events[0].userId == 1
