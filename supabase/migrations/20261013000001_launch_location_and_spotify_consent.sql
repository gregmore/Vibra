BEGIN;

CREATE OR REPLACE FUNCTION public.update_user_location(lon double precision, lat double precision)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  IF auth.uid() IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF lon IS NULL OR lat IS NULL OR lon NOT BETWEEN -180 AND 180 OR lat NOT BETWEEN -90 AND 90 THEN
    RAISE invalid_parameter_value USING MESSAGE = 'Invalid location coordinates';
  END IF;
  -- Serialize location writes and a concurrent opt-out on the same preference.
  PERFORM 1 FROM public.privacy_preferences p
    WHERE p.user_id = auth.uid() AND p.location_processing FOR UPDATE;
  IF NOT FOUND THEN RAISE insufficient_privilege USING MESSAGE = 'Location consent required'; END IF;
  UPDATE public.users SET last_location = public.ST_SetSRID(public.ST_MakePoint(lon, lat), 4326)::public.geography,
    last_latitude = lat, last_longitude = lon, location_updated_at = now()
  WHERE id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.update_user_location(double precision, double precision) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.update_user_location(double precision, double precision) TO authenticated;

CREATE FUNCTION public.protect_location_consent()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog AS $$
BEGIN
  IF current_user = 'authenticated' AND
    (NEW.last_location IS NOT NULL OR NEW.last_latitude IS NOT NULL OR NEW.last_longitude IS NOT NULL) THEN
    PERFORM public.require_active_session();
    PERFORM 1 FROM public.privacy_preferences p
      WHERE p.user_id = NEW.id AND p.location_processing FOR UPDATE;
    IF NOT FOUND THEN RAISE insufficient_privilege USING MESSAGE = 'Location consent required'; END IF;
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_location_consent() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_location_consent BEFORE INSERT OR UPDATE OF last_location, last_latitude, last_longitude
ON public.users FOR EACH ROW EXECUTE FUNCTION public.protect_location_consent();

CREATE FUNCTION public.clear_location_on_consent_revocation()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF TG_OP = 'DELETE' OR NEW.location_processing IS FALSE THEN
    UPDATE public.users SET last_location = NULL, last_latitude = NULL,
      last_longitude = NULL, location_updated_at = NULL
    WHERE id = OLD.user_id;
  END IF;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.clear_location_on_consent_revocation() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_clear_location_on_consent_revocation
AFTER UPDATE OF location_processing OR DELETE ON public.privacy_preferences
FOR EACH ROW EXECUTE FUNCTION public.clear_location_on_consent_revocation();
UPDATE public.users u SET last_location = NULL, last_latitude = NULL, last_longitude = NULL, location_updated_at = NULL
WHERE NOT EXISTS (SELECT 1 FROM public.privacy_preferences p WHERE p.user_id = u.id AND p.location_processing);

-- Disconnect must clear every derived record atomically; a failed statement
-- must never leave matching enabled while reporting success to the client.
CREATE FUNCTION public.disconnect_spotify_account(p_user_id uuid)
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
  DELETE FROM public.spotify_connections WHERE user_id = p_user_id;
  UPDATE public.users SET spotify_id = NULL WHERE id = p_user_id;
END;
$$;
REVOKE ALL ON FUNCTION public.disconnect_spotify_account(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.disconnect_spotify_account(uuid) TO service_role;

CREATE FUNCTION public.connect_spotify_account(
  p_user_id uuid, p_spotify_user_id text, p_profile jsonb,
  p_access_token_ciphertext text, p_refresh_token_ciphertext text,
  p_token_expires_at timestamptz
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_previous_spotify_id text;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  IF NULLIF(p_spotify_user_id, '') IS NULL THEN
    RAISE invalid_parameter_value USING MESSAGE = 'Spotify identity required';
  END IF;
  SELECT spotify_id INTO v_previous_spotify_id FROM public.users WHERE id = p_user_id FOR UPDATE;
  -- Preserve profile edits made while OAuth was open. The endpoint supplies
  -- display fields only for bootstrapping an account without a profile.
  INSERT INTO public.users (id, email, username, display_name, avatar_url, spotify_id)
  VALUES (p_user_id, p_profile->>'email', p_profile->>'username', p_profile->>'display_name',
    p_profile->>'avatar_url', p_spotify_user_id)
  ON CONFLICT (id) DO UPDATE SET spotify_id = EXCLUDED.spotify_id;
  INSERT INTO public.spotify_connections AS existing (
    user_id, spotify_user_id, access_token_ciphertext, refresh_token_ciphertext,
    token_expires_at, connected_at
  ) VALUES (p_user_id, p_spotify_user_id, p_access_token_ciphertext,
    p_refresh_token_ciphertext, p_token_expires_at, clock_timestamp())
  ON CONFLICT (user_id) DO UPDATE SET
    spotify_user_id = EXCLUDED.spotify_user_id,
    access_token_ciphertext = EXCLUDED.access_token_ciphertext,
    refresh_token_ciphertext = COALESCE(EXCLUDED.refresh_token_ciphertext,
      CASE WHEN existing.spotify_user_id = EXCLUDED.spotify_user_id THEN existing.refresh_token_ciphertext END),
    token_expires_at = EXCLUDED.token_expires_at, connected_at = EXCLUDED.connected_at;
  IF v_previous_spotify_id IS DISTINCT FROM p_spotify_user_id THEN
    DELETE FROM public.user_matches WHERE user_id_a = p_user_id OR user_id_b = p_user_id;
    DELETE FROM public.music_profiles WHERE user_id = p_user_id;
  END IF;
  INSERT INTO public.privacy_preferences (user_id, spotify_matching, policy_version, updated_at)
  VALUES (p_user_id, true, '2026-08-27', now())
  ON CONFLICT (user_id) DO UPDATE SET spotify_matching = true, updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.connect_spotify_account(uuid, text, jsonb, text, text, timestamptz)
FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.connect_spotify_account(uuid, text, jsonb, text, text, timestamptz) TO service_role;

CREATE FUNCTION public.refresh_spotify_connection(
  p_user_id uuid, p_spotify_user_id text, p_connected_at timestamptz,
  p_access_token_ciphertext text, p_refresh_token_ciphertext text,
  p_token_expires_at timestamptz
)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_updated integer;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  PERFORM 1 FROM public.users WHERE id = p_user_id AND spotify_id = p_spotify_user_id FOR UPDATE;
  IF NOT FOUND THEN RETURN false; END IF;
  UPDATE public.spotify_connections
  SET access_token_ciphertext = p_access_token_ciphertext,
    refresh_token_ciphertext = COALESCE(p_refresh_token_ciphertext, refresh_token_ciphertext),
    token_expires_at = p_token_expires_at
  WHERE user_id = p_user_id AND spotify_user_id = p_spotify_user_id
    AND connected_at = p_connected_at;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated = 1;
END;
$$;
REVOKE ALL ON FUNCTION public.refresh_spotify_connection(uuid, text, timestamptz, text, text, timestamptz)
FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.refresh_spotify_connection(uuid, text, timestamptz, text, text, timestamptz)
TO service_role;

CREATE FUNCTION public.save_connected_music_profile(
  p_user_id uuid, p_spotify_user_id text, p_connected_at timestamptz, p_profile jsonb
)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_profile public.music_profiles; v_saved public.music_profiles;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  PERFORM 1 FROM public.users WHERE id = p_user_id AND spotify_id = p_spotify_user_id FOR UPDATE;
  IF NOT FOUND OR NOT EXISTS (SELECT 1 FROM public.spotify_connections
    WHERE user_id = p_user_id AND spotify_user_id = p_spotify_user_id AND connected_at = p_connected_at) THEN
    RAISE SQLSTATE 'PT409' USING MESSAGE = 'Spotify connection changed or disconnected';
  END IF;
  v_profile := jsonb_populate_record(NULL::public.music_profiles, p_profile);
  INSERT INTO public.music_profiles (
    user_id, top_artists, top_tracks, top_genres, audio_features, embedding,
    listening_heatmap, last_synced_at
  ) VALUES (
    p_user_id, COALESCE(v_profile.top_artists, '[]'::jsonb), COALESCE(v_profile.top_tracks, '[]'::jsonb),
    COALESCE(v_profile.top_genres, '[]'::jsonb), v_profile.audio_features, v_profile.embedding,
    COALESCE(v_profile.listening_heatmap, '[]'::jsonb), now()
  ) ON CONFLICT (user_id) DO UPDATE SET
    top_artists = EXCLUDED.top_artists, top_tracks = EXCLUDED.top_tracks,
    top_genres = EXCLUDED.top_genres, audio_features = EXCLUDED.audio_features,
    embedding = EXCLUDED.embedding, listening_heatmap = EXCLUDED.listening_heatmap,
    last_synced_at = EXCLUDED.last_synced_at
  RETURNING * INTO v_saved;
  RETURN to_jsonb(v_saved);
END;
$$;
REVOKE ALL ON FUNCTION public.save_connected_music_profile(uuid, text, timestamptz, jsonb)
FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_connected_music_profile(uuid, text, timestamptz, jsonb) TO service_role;

-- Previously computed affinities carry music-derived data too. Revoking
-- matching or blocking the other user must hide cached rows immediately.
CREATE FUNCTION public.may_access_music_match(p_user_id_a uuid, p_user_id_b uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT public.may_access_message(p_user_id_a, p_user_id_b)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences WHERE user_id = p_user_id_a AND spotify_matching)
    AND EXISTS (SELECT 1 FROM public.privacy_preferences WHERE user_id = p_user_id_b AND spotify_matching);
$$;
REVOKE ALL ON FUNCTION public.may_access_music_match(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.may_access_music_match(uuid, uuid) TO authenticated;
CREATE POLICY user_matches_private_consent ON public.user_matches
AS RESTRICTIVE FOR SELECT TO authenticated
USING (public.may_access_music_match(user_id_a, user_id_b));

NOTIFY pgrst, 'reload schema';
COMMIT;
