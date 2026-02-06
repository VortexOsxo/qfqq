from flaskr.database import ProjectDataHandler


def test_create_projects(app_ctx):
    ProjectDataHandler.create_project("project1", "hi", 1)
    project = ProjectDataHandler.get_projects()[0]
    assert project.id == 1


def test_get_not_found_user_by_email(app_ctx):
    project = ProjectDataHandler.get_project_by_id(5)
    assert project is None
