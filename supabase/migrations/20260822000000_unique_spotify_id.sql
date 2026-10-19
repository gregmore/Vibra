-- Migration 20260822000000: Enforce unique spotify_id per user account
-- Ensures that a Spotify account can be linked to at most one Vibra profile.
--
-- Existing duplicates can occur when an account was re-linked. Keep the most
-- recently updated profile and clear the stale link; its owner can link the
-- Spotify account again from the app if needed.

WITH ranked_profiles AS (
  SELECT
    id,
    row_number() OVER (
      PARTITION BY spotify_id
      ORDER BY updated_at DESC NULLS LAST, created_at DESC, id DESC
    ) AS link_rank
  FROM public.users
  WHERE spotify_id IS NOT NULL
)
UPDATE public.users AS profile
SET spotify_id = NULL,
    updated_at = now()
FROM ranked_profiles AS ranked
WHERE profile.id = ranked.id
  AND ranked.link_rank > 1;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_spotify_id_unique
ON public.users (spotify_id)
WHERE spotify_id IS NOT NULL;
