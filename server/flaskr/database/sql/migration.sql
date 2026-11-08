-- qfqq-128 : Adding a project status
DO $$
BEGIN
    CREATE TYPE projectStatus AS ENUM ('inProgress', 'completed');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END
$$;

ALTER TABLE projects
ADD COLUMN IF NOT EXISTS status projectStatus NOT NULL DEFAULT 'inProgress';