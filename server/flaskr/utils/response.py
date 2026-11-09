from flask import jsonify


def create_auth_response(session_token, refresh_token, user, orgStatus=None, permissions=None):
    return jsonify(
        {
            "session_token": session_token,
            "refresh_token": refresh_token,
            "orgStatus": orgStatus,
        }
        | user.to_dict()
        | (
            {
                "contribute": permissions[0],
                "deleteContent": permissions[1],
                "manageTeam": permissions[2],
            }
            if permissions is not None
            else {}
        )
    )
