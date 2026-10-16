from flaskr.database import ProjectDataHandler


def test_create_projects(app):
    ProjectDataHandler.create_project("project1", "hi", 1)
    project = ProjectDataHandler.get_projects()[0]
    assert project.id == 1
    assert project.status == "inProgress"


def test_get_not_found_project(app):
    project = ProjectDataHandler.get_project_by_id(5)
    assert project is None


def test_update_status(app):
    ProjectDataHandler.create_project("project1", "hi", 1)

    ProjectDataHandler.update_project_status(1, "completed")

    project = ProjectDataHandler.get_project_by_id(1)
    assert project.status == "completed"
