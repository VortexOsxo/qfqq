# Server commands

## Setup the environment variable

1. Create the file in the etc folder:
    ```
    sudo mkdir -p /etc/qfqq
    sudo nano /etc/qfqq/qfqq.env
    ```
    Write the different environment variables into the file and save it.

2. Set the file permissions:

    ```
    sudo chown root:ubuntu /etc/qfqq/qfqq.env
    sudo chmod 640 /etc/qfqq/qfqq.env
    ```

## Setup the systemd service
1. Copy the service file from the repo into etc/:
    ```bash
    sudo cp /home/ubuntu/qfqq/server/qfqq.service /etc/systemd/system/qfqq.service
    ```

2. Give execution access to the start script:
    ```
    sudo chmod +x /home/ubuntu/qfqq/server/start.sh
    ```

3. Reload systemd:
    ```
    sudo systemctl daemon-reload
    ```

4. Enable the qfqq service:
    ```
    sudo systemctl enable --now qfqq
    ```


## Start the server

0. Allow python to bind to the 443 port:
    ```bash
    sudo setcap 'cap_net_bind_service=+ep' "$(readlink -f /usr/bin/python3)"
    ```

    Verify that the permission was granted
    ```bash
    getcap "$(readlink -f /usr/bin/python3)"
    ```

    expected output:
    `/usr/bin/python3.12 cap_net_bind_service=ep`

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
