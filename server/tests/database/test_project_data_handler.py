from flaskr.database import ProjectDataHandler
from flaskr.models import Project

def test_create_projects(app_ctx):
    ProjectDataHandler.create_project(
        'project1', 'hi', 1
    )
    project = ProjectDataHandler.get_projects()[0]
    assert project.id == 1
    
