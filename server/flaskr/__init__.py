import os
from dotenv import load_dotenv
from flask import Flask

from .database import init_db
from .blueprints import register_blueprints, get_api_version

def create_app(config_name='development'):
    load_dotenv()

    app = Flask(__name__)

    app.config.from_mapping(
        SECRET_KEY='dev',
    )
    
    if config_name == "testing":
        app.config["DATABASE_URL"] = "postgresql://postgres:user@localhost:5432/qfqq_test"
    else:
        app.config["DATABASE_URL"] = os.environ.get("DB_URL")

    register_blueprints(app)
    app.before_request(get_api_version)
    init_db(app)

    return app