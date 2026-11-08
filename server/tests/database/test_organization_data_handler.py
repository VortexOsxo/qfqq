from flaskr.database import OrganizationDataHandler
from flaskr.database.postgres import read_query, write_query
from flaskr.models.data.invitation import Invitation

def test_create_organization(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    assert orgId == 3

def test_create_organization_defaults(app):
    before_creation = read_query("SELECT clock_timestamp();")[0][0]
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    createdAt, isPaying = read_query(
        "SELECT createdAt, isPaying FROM public.organizations WHERE id = %s;",
        (orgId,),
    )[0]
    after_creation = read_query("SELECT clock_timestamp();")[0][0]

    assert before_creation <= createdAt <= after_creation
    assert isPaying is False


def test_set_is_paying(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")

    OrganizationDataHandler.set_is_paying(orgId, True)

    assert read_query(
        "SELECT isPaying FROM public.organizations WHERE id = %s;",
        (orgId,),
    ) == [(True,)]

    OrganizationDataHandler.set_is_paying(orgId, False)

    assert read_query(
        "SELECT isPaying FROM public.organizations WHERE id = %s;",
        (orgId,),
    ) == [(False,)]


def test_has_access_during_free_trial(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")

    assert OrganizationDataHandler.has_access(orgId) is True


def test_has_access_for_paying_organization_after_trial(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    write_query(
        "UPDATE public.organizations SET createdAt = NOW() - INTERVAL '31 days' "
        "WHERE id = %s;",
        (orgId,),
    )
    OrganizationDataHandler.set_is_paying(orgId, True)

    assert OrganizationDataHandler.has_access(orgId) is True


def test_has_no_access_after_free_trial(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    write_query(
        "UPDATE public.organizations SET createdAt = NOW() - INTERVAL '31 days' "
        "WHERE id = %s;",
        (orgId,),
    )

    assert OrganizationDataHandler.has_access(orgId) is False


def test_get_slugs(app):
    orgId = OrganizationDataHandler.create_organization("Bubbly")
    assert orgId == 3

    orgId = OrganizationDataHandler.create_organization("Avio")
    assert orgId == 4

    slugs = OrganizationDataHandler.get_existing_slugs()
    assert len(slugs) == 4
    assert "bubbly" in slugs
    assert "avio" in slugs
    assert "test" in slugs
    assert "test2" in slugs

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

    OrganizationDataHandler.remove_invite(1, "random@email.com")
    orgId, _ = OrganizationDataHandler.check_invite("random@email.com")
    assert orgId is None