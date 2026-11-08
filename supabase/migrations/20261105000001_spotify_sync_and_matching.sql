-- Spotify: server-side listening history, scheduled sync, deterministic
-- matching inputs and event genres. See docs/spotify-integration.md.
BEGIN;

-- ── Listening history (heatmap) ───────────────────────────────────────────
-- Spotify's API exposes only the last 50 plays. An hourly worker accumulates
-- them here. Only the play timestamp is kept (no track, device or context):
-- it is all the weekday heatmap needs. Rows expire after 26 weeks and go
-- with the account (CASCADE) or on Spotify disconnect.
CREATE TABLE public.spotify_listening_events (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  played_at timestamptz NOT NULL,
  PRIMARY KEY (user_id, played_at)
);
ALTER TABLE public.spotify_listening_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.spotify_listening_events FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, DELETE ON public.spotify_listening_events TO service_role;
CREATE TRIGGER trg_spotify_listening_launch_feature BEFORE INSERT
ON public.spotify_listening_events FOR EACH ROW EXECUTE FUNCTION public.protect_paused_spotify_write();

-- Last time the worker polled a connection (claim marker; not user-visible).
ALTER TABLE public.spotify_connections ADD COLUMN IF NOT EXISTS last_polled_at timestamptz;

-- Records new plays for an unchanged connection and returns the weekday
-- counts (Mon..Sun, UTC) over the last 12 weeks.
CREATE FUNCTION public.record_spotify_listening(
  p_user_id uuid, p_spotify_user_id text, p_connected_at timestamptz, p_played_at timestamptz[]
)
RETURNS integer[] LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_counts integer[];
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  PERFORM public.require_spotify_feature_enabled();
  PERFORM 1 FROM public.users WHERE id = p_user_id AND spotify_id = p_spotify_user_id FOR UPDATE;
  IF NOT FOUND OR NOT EXISTS (SELECT 1 FROM public.spotify_connections
    WHERE user_id = p_user_id AND spotify_user_id = p_spotify_user_id AND connected_at = p_connected_at) THEN
    RAISE SQLSTATE 'PT409' USING MESSAGE = 'Spotify connection changed or disconnected';
  END IF;
  IF cardinality(COALESCE(p_played_at, '{}')) > 200 THEN
    RAISE invalid_parameter_value USING MESSAGE = 'Too many plays in one batch';
  END IF;
  INSERT INTO public.spotify_listening_events (user_id, played_at)
  SELECT p_user_id, played FROM unnest(COALESCE(p_played_at, '{}')) AS played
  WHERE played > now() - interval '26 weeks' AND played <= now() + interval '5 minutes'
  ON CONFLICT DO NOTHING;
  DELETE FROM public.spotify_listening_events
  WHERE user_id = p_user_id AND played_at <= now() - interval '26 weeks';
  SELECT array_agg(COALESCE(c.count, 0)::integer ORDER BY d.dow) INTO v_counts
  FROM generate_series(1, 7) AS d(dow)
  LEFT JOIN (
    SELECT extract(isodow FROM played_at AT TIME ZONE 'UTC')::integer AS dow, count(*) AS count
    FROM public.spotify_listening_events
    WHERE user_id = p_user_id AND played_at > now() - interval '12 weeks'
    GROUP BY 1
  ) AS c USING (dow);
  RETURN v_counts;
END;
$$;
REVOKE ALL ON FUNCTION public.record_spotify_listening(uuid, text, timestamptz, timestamptz[])
FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_spotify_listening(uuid, text, timestamptz, timestamptz[])
TO service_role;

-- ── Scheduled sync claim ──────────────────────────────────────────────────
-- Claims up to p_limit connections not polled in the last 50 minutes, oldest
-- first, and stamps them so overlapping workers never process the same user.
CREATE FUNCTION public.claim_spotify_sync_batch(p_limit integer DEFAULT 25)
RETURNS TABLE (
  user_id uuid, spotify_user_id text, connected_at timestamptz,
  access_token_ciphertext text, refresh_token_ciphertext text,
  token_expires_at timestamptz, last_synced_at timestamptz
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF NOT public.spotify_feature_enabled() THEN RETURN; END IF;
  RETURN QUERY
  WITH due AS (
    SELECT c.user_id FROM public.spotify_connections c
    WHERE c.last_polled_at IS NULL OR c.last_polled_at < now() - interval '50 minutes'
    ORDER BY c.last_polled_at NULLS FIRST, c.user_id
    LIMIT LEAST(GREATEST(COALESCE(p_limit, 25), 1), 100)
    FOR UPDATE SKIP LOCKED
  ), claimed AS (
    UPDATE public.spotify_connections c SET last_polled_at = now()
    FROM due WHERE c.user_id = due.user_id
    RETURNING c.user_id, c.spotify_user_id, c.connected_at, c.access_token_ciphertext,
      c.refresh_token_ciphertext, c.token_expires_at
  )
  SELECT claimed.user_id, claimed.spotify_user_id, claimed.connected_at,
    claimed.access_token_ciphertext, claimed.refresh_token_ciphertext,
    claimed.token_expires_at, mp.last_synced_at
  FROM claimed LEFT JOIN public.music_profiles mp ON mp.user_id = claimed.user_id;
END;
$$;
REVOKE ALL ON FUNCTION public.claim_spotify_sync_batch(integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_spotify_sync_batch(integer) TO service_role;

-- ── Matching candidates ───────────────────────────────────────────────────
-- Same consent, block and test-segment filters as find_compatible_users, but
-- without the audio-feature embedding Spotify no longer provides.
CREATE FUNCTION public.find_music_match_candidates(p_user_id uuid, p_limit integer DEFAULT 500)
RETURNS TABLE (user_id uuid, top_artists jsonb, top_genres jsonb)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF NOT public.spotify_feature_enabled() THEN RETURN; END IF;
  RETURN QUERY
  SELECT candidate.user_id, candidate.top_artists, candidate.top_genres
  FROM public.music_profiles AS candidate
  JOIN public.users AS candidate_user ON candidate_user.id = candidate.user_id
  JOIN public.users AS target_user ON target_user.id = p_user_id
  WHERE candidate.user_id <> p_user_id
    AND EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = candidate.user_id AND p.spotify_matching)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = p_user_id AND p.spotify_matching)
    AND NOT EXISTS (SELECT 1 FROM public.blocked_users b WHERE
      (b.blocker_id = p_user_id AND b.blocked_id = candidate.user_id) OR
      (b.blocked_id = p_user_id AND b.blocker_id = candidate.user_id))
    AND candidate_user.is_test_user = target_user.is_test_user
  ORDER BY candidate.last_synced_at DESC NULLS LAST, candidate.user_id
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 500), 1), 1000);
END;
$$;
REVOKE ALL ON FUNCTION public.find_music_match_candidates(uuid, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.find_music_match_candidates(uuid, integer) TO service_role;

-- ── Event genres (Ticketmaster classifications) ───────────────────────────
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS genres text[] NOT NULL DEFAULT '{}';

-- ── Disconnect / reconnect also clear listening history ───────────────────
CREATE OR REPLACE FUNCTION public.disconnect_spotify_account(p_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  -- Token refresh and profile sync take this same lock. Once disconnect
  -- commits, an already-running request cannot recreate its derived data.
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;
  UPDATE public.privacy_preferences SET spotify_matching = false, updated_at = now() WHERE user_id = p_user_id;
  DELETE FROM public.user_matches WHERE user_id_a = p_user_id OR user_id_b = p_user_id;
  DELETE FROM public.music_profiles WHERE user_id = p_user_id;
  DELETE FROM public.spotify_listening_events WHERE user_id = p_user_id;
  DELETE FROM public.spotify_connections WHERE user_id = p_user_id;
  UPDATE public.users SET spotify_id = NULL WHERE id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.clear_listening_on_spotify_change()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.spotify_id IS DISTINCT FROM OLD.spotify_id THEN
    DELETE FROM public.spotify_listening_events WHERE user_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.clear_listening_on_spotify_change() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_clear_listening_on_spotify_change AFTER UPDATE OF spotify_id
ON public.users FOR EACH ROW EXECUTE FUNCTION public.clear_listening_on_spotify_change();

-- ── Hourly schedule ───────────────────────────────────────────────────────
-- Reuses the dedicated server-to-server job credential already in Vault for
-- the catalogue worker; nothing is embedded in the function or cron command.
CREATE FUNCTION vibra_private.enqueue_spotify_sync()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE endpoint text; credential text;
BEGIN
  IF NOT public.spotify_feature_enabled() THEN RETURN; END IF;
  SELECT decrypted_secret INTO endpoint FROM vault.decrypted_secrets WHERE name='vibra_functions_url';
  SELECT decrypted_secret INTO credential FROM vault.decrypted_secrets WHERE name='vibra_catalogue_job_secret';
  IF NULLIF(btrim(endpoint), '') IS NULL OR NULLIF(btrim(credential), '') IS NULL THEN RETURN; END IF;
  PERFORM net.http_post(url:=rtrim(endpoint,'/')||'/spotify-sync-worker',
    headers:=jsonb_build_object('Content-Type','application/json','x-vibra-job-secret',credential),
    body:='{}'::jsonb, timeout_milliseconds:=140000);
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.enqueue_spotify_sync() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('invoke-spotify-sync', '17 * * * *', 'SELECT vibra_private.enqueue_spotify_sync();');

NOTIFY pgrst, 'reload schema';
COMMIT;
