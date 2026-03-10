BEGIN;

-- Clear existing data and reset identities for a clean slate
TRUNCATE TABLE
  decisionsAssistants,
  decisions,
  meetingsParticipants,
  meetingsThemes,
  meetings,
  projects,
  users
RESTART IDENTITY CASCADE;

-- Users
INSERT INTO users (firstName, lastName, passwordHash, email) VALUES
  ('Alice', 'Smith', 'passhash_alice', 'alice@example.com'),
  ('Bob', 'Jones', 'passhash_bob', 'bob@example.com'),
  ('Carol', 'Davis', 'passhash_carol', 'carol@example.com'),
  ('Dave', 'Wilson', 'passhash_dave', 'dave@example.com');

-- Projects
INSERT INTO projects (title, goals, supervisorId) VALUES
  ('Apollo', 'Create prototype for feature X', (SELECT id FROM users WHERE email='alice@example.com')),
  ('Beacon', 'Improve onboarding flow', (SELECT id FROM users WHERE email='bob@example.com'));

-- Meetings
INSERT INTO meetings (title, goals, status, redactionDate, meetingDate, meetingLocation, animatorId, projectId) VALUES
  ('Apollo Kickoff', 'Discuss scope and milestones', 'planned', '2025-11-01', '2025-11-10', 'Room 101', (SELECT id FROM users WHERE email='alice@example.com'), (SELECT id FROM projects WHERE title='Apollo')),
  ('Sprint Review', 'Review last sprint results', 'completed', '2025-12-05', '2025-12-06', 'Zoom', (SELECT id FROM users WHERE email='bob@example.com'), (SELECT id FROM projects WHERE title='Beacon')),
  ('Design Sync', 'Align on UI patterns', 'draft', '2026-01-10', NULL, 'Room 202', (SELECT id FROM users WHERE email='carol@example.com'), (SELECT id FROM projects WHERE title='Apollo'));

-- Meeting themes
INSERT INTO meetingsThemes (meetingId, theme) VALUES
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), 'Scope'),
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), 'Timeline'),
  ((SELECT id FROM meetings WHERE title='Sprint Review'), 'Retrospective'),
  ((SELECT id FROM meetings WHERE title='Design Sync'), 'UI'),
  ((SELECT id FROM meetings WHERE title='Design Sync'), 'Accessibility');

-- Meeting participants
INSERT INTO meetingsParticipants (meetingId, userId) VALUES
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), (SELECT id FROM users WHERE email='alice@example.com')),
  ((SELECT id FROM meetings WHERE title='Apollo Kickoff'), (SELECT id FROM users WHERE email='carol@example.com')),
  ((SELECT id FROM meetings WHERE title='Sprint Review'), (SELECT id FROM users WHERE email='bob@example.com')),
  ((SELECT id FROM meetings WHERE title='Sprint Review'), (SELECT id FROM users WHERE email='dave@example.com')),
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
