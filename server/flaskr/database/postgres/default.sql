DROP TABLE IF EXISTS public.memberships,
public.organizations,
public.users CASCADE;

CREATE TABLE
  public.organizations (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL
  );

CREATE TABLE
  public.users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    passwordHash TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
  );

CREATE TABLE
  public.memberships (
    userId INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    orgId INTEGER NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    PRIMARY KEY (userId, orgId)
  );