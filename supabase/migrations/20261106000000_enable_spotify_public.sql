-- Spotify is part of the public app: statistics, musical affinity and
-- personalised events are available to every user who connects Spotify.
-- The row remains the backend kill-switch (set enabled=false to pause again;
-- the pause triggers in 20261013000002 then stop every Spotify write).
-- Deploy together with the Edge secret SPOTIFY_ENABLED=true.
BEGIN;
UPDATE public.launch_features SET enabled = true WHERE feature = 'spotify';
COMMIT;
