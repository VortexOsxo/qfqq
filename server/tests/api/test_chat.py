import pytest

from flaskr.database import ChatDataHandler
from flaskr.database.postgres import read_query, write_query
from tests.api.utils import get_auth_headers


@pytest.fixture
def chat_id():
    return ChatDataHandler.create_chat("Test chat", [1, 2])


@pytest.fixture
def chat_messages(chat_id):
    first = ChatDataHandler.send_message(chat_id, 1, "First")
    second = ChatDataHandler.send_message(chat_id, 2, "Second")
    return first, second


def test_create_chat_adds_creator_and_participants(client):
    response = client.post(
        "/chats", json={"chatName": "Test chat", "userIds": [2]}, headers=get_auth_headers(client)
    )
    assert response.status_code == 201
    chat_id = response.json["id"]
    assert read_query(
        "SELECT userId FROM chatsUsers WHERE chatId = %s ORDER BY userId;",
        (chat_id,),
    ) == [(1,), (2,)]
    assert read_query("SELECT chatName FROM chats WHERE id = %s;", (chat_id,)) == [("Test chat",)]
    response = client.get("/chats", headers=get_auth_headers(client))
    assert response.json == [{"id": chat_id, "chatName": "Test chat"}]


def test_create_chat_does_not_duplicate_creator(client):
    response = client.post(
        "/chats", json={"chatName": "Test chat", "userIds": [1]}, headers=get_auth_headers(client)
    )
    assert response.status_code == 201
    assert read_query(
        "SELECT userId FROM chatsUsers WHERE chatId = %s;", (response.json["id"],)
    ) == [(1,)]

def test_get_chats_returns_only_active_chats_for_user(client):
    active_chat_id = ChatDataHandler.create_chat("Active chat", [1, 2])
    ChatDataHandler.create_chat("Other chat", [2])
    left_chat_id = ChatDataHandler.create_chat("Left chat", [1, 2])
    ChatDataHandler.leave_chat(left_chat_id, 1)

    response = client.get("/chats", headers=get_auth_headers(client, user_id=1))

    assert response.status_code == 200
    assert response.json == [{"id": active_chat_id, "chatName": "Active chat"}]


def test_get_chats_requires_authentication(client):
    assert client.get("/chats").status_code == 401


@pytest.mark.parametrize(("sender_id", "spoofed_sender_id"), [(1, 2), (2, 1)])
def test_send_message_uses_authenticated_sender(client, chat_id, sender_id, spoofed_sender_id):
    response = client.post(
        f"/chats/{chat_id}/messages",
        json={"content": "Hello", "senderId": spoofed_sender_id},
        headers=get_auth_headers(client, user_id=sender_id),
    )
    assert response.status_code == 201
    assert response.json["senderId"] == sender_id
    assert response.json["chatId"] == chat_id
    assert response.json["content"] == "Hello"
    assert response.json["sentAt"]


@pytest.mark.parametrize(
    ("query", "expected_index"),
    [("offset=0&limit=1", 1), ("offset=1&limit=1", 0), ("limit=0", None)],
)
def test_get_messages_pagination(client, chat_id, chat_messages, query, expected_index):
    response = client.get(
        f"/chats/{chat_id}/messages?{query}", headers=get_auth_headers(client)
    )
    assert response.status_code == 200
    expected_ids = [] if expected_index is None else [chat_messages[expected_index].id]
    assert [message["id"] for message in response.json] == expected_ids


def test_leave_chat_marks_participant_as_left(client, chat_id):
    response = client.delete(
        f"/chats/{chat_id}/participants/me", headers=get_auth_headers(client)
    )
    assert response.status_code == 204
    assert read_query(
        "SELECT leftAt IS NOT NULL FROM chatsUsers WHERE chatId = %s AND userId = %s;",
        (chat_id, 1),
    ) == [(True,)]


@pytest.mark.parametrize("methodCode", [("post", 403), ("delete", 204)])
def test_former_participant_cannot_access_chat(client, chat_id, methodCode):
    method, statusCode = methodCode

    ChatDataHandler.leave_chat(chat_id, 1)
    url = f"/chats/{chat_id}/participants/me" if method == "delete" else f"/chats/{chat_id}/messages"
    kwargs = {"headers": get_auth_headers(client)}
    if method == "post":
        kwargs["json"] = {"content": "No"}
    response = getattr(client, method)(url, **kwargs)
    assert response.status_code == statusCode

def test_former_participant_cannot_read_messages(client, chat_id, chat_messages):
    ChatDataHandler.leave_chat(chat_id, 1)
    response = client.get(
        f"/chats/{chat_id}/messages", headers=get_auth_headers(client, user_id=1)
    )
    assert response.status_code == 403


def test_nonparticipant_cannot_read_messages(client, chat_id, chat_messages):
    response = client.get(
        f"/chats/{chat_id}/messages", headers=get_auth_headers(client, user_id=3)
    )
    assert response.status_code == 403


def test_leaving_preserves_messages_for_remaining_participant(client, chat_id, chat_messages):
    ChatDataHandler.leave_chat(chat_id, 1)
    response = client.get(
        f"/chats/{chat_id}/messages", headers=get_auth_headers(client, user_id=2)
    )
    assert response.status_code == 200
    assert [message["id"] for message in response.json] == [
        chat_messages[1].id, chat_messages[0].id
    ]


@pytest.mark.parametrize("user_ids", [None, "2", [True], [0], [1, 1], [999]])
def test_create_chat_rejects_invalid_participants(client, user_ids):
    response = client.post(
        "/chats", json={"chatName": "Test chat", "userIds": user_ids}, headers=get_auth_headers(client)
    )
    assert response.status_code == 400
    assert "userIds" in response.json


def test_create_chat_rejects_users_outside_organization(client):
    write_query("DELETE FROM public.memberships WHERE userId = %s AND orgId = %s;", (2, 1))
    response = client.post(
        "/chats", json={"chatName": "Test chat", "userIds": [2]}, headers=get_auth_headers(client)
    )
    assert response.status_code == 400
    assert read_query("SELECT id FROM chats;") == []


@pytest.mark.parametrize(("chat_name", "status_code"), [
    ("", 400),
    ("x", 201),
    ("x" * 400, 201),
    ("x" * 401, 400),
])
def test_create_chat_name_length(client, chat_name, status_code):
    response = client.post(
        "/chats",
        json={"chatName": chat_name, "userIds": [2]},
        headers=get_auth_headers(client),
    )
    assert response.status_code == status_code
    if status_code == 201:
        assert read_query(
            "SELECT chatName FROM chats WHERE id = %s;", (response.json["id"],)
        ) == [(chat_name,)]
    else:
        assert "chatName" in response.json


@pytest.mark.parametrize("payload", [
    {"userIds": [2]},
    {"chatName": "   ", "userIds": [2]},
    {"chatName": 123, "userIds": [2]},
])
def test_create_chat_rejects_invalid_name(client, payload):
    response = client.post("/chats", json=payload, headers=get_auth_headers(client))
    assert response.status_code == 400
    assert "chatName" in response.json


def test_default_pagination_limits_messages(client, chat_id):
    for index in range(51):
        ChatDataHandler.send_message(chat_id, 1, str(index))

    response = client.get(f"/chats/{chat_id}/messages", headers=get_auth_headers(client))
    assert response.status_code == 200
    messages = response.json
    assert len(messages) == 50
    assert messages[0]["content"] == "50"
    assert messages[-1]["content"] == "1"


def test_get_messages_excludes_other_chats(client, chat_id):
    message = ChatDataHandler.send_message(chat_id, 1, "This chat")
    other_chat_id = ChatDataHandler.create_chat("Other chat", [1])
    ChatDataHandler.send_message(other_chat_id, 1, "Other chat")
    response = client.get(f"/chats/{chat_id}/messages", headers=get_auth_headers(client))
    assert response.status_code == 200
    assert [item["id"] for item in response.json] == [message.id]


def test_get_messages_requires_authentication(client, chat_id):
    assert client.get(f"/chats/{chat_id}/messages").status_code == 401


@pytest.mark.parametrize("methodCode", [("post", 403), ("delete", 204)])
def test_nonparticipant_cannot_access_chat(client, chat_id, methodCode):
    method, statusCode = methodCode

    url = f"/chats/{chat_id}/participants/me" if method == "delete" else f"/chats/{chat_id}/messages"
    kwargs = {"headers": get_auth_headers(client, user_id=3)}
    if method == "post":
        kwargs["json"] = {"content": "No"}
    assert getattr(client, method)(url, **kwargs).status_code == statusCode


def test_nonparticipant_cannot_read_missing_chat(client):
    response = client.get("/chats/999/messages", headers=get_auth_headers(client, user_id=3))
    assert response.status_code == 403


def test_participant_cannot_read_missing_chat(client, chat_id):
    response = client.get(
        f"/chats/{chat_id + 1000}/messages", headers=get_auth_headers(client, user_id=1)
    )
    assert response.status_code == 403


@pytest.mark.parametrize("query", [
    "offset=-1", "limit=-1", "offset=nope", "limit=1.5",
    "offset=9223372036854775808",
])
def test_invalid_pagination(client, query):
    chat_id = ChatDataHandler.create_chat("Test chat", [1])
    response = client.get(
        f"/chats/{chat_id}/messages?{query}", headers=get_auth_headers(client)
    )
    assert response.status_code == 400


@pytest.mark.parametrize("content", [None, "", "  ", 42])
def test_invalid_message_content(client, content):
    chat_id = ChatDataHandler.create_chat("Test chat", [1])
    response = client.post(
        f"/chats/{chat_id}/messages",
        json={"content": content},
        headers=get_auth_headers(client),
    )
    assert response.status_code == 400
    assert "content" in response.json
