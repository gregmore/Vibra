-- VIBRA Music Radar (docs/music-radar.md): people nearby who share your
-- musical taste, built so that no one's location can be extracted.
--
-- Privacy model
-- * Opt-in. Off by default; also requires the existing location consent
--   (privacy_preferences.location_processing). Turning either off removes
--   the user from the radar at once.
-- * Coarse cells. A person's radar position is the CENTRE of a grid cell
--   (~5 km "area" or ~20 km "region", their choice), never their point.
-- * Slow anchor. The point a cell is derived from moves at most once every
--   6 hours, so live movements cannot be followed and faking one's own
--   location to probe others is impractically slow.
-- * Nothing precise leaves the database. get_music_radar returns no
--   coordinates, distances, cells or timestamps, and does not order people by
--   distance. Positions live in vibra_private, which the API cannot reach.
-- * Fixed radii (5/10/25/50 km), a rate limit on queries, and area genre
--   statistics only when at least 5 people contribute.
-- * Hide: radar_visible = false keeps using the radar without appearing.
BEGIN;

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS radar_enabled boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS radar_visible boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS radar_distance_km smallint NOT NULL DEFAULT 25
    CHECK (radar_distance_km IN (5, 10, 25, 50)),
  ADD COLUMN IF NOT EXISTS radar_precision text NOT NULL DEFAULT 'area'
    CHECK (radar_precision IN ('area', 'region'));

-- ── Private positions ─────────────────────────────────────────────────────
CREATE TABLE vibra_private.radar_presence (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  anchor public.geography(Point, 4326) NOT NULL,
  center public.geography(Point, 4326) NOT NULL,
  precision text NOT NULL,
  anchored_at timestamptz NOT NULL,
  located_at timestamptz NOT NULL
);
CREATE INDEX radar_presence_center_gist ON vibra_private.radar_presence USING gist (center);
REVOKE ALL ON vibra_private.radar_presence FROM PUBLIC, anon, authenticated;

-- Centre of the grid cell containing p. Cells are `step` degrees of
-- latitude tall and about as wide in kilometres (longitude step widened by
-- 1/cos(latitude)), so a cell is roughly square everywhere.
CREATE FUNCTION vibra_private.radar_snap(p public.geography, p_precision text)
RETURNS public.geography LANGUAGE plpgsql IMMUTABLE SET search_path = pg_catalog AS $$
DECLARE
  lat double precision := public.ST_Y(p::public.geometry);
  lon double precision := public.ST_X(p::public.geometry);
  step double precision := CASE p_precision WHEN 'region' THEN 0.18 ELSE 0.045 END;
  lat_c double precision;
  lon_step double precision;
  lon_c double precision;
BEGIN
  lat_c := LEAST(GREATEST((floor(lat / step) + 0.5) * step, -89.9), 89.9);
  lon_step := step / GREATEST(cos(radians(lat_c)), 0.05);
  lon_c := (floor((lon + 180) / lon_step) + 0.5) * lon_step - 180;
  lon_c := LEAST(GREATEST(lon_c, -179.999), 179.999);
  RETURN public.ST_SetSRID(public.ST_MakePoint(lon_c, lat_c), 4326)::public.geography;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.radar_snap(public.geography, text) FROM PUBLIC, anon, authenticated;

-- Keeps one user's radar position in line with their settings and their
-- private server location, applying the 6-hour anchor rule.
CREATE FUNCTION vibra_private.radar_refresh(p_user uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_location public.geography;
  v_located_at timestamptz;
  v_enabled boolean;
  v_consent boolean;
  v_precision text;
  v_presence vibra_private.radar_presence%ROWTYPE;
BEGIN
  SELECT u.last_location, COALESCE(u.location_updated_at, now())
    INTO v_location, v_located_at FROM public.users u WHERE u.id = p_user;
  SELECT p.radar_enabled, p.location_processing, p.radar_precision
    INTO v_enabled, v_consent, v_precision
    FROM public.privacy_preferences p WHERE p.user_id = p_user;
  IF NOT COALESCE(v_enabled, false) OR NOT COALESCE(v_consent, false) OR v_location IS NULL THEN
    DELETE FROM vibra_private.radar_presence WHERE user_id = p_user;
    RETURN;
  END IF;
  SELECT * INTO v_presence FROM vibra_private.radar_presence WHERE user_id = p_user FOR UPDATE;
  IF FOUND AND v_presence.anchored_at > now() - interval '6 hours' THEN
    -- Anchor stays; only a precision change re-snaps the same anchor.
    UPDATE vibra_private.radar_presence
      SET center = vibra_private.radar_snap(v_presence.anchor, v_precision), precision = v_precision
      WHERE user_id = p_user;
    RETURN;
  END IF;
  INSERT INTO vibra_private.radar_presence AS r (user_id, anchor, center, precision, anchored_at, located_at)
  VALUES (p_user, v_location, vibra_private.radar_snap(v_location, v_precision), v_precision, now(), v_located_at)
  ON CONFLICT (user_id) DO UPDATE SET
    anchor = EXCLUDED.anchor, center = EXCLUDED.center, precision = EXCLUDED.precision,
    anchored_at = EXCLUDED.anchored_at, located_at = EXCLUDED.located_at;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.radar_refresh(uuid) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION vibra_private.radar_refresh_from_users()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM vibra_private.radar_refresh(NEW.id);
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.radar_refresh_from_users() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_radar_location AFTER UPDATE OF last_location ON public.users
FOR EACH ROW EXECUTE FUNCTION vibra_private.radar_refresh_from_users();

CREATE FUNCTION vibra_private.radar_refresh_from_preferences()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM vibra_private.radar_presence WHERE user_id = OLD.user_id;
    RETURN NULL;
  END IF;
  PERFORM vibra_private.radar_refresh(NEW.user_id);
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.radar_refresh_from_preferences() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_radar_preferences
AFTER INSERT OR DELETE OR UPDATE OF radar_enabled, radar_precision, location_processing
ON public.privacy_preferences FOR EACH ROW EXECUTE FUNCTION vibra_private.radar_refresh_from_preferences();

-- ── Rate limit: add the radar to the shared per-minute limiter ───────────
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
    WHEN 'delete-account' THEN 3 WHEN 'music-radar' THEN 6 ELSE NULL END;
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

-- ── Event genre matching (coarse) ─────────────────────────────────────────
-- Ticketmaster labels ("Hip-Hop/Rap", "R&B", "Dance/Electronic") against
-- catalogue family keys, compared as lowercase alphanumerics.
CREATE FUNCTION vibra_private.radar_family_token(p_family text)
RETURNS text LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT CASE p_family WHEN 'rnb' THEN 'rb' ELSE regexp_replace(lower(p_family), '[^a-z0-9]', '', 'g') END;
$$;
REVOKE ALL ON FUNCTION vibra_private.radar_family_token(text) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION vibra_private.radar_genre_match(p_labels text[], p_families text[])
RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT EXISTS (
    SELECT 1 FROM unnest(COALESCE(p_labels, '{}')) g, unnest(COALESCE(p_families, '{}')) f
    WHERE position(vibra_private.radar_family_token(f) IN regexp_replace(lower(g), '[^a-z0-9]', '', 'g')) > 0
  );
$$;
REVOKE ALL ON FUNCTION vibra_private.radar_genre_match(text[], text[]) FROM PUBLIC, anon, authenticated;

-- ── The radar ─────────────────────────────────────────────────────────────
CREATE FUNCTION public.get_music_radar()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_prefs public.privacy_preferences%ROWTYPE;
  v_center public.geography;
  v_radius double precision;
  v_settings jsonb;
  v_my_families text[];
  v_my_artists text[];
  v_result jsonb;
BEGIN
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM public.consume_action_limit('music-radar');
  SELECT * INTO v_prefs FROM public.privacy_preferences WHERE user_id = v_me;
  v_settings := jsonb_build_object(
    'enabled', COALESCE(v_prefs.radar_enabled, false),
    'visible', COALESCE(v_prefs.radar_visible, true),
    'distance_km', COALESCE(v_prefs.radar_distance_km, 25),
    'precision', COALESCE(v_prefs.radar_precision, 'area'),
    'location_consent', COALESCE(v_prefs.location_processing, false),
    'matching_consent', COALESCE(v_prefs.spotify_matching, false)
  );
  IF NOT COALESCE(v_prefs.radar_enabled, false) THEN
    RETURN jsonb_build_object('status', 'disabled', 'settings', v_settings);
  END IF;
  IF NOT COALESCE(v_prefs.location_processing, false) THEN
    RETURN jsonb_build_object('status', 'location_needed', 'settings', v_settings);
  END IF;
  PERFORM vibra_private.radar_refresh(v_me);
  SELECT r.center INTO v_center FROM vibra_private.radar_presence r
    WHERE r.user_id = v_me AND r.located_at > now() - interval '14 days';
  IF v_center IS NULL THEN
    RETURN jsonb_build_object('status', 'location_needed', 'settings', v_settings);
  END IF;
  v_radius := v_prefs.radar_distance_km * 1000.0;

  -- The caller's own sound, for events.
  SELECT ARRAY(SELECT f.key FROM jsonb_to_recordset(s.dna->'families') AS f(key text, share double precision)
               ORDER BY f.share DESC LIMIT 3),
         ARRAY(SELECT lower(a.name) FROM jsonb_to_recordset(COALESCE(s.dna->'artists', '[]')) AS a(name text)
               WHERE NULLIF(a.name, '') IS NOT NULL)
    INTO v_my_families, v_my_artists
  FROM public.musical_dna_snapshots s WHERE s.user_id = v_me ORDER BY s.captured_on DESC LIMIT 1;

  WITH pool AS (
    -- Visible radar users whose cell centre is within the caller's radius.
    SELECT r.user_id
    FROM vibra_private.radar_presence r
    JOIN public.privacy_preferences pp ON pp.user_id = r.user_id
    WHERE r.user_id <> v_me
      AND pp.radar_enabled AND pp.radar_visible AND pp.location_processing
      AND r.located_at > now() - interval '14 days'
      AND public.ST_DWithin(r.center, v_center, v_radius)
      AND public.may_access_message(v_me, r.user_id)
  ), compatible AS (
    SELECT p.user_id, d.username::text AS username, d.display_name, d.avatar_url, d.bio,
      round(m.compatibility)::integer AS compatibility, m.details,
      (SELECT f.status FROM public.friendships f
        WHERE (f.requester_id = v_me AND f.receiver_id = p.user_id)
           OR (f.requester_id = p.user_id AND f.receiver_id = v_me)
        ORDER BY (f.status = 'accepted') DESC LIMIT 1) AS connection
    FROM pool p
    JOIN public.user_matches m
      ON m.user_id_a = LEAST(v_me, p.user_id) AND m.user_id_b = GREATEST(v_me, p.user_id)
    JOIN public.profile_discovery d ON d.id = p.user_id
    WHERE m.compatibility >= 45
      AND public.may_access_music_match(LEAST(v_me, p.user_id), GREATEST(v_me, p.user_id))
      AND NOT EXISTS (SELECT 1 FROM public.affinity_dismissals x
        WHERE x.user_id = v_me AND x.dismissed_user_id = p.user_id)
  ), contributors AS (
    -- Area sound: latest DNA of nearby people who consented to musical use.
    SELECT p.user_id, latest.dna
    FROM pool p
    JOIN public.privacy_preferences pp ON pp.user_id = p.user_id AND pp.spotify_matching
    CROSS JOIN LATERAL (
      SELECT s.dna FROM public.musical_dna_snapshots s
      WHERE s.user_id = p.user_id ORDER BY s.captured_on DESC LIMIT 1
    ) latest
  ), area AS (
    SELECT f.key, sum(f.share) / (SELECT count(*) FROM contributors) AS share
    FROM contributors c, jsonb_to_recordset(c.dna->'families') AS f(key text, share double precision)
    GROUP BY f.key
  ), shared_names AS (
    SELECT DISTINCT lower(a) AS name FROM compatible c,
      jsonb_array_elements_text(COALESCE(c.details->'shared_artists', '[]')) a
  ), area_top AS (
    SELECT ARRAY(SELECT key FROM area ORDER BY share DESC, key LIMIT 3) AS families
  ), scored_events AS (
    SELECT e.*,
      CASE
        WHEN lower(e.artist_name) = ANY (COALESCE(v_my_artists, '{}')) THEN 'your_artist'
        WHEN lower(e.artist_name) IN (SELECT name FROM shared_names) THEN 'shared_artist'
        WHEN vibra_private.radar_genre_match(e.genres, v_my_families) THEN 'your_genre'
        WHEN vibra_private.radar_genre_match(e.genres, (SELECT families FROM area_top)) THEN 'area_genre'
      END AS reason,
      (CASE WHEN lower(e.artist_name) = ANY (COALESCE(v_my_artists, '{}')) THEN 3 ELSE 0 END
       + CASE WHEN lower(e.artist_name) IN (SELECT name FROM shared_names) THEN 2 ELSE 0 END
       + CASE WHEN vibra_private.radar_genre_match(e.genres, v_my_families) THEN 1 ELSE 0 END
       + CASE WHEN vibra_private.radar_genre_match(e.genres, (SELECT families FROM area_top)) THEN 0.5 ELSE 0 END
      ) AS score
    FROM public.events e
    WHERE e.location IS NOT NULL
      AND e.event_date BETWEEN now() AND now() + interval '45 days'
      AND COALESCE(e.status, 'onsale') NOT IN ('canceled', 'postponed', 'offsale')
      AND public.ST_DWithin(e.location, v_center, v_radius)
  )
  SELECT jsonb_build_object(
    'status', 'ok',
    'settings', v_settings,
    'compatible_count', (SELECT count(*) FROM compatible),
    -- Area statistics only with at least 5 contributors (k-anonymity).
    'area_genres', CASE WHEN (SELECT count(*) FROM contributors) >= 5 THEN COALESCE((
        SELECT jsonb_agg(jsonb_build_object('family', key, 'share', round(share::numeric, 3)) ORDER BY share DESC, key)
        FROM (SELECT * FROM area ORDER BY share DESC, key LIMIT 5) t), '[]'::jsonb)
      ELSE '[]'::jsonb END,
    'profiles', COALESCE((
      SELECT jsonb_agg(to_jsonb(c) ORDER BY c.compatibility DESC, md5(c.user_id::text || v_me::text || current_date::text))
      FROM (SELECT * FROM compatible
            ORDER BY compatibility DESC, md5(user_id::text || v_me::text || current_date::text)
            LIMIT 30) c), '[]'::jsonb),
    'events', COALESCE((
      SELECT jsonb_agg((to_jsonb(se) - 'location' - 'score' - 'genres') ORDER BY se.score DESC, se.event_date)
      FROM (SELECT * FROM scored_events WHERE score >= 1 ORDER BY score DESC, event_date LIMIT 6) se), '[]'::jsonb)
  ) INTO v_result;
  RETURN v_result;
END;
$$;
REVOKE ALL ON FUNCTION public.get_music_radar() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_music_radar() TO authenticated;

-- ── Settings ──────────────────────────────────────────────────────────────
-- One validated entry point for the four radar settings (NULL = unchanged).
CREATE FUNCTION public.set_music_radar_settings(
  p_enabled boolean DEFAULT NULL, p_visible boolean DEFAULT NULL,
  p_distance_km integer DEFAULT NULL, p_precision text DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog AS $$
BEGIN
  IF auth.uid() IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  INSERT INTO public.privacy_preferences AS p (user_id, radar_enabled, radar_visible, radar_distance_km, radar_precision, updated_at)
  VALUES (auth.uid(), COALESCE(p_enabled, false), COALESCE(p_visible, true),
          COALESCE(p_distance_km, 25)::smallint, COALESCE(p_precision, 'area'), now())
  ON CONFLICT (user_id) DO UPDATE SET
    radar_enabled = COALESCE(p_enabled, p.radar_enabled),
    radar_visible = COALESCE(p_visible, p.radar_visible),
    radar_distance_km = COALESCE(p_distance_km::smallint, p.radar_distance_km),
    radar_precision = COALESCE(p_precision, p.radar_precision),
    updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_music_radar_settings(boolean, boolean, integer, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_music_radar_settings(boolean, boolean, integer, text) TO authenticated;

-- ── Personal data export ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.export_my_personal_data()
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  RETURN jsonb_build_object(
    'format', 'vibra-personal-data-export/v1',
    'generated_at', now(),
    'response_target', 'Immediate automated export (well within 30 days)',
    'profile', (SELECT to_jsonb(u) - 'fcm_token' FROM public.users u WHERE u.id = uid),
    'privacy_preferences', (SELECT to_jsonb(p) FROM public.privacy_preferences p WHERE p.user_id = uid),
    'spotify_connection', (SELECT jsonb_build_object('spotify_user_id', s.spotify_user_id, 'connected_at', s.connected_at, 'token_expires_at', s.token_expires_at) FROM public.spotify_connections s WHERE s.user_id = uid),
    'music_profile', (SELECT to_jsonb(m) - 'embedding' FROM public.music_profiles m WHERE m.user_id = uid),
    'saved_events', COALESCE((SELECT jsonb_agg(to_jsonb(ea) ORDER BY ea.created_at) FROM public.event_attendees ea WHERE ea.user_id = uid), '[]'::jsonb),
    'messages', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at) FROM public.messages m WHERE m.sender_id = uid OR m.receiver_id = uid), '[]'::jsonb),
    'live_messages', COALESCE((SELECT jsonb_agg(to_jsonb(l) ORDER BY l.created_at) FROM public.live_messages l WHERE l.user_id = uid), '[]'::jsonb),
    'matches', COALESCE((SELECT jsonb_agg(to_jsonb(um) ORDER BY um.created_at) FROM public.user_matches um WHERE um.user_id_a = uid OR um.user_id_b = uid), '[]'::jsonb),
    'social_interactions', COALESCE((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.created_at) FROM public.user_interactions_log i WHERE i.user_id = uid), '[]'::jsonb),
    'ticket_clicks', COALESCE((SELECT jsonb_agg(to_jsonb(t) ORDER BY t.clicked_at) FROM public.ticket_clicks t WHERE t.user_id = uid), '[]'::jsonb),
    'genre_preferences', COALESCE((SELECT jsonb_agg(to_jsonb(g) ORDER BY g.genre_key) FROM public.user_genre_preferences g WHERE g.user_id = uid), '[]'::jsonb),
    'affinity_dismissals', COALESCE((SELECT jsonb_agg(to_jsonb(d) ORDER BY d.created_at) FROM public.affinity_dismissals d WHERE d.user_id = uid), '[]'::jsonb),
    'musical_dna', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.captured_on) FROM public.musical_dna_snapshots s WHERE s.user_id = uid), '[]'::jsonb),
    'saved_profiles', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.created_at) FROM public.saved_profiles s WHERE s.user_id = uid), '[]'::jsonb),
    'same_frequency_views', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.last_shown_at) FROM public.same_frequency_views v WHERE v.user_id = uid), '[]'::jsonb),
    'music_radar_position', (SELECT jsonb_build_object(
        'cell_center_latitude', public.ST_Y(r.center::public.geometry),
        'cell_center_longitude', public.ST_X(r.center::public.geometry),
        'precision', r.precision, 'anchored_at', r.anchored_at, 'located_at', r.located_at)
      FROM vibra_private.radar_presence r WHERE r.user_id = uid)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
