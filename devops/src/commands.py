DEFAULT_COMMANDS = """#!/bin/bash
apt update -y
apt upgrade -y
cd /home/ubuntu
"""

CLONE_COMMANDS = """
git clone https://github.com/VortexOsxo/qfqq.git
cd qfqq/server
"""

GET_CERTIFICATE = """mkdir -p /certs
curl https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o /certs/global-bundle.pem
"""

CREATE_ENV = """
snap install aws-cli --classic
DB_URL=$(aws ssm get-parameter \
      --name "/qfqq/secrets/db-url" \
      --with-decryption \
      --region us-east-1 \
      --query "Parameter.Value" \
      --output text)

chown ubuntu:ubuntu .env
echo "DB_URL=$DB_URL" >> .env
"""

INSTALL_PYTHON_AND_RUN_SERVER_COMMANDS = """
apt install -y python3 python3-pip python3-venv
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
pip install gunicorn
sudo nohup venv/bin/gunicorn --workers 4 --bind 0.0.0.0:443 --certfile=/etc/letsencrypt/live/quifaitquoiquand.com/fullchain.pem --keyfile=/etc/letsencrypt/live/quifaitquoiquand.com/privkey.pem --access-logfile access.log --error-logfile error.log "flaskr:create_app()" &
"""

# To give acces to the certificate to our user
"""
sudo apt install acl -y
sudo setfacl -R -m u:ubuntu:rX /etc/letsencrypt/live/
sudo setfacl -R -m u:ubuntu:rX /etc/letsencrypt/archive/
"""


BACKEND_COMMANDS = (
    DEFAULT_COMMANDS
    + CLONE_COMMANDS
    + GET_CERTIFICATE
    + CREATE_ENV
    + INSTALL_PYTHON_AND_RUN_SERVER_COMMANDS
)
