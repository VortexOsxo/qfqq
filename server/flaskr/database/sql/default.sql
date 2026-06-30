DROP TABLE IF EXISTS public.memberships,
public.organizations,
public.invitations,
public.users,
public.passwordRequests CASCADE;

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
    userId INTEGER NOT NULL REFERENCES public.users (id) ON DELETE CASCADE,
    orgId INTEGER NOT NULL REFERENCES public.organizations (id) ON DELETE CASCADE,
    PRIMARY KEY (userId, orgId)
  );

CREATE TABLE
  public.invitations (
    orgId INTEGER NOT NULL REFERENCES public.organizations (id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    roleId INTEGER NOT NULL,
    PRIMARY KEY (orgId, email)
  );

CREATE TABLE
  public.passwordRequests (
    email TEXT REFERENCES users (email),
    code TEXT,
    date TEXT,
    PRIMARY KEY (email)
  );