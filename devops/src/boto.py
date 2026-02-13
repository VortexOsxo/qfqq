import os
import boto3
from dotenv import load_dotenv

load_dotenv()


class Boto():
    def __init__(self):
        self.session, self.ec2 = self.create_session()

    def create_session(self):
        session = boto3.Session(
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
            region_name="us-east-1",
        )
        ec2 = session.resource("ec2")
        return session, ec2

boto = Boto()