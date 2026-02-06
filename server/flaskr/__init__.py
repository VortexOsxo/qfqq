import os
from dotenv import load_dotenv
from flask import Flask

from .database import init_db
from .blueprints import register_blueprints

def create_app(config_name='development'):
    load_dotenv()

    app = Flask(__name__)

    app.config.from_mapping(
        SECRET_KEY='dev',
    )
    
    if config_name == "testing":
        app.config["DATABASE_URL"] = "postgresql://postgres:user@localhost:5432/qfqq_test"
        app.config["TESTING"] = True
    else:
        app.config["DATABASE_URL"] = os.environ.get("postgres_uri")

    register_blueprints(app)
    init_db(app)

    return app