BEGIN;

SET search_path TO "1", public;

-- Clear existing data and reset identities for a clean slate
TRUNCATE TABLE
  decisionsAssistants,
  decisions,
  meetingsParticipants,
  meetingsThemes,
  meetingsReviews,
  meetings,
  projects,
  usersRoles,
  roles,
  users
RESTART IDENTITY CASCADE;

-- Users
INSERT INTO users (firstName, lastName, passwordHash, email) VALUES
  ('Alice', 'Smith', 'passhash_alice', 'alice@example.com'),
  ('Bob', 'Jones', 'passhash_bob', 'bob@example.com'),
  ('Carol', 'Davis', 'passhash_carol', 'carol@example.com'),
  ('Dave', 'Wilson', 'passhash_dave', 'dave@example.com');

--Memberships
INSERT INTO memberships (userId, orgId) VALUES
  ((SELECT id FROM users WHERE email='alice@example.com'), 1),
  ((SELECT id FROM users WHERE email='bob@example.com'), 1),
  ((SELECT id FROM users WHERE email='carol@example.com'), 1),
  ((SELECT id FROM users WHERE email='dave@example.com'), 1);

--Default Roles
INSERT INTO
  roles (name, canWrite, canDelete, canUpdatePermissions)
VALUES
  ('default', true, true, true);

-- Roles
INSERT INTO roles (name, canWrite, canDelete, canUpdatePermissions) VALUES
  ('Admin', true, true, true),
  ('Manager', true, true, false),
  ('Contributor', true, false, false),
  ('Viewer', false, false, false),
  ('Unused', false, false, false);

-- Users Roles
INSERT INTO usersRoles (userId, roleId) VALUES
  ((SELECT id FROM users WHERE email='alice@example.com'), (SELECT id FROM roles WHERE name='Admin')),
  ((SELECT id FROM users WHERE email='bob@example.com'), (SELECT id FROM roles WHERE name='Manager')),
  ((SELECT id FROM users WHERE email='carol@example.com'), (SELECT id FROM roles WHERE name='Contributor')),
  ((SELECT id FROM users WHERE email='dave@example.com'), (SELECT id FROM roles WHERE name='Viewer'));

-- Projects
INSERT INTO projects (title, goals, supervisorId) VALUES
  ('Apollo', 'Create prototype for feature X', (SELECT id FROM users WHERE email='alice@example.com')),
  ('Beacon', 'Improve onboarding flow', (SELECT id FROM users WHERE email='bob@example.com'));

-- Meetings
INSERT INTO meetings (title, goals, status, redactionDate, meetingDate, meetingLocation, animatorId, projectId, nextMeetingId) VALUES
  ('Apollo Kickoff', 'Discuss scope and milestones', 'planned', '2025-11-01', '2025-11-10', 'Room 101', (SELECT id FROM users WHERE email='alice@example.com'), (SELECT id FROM projects WHERE title='Apollo'), null),
  ('Sprint Review 2', 'Review last sprint results', 'completed', '2025-12-06', '2025-12-13', 'Zoom', (SELECT id FROM users WHERE email='bob@example.com'), (SELECT id FROM projects WHERE title='Beacon'), null),
  ('Sprint Review', 'Review last sprint results', 'completed', '2025-12-05', '2025-12-06', 'Zoom', (SELECT id FROM users WHERE email='bob@example.com'), (SELECT id FROM projects WHERE title='Beacon'), 2),
  ('Design Sync', 'Align on UI patterns', 'draft', '2026-01-10', NULL, 'Room 202', (SELECT id FROM users WHERE email='carol@example.com'), (SELECT id FROM projects WHERE title='Apollo'), null);

-- Meeting themes
INSERT INTO meetingsThemes (meetingId, theme) VALUES
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), 'Scope'),
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), 'Timeline'),
  ((SELECT id FROM meetings WHERE title='Sprint Review'), 'Retrospective'),
  ((SELECT id FROM meetings WHERE title='Sprint Review 2'), 'Retrospective'),
  ((SELECT id FROM meetings WHERE title='Design Sync'), 'UI'),
  ((SELECT id FROM meetings WHERE title='Design Sync'), 'Accessibility');

-- Meeting participants
INSERT INTO meetingsParticipants (meetingId, userId) VALUES
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), (SELECT id FROM users WHERE email='alice@example.com')),
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), (SELECT id FROM users WHERE email='carol@example.com')),
  ((SELECT id FROM meetings WHERE title='Sprint Review'), (SELECT id FROM users WHERE email='bob@example.com')),
  ((SELECT id FROM meetings WHERE title='Sprint Review'), (SELECT id FROM users WHERE email='dave@example.com')),
  ((SELECT id FROM meetings WHERE title='Sprint Review 2'), (SELECT id FROM users WHERE email='bob@example.com')),
  ((SELECT id FROM meetings WHERE title='Sprint Review 2'), (SELECT id FROM users WHERE email='dave@example.com')),
  ((SELECT id FROM meetings WHERE title='Design Sync'), (SELECT id FROM users WHERE email='carol@example.com')),
  ((SELECT id FROM meetings WHERE title='Design Sync'), (SELECT id FROM users WHERE email='alice@example.com'));

-- Decisions
INSERT INTO decisions (description, status, initialDate, dueDate, completedDate, responsibleId, meetingId) VALUES
  ('Define MVP features', 'inProgress', '2025-11-10', '2025-12-01', NULL, (SELECT id FROM users WHERE email='alice@example.com'), (SELECT id FROM meetings WHERE title='Apollo Kickoff')),
  ('Fix login bug', 'completed', '2025-12-06', '2025-12-10', '2025-12-09', (SELECT id FROM users WHERE email='dave@example.com'), (SELECT id FROM meetings WHERE title='Sprint Review')),
  ('Create accessibility checklist', 'cancelled', '2026-01-10', '2026-02-01', NULL, (SELECT id FROM users WHERE email='carol@example.com'), (SELECT id FROM meetings WHERE title='Design Sync'));

-- Decision assistants
INSERT INTO decisionsAssistants (decisionId, userId) VALUES
  ((SELECT id FROM decisions WHERE description='Define MVP features'), (SELECT id FROM users WHERE email='bob@example.com')),
  ((SELECT id FROM decisions WHERE description='Fix login bug'), (SELECT id FROM users WHERE email='bob@example.com')),
  ((SELECT id FROM decisions WHERE description='Create accessibility checklist'), (SELECT id FROM users WHERE email='alice@example.com'));

COMMIT;

-- End of mock data
