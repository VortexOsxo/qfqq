import os

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

INSTALL_PYTHON_AND_RUN_SERVER_COMMANDS = f"""
apt install -y python3 python3-pip python3-venv
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
pip install gunicorn
venv/bin/gunicorn --workers 4 --bind 0.0.0.0:8000 --access-logfile access.log --error-logfile error.log "flaskr:create_app()" &
"""


BACKEND_COMMANDS = (
    DEFAULT_COMMANDS
    + CLONE_COMMANDS
    + GET_CERTIFICATE
    + CREATE_ENV
    + INSTALL_PYTHON_AND_RUN_SERVER_COMMANDS
)
