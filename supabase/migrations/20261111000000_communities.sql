-- VIBRA Musical Communities (docs/communities.md).
--
-- Communities around genres, artists and interests: membership, posts,
-- discussions, shared music, comments, reactions and community events.
--
-- Security model
-- * Every write goes through a SECURITY DEFINER function that checks the
--   session, membership, community bans, blocks and test segments
--   (may_access_message), the shared rate limiter, daily caps, duplicate
--   content and links. Clients have SELECT only.
-- * Reads apply RLS: removed or held content is hidden, and content by
--   people you blocked (or who blocked you) is never returned.
-- * Reports reuse public.reports (rate-limited, validated). Three distinct
--   reports hide a post or comment until a moderator reviews it.
-- * Roles: owner > moderator > member. Moderators remove/restore content and
--   ban members; the owner also promotes and demotes moderators.
BEGIN;

-- ── Tables ────────────────────────────────────────────────────────────────
CREATE TABLE public.communities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length(slug) BETWEEN 3 AND 48),
  name text NOT NULL CHECK (char_length(btrim(name)) BETWEEN 3 AND 60),
  description text NOT NULL DEFAULT '' CHECK (char_length(description) <= 500),
  kind text NOT NULL CHECK (kind IN ('genre', 'artist', 'interest')),
  genre_key text CHECK (genre_key ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length(genre_key) <= 40),
  genre_family text CHECK (genre_family ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length(genre_family) <= 40),
  artist_name text CHECK (char_length(btrim(artist_name)) BETWEEN 1 AND 80),
  is_official boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  member_count integer NOT NULL DEFAULT 0 CHECK (member_count >= 0),
  post_count integer NOT NULL DEFAULT 0 CHECK (post_count >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK (kind <> 'genre' OR (genre_key IS NOT NULL AND genre_family IS NOT NULL)),
  CHECK (kind <> 'artist' OR artist_name IS NOT NULL)
);
CREATE UNIQUE INDEX communities_artist_unique ON public.communities (lower(artist_name))
  WHERE kind = 'artist' AND archived_at IS NULL;
CREATE INDEX communities_members_idx ON public.communities (member_count DESC) WHERE archived_at IS NULL;

CREATE TABLE public.community_members (
  community_id uuid NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'owner')),
  joined_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (community_id, user_id)
);
CREATE INDEX community_members_user_idx ON public.community_members (user_id);

CREATE TABLE public.community_bans (
  community_id uuid NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  banned_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  reason text CHECK (char_length(reason) <= 200),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (community_id, user_id)
);

CREATE TABLE public.community_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  community_id uuid NOT NULL REFERENCES public.communities(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN ('post', 'discussion', 'music', 'event')),
  title text CHECK (char_length(btrim(title)) BETWEEN 1 AND 120),
  body text NOT NULL DEFAULT '' CHECK (char_length(body) <= 4000),
  music jsonb CHECK (music IS NULL OR jsonb_typeof(music) = 'object'),
  event_id uuid REFERENCES public.events(id) ON DELETE SET NULL,
  comment_count integer NOT NULL DEFAULT 0 CHECK (comment_count >= 0),
  reaction_count integer NOT NULL DEFAULT 0 CHECK (reaction_count >= 0),
  held_for_review boolean NOT NULL DEFAULT false,
  removed_at timestamptz,
  removed_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  removal_reason text CHECK (char_length(removal_reason) <= 200),
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (kind <> 'discussion' OR title IS NOT NULL),
  CHECK (kind <> 'music' OR music IS NOT NULL),
  CHECK (kind <> 'event' OR event_id IS NOT NULL OR removed_at IS NOT NULL)
);
CREATE INDEX community_posts_feed_idx ON public.community_posts (community_id, created_at DESC);
CREATE INDEX community_posts_author_idx ON public.community_posts (author_id, created_at DESC);

CREATE TABLE public.community_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  body text NOT NULL CHECK (char_length(btrim(body)) BETWEEN 1 AND 1000),
  held_for_review boolean NOT NULL DEFAULT false,
  removed_at timestamptz,
  removed_by uuid REFERENCES public.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX community_comments_post_idx ON public.community_comments (post_id, created_at);
CREATE INDEX community_comments_author_idx ON public.community_comments (author_id, created_at DESC);

CREATE TABLE public.community_reactions (
  post_id uuid NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reaction text NOT NULL CHECK (reaction IN ('fire', 'heart', 'headphones', 'clap', 'mind_blown')),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id, reaction)
);

-- Reports can point at community content.
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS community_post_id uuid REFERENCES public.community_posts(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS community_comment_id uuid REFERENCES public.community_comments(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS reports_community_post_idx ON public.reports (community_post_id) WHERE community_post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS reports_community_comment_idx ON public.reports (community_comment_id) WHERE community_comment_id IS NOT NULL;

-- ── Helpers ───────────────────────────────────────────────────────────────
CREATE FUNCTION public.community_role(p_community uuid, p_user uuid)
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT role FROM public.community_members WHERE community_id = p_community AND user_id = p_user;
$$;
REVOKE ALL ON FUNCTION public.community_role(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.community_role(uuid, uuid) TO authenticated;

CREATE FUNCTION public.is_community_moderator(p_community uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT COALESCE(public.community_role(p_community, auth.uid()) IN ('moderator', 'owner'), false);
$$;
REVOKE ALL ON FUNCTION public.is_community_moderator(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_community_moderator(uuid) TO authenticated;

-- Content the caller may see from this author: self, or not blocked either
-- way and same test segment.
CREATE FUNCTION public.may_see_community_author(p_author uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT p_author = auth.uid() OR public.may_access_message(auth.uid(), p_author);
$$;
REVOKE ALL ON FUNCTION public.may_see_community_author(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.may_see_community_author(uuid) TO authenticated;

-- Spam checks shared by posts and comments. Raises with a stable code.
CREATE FUNCTION vibra_private.community_text_guard(p_text text)
RETURNS void LANGUAGE plpgsql STABLE SET search_path = pg_catalog AS $$
DECLARE v_links integer;
BEGIN
  IF p_text IS NULL THEN RETURN; END IF;
  SELECT count(*) INTO v_links FROM regexp_matches(p_text, 'https?://', 'gi');
  IF v_links > 2 THEN RAISE check_violation USING MESSAGE = 'too_many_links'; END IF;
  IF p_text ~* '(http|https)://\S*(ngrok|bit\.ly|tinyurl|free-money|adult|casino|scam)' THEN
    RAISE check_violation USING MESSAGE = 'suspicious_link';
  END IF;
  -- Long runs of one character ("!!!!!!!!!!!!!!!!!!!!") are flood, not text.
  IF p_text ~ '(.)\1{24,}' THEN RAISE check_violation USING MESSAGE = 'flood'; END IF;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.community_text_guard(text) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION vibra_private.normalize_text(p_text text)
RETURNS text LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT regexp_replace(lower(COALESCE(p_text, '')), '[^a-z0-9]+', '', 'g');
$$;
REVOKE ALL ON FUNCTION vibra_private.normalize_text(text) FROM PUBLIC, anon, authenticated;

-- ── Rate limits (shared limiter + community actions) ──────────────────────
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

-- ── RLS (reads) ───────────────────────────────────────────────────────────
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
CREATE POLICY communities_read ON public.communities FOR SELECT TO authenticated
  USING (archived_at IS NULL);

ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_members_read ON public.community_members FOR SELECT TO authenticated
  USING (public.may_see_community_author(user_id));

ALTER TABLE public.community_bans ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_bans_read ON public.community_bans FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()) OR public.is_community_moderator(community_id));

ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_posts_read ON public.community_posts FOR SELECT TO authenticated
  USING (
    public.may_see_community_author(author_id)
    AND EXISTS (SELECT 1 FROM public.communities c WHERE c.id = community_id AND c.archived_at IS NULL)
    AND (
      (removed_at IS NULL AND NOT held_for_review)
      OR (removed_at IS NULL AND author_id = (SELECT auth.uid()))
      OR public.is_community_moderator(community_id)
    )
  );

ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_comments_read ON public.community_comments FOR SELECT TO authenticated
  USING (
    public.may_see_community_author(author_id)
    AND EXISTS (SELECT 1 FROM public.community_posts p WHERE p.id = post_id)
    AND (
      (removed_at IS NULL AND NOT held_for_review)
      OR (removed_at IS NULL AND author_id = (SELECT auth.uid()))
      OR public.is_community_moderator((SELECT p.community_id FROM public.community_posts p WHERE p.id = post_id))
    )
  );

ALTER TABLE public.community_reactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_reactions_read ON public.community_reactions FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.community_posts p WHERE p.id = post_id));

REVOKE ALL ON public.communities, public.community_members, public.community_bans,
  public.community_posts, public.community_comments, public.community_reactions
  FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.communities, public.community_members, public.community_bans,
  public.community_posts, public.community_comments, public.community_reactions TO authenticated;
GRANT ALL ON public.communities, public.community_members, public.community_bans,
  public.community_posts, public.community_comments, public.community_reactions TO service_role;

-- ── Communities: create, join, leave ──────────────────────────────────────
CREATE FUNCTION public.create_community(
  p_name text, p_description text, p_kind text,
  p_genre_key text DEFAULT NULL, p_genre_family text DEFAULT NULL, p_artist_name text DEFAULT NULL
)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_id uuid;
  v_base text;
  v_slug text;
  v_n integer := 1;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM public.consume_action_limit('community-create');
  IF (SELECT count(*) FROM public.communities WHERE created_by = v_me AND created_at > now() - interval '1 day') >= 3 THEN
    RAISE check_violation USING MESSAGE = 'community_daily_limit';
  END IF;
  IF (SELECT count(*) FROM public.community_members WHERE user_id = v_me AND role = 'owner') >= 10 THEN
    RAISE check_violation USING MESSAGE = 'community_owner_limit';
  END IF;
  PERFORM vibra_private.community_text_guard(p_name);
  PERFORM vibra_private.community_text_guard(p_description);
  IF p_kind = 'artist' AND EXISTS (SELECT 1 FROM public.communities
      WHERE kind = 'artist' AND archived_at IS NULL AND lower(artist_name) = lower(btrim(p_artist_name))) THEN
    RAISE unique_violation USING MESSAGE = 'artist_community_exists';
  END IF;
  v_base := left(trim(both '-' FROM regexp_replace(lower(p_name), '[^a-z0-9]+', '-', 'g')), 40);
  IF char_length(v_base) < 3 THEN v_base := 'community'; END IF;
  v_slug := v_base;
  WHILE EXISTS (SELECT 1 FROM public.communities WHERE slug = v_slug) LOOP
    v_n := v_n + 1;
    v_slug := v_base || '-' || v_n;
  END LOOP;
  INSERT INTO public.communities (slug, name, description, kind, genre_key, genre_family, artist_name, created_by)
  VALUES (v_slug, btrim(p_name), COALESCE(btrim(p_description), ''), p_kind,
    CASE WHEN p_kind = 'genre' THEN p_genre_key END,
    CASE WHEN p_kind = 'genre' THEN p_genre_family END,
    CASE WHEN p_kind = 'artist' THEN btrim(p_artist_name) END, v_me)
  RETURNING id INTO v_id;
  INSERT INTO public.community_members (community_id, user_id, role) VALUES (v_id, v_me, 'owner');
  UPDATE public.communities SET member_count = 1 WHERE id = v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_community(text, text, text, text, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_community(text, text, text, text, text, text) TO authenticated;

CREATE FUNCTION public.join_community(p_community uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid();
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM public.consume_action_limit('community-join');
  IF NOT EXISTS (SELECT 1 FROM public.communities WHERE id = p_community AND archived_at IS NULL) THEN
    RAISE no_data_found USING MESSAGE = 'community_not_found';
  END IF;
  IF EXISTS (SELECT 1 FROM public.community_bans WHERE community_id = p_community AND user_id = v_me) THEN
    RAISE insufficient_privilege USING MESSAGE = 'community_banned';
  END IF;
  IF (SELECT count(*) FROM public.community_members WHERE user_id = v_me) >= 200 THEN
    RAISE check_violation USING MESSAGE = 'community_membership_limit';
  END IF;
  INSERT INTO public.community_members (community_id, user_id) VALUES (p_community, v_me)
  ON CONFLICT DO NOTHING;
  IF FOUND THEN
    UPDATE public.communities SET member_count = member_count + 1 WHERE id = p_community;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.join_community(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.join_community(uuid) TO authenticated;

-- An owner who leaves hands the community to the longest-standing
-- moderator, else the longest-standing member; an empty community stays
-- (official ones are never orphaned in practice).
CREATE FUNCTION public.leave_community(p_community uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_role text;
  v_heir uuid;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  DELETE FROM public.community_members WHERE community_id = p_community AND user_id = v_me
  RETURNING role INTO v_role;
  IF v_role IS NULL THEN RETURN; END IF;
  UPDATE public.communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = p_community;
  IF v_role = 'owner' THEN
    SELECT user_id INTO v_heir FROM public.community_members WHERE community_id = p_community
    ORDER BY (role = 'moderator') DESC, joined_at LIMIT 1;
    IF v_heir IS NOT NULL THEN
      UPDATE public.community_members SET role = 'owner' WHERE community_id = p_community AND user_id = v_heir;
    END IF;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.leave_community(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.leave_community(uuid) TO authenticated;

-- ── Posts, comments, reactions ────────────────────────────────────────────
CREATE FUNCTION public.create_community_post(
  p_community uuid, p_kind text, p_title text DEFAULT NULL, p_body text DEFAULT '',
  p_music jsonb DEFAULT NULL, p_event_id uuid DEFAULT NULL
)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_me uuid := auth.uid();
  v_id uuid;
  v_music jsonb;
  v_url text;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF public.community_role(p_community, v_me) IS NULL THEN
    RAISE insufficient_privilege USING MESSAGE = 'community_membership_required';
  END IF;
  IF EXISTS (SELECT 1 FROM public.community_bans WHERE community_id = p_community AND user_id = v_me) THEN
    RAISE insufficient_privilege USING MESSAGE = 'community_banned';
  END IF;
  PERFORM public.consume_action_limit('community-post');
  IF (SELECT count(*) FROM public.community_posts WHERE author_id = v_me AND created_at > now() - interval '1 day') >= 30 THEN
    RAISE check_violation USING MESSAGE = 'community_post_daily_limit';
  END IF;
  IF p_kind NOT IN ('post', 'discussion', 'music', 'event') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_post_kind';
  END IF;
  IF p_kind = 'post' AND NULLIF(btrim(COALESCE(p_body, '')), '') IS NULL THEN
    RAISE invalid_parameter_value USING MESSAGE = 'empty_post';
  END IF;
  PERFORM vibra_private.community_text_guard(p_title);
  PERFORM vibra_private.community_text_guard(p_body);
  -- The same text posted again within 10 minutes, anywhere, is spam.
  IF char_length(vibra_private.normalize_text(p_body)) >= 8 AND EXISTS (
      SELECT 1 FROM public.community_posts
      WHERE author_id = v_me AND created_at > now() - interval '10 minutes'
        AND vibra_private.normalize_text(body) = vibra_private.normalize_text(p_body)) THEN
    RAISE check_violation USING MESSAGE = 'duplicate_content';
  END IF;
  IF p_kind = 'music' THEN
    -- Shared music: a Spotify, Apple Music, YouTube Music, SoundCloud or
    -- Bandcamp link, plus optional title/artist text. Nothing else is kept.
    v_url := btrim(p_music->>'url');
    IF v_url IS NULL OR char_length(v_url) > 300 OR v_url !~* '^https://(open\.spotify\.com|music\.apple\.com|music\.youtube\.com|(www\.)?youtube\.com|youtu\.be|soundcloud\.com|[a-z0-9-]+\.bandcamp\.com)/' THEN
      RAISE invalid_parameter_value USING MESSAGE = 'invalid_music_link';
    END IF;
    v_music := jsonb_strip_nulls(jsonb_build_object(
      'url', v_url,
      'title', left(NULLIF(btrim(p_music->>'title'), ''), 120),
      'artist', left(NULLIF(btrim(p_music->>'artist'), ''), 80)));
  END IF;
  IF p_kind = 'event' AND NOT EXISTS (SELECT 1 FROM public.events WHERE id = p_event_id) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'event_not_found';
  END IF;
  INSERT INTO public.community_posts (community_id, author_id, kind, title, body, music, event_id)
  VALUES (p_community, v_me, p_kind, NULLIF(btrim(p_title), ''), COALESCE(btrim(p_body), ''), v_music,
    CASE WHEN p_kind = 'event' THEN p_event_id END)
  RETURNING id INTO v_id;
  UPDATE public.communities SET post_count = post_count + 1 WHERE id = p_community;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_community_post(uuid, text, text, text, jsonb, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_community_post(uuid, text, text, text, jsonb, uuid) TO authenticated;

-- A visible post the caller may interact with (member, not banned, no block
-- with the author). Returns the community id.
CREATE FUNCTION vibra_private.community_post_access(p_post uuid, p_me uuid)
RETURNS uuid LANGUAGE plpgsql STABLE SET search_path = pg_catalog AS $$
DECLARE v_post public.community_posts%ROWTYPE;
BEGIN
  SELECT * INTO v_post FROM public.community_posts WHERE id = p_post;
  IF NOT FOUND OR v_post.removed_at IS NOT NULL OR v_post.held_for_review THEN
    RAISE no_data_found USING MESSAGE = 'post_not_found';
  END IF;
  IF v_post.author_id <> p_me AND NOT public.may_access_message(p_me, v_post.author_id) THEN
    RAISE no_data_found USING MESSAGE = 'post_not_found';
  END IF;
  IF public.community_role(v_post.community_id, p_me) IS NULL THEN
    RAISE insufficient_privilege USING MESSAGE = 'community_membership_required';
  END IF;
  IF EXISTS (SELECT 1 FROM public.community_bans WHERE community_id = v_post.community_id AND user_id = p_me) THEN
    RAISE insufficient_privilege USING MESSAGE = 'community_banned';
  END IF;
  RETURN v_post.community_id;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.community_post_access(uuid, uuid) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION public.create_community_comment(p_post uuid, p_body text)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM vibra_private.community_post_access(p_post, v_me);
  PERFORM public.consume_action_limit('community-comment');
  IF (SELECT count(*) FROM public.community_comments WHERE author_id = v_me AND created_at > now() - interval '1 day') >= 200 THEN
    RAISE check_violation USING MESSAGE = 'community_comment_daily_limit';
  END IF;
  PERFORM vibra_private.community_text_guard(p_body);
  IF char_length(vibra_private.normalize_text(p_body)) >= 8 AND EXISTS (
      SELECT 1 FROM public.community_comments
      WHERE author_id = v_me AND created_at > now() - interval '10 minutes'
        AND vibra_private.normalize_text(body) = vibra_private.normalize_text(p_body)) THEN
    RAISE check_violation USING MESSAGE = 'duplicate_content';
  END IF;
  INSERT INTO public.community_comments (post_id, author_id, body) VALUES (p_post, v_me, btrim(p_body))
  RETURNING id INTO v_id;
  UPDATE public.community_posts SET comment_count = comment_count + 1 WHERE id = p_post;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_community_comment(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_community_comment(uuid, text) TO authenticated;

-- Toggles one reaction; returns true when it is now set.
CREATE FUNCTION public.toggle_community_reaction(p_post uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid();
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM vibra_private.community_post_access(p_post, v_me);
  PERFORM public.consume_action_limit('community-reaction');
  DELETE FROM public.community_reactions WHERE post_id = p_post AND user_id = v_me AND reaction = p_reaction;
  IF FOUND THEN
    UPDATE public.community_posts SET reaction_count = GREATEST(reaction_count - 1, 0) WHERE id = p_post;
    RETURN false;
  END IF;
  INSERT INTO public.community_reactions (post_id, user_id, reaction) VALUES (p_post, v_me, p_reaction);
  UPDATE public.community_posts SET reaction_count = reaction_count + 1 WHERE id = p_post;
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_community_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_community_reaction(uuid, text) TO authenticated;

-- Authors delete their own content outright.
CREATE FUNCTION public.delete_own_community_content(p_post uuid DEFAULT NULL, p_comment uuid DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_post uuid; v_community uuid;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF p_post IS NOT NULL THEN
    DELETE FROM public.community_posts WHERE id = p_post AND author_id = v_me RETURNING community_id INTO v_community;
    IF v_community IS NOT NULL THEN
      UPDATE public.communities SET post_count = GREATEST(post_count - 1, 0) WHERE id = v_community;
    END IF;
  ELSIF p_comment IS NOT NULL THEN
    DELETE FROM public.community_comments WHERE id = p_comment AND author_id = v_me RETURNING post_id INTO v_post;
    IF v_post IS NOT NULL THEN
      UPDATE public.community_posts SET comment_count = GREATEST(comment_count - 1, 0) WHERE id = v_post;
    END IF;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.delete_own_community_content(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_own_community_content(uuid, uuid) TO authenticated;

-- ── Moderation ────────────────────────────────────────────────────────────
-- Remove (soft, with reason) or restore a post/comment. Moderators of that
-- community only.
CREATE FUNCTION public.moderate_community_content(
  p_action text, p_post uuid DEFAULT NULL, p_comment uuid DEFAULT NULL, p_reason text DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_community uuid; v_post uuid := p_post;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  IF p_action NOT IN ('remove', 'restore') THEN RAISE invalid_parameter_value USING MESSAGE = 'invalid_action'; END IF;
  IF p_comment IS NOT NULL THEN SELECT post_id INTO v_post FROM public.community_comments WHERE id = p_comment; END IF;
  SELECT community_id INTO v_community FROM public.community_posts WHERE id = v_post;
  IF v_community IS NULL OR COALESCE(public.community_role(v_community, v_me), 'member') NOT IN ('moderator', 'owner') THEN
    RAISE insufficient_privilege USING MESSAGE = 'moderator_required';
  END IF;
  PERFORM public.consume_action_limit('community-moderate');
  IF p_comment IS NOT NULL THEN
    UPDATE public.community_comments SET
      removed_at = CASE WHEN p_action = 'remove' THEN now() END,
      removed_by = CASE WHEN p_action = 'remove' THEN v_me END,
      held_for_review = false
    WHERE id = p_comment;
  ELSE
    UPDATE public.community_posts SET
      removed_at = CASE WHEN p_action = 'remove' THEN now() END,
      removed_by = CASE WHEN p_action = 'remove' THEN v_me END,
      removal_reason = CASE WHEN p_action = 'remove' THEN left(p_reason, 200) END,
      held_for_review = false
    WHERE id = p_post;
  END IF;
  -- Reports about this content are now handled.
  UPDATE public.reports SET status = 'action_taken'
  WHERE status = 'pending' AND (community_post_id = p_post OR community_comment_id = p_comment)
    AND (p_post IS NOT NULL OR p_comment IS NOT NULL);
END;
$$;
REVOKE ALL ON FUNCTION public.moderate_community_content(text, uuid, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.moderate_community_content(text, uuid, uuid, text) TO authenticated;

-- Ban (removes membership, blocks rejoining) or unban. Moderators can ban
-- members; only the owner can ban a moderator; nobody can ban the owner.
CREATE FUNCTION public.set_community_ban(p_community uuid, p_user uuid, p_banned boolean, p_reason text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_my_role text; v_their_role text;
BEGIN
  PERFORM public.require_active_session();
  v_my_role := public.community_role(p_community, v_me);
  IF COALESCE(v_my_role, 'member') NOT IN ('moderator', 'owner') OR p_user = v_me THEN
    RAISE insufficient_privilege USING MESSAGE = 'moderator_required';
  END IF;
  PERFORM public.consume_action_limit('community-moderate');
  v_their_role := public.community_role(p_community, p_user);
  IF v_their_role = 'owner' OR (v_their_role = 'moderator' AND v_my_role <> 'owner') THEN
    RAISE insufficient_privilege USING MESSAGE = 'cannot_ban_role';
  END IF;
  IF p_banned THEN
    INSERT INTO public.community_bans (community_id, user_id, banned_by, reason)
    VALUES (p_community, p_user, v_me, left(p_reason, 200)) ON CONFLICT DO NOTHING;
    DELETE FROM public.community_members WHERE community_id = p_community AND user_id = p_user;
    IF FOUND THEN
      UPDATE public.communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = p_community;
    END IF;
  ELSE
    DELETE FROM public.community_bans WHERE community_id = p_community AND user_id = p_user;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_community_ban(uuid, uuid, boolean, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_community_ban(uuid, uuid, boolean, text) TO authenticated;

-- Owner promotes a member to moderator or demotes a moderator.
CREATE FUNCTION public.set_community_role(p_community uuid, p_user uuid, p_role text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  IF public.community_role(p_community, auth.uid()) IS DISTINCT FROM 'owner' THEN
    RAISE insufficient_privilege USING MESSAGE = 'owner_required';
  END IF;
  IF p_role NOT IN ('member', 'moderator') OR p_user = auth.uid() THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_role';
  END IF;
  UPDATE public.community_members SET role = p_role
  WHERE community_id = p_community AND user_id = p_user AND role <> 'owner';
  IF NOT FOUND THEN RAISE no_data_found USING MESSAGE = 'member_not_found'; END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_community_role(uuid, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_community_role(uuid, uuid, text) TO authenticated;

-- Reports on community content: validated like message reports, and three
-- distinct reporters hold the content for moderator review.
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
      -- Community content: must be by the reported person and visible to the
      -- reporter (RLS applies to this read).
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

CREATE FUNCTION vibra_private.hold_reported_community_content()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.community_post_id IS NOT NULL AND (
      SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE community_post_id = NEW.community_post_id AND status = 'pending') >= 3 THEN
    UPDATE public.community_posts SET held_for_review = true
    WHERE id = NEW.community_post_id AND removed_at IS NULL;
  END IF;
  IF NEW.community_comment_id IS NOT NULL AND (
      SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE community_comment_id = NEW.community_comment_id AND status = 'pending') >= 3 THEN
    UPDATE public.community_comments SET held_for_review = true
    WHERE id = NEW.community_comment_id AND removed_at IS NULL;
  END IF;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.hold_reported_community_content() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_hold_reported_community_content AFTER INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION vibra_private.hold_reported_community_content();

-- Moderators' queue: held or reported content in their community.
CREATE FUNCTION public.get_community_moderation_queue(p_community uuid)
RETURNS TABLE (
  post_id uuid, comment_id uuid, author_id uuid, author_username text, body text, title text,
  held_for_review boolean, removed boolean, report_count bigint, reasons text[], created_at timestamptz
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NOT public.is_community_moderator(p_community) THEN
    RAISE insufficient_privilege USING MESSAGE = 'moderator_required';
  END IF;
  RETURN QUERY
  SELECT p.id, NULL::uuid, p.author_id, d.username::text, p.body, p.title, p.held_for_review, p.removed_at IS NOT NULL,
    count(r.id), array_remove(array_agg(DISTINCT r.reason), NULL), p.created_at
  FROM public.community_posts p
  LEFT JOIN public.profile_discovery d ON d.id = p.author_id
  LEFT JOIN public.reports r ON r.community_post_id = p.id AND r.status = 'pending'
  WHERE p.community_id = p_community AND (p.held_for_review OR r.id IS NOT NULL)
  GROUP BY p.id, d.username
  UNION ALL
  SELECT c.post_id, c.id, c.author_id, d.username::text, c.body, NULL, c.held_for_review, c.removed_at IS NOT NULL,
    count(r.id), array_remove(array_agg(DISTINCT r.reason), NULL), c.created_at
  FROM public.community_comments c
  JOIN public.community_posts p ON p.id = c.post_id AND p.community_id = p_community
  LEFT JOIN public.profile_discovery d ON d.id = c.author_id
  LEFT JOIN public.reports r ON r.community_comment_id = c.id AND r.status = 'pending'
  WHERE c.held_for_review OR r.id IS NOT NULL
  GROUP BY c.id, d.username
  ORDER BY 7 DESC, 9 DESC, 11 DESC
  LIMIT 100;
END;
$$;
REVOKE ALL ON FUNCTION public.get_community_moderation_queue(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_community_moderation_queue(uuid) TO authenticated;

-- ── Reads for the app ─────────────────────────────────────────────────────
CREATE FUNCTION public.get_communities(p_search text DEFAULT NULL, p_limit integer DEFAULT 200)
RETURNS TABLE (
  id uuid, slug text, name text, description text, kind text, genre_key text, genre_family text,
  artist_name text, is_official boolean, member_count integer, post_count integer, my_role text
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT c.id, c.slug, c.name, c.description, c.kind, c.genre_key, c.genre_family, c.artist_name,
    c.is_official, c.member_count, c.post_count,
    (SELECT m.role FROM public.community_members m WHERE m.community_id = c.id AND m.user_id = auth.uid())
  FROM public.communities c
  WHERE c.archived_at IS NULL
    AND (NULLIF(btrim(p_search), '') IS NULL
      OR c.name ILIKE '%' || replace(replace(btrim(p_search), '%', ''), '_', '') || '%'
      OR c.artist_name ILIKE '%' || replace(replace(btrim(p_search), '%', ''), '_', '') || '%')
  ORDER BY c.is_official DESC, c.member_count DESC, c.name
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 200), 1), 300);
$$;
REVOKE ALL ON FUNCTION public.get_communities(text, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_communities(text, integer) TO authenticated;

CREATE FUNCTION public.get_community_feed(
  p_community uuid, p_kind text DEFAULT NULL, p_before timestamptz DEFAULT NULL, p_limit integer DEFAULT 30
)
RETURNS TABLE (
  id uuid, community_id uuid, author_id uuid, author_username text, author_display_name text,
  author_avatar_url text, kind text, title text, body text, music jsonb, event jsonb,
  comment_count integer, reactions jsonb, my_reactions text[], held_for_review boolean,
  removed boolean, created_at timestamptz
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT p.id, p.community_id, p.author_id, d.username::text, d.display_name, d.avatar_url,
    p.kind, p.title, p.body, p.music,
    (SELECT to_jsonb(e) - 'location' FROM public.events e WHERE e.id = p.event_id),
    p.comment_count,
    COALESCE((SELECT jsonb_object_agg(x.reaction, x.n) FROM (
      SELECT r.reaction, count(*) AS n FROM public.community_reactions r WHERE r.post_id = p.id GROUP BY r.reaction) x), '{}'::jsonb),
    ARRAY(SELECT r.reaction FROM public.community_reactions r WHERE r.post_id = p.id AND r.user_id = auth.uid()),
    p.held_for_review, p.removed_at IS NOT NULL, p.created_at
  FROM public.community_posts p
  LEFT JOIN public.profile_discovery d ON d.id = p.author_id
  WHERE p.community_id = p_community
    AND p.removed_at IS NULL
    AND (p_kind IS NULL OR p.kind = p_kind OR (p_kind = 'post' AND p.kind IN ('post', 'music', 'event')))
    AND (p_before IS NULL OR p.created_at < p_before)
  ORDER BY p.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 30), 1), 50);
$$;
REVOKE ALL ON FUNCTION public.get_community_feed(uuid, text, timestamptz, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_community_feed(uuid, text, timestamptz, integer) TO authenticated;

CREATE FUNCTION public.get_community_comments(p_post uuid)
RETURNS TABLE (
  id uuid, post_id uuid, author_id uuid, author_username text, author_display_name text,
  author_avatar_url text, body text, held_for_review boolean, created_at timestamptz
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT c.id, c.post_id, c.author_id, d.username::text, d.display_name, d.avatar_url,
    c.body, c.held_for_review, c.created_at
  FROM public.community_comments c
  LEFT JOIN public.profile_discovery d ON d.id = c.author_id
  WHERE c.post_id = p_post AND c.removed_at IS NULL
  ORDER BY c.created_at
  LIMIT 300;
$$;
REVOKE ALL ON FUNCTION public.get_community_comments(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_community_comments(uuid) TO authenticated;

CREATE FUNCTION public.get_community_members(p_community uuid, p_limit integer DEFAULT 100, p_offset integer DEFAULT 0)
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text, role text, joined_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT m.user_id, d.username::text, d.display_name, d.avatar_url, m.role, m.joined_at
  FROM public.community_members m
  JOIN public.users_public d ON d.id = m.user_id
  WHERE m.community_id = p_community
  ORDER BY CASE m.role WHEN 'owner' THEN 0 WHEN 'moderator' THEN 1 ELSE 2 END, m.joined_at
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 100), 1), 200)
  OFFSET GREATEST(COALESCE(p_offset, 0), 0);
$$;
REVOKE ALL ON FUNCTION public.get_community_members(uuid, integer, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_community_members(uuid, integer, integer) TO authenticated;

-- Upcoming events for a community: the artist's shows, or events whose
-- Ticketmaster genres match the community's family (coarse, as the radar).
CREATE FUNCTION public.get_community_events(p_community uuid, p_limit integer DEFAULT 20)
RETURNS SETOF jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_c public.communities%ROWTYPE;
BEGIN
  SELECT * INTO v_c FROM public.communities WHERE id = p_community AND archived_at IS NULL;
  IF NOT FOUND THEN RETURN; END IF;
  RETURN QUERY
  SELECT to_jsonb(e) - 'location'
  FROM public.events e
  WHERE e.event_date BETWEEN now() AND now() + interval '90 days'
    AND COALESCE(e.status, 'onsale') NOT IN ('canceled', 'postponed', 'offsale')
    AND (
      (v_c.kind = 'artist' AND lower(e.artist_name) = lower(v_c.artist_name))
      OR (v_c.kind = 'genre' AND vibra_private.radar_genre_match(e.genres, ARRAY[v_c.genre_family]))
    )
  ORDER BY e.event_date
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50);
END;
$$;
REVOKE ALL ON FUNCTION public.get_community_events(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_community_events(uuid, integer) TO authenticated;

-- ── Shared communities (Same Frequency signal) ────────────────────────────
-- Communities the caller shares with each listed person. INVOKER: membership
-- rows are read under RLS, so blocked people and other test segments never
-- appear.
CREATE FUNCTION public.get_shared_communities(p_users uuid[])
RETURNS TABLE (user_id uuid, names text[])
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT other.user_id, (array_agg(c.name ORDER BY c.member_count, c.name))[1:3]
  FROM public.community_members mine
  JOIN public.community_members other ON other.community_id = mine.community_id
  JOIN public.communities c ON c.id = mine.community_id
  WHERE mine.user_id = auth.uid()
    AND other.user_id = ANY (p_users[1:100])
    AND other.user_id <> auth.uid()
  GROUP BY other.user_id;
$$;
REVOKE ALL ON FUNCTION public.get_shared_communities(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_shared_communities(uuid[]) TO authenticated;

-- ── Official communities ──────────────────────────────────────────────────
INSERT INTO public.communities (slug, name, description, kind, genre_key, genre_family, is_official) VALUES
  ('hip-hop-culture', 'Hip-Hop Culture', 'Rap, beats and everything around them.', 'genre', 'hip-hop', 'hip-hop', true),
  ('underground-rap', 'Underground Rap', 'Independent and underground hip-hop, far from the charts.', 'genre', 'underground-hip-hop', 'hip-hop', true),
  ('trap-nation', 'Trap Nation', '808s, hi-hats and the trap sound.', 'genre', 'trap', 'hip-hop', true),
  ('drill-scene', 'Drill Scene', 'UK, Brooklyn and Italian drill.', 'genre', 'drill', 'hip-hop', true),
  ('rnb-soul', 'R&B & Soul', 'Smooth, soulful and timeless.', 'genre', 'rnb', 'rnb', true),
  ('alternative-rnb', 'Alternative R&B', 'Moody, experimental R&B.', 'genre', 'alternative-rnb', 'rnb', true),
  ('electronic-music-lovers', 'Electronic Music Lovers', 'House, techno and every electronic sound.', 'genre', 'electronic', 'electronic', true),
  ('techno-underground', 'Techno Underground', 'Warehouses, raves and the techno sound.', 'genre', 'techno', 'electronic', true),
  ('house-music', 'House Music', 'Four-on-the-floor since Chicago.', 'genre', 'house', 'electronic', true),
  ('rock-forever', 'Rock Forever', 'Guitars, riffs and rock in every form.', 'genre', 'rock', 'rock', true),
  ('indie-alternative', 'Indie & Alternative', 'Indie rock and alternative sounds.', 'genre', 'indie-rock', 'rock', true),
  ('metal-heads', 'Metal Heads', 'Heavy, thrash, nu and everything loud.', 'genre', 'metal', 'metal', true),
  ('punk-spirit', 'Punk Spirit', 'Fast, loud and DIY.', 'genre', 'punk', 'punk', true),
  ('pop-hits', 'Pop Hits', 'The songs everyone is singing.', 'genre', 'pop', 'pop', true),
  ('jazz-lounge', 'Jazz Lounge', 'From bebop to nu jazz.', 'genre', 'jazz', 'jazz', true),
  ('blues-roots', 'Blues Roots', 'Where it all began.', 'genre', 'blues', 'blues', true),
  ('reggae-vibes', 'Reggae Vibes', 'Roots, dub and dancehall.', 'genre', 'reggae', 'reggae', true),
  ('latin-beats', 'Latin Beats', 'Reggaeton, salsa and Latin sounds.', 'genre', 'latin', 'latin', true),
  ('afro-sounds', 'Afro Sounds', 'Afrobeats, amapiano and African music.', 'genre', 'afro', 'afro', true),
  ('country-roads', 'Country Roads', 'Country music old and new.', 'genre', 'country', 'country', true),
  ('folk-acoustic', 'Folk & Acoustic', 'Songwriters and acoustic sounds.', 'genre', 'folk', 'folk', true),
  ('classical-corner', 'Classical Corner', 'Orchestras, piano and composers.', 'genre', 'classical', 'classical', true),
  ('soundtrack-scores', 'Soundtracks & Scores', 'Music from films, series and games.', 'genre', 'soundtrack', 'soundtrack', true),
  ('gospel-spirit', 'Gospel Spirit', 'Gospel and spiritual music.', 'genre', 'gospel', 'gospel', true),
  ('world-music', 'World Music', 'Sounds from every corner of the world.', 'genre', 'world', 'world', true)
ON CONFLICT (slug) DO NOTHING;

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
    'community_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.community_reactions r WHERE r.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
