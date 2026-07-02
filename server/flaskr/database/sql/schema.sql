DROP TABLE IF EXISTS roles,
usersRoles,
usersFCM,
projects,
meetings,
meetingsReviews,
meetingsThemes,
meetingsParticipants,
decisions,
decisionsAssistants CASCADE;

DROP TYPE IF EXISTS meetingStatus,
decisionStatus CASCADE;

CREATE TYPE meetingStatus AS ENUM ('draft', 'planned', 'ongoing', 'completed');

CREATE TYPE decisionStatus AS ENUM ('inProgress', 'cancelled', 'completed');

CREATE TABLE
  roles (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    canWrite BOOLEAN,
    canDelete BOOLEAN,
    canUpdatePermissions BOOLEAN
  );

CREATE TABLE
  usersRoles (
    userId INTEGER PRIMARY KEY REFERENCES users (id),
    roleId INTEGER NOT NULL REFERENCES roles (id)
  );

CREATE TABLE 
  usersFCM (
    userId INTEGER REFERENCES users (id),
    FCM TEXT NOT NULL,
    locale TEXT NOT NULL DEFAULT 'fr',
    PRIMARY KEY (userId)
  );

CREATE TABLE
  projects (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nb INTEGER GENERATED ALWAYS AS IDENTITY,
    title TEXT NOT NULL,
    goals TEXT NOT NULL,
    supervisorId INTEGER REFERENCES users (id)
  );

CREATE TABLE
  meetings (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nb INTEGER GENERATED ALWAYS AS IDENTITY,
    title TEXT NOT NULL,
    goals TEXT,
    status meetingStatus NOT NULL,
    redactionDate DATE NOT NULL,
    meetingDate DATE,
    meetingLocation TEXT,
    animatorId INTEGER REFERENCES users (id),
    projectId INTEGER REFERENCES projects (id) ON DELETE CASCADE,
    nextMeetingId INTEGER REFERENCES meetings (id)
  );

CREATE TABLE
  meetingsThemes (
    meetingId INTEGER REFERENCES meetings (id) ON DELETE CASCADE,
    theme TEXT NOT NULL,
    PRIMARY KEY (meetingId, theme)
  );

CREATE TABLE
  meetingsParticipants (
    meetingId INTEGER REFERENCES meetings (id) ON DELETE CASCADE,
    userId INTEGER REFERENCES users (id),
    PRIMARY KEY (meetingId, userId)
  );

CREATE TABLE
  meetingsReviews (
    -- Could reference a participant instead ?
    meetingId INTEGER REFERENCES meetings (id) ON DELETE CASCADE,
    userId INTEGER REFERENCES users (id),

    isAnonymous BOOLEAN NOT NULL,
    objective INTEGER NOT NULL,
    smoothRunning INTEGER NOT NULL,
    preparation INTEGER NOT NULL,
    length INTEGER NOT NULL,
    respect INTEGER NOT NULL,

    comments TEXT NOT NULL,

    PRIMARY KEY (meetingId, userId)
  );

CREATE VIEW
  meetingsComplete AS
SELECT
  m.*,
  mp.participantsIds,
  mt.themes
FROM
  meetings m
  LEFT JOIN (
    SELECT
      meetingId,
      array_agg (userId) AS participantsIds
    FROM
      meetingsParticipants
    GROUP BY
      meetingId
  ) mp ON mp.meetingId = m.id
  LEFT JOIN (
    SELECT
      meetingId,
      array_agg (theme) AS themes
    FROM
      meetingsThemes
    GROUP BY
      meetingId
  ) mt ON mt.meetingId = m.id;

CREATE TABLE
  decisions (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nb INTEGER GENERATED ALWAYS AS IDENTITY,
    description TEXT NOT NULL,
    status decisionStatus NOT NULL,
    initialDate DATE NOT NULL,
    dueDate DATE,
    completedDate DATE,
    responsibleId INTEGER REFERENCES users (id),
    meetingId INTEGER REFERENCES meetings (id) ON DELETE CASCADE
  );

CREATE TABLE
  decisionsAssistants (
    decisionId INTEGER REFERENCES decisions (id) ON DELETE CASCADE,
    userId INTEGER REFERENCES users (id),
    PRIMARY KEY (decisionId, userId)
  );

CREATE VIEW
  decisionsComplete AS
SELECT
  d.*,
  da.assistantsIds,
  m.projectId
FROM
  decisions d
  LEFT JOIN (
    SELECT
      decisionId,
      array_agg (userId) as assistantsIds
    FROM
      decisionsAssistants
    GROUP BY
      decisionId
  ) da ON da.decisionId = d.id
  JOIN meetings m on m.id = d.meetingId;

INSERT INTO
  roles (name, canWrite, canDelete, canUpdatePermissions)
VALUES
  ('default', true, false, false),
  ('admin', true, true, true);