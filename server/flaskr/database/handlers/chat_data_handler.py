from flaskr.models import Message
from ..postgres import get_db_access, read_query
from psycopg import sql

class ChatDataHandler:
    @classmethod
    def create_direct_chat(cls, chatName: str, userIds: list[int]) -> tuple[int, bool]:
        firstUserId, secondUserId = sorted(userIds)
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute("SELECT pg_advisory_xact_lock(%s, %s);", (firstUserId, secondUserId))
            cur.execute(
                "SELECT c.id FROM chats c "
                "JOIN chatsUsers firstUser ON firstUser.chatId = c.id "
                "JOIN chatsUsers secondUser ON secondUser.chatId = c.id "
                "WHERE firstUser.userId = %s AND secondUser.userId = %s "
                "AND firstUser.leftAt IS NULL AND secondUser.leftAt IS NULL "
                "AND (SELECT COUNT(*) FROM chatsUsers WHERE chatId = c.id) = 2 "
                "ORDER BY c.id LIMIT 1;",
                (firstUserId, secondUserId),
            )
            existing = cur.fetchone()
            if existing:
                return existing[0], False

            cur.execute(
                "INSERT INTO chats (chatName) VALUES (%s) RETURNING id;",
                (chatName,),
            )
            chatId = cur.fetchone()[0]
            cur.executemany(
                "INSERT INTO chatsUsers (chatId, userId) VALUES (%s, %s);",
                [(chatId, userId) for userId in userIds],
            )
            return chatId, True

    @classmethod
    def create_chat(cls, chatName: str, userIds: list[int]) -> int:
        with get_db_access() as conn:
            cur = conn.cursor()
            cur.execute("INSERT INTO chats (chatName) VALUES (%s) RETURNING id;", (chatName,))
            chatId = cur.fetchone()[0]
            cur.executemany(
                "INSERT INTO chatsUsers (chatId, userId) VALUES (%s, %s);",
                [(chatId, userId) for userId in userIds],
            )
        return chatId

    @classmethod
    def get_chats(cls, userId: int) -> list[tuple[int, str]]:
        rows = read_query(
            "SELECT c.id, COALESCE(otherUser.firstName || ' ' || otherUser.lastName, c.chatName) FROM chats c "
            "JOIN chatsUsers cu ON cu.chatId = c.id "
            "LEFT JOIN chatsUsers otherParticipant ON otherParticipant.chatId = c.id "
            "AND (SELECT COUNT(*) FROM chatsUsers participants WHERE participants.chatId = c.id) = 2 "
            "AND otherParticipant.userId <> cu.userId "
            "LEFT JOIN public.users otherUser ON otherUser.id = otherParticipant.userId "
            "WHERE cu.userId = %s AND cu.leftAt IS NULL ORDER BY c.id;",
            (userId,),
        )
        return rows

    @classmethod
    def leave_chat(cls, chatId: int, userId: int) -> bool:
        with get_db_access() as conn:
            result = conn.execute(
                "UPDATE chatsUsers SET leftAt = NOW() "
                "WHERE chatId = %s AND userId = %s AND leftAt IS NULL "
                "AND (SELECT COUNT(*) FROM chatsUsers participants WHERE participants.chatId = %s) <> 2;",
                (chatId, userId, chatId),
            )
            if result.rowcount:
                return True
            blocked = conn.execute(
                "SELECT 1 FROM chatsUsers WHERE chatId = %s AND userId = %s AND leftAt IS NULL "
                "AND (SELECT COUNT(*) FROM chatsUsers participants WHERE participants.chatId = %s) = 2;",
                (chatId, userId, chatId),
            ).fetchone()
            return blocked is None

    @classmethod
    def is_active_participant(cls, chatId: int, userId: int) -> bool:
        return bool(read_query(
            "SELECT 1 FROM chatsUsers WHERE chatId = %s AND userId = %s AND leftAt IS NULL;",
            (chatId, userId),
        ))

    @classmethod
    def get_active_participants(cls, chatId, orgId=None) -> list[int]:
        query = "SELECT userId from chatsUsers WHERE chatId = %s AND leftAt IS NULL;"

        with get_db_access() as conn:
            cur = conn.cursor()

            if orgId is not None:
                cur.execute(sql.SQL("SET search_path TO {}, public;").format(sql.Identifier(str(orgId))))

            cur.execute(query, (chatId,))
            results = cur.fetchall()

        return [result[0] for result in results]

    @classmethod
    def send_message(cls, chatId: int, senderId: int, content: str) -> Message:
        if not cls.is_active_participant(chatId, senderId):
            raise ValueError("Sender is not an active participant in this chat")

        with get_db_access() as conn:
            insert_query = "INSERT INTO messages (chatId, senderId, content) VALUES (%s, %s, %s) RETURNING id, sentAt;"
            cur = conn.execute(insert_query, (chatId, senderId, content))
            id, sentAt = cur.fetchone()
        return Message(id=id, chatId=chatId, senderId=senderId, content=content, sentAt=sentAt)


    @classmethod
    def get_messages(cls, chatId: int, offset: int, limit: int) -> list[Message]:
        if offset < 0 or limit < 0:
            raise ValueError("Offset and limit must be non-negative")

        rows = read_query(
            "SELECT id, chatId, senderId, content, sentAt FROM messages "
            "WHERE chatId = %s ORDER BY sentAt DESC, id DESC LIMIT %s OFFSET %s;",
            (chatId, limit, offset),
        )
        return [Message(*row) for row in rows]
