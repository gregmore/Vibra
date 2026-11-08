-- VIBRA Concert Match (docs/concert-match.md): connect through a concert.
--
-- get_concert_matches(event) finds, for the caller:
--   * people whose plans for this event are visible to the caller (same
--     rules as get_event_social: the attendee's own visibility choice,
--     blocks, test segments);
--   * people with a mutual musical-affinity pair (both consented) who share
--     the event's artist, WITHOUT any information about whether they go.
-- Nothing about location, distance, travel or timestamps is returned.
--
-- circle_plans: group activities inside a circle (e.g. "Dinner before the
-- show"). Written by members, visible only to that circle's members; any
-- place is free text the author chose to type.
BEGIN;

CREATE FUNCTION public.get_concert_matches(p_event uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_artist text;
  v_my_status text;
  v_result jsonb;
BEGIN
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM public.require_active_session();
  SELECT lower(btrim(e.artist_name)) INTO v_artist FROM public.events e WHERE e.id = p_event;
  SELECT a.status INTO v_my_status FROM public.event_attendees a
    WHERE a.event_id = p_event AND a.user_id = v_me AND a.status IN ('interested', 'maybe', 'going');

  WITH attendees AS (
    SELECT a.user_id, a.status,
      COALESCE(a.visibility, pp.attendance_visibility, 'private') AS vis
    FROM public.event_attendees a
    LEFT JOIN public.privacy_preferences pp ON pp.user_id = a.user_id
    WHERE a.event_id = p_event AND a.user_id <> v_me
      AND a.status IN ('interested', 'maybe', 'going')
  ), pairs AS (
    -- Mutual affinity pairs of the caller (consent re-checked).
    SELECT CASE WHEN m.user_id_a = v_me THEN m.user_id_b ELSE m.user_id_a END AS user_id,
      round(m.compatibility)::integer AS compatibility, m.details
    FROM public.user_matches m
    WHERE (m.user_id_a = v_me OR m.user_id_b = v_me)
      AND public.may_access_music_match(m.user_id_a, m.user_id_b)
  ), friends AS (
    SELECT CASE WHEN f.requester_id = v_me THEN f.receiver_id ELSE f.requester_id END AS user_id
    FROM public.friendships f
    WHERE f.status = 'accepted' AND (f.requester_id = v_me OR f.receiver_id = v_me)
  ), candidates AS (
    -- Visible attendees.
    SELECT a.user_id, a.status, false AS artist_fan
    FROM attendees a
    WHERE a.vis = 'public'
       OR (a.vis = 'friends' AND a.user_id IN (SELECT user_id FROM friends))
       OR (a.vis = 'matches' AND (a.user_id IN (SELECT user_id FROM friends) OR a.user_id IN (SELECT user_id FROM pairs)))
    UNION ALL
    -- Matches who share this artist (their attendance, if any, stays hidden
    -- unless it is visible above).
    SELECT p.user_id, NULL, true
    FROM pairs p
    WHERE v_artist IS NOT NULL AND char_length(v_artist) >= 2
      AND EXISTS (SELECT 1 FROM jsonb_array_elements_text(COALESCE(p.details->'shared_artists', '[]')) s
                  WHERE lower(s) = v_artist)
  ), merged AS (
    SELECT c.user_id,
      (array_agg(c.status) FILTER (WHERE c.status IS NOT NULL))[1] AS status,
      bool_or(c.artist_fan) AS artist_fan
    FROM candidates c
    WHERE public.may_access_message(v_me, c.user_id)
    GROUP BY c.user_id
  ), people AS (
    SELECT m.user_id, m.status, m.artist_fan, d.username::text AS username, d.display_name, d.avatar_url,
      p.compatibility,
      m.user_id IN (SELECT user_id FROM friends) AS is_friend,
      (SELECT f.status FROM public.friendships f
        WHERE (f.requester_id = v_me AND f.receiver_id = m.user_id)
           OR (f.requester_id = m.user_id AND f.receiver_id = v_me)
        ORDER BY (f.status = 'accepted') DESC LIMIT 1) AS connection
    FROM merged m
    JOIN public.profile_discovery d ON d.id = m.user_id
    LEFT JOIN pairs p ON p.user_id = m.user_id
  )
  SELECT jsonb_build_object(
    'my_status', v_my_status,
    'interested_count', (SELECT count(*) FROM people WHERE status IS NOT NULL),
    'people', COALESCE((
      SELECT jsonb_agg(jsonb_build_object(
          'user_id', x.user_id, 'username', x.username, 'display_name', x.display_name,
          'avatar_url', x.avatar_url, 'status', x.status, 'artist_fan', x.artist_fan,
          'compatibility', x.compatibility, 'is_friend', x.is_friend, 'connection', x.connection,
          'can_invite', x.is_friend OR x.compatibility IS NOT NULL)
        ORDER BY x.rank_status, x.compatibility DESC NULLS LAST, x.username)
      FROM (SELECT p.*, CASE p.status WHEN 'going' THEN 0 WHEN 'maybe' THEN 1 WHEN 'interested' THEN 2 ELSE 3 END AS rank_status
            FROM people p
            ORDER BY rank_status, compatibility DESC NULLS LAST, username
            LIMIT 80) x), '[]'::jsonb)
  ) INTO v_result;
  RETURN v_result;
END;
$$;
REVOKE ALL ON FUNCTION public.get_concert_matches(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_concert_matches(uuid) TO authenticated;

-- ── Group activities inside circles ──────────────────────────────────────
CREATE TABLE public.circle_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  created_by uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 80),
  starts_at timestamptz,
  note text CHECK (char_length(note) <= 300),
  event_id uuid REFERENCES public.events(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX circle_plans_circle_idx ON public.circle_plans (circle_id, starts_at);

CREATE TABLE public.circle_plan_participants (
  plan_id uuid NOT NULL REFERENCES public.circle_plans(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (plan_id, user_id)
);

ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update',
  'circle_invite', 'circle_message', 'circle_plan'
));

ALTER TABLE public.circle_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_plans_read ON public.circle_plans FOR SELECT TO authenticated
  USING (public.is_circle_member(circle_id));
ALTER TABLE public.circle_plan_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_plan_participants_read ON public.circle_plan_participants FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.circle_plans p WHERE p.id = plan_id AND public.is_circle_member(p.circle_id)));
REVOKE ALL ON public.circle_plans, public.circle_plan_participants FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.circle_plans, public.circle_plan_participants TO authenticated;
GRANT ALL ON public.circle_plans, public.circle_plan_participants TO service_role;

-- New plans notify the circle's (unmuted) members via the existing worker.
CREATE TRIGGER circle_plans_notify AFTER INSERT ON public.circle_plans
FOR EACH ROW EXECUTE FUNCTION public.notify_social_action();

CREATE FUNCTION public.add_circle_plan(
  p_circle uuid, p_title text, p_starts_at timestamptz DEFAULT NULL,
  p_note text DEFAULT NULL, p_event uuid DEFAULT NULL
)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, false);
  PERFORM public.consume_action_limit('circle-update');
  PERFORM vibra_private.community_text_guard(p_title);
  PERFORM vibra_private.community_text_guard(p_note);
  IF (SELECT count(*) FROM public.circle_plans WHERE circle_id = p_circle) >= 50 THEN
    RAISE check_violation USING MESSAGE = 'circle_plans_limit';
  END IF;
  INSERT INTO public.circle_plans (circle_id, created_by, title, starts_at, note, event_id)
  VALUES (p_circle, auth.uid(), btrim(p_title), p_starts_at, NULLIF(btrim(p_note), ''), p_event)
  RETURNING id INTO v_id;
  INSERT INTO public.circle_plan_participants (plan_id, user_id) VALUES (v_id, auth.uid());
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.add_circle_plan(uuid, text, timestamptz, text, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_circle_plan(uuid, text, timestamptz, text, uuid) TO authenticated;

-- "I'm in" / "I'm out". Returns true when the caller now joins the plan.
CREATE FUNCTION public.toggle_circle_plan(p_plan uuid)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_circle uuid;
BEGIN
  PERFORM public.require_active_session();
  SELECT circle_id INTO v_circle FROM public.circle_plans WHERE id = p_plan;
  IF v_circle IS NULL THEN RAISE no_data_found USING MESSAGE = 'plan_not_found'; END IF;
  PERFORM vibra_private.require_circle_role(v_circle, false);
  DELETE FROM public.circle_plan_participants WHERE plan_id = p_plan AND user_id = auth.uid();
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.circle_plan_participants (plan_id, user_id) VALUES (p_plan, auth.uid());
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_circle_plan(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_circle_plan(uuid) TO authenticated;

-- The author or an admin removes a plan.
CREATE FUNCTION public.remove_circle_plan(p_plan uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_plan public.circle_plans%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  SELECT * INTO v_plan FROM public.circle_plans WHERE id = p_plan;
  IF NOT FOUND THEN RETURN; END IF;
  PERFORM vibra_private.require_circle_role(v_plan.circle_id, v_plan.created_by <> auth.uid());
  DELETE FROM public.circle_plans WHERE id = p_plan;
END;
$$;
REVOKE ALL ON FUNCTION public.remove_circle_plan(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.remove_circle_plan(uuid) TO authenticated;

CREATE FUNCTION public.get_circle_plans(p_circle uuid)
RETURNS TABLE (
  id uuid, title text, starts_at timestamptz, note text, event_id uuid,
  created_by uuid, participants bigint, joined boolean
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT p.id, p.title, p.starts_at, p.note, p.event_id, p.created_by,
    (SELECT count(*) FROM public.circle_plan_participants x WHERE x.plan_id = p.id),
    EXISTS (SELECT 1 FROM public.circle_plan_participants x WHERE x.plan_id = p.id AND x.user_id = auth.uid())
  FROM public.circle_plans p
  WHERE p.circle_id = p_circle
  ORDER BY p.starts_at NULLS LAST, p.created_at;
$$;
REVOKE ALL ON FUNCTION public.get_circle_plans(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_plans(uuid) TO authenticated;

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
      FROM vibra_private.radar_presence r WHERE r.user_id = uid),
    'community_memberships', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.joined_at) FROM public.community_members m WHERE m.user_id = uid), '[]'::jsonb),
    'community_posts', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.community_posts p WHERE p.author_id = uid), '[]'::jsonb),
    'community_comments', COALESCE((SELECT jsonb_agg(to_jsonb(c) ORDER BY c.created_at) FROM public.community_comments c WHERE c.author_id = uid), '[]'::jsonb),
    'community_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.community_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'circle_memberships', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.joined_at) FROM public.circle_members m WHERE m.user_id = uid), '[]'::jsonb),
    'circle_invitations', COALESCE((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.created_at) FROM public.circle_invitations i WHERE i.inviter_id = uid OR i.invitee_id = uid), '[]'::jsonb),
    'circle_messages', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY x.created_at) FROM public.circle_messages x WHERE x.sender_id = uid), '[]'::jsonb),
    'circle_playlist_items', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_playlist_items p WHERE p.added_by = uid), '[]'::jsonb),
    'circle_plans', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_plans p WHERE p.created_by = uid), '[]'::jsonb),
    'circle_plan_participation', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY x.created_at) FROM public.circle_plan_participants x WHERE x.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
