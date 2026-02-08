from datetime import datetime, timedelta
from flaskr.database import DecisionDataHandler
from flaskr.models import Decision


def test_get_all_decisions(app_ctx):
    decisions = DecisionDataHandler.get_decisions()

    assert len(decisions) == 3
    assert all(isinstance(d, Decision) for d in decisions)


def test_get_decision_by_id(app_ctx):
    decision = DecisionDataHandler.get_decision(1)

    assert isinstance(decision, Decision)
    assert decision.id == 1
    assert decision.description == "Define MVP features"
    assert decision.status == "inProgress"

    assert decision.assistantsIds is not None
    assert 2 in decision.assistantsIds


def test_get_decision_complete(app_ctx):
    decision = DecisionDataHandler.get_decision(2)

    assert decision.description == "Fix login bug"
    assert decision.status == "completed"

    assert str(decision.initialDate) == '2025-12-06'
    assert str(decision.dueDate) == '2025-12-10'
    assert str(decision.completedDate) == '2025-12-09'
    
    assert decision.responsibleId == 4
    assert decision.meetingId == 2


def test_get_decisions_by_responsible(app_ctx):
    decisions = DecisionDataHandler.get_decision_by_responsible(1)

    assert len(decisions) == 1
    assert decisions[0].description == "Define MVP features"
    assert decisions[0].responsibleId == 1
    assert decisions[0].status == "inProgress"


def test_get_decisions_by_notfound_responsible(app_ctx):
    decisions = DecisionDataHandler.get_decision_by_responsible(2)

    assert len(decisions) == 0


def test_get_decisions_by_project(app_ctx):
    decisions = DecisionDataHandler.get_decisions_by_project(1)

    assert len(decisions) == 2
    decisions.sort(key=lambda x: x.description)
    assert decisions[0].description == "Create accessibility checklist"
    assert decisions[1].description == "Define MVP features"

def test_get_decisions_and_responsible_by_project(app_ctx):
    decisions_with_responsibles = DecisionDataHandler.get_decisions_and_responsible_by_project(1)
    decisions = [dr[0] for dr in decisions_with_responsibles]
    responsibles = [dr[1] for dr in decisions_with_responsibles]

    assert len(decisions) == 2
    decisions.sort(key=lambda x: x.description)
    assert decisions[0].description == "Create accessibility checklist"
    assert decisions[1].description == "Define MVP features"

    assert len(responsibles) == len(decisions)
    responsibles.sort()
    assert responsibles[0] == "alice"
    assert responsibles[1] == "carol"

def test_create_decision(app_ctx):
    dueDate = datetime.now() + timedelta(days=7)
    initialDate = datetime.now()

    decision = DecisionDataHandler.create_decision(
        description="Update documentation",
        status="pending",
        dueDate=dueDate,
        responsibleId=1,
        initialDate=initialDate,
        assistantsIds=[2],
        meetingId=1,
    )

    assert decision.description == "Update documentation"
    assert decision.status == "pending"
    assert decision.dueDate == dueDate.date()
    assert decision.responsibleId == 1
    assert decision.initialDate == initialDate.date()
    assert decision.assistantsIds == [2]
    assert decision.meetingId == 1

def test_get_not_found_decision(app_ctx):
    decision = DecisionDataHandler.get_decision(25)
    assert decision is None

def test_get_not_found_decision_by_responsible(app_ctx):
    decisions = DecisionDataHandler.get_decision_by_responsible(25)
    assert len(decisions) == 0

def test_get_decisions_and_responsible_by_meeting(app_ctx):
    decisions_with_responsibles = DecisionDataHandler.get_decisions_and_responsible_by_meeting(1)
    decisions = [dr[0] for dr in decisions_with_responsibles]
    responsibles = [dr[1] for dr in decisions_with_responsibles]

    assert len(decisions) == 1
    assert decisions[0].description == "Define MVP features"

    assert len(responsibles) == len(decisions)
    assert responsibles[0] == "alice"