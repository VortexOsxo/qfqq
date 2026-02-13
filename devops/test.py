import requests

resp = requests.get(f'http://98.91.0.154:8000/decisions')
print(resp.status_code)