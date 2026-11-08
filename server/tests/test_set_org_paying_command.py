from flaskr.database.postgres import read_query


def test_set_org_paying_command(runner):
    paying_result = runner.invoke(
        args=["set-org-paying", "1", "true"],
    )

    assert paying_result.exit_code == 0
    assert "set to true" in paying_result.output
    assert read_query(
        "SELECT isPaying FROM public.organizations WHERE id = %s;",
        (1,),
    ) == [(True,)]

    not_paying_result = runner.invoke(
        args=["set-org-paying", "1", "false"],
    )

    assert not_paying_result.exit_code == 0
    assert "set to false" in not_paying_result.output
    assert read_query(
        "SELECT isPaying FROM public.organizations WHERE id = %s;",
        (1,),
    ) == [(False,)]


def test_set_org_paying_command_rejects_invalid_status(runner):
    result = runner.invoke(
        args=["set-org-paying", "1", "yes"],
    )

    assert result.exit_code == 2
    assert "Invalid value" in result.output


def test_set_org_paying_command_rejects_missing_organization(runner):
    result = runner.invoke(
        args=["set-org-paying", "2147483647", "true"],
    )

    assert result.exit_code == 1
    assert "Organization 2147483647 was not found." in result.output
