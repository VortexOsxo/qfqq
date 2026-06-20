import json

class MeetingHandler:
    rooms = {}

    def __init__(self, websocket):
        self.websocket = websocket
        self.joined = None

    async def on_event(self, event):
        match event["type"]:
            case "join":
                self._leave()

                self._join(event["code"])
                
            case "leave":
                self._leave()
                
            case "decision":
                await self._decision()
            
    def on_disconnect(self):
        self._leave()

    async def _decision(self):
        room = self.rooms[self.joined]
        for ws in room:
            if ws is self.websocket:
                continue
            await ws.send(json.dumps({"handler": "meeting", "type": "decision"}))

    def _join(self, code):
        if code not in self.rooms:
            self.rooms[code] = [] # Set instead of list ?
        
        self.rooms[code].append(self.websocket) # Verify that it's not present before adding ?
        self.joined = code

    def _leave(self):
        if self.joined is not None:
            self.rooms[self.joined].remove(self.websocket)
            self.joined = None