from flaskr.database import OrganizationDataHandler


def test_create_organization(app):
    orgSlug = OrganizationDataHandler.create_organization("Bubbly")
    assert orgSlug == "bubbly"


def test_create_organization_with_duplicate_name(app):
    orgSlug = OrganizationDataHandler.create_organization("Bubbly")
    assert orgSlug == "bubbly"

    orgSlug = OrganizationDataHandler.create_organization("Bubbly")
    assert orgSlug == "bubbly2"

def test_get_slugs(app):
    orgSlug = OrganizationDataHandler.create_organization("Bubbly")
    assert orgSlug == "bubbly"

    orgSlug = OrganizationDataHandler.create_organization("Avio")
    assert orgSlug == "avio"

    slugs = OrganizationDataHandler.get_existing_slugs()
    assert len(slugs) == 3
    assert "bubbly" in slugs
    assert "avio" in slugs
    assert "test" in slugs

