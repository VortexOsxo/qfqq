import os

from src.boto import boto
from src.security_group_manager import security_group_manager


class DatabaseManager:
    def __init__(self):
        self.rds = boto.rds
        self.sgm = security_group_manager

    def create_database(self):
        database_sg = self.sgm.create_database_security_group()

        username = os.getenv('DB_USERNAME')
        password = os.getenv('DB_PASSWORD')
        if username is None or password is None:
            raise Exception('Db username or password not found in env variables')

        try:
            response = self.rds.create_db_instance(
                DBInstanceIdentifier="qfqq-db",
                AllocatedStorage=20,
                DBInstanceClass="db.t3.micro",
                Engine="postgres",
                MasterUsername=username,
                MasterUserPassword=password,
                DBName="qfqq",
                VpcSecurityGroupIds=[database_sg.id],
                PubliclyAccessible=False,
                BackupRetentionPeriod=7,
                MultiAZ=False,
                StorageType="gp2",
                AutoMinorVersionUpgrade=True,
            )

        except self.rds.exceptions.DBInstanceAlreadyExistsFault:
            pass

        waiter = self.rds.get_waiter("db_instance_available")
        waiter.wait(DBInstanceIdentifier="qfqq-db")

        db = self.rds.describe_db_instances(
            DBInstanceIdentifier="qfqq-db"
        )

        endpoint = db["DBInstances"][0]["Endpoint"]["Address"]
        print("Database is ready.")
        print("Endpoint:", endpoint)

        return endpoint
    
database_manager = DatabaseManager()