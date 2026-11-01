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
