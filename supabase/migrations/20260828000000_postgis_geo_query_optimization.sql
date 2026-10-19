-- PostGIS query optimization for event discovery, maps, and nearby users.
--
-- The project already stores geographic data in public.events.location and
-- public.users.last_location. This migration is intentionally idempotent so
-- it also repairs legacy rows that only have latitude/longitude populated.

BEGIN;

CREATE EXTENSION IF NOT EXISTS postgis;

-- Keep latitude/longitude as UI-friendly values while geography is the
-- canonical column for distance and map filtering.
ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS location public.geography(Point, 4326);

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS last_location public.geography(Point, 4326);

UPDATE public.events
SET location = public.ST_SetSRID(
  public.ST_MakePoint(longitude, latitude),
  4326
)::public.geography
WHERE location IS NULL
  AND latitude BETWEEN -90 AND 90
  AND longitude BETWEEN -180 AND 180;

UPDATE public.users
SET last_location = public.ST_SetSRID(
  public.ST_MakePoint(last_longitude, last_latitude),
  4326
)::public.geography
WHERE last_location IS NULL
  AND last_latitude BETWEEN -90 AND 90
  AND last_longitude BETWEEN -180 AND 180;

-- Repair UI coordinates when an older row only stored the geography value.
UPDATE public.users
SET last_latitude = public.ST_Y(last_location::public.geometry),
    last_longitude = public.ST_X(last_location::public.geometry)
WHERE last_location IS NOT NULL
  AND (last_latitude IS NULL OR last_longitude IS NULL);

-- Some seed and service writes update the convenience coordinates directly.
-- Keep their geography counterpart consistent for future PostGIS queries.
CREATE OR REPLACE FUNCTION public.users_sync_last_location()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF (NEW.last_latitude IS NULL) <> (NEW.last_longitude IS NULL) THEN
    RAISE EXCEPTION 'last_latitude and last_longitude must be set together';
  END IF;

  IF NEW.last_latitude IS NOT NULL
     AND (NEW.last_latitude NOT BETWEEN -90 AND 90
          OR NEW.last_longitude NOT BETWEEN -180 AND 180) THEN
    RAISE EXCEPTION 'invalid user location coordinates';
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NEW.last_latitude IS NOT NULL THEN
      NEW.last_location := public.ST_SetSRID(
        public.ST_MakePoint(NEW.last_longitude, NEW.last_latitude),
        4326
      )::public.geography;
    ELSIF NEW.last_location IS NOT NULL THEN
      NEW.last_latitude := public.ST_Y(NEW.last_location::public.geometry);
      NEW.last_longitude := public.ST_X(NEW.last_location::public.geometry);
    END IF;
  ELSIF NEW.last_latitude IS DISTINCT FROM OLD.last_latitude
     OR NEW.last_longitude IS DISTINCT FROM OLD.last_longitude THEN
    IF NEW.last_latitude IS NULL THEN
      NEW.last_location := NULL;
    ELSE
      NEW.last_location := public.ST_SetSRID(
        public.ST_MakePoint(NEW.last_longitude, NEW.last_latitude),
        4326
      )::public.geography;
    END IF;
  ELSIF NEW.last_location IS DISTINCT FROM OLD.last_location THEN
    IF NEW.last_location IS NULL THEN
      NEW.last_latitude := NULL;
      NEW.last_longitude := NULL;
    ELSE
      NEW.last_latitude := public.ST_Y(NEW.last_location::public.geometry);
      NEW.last_longitude := public.ST_X(NEW.last_location::public.geometry);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_users_last_location ON public.users;
CREATE TRIGGER trg_users_last_location
BEFORE INSERT OR UPDATE OF last_latitude, last_longitude, last_location
ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.users_sync_last_location();

CREATE INDEX IF NOT EXISTS idx_events_location_gist
  ON public.events USING gist (location);

CREATE INDEX IF NOT EXISTS idx_users_last_location_gist
  ON public.users USING gist (last_location);

-- events.event_date already has a standalone index. This composite index adds
-- the status predicate used by the public discovery and map queries.
CREATE INDEX IF NOT EXISTS idx_events_status_event_date
  ON public.events (status, event_date ASC);

-- Read-only radius search for the app. Unlike the legacy
-- get_nearby_events_with_distance RPC, it never writes the caller's location.
CREATE OR REPLACE FUNCTION public.find_events_in_radius(
  p_latitude double precision,
  p_longitude double precision,
  p_radius_meters double precision,
  p_status text DEFAULT 'onsale',
  p_from timestamptz DEFAULT now(),
  p_limit integer DEFAULT 200
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
  status text,
  created_at timestamptz,
  distance_meters double precision
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_origin public.geography;
BEGIN
  IF p_latitude IS NULL OR p_longitude IS NULL
     OR p_latitude NOT BETWEEN -90 AND 90
     OR p_longitude NOT BETWEEN -180 AND 180
     OR p_radius_meters IS NULL OR p_radius_meters NOT BETWEEN 100 AND 250000
     OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 500 THEN
    RAISE EXCEPTION 'Invalid nearby-events query parameters';
  END IF;

  v_origin := public.ST_SetSRID(
    public.ST_MakePoint(p_longitude, p_latitude),
    4326
  )::public.geography;

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
    public.ST_X(e.location::public.geometry) AS location_lon,
    public.ST_Y(e.location::public.geometry) AS location_lat,
    e.event_date,
    e.ticket_url,
    e.price_min,
    e.price_max,
    e.image_url,
    e.description,
    e.status,
    e.created_at,
    public.ST_Distance(e.location, v_origin) AS distance_meters
  FROM public.events AS e
  WHERE e.location IS NOT NULL
    AND public.ST_DWithin(e.location, v_origin, p_radius_meters)
    AND (p_status IS NULL OR e.status = p_status)
    AND (p_from IS NULL OR e.event_date >= p_from)
  ORDER BY distance_meters ASC, e.event_date ASC, e.id ASC
  LIMIT p_limit;
END;
$$;

-- Bounding-box variant for a map viewport. Anti-meridian views must be split
-- into two requests by a future caller; this keeps the index predicate exact.
CREATE OR REPLACE FUNCTION public.find_events_in_bounds(
  p_min_latitude double precision,
  p_min_longitude double precision,
  p_max_latitude double precision,
  p_max_longitude double precision,
  p_status text DEFAULT 'onsale',
  p_from timestamptz DEFAULT now(),
  p_limit integer DEFAULT 500
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
  status text,
  created_at timestamptz,
  distance_meters double precision
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_bounds public.geography;
BEGIN
  IF p_min_latitude IS NULL OR p_min_longitude IS NULL
     OR p_max_latitude IS NULL OR p_max_longitude IS NULL
     OR p_min_latitude NOT BETWEEN -90 AND 90
     OR p_max_latitude NOT BETWEEN -90 AND 90
     OR p_min_longitude NOT BETWEEN -180 AND 180
     OR p_max_longitude NOT BETWEEN -180 AND 180
     OR p_min_latitude >= p_max_latitude
     OR p_min_longitude >= p_max_longitude
     OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 500 THEN
    RAISE EXCEPTION 'Invalid map bounds';
  END IF;

  v_bounds := public.ST_MakeEnvelope(
    p_min_longitude,
    p_min_latitude,
    p_max_longitude,
    p_max_latitude,
    4326
  )::public.geography;

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
    public.ST_X(e.location::public.geometry) AS location_lon,
    public.ST_Y(e.location::public.geometry) AS location_lat,
    e.event_date,
    e.ticket_url,
    e.price_min,
    e.price_max,
    e.image_url,
    e.description,
    e.status,
    e.created_at,
    NULL::double precision AS distance_meters
  FROM public.events AS e
  WHERE e.location OPERATOR(public.&&) v_bounds
    AND (p_status IS NULL OR e.status = p_status)
    AND (p_from IS NULL OR e.event_date >= p_from)
  ORDER BY e.event_date ASC, e.id ASC
  LIMIT p_limit;
END;
$$;

-- Batch distance lookup for the event-alert worker. The caller retains its
-- complete candidate set; pairs not returned are simply farther than the
-- requested radius and keep a zero proximity score.
CREATE OR REPLACE FUNCTION public.nearby_event_distances_for_users(
  p_user_ids uuid[],
  p_event_ids uuid[],
  p_radius_meters double precision DEFAULT 250000
)
RETURNS TABLE (
  user_id uuid,
  event_id uuid,
  distance_meters double precision
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'service role required';
  END IF;

  IF p_user_ids IS NULL OR p_event_ids IS NULL
     OR p_radius_meters IS NULL OR p_radius_meters NOT BETWEEN 100 AND 250000 THEN
    RAISE EXCEPTION 'Invalid event-distance query parameters';
  END IF;

  RETURN QUERY
  SELECT
    u.id,
    e.id,
    public.ST_Distance(e.location, u.last_location)
  FROM public.users AS u
  CROSS JOIN LATERAL (
    SELECT candidate.id, candidate.location
    FROM public.events AS candidate
    WHERE candidate.id = ANY(p_event_ids)
      AND candidate.location IS NOT NULL
      AND public.ST_DWithin(candidate.location, u.last_location, p_radius_meters)
  ) AS e
  WHERE u.id = ANY(p_user_ids)
    AND u.last_location IS NOT NULL;
END;
$$;

-- Nearby users for live-chat notifications. It returns only the fields the
-- service worker needs and is deliberately unavailable to client roles.
CREATE OR REPLACE FUNCTION public.live_chat_notification_recipients(
  p_event_id uuid,
  p_exclude_user_id uuid,
  p_radius_meters double precision DEFAULT 5000
)
RETURNS TABLE (
  id uuid,
  fcm_token text,
  push_enabled boolean,
  push_settings jsonb
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'service role required';
  END IF;

  IF p_event_id IS NULL OR p_exclude_user_id IS NULL
     OR p_radius_meters IS NULL OR p_radius_meters NOT BETWEEN 100 AND 250000 THEN
    RAISE EXCEPTION 'Invalid live-chat recipient query parameters';
  END IF;

  RETURN QUERY
  SELECT u.id, u.fcm_token, u.push_enabled, u.push_settings
  FROM public.events AS e
  JOIN public.users AS u
    ON u.last_location IS NOT NULL
   AND public.ST_DWithin(u.last_location, e.location, p_radius_meters)
  WHERE e.id = p_event_id
    AND e.location IS NOT NULL
    AND u.id <> p_exclude_user_id;
END;
$$;

-- Retention notifications consider only the most recent five qualifying
-- matches before applying the spatial predicate, preserving current behavior.
CREATE OR REPLACE FUNCTION public.nearby_recent_match_for_user(
  p_user_id uuid,
  p_radius_meters double precision DEFAULT 25000
)
RETURNS TABLE (
  match_id uuid,
  compatibility double precision,
  display_name text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'service role required';
  END IF;

  IF p_user_id IS NULL
     OR p_radius_meters IS NULL OR p_radius_meters NOT BETWEEN 100 AND 250000 THEN
    RAISE EXCEPTION 'Invalid nearby-match query parameters';
  END IF;

  RETURN QUERY
  WITH recent_matches AS (
    SELECT
      m.id,
      m.compatibility,
      m.created_at,
      CASE
        WHEN m.user_id_a = p_user_id THEN m.user_id_b
        ELSE m.user_id_a
      END AS other_user_id
    FROM public.user_matches AS m
    WHERE (m.user_id_a = p_user_id OR m.user_id_b = p_user_id)
      AND m.compatibility >= 75
      AND m.created_at >= now() - interval '7 days'
    ORDER BY m.created_at DESC
    LIMIT 5
  )
  SELECT
    rm.id,
    rm.compatibility,
    COALESCE(other_user.display_name, other_user.username::text, 'Una nuova persona')
  FROM recent_matches AS rm
  JOIN public.users AS viewer_user
    ON viewer_user.id = p_user_id
  JOIN public.users AS other_user
    ON other_user.id = rm.other_user_id
  WHERE viewer_user.last_location IS NOT NULL
    AND other_user.last_location IS NOT NULL
    AND public.ST_DWithin(
      viewer_user.last_location,
      other_user.last_location,
      p_radius_meters
    )
  ORDER BY rm.created_at DESC
  LIMIT 1;
END;
$$;

REVOKE ALL ON FUNCTION public.find_events_in_radius(
  double precision, double precision, double precision, text, timestamptz, integer
) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.find_events_in_bounds(
  double precision, double precision, double precision, double precision, text, timestamptz, integer
) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.nearby_event_distances_for_users(
  uuid[], uuid[], double precision
) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.live_chat_notification_recipients(
  uuid, uuid, double precision
) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.nearby_recent_match_for_user(
  uuid, double precision
) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.find_events_in_radius(
  double precision, double precision, double precision, text, timestamptz, integer
) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.find_events_in_bounds(
  double precision, double precision, double precision, double precision, text, timestamptz, integer
) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.nearby_event_distances_for_users(
  uuid[], uuid[], double precision
) TO service_role;
GRANT EXECUTE ON FUNCTION public.live_chat_notification_recipients(
  uuid, uuid, double precision
) TO service_role;
GRANT EXECUTE ON FUNCTION public.nearby_recent_match_for_user(
  uuid, double precision
) TO service_role;

ANALYZE public.events;
ANALYZE public.users;

COMMIT;
