from html import escape

from flask import Blueprint, Response, request


privacy_bp = Blueprint("privacy", __name__, url_prefix="/privacy-policy")

_POLICIES = {
    "en": {
        "title": "Privacy policy",
        "status": "Version 1.0.0 · Last updated 2026-10-25",
        "content": """Qui Fait Quoi Quand ("QFQQ") collects and retains certain personal information necessary to operate the application.

## Information we collect and how we use it

First and last name: used to identify and display users in the application, including when they participate in organizations, projects, or meetings.

Email address: used to allow users to sign in to their account and to uniquely identify them.

Password hash: stored instead of the plaintext password and used to authenticate the account.

Organization membership and roles: used to provide access to organization features and content according to each user's permissions.

User-generated content: information users add to the application is stored so members of the relevant organization can access it later, according to their permissions.

Device token and language preference: used to deliver push notifications to the user's registered device in their selected language.""",
    },
    "fr": {
        "title": "Politique de confidentialité",
        "status": "Version 1.0.0 · Dernière mise à jour 2026-10-25",
        "content": """Qui Fait Quoi Quand (« QFQQ ») collecte et conserve certaines informations personnelles nécessaires au fonctionnement de l'application.

## Informations collectées et utilisation

Nom et prénom : utilisés pour identifier et afficher les utilisateurs dans l'application, notamment lorsqu'ils participent à des organisations, projets ou réunions.

Adresse courriel : utilisée pour permettre la connexion au compte et pour identifier l'utilisateur de manière unique.

Empreinte du mot de passe : conservée plutôt que le mot de passe en texte clair et utilisée pour authentifier le compte.

Appartenance aux organisations et rôles : utilisés pour donner accès aux fonctions et au contenu de l'organisation selon les autorisations de chaque utilisateur.

Contenu créé par les utilisateurs : les informations ajoutées à l'application sont conservées afin que les membres de l'organisation concernée puissent y accéder ultérieurement, selon leurs autorisations.

Jeton d'appareil et préférence linguistique : utilisés pour envoyer des notifications poussées à l'appareil enregistré de l'utilisateur dans la langue choisie.""",
    },
}


@privacy_bp.get("")
def get_privacy_policy():
    language = request.accept_languages.best_match(["fr", "en"], default="fr")
    policy = _POLICIES[language]
    sections = []
    for section in policy["content"].split("\n\n"):
        if section.startswith("## "):
            sections.append(f"<h2>{escape(section[3:])}</h2>")
        else:
            sections.append(f"<p>{escape(section)}</p>")

    page = f"""<!doctype html>
<html lang="{language}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{escape(policy["title"])}</title>
  <style>
    body {{ font-family: system-ui, sans-serif; line-height: 1.6; margin: 2rem auto; max-width: 48rem; padding: 0 1rem; }}
    h1, h2 {{ line-height: 1.25; }}
    .status {{ color: #555; font-size: 0.9rem; }}
  </style>
</head>
<body>
  <main>
    <p>QuiFaitQuoiQuand</p>
    <h1>{escape(policy["title"])}</h1>
    <p class="status">{escape(policy.get("status"))}</p>
    {"".join(sections)}
  </main>
</body>
</html>"""
    return Response(page, mimetype="text/html")
