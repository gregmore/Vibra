-- VIBRA Taste Evolution (docs/taste-evolution.md).
--
-- * History is the user's own daily Musical DNA snapshots (kept 400 days by
--   save_musical_dna). Nothing here invents or back-fills history: the
--   comparison uses real snapshots only and reports the dates it used.
-- * privacy_preferences.taste_history (on by default, as before): turning it
--   off deletes past snapshots and keeps only the current DNA from then on.
-- * get_taste_evolution(days): the current snapshot, the baseline (the
--   newest snapshot at least `days` old, or the oldest one there is), a
--   sampled timeline between them, and communities joined since.
BEGIN;

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS taste_history boolean NOT NULL DEFAULT true;

CREATE OR REPLACE FUNCTION public.save_musical_dna(p_user_id uuid, p_dna jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  -- Same lock as Spotify disconnect/sync: a concurrent disconnect wins.
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  IF p_dna IS NULL OR jsonb_typeof(p_dna) = 'null' THEN
    DELETE FROM public.musical_dna_snapshots WHERE user_id = p_user_id;
    RETURN;
  END IF;
  IF jsonb_typeof(p_dna) <> 'object' OR jsonb_typeof(p_dna->'families') <> 'array' THEN
    RAISE invalid_parameter_value USING MESSAGE = 'dna must be an object with families';
  END IF;
  -- Spotify-derived DNA without a music profile means a disconnect won the
  -- race: do not write it back.
  IF COALESCE((p_dna #>> '{sources,spotify}')::boolean, false)
     AND NOT EXISTS (SELECT 1 FROM public.music_profiles WHERE user_id = p_user_id) THEN
    RETURN;
  END IF;
  INSERT INTO public.musical_dna_snapshots AS s (user_id, captured_on, dna, algorithm_version, updated_at)
  VALUES (p_user_id, current_date, p_dna, COALESCE((p_dna->>'version')::smallint, 1), now())
  ON CONFLICT (user_id, captured_on) DO UPDATE
    SET dna = EXCLUDED.dna, algorithm_version = EXCLUDED.algorithm_version, updated_at = now();
  IF COALESCE((SELECT p.taste_history FROM public.privacy_preferences p WHERE p.user_id = p_user_id), true) THEN
    DELETE FROM public.musical_dna_snapshots
    WHERE user_id = p_user_id AND captured_on < current_date - 400;
  ELSE
    -- History off: only the current DNA is kept.
    DELETE FROM public.musical_dna_snapshots
    WHERE user_id = p_user_id AND captured_on < current_date;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.save_musical_dna(uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_musical_dna(uuid, jsonb) TO service_role;

CREATE OR REPLACE FUNCTION public.consume_action_limit(p_action text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE maximum integer; used integer;
BEGIN
  PERFORM public.require_active_session();
  IF auth.uid() IS NULL THEN RAISE SQLSTATE 'PT401' USING MESSAGE='Authentication required'; END IF;
  maximum := CASE p_action
    WHEN 'auth_errors_log' THEN 5 WHEN 'reactions' THEN 60 WHEN 'search-events' THEN 30 WHEN 'resolve-event' THEN 20 WHEN 'upload-image' THEN 10 WHEN 'messages' THEN 30 WHEN 'live_messages' THEN 20
    WHEN 'friendships' THEN 10 WHEN 'follows' THEN 20
    WHEN 'reports' THEN 5 WHEN 'support_reports' THEN 5
    WHEN 'spotify-token-exchange' THEN 10 WHEN 'sync-music-profile' THEN 5
    WHEN 'calculate-match' THEN 10 WHEN 'recommend-events' THEN 30
    WHEN 'track-ticket-click' THEN 30 WHEN 'spotify-disconnect' THEN 5
    WHEN 'delete-account' THEN 3 WHEN 'music-radar' THEN 6
    WHEN 'community-create' THEN 2 WHEN 'community-join' THEN 20 WHEN 'community-post' THEN 5
    WHEN 'community-comment' THEN 10 WHEN 'community-reaction' THEN 60 WHEN 'community-moderate' THEN 30
    WHEN 'circle-create' THEN 2 WHEN 'circle-invite' THEN 10 WHEN 'circle-message' THEN 20
    WHEN 'circle-update' THEN 20
    WHEN 'track-search' THEN 20 WHEN 'vibe-comment' THEN 10 WHEN 'vibe-reaction' THEN 60 WHEN 'discovery' THEN 30
    WHEN 'story-reaction' THEN 60 WHEN 'story-reply' THEN 20 WHEN 'story-view' THEN 120
    WHEN 'story-settings' THEN 30
    WHEN 'feed-reaction' THEN 60 WHEN 'feed-comment' THEN 10 WHEN 'feed-bookmark' THEN 30
    WHEN 'feed-seen' THEN 60 WHEN 'feed-read' THEN 60
    WHEN 'ai-assistant' THEN 6 WHEN 'ai-consent' THEN 10
    WHEN 'discover-artists' THEN 6 WHEN 'artist-feedback' THEN 60
    WHEN 'taste-history' THEN 10
    ELSE NULL END;
  IF maximum IS NULL THEN RAISE invalid_parameter_value USING MESSAGE='Unknown action'; END IF;
  INSERT INTO vibra_private.action_limits AS limits VALUES(auth.uid(),p_action,clock_timestamp(),1)
  ON CONFLICT(user_id,action) DO UPDATE SET
    count = CASE WHEN limits.window_start <= clock_timestamp()-interval '1 minute' THEN 1 ELSE limits.count+1 END,
    window_start = CASE WHEN limits.window_start <= clock_timestamp()-interval '1 minute' THEN clock_timestamp() ELSE limits.window_start END
  RETURNING count INTO used;
  IF used > maximum THEN RAISE SQLSTATE 'PT429' USING MESSAGE='Rate limit exceeded'; END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.consume_action_limit(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.consume_action_limit(text) TO authenticated;

-- Turning history off deletes past snapshots now (the newest one stays as
-- the current DNA). Turning it on starts a new history from today.
CREATE FUNCTION public.set_taste_history(p_enabled boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('taste-history');
  INSERT INTO public.privacy_preferences (user_id, taste_history)
  VALUES (auth.uid(), COALESCE(p_enabled, true))
  ON CONFLICT (user_id) DO UPDATE SET taste_history = EXCLUDED.taste_history, updated_at = now();
  IF NOT COALESCE(p_enabled, true) THEN
    DELETE FROM public.musical_dna_snapshots s
    WHERE s.user_id = auth.uid()
      AND s.captured_on < (SELECT max(x.captured_on) FROM public.musical_dna_snapshots x WHERE x.user_id = auth.uid());
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_taste_history(boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_taste_history(boolean) TO authenticated;

-- The caller's own evolution over the last p_days (30..400).
CREATE FUNCTION public.get_taste_evolution(p_days integer DEFAULT 90)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
DECLARE
  me uuid := auth.uid();
  v_days integer := LEAST(GREATEST(COALESCE(p_days, 90), 30), 400);
  v_current record; v_base record; v_oldest date; v_count integer;
BEGIN
  IF me IS NULL THEN RAISE SQLSTATE 'PT401' USING MESSAGE = 'Authentication required'; END IF;
  SELECT s.captured_on, s.dna INTO v_current FROM public.musical_dna_snapshots s
  WHERE s.user_id = me ORDER BY s.captured_on DESC LIMIT 1;
  SELECT min(s.captured_on), count(*) INTO v_oldest, v_count FROM public.musical_dna_snapshots s WHERE s.user_id = me;
  -- Baseline: the newest snapshot at least p_days before the current one;
  -- if history is shorter, the oldest snapshot (reported as such).
  SELECT s.captured_on, s.dna INTO v_base FROM public.musical_dna_snapshots s
  WHERE s.user_id = me AND s.captured_on <= v_current.captured_on - v_days
  ORDER BY s.captured_on DESC LIMIT 1;
  IF v_base.captured_on IS NULL THEN
    SELECT s.captured_on, s.dna INTO v_base FROM public.musical_dna_snapshots s
    WHERE s.user_id = me AND s.captured_on < v_current.captured_on
    ORDER BY s.captured_on ASC LIMIT 1;
  END IF;
  RETURN jsonb_build_object(
    'tracking', COALESCE((SELECT p.taste_history FROM public.privacy_preferences p WHERE p.user_id = me), true),
    'days', v_days,
    'snapshot_count', COALESCE(v_count, 0),
    'oldest_on', v_oldest,
    'current', CASE WHEN v_current.captured_on IS NULL THEN NULL
      ELSE jsonb_build_object('captured_on', v_current.captured_on, 'dna', v_current.dna) END,
    'baseline', CASE WHEN v_base.captured_on IS NULL THEN NULL
      ELSE jsonb_build_object('captured_on', v_base.captured_on, 'dna', v_base.dna,
        'full_period', v_base.captured_on <= v_current.captured_on - v_days) END,
    -- Up to 12 real snapshots spread between baseline and now (families only).
    'timeline', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('captured_on', y.captured_on, 'families', y.families) ORDER BY y.captured_on)
      FROM (
        SELECT x.*, first_value(x.captured_on) OVER (PARTITION BY x.bucket ORDER BY x.captured_on) AS first_in_bucket
        FROM (
          SELECT s.captured_on, s.dna->'families' AS families,
            ntile(12) OVER (ORDER BY s.captured_on) AS bucket,
            row_number() OVER (ORDER BY s.captured_on DESC) AS newest_rank
          FROM public.musical_dna_snapshots s
          WHERE s.user_id = me AND v_base.captured_on IS NOT NULL
            AND s.captured_on BETWEEN v_base.captured_on AND v_current.captured_on
        ) x
      ) y
      WHERE y.captured_on = y.first_in_bucket OR y.newest_rank = 1
    ), '[]'::jsonb),
    -- Communities joined since the baseline (real join dates).
    'communities', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name, 'genre_family', c.genre_family,
          'joined_at', m.joined_at) ORDER BY m.joined_at DESC)
      FROM public.community_members m JOIN public.communities c ON c.id = m.community_id
      WHERE m.user_id = me AND c.archived_at IS NULL
        AND m.joined_at >= COALESCE(v_base.captured_on, v_current.captured_on, current_date)::timestamptz
    ), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.get_taste_evolution(integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_taste_evolution(integer) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
