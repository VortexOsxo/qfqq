# Commands


## Run the server:

### Activate the venv:
```source venv/bin/activate```

### Run the different scripts
```sudo nohup venv/bin/gunicorn --workers 4 --bind 0.0.0.0:443 --certfile=/etc/letsencrypt/live/quifaitquoiquand.com/fullchain.pem --keyfile=/etc/letsencrypt/live/quifaitquoiquand.com/privkey.pem --access-logfile access.log --error-logfile error.log "flaskr:create_app()" &```

```nohup python notifications.py &```

```nohup python events.py &```