DROP TABLE IF EXISTS public.notificationJobs CASCADE;

-- Need to delete those when the target is deleted :(
DROP TABLE IF EXISTS public.notificationsTarget CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.notificationOffsets CASCADE;

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
    targetId INTEGER NOT NULL REFERENCES public.notificationsTarget (id) ON DELETE CASCADE
  );

CREATE INDEX ON public.notifications (targetId);
CREATE INDEX ON public.notificationsTarget (orgId);


CREATE TABLE public.notificationOffsets (
  userId INTEGER NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  nOffset INTERVAL NOT NULL,
  isActive BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (userId, type)
);
