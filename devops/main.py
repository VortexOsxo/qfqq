from src.instance_manager import instance_manager as im
from src.database_manager import database_manager as dm
from src.parameter_manager import parameter_manager as pm

instance = im.create_backend_instance()
print(instance.public_ip_address, instance.private_ip_address)

# dm.create_database()

# import os
# pm.get_database_url()