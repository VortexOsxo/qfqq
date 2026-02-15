import botocore.exceptions
from src.boto import boto

ssh_debug_permissions = (
    {
        "IpProtocol": "tcp",
        "FromPort": 22,
        "ToPort": 22,
        "IpRanges": [{"CidrIp": "0.0.0.0/0"}],  # TODO: Use select ips
    },
)


class SecurityGroupManager:
    def __init__(self):
        self._ec2 = boto.ec2
        self._vpc = list(self._ec2.vpcs.all())[0]

        self.backend_sg = None
        self.database_sg = None

    def print_security_groups(self):
        sgs = list(
            self._ec2.security_groups.filter(
                Filters=[
                    {"Name": "vpc-id", "Values": [self._vpc.id]},
                ]
            )
        )
        print("Security Groups:")
        for sg in sgs:
            print(f"\t Id: {sg.id}, Name: {sg.group_name}")

    def create_backend_security_group(self):
        group_name = "backend-sg"
        description = "Security group for Backend (Public Http, Public SSH)"

        # Allows: HTTP (80) from anywhere
        permissions = [
            {
                "IpProtocol": "tcp",
                "FromPort": 8000,
                "ToPort": 8000,
                "IpRanges": [{"CidrIp": "0.0.0.0/0"}],
            },
        ]

        # Allows ssh
        permissions += ssh_debug_permissions

        self.backend_sg = self._get_existing_sg(group_name)
        if not self.backend_sg:
            self.backend_sg = self._ec2.create_security_group(
                GroupName=group_name, Description=description, VpcId=self._vpc.id
            )
            self._add_permissions(self.backend_sg, permissions)
        return self.backend_sg

    def create_database_security_group(self):
        if self.backend_sg is None:
            self.create_backend_security_group()

        group_name = "database-sg"
        description = "Security group for database"

        permissions = [
            {
                "IpProtocol": "tcp",
                "FromPort": 5432,
                "ToPort": 5432,
                "UserIdGroupPairs": [{"GroupId": self.backend_sg.id}],
            }
        ]

        self.database_sg = self._get_existing_sg(group_name)
        if not self.database_sg:
            self.database_sg = self._ec2.create_security_group(
                GroupName=group_name, Description=description, VpcId=self._vpc.id
            )
            self._add_permissions(self.database_sg, permissions)
        return self.database_sg

    def _get_existing_sg(self, group_name):
        sgs = list(
            self._ec2.security_groups.filter(
                Filters=[
                    {"Name": "group-name", "Values": [group_name]},
                    {"Name": "vpc-id", "Values": [self._vpc.id]},
                ]
            )
        )
        return sgs[0] if sgs else None

    def _add_permissions(self, sg, permissions):
        try:
            sg.authorize_ingress(IpPermissions=permissions)
        except botocore.exceptions.ClientError as e:
            if e.response["Error"]["Code"] != "InvalidPermission.Duplicate":
                raise


security_group_manager = SecurityGroupManager()
