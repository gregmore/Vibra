-- 1. FIX VULNERABILITY IN USERS_PUBLIC VIEW
-- Previously, it was created with security_invoker = true, which means it runs with the
-- caller's privileges. Since the caller (authenticated user) only has access to their own row
-- in the users table due to RLS, they couldn't see any other user's public profile data.
-- Setting security_invoker = false (the default) allows the view to bypass RLS and return
-- the subset of safe, public columns for all users.

DROP VIEW IF EXISTS public.users_public CASCADE;

CREATE VIEW public.users_public
WITH (security_invoker = false)
AS
SELECT
  id,
  username,
  display_name,
  avatar_url,
  bio,
  spotify_id,
  onboarding_completed,
  onboarding_step,
  created_at,
  updated_at
FROM public.users;

-- Ensure the public can't read it, only authenticated users
REVOKE ALL ON TABLE public.users_public FROM public;
GRANT SELECT ON TABLE public.users_public TO authenticated;
