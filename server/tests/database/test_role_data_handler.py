from flaskr.database import RoleDataHandler
from flaskr.models import Role


def test_create_role(app):
    role = RoleDataHandler.create_role("SuperAdmin", True, True, True)

    assert role is not None
    assert isinstance(role, Role)
    assert role.name == "SuperAdmin"
    assert role.contribute is True
    assert role.deleteContent is True
    assert role.manageTeam is True

    db_role = RoleDataHandler.get_role(role.id)
    assert db_role == role


def test_create_duplicate_role(app):
    role = RoleDataHandler.create_role("Admin", True, True, True)
    assert role is None


def test_get_role(app):
    role = RoleDataHandler.get_role(3)
    assert role.name == "Manager"
    assert role.contribute is True
    assert role.deleteContent is True
    assert role.manageTeam is False


def test_get_default_role(app):
    role = RoleDataHandler.get_role(1)
    assert role.name == "default"
    assert role.contribute is True
    assert role.deleteContent is True
    assert role.manageTeam is True


def test_get_role_not_found(app):
    role = RoleDataHandler.get_role(999)
    assert role is None


def test_update_role(app):
    role = RoleDataHandler.create_role("Moderator", False, False, False)
    assert role.contribute is False

    RoleDataHandler.update_role(role.id, "contribute", True)
    updated_role = RoleDataHandler.get_role(role.id)
    assert updated_role.contribute is True
    assert updated_role.deleteContent is False
    assert updated_role.manageTeam is False

    RoleDataHandler.update_role(role.id, "deleteContent", True)
    updated_role = RoleDataHandler.get_role(role.id)
    assert updated_role.contribute is True
    assert updated_role.deleteContent is True
    assert updated_role.manageTeam is False


def test_delete_unused_role(app):
    role = RoleDataHandler.create_role("Guest", False, False, False)
    assert role is not None

    result = RoleDataHandler.delete_role(role.id)
    assert result

    deleted_role = RoleDataHandler.get_role(role.id)
    assert deleted_role is None

def test_delete_used_role(app):
    result = RoleDataHandler.delete_role(2)
    assert not result

    deleted_role = RoleDataHandler.get_role(2)
    assert deleted_role is not None

def test_delete_default_role(app):
    result = RoleDataHandler.delete_role(1)
    assert not result

    deleted_role = RoleDataHandler.get_role(1)
    assert deleted_role is not None
