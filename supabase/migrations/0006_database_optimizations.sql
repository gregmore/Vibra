-- Migration 0006: Comprehensive Database Optimizations

-- 1. Optimize Geo-Spatial queries (PostGIS KNN)
DROP FUNCTION IF EXISTS get_nearby_events_with_distance(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION get_nearby_events_with_distance(
    user_lon DOUBLE PRECISION,
    user_lat DOUBLE PRECISION,
    radius_meters DOUBLE PRECISION
)
RETURNS TABLE (
    id UUID,
    external_id TEXT,
    source TEXT,
    name TEXT,
    artist_name TEXT,
    artist_spotify_id TEXT,
    venue_name TEXT,
    city TEXT,
    country TEXT,
    location_lon DOUBLE PRECISION,
    location_lat DOUBLE PRECISION,
    event_date TIMESTAMPTZ,
    ticket_url TEXT,
    price_min DOUBLE PRECISION,
    price_max DOUBLE PRECISION,
    image_url TEXT,
    description TEXT,
    distance_meters DOUBLE PRECISION
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Aggiorniamo anche la posizione dell'utente mentre facciamo la query
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
    FROM public.events e
    WHERE ST_DWithin(
        e.location, 
        ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography, 
        radius_meters
    )
    -- Using KNN operator <-> for GiST index usage on sorting
    ORDER BY e.location <-> ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography ASC;
END;
$$;


-- 2. Add Missing Compound and GiST Indexes
-- Index for event_attendees used by listAttendees
CREATE INDEX IF NOT EXISTS idx_event_attendees_event_created 
ON public.event_attendees (event_id, created_at DESC);

-- Index for friendships to optimize EXISTS checks in RLS
CREATE INDEX IF NOT EXISTS idx_friendships_req_rec_status 
ON public.friendships (requester_id, receiver_id, status);

CREATE INDEX IF NOT EXISTS idx_friendships_rec_req_status 
ON public.friendships (receiver_id, requester_id, status);

-- GiST index on users.last_location for ST_DWithin performance in RLS
CREATE INDEX IF NOT EXISTS idx_users_last_location_gist 
ON public.users USING gist (last_location);


-- 3. RLS Optimizations for `live_messages_select_secure`
-- Invece di un JOIN su events completo, usiamo due EXISTS separati per evitare nested loop lenti
DROP POLICY IF EXISTS "live_messages_select_secure" ON public.live_messages;

CREATE POLICY "live_messages_select_secure"
ON public.live_messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.events e
    WHERE e.id = live_messages.event_id
    AND e.event_date >= (now() - interval '24 hours')
    AND e.event_date <= (now() + interval '24 hours')
    AND EXISTS (
        SELECT 1 FROM public.users u
        WHERE u.id = auth.uid()
        AND u.last_location IS NOT NULL
        AND ST_DWithin(e.location, u.last_location, 500)
    )
  )
);

DROP POLICY IF EXISTS "live_messages_insert_secure" ON public.live_messages;

CREATE POLICY "live_messages_insert_secure"
ON public.live_messages FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM public.event_attendees ea
    WHERE ea.event_id = live_messages.event_id
      AND ea.user_id = auth.uid()
      AND ea.status IN ('going', 'maybe')
  )
  AND EXISTS (
    SELECT 1 FROM public.events e
    WHERE e.id = live_messages.event_id
    AND e.event_date >= (now() - interval '24 hours')
    AND e.event_date <= (now() + interval '24 hours')
    AND EXISTS (
        SELECT 1 FROM public.users u
        WHERE u.id = auth.uid()
        AND u.last_location IS NOT NULL
        AND ST_DWithin(e.location, u.last_location, 500)
    )
  )
);
