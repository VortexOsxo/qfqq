from flask import jsonify


def create_auth_response(token, user, hasOrg=False, permissions=None):
    return jsonify(
        {"session_token": token, "hasOrg": hasOrg}
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
