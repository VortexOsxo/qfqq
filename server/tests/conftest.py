import pytest
from flaskr import create_app
from flaskr.database import create_db, fill_test_db


@pytest.fixture(scope="session")
def app():
    app = create_app("testing")

    with app.app_context():
        create_db()
        fill_test_db()
        yield app

@pytest.fixture()
def client(app):
    return app.test_client()


@pytest.fixture()
def runner(app):
    return app.test_cli_runner()

@pytest.fixture(autouse=True)
def reset_db(app):
    fill_test_db()
    yield


@pytest.fixture(autouse=True)
def request_context(app):
    from flaskr.database.tenant_context import use_tenant

    with app.test_request_context():
        with use_tenant("1"):
            yield
