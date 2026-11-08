-- Map discovery returns every event in the visible radius (clustered on the
-- client) instead of stopping at 500. Body identical to 20260828000000 except
-- for the accepted p_limit range.
BEGIN;
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
     OR p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 2000 THEN
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
COMMIT;
