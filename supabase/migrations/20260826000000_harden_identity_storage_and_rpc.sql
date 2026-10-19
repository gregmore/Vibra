-- Vibra: identity integrity, secure avatar uploads and RPC exposure hardening.
-- This migration is intentionally additive so it can be applied safely to an
-- existing project as well as to a fresh local database.

BEGIN;

-- ─────────────────────────────────────────────────────────────
-- 1. Notification domain and lookup performance
-- ─────────────────────────────────────────────────────────────

ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check CHECK (
    type IN (
      'event_alert',
      'match',
      'friend_request',
      'message_request',
      'chat_message',
      'live_chat',
      'ticket_low'
    )
  );

CREATE INDEX IF NOT EXISTS idx_notifications_event_dedupe
  ON public.notifications (user_id, (data->>'event_id'), created_at DESC)
  WHERE type = 'event_alert';

-- ─────────────────────────────────────────────────────────────
-- 2. Email identity must always mirror auth.users
--
-- auth.users already provides the authoritative case-insensitive unique email
-- constraint. This trigger prevents a client from changing public.users.email
-- to a different address, which could otherwise make the app profile diverge
-- from the authenticated identity.
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.enforce_profile_email_from_auth()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_email citext;
BEGIN
  SELECT email INTO v_email
  FROM auth.users
  WHERE id = NEW.id;

  IF v_email IS NULL THEN
    RAISE EXCEPTION 'Vibra Security: a profile must belong to an email-authenticated user.';
  END IF;

  NEW.email := v_email;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_users_enforce_auth_email ON public.users;
CREATE TRIGGER trg_users_enforce_auth_email
BEFORE INSERT OR UPDATE OF email ON public.users
FOR EACH ROW EXECUTE FUNCTION public.enforce_profile_email_from_auth();

CREATE OR REPLACE FUNCTION public.sync_profile_email_from_auth()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  UPDATE public.users
  SET email = NEW.email
  WHERE id = NEW.id
    AND email IS DISTINCT FROM NEW.email;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_auth_users_sync_profile_email ON auth.users;
CREATE TRIGGER trg_auth_users_sync_profile_email
AFTER UPDATE OF email ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.sync_profile_email_from_auth();

UPDATE public.users AS profile
SET email = auth_user.email
FROM auth.users AS auth_user
WHERE profile.id = auth_user.id
  AND profile.email IS DISTINCT FROM auth_user.email;

-- ─────────────────────────────────────────────────────────────
-- 3. Avatar storage: size/type limits and per-user paths
-- ─────────────────────────────────────────────────────────────

INSERT INTO storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "avatars_insert_own_folder" ON storage.objects;
CREATE POLICY "avatars_insert_own_folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

DROP POLICY IF EXISTS "avatars_update_own_folder" ON storage.objects;
CREATE POLICY "avatars_update_own_folder"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
)
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

DROP POLICY IF EXISTS "avatars_delete_own_folder" ON storage.objects;
CREATE POLICY "avatars_delete_own_folder"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

-- ─────────────────────────────────────────────────────────────
-- 4. Validate location writes and limit RPC exposure
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.update_user_location(
  lon double precision,
  lat double precision
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL AND auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF lon IS NULL OR lat IS NULL
     OR lon < -180 OR lon > 180
     OR lat < -90 OR lat > 90 THEN
    RAISE EXCEPTION 'Invalid longitude or latitude';
  END IF;

  -- Service calls have no end-user subject and must never update an arbitrary
  -- profile; direct authenticated calls update only their own location.
  IF v_user_id IS NOT NULL THEN
    UPDATE public.users
    SET last_location = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
        last_latitude = lat,
        last_longitude = lon,
        updated_at = now()
    WHERE id = v_user_id;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_nearby_events_with_distance(
  user_lon double precision,
  user_lat double precision,
  radius_meters double precision
)
RETURNS TABLE (
  id uuid,
  external_id text,
  source text,
  name text,
  artist_name text,
  artist_spotify_id text,
  venue_name text,
  city text,
  country text,
  location_lon double precision,
  location_lat double precision,
  event_date timestamptz,
  ticket_url text,
  price_min double precision,
  price_max double precision,
  image_url text,
  description text,
  distance_meters double precision
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.uid() IS NULL AND auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF user_lon IS NULL OR user_lat IS NULL
     OR user_lon < -180 OR user_lon > 180
     OR user_lat < -90 OR user_lat > 90
     OR radius_meters IS NULL OR radius_meters < 100 OR radius_meters > 200000 THEN
    RAISE EXCEPTION 'Invalid nearby-events query parameters';
  END IF;

  PERFORM public.update_user_location(user_lon, user_lat);

  RETURN QUERY
  SELECT
    e.id,
    e.external_id,
    e.source,
    e.name,
    e.artist_name,
    e.artist_spotify_id,
    e.venue_name,
    e.city,
    e.country,
    ST_X(e.location::geometry) AS location_lon,
    ST_Y(e.location::geometry) AS location_lat,
    e.event_date,
    e.ticket_url,
    e.price_min,
    e.price_max,
    e.image_url,
    e.description,
    ST_Distance(
      e.location,
      ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography
    ) AS distance_meters
  FROM public.events AS e
  WHERE ST_DWithin(
      e.location,
      ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography,
      radius_meters
    )
    AND e.event_date >= (now() - interval '12 hours')
  ORDER BY e.location <-> ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography ASC;
END;
$$;

-- SECURITY DEFINER functions are not public API by default. Grant the smallest
-- required audience explicitly; the compatibility search remains backend-only.
REVOKE ALL ON FUNCTION public.update_user_location(double precision, double precision) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_nearby_events_with_distance(double precision, double precision, double precision) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.find_compatible_users(uuid, vector, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.soft_delete_chat(uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.react_to_message(uuid, uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.delete_user_account() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_user_follow_stats(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_user_followers(uuid, integer, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_user_following(uuid, integer, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.get_user_conversations() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.update_user_location(double precision, double precision) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_nearby_events_with_distance(double precision, double precision, double precision) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.find_compatible_users(uuid, vector, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.soft_delete_chat(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.react_to_message(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_follow_stats(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_followers(uuid, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_following(uuid, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_conversations() TO authenticated;

COMMIT;
