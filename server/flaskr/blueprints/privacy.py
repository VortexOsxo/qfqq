from flask import Blueprint, render_template, request, url_for

from flaskr.translations import PRIVACY_POLICY_COPY

privacy_bp = Blueprint("privacy", __name__, url_prefix="/privacy-policy")


@privacy_bp.get("")
def get_privacy_policy():
    language = request.accept_languages.best_match(["fr", "en"], default="fr")
    policy = PRIVACY_POLICY_COPY[language]
    sections = []
    for section in policy["content"].split("\n\n"):
        if section.startswith("## "):
            sections.append({"heading": True, "text": section[3:]})
        else:
            sections.append({"heading": False, "text": section})

    return render_template(
        "privacy_policy.html",
        language=language,
        policy=policy,
        sections=sections,
        account_deletion_url=url_for("auth.account.account_deletion_form"),
    )
