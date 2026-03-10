import jwt
def get_auth_headers(client, user_id=1):
    app = client.application
    token = jwt.encode({"user_id": user_id}, app.config["SECRET_KEY"], algorithm="HS256")
    return {
        "Authorization": f"Bearer {token}",
        "QfqqVersion": "beta"
    }
