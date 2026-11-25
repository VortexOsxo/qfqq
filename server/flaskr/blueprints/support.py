from flask import Blueprint, render_template, request

from flaskr.translations import SUPPORT_COPY

support_bp = Blueprint("support", __name__, url_prefix="/support")


@support_bp.get("")
def get_support():
    language = request.accept_languages.best_match(["fr", "en"], default="fr")
    return render_template(
        "support.html",
        language=language,
        copy=SUPPORT_COPY[language],
    )
