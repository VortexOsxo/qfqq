from flask import Blueprint, g, jsonify, request

from flaskr.blueprints.before_request import login_required, on_exception
from flaskr.database import ChatDataHandler, UserDataHandler
from flaskr.errors import InputError
from flaskr.services.inputs import IntValidator, LambdaBuilder, StringValidator, TypedListValidator, input_middleware


chats_bp = Blueprint("chats", __name__, url_prefix="/chats")
chats_bp.before_request(login_required)


@chats_bp.get("")
def get_chats():
    chats = ChatDataHandler.get_chats(g.user_id)
    return jsonify([{"id": chatId, "chatName": chatName} for chatId, chatName in chats])


@chats_bp.post("")
@input_middleware(
    LambdaBuilder(
        ("chatName", StringValidator(max_length=400)),
        ("userIds", TypedListValidator(IntValidator(min_value=1), unique_element=True))
    )
)
def create_chat(chatName, userIds):
    allUserIds = {user.id for user in UserDataHandler.get_users(g.org_id)}
    if not set(userIds).issubset(allUserIds):
        return jsonify({"userIds": InputError.ObjectIdNotFound}), 400

    if g.user_id not in userIds:
        userIds = [g.user_id, *userIds]
    chatId = ChatDataHandler.create_chat(chatName, userIds)
    return jsonify({"id": chatId}), 201


@chats_bp.delete("/<int:chatId>/participants/me")
def leave_chat(chatId):
    ChatDataHandler.leave_chat(chatId, g.user_id)
    return "", 204


@chats_bp.post("/<int:chatId>/messages")
@input_middleware(LambdaBuilder(("content", StringValidator())))
@on_exception(statusCode=403)
def send_message(chatId, content):
    message = ChatDataHandler.send_message(chatId, g.user_id, content)
    return jsonify(message.to_dict()), 201


@chats_bp.get("/<int:chatId>/messages")
def get_messages(chatId):
    if not ChatDataHandler.is_active_participant(chatId, g.user_id):
        return "", 403

    try:
        offset = int(request.args.get("offset", "0"))
        limit = int(request.args.get("limit", "50"))
    except ValueError:
        return jsonify({"error": "Offset and limit must be non-negative integers"}), 400

    if not (0 <= offset <= 2**63 - 1 and 0 <= limit <= 2**63 - 1):
        return jsonify({"error": "Offset and limit must be non-negative integers"}), 400

    messages = ChatDataHandler.get_messages(chatId, offset, limit)
    return jsonify([message.to_dict() for message in messages])
