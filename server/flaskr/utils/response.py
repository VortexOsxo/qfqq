from flask import jsonify


def create_auth_response(session_token, refresh_token, user, hasOrg=False, permissions=None):
    return jsonify(
        {
            "session_token": session_token,
            "refresh_token": refresh_token,
            "hasOrg": hasOrg,
        }
        | user.to_dict()
        | (
            {
                "canWrite": permissions[0],
                "canDelete": permissions[1],
                "canUpdatePermissions": permissions[2],
            }
            if permissions is not None
            else {}
        )
    )
