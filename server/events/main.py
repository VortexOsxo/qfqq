import json
import ssl
import sys

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
    is_dev = "--dev" in sys.argv

    if not is_dev:
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ssl_context.load_cert_chain(
            certfile="/etc/letsencrypt/live/quifaitquoiquand.com/fullchain.pem",
            keyfile="/etc/letsencrypt/live/quifaitquoiquand.com/privkey.pem",
        )
    else:
        ssl_context = None

    async with serve(handler, "", 8001, ssl=ssl_context) as server:
        print(f"Web socket server running in {'dev' if is_dev else 'prod'} mode")
        await server.serve_forever()
