from flask import Blueprint, jsonify
from flaskr.services.inputs import input_middleware, LambdaBuilder, StringValidator
from flaskr.database import OrganizationDataHandler

organizations_bp = Blueprint("organizations", __name__, url_prefix="/organizations")


@organizations_bp.post("/")
@input_middleware(LambdaBuilder(("organizationName", StringValidator())))
def create_organization(organizationName: str):
    orgSlug = OrganizationDataHandler.create_organization(organizationName)
    if orgSlug is None:
        return "", 400
    return jsonify({"orgSlug": orgSlug}), 201