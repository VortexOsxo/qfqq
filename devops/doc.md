# Server commands

## Update to a new version
Run these commands from the qfqq/server folder

1. Clone the latest changes:
    ```
    sudo git clone
    ```

2. Stop the systemctl service:
    ```
    sudo systemctl stop qfqq
    ```

3. Update the database if needed:
    ```
    source venv/bin/activate
    flask migrate-db
    ```
4. Update the environment variable if needed:
    TODO

5. Restart the systemctl service:
    ```
    sudo systemctl start qfqq
    ```

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

1. Launch the bash start.sh script to launch the server
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
