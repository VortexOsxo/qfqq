from src.security_group_manager import security_group_manager as sgm
from src.instance_manager import instance_manager as im

instance = im.create_backend_instance()
print(instance.public_ip_address, instance.private_ip_address)