import os
from dotenv import load_dotenv
from flask import Flask
from .database import init_db

from .blueprints import *

def create_app(test_config=None):
    load_dotenv()

    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    app.config.from_pyfile('config.py', silent=True)

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    app.register_blueprint(auth_bp)

    init_db(app)

    return app