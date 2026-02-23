from src.boto import boto
from src.security_group_manager import security_group_manager


class InstanceManager:

    def __init__(self):
        self._ec2 = boto.ec2
        self.sgm = security_group_manager

    def create_backend_instance(self):
        from .commands import BACKEND_COMMANDS

        backend_sg = self.sgm.create_backend_security_group()

        instances = self._ec2.create_instances(
            ImageId="ami-0ecb62995f68bb549",
            MinCount=1,
            MaxCount=1,
            InstanceType="t3.small",
            SecurityGroupIds=[backend_sg.id],
            UserData=BACKEND_COMMANDS,
            TagSpecifications=[
                {
                    "ResourceType": "instance",
                    "Tags": [{"Key": "Name", "Value": "backend"}],
                }
            ],
            IamInstanceProfile={"Name": "EC2-Read-Decrypt-Ssm"},
        )

        instance = instances[0]
        instance.wait_until_running()
        instance.reload()
        return instance


instance_manager = InstanceManager()
