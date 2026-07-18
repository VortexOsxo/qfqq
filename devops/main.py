from src.instance_manager import instance_manager as im
from src.database_manager import database_manager as dm
from src.parameter_manager import parameter_manager as pm
from src.security_group_manager import security_group_manager as sgm

if __name__ == "__main__":
    sgm.create_backend_security_group()