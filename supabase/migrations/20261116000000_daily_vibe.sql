-- VIBRA Daily Vibe (docs/daily-vibe.md): one song a day.
--
-- * Songs come from Spotify (metadata re-fetched by the daily-vibe Edge
--   Function) or a link to another provider with typed title/artist.
--   Only metadata, the provider-hosted artwork URL and a link back are
--   stored. No audio, previews or copied artwork, ever.
-- * One vibe per user per day (posting again replaces it). Optional 24-hour
--   expiry, enforced in every read and purged hourly.
-- * Visibility: 'connections' (accepted connections and mutual musical
--   matches, the default) or 'everyone'. Blocks and test segments always
--   apply.
-- * Reactions, comments and replies, a personal discovery collection,
--   reports (3 hold a vibe or comment), rate limits and comment
--   notifications.
BEGIN;

CREATE TABLE public.daily_vibes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  vibe_day date NOT NULL DEFAULT current_date,
  provider text NOT NULL CHECK (provider IN ('spotify', 'link')),
  track_id text CHECK (track_id ~ '^[A-Za-z0-9]{22}$'),
  title text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 200),
  artist text NOT NULL CHECK (char_length(artist) BETWEEN 1 AND 300),
  album text CHECK (char_length(album) <= 200),
  artwork_url text CHECK (artwork_url ~ '^https://i\.scdn\.co/'),
  external_url text NOT NULL CHECK (char_length(external_url) <= 300 AND external_url ~ '^https://'),
  caption text CHECK (char_length(caption) <= 200),
  visibility text NOT NULL DEFAULT 'connections' CHECK (visibility IN ('connections', 'everyone')),
  expires_at timestamptz,
  held_for_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, vibe_day),
  CHECK (provider <> 'spotify' OR track_id IS NOT NULL)
);
CREATE INDEX daily_vibes_feed_idx ON public.daily_vibes (created_at DESC);

CREATE TABLE public.daily_vibe_reactions (
  vibe_id uuid NOT NULL REFERENCES public.daily_vibes(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reaction text NOT NULL CHECK (reaction IN ('fire', 'heart', 'headphones', 'clap', 'mind_blown')),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (vibe_id, user_id, reaction)
);

CREATE TABLE public.daily_vibe_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vibe_id uuid NOT NULL REFERENCES public.daily_vibes(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  parent_id uuid REFERENCES public.daily_vibe_comments(id) ON DELETE CASCADE,
  body text NOT NULL CHECK (char_length(btrim(body)) BETWEEN 1 AND 500),
  held_for_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX daily_vibe_comments_idx ON public.daily_vibe_comments (vibe_id, created_at);

CREATE TABLE public.discovery_collection (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  provider text NOT NULL CHECK (provider IN ('spotify', 'link')),
  track_id text,
  title text NOT NULL,
  artist text NOT NULL,
  album text,
  artwork_url text CHECK (artwork_url ~ '^https://i\.scdn\.co/'),
  external_url text NOT NULL,
  from_vibe_id uuid REFERENCES public.daily_vibes(id) ON DELETE SET NULL,
  saved_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, external_url)
);

-- ── Visibility ────────────────────────────────────────────────────────────
CREATE FUNCTION public.can_see_daily_vibe(p_author uuid, p_visibility text, p_expires timestamptz, p_held boolean)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT p_author = auth.uid() OR (
    (p_expires IS NULL OR p_expires > now())
    AND NOT p_held
    AND public.may_access_message(auth.uid(), p_author)
    AND (
      p_visibility = 'everyone'
      OR EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
        AND ((f.requester_id = auth.uid() AND f.receiver_id = p_author)
          OR (f.requester_id = p_author AND f.receiver_id = auth.uid())))
      OR (EXISTS (SELECT 1 FROM public.user_matches m
            WHERE m.user_id_a = LEAST(auth.uid(), p_author) AND m.user_id_b = GREATEST(auth.uid(), p_author))
          AND public.may_access_music_match(LEAST(auth.uid(), p_author), GREATEST(auth.uid(), p_author)))
    )
  );
$$;
REVOKE ALL ON FUNCTION public.can_see_daily_vibe(uuid, text, timestamptz, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.can_see_daily_vibe(uuid, text, timestamptz, boolean) TO authenticated;

ALTER TABLE public.daily_vibes ENABLE ROW LEVEL SECURITY;
CREATE POLICY daily_vibes_read ON public.daily_vibes FOR SELECT TO authenticated
  USING (public.can_see_daily_vibe(user_id, visibility, expires_at, held_for_review));

ALTER TABLE public.daily_vibe_reactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY daily_vibe_reactions_read ON public.daily_vibe_reactions FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.daily_vibes v WHERE v.id = vibe_id));

ALTER TABLE public.daily_vibe_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY daily_vibe_comments_read ON public.daily_vibe_comments FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.daily_vibes v WHERE v.id = vibe_id)
    AND (author_id = (SELECT auth.uid()) OR (NOT held_for_review AND public.may_access_message((SELECT auth.uid()), author_id))));

ALTER TABLE public.discovery_collection ENABLE ROW LEVEL SECURITY;
CREATE POLICY discovery_collection_owner ON public.discovery_collection FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

REVOKE ALL ON public.daily_vibes, public.daily_vibe_reactions, public.daily_vibe_comments, public.discovery_collection
  FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.daily_vibes, public.daily_vibe_reactions, public.daily_vibe_comments, public.discovery_collection
  TO authenticated;
GRANT ALL ON public.daily_vibes, public.daily_vibe_reactions, public.daily_vibe_comments, public.discovery_collection
  TO service_role;

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
    WHEN 'track-search' THEN 20 WHEN 'vibe-comment' THEN 10 WHEN 'vibe-reaction' THEN 60 WHEN 'discovery' THEN 30
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

-- ── Posting (service role: called by the daily-vibe Edge Function) ────────
-- Posting again the same day replaces the vibe (its reactions and comments
-- belonged to the previous song). At most 6 changes a day.
CREATE FUNCTION public.create_daily_vibe(
  p_user_id uuid, p_track jsonb, p_caption text, p_expires boolean, p_visibility text
)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_id uuid;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  PERFORM vibra_private.community_text_guard(p_caption);
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;
  IF (SELECT count(*) FROM vibra_private.daily_vibe_changes WHERE user_id = p_user_id AND changed_at > now() - interval '1 day') >= 6 THEN
    RAISE SQLSTATE 'PT429' USING MESSAGE = 'daily_vibe_rate_limit';
  END IF;
  INSERT INTO vibra_private.daily_vibe_changes (user_id) VALUES (p_user_id);
  DELETE FROM public.daily_vibes WHERE user_id = p_user_id AND vibe_day = current_date;
  INSERT INTO public.daily_vibes (user_id, provider, track_id, title, artist, album, artwork_url, external_url,
    caption, visibility, expires_at)
  VALUES (p_user_id, p_track->>'provider', p_track->>'track_id', p_track->>'title', p_track->>'artist',
    p_track->>'album', p_track->>'artwork_url', p_track->>'external_url',
    NULLIF(btrim(p_caption), ''), COALESCE(p_visibility, 'connections'),
    CASE WHEN COALESCE(p_expires, true) THEN now() + interval '24 hours' END)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_daily_vibe(uuid, jsonb, text, boolean, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_daily_vibe(uuid, jsonb, text, boolean, text) TO service_role;

CREATE TABLE vibra_private.daily_vibe_changes (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  changed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX daily_vibe_changes_idx ON vibra_private.daily_vibe_changes (user_id, changed_at);
REVOKE ALL ON vibra_private.daily_vibe_changes FROM PUBLIC, anon, authenticated;

CREATE FUNCTION public.delete_my_daily_vibe(p_vibe uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  DELETE FROM public.daily_vibes WHERE id = p_vibe AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.delete_my_daily_vibe(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_daily_vibe(uuid) TO authenticated;

-- A vibe the caller can see (RLS-equivalent check for DEFINER writes).
CREATE FUNCTION vibra_private.require_visible_vibe(p_vibe uuid)
RETURNS public.daily_vibes LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.daily_vibes%ROWTYPE;
BEGIN
  SELECT * INTO v FROM public.daily_vibes WHERE id = p_vibe;
  IF NOT FOUND OR NOT public.can_see_daily_vibe(v.user_id, v.visibility, v.expires_at, v.held_for_review) THEN
    RAISE no_data_found USING MESSAGE = 'vibe_not_found';
  END IF;
  RETURN v;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.require_visible_vibe(uuid) FROM PUBLIC, anon, authenticated;

-- ── Reactions, comments, replies ──────────────────────────────────────────
CREATE FUNCTION public.toggle_daily_vibe_reaction(p_vibe uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_visible_vibe(p_vibe);
  PERFORM public.consume_action_limit('vibe-reaction');
  DELETE FROM public.daily_vibe_reactions WHERE vibe_id = p_vibe AND user_id = auth.uid() AND reaction = p_reaction;
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.daily_vibe_reactions (vibe_id, user_id, reaction) VALUES (p_vibe, auth.uid(), p_reaction);
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_daily_vibe_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_daily_vibe_reaction(uuid, text) TO authenticated;

CREATE FUNCTION public.add_daily_vibe_comment(p_vibe uuid, p_body text, p_parent uuid DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.daily_vibes%ROWTYPE; v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  v := vibra_private.require_visible_vibe(p_vibe);
  PERFORM public.consume_action_limit('vibe-comment');
  PERFORM vibra_private.community_text_guard(p_body);
  IF p_parent IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM public.daily_vibe_comments c WHERE c.id = p_parent AND c.vibe_id = p_vibe
        AND public.may_access_message(auth.uid(), c.author_id)) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_parent';
  END IF;
  IF (SELECT count(*) FROM public.daily_vibe_comments WHERE author_id = auth.uid() AND created_at > now() - interval '1 day') >= 200 THEN
    RAISE check_violation USING MESSAGE = 'vibe_comment_daily_limit';
  END IF;
  INSERT INTO public.daily_vibe_comments (vibe_id, author_id, parent_id, body)
  VALUES (p_vibe, auth.uid(), p_parent, btrim(p_body)) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.add_daily_vibe_comment(uuid, text, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_daily_vibe_comment(uuid, text, uuid) TO authenticated;

-- The author, or the vibe's owner, deletes a comment.
CREATE FUNCTION public.delete_daily_vibe_comment(p_comment uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  DELETE FROM public.daily_vibe_comments c
  WHERE c.id = p_comment AND (c.author_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.daily_vibes v WHERE v.id = c.vibe_id AND v.user_id = auth.uid()));
END;
$$;
REVOKE ALL ON FUNCTION public.delete_daily_vibe_comment(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_daily_vibe_comment(uuid) TO authenticated;

-- ── Discovery collection ──────────────────────────────────────────────────
CREATE FUNCTION public.save_vibe_to_discoveries(p_vibe uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v public.daily_vibes%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  v := vibra_private.require_visible_vibe(p_vibe);
  PERFORM public.consume_action_limit('discovery');
  IF (SELECT count(*) FROM public.discovery_collection WHERE user_id = auth.uid()) >= 500 THEN
    RAISE check_violation USING MESSAGE = 'discovery_limit';
  END IF;
  INSERT INTO public.discovery_collection (user_id, provider, track_id, title, artist, album, artwork_url, external_url, from_vibe_id)
  VALUES (auth.uid(), v.provider, v.track_id, v.title, v.artist, v.album, v.artwork_url, v.external_url, v.id)
  ON CONFLICT (user_id, external_url) DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.save_vibe_to_discoveries(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_vibe_to_discoveries(uuid) TO authenticated;

CREATE FUNCTION public.remove_discovery(p_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  DELETE FROM public.discovery_collection WHERE id = p_id AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.remove_discovery(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.remove_discovery(uuid) TO authenticated;

-- ── Reads ─────────────────────────────────────────────────────────────────
-- Today's feed: my vibe and visible vibes of my connections, matches and
-- people I follow. RLS (can_see_daily_vibe) decides what is visible.
CREATE FUNCTION public.get_daily_vibes(p_limit integer DEFAULT 50)
RETURNS TABLE (
  id uuid, user_id uuid, username text, display_name text, avatar_url text,
  provider text, track_id text, title text, artist text, album text, artwork_url text,
  external_url text, caption text, visibility text, expires_at timestamptz, created_at timestamptz,
  reactions jsonb, my_reactions text[], comment_count bigint, saved boolean, held_for_review boolean
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT v.id, v.user_id, d.username::text, d.display_name, d.avatar_url,
    v.provider, v.track_id, v.title, v.artist, v.album, v.artwork_url, v.external_url,
    v.caption, v.visibility, v.expires_at, v.created_at,
    COALESCE((SELECT jsonb_object_agg(x.reaction, x.n) FROM (
      SELECT r.reaction, count(*) AS n FROM public.daily_vibe_reactions r WHERE r.vibe_id = v.id GROUP BY r.reaction) x), '{}'::jsonb),
    ARRAY(SELECT r.reaction FROM public.daily_vibe_reactions r WHERE r.vibe_id = v.id AND r.user_id = auth.uid()),
    (SELECT count(*) FROM public.daily_vibe_comments c WHERE c.vibe_id = v.id),
    EXISTS (SELECT 1 FROM public.discovery_collection dc WHERE dc.user_id = auth.uid() AND dc.external_url = v.external_url),
    v.held_for_review
  FROM public.daily_vibes v
  JOIN public.profile_discovery d ON d.id = v.user_id
  WHERE v.created_at > now() - interval '48 hours'
    AND (v.user_id = auth.uid()
      OR EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
        AND ((f.requester_id = auth.uid() AND f.receiver_id = v.user_id) OR (f.requester_id = v.user_id AND f.receiver_id = auth.uid())))
      OR EXISTS (SELECT 1 FROM public.user_matches m
        WHERE m.user_id_a = LEAST(auth.uid(), v.user_id) AND m.user_id_b = GREATEST(auth.uid(), v.user_id))
      OR EXISTS (SELECT 1 FROM public.follows fo WHERE fo.follower_id = auth.uid() AND fo.following_id = v.user_id))
  ORDER BY (v.user_id = auth.uid()) DESC, v.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 50), 1), 100);
$$;
REVOKE ALL ON FUNCTION public.get_daily_vibes(integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_daily_vibes(integer) TO authenticated;

CREATE FUNCTION public.get_daily_vibe_comments(p_vibe uuid)
RETURNS TABLE (id uuid, parent_id uuid, author_id uuid, username text, display_name text, avatar_url text, body text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT c.id, c.parent_id, c.author_id, d.username::text, d.display_name, d.avatar_url, c.body, c.created_at
  FROM public.daily_vibe_comments c
  LEFT JOIN public.profile_discovery d ON d.id = c.author_id
  WHERE c.vibe_id = p_vibe
  ORDER BY c.created_at
  LIMIT 300;
$$;
REVOKE ALL ON FUNCTION public.get_daily_vibe_comments(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_daily_vibe_comments(uuid) TO authenticated;

-- ── Expiry ────────────────────────────────────────────────────────────────
CREATE FUNCTION vibra_private.purge_expired_daily_vibes()
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $$
  DELETE FROM public.daily_vibes WHERE expires_at IS NOT NULL AND expires_at < now();
  DELETE FROM vibra_private.daily_vibe_changes WHERE changed_at < now() - interval '2 days';
$$;
REVOKE ALL ON FUNCTION vibra_private.purge_expired_daily_vibes() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('purge-expired-daily-vibes', '7 * * * *', 'SELECT vibra_private.purge_expired_daily_vibes();');

-- ── Reports ───────────────────────────────────────────────────────────────
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS daily_vibe_id uuid REFERENCES public.daily_vibes(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS daily_vibe_comment_id uuid REFERENCES public.daily_vibe_comments(id) ON DELETE CASCADE;

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
      IF NEW.daily_vibe_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.daily_vibes v WHERE v.id=NEW.daily_vibe_id AND v.user_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible vibes may be reported';
      END IF;
      IF NEW.daily_vibe_comment_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.daily_vibe_comments c WHERE c.id=NEW.daily_vibe_comment_id AND c.author_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible comments may be reported';
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

CREATE FUNCTION vibra_private.hold_reported_daily_vibe()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.daily_vibe_id IS NOT NULL AND (SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE daily_vibe_id = NEW.daily_vibe_id AND status = 'pending') >= 3 THEN
    UPDATE public.daily_vibes SET held_for_review = true WHERE id = NEW.daily_vibe_id;
  END IF;
  IF NEW.daily_vibe_comment_id IS NOT NULL AND (SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE daily_vibe_comment_id = NEW.daily_vibe_comment_id AND status = 'pending') >= 3 THEN
    UPDATE public.daily_vibe_comments SET held_for_review = true WHERE id = NEW.daily_vibe_comment_id;
  END IF;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.hold_reported_daily_vibe() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_hold_reported_daily_vibe AFTER INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION vibra_private.hold_reported_daily_vibe();

-- ── Notifications: comments and replies ───────────────────────────────────
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update',
  'circle_invite', 'circle_message', 'circle_plan', 'vibe_comment'
));
CREATE TRIGGER daily_vibe_comments_notify AFTER INSERT ON public.daily_vibe_comments
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
    'circle_playlist_items', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_playlist_items p WHERE p.added_by = uid), '[]'::jsonb),
    'circle_plans', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.circle_plans p WHERE p.created_by = uid), '[]'::jsonb),
    'circle_plan_participation', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY x.created_at) FROM public.circle_plan_participants x WHERE x.user_id = uid), '[]'::jsonb),
    'daily_vibes', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.created_at) FROM public.daily_vibes v WHERE v.user_id = uid), '[]'::jsonb),
    'daily_vibe_comments', COALESCE((SELECT jsonb_agg(to_jsonb(c) ORDER BY c.created_at) FROM public.daily_vibe_comments c WHERE c.author_id = uid), '[]'::jsonb),
    'daily_vibe_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.daily_vibe_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'discovery_collection', COALESCE((SELECT jsonb_agg(to_jsonb(d) ORDER BY d.saved_at) FROM public.discovery_collection d WHERE d.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
