from src.boto import boto


class ParameterManager:

    def __init__(self):
        self._ssm = boto.ssm

    def set_database_url(self, db_url):
        self._ssm.put_parameter(
            Name="/qfqq/secrets/db-url",
            Value=db_url,
            Type="SecureString",
            Overwrite=True,
        )
    
    def get_database_url(self):
        response = self._ssm.get_parameter(
            Name="/qfqq/secrets/db-url",
            WithDecryption=True
        )

        return response['Parameter']['Value']


parameter_manager = ParameterManager()
