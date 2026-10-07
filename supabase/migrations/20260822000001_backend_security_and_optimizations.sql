-- Migration 20260822000001: Backend Security Hardening & Performance Optimizations

-- ─────────────────────────────────────────────────────────────
-- 1. SECURITY DEFINER SEARCH PATH HARDENING (CWE-426)
-- ─────────────────────────────────────────────────────────────

-- Helper set_updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Helper events_sync_location
CREATE OR REPLACE FUNCTION public.events_sync_location()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  ELSE
    NEW.location = NULL;
  END IF;
  RETURN NEW;
END;
$$;

-- Helper update_user_location
CREATE OR REPLACE FUNCTION public.update_user_location(lon double precision, lat double precision)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  UPDATE public.users
  SET last_location = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
      last_latitude = lat,
      last_longitude = lon,
      updated_at = now()
  WHERE id = auth.uid();
$$;

-- Helper get_nearby_events_with_distance
CREATE OR REPLACE FUNCTION public.get_nearby_events_with_distance(
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
SET search_path = public, pg_temp
AS $$
BEGIN
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
    AND e.event_date >= (now() - interval '12 hours')
    ORDER BY e.location <-> ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography ASC;
END;
$$;

-- Helper find_compatible_users (pgvector)
CREATE OR REPLACE FUNCTION public.find_compatible_users(
  p_user_id uuid,
  p_embedding vector(10),
  p_limit int default 50
)
RETURNS TABLE (
  user_id uuid,
  distance float,
  top_artists jsonb,
  top_genres jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.user_id,
    (m.embedding <-> p_embedding) AS distance,
    m.top_artists,
    m.top_genres
  FROM public.music_profiles m
  WHERE m.user_id != p_user_id
    AND m.embedding IS NOT NULL
  ORDER BY m.embedding <-> p_embedding
  LIMIT p_limit;
END;
$$;

-- Moderation triggers search path hardening
CREATE OR REPLACE FUNCTION public.check_block_before_message()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.blocked_users
    WHERE (blocker_id = NEW.sender_id AND blocked_id = NEW.receiver_id)
       OR (blocker_id = NEW.receiver_id AND blocked_id = NEW.sender_id)
  ) THEN
    RAISE EXCEPTION 'Cannot send message. A block exists between the users.';
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.first_contact_limiter()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  replies_count int;
  sent_count int;
BEGIN
  SELECT COUNT(*) INTO replies_count
  FROM public.messages
  WHERE sender_id = NEW.receiver_id AND receiver_id = NEW.sender_id;

  IF replies_count = 0 THEN
    SELECT COUNT(*) INTO sent_count
    FROM public.messages
    WHERE sender_id = NEW.sender_id AND receiver_id = NEW.receiver_id;

    IF sent_count >= 3 THEN
      RAISE EXCEPTION 'Cannot send more than 3 messages before receiving a reply.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.content_filter()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.message_type = 'text' THEN
    IF NEW.content ~* '(http|https)://.*(ngrok|bit\.ly|tinyurl|free-money|adult|casino|scam)' THEN
      RAISE EXCEPTION 'Message blocked by content filter: suspicious link detected.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.soft_delete_chat(p_user_id uuid, p_other_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Vibra Security: You can only delete your own chats.';
  END IF;

  UPDATE public.messages
  SET deleted_by = array_append(deleted_by, p_user_id)
  WHERE ((sender_id = p_user_id AND receiver_id = p_other_user_id)
     OR (sender_id = p_other_user_id AND receiver_id = p_user_id))
    AND NOT (p_user_id = ANY(deleted_by));
END;
$$;

CREATE OR REPLACE FUNCTION public.react_to_message(p_message_id uuid, p_user_id uuid, p_reaction text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Vibra Security: You can only add reactions for yourself.';
  END IF;

  UPDATE public.messages
  SET reactions = COALESCE(reactions, '{}'::jsonb) || jsonb_build_object(p_user_id::text, p_reaction)
  WHERE id = p_message_id
    AND (sender_id = auth.uid() OR receiver_id = auth.uid());
END;
$$;

-- ─────────────────────────────────────────────────────────────
-- 2. SECURE PUBLIC VIEW FOR MUSIC PROFILES
-- ─────────────────────────────────────────────────────────────

DROP VIEW IF EXISTS public.music_profiles_public CASCADE;

CREATE VIEW public.music_profiles_public
WITH (security_invoker = false)
AS
SELECT
  user_id,
  top_artists,
  top_genres,
  listening_heatmap,
  last_synced_at
FROM public.music_profiles;

REVOKE ALL ON TABLE public.music_profiles_public FROM public;
GRANT SELECT ON TABLE public.music_profiles_public TO authenticated;

-- ─────────────────────────────────────────────────────────────
-- 3. HIGH PERFORMANCE COMPOSITE & PARTIAL INDEXES
-- ─────────────────────────────────────────────────────────────

-- Events: city + date ordering. A partial-index predicate using `now()` would
-- be rejected by PostgreSQL because index predicates must be immutable.
CREATE INDEX IF NOT EXISTS idx_events_upcoming_city
ON public.events (city, event_date ASC);

-- Messages: Conversazioni bidirezionali e messaggi non letti
CREATE INDEX IF NOT EXISTS idx_messages_conversation
ON public.messages (sender_id, receiver_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_unread
ON public.messages (receiver_id, read_at)
WHERE read_at IS NULL;

-- Friendships: Ricerca rapida dello stato amicizia
CREATE INDEX IF NOT EXISTS idx_friendships_composite
ON public.friendships (requester_id, receiver_id, status);

-- User Matches: Ordinamento per compatibilità decrescente
CREATE INDEX IF NOT EXISTS idx_user_matches_composite
ON public.user_matches (user_id_a, user_id_b, compatibility DESC);

-- Blocked Users & Reports
CREATE INDEX IF NOT EXISTS idx_blocked_users_pair
ON public.blocked_users (blocker_id, blocked_id);

CREATE INDEX IF NOT EXISTS idx_reports_pending
ON public.reports (status, created_at DESC);

-- Ticket Clicks Analytics
CREATE INDEX IF NOT EXISTS idx_ticket_clicks_composite
ON public.ticket_clicks (user_id, event_id, clicked_at DESC);

-- ─────────────────────────────────────────────────────────────
-- 4. DATA INTEGRITY CHECK CONSTRAINTS
-- ─────────────────────────────────────────────────────────────

DO $$
BEGIN
  -- Username length constraint (3 to 30 chars)
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_users_username_len') THEN
    ALTER TABLE public.users ADD CONSTRAINT chk_users_username_len CHECK (username IS NULL OR (length(username) >= 3 AND length(username) <= 30));
  END IF;

  -- Display name length constraint (<= 50 chars)
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_users_display_name_len') THEN
    ALTER TABLE public.users ADD CONSTRAINT chk_users_display_name_len CHECK (display_name IS NULL OR length(display_name) <= 50);
  END IF;

  -- Bio length constraint (<= 500 chars)
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_users_bio_len') THEN
    ALTER TABLE public.users ADD CONSTRAINT chk_users_bio_len CHECK (bio IS NULL OR length(bio) <= 500);
  END IF;

  -- Message content length constraint (1 to 2000 chars)
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_messages_content_len') THEN
    ALTER TABLE public.messages ADD CONSTRAINT chk_messages_content_len CHECK (length(content) >= 1 AND length(content) <= 2000);
  END IF;
END $$;
