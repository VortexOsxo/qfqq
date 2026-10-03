DROP TABLE IF EXISTS public.memberships,
public.organizations,
public.invitations,
public.users,
public.passwordRequests,
public.notificationsTarget,
public.notifications,
public.notificationOffsets CASCADE;

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

-- Need to delete those when the target is deleted :(
CREATE TABLE
  public.notificationsTarget (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    orgId INTEGER NOT NULL REFERENCES public.organizations (id) ON DELETE CASCADE,
    targetId INTEGER NOT NULL,
    type TEXT NOT NULL,
    eventAt TIMESTAMPTZ NOT NULL,
    CONSTRAINT notifications_target_org_target_type_unique UNIQUE (orgId, targetId, type)
  );

CREATE TABLE
  public.notifications (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    userId INTEGER NOT NULL REFERENCES public.users (id) ON DELETE CASCADE,
    targetId INTEGER NOT NULL REFERENCES public.notificationsTarget (id) ON DELETE CASCADE,
    nOffset INTERVAL NOT NULL
  );

CREATE VIEW public.notificationsToSend AS
  SELECT t.orgId as orgId, t.targetId as targetId, t.type as type, n.userId as userId, n.nOffset as nOffset 
  FROM public.notifications n
  JOIN public.notificationsTarget t
  ON n.targetId = t.id
  WHERE t.eventAt - n.nOffset <= NOW();

CREATE INDEX ON notifications (targetId);
CREATE INDEX ON notificationsTarget (orgId);


-- May want to move type to a separate table
CREATE TABLE public.notificationOffsets (
  userId INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  nOffset INTERVAL NOT NULL,
  PRIMARY KEY (userId, type)
);