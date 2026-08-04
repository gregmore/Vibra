-- Migration 0004: Geo RPC and RLS Optimizations

-- 1. Add last_location to users for distance-based RLS
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS last_location geography(point, 4326);

-- Helper to update user location
CREATE OR REPLACE FUNCTION public.update_user_location(lon double precision, lat double precision)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE public.users 
  SET last_location = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
      updated_at = now()
  WHERE id = auth.uid();
$$;

-- 2. Create PostGIS RPC to calculate distance and return nearby events
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
    ORDER BY distance_meters ASC;
END;
$$;

-- 3. RLS per live_messages (Distanza < 500m & 24h)
DROP POLICY IF EXISTS "live_messages_select_authenticated" ON public.live_messages;
DROP POLICY IF EXISTS "live_messages_insert_if_attending" ON public.live_messages;

CREATE POLICY "live_messages_select_secure"
ON public.live_messages FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.events e
    JOIN public.users u ON u.id = auth.uid()
    WHERE e.id = live_messages.event_id
    AND e.event_date >= (now() - interval '24 hours')
    AND e.event_date <= (now() + interval '24 hours')
    AND u.last_location IS NOT NULL
    AND ST_DWithin(e.location, u.last_location, 500)
  )
);

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
    JOIN public.users u ON u.id = auth.uid()
    WHERE e.id = live_messages.event_id
    AND e.event_date >= (now() - interval '24 hours')
    AND e.event_date <= (now() + interval '24 hours')
    AND u.last_location IS NOT NULL
    AND ST_DWithin(e.location, u.last_location, 500)
  )
);

-- 4. RLS per messages (Distanza < 500m)
DROP POLICY IF EXISTS "messages_select_involved" ON public.messages;
DROP POLICY IF EXISTS "messages_insert_sender" ON public.messages;

CREATE POLICY "messages_select_secure"
ON public.messages FOR SELECT
TO authenticated
USING (
  sender_id = auth.uid() OR receiver_id = auth.uid()
);

CREATE POLICY "messages_insert_secure"
ON public.messages FOR INSERT
TO authenticated
WITH CHECK (
  sender_id = auth.uid() AND
  (
    -- Amici accettati
    EXISTS (
      SELECT 1 FROM public.friendships f
      WHERE (
        (f.requester_id = auth.uid() AND f.receiver_id = messages.receiver_id) OR 
        (f.receiver_id = auth.uid() AND f.requester_id = messages.receiver_id)
      )
      AND f.status = 'accepted'
    )
    OR
    -- Oppure entro 500m
    EXISTS (
      SELECT 1 FROM public.users u1, public.users u2
      WHERE u1.id = auth.uid() AND u2.id = messages.receiver_id
      AND u1.last_location IS NOT NULL AND u2.last_location IS NOT NULL
      AND ST_DWithin(u1.last_location, u2.last_location, 500)
    )
  )
);
