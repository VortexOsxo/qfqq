from flaskr.database import OrganizationDataHandler


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

    OrganizationDataHandler.delete_invite("random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId is None