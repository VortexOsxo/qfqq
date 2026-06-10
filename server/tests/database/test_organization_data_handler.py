from flaskr.database import OrganizationDataHandler
from flaskr.models.data.invitation import Invitation

def test_create_organization(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    assert orgId == 2


def test_get_slugs(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    assert orgId == 2

    orgId = OrganizationDataHandler.create_organization("Avio")
    assert orgId == 3

    slugs = OrganizationDataHandler.get_existing_slugs()
    assert len(slugs) == 3
    assert "bubbly" in slugs
    assert "avio" in slugs
    assert "test" in slugs

def test_get_invites(app):
    OrganizationDataHandler.add_invite(1, "random@example.com", 2)
    OrganizationDataHandler.add_invite(1, "random2@example.com")

    invitations = OrganizationDataHandler.get_invites(1)

    assert len(invitations) == 2
    assert all(isinstance(i, Invitation) for i in invitations)

    assert invitations[0].email == "random@example.com"
    assert invitations[0].roleId == 2
    assert invitations[0].orgId == 1

    assert invitations[1].email == "random2@example.com"
    assert invitations[1].roleId == 1
    assert invitations[1].orgId == 1

def test_add_invite(app):
    OrganizationDataHandler.add_invite(1, "random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId == 1

def test_no_invite(app):
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId is None 

def test_delete_invite(app):
    OrganizationDataHandler.add_invite(1, "random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId == 1

    OrganizationDataHandler.delete_email_invite("random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId is None

def test_revoke_invite(app):
    OrganizationDataHandler.add_invite(1, "random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId == 1

    OrganizationDataHandler.revoke_invite(1, "random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId is None