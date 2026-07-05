import json
from websockets.asyncio.server import serve

from .meeting_handler import MeetingHandler

async def handler(websocket):
    handlers = {
        'meeting': MeetingHandler(websocket)
    }

    try:
        async for message in websocket:
            print(f"Received: {message}")
            
            event = json.loads(message)

            handler = handlers.get(event.get('handler', None), None)
            assert handler is not None
            await handler.on_event(event)
                        
    except Exception as e:
        print(e)
    finally:
        for handler in handlers.values():
            handler.on_disconnect()


async def main():
    async with serve(handler, "", 8001) as server:
        print("Server running on ws://localhost:8001")
        await server.serve_forever()
