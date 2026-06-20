import asyncio
import json
from websockets.asyncio.server import serve # type: ignore

from meeting_handler import MeetingHandler

rooms = {}

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

if __name__ == "__main__":
    asyncio.run(main())