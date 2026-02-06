import pytest
from flaskr import create_app
from flaskr.database import create_db, fill_db


@pytest.fixture(scope="session")
def app():
    app = create_app("testing")

    with app.app_context():
        create_db()
        fill_db()

    yield app


@pytest.fixture
def app_ctx(app):
    with app.app_context():
        yield


@pytest.fixture(autouse=True)
def reset_db(app_ctx):
    fill_db()
    yield
