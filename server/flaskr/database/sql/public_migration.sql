DROP TABLE IF EXISTS public.emailVerificationRequests;
CREATE TABLE
  public.emailVerificationRequests (
    email TEXT,
    code TEXT,
    PRIMARY KEY (email)
  );

ALTER TABLE public.passwordRequests
  DROP CONSTRAINT IF EXISTS passwordrequests_email_fkey,
  ADD CONSTRAINT passwordrequests_email_fkey
    FOREIGN KEY (email) REFERENCES public.users (email) ON DELETE CASCADE;

-- Qfqq-171
ALTER TABLE public.organizations
  ADD COLUMN IF NOT EXISTS createdAt TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS isPaying BOOLEAN NOT NULL DEFAULT FALSE;
