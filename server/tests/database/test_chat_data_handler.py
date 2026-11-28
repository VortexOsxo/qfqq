import psycopg
import pytest
from concurrent.futures import ThreadPoolExecutor
from threading import Barrier

from flaskr.database import ChatDataHandler, UserDataHandler
from flaskr.database.postgres import read_query, write_query
from flaskr.database.tenant_context import use_tenant
from flaskr.models import Message


def test_create_chat_adds_participants(app):
    chat_id = ChatDataHandler.create_chat("Super Chat", [1, 2])

    assert read_query(
        "SELECT userId FROM chatsUsers WHERE chatId = %s ORDER BY userId;",
        (chat_id,),
    ) == [(1,), (2,)]


def test_create_chat_is_atomic_when_participant_is_invalid(app):
    with pytest.raises(psycopg.errors.ForeignKeyViolation):
        ChatDataHandler.create_chat("Chat", [1, 999])
    assert read_query("SELECT id FROM chats;") == []


def test_is_active_participant(app):
    chat_id = ChatDataHandler.create_chat("Name", [1, 2, 4])
    ChatDataHandler.create_chat("Name", [3])
    ChatDataHandler.leave_chat(chat_id, 2)

    assert ChatDataHandler.is_active_participant(chat_id, 1) is True
    assert ChatDataHandler.is_active_participant(chat_id, 2) is False
    assert ChatDataHandler.is_active_participant(chat_id, 3) is False


def test_get_active_participants(app):
    chat_id = ChatDataHandler.create_chat("Name", [1, 2, 3])
    other_chat_id = ChatDataHandler.create_chat("Other chat", [2])
    ChatDataHandler.leave_chat(chat_id, 2)

    assert sorted(ChatDataHandler.get_active_participants(chat_id)) == [1, 3]
    assert ChatDataHandler.get_active_participants(other_chat_id) == [2]
    ChatDataHandler.leave_chat(chat_id, 1)
    ChatDataHandler.leave_chat(chat_id, 3)
    assert ChatDataHandler.get_active_participants(chat_id) == []


def test_send_and_paginate_messages(app):
    chat_id = ChatDataHandler.create_chat("Name", [1, 2])
    other_chat_id = ChatDataHandler.create_chat("Name", [1])
    first = ChatDataHandler.send_message(chat_id, 1, "First")
    second = ChatDataHandler.send_message(chat_id, 2, "Second")
    third = ChatDataHandler.send_message(chat_id, 1, "Third")
    ChatDataHandler.send_message(other_chat_id, 1, "Other chat")

    assert isinstance(first, Message)
    assert first.sentAt.tzinfo is not None
    assert first.to_dict()["content"] == "First"
    # Make the timestamp tie explicit so pagination also tests its ID tie-breaker.
    write_query(
        "UPDATE messages SET sentAt = %s WHERE chatId = %s;",
        (first.sentAt, chat_id),
    )
    assert [m.id for m in ChatDataHandler.get_messages(chat_id, 0, 2)] == [
        third.id, second.id
    ]
    assert [m.id for m in ChatDataHandler.get_messages(chat_id, 2, 2)] == [first.id]
    assert ChatDataHandler.get_messages(chat_id, 0, 0) == []
    assert ChatDataHandler.get_messages(chat_id, 10, 2) == []


def test_get_messages_invalid():
    chat_id = ChatDataHandler.create_chat("Name", [1, 2])

    with pytest.raises(ValueError):
        ChatDataHandler.get_messages(chat_id, -1, 2)
    with pytest.raises(ValueError):
        ChatDataHandler.get_messages(chat_id, 0, -1)


def test_leaving_preserves_messages_and_prevents_sending(app):
    chat_id = ChatDataHandler.create_chat("Name", [1, 2, 4])
    message = ChatDataHandler.send_message(chat_id, 1, "Hello")

    ChatDataHandler.leave_chat(chat_id, 1)

    assert [m.id for m in ChatDataHandler.get_messages(chat_id, 0, 10)] == [message.id]

    with pytest.raises(ValueError):
        ChatDataHandler.send_message(chat_id, 1, "After leaving")

    with pytest.raises(ValueError):
        ChatDataHandler.send_message(chat_id, 3, "Not a member")

    assert ChatDataHandler.send_message(chat_id, 2, "Still here").senderId == 2


def test_concurrent_direct_chat_creation_reuses_one_chat(app):
    barrier = Barrier(2)

    def create(user_ids):
        with use_tenant("1"):
            barrier.wait(timeout=10)
            return ChatDataHandler.create_direct_chat("Name", user_ids)

    with ThreadPoolExecutor(max_workers=2) as executor:
        results = list(executor.map(create, ([1, 2], [2, 1])))

    assert results[0][0] == results[1][0]
    assert sorted(result[1] for result in results) == [False, True]
    assert read_query("SELECT COUNT(*) FROM chats;") == [(1,)]


def test_deleting_account_removes_only_its_messages(app):
    chat_id = ChatDataHandler.create_chat("Name", [1, 2])
    ChatDataHandler.send_message(chat_id, 1, "Deleted account")
    other = ChatDataHandler.send_message(chat_id, 2, "Remaining account")

    assert UserDataHandler.delete_user(1)
    assert [m.id for m in ChatDataHandler.get_messages(chat_id, 0, 10)] == [other.id]

