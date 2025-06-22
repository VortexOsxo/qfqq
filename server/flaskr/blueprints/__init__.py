from .auth import auth_bp
from .user import users_bp
from .meeting_agenda import meeting_agendas_bp
from .decision import decisions_bp


def register_blueprints(app):
    app.register_blueprint(auth_bp)
    app.register_blueprint(users_bp)
    app.register_blueprint(meeting_agendas_bp)
    app.register_blueprint(decisions_bp)


__all__ = ["register_blueprints"]
