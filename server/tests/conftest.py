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

@pytest.fixture()
def client(app):
    return app.test_client()


@pytest.fixture()
def runner(app):
    return app.test_cli_runner()

@pytest.fixture(autouse=True)
def reset_db(app):
    fill_db()
    yield
