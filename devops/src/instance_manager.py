import os

from src.boto import boto
from src.security_group_manager import security_group_manager

class InstanceManager():

    def __init__(self):
        self._ec2 = boto.ec2
        self.sgm = security_group_manager

    def create_backend_instance(self):
        backend_sg = self.sgm.create_backend_security_group()

        instances = self._ec2.create_instances(
            ImageId="ami-0ecb62995f68bb549",
            MinCount=1,
            MaxCount=1,
            InstanceType="t3.small",
            SecurityGroupIds=[backend_sg.id],
            UserData=f"""#!/bin/bash
apt update -y
apt upgrade -y

export DATABASE_URL="{os.getenv("DB_URL")}"

cd /home/ubuntu
git clone https://github.com/VortexOsxo/qfqq.git
cd qfqq/server

apt install -y python3 python3-pip python3-venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

pip install -r requirements.txt
pip install gunicorn
gunicorn --workers 4 --bind 0.0.0.0:8000 --access-logfile access.log --error-logfile error.log "flaskr:create_app()" &
            """,
            TagSpecifications=[
                {
                    "ResourceType": "instance",
                    "Tags": [{"Key": "Name", "Value": "backend"}],
                }
            ],
        )

        instance = instances[0]
        instance.wait_until_running()
        instance.reload()
        return instance
        
instance_manager = InstanceManager()