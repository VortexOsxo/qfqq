DROP TABLE IF EXISTS users,
projects,
meetings,
meetingsThemes,
meetingsParticipants,
decisions,
decisionsAssistants CASCADE;

DROP TYPE IF EXISTS meetingStatus,
decisionStatus CASCADE;

CREATE TYPE meetingStatus AS ENUM ('draft', 'planned', 'completed');

CREATE TYPE decisionStatus AS ENUM (
  'inProgress',
  'cancelled',
  'pending',
  'completed',
  'taskDescription',
  'approved',
  'toBeValidated'
);

CREATE TABLE
  users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT NOT NULL,
    passwordHash TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
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
    projectId INTEGER REFERENCES projects (id)
  );

CREATE TABLE
  meetingsThemes (
    meetingId INTEGER REFERENCES meetings (id),
    theme TEXT NOT NULL,
    PRIMARY KEY (meetingId, theme)
  );

CREATE TABLE
  meetingsParticipants (
    meetingId INTEGER REFERENCES meetings (id),
    userId INTEGER REFERENCES users (id),
    PRIMARY KEY (meetingId, userId)
  );

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
    meetingId INTEGER REFERENCES meetings (id)
  );

CREATE TABLE
  decisionsAssistants (
    decisionId INTEGER REFERENCES decisions (id),
    userId INTEGER REFERENCES users (id),
    PRIMARY KEY (decisionId, userId)
  );