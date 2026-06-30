from datetime import datetime, timedelta, timezone

from flaskr.database import NotificationJobDataHandler
from flaskr.models import NotificationJob

# Org 1 exists from the mock data seed; meeting id=1 is used as a stand-in targetId.
ORG_ID = 1
TARGET_ID = 1
JOB_TYPE = "meeting_start"
PAYLOAD = '{"meetingId": 1}'


def make_job(orgId = None, scheduledAt: datetime = None) -> NotificationJob | None:
    return NotificationJobDataHandler.create_notification_job(
        orgId=orgId or ORG_ID,
        targetId=TARGET_ID,
        type=JOB_TYPE,
        payload=PAYLOAD,
        scheduledAt=scheduledAt or datetime.now(timezone.utc),
    )


# ---------------------------------------------------------------------------
# create_notification_job
# ---------------------------------------------------------------------------

def test_create_job_returns_notification_job(app):
    scheduled = datetime.now(timezone.utc) + timedelta(hours=1)
    job = make_job(scheduledAt=scheduled)

    assert isinstance(job, NotificationJob)
    assert job.id is not None
    assert job.orgId == ORG_ID
    assert job.targetId == TARGET_ID
    assert job.type == JOB_TYPE
    assert job.payload == PAYLOAD
    assert job.sentAt is None


def test_create_job_with_invalid_org_returns_none(app):
    scheduled = datetime.now(timezone.utc) + timedelta(hours=1)
    job = NotificationJobDataHandler.create_notification_job(
        orgId=9999,
        targetId=TARGET_ID,
        type=JOB_TYPE,
        payload=PAYLOAD,
        scheduledAt=scheduled,
    )

    assert job is None


# ---------------------------------------------------------------------------
# get_pending_jobs
# ---------------------------------------------------------------------------

def test_get_pending_jobs_returns_due_jobs(app):
    past = datetime.now(timezone.utc) - timedelta(minutes=5)
    make_job(scheduledAt=past)

    jobs = NotificationJobDataHandler.get_pending_jobs()

    assert len(jobs) == 1
    assert all(isinstance(j, NotificationJob) for j in jobs)


def test_get_pending_jobs_excludes_future_jobs(app):
    future = datetime.now(timezone.utc) + timedelta(hours=2)
    make_job(scheduledAt=future)

    jobs = NotificationJobDataHandler.get_pending_jobs()

    assert len(jobs) == 0


def test_get_pending_jobs_excludes_already_sent(app):
    past = datetime.now(timezone.utc) - timedelta(minutes=5)
    job = make_job(scheduledAt=past)
    NotificationJobDataHandler.mark_as_sent(job.id)

    jobs = NotificationJobDataHandler.get_pending_jobs()

    assert len(jobs) == 0


def test_get_pending_jobs_ordered_by_scheduled_at(app):
    now = datetime.now(timezone.utc)
    make_job(scheduledAt=now - timedelta(minutes=30))
    make_job(scheduledAt=now - timedelta(minutes=10))
    make_job(scheduledAt=now - timedelta(minutes=20))

    jobs = NotificationJobDataHandler.get_pending_jobs()

    scheduled_times = [j.scheduledAt for j in jobs]
    assert scheduled_times == sorted(scheduled_times)


# ---------------------------------------------------------------------------
# get_jobs_by_target
# ---------------------------------------------------------------------------

def test_get_jobs_by_target(app):
    make_job(scheduledAt=datetime.now(timezone.utc) + timedelta(hours=1))
    make_job(scheduledAt=datetime.now(timezone.utc) + timedelta(hours=2))

    jobs = NotificationJobDataHandler.get_jobs_by_target(ORG_ID, TARGET_ID, JOB_TYPE)

    assert len(jobs) == 2
    assert all(j.targetId == TARGET_ID for j in jobs)
    assert all(j.type == JOB_TYPE for j in jobs)

def test_get_jobs_by_target_exclude_other_org(app):
    make_job(scheduledAt=datetime.now(timezone.utc) + timedelta(hours=1))
    make_job(scheduledAt=datetime.now(timezone.utc) + timedelta(hours=2))
    make_job(orgId=2, scheduledAt=datetime.now(timezone.utc) + timedelta(hours=2))

    jobs = NotificationJobDataHandler.get_jobs_by_target(ORG_ID, TARGET_ID, JOB_TYPE)

    assert len(jobs) == 2
    assert all(j.targetId == TARGET_ID for j in jobs)
    assert all(j.type == JOB_TYPE for j in jobs)

def test_get_jobs_by_target_wrong_type_returns_empty(app):
    make_job(datetime.now(timezone.utc) + timedelta(hours=1))

    jobs = NotificationJobDataHandler.get_jobs_by_target(ORG_ID, TARGET_ID, "decision_due")
    assert len(jobs) == 0


def test_get_jobs_by_target_not_found_returns_empty(app):
    jobs = NotificationJobDataHandler.get_jobs_by_target(ORG_ID, 9999, JOB_TYPE)
    assert len(jobs) == 0


# ---------------------------------------------------------------------------
# update_job
# ---------------------------------------------------------------------------

def test_update_job_replaces_data(app):
    job = make_job(scheduledAt=datetime.now(timezone.utc) + timedelta(hours=1))

    new_scheduled = datetime.now(timezone.utc) + timedelta(hours=5)
    updated = NotificationJob(
        id=job.id,
        orgId=ORG_ID,
        targetId=2,
        type="decision_due",
        payload='{"decisionId": 2}',
        scheduledAt=new_scheduled,
        sentAt=None,
    )

    result = NotificationJobDataHandler.update_job(job.id, updated)
    assert result is True

    jobs = NotificationJobDataHandler.get_jobs_by_target(ORG_ID, 2, "decision_due")
    assert len(jobs) == 1
    assert jobs[0].targetId == 2
    assert jobs[0].type == "decision_due"
    assert jobs[0].payload == '{"decisionId": 2}'


def test_update_job_not_found_returns_true(app):
    # write_query doesn't raise on 0 rows affected, so we just expect no crash
    dummy = NotificationJob(
        id=9999,
        orgId=ORG_ID,
        targetId=TARGET_ID,
        type=JOB_TYPE,
        payload=PAYLOAD,
        scheduledAt=datetime.now(timezone.utc),
        sentAt=None,
    )
    result = NotificationJobDataHandler.update_job(9999, dummy)
    assert result is True


# ---------------------------------------------------------------------------
# mark_as_sent / mark_many_as_sent
# ---------------------------------------------------------------------------

def test_mark_as_sent(app):
    job = make_job(scheduledAt=datetime.now(timezone.utc) - timedelta(minutes=1))

    NotificationJobDataHandler.mark_as_sent(job.id)

    pending = NotificationJobDataHandler.get_pending_jobs()
    assert all(j.id != job.id for j in pending)


def test_mark_as_sent_with_explicit_timestamp(app):
    job = make_job(scheduledAt=datetime.now(timezone.utc) - timedelta(minutes=1))
    sent_time = datetime(2026, 1, 1, 12, 0, 0, tzinfo=timezone.utc)

    NotificationJobDataHandler.mark_as_sent(job.id, sentAt=sent_time)

    # Job should no longer appear in pending
    pending = NotificationJobDataHandler.get_pending_jobs()
    assert all(j.id != job.id for j in pending)


def test_mark_many_as_sent(app):
    now = datetime.now(timezone.utc)
    job1 = make_job(scheduledAt=now - timedelta(minutes=5))
    job2 = make_job(scheduledAt=now - timedelta(minutes=3))
    job3 = make_job(scheduledAt=now - timedelta(minutes=1))

    NotificationJobDataHandler.mark_many_as_sent([job1.id, job2.id])

    pending = NotificationJobDataHandler.get_pending_jobs()
    pending_ids = [j.id for j in pending]
    assert job1.id not in pending_ids
    assert job2.id not in pending_ids
    assert job3.id in pending_ids

