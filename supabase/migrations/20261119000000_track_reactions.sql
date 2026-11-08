-- VIBRA Track Reactions (docs/track-reactions.md).
--
-- * When someone shares a song, others react with dedicated musical
--   reactions: fire, obsessed, underrated, classic, new_discovery,
--   on_repeat. A song share is a Daily Vibe, a "Now listening" story, a
--   feed post about a track (or a share of one) and a community music post.
--   Everything else keeps the general reactions (fire, heart, headphones,
--   clap, mind_blown).
-- * The server decides which set applies to each piece of content, so a
--   client cannot put a track reaction on a non-song or the reverse.
-- * The personal discovery collection (Discoveries) now accepts songs from
--   every song share, remembering where the song was found.
BEGIN;

-- ── Reaction sets ─────────────────────────────────────────────────────────
CREATE FUNCTION public.track_reactions()
RETURNS text[] LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT ARRAY['fire', 'obsessed', 'underrated', 'classic', 'new_discovery', 'on_repeat'];
$$;
GRANT EXECUTE ON FUNCTION public.track_reactions() TO authenticated, service_role;

CREATE FUNCTION public.general_reactions()
RETURNS text[] LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT ARRAY['fire', 'heart', 'headphones', 'clap', 'mind_blown'];
$$;
GRANT EXECUTE ON FUNCTION public.general_reactions() TO authenticated, service_role;

-- Raises unless p_reaction belongs to the set for this content.
CREATE FUNCTION vibra_private.require_reaction(p_is_song boolean, p_reaction text)
RETURNS void LANGUAGE plpgsql IMMUTABLE SET search_path = pg_catalog AS $$
BEGIN
  IF p_reaction IS NULL OR NOT (p_reaction = ANY (CASE WHEN p_is_song
      THEN public.track_reactions() ELSE public.general_reactions() END)) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_reaction';
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.require_reaction(boolean, text) FROM PUBLIC, anon, authenticated;

-- A community music post links a song on a supported provider.
CREATE FUNCTION public.is_song_link(p_url text)
RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path = pg_catalog AS $$
  SELECT COALESCE(p_url ~* '^https://(open\.spotify\.com/track/|music\.apple\.com/|music\.youtube\.com/|(www\.)?youtube\.com/|youtu\.be/|soundcloud\.com/|[a-z0-9-]+\.bandcamp\.com/)', false);
$$;
GRANT EXECUTE ON FUNCTION public.is_song_link(text) TO authenticated, service_role;

-- ── Daily Vibe: always a song, so track reactions only ────────────────────
-- Existing general reactions map to the closest musical one.
UPDATE public.daily_vibe_reactions SET reaction = CASE reaction
  WHEN 'heart' THEN 'obsessed' WHEN 'headphones' THEN 'on_repeat'
  WHEN 'clap' THEN 'classic' WHEN 'mind_blown' THEN 'new_discovery' ELSE reaction END
WHERE reaction IN ('heart', 'headphones', 'clap', 'mind_blown');
ALTER TABLE public.daily_vibe_reactions DROP CONSTRAINT IF EXISTS daily_vibe_reactions_reaction_check;
ALTER TABLE public.daily_vibe_reactions ADD CONSTRAINT daily_vibe_reactions_reaction_check
  CHECK (reaction IN ('fire', 'obsessed', 'underrated', 'classic', 'new_discovery', 'on_repeat'));

CREATE OR REPLACE FUNCTION public.toggle_daily_vibe_reaction(p_vibe uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_visible_vibe(p_vibe);
  PERFORM vibra_private.require_reaction(true, p_reaction);
  PERFORM public.consume_action_limit('vibe-reaction');
  DELETE FROM public.daily_vibe_reactions WHERE vibe_id = p_vibe AND user_id = auth.uid() AND reaction = p_reaction;
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.daily_vibe_reactions (vibe_id, user_id, reaction) VALUES (p_vibe, auth.uid(), p_reaction);
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_daily_vibe_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_daily_vibe_reaction(uuid, text) TO authenticated;

-- ── Stories: "Now listening" is a song ────────────────────────────────────
ALTER TABLE public.music_story_reactions DROP CONSTRAINT IF EXISTS music_story_reactions_reaction_check;
ALTER TABLE public.music_story_reactions ADD CONSTRAINT music_story_reactions_reaction_check
  CHECK (reaction IN ('fire', 'heart', 'headphones', 'clap', 'mind_blown',
    'obsessed', 'underrated', 'classic', 'new_discovery', 'on_repeat'));

CREATE OR REPLACE FUNCTION public.toggle_music_story_reaction(p_story uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE s public.music_stories%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  s := vibra_private.require_visible_story(p_story);
  PERFORM vibra_private.require_reaction(s.kind = 'now_playing', p_reaction);
  PERFORM public.consume_action_limit('story-reaction');
  DELETE FROM public.music_story_reactions WHERE story_id = p_story AND user_id = auth.uid() AND reaction = p_reaction;
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.music_story_reactions (story_id, user_id, reaction) VALUES (p_story, auth.uid(), p_reaction);
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_music_story_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_music_story_reaction(uuid, text) TO authenticated;

-- ── Feed: a post about a track, or a share of one ─────────────────────────
ALTER TABLE public.feed_post_reactions DROP CONSTRAINT IF EXISTS feed_post_reactions_reaction_check;
ALTER TABLE public.feed_post_reactions ADD CONSTRAINT feed_post_reactions_reaction_check
  CHECK (reaction IN ('like', 'fire', 'heart', 'headphones', 'clap', 'mind_blown',
    'obsessed', 'underrated', 'classic', 'new_discovery', 'on_repeat'));

CREATE FUNCTION public.feed_post_is_song(p_post public.feed_posts)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT CASE WHEN p_post.kind = 'share'
    THEN EXISTS (SELECT 1 FROM public.feed_posts o WHERE o.id = p_post.shared_post_id AND o.item_type = 'track')
    ELSE p_post.item_type = 'track' END;
$$;
REVOKE ALL ON FUNCTION public.feed_post_is_song(public.feed_posts) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.feed_post_is_song(public.feed_posts) TO authenticated;

CREATE OR REPLACE FUNCTION public.toggle_feed_reaction(p_post uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE p public.feed_posts%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  p := vibra_private.require_visible_post(p_post);
  -- The like button is on every post; emoji depend on the content.
  IF p_reaction IS DISTINCT FROM 'like' THEN
    PERFORM vibra_private.require_reaction(public.feed_post_is_song(p), p_reaction);
  END IF;
  PERFORM public.consume_action_limit('feed-reaction');
  DELETE FROM public.feed_post_reactions WHERE post_id = p_post AND user_id = auth.uid() AND reaction = p_reaction;
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.feed_post_reactions (post_id, user_id, reaction) VALUES (p_post, auth.uid(), p_reaction);
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_feed_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_feed_reaction(uuid, text) TO authenticated;

-- ── Communities: a music post with a song link ────────────────────────────
ALTER TABLE public.community_reactions DROP CONSTRAINT IF EXISTS community_reactions_reaction_check;
ALTER TABLE public.community_reactions ADD CONSTRAINT community_reactions_reaction_check
  CHECK (reaction IN ('fire', 'heart', 'headphones', 'clap', 'mind_blown',
    'obsessed', 'underrated', 'classic', 'new_discovery', 'on_repeat'));

CREATE OR REPLACE FUNCTION public.toggle_community_reaction(p_post uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_me uuid := auth.uid(); v_song boolean;
BEGIN
  PERFORM public.require_active_session();
  IF v_me IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  PERFORM vibra_private.community_post_access(p_post, v_me);
  SELECT kind = 'music' AND public.is_song_link(music->>'url') INTO v_song
  FROM public.community_posts WHERE id = p_post;
  PERFORM vibra_private.require_reaction(COALESCE(v_song, false), p_reaction);
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

-- ── Discoveries: songs from every song share ──────────────────────────────
ALTER TABLE public.discovery_collection
  ADD COLUMN source text NOT NULL DEFAULT 'vibe' CHECK (source IN ('vibe', 'story', 'post', 'community')),
  ADD COLUMN from_story_id uuid REFERENCES public.music_stories(id) ON DELETE SET NULL,
  ADD COLUMN from_post_id uuid REFERENCES public.feed_posts(id) ON DELETE SET NULL,
  ADD COLUMN from_community_post_id uuid REFERENCES public.community_posts(id) ON DELETE SET NULL,
  -- Who shared it (shown as "found via"; hidden later if either blocks).
  ADD COLUMN found_via uuid REFERENCES public.users(id) ON DELETE SET NULL;
UPDATE public.discovery_collection d SET found_via = v.user_id
FROM public.daily_vibes v WHERE v.id = d.from_vibe_id AND d.found_via IS NULL;

-- Saves a shared song. p_source: 'vibe' | 'story' | 'post' | 'community'.
-- Only songs, and only content the caller can see.
CREATE FUNCTION public.save_track_to_discoveries(p_source text, p_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_provider text; v_track text; v_title text; v_artist text; v_album text;
  v_art text; v_url text; v_via uuid;
  vb public.daily_vibes%ROWTYPE; st public.music_stories%ROWTYPE; fp public.feed_posts%ROWTYPE;
  cp public.community_posts%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  IF p_source = 'vibe' THEN
    vb := vibra_private.require_visible_vibe(p_id);
    v_provider := vb.provider; v_track := vb.track_id; v_title := vb.title; v_artist := vb.artist;
    v_album := vb.album; v_art := vb.artwork_url; v_url := vb.external_url; v_via := vb.user_id;
  ELSIF p_source = 'story' THEN
    st := vibra_private.require_visible_story(p_id);
    IF st.kind <> 'now_playing' THEN RAISE invalid_parameter_value USING MESSAGE = 'not_a_song'; END IF;
    v_provider := st.provider; v_track := st.item_id; v_title := st.title;
    v_artist := split_part(COALESCE(st.subtitle, ''), ' · ', 1); v_album := NULLIF(split_part(COALESCE(st.subtitle, ''), ' · ', 2), '');
    v_art := st.artwork_url; v_url := st.external_url; v_via := st.user_id;
  ELSIF p_source = 'post' THEN
    fp := vibra_private.require_visible_post(p_id);
    IF fp.kind = 'share' THEN
      v_via := fp.user_id;
      fp := vibra_private.require_visible_post(fp.shared_post_id);
    END IF;
    IF fp.item_type IS DISTINCT FROM 'track' THEN RAISE invalid_parameter_value USING MESSAGE = 'not_a_song'; END IF;
    v_provider := fp.provider; v_track := fp.item_id; v_title := fp.title;
    v_artist := split_part(COALESCE(fp.subtitle, ''), ' · ', 1); v_album := NULLIF(split_part(COALESCE(fp.subtitle, ''), ' · ', 2), '');
    v_art := fp.artwork_url; v_url := fp.external_url; v_via := COALESCE(v_via, fp.user_id);
  ELSIF p_source = 'community' THEN
    PERFORM vibra_private.community_post_access(p_id, auth.uid());
    SELECT * INTO cp FROM public.community_posts WHERE id = p_id;
    IF cp.kind <> 'music' OR NOT public.is_song_link(cp.music->>'url') THEN
      RAISE invalid_parameter_value USING MESSAGE = 'not_a_song';
    END IF;
    v_url := cp.music->>'url';
    v_provider := CASE WHEN v_url ~ '^https://open\.spotify\.com/track/' THEN 'spotify' ELSE 'link' END;
    v_track := CASE WHEN v_provider = 'spotify' THEN substring(v_url FROM 'track/([A-Za-z0-9]{22})') END;
    IF v_provider = 'spotify' AND v_track IS NULL THEN v_provider := 'link'; END IF;
    v_title := COALESCE(NULLIF(btrim(cp.music->>'title'), ''), cp.title, v_url);
    v_artist := COALESCE(NULLIF(btrim(cp.music->>'artist'), ''), '—');
    v_via := cp.author_id;
  ELSE
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_source';
  END IF;
  IF v_title IS NULL OR v_url IS NULL THEN RAISE invalid_parameter_value USING MESSAGE = 'not_a_song'; END IF;
  PERFORM public.consume_action_limit('discovery');
  IF (SELECT count(*) FROM public.discovery_collection WHERE user_id = auth.uid()) >= 500 THEN
    RAISE check_violation USING MESSAGE = 'discovery_limit';
  END IF;
  INSERT INTO public.discovery_collection (user_id, provider, track_id, title, artist, album, artwork_url,
    external_url, source, from_vibe_id, from_story_id, from_post_id, from_community_post_id, found_via)
  VALUES (auth.uid(), v_provider, v_track, left(v_title, 200), left(COALESCE(NULLIF(v_artist, ''), '—'), 300),
    left(v_album, 200), CASE WHEN v_art ~ '^https://i\.scdn\.co/' THEN v_art END, v_url, p_source,
    CASE WHEN p_source = 'vibe' THEN p_id END, CASE WHEN p_source = 'story' THEN p_id END,
    CASE WHEN p_source = 'post' THEN p_id END, CASE WHEN p_source = 'community' THEN p_id END,
    NULLIF(v_via, auth.uid()))
  ON CONFLICT (user_id, external_url) DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.save_track_to_discoveries(text, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_track_to_discoveries(text, uuid) TO authenticated;

-- The original Daily Vibe entry point, kept for existing clients.
CREATE OR REPLACE FUNCTION public.save_vibe_to_discoveries(p_vibe uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT public.save_track_to_discoveries('vibe', p_vibe);
$$;
REVOKE ALL ON FUNCTION public.save_vibe_to_discoveries(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.save_vibe_to_discoveries(uuid) TO authenticated;

-- My collection, newest first, with who I found each song through (only
-- while neither of us has blocked the other).
CREATE FUNCTION public.get_discoveries(p_limit integer DEFAULT 500)
RETURNS TABLE (id uuid, provider text, track_id text, title text, artist text, album text,
  artwork_url text, external_url text, source text, saved_at timestamptz,
  via_user_id uuid, via_name text)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT d.id, d.provider, d.track_id, d.title, d.artist, d.album, d.artwork_url, d.external_url,
    d.source, d.saved_at,
    CASE WHEN ok.visible THEN d.found_via END,
    CASE WHEN ok.visible THEN COALESCE(NULLIF(btrim(p.display_name), ''), p.username::text) END
  FROM public.discovery_collection d
  LEFT JOIN public.profile_discovery p ON p.id = d.found_via
  CROSS JOIN LATERAL (SELECT d.found_via IS NOT NULL
    AND public.may_access_message(auth.uid(), d.found_via) AS visible) ok
  WHERE d.user_id = auth.uid()
  ORDER BY d.saved_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 500), 1), 500);
$$;
REVOKE ALL ON FUNCTION public.get_discoveries(integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_discoveries(integer) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
