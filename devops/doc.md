# Server commands

## Start the server

1. Activate the virtual environment:

    ```bash
    source venv/bin/activate
    ```

2. Start the Flask application:

    ```bash
    sudo nohup venv/bin/gunicorn --workers 4 --bind 0.0.0.0:443 --certfile=/etc/letsencrypt/live/quifaitquoiquand.com/fullchain.pem --keyfile=/etc/letsencrypt/live/quifaitquoiquand.com/privkey.pem --access-logfile access.log --error-logfile error.log "flaskr:create_app()" &
    ```

3. Start the background scripts:

    ```bash
    nohup python notifications.py &
    ```

    ```bash
    nohup python events.py &
    ```

## Renew the certificate

1. Check the current certificates:

   ```bash
   sudo certbot certificates
   ```

2. Temporarily allow inbound HTTP traffic on port 80 in the AWS security group. Certbot needs to reach the backend over HTTP to verify the certificate.

3. Renew the certificate:

   ```bash
   sudo certbot renew --cert-name quifaitquoiquand.com
   ```
