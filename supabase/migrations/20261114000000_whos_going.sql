-- VIBRA Who's Going? (docs/whos-going.md): social event discovery.
--
-- Participation states: interested (saved), maybe, going. 'not_going' rows
-- from earlier versions stay valid and are never shown to anyone.
--
-- Visibility is the attendee's choice, per event or by default:
--   private  – only me (DEFAULT: attendance stays private, as since
--              20260830000000, until the user decides otherwise)
--   friends  – my accepted connections
--   matches  – connections and people with a mutual musical-affinity pair
--   public   – anyone signed in
-- get_event_social is the only way to see other attendees. It returns a
-- person only when their effective visibility includes the caller, never
-- across a block or test segment, and never returns private rows, counts
-- of private rows, or timestamps.
BEGIN;

ALTER TABLE public.event_attendees DROP CONSTRAINT IF EXISTS event_attendees_status_check;
ALTER TABLE public.event_attendees ADD CONSTRAINT event_attendees_status_check
  CHECK (status IN ('interested', 'maybe', 'going', 'not_going'));
ALTER TABLE public.event_attendees
  ADD COLUMN IF NOT EXISTS visibility text CHECK (visibility IN ('private', 'friends', 'matches', 'public'));

ALTER TABLE public.privacy_preferences
  ADD COLUMN IF NOT EXISTS attendance_visibility text NOT NULL DEFAULT 'private'
  CHECK (attendance_visibility IN ('private', 'friends', 'matches', 'public'));

-- Sets the caller's visibility for one event (NULL = follow the default),
-- and optionally the default for all events.
CREATE FUNCTION public.set_attendance_visibility(p_event uuid, p_visibility text, p_make_default boolean DEFAULT false)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid();
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF p_visibility IS NOT NULL AND p_visibility NOT IN ('private', 'friends', 'matches', 'public') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_visibility';
  END IF;
  IF p_make_default AND p_visibility IS NOT NULL THEN
    INSERT INTO public.privacy_preferences AS p (user_id, attendance_visibility, updated_at)
    VALUES (v_me, p_visibility, now())
    ON CONFLICT (user_id) DO UPDATE SET attendance_visibility = EXCLUDED.attendance_visibility, updated_at = now();
    -- The default applies to every event without its own choice.
    UPDATE public.event_attendees SET visibility = NULL WHERE user_id = v_me AND event_id = p_event;
  ELSE
    UPDATE public.event_attendees SET visibility = p_visibility WHERE user_id = v_me AND event_id = p_event;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_attendance_visibility(uuid, text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_attendance_visibility(uuid, text, boolean) TO authenticated;

-- The caller's own state and effective visibility for an event.
CREATE FUNCTION public.get_my_attendance(p_event uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT jsonb_build_object(
    'status', (SELECT a.status FROM public.event_attendees a WHERE a.event_id = p_event AND a.user_id = auth.uid()),
    'visibility', (SELECT a.visibility FROM public.event_attendees a WHERE a.event_id = p_event AND a.user_id = auth.uid()),
    'default_visibility', COALESCE((SELECT p.attendance_visibility FROM public.privacy_preferences p WHERE p.user_id = auth.uid()), 'private')
  );
$$;
REVOKE ALL ON FUNCTION public.get_my_attendance(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_attendance(uuid) TO authenticated;

-- Who else is interested in / going to this event, as the caller may see.
CREATE FUNCTION public.get_event_social(p_event uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_result jsonb;
BEGIN
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM public.require_active_session();

  WITH visible AS (
    SELECT a.user_id, a.status,
      COALESCE(a.visibility, pp.attendance_visibility, 'private') AS vis,
      EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
        AND ((f.requester_id = v_me AND f.receiver_id = a.user_id)
          OR (f.requester_id = a.user_id AND f.receiver_id = v_me))) AS is_friend,
      (SELECT round(m.compatibility)::integer FROM public.user_matches m
        WHERE m.user_id_a = LEAST(v_me, a.user_id) AND m.user_id_b = GREATEST(v_me, a.user_id)
          AND public.may_access_music_match(LEAST(v_me, a.user_id), GREATEST(v_me, a.user_id))) AS compatibility
    FROM public.event_attendees a
    LEFT JOIN public.privacy_preferences pp ON pp.user_id = a.user_id
    WHERE a.event_id = p_event
      AND a.user_id <> v_me
      AND a.status IN ('interested', 'maybe', 'going')
      AND public.may_access_message(v_me, a.user_id)
  ), allowed AS (
    SELECT v.*, (v.compatibility IS NOT NULL) AS is_match
    FROM visible v
    WHERE v.vis = 'public'
       OR (v.vis = 'friends' AND v.is_friend)
       OR (v.vis = 'matches' AND (v.is_friend OR v.compatibility IS NOT NULL))
  ), people AS (
    SELECT al.*, d.username::text AS username, d.display_name, d.avatar_url,
      (SELECT f.status FROM public.friendships f
        WHERE (f.requester_id = v_me AND f.receiver_id = al.user_id)
           OR (f.requester_id = al.user_id AND f.receiver_id = v_me)
        ORDER BY (f.status = 'accepted') DESC LIMIT 1) AS connection
    FROM allowed al
    JOIN public.profile_discovery d ON d.id = al.user_id
  )
  SELECT jsonb_build_object(
    'counts', jsonb_build_object(
      'going', (SELECT count(*) FROM people WHERE status = 'going'),
      'maybe', (SELECT count(*) FROM people WHERE status = 'maybe'),
      'interested', (SELECT count(*) FROM people WHERE status = 'interested')
    ),
    'people', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
          'user_id', p.user_id, 'username', p.username, 'display_name', p.display_name,
          'avatar_url', p.avatar_url, 'status', p.status, 'is_friend', p.is_friend,
          'compatibility', p.compatibility, 'connection', p.connection)
        ORDER BY p.is_friend DESC, (p.status = 'going') DESC, p.compatibility DESC NULLS LAST, p.username)
      FROM (SELECT * FROM people
            ORDER BY is_friend DESC, (status = 'going') DESC, compatibility DESC NULLS LAST, username
            LIMIT 60) p), '[]'::jsonb),
    'communities', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('id', c.id, 'name', c.name, 'kind', c.kind, 'member_count', c.member_count)
        ORDER BY (c.kind = 'artist') DESC, c.member_count DESC)
      FROM (
        SELECT c.* FROM public.communities c, public.events e
        WHERE e.id = p_event AND c.archived_at IS NULL
          AND ((c.kind = 'artist' AND lower(c.artist_name) = lower(e.artist_name))
            OR (c.kind = 'genre' AND c.genre_key = c.genre_family
                AND vibra_private.radar_genre_match(e.genres, ARRAY[c.genre_family])))
        ORDER BY (c.kind = 'artist') DESC, c.member_count DESC
        LIMIT 3) c), '[]'::jsonb)
  ) INTO v_result;
  RETURN v_result;
END;
$$;
REVOKE ALL ON FUNCTION public.get_event_social(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_event_social(uuid) TO authenticated;

-- Same Frequency's opt-in shared events now include "interested".
CREATE OR REPLACE FUNCTION public.same_frequency_signals(p_other uuid)
RETURNS TABLE (
  shared_discoveries text[], rising_families text[],
  shared_events integer, shared_event jsonb,
  times_shown integer, last_shown_at timestamptz, saved boolean
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_dna_visible boolean;
  v_events boolean;
BEGIN
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF v_me = p_other OR NOT EXISTS (
      SELECT 1 FROM public.user_matches m
      WHERE m.user_id_a = LEAST(v_me, p_other) AND m.user_id_b = GREATEST(v_me, p_other))
     OR NOT public.may_access_music_match(LEAST(v_me, p_other), GREATEST(v_me, p_other)) THEN
    RETURN;
  END IF;
  SELECT COALESCE(p.musical_dna_visibility IN ('public', 'matches'), false) INTO v_dna_visible
  FROM public.privacy_preferences p WHERE p.user_id = p_other;
  SELECT count(*) = 2 INTO v_events FROM public.privacy_preferences p
  WHERE p.user_id IN (v_me, p_other) AND p.same_frequency_events;

  RETURN QUERY
  SELECT
    CASE WHEN COALESCE(v_dna_visible, false) THEN ARRAY(
      SELECT o.name FROM public.dna_new_artists(p_other) o
      JOIN public.dna_new_artists(v_me) m ON m.key = o.key
      WHERE NULLIF(o.name, '') IS NOT NULL ORDER BY o.name LIMIT 3
    ) ELSE '{}'::text[] END,
    CASE WHEN COALESCE(v_dna_visible, false) THEN ARRAY(
      SELECT o.family FROM public.dna_rising_families(p_other) o
      JOIN public.dna_rising_families(v_me) m ON m.family = o.family
      ORDER BY LEAST(o.delta, m.delta) DESC, o.family LIMIT 2
    ) ELSE '{}'::text[] END,
    CASE WHEN COALESCE(v_events, false) THEN (
      SELECT count(*)::integer FROM public.events e
      WHERE e.event_date >= now()
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = v_me AND a.status IN ('interested', 'going', 'maybe'))
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = p_other AND a.status IN ('interested', 'going', 'maybe'))
    ) ELSE 0 END,
    CASE WHEN COALESCE(v_events, false) THEN (
      SELECT jsonb_build_object('id', e.id, 'name', e.name, 'artist', e.artist_name, 'date', e.event_date, 'city', e.city)
      FROM public.events e
      WHERE e.event_date >= now()
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = v_me AND a.status IN ('interested', 'going', 'maybe'))
        AND EXISTS (SELECT 1 FROM public.event_attendees a WHERE a.event_id = e.id AND a.user_id = p_other AND a.status IN ('interested', 'going', 'maybe'))
      ORDER BY e.event_date LIMIT 1
    ) ELSE NULL END,
    COALESCE((SELECT v.times_shown FROM public.same_frequency_views v WHERE v.user_id = v_me AND v.shown_user_id = p_other), 0),
    (SELECT v.last_shown_at FROM public.same_frequency_views v WHERE v.user_id = v_me AND v.shown_user_id = p_other),
    EXISTS (SELECT 1 FROM public.saved_profiles s WHERE s.user_id = v_me AND s.saved_user_id = p_other);
END;
$$;

NOTIFY pgrst, 'reload schema';
COMMIT;
