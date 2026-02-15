from src.instance_manager import instance_manager as im
from src.database_manager import database_manager as dm

instance = im.create_backend_instance()
print(instance.public_ip_address, instance.private_ip_address)

# dm.create_database()