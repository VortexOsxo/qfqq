
-- qfqq-128 : Adding a project status
CREATE TYPE projectStatus AS ENUM ('inProgress', 'completed');

ALTER TABLE projects
ADD COLUMN status projectStatus NOT NULL DEFAULT 'inProgress';