-- VIBRA Circles (docs/circles.md): small, invite-only music groups.
--
-- Consent model
-- * Nobody is ever added to a circle by someone else. Membership comes from
--   creating a circle or ACCEPTING an invitation; VIBRA's automatic
--   suggestions only propose a circle to one user, who decides whether to
--   send invitations.
-- * You can invite only people you already have a relationship with: an
--   accepted connection, or a cached musical-affinity pair (both consented
--   to musical matching). Blocks and test segments always apply.
-- * A declined invitation cannot be re-sent to the same circle for 30 days;
--   invitations expire after 14 days; invites are rate-limited.
-- * Circle content (chat, playlist, events, members) is readable by members
--   only. Messages from someone you blocked are hidden from you.
-- * Notifications: invitations and messages reach members through the
--   existing notification worker; each member can mute a circle.
BEGIN;

CREATE TABLE public.circles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (char_length(btrim(name)) BETWEEN 3 AND 50),
  description text NOT NULL DEFAULT '' CHECK (char_length(description) <= 300),
  basis text NOT NULL CHECK (basis IN ('genre', 'artist', 'concert', 'interest', 'activity')),
  genre_key text CHECK (genre_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length(genre_key) <= 40),
  artist_name text CHECK (char_length(btrim(artist_name)) BETWEEN 1 AND 80),
  event_id uuid REFERENCES public.events(id) ON DELETE SET NULL,
  topic text CHECK (char_length(btrim(topic)) BETWEEN 1 AND 60),
  max_members smallint NOT NULL DEFAULT 12 CHECK (max_members BETWEEN 2 AND 12),
  member_count smallint NOT NULL DEFAULT 0,
  created_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);

CREATE TABLE public.circle_members (
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'admin')),
  muted boolean NOT NULL DEFAULT false,
  -- Participation in the circle's concert, shared with the circle only.
  event_status text CHECK (event_status IN ('interested', 'maybe', 'going')),
  joined_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (circle_id, user_id)
);

-- Banned people cannot be invited again or accept an old invitation.
CREATE TABLE public.circle_bans (
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  banned_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (circle_id, user_id)
);
CREATE INDEX circle_members_user_idx ON public.circle_members (user_id);

CREATE TABLE public.circle_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  inviter_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  invitee_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'revoked')),
  created_at timestamptz NOT NULL DEFAULT now(),
  responded_at timestamptz,
  expires_at timestamptz NOT NULL DEFAULT now() + interval '14 days',
  CHECK (inviter_id <> invitee_id)
);
CREATE UNIQUE INDEX circle_invitations_pending ON public.circle_invitations (circle_id, invitee_id)
  WHERE status = 'pending';
CREATE INDEX circle_invitations_invitee ON public.circle_invitations (invitee_id, status);

CREATE TABLE public.circle_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  body text NOT NULL CHECK (char_length(btrim(body)) BETWEEN 1 AND 2000),
  held_for_review boolean NOT NULL DEFAULT false,
  removed_at timestamptz,
  removed_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX circle_messages_feed ON public.circle_messages (circle_id, created_at DESC);

CREATE TABLE public.circle_playlist_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  added_by uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  url text NOT NULL CHECK (char_length(url) <= 300),
  title text CHECK (char_length(title) <= 120),
  artist text CHECK (char_length(artist) <= 80),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX circle_playlist_idx ON public.circle_playlist_items (circle_id, created_at DESC);

CREATE TABLE public.circle_events (
  circle_id uuid NOT NULL REFERENCES public.circles(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  added_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (circle_id, event_id)
);

-- ── Helpers ───────────────────────────────────────────────────────────────
CREATE FUNCTION public.is_circle_member(p_circle uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT EXISTS (SELECT 1 FROM public.circle_members m
    JOIN public.circles c ON c.id = m.circle_id AND c.archived_at IS NULL
    WHERE m.circle_id = p_circle AND m.user_id = auth.uid());
$$;
REVOKE ALL ON FUNCTION public.is_circle_member(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_circle_member(uuid) TO authenticated;

CREATE FUNCTION vibra_private.require_circle_role(p_circle uuid, p_admin boolean)
RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_role text;
BEGIN
  SELECT m.role INTO v_role FROM public.circle_members m
  JOIN public.circles c ON c.id = m.circle_id AND c.archived_at IS NULL
  WHERE m.circle_id = p_circle AND m.user_id = auth.uid();
  IF v_role IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'circle_membership_required'; END IF;
  IF p_admin AND v_role <> 'admin' THEN RAISE insufficient_privilege USING MESSAGE = 'circle_admin_required'; END IF;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.require_circle_role(uuid, boolean) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION public.is_circle_admin(p_circle uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT EXISTS (SELECT 1 FROM public.circle_members m
    WHERE m.circle_id = p_circle AND m.user_id = auth.uid() AND m.role = 'admin');
$$;
REVOKE ALL ON FUNCTION public.is_circle_admin(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_circle_admin(uuid) TO authenticated;

-- Who may be invited by whom: an accepted connection or a mutual affinity
-- pair, never someone blocked or in another test segment.
CREATE FUNCTION vibra_private.may_invite_to_circle(p_inviter uuid, p_invitee uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT p_inviter <> p_invitee
    AND public.may_access_message(p_inviter, p_invitee)
    AND (
      EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
        AND ((f.requester_id = p_inviter AND f.receiver_id = p_invitee)
          OR (f.requester_id = p_invitee AND f.receiver_id = p_inviter)))
      OR (EXISTS (SELECT 1 FROM public.user_matches m
            WHERE m.user_id_a = LEAST(p_inviter, p_invitee) AND m.user_id_b = GREATEST(p_inviter, p_invitee))
          AND public.may_access_music_match(LEAST(p_inviter, p_invitee), GREATEST(p_inviter, p_invitee)))
    );
$$;
REVOKE ALL ON FUNCTION vibra_private.may_invite_to_circle(uuid, uuid) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION vibra_private.music_link_ok(p_url text)
RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT p_url IS NOT NULL AND char_length(p_url) <= 300 AND p_url ~* '^https://(open\.spotify\.com|music\.apple\.com|music\.youtube\.com|(www\.)?youtube\.com|youtu\.be|soundcloud\.com|[a-z0-9-]+\.bandcamp\.com)/';
$$;
REVOKE ALL ON FUNCTION vibra_private.music_link_ok(text) FROM PUBLIC, anon, authenticated;

-- ── Rate limits ───────────────────────────────────────────────────────────
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
    WHEN 'delete-account' THEN 3 WHEN 'music-radar' THEN 6
    WHEN 'community-create' THEN 2 WHEN 'community-join' THEN 20 WHEN 'community-post' THEN 5
    WHEN 'community-comment' THEN 10 WHEN 'community-reaction' THEN 60 WHEN 'community-moderate' THEN 30
    WHEN 'circle-create' THEN 2 WHEN 'circle-invite' THEN 10 WHEN 'circle-message' THEN 20
    WHEN 'circle-update' THEN 20
    ELSE NULL END;
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

-- ── RLS: members read, nobody writes directly ─────────────────────────────
ALTER TABLE public.circles ENABLE ROW LEVEL SECURITY;
CREATE POLICY circles_read ON public.circles FOR SELECT TO authenticated
  USING (archived_at IS NULL AND (public.is_circle_member(id)
    OR EXISTS (SELECT 1 FROM public.circle_invitations i WHERE i.circle_id = circles.id
      AND i.invitee_id = (SELECT auth.uid()) AND i.status = 'pending' AND i.expires_at > now())));

ALTER TABLE public.circle_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_members_read ON public.circle_members FOR SELECT TO authenticated
  USING (public.is_circle_member(circle_id));

ALTER TABLE public.circle_invitations ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_invitations_read ON public.circle_invitations FOR SELECT TO authenticated
  USING (invitee_id = (SELECT auth.uid()) OR inviter_id = (SELECT auth.uid()) OR public.is_circle_member(circle_id));

ALTER TABLE public.circle_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_messages_read ON public.circle_messages FOR SELECT TO authenticated
  USING (public.is_circle_member(circle_id)
    AND removed_at IS NULL
    AND (NOT held_for_review OR sender_id = (SELECT auth.uid()) OR public.is_circle_admin(circle_id))
    AND (sender_id = (SELECT auth.uid()) OR public.may_access_message((SELECT auth.uid()), sender_id)));

ALTER TABLE public.circle_bans ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_bans_read ON public.circle_bans FOR SELECT TO authenticated
  USING (public.is_circle_admin(circle_id));
REVOKE ALL ON public.circle_bans FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.circle_bans TO authenticated;
GRANT ALL ON public.circle_bans TO service_role;

ALTER TABLE public.circle_playlist_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_playlist_read ON public.circle_playlist_items FOR SELECT TO authenticated
  USING (public.is_circle_member(circle_id));

ALTER TABLE public.circle_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY circle_events_read ON public.circle_events FOR SELECT TO authenticated
  USING (public.is_circle_member(circle_id));

REVOKE ALL ON public.circles, public.circle_members, public.circle_invitations, public.circle_messages,
  public.circle_playlist_items, public.circle_events FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.circles, public.circle_members, public.circle_invitations, public.circle_messages,
  public.circle_playlist_items, public.circle_events TO authenticated;
GRANT ALL ON public.circles, public.circle_members, public.circle_invitations, public.circle_messages,
  public.circle_playlist_items, public.circle_events TO service_role;

-- Group chat is delivered through Realtime (RLS applies to subscribers).
ALTER PUBLICATION supabase_realtime ADD TABLE public.circle_messages;

-- ── Create, edit, leave ───────────────────────────────────────────────────
CREATE FUNCTION public.create_circle(
  p_name text, p_description text, p_basis text,
  p_genre_key text DEFAULT NULL, p_artist_name text DEFAULT NULL,
  p_event_id uuid DEFAULT NULL, p_topic text DEFAULT NULL
)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM public.consume_action_limit('circle-create');
  IF (SELECT count(*) FROM public.circles WHERE created_by = v_me AND created_at > now() - interval '1 day') >= 5 THEN
    RAISE check_violation USING MESSAGE = 'circle_daily_limit';
  END IF;
  IF (SELECT count(*) FROM public.circle_members m JOIN public.circles c ON c.id = m.circle_id
      WHERE m.user_id = v_me AND c.archived_at IS NULL) >= 30 THEN
    RAISE check_violation USING MESSAGE = 'circle_membership_limit';
  END IF;
  PERFORM vibra_private.community_text_guard(p_name);
  PERFORM vibra_private.community_text_guard(p_description);
  IF p_basis = 'concert' AND NOT EXISTS (SELECT 1 FROM public.events WHERE id = p_event_id) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'event_not_found';
  END IF;
  INSERT INTO public.circles (name, description, basis, genre_key, artist_name, event_id, topic, created_by, member_count)
  VALUES (btrim(p_name), COALESCE(btrim(p_description), ''), p_basis,
    CASE WHEN p_basis = 'genre' THEN p_genre_key END,
    CASE WHEN p_basis = 'artist' THEN NULLIF(btrim(p_artist_name), '') END,
    CASE WHEN p_basis = 'concert' THEN p_event_id END,
    CASE WHEN p_basis IN ('interest', 'activity') THEN NULLIF(btrim(p_topic), '') END,
    v_me, 1)
  RETURNING id INTO v_id;
  INSERT INTO public.circle_members (circle_id, user_id, role) VALUES (v_id, v_me, 'admin');
  IF p_basis = 'concert' THEN
    INSERT INTO public.circle_events (circle_id, event_id, added_by) VALUES (v_id, p_event_id, v_me);
  END IF;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_circle(text, text, text, text, text, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_circle(text, text, text, text, text, uuid, text) TO authenticated;

CREATE FUNCTION public.update_circle(p_circle uuid, p_name text DEFAULT NULL, p_description text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, true);
  PERFORM public.consume_action_limit('circle-update');
  PERFORM vibra_private.community_text_guard(p_name);
  PERFORM vibra_private.community_text_guard(p_description);
  UPDATE public.circles SET
    name = COALESCE(NULLIF(btrim(p_name), ''), name),
    description = COALESCE(btrim(p_description), description)
  WHERE id = p_circle;
END;
$$;
REVOKE ALL ON FUNCTION public.update_circle(uuid, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.update_circle(uuid, text, text) TO authenticated;

-- Leaving: the last admin hands over to the longest-standing member; an
-- empty circle is archived.
CREATE FUNCTION public.leave_circle(p_circle uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_role text;
BEGIN
  PERFORM public.require_active_session();
  DELETE FROM public.circle_members WHERE circle_id = p_circle AND user_id = v_me RETURNING role INTO v_role;
  IF v_role IS NULL THEN RETURN; END IF;
  UPDATE public.circles SET member_count = GREATEST(member_count - 1, 0) WHERE id = p_circle;
  IF NOT EXISTS (SELECT 1 FROM public.circle_members WHERE circle_id = p_circle) THEN
    UPDATE public.circles SET archived_at = now() WHERE id = p_circle;
    UPDATE public.circle_invitations SET status = 'revoked', responded_at = now()
    WHERE circle_id = p_circle AND status = 'pending';
  ELSIF v_role = 'admin' AND NOT EXISTS (SELECT 1 FROM public.circle_members WHERE circle_id = p_circle AND role = 'admin') THEN
    UPDATE public.circle_members SET role = 'admin'
    WHERE circle_id = p_circle AND user_id = (SELECT user_id FROM public.circle_members
      WHERE circle_id = p_circle ORDER BY joined_at LIMIT 1);
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.leave_circle(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.leave_circle(uuid) TO authenticated;

CREATE FUNCTION public.set_circle_muted(p_circle uuid, p_muted boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  UPDATE public.circle_members SET muted = COALESCE(p_muted, false)
  WHERE circle_id = p_circle AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.set_circle_muted(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_circle_muted(uuid, boolean) TO authenticated;

-- ── Member management (admins) ────────────────────────────────────────────
CREATE FUNCTION public.manage_circle_member(p_circle uuid, p_user uuid, p_action text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, true);
  PERFORM public.consume_action_limit('circle-update');
  IF p_user = auth.uid() THEN RAISE invalid_parameter_value USING MESSAGE = 'use_leave'; END IF;
  CASE p_action
    WHEN 'remove' THEN
      DELETE FROM public.circle_members WHERE circle_id = p_circle AND user_id = p_user;
      IF FOUND THEN
        UPDATE public.circles SET member_count = GREATEST(member_count - 1, 0) WHERE id = p_circle;
      END IF;
    WHEN 'make_admin' THEN
      UPDATE public.circle_members SET role = 'admin' WHERE circle_id = p_circle AND user_id = p_user;
    WHEN 'make_member' THEN
      UPDATE public.circle_members SET role = 'member' WHERE circle_id = p_circle AND user_id = p_user;
    WHEN 'ban' THEN
      INSERT INTO public.circle_bans (circle_id, user_id, banned_by) VALUES (p_circle, p_user, auth.uid())
      ON CONFLICT DO NOTHING;
      DELETE FROM public.circle_members WHERE circle_id = p_circle AND user_id = p_user;
      IF FOUND THEN
        UPDATE public.circles SET member_count = GREATEST(member_count - 1, 0) WHERE id = p_circle;
      END IF;
      UPDATE public.circle_invitations SET status = 'revoked', responded_at = now()
      WHERE circle_id = p_circle AND invitee_id = p_user AND status = 'pending';
    WHEN 'unban' THEN
      DELETE FROM public.circle_bans WHERE circle_id = p_circle AND user_id = p_user;
    ELSE RAISE invalid_parameter_value USING MESSAGE = 'invalid_action';
  END CASE;
END;
$$;
REVOKE ALL ON FUNCTION public.manage_circle_member(uuid, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.manage_circle_member(uuid, uuid, text) TO authenticated;

-- ── Invitations (consent) ─────────────────────────────────────────────────
CREATE FUNCTION public.invite_to_circle(p_circle uuid, p_user uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_circle public.circles%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, true);
  PERFORM public.consume_action_limit('circle-invite');
  IF (SELECT count(*) FROM public.circle_invitations WHERE inviter_id = v_me AND created_at > now() - interval '1 day') >= 40 THEN
    RAISE check_violation USING MESSAGE = 'circle_invite_daily_limit';
  END IF;
  SELECT * INTO v_circle FROM public.circles WHERE id = p_circle FOR UPDATE;
  IF NOT vibra_private.may_invite_to_circle(v_me, p_user) THEN
    RAISE insufficient_privilege USING MESSAGE = 'circle_invite_not_allowed';
  END IF;
  IF EXISTS (SELECT 1 FROM public.circle_members WHERE circle_id = p_circle AND user_id = p_user) THEN
    RAISE unique_violation USING MESSAGE = 'already_member';
  END IF;
  IF EXISTS (SELECT 1 FROM public.circle_bans WHERE circle_id = p_circle AND user_id = p_user) THEN
    RAISE insufficient_privilege USING MESSAGE = 'circle_banned';
  END IF;
  IF EXISTS (SELECT 1 FROM public.circle_invitations WHERE circle_id = p_circle AND invitee_id = p_user
      AND status = 'declined' AND responded_at > now() - interval '30 days') THEN
    RAISE check_violation USING MESSAGE = 'circle_invite_declined_recently';
  END IF;
  IF v_circle.member_count + (SELECT count(*) FROM public.circle_invitations
      WHERE circle_id = p_circle AND status = 'pending' AND expires_at > now()) >= v_circle.max_members THEN
    RAISE check_violation USING MESSAGE = 'circle_full';
  END IF;
  -- An expired pending invitation is replaced by the new one.
  UPDATE public.circle_invitations SET status = 'revoked', responded_at = now()
  WHERE circle_id = p_circle AND invitee_id = p_user AND status = 'pending' AND expires_at <= now();
  INSERT INTO public.circle_invitations (circle_id, inviter_id, invitee_id) VALUES (p_circle, v_me, p_user)
  ON CONFLICT DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.invite_to_circle(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.invite_to_circle(uuid, uuid) TO authenticated;

-- The invitee accepts or declines; the inviter (or an admin) can revoke.
CREATE FUNCTION public.respond_circle_invitation(p_invitation uuid, p_accept boolean)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_inv public.circle_invitations%ROWTYPE; v_circle public.circles%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  SELECT * INTO v_inv FROM public.circle_invitations WHERE id = p_invitation AND invitee_id = v_me FOR UPDATE;
  IF NOT FOUND OR v_inv.status <> 'pending' OR v_inv.expires_at <= now() THEN
    RAISE no_data_found USING MESSAGE = 'invitation_not_found';
  END IF;
  IF NOT p_accept THEN
    UPDATE public.circle_invitations SET status = 'declined', responded_at = now() WHERE id = p_invitation;
    RETURN NULL;
  END IF;
  SELECT * INTO v_circle FROM public.circles WHERE id = v_inv.circle_id FOR UPDATE;
  IF v_circle.archived_at IS NOT NULL THEN RAISE no_data_found USING MESSAGE = 'invitation_not_found'; END IF;
  IF v_circle.member_count >= v_circle.max_members THEN RAISE check_violation USING MESSAGE = 'circle_full'; END IF;
  -- Blocks created after the invitation, and bans, still win.
  IF NOT public.may_access_message(v_me, v_inv.inviter_id)
     OR EXISTS (SELECT 1 FROM public.circle_bans WHERE circle_id = v_inv.circle_id AND user_id = v_me) THEN
    RAISE no_data_found USING MESSAGE = 'invitation_not_found';
  END IF;
  INSERT INTO public.circle_members (circle_id, user_id) VALUES (v_inv.circle_id, v_me) ON CONFLICT DO NOTHING;
  UPDATE public.circles SET member_count = member_count + 1 WHERE id = v_inv.circle_id;
  UPDATE public.circle_invitations SET status = 'accepted', responded_at = now() WHERE id = p_invitation;
  RETURN v_inv.circle_id;
END;
$$;
REVOKE ALL ON FUNCTION public.respond_circle_invitation(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.respond_circle_invitation(uuid, boolean) TO authenticated;

CREATE FUNCTION public.revoke_circle_invitation(p_invitation uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_inv public.circle_invitations%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  SELECT * INTO v_inv FROM public.circle_invitations WHERE id = p_invitation AND status = 'pending';
  IF NOT FOUND THEN RETURN; END IF;
  IF v_inv.inviter_id <> auth.uid() THEN PERFORM vibra_private.require_circle_role(v_inv.circle_id, true); END IF;
  UPDATE public.circle_invitations SET status = 'revoked', responded_at = now() WHERE id = p_invitation;
END;
$$;
REVOKE ALL ON FUNCTION public.revoke_circle_invitation(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.revoke_circle_invitation(uuid) TO authenticated;

-- People the caller may invite to this circle (connections and mutual
-- affinity pairs), excluding members, pending and recently declined.
CREATE FUNCTION public.get_circle_invite_candidates(p_circle uuid)
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text, compatibility integer)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid();
BEGIN
  PERFORM vibra_private.require_circle_role(p_circle, true);
  RETURN QUERY
  WITH pool AS (
    SELECT CASE WHEN f.requester_id = v_me THEN f.receiver_id ELSE f.requester_id END AS id
    FROM public.friendships f
    WHERE f.status = 'accepted' AND (f.requester_id = v_me OR f.receiver_id = v_me)
    UNION
    SELECT CASE WHEN m.user_id_a = v_me THEN m.user_id_b ELSE m.user_id_a END
    FROM public.user_matches m WHERE m.user_id_a = v_me OR m.user_id_b = v_me
  )
  SELECT d.id, d.username::text, d.display_name, d.avatar_url,
    (SELECT round(m.compatibility)::integer FROM public.user_matches m
      WHERE m.user_id_a = LEAST(v_me, d.id) AND m.user_id_b = GREATEST(v_me, d.id))
  FROM pool p
  JOIN public.profile_discovery d ON d.id = p.id
  WHERE vibra_private.may_invite_to_circle(v_me, p.id)
    AND NOT EXISTS (SELECT 1 FROM public.circle_members cm WHERE cm.circle_id = p_circle AND cm.user_id = p.id)
    AND NOT EXISTS (SELECT 1 FROM public.circle_bans b WHERE b.circle_id = p_circle AND b.user_id = p.id)
    AND NOT EXISTS (SELECT 1 FROM public.circle_invitations i WHERE i.circle_id = p_circle AND i.invitee_id = p.id
      AND ((i.status = 'pending' AND i.expires_at > now()) OR (i.status = 'declined' AND i.responded_at > now() - interval '30 days')))
  ORDER BY 5 DESC NULLS LAST, 2
  LIMIT 100;
END;
$$;
REVOKE ALL ON FUNCTION public.get_circle_invite_candidates(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_invite_candidates(uuid) TO authenticated;

-- ── Chat, playlist, events ────────────────────────────────────────────────
CREATE FUNCTION public.send_circle_message(p_circle uuid, p_body text)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, false);
  PERFORM public.consume_action_limit('circle-message');
  PERFORM vibra_private.community_text_guard(p_body);
  INSERT INTO public.circle_messages (circle_id, sender_id, body) VALUES (p_circle, auth.uid(), btrim(p_body))
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.send_circle_message(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.send_circle_message(uuid, text) TO authenticated;

CREATE FUNCTION public.add_circle_playlist_item(p_circle uuid, p_url text, p_title text DEFAULT NULL, p_artist text DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, false);
  PERFORM public.consume_action_limit('circle-update');
  IF NOT vibra_private.music_link_ok(btrim(p_url)) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_music_link';
  END IF;
  IF (SELECT count(*) FROM public.circle_playlist_items WHERE circle_id = p_circle) >= 200 THEN
    RAISE check_violation USING MESSAGE = 'circle_playlist_limit';
  END IF;
  INSERT INTO public.circle_playlist_items (circle_id, added_by, url, title, artist)
  VALUES (p_circle, auth.uid(), btrim(p_url), left(NULLIF(btrim(p_title), ''), 120), left(NULLIF(btrim(p_artist), ''), 80))
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.add_circle_playlist_item(uuid, text, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_circle_playlist_item(uuid, text, text, text) TO authenticated;

-- The person who added an item, or an admin, removes it.
CREATE FUNCTION public.remove_circle_playlist_item(p_item uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_item public.circle_playlist_items%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  SELECT * INTO v_item FROM public.circle_playlist_items WHERE id = p_item;
  IF NOT FOUND THEN RETURN; END IF;
  PERFORM vibra_private.require_circle_role(v_item.circle_id, v_item.added_by <> auth.uid());
  DELETE FROM public.circle_playlist_items WHERE id = p_item;
END;
$$;
REVOKE ALL ON FUNCTION public.remove_circle_playlist_item(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.remove_circle_playlist_item(uuid) TO authenticated;

CREATE FUNCTION public.set_circle_event(p_circle uuid, p_event uuid, p_shared boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, false);
  PERFORM public.consume_action_limit('circle-update');
  IF p_shared THEN
    IF NOT EXISTS (SELECT 1 FROM public.events WHERE id = p_event) THEN
      RAISE invalid_parameter_value USING MESSAGE = 'event_not_found';
    END IF;
    IF (SELECT count(*) FROM public.circle_events WHERE circle_id = p_circle) >= 50 THEN
      RAISE check_violation USING MESSAGE = 'circle_events_limit';
    END IF;
    INSERT INTO public.circle_events (circle_id, event_id, added_by) VALUES (p_circle, p_event, auth.uid())
    ON CONFLICT DO NOTHING;
  ELSE
    DELETE FROM public.circle_events WHERE circle_id = p_circle AND event_id = p_event;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_circle_event(uuid, uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_circle_event(uuid, uuid, boolean) TO authenticated;

-- ── Reads ─────────────────────────────────────────────────────────────────
CREATE FUNCTION public.get_my_circles()
RETURNS TABLE (
  id uuid, name text, description text, basis text, genre_key text, artist_name text,
  event_id uuid, topic text, member_count smallint, max_members smallint, my_role text,
  muted boolean, last_message_at timestamptz
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT c.id, c.name, c.description, c.basis, c.genre_key, c.artist_name, c.event_id, c.topic,
    c.member_count, c.max_members, m.role, m.muted,
    (SELECT max(x.created_at) FROM public.circle_messages x WHERE x.circle_id = c.id)
  FROM public.circle_members m
  JOIN public.circles c ON c.id = m.circle_id
  WHERE m.user_id = auth.uid() AND c.archived_at IS NULL
  ORDER BY 13 DESC NULLS LAST, c.created_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_my_circles() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_circles() TO authenticated;

CREATE FUNCTION public.get_my_circle_invitations()
RETURNS TABLE (
  id uuid, circle_id uuid, circle_name text, circle_description text, basis text,
  member_count smallint, inviter_id uuid, inviter_username text, inviter_display_name text,
  inviter_avatar_url text, created_at timestamptz
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT i.id, c.id, c.name, c.description, c.basis, c.member_count, i.inviter_id,
    d.username::text, d.display_name, d.avatar_url, i.created_at
  FROM public.circle_invitations i
  JOIN public.circles c ON c.id = i.circle_id AND c.archived_at IS NULL
  JOIN public.users_public d ON d.id = i.inviter_id
  WHERE i.invitee_id = auth.uid() AND i.status = 'pending' AND i.expires_at > now()
  ORDER BY i.created_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_my_circle_invitations() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_circle_invitations() TO authenticated;

CREATE FUNCTION public.get_circle_members(p_circle uuid)
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text, role text, joined_at timestamptz, event_status text)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT m.user_id, d.username::text, d.display_name, d.avatar_url, m.role, m.joined_at, m.event_status
  FROM public.circle_members m
  JOIN public.profile_discovery d ON d.id = m.user_id
  WHERE m.circle_id = p_circle
  ORDER BY (m.role = 'admin') DESC, m.joined_at;
$$;
REVOKE ALL ON FUNCTION public.get_circle_members(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_members(uuid) TO authenticated;

CREATE FUNCTION public.get_circle_pending_invitations(p_circle uuid)
RETURNS TABLE (id uuid, invitee_id uuid, username text, display_name text, avatar_url text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT i.id, i.invitee_id, d.username::text, d.display_name, d.avatar_url, i.created_at
  FROM public.circle_invitations i
  JOIN public.profile_discovery d ON d.id = i.invitee_id
  WHERE i.circle_id = p_circle AND i.status = 'pending' AND i.expires_at > now()
    AND public.is_circle_member(p_circle)
  ORDER BY i.created_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_circle_pending_invitations(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_pending_invitations(uuid) TO authenticated;

CREATE FUNCTION public.get_circle_messages(p_circle uuid, p_before timestamptz DEFAULT NULL, p_limit integer DEFAULT 50)
RETURNS TABLE (id uuid, circle_id uuid, sender_id uuid, username text, display_name text, avatar_url text, body text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT x.id, x.circle_id, x.sender_id, d.username::text, d.display_name, d.avatar_url, x.body, x.created_at
  FROM public.circle_messages x
  LEFT JOIN public.profile_discovery d ON d.id = x.sender_id
  WHERE x.circle_id = p_circle AND x.removed_at IS NULL AND (p_before IS NULL OR x.created_at < p_before)
  ORDER BY x.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 100);
$$;
REVOKE ALL ON FUNCTION public.get_circle_messages(uuid, timestamptz, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_messages(uuid, timestamptz, integer) TO authenticated;

CREATE FUNCTION public.get_circle_playlist(p_circle uuid)
RETURNS TABLE (id uuid, url text, title text, artist text, added_by uuid, added_by_username text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT p.id, p.url, p.title, p.artist, p.added_by, d.username::text, p.created_at
  FROM public.circle_playlist_items p
  LEFT JOIN public.profile_discovery d ON d.id = p.added_by
  WHERE p.circle_id = p_circle
  ORDER BY p.created_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_circle_playlist(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_playlist(uuid) TO authenticated;

CREATE FUNCTION public.get_circle_events(p_circle uuid)
RETURNS SETOF jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT to_jsonb(e) - 'location'
  FROM public.circle_events ce JOIN public.events e ON e.id = ce.event_id
  WHERE ce.circle_id = p_circle AND e.event_date >= now() - interval '1 day'
  ORDER BY e.event_date;
$$;
REVOKE ALL ON FUNCTION public.get_circle_events(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_circle_events(uuid) TO authenticated;

-- ── Concert groups: participation and moderation ──────────────────────────
-- The caller's participation in the circle's concert, visible to members.
CREATE FUNCTION public.set_circle_event_status(p_circle uuid, p_status text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_circle_role(p_circle, false);
  IF p_status IS NOT NULL AND p_status NOT IN ('interested', 'maybe', 'going') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_status';
  END IF;
  UPDATE public.circle_members SET event_status = p_status
  WHERE circle_id = p_circle AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.set_circle_event_status(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_circle_event_status(uuid, text) TO authenticated;

-- The sender deletes their own message; an admin removes anyone's (and the
-- pending reports on it are marked handled).
CREATE FUNCTION public.remove_circle_message(p_message uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_msg public.circle_messages%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  SELECT * INTO v_msg FROM public.circle_messages WHERE id = p_message;
  IF NOT FOUND THEN RETURN; END IF;
  PERFORM vibra_private.require_circle_role(v_msg.circle_id, v_msg.sender_id <> auth.uid());
  UPDATE public.circle_messages SET removed_at = now(), removed_by = auth.uid(), held_for_review = false
  WHERE id = p_message;
  UPDATE public.reports SET status = 'action_taken' WHERE circle_message_id = p_message AND status = 'pending';
END;
$$;
REVOKE ALL ON FUNCTION public.remove_circle_message(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.remove_circle_message(uuid) TO authenticated;

-- Admins restore a message held after reports.
CREATE FUNCTION public.restore_circle_message(p_message uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_circle uuid;
BEGIN
  PERFORM public.require_active_session();
  SELECT circle_id INTO v_circle FROM public.circle_messages WHERE id = p_message;
  IF v_circle IS NULL THEN RETURN; END IF;
  PERFORM vibra_private.require_circle_role(v_circle, true);
  UPDATE public.circle_messages SET held_for_review = false WHERE id = p_message AND removed_at IS NULL;
  UPDATE public.reports SET status = 'reviewed' WHERE circle_message_id = p_message AND status = 'pending';
END;
$$;
REVOKE ALL ON FUNCTION public.restore_circle_message(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.restore_circle_message(uuid) TO authenticated;

-- Reports: a circle message (by the reported person, seen by the reporter)
-- or a member of a circle the reporter belongs to. Same table, same rate
-- limit and validation as message and community reports. Two distinct
-- reports hold a message for the circle's admins (groups are small).
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS circle_message_id uuid REFERENCES public.circle_messages(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS circle_id uuid REFERENCES public.circles(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION public.protect_report_submission()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog AS $$
BEGIN
  IF current_user IN ('authenticated','anon') THEN
    IF TG_TABLE_NAME='reports' THEN
      IF NEW.status <> 'pending' THEN
        RAISE insufficient_privilege USING MESSAGE='Moderation status is backend-managed';
      END IF;
      IF NEW.message_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.messages m WHERE m.id=NEW.message_id
          AND m.sender_id=NEW.reported_id AND m.receiver_id=auth.uid()
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only received messages may be reported';
      END IF;
      IF NEW.community_post_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.community_posts p WHERE p.id=NEW.community_post_id AND p.author_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible posts may be reported';
      END IF;
      IF NEW.community_comment_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.community_comments c WHERE c.id=NEW.community_comment_id AND c.author_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible comments may be reported';
      END IF;
      -- RLS applies: the message must be visible to the reporter.
      IF NEW.circle_message_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.circle_messages x WHERE x.id=NEW.circle_message_id AND x.sender_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible circle messages may be reported';
      END IF;
      IF NEW.circle_id IS NOT NULL AND NOT (public.is_circle_member(NEW.circle_id) AND EXISTS (
        SELECT 1 FROM public.circle_members m WHERE m.circle_id=NEW.circle_id AND m.user_id=NEW.reported_id
      )) THEN
        RAISE insufficient_privilege USING MESSAGE='Only members of your circles may be reported';
      END IF;
      IF NEW.reported_id = auth.uid() THEN
        RAISE insufficient_privilege USING MESSAGE='You cannot report yourself';
      END IF;
    ELSE
      IF NEW.status <> 'open' OR NEW.responded_at IS NOT NULL THEN
        RAISE insufficient_privilege USING MESSAGE='Support status is backend-managed';
      END IF;
      IF NEW.screenshot_path IS NOT NULL AND
         (split_part(NEW.screenshot_path,'/',1) IS DISTINCT FROM auth.uid()::text OR NEW.screenshot_path LIKE '%..%') THEN
        RAISE insufficient_privilege USING MESSAGE='Support attachment must belong to the sender';
      END IF;
    END IF;
    NEW.created_at=now();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_report_submission() FROM PUBLIC,anon,authenticated;

CREATE FUNCTION vibra_private.hold_reported_circle_message()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.circle_message_id IS NOT NULL AND (
      SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE circle_message_id = NEW.circle_message_id AND status = 'pending') >= 2 THEN
    UPDATE public.circle_messages SET held_for_review = true
    WHERE id = NEW.circle_message_id AND removed_at IS NULL;
  END IF;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.hold_reported_circle_message() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_hold_reported_circle_message AFTER INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION vibra_private.hold_reported_circle_message();

-- Concert groups for one event that the caller belongs to.
CREATE FUNCTION public.get_my_event_circles(p_event uuid)
RETURNS TABLE (id uuid, name text, member_count smallint, my_role text)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT c.id, c.name, c.member_count, m.role
  FROM public.circles c
  JOIN public.circle_members m ON m.circle_id = c.id AND m.user_id = auth.uid()
  WHERE c.archived_at IS NULL
    AND (c.event_id = p_event OR EXISTS (SELECT 1 FROM public.circle_events ce WHERE ce.circle_id = c.id AND ce.event_id = p_event))
  ORDER BY c.created_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_my_event_circles(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_event_circles(uuid) TO authenticated;

-- ── Notifications ─────────────────────────────────────────────────────────
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update',
  'circle_invite', 'circle_message'
));
CREATE TRIGGER circle_invitations_notify AFTER INSERT ON public.circle_invitations
FOR EACH ROW EXECUTE FUNCTION public.notify_social_action();
CREATE TRIGGER circle_messages_notify AFTER INSERT ON public.circle_messages
FOR EACH ROW EXECUTE FUNCTION public.notify_social_action();

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
    'circle_playlist_items', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_playlist_items p WHERE p.added_by = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
