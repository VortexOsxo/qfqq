import asyncio
import json
from flaskr.database.handlers import ChatDataHandler, OrganizationDataHandler

class ChatHandler:
    users = {} # id -> websocket

    def __init__(self, websocket):
        self.websocket = websocket
        self.userId = None

    async def on_event(self, event):
        match event["type"]:
            case "join":
                self._join(event["userId"])

            case "leave":
                self._leave()

            case "sendMessage":
                await self._onMessage(event["chatId"])
            
    def on_disconnect(self):
        self._leave()

    async def _onMessage(self, chatId):
        print("Chatid: ", chatId)
        if self.userId is None:
            return
        orgId = OrganizationDataHandler.get_user_org_id(self.userId)
        userIds = ChatDataHandler.get_active_participants(chatId=chatId, orgId=orgId)

        payload = json.dumps({"handler": "chat", "type": "receiveMessage", "chatId": chatId})
        print(payload)

        sends = []
        for userId in userIds:
            ws = self.users.get(userId)
            if ws is None: continue

            sends.append(ws.send(payload))

        if sends:
            await asyncio.gather(*sends)

    def _join(self, userId):
        self.users[userId] = self.websocket
        self.userId = userId

    def _leave(self):
        if self.userId is not None:
            self.users.pop(self.userId, None)
            self.userId = None