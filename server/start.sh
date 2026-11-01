#!/bin/bash

cd /home/ubuntu/qfqq/server || exit 1

venv/bin/gunicorn \
    --workers 4 \
    --bind 0.0.0.0:443 \
    --certfile=/etc/letsencrypt/live/quifaitquoiquand.com/fullchain.pem \
    --keyfile=/etc/letsencrypt/live/quifaitquoiquand.com/privkey.pem \
    --access-logfile access.log \
    --error-logfile error.log \
    --capture-output \
    "flaskr:create_app()" &

venv/bin/python events.py &

venv/bin/python notifications.py &

wait -n