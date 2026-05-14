DROP TABLE IF EXISTS public.organizations,
public.users CASCADE;

CREATE TABLE
  public.organizations (
    orgSlug TEXT PRIMARY KEY,
    orgName TEXT NOT NULL
  );

CREATE TABLE
  public.users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    orgSlug TEXT NOT NULL,
    FOREIGN KEY (orgSlug) REFERENCES public.organizations (orgSlug) ON DELETE CASCADE
  );