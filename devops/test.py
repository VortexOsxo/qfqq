import requests

resp = requests.get(f'http://98.88.250.179:8000/decisions')
print(resp.status_code)