/*
  Vibra — Onboarding Migration
  - Adds fields to track onboarding wizard progress.
*/

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS onboarding_completed boolean not null default false;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS onboarding_step text;

-- Recreate view to include the new fields, though usually view has to be dropped and recreated
DROP VIEW IF EXISTS public.users_public CASCADE;

CREATE VIEW public.users_public
WITH (security_invoker = true)
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

REVOKE ALL ON TABLE public.users_public FROM public;
GRANT SELECT ON TABLE public.users_public TO authenticated;
