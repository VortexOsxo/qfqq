import os
import boto3
from dotenv import load_dotenv

load_dotenv()

region = 'us-east-1'

class Boto():
    def __init__(self):
        self.session = self.create_session()
        self.ec2 = self.session.resource("ec2")
        self.rds = self.session.client("rds")
        self.ssm = self.session.client("ssm")

    def create_session(self):
        session = boto3.Session(
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
            region_name=region,
        )
        return session

boto = Boto()