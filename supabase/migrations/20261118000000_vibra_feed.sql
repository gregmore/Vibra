-- VIBRA Feed (docs/vibra-feed.md): a personalized, music-focused feed.
--
-- * Posts: song, album, playlist, recommendation, discovery, review (with a
--   1–5 rating), opinion, concert photo, and shares of other posts. Music
--   items are re-fetched from Spotify by the feed-posts Edge Function (or a
--   link to another provider with typed text). Metadata, provider-hosted
--   artwork and a link back only; no audio, ever.
-- * Likes, emoji reactions, comments with replies, shares, bookmarks,
--   "not interested", reports (3 hold a post or comment), rate limits,
--   duplicate-post checks and comment notifications.
-- * get_feed: 'for_you' ranks by relevance (people you follow, connections,
--   musical matches, joined communities, shared genres and artists, your
--   recent interactions) with bounded weights. Popularity is a small,
--   capped signal; the same author, the same item and posts you have
--   already seen are pushed down. 'following' and 'latest' are strictly
--   chronological.
BEGIN;

-- ── Storage (concert photos) ──────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('feed-media', 'feed-media', false, 10485760, ARRAY['image/png'])
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Only the upload-image Edge Function (service role) writes feed photos.
CREATE POLICY feed_media_upload_requires_backend ON storage.objects
AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK (bucket_id <> 'feed-media');
CREATE POLICY feed_media_replace_requires_backend ON storage.objects
AS RESTRICTIVE FOR UPDATE TO authenticated USING (bucket_id <> 'feed-media')
WITH CHECK (bucket_id <> 'feed-media');
CREATE POLICY feed_media_delete_requires_backend ON storage.objects
AS RESTRICTIVE FOR DELETE TO authenticated USING (bucket_id <> 'feed-media');

CREATE OR REPLACE FUNCTION public.guard_account_storage_write()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog AS $$
DECLARE uid uuid;
BEGIN
  IF NEW.bucket_id NOT IN ('avatars','chat-media','support-attachments','story-media','feed-media') THEN RETURN NEW; END IF;
  uid:=split_part(NEW.name,'/',1)::uuid;
  PERFORM pg_advisory_xact_lock(hashtextextended(uid::text,4721));
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id=uid) OR
    EXISTS (SELECT 1 FROM vibra_private.account_erasures WHERE user_id=uid) THEN
    RAISE insufficient_privilege USING MESSAGE='Account unavailable for uploads';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.guard_account_storage_write() FROM PUBLIC,anon,authenticated;

-- ── Tables ────────────────────────────────────────────────────────────────
CREATE TABLE public.feed_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN ('song', 'album', 'playlist', 'recommendation', 'discovery',
    'review', 'opinion', 'concert_photo', 'share')),
  provider text CHECK (provider IN ('spotify', 'link')),
  item_type text CHECK (item_type IN ('track', 'album', 'artist', 'playlist')),
  item_id text CHECK (item_id ~ '^[A-Za-z0-9]{22}$'),
  title text CHECK (char_length(title) BETWEEN 1 AND 200),
  subtitle text CHECK (char_length(subtitle) <= 300),
  artwork_url text CHECK (artwork_url ~ '^https://(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)/'),
  external_url text CHECK (char_length(external_url) <= 300 AND external_url ~ '^https://'),
  media_path text UNIQUE CHECK (media_path ~ '^[0-9a-f-]{36}/[0-9a-f-]{36}\.png$'),
  event_id uuid REFERENCES public.events(id) ON DELETE SET NULL,
  body text CHECK (char_length(btrim(body)) BETWEEN 1 AND 2000),
  rating smallint CHECK (rating BETWEEN 1 AND 5),
  -- Set by the server from the provider's artist genres (catalogue keys:
  -- subgenres and their families) and artist names, for relevance only.
  genre_keys text[] NOT NULL DEFAULT '{}' CHECK (cardinality(genre_keys) <= 12),
  artist_keys text[] NOT NULL DEFAULT '{}' CHECK (cardinality(artist_keys) <= 5),
  shared_post_id uuid REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  visibility text NOT NULL DEFAULT 'everyone' CHECK (visibility IN ('connections', 'everyone')),
  comments_enabled boolean NOT NULL DEFAULT true,
  held_for_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (kind <> 'review' OR (rating IS NOT NULL AND body IS NOT NULL)),
  CHECK (rating IS NULL OR kind = 'review'),
  CHECK (CASE kind
    WHEN 'share' THEN shared_post_id IS NOT NULL AND provider IS NULL AND media_path IS NULL
    WHEN 'opinion' THEN body IS NOT NULL AND provider IS NULL AND media_path IS NULL
    WHEN 'concert_photo' THEN media_path IS NOT NULL AND provider IS NULL
    ELSE provider IS NOT NULL AND item_type IS NOT NULL AND title IS NOT NULL AND external_url IS NOT NULL
      AND media_path IS NULL AND (provider <> 'spotify' OR item_id IS NOT NULL)
  END),
  CHECK (shared_post_id IS NULL OR kind = 'share')
);
CREATE INDEX feed_posts_recent_idx ON public.feed_posts (created_at DESC);
CREATE INDEX feed_posts_author_idx ON public.feed_posts (user_id, created_at DESC);
CREATE INDEX feed_posts_shared_idx ON public.feed_posts (shared_post_id) WHERE shared_post_id IS NOT NULL;
CREATE INDEX feed_posts_genres_idx ON public.feed_posts USING gin (genre_keys);

-- 'like' is the like button; the rest are the VIBRA emoji reactions.
CREATE TABLE public.feed_post_reactions (
  post_id uuid NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reaction text NOT NULL CHECK (reaction IN ('like', 'fire', 'heart', 'headphones', 'clap', 'mind_blown')),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (post_id, user_id, reaction)
);
CREATE INDEX feed_post_reactions_user_idx ON public.feed_post_reactions (user_id, created_at DESC);

CREATE TABLE public.feed_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  parent_id uuid REFERENCES public.feed_comments(id) ON DELETE CASCADE,
  body text NOT NULL CHECK (char_length(btrim(body)) BETWEEN 1 AND 1000),
  held_for_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX feed_comments_post_idx ON public.feed_comments (post_id, created_at);
CREATE INDEX feed_comments_author_idx ON public.feed_comments (author_id, created_at DESC);

CREATE TABLE public.feed_bookmarks (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  post_id uuid NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);

-- How often a post was shown to me (to avoid repeating it) and posts I
-- marked "not interested". Private to their owner.
CREATE TABLE public.feed_impressions (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  post_id uuid NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  shown_count integer NOT NULL DEFAULT 1 CHECK (shown_count >= 0),
  last_shown_at timestamptz NOT NULL DEFAULT now(),
  dismissed boolean NOT NULL DEFAULT false,
  PRIMARY KEY (user_id, post_id)
);

CREATE TABLE vibra_private.feed_post_log (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  posted_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX feed_post_log_idx ON vibra_private.feed_post_log (user_id, posted_at);
REVOKE ALL ON vibra_private.feed_post_log FROM PUBLIC, anon, authenticated;

-- ── Visibility ────────────────────────────────────────────────────────────
-- Same audience rules as Daily Vibe and Music Stories: 'everyone' or
-- connections and mutual musical matches; blocks and test segments always
-- apply. Held posts are visible to their author only.
CREATE FUNCTION public.can_see_feed_post(p_author uuid, p_visibility text, p_held boolean)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT public.can_see_daily_vibe(p_author, p_visibility, NULL, p_held);
$$;
REVOKE ALL ON FUNCTION public.can_see_feed_post(uuid, text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.can_see_feed_post(uuid, text, boolean) TO authenticated;

ALTER TABLE public.feed_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY feed_posts_read ON public.feed_posts FOR SELECT TO authenticated
  USING (public.can_see_feed_post(user_id, visibility, held_for_review));

ALTER TABLE public.feed_post_reactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY feed_post_reactions_read ON public.feed_post_reactions FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.feed_posts p WHERE p.id = post_id));

ALTER TABLE public.feed_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY feed_comments_read ON public.feed_comments FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.feed_posts p WHERE p.id = post_id)
    AND (author_id = (SELECT auth.uid()) OR (NOT held_for_review AND public.may_access_message((SELECT auth.uid()), author_id))));

ALTER TABLE public.feed_bookmarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY feed_bookmarks_owner ON public.feed_bookmarks FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));
ALTER TABLE public.feed_impressions ENABLE ROW LEVEL SECURITY;
CREATE POLICY feed_impressions_owner ON public.feed_impressions FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

REVOKE ALL ON public.feed_posts, public.feed_post_reactions, public.feed_comments,
  public.feed_bookmarks, public.feed_impressions FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.feed_posts, public.feed_post_reactions, public.feed_comments,
  public.feed_bookmarks, public.feed_impressions TO authenticated;
GRANT ALL ON public.feed_posts, public.feed_post_reactions, public.feed_comments,
  public.feed_bookmarks, public.feed_impressions TO service_role;

-- A photo is readable only while its post is visible to the caller.
CREATE POLICY feed_media_select_visible ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'feed-media' AND EXISTS (
  SELECT 1 FROM public.feed_posts p WHERE p.media_path = storage.objects.name));

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
    WHEN 'story-reaction' THEN 60 WHEN 'story-reply' THEN 20 WHEN 'story-view' THEN 120
    WHEN 'story-settings' THEN 30
    WHEN 'feed-reaction' THEN 60 WHEN 'feed-comment' THEN 10 WHEN 'feed-bookmark' THEN 30
    WHEN 'feed-seen' THEN 60 WHEN 'feed-read' THEN 60
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

-- A post the caller can see (RLS-equivalent check for DEFINER writes).
CREATE FUNCTION vibra_private.require_visible_post(p_post uuid)
RETURNS public.feed_posts LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE p public.feed_posts%ROWTYPE;
BEGIN
  SELECT * INTO p FROM public.feed_posts WHERE id = p_post;
  IF NOT FOUND OR NOT public.can_see_feed_post(p.user_id, p.visibility, p.held_for_review) THEN
    RAISE no_data_found USING MESSAGE = 'post_not_found';
  END IF;
  RETURN p;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.require_visible_post(uuid) FROM PUBLIC, anon, authenticated;

-- ── Posting (service role: called by the feed-posts Edge Function) ────────
-- At most 5 posts a minute and 50 a day. The same link or the same text
-- twice within a day is refused (repetitive content). A share must point to
-- a post the author can see, and never to another share.
CREATE FUNCTION public.create_feed_post(p_user_id uuid, p_post jsonb)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE
  v_id uuid; v_media text := p_post->>'media_path'; v_event uuid; v_shared uuid;
  v_body text := NULLIF(btrim(p_post->>'body'), ''); v_kind text := p_post->>'kind';
  v_original public.feed_posts%ROWTYPE;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  PERFORM vibra_private.community_text_guard(v_body);
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE no_data_found USING MESSAGE = 'user_not_found'; END IF;
  IF (SELECT count(*) FROM vibra_private.feed_post_log WHERE user_id = p_user_id AND posted_at > now() - interval '1 minute') >= 5
     OR (SELECT count(*) FROM vibra_private.feed_post_log WHERE user_id = p_user_id AND posted_at > now() - interval '1 day') >= 50 THEN
    RAISE SQLSTATE 'PT429' USING MESSAGE = 'feed_rate_limit';
  END IF;
  IF p_post->>'external_url' IS NOT NULL AND EXISTS (SELECT 1 FROM public.feed_posts p
      WHERE p.user_id = p_user_id AND p.external_url = p_post->>'external_url' AND p.created_at > now() - interval '1 day') THEN
    RAISE check_violation USING MESSAGE = 'duplicate_post';
  END IF;
  IF v_body IS NOT NULL AND length(vibra_private.normalize_text(v_body)) >= 12 AND EXISTS (SELECT 1 FROM public.feed_posts p
      WHERE p.user_id = p_user_id AND p.created_at > now() - interval '1 day'
        AND vibra_private.normalize_text(p.body) = vibra_private.normalize_text(v_body)) THEN
    RAISE check_violation USING MESSAGE = 'duplicate_post';
  END IF;
  IF v_media IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM storage.objects o WHERE o.bucket_id = 'feed-media' AND o.name = v_media
        AND split_part(o.name, '/', 1) = p_user_id::text) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_media';
  END IF;
  IF v_kind = 'share' THEN
    SELECT * INTO v_original FROM public.feed_posts WHERE id = (p_post->>'shared_post_id')::uuid;
    IF NOT FOUND OR v_original.kind = 'share' OR v_original.held_for_review
       OR v_original.user_id = p_user_id
       OR NOT (v_original.visibility = 'everyone' OR EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
         AND ((f.requester_id = p_user_id AND f.receiver_id = v_original.user_id)
           OR (f.requester_id = v_original.user_id AND f.receiver_id = p_user_id))))
       OR EXISTS (SELECT 1 FROM public.blocked_users b
         WHERE (b.blocker_id = p_user_id AND b.blocked_id = v_original.user_id)
            OR (b.blocker_id = v_original.user_id AND b.blocked_id = p_user_id)) THEN
      RAISE invalid_parameter_value USING MESSAGE = 'invalid_share';
    END IF;
    IF EXISTS (SELECT 1 FROM public.feed_posts WHERE user_id = p_user_id AND shared_post_id = v_original.id) THEN
      RAISE check_violation USING MESSAGE = 'duplicate_post';
    END IF;
    v_shared := v_original.id;
  END IF;
  IF p_post->>'event_id' ~ '^[0-9a-f-]{36}$' THEN
    SELECT id INTO v_event FROM public.events WHERE id = (p_post->>'event_id')::uuid;
  END IF;
  INSERT INTO vibra_private.feed_post_log (user_id) VALUES (p_user_id);
  INSERT INTO public.feed_posts (user_id, kind, provider, item_type, item_id, title, subtitle, artwork_url,
    external_url, media_path, event_id, body, rating, genre_keys, artist_keys, shared_post_id,
    visibility, comments_enabled)
  VALUES (p_user_id, v_kind, p_post->>'provider', p_post->>'item_type', p_post->>'item_id',
    NULLIF(btrim(p_post->>'title'), ''), NULLIF(btrim(p_post->>'subtitle'), ''),
    p_post->>'artwork_url', p_post->>'external_url', v_media, v_event, v_body,
    CASE WHEN v_kind = 'review' THEN (p_post->>'rating')::smallint END,
    -- A share inherits the original's genres for relevance.
    CASE WHEN v_shared IS NOT NULL THEN v_original.genre_keys
      ELSE ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_post->'genre_keys', '[]'::jsonb)) LIMIT 12) END,
    CASE WHEN v_shared IS NOT NULL THEN v_original.artist_keys
      ELSE ARRAY(SELECT lower(jsonb_array_elements_text(COALESCE(p_post->'artist_keys', '[]'::jsonb))) LIMIT 5) END,
    v_shared, COALESCE(p_post->>'visibility', 'everyone'),
    COALESCE((p_post->>'comments_enabled')::boolean, true))
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_feed_post(uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_feed_post(uuid, jsonb) TO service_role;

CREATE FUNCTION public.delete_my_feed_post(p_post uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  -- Shares of it go with it (ON DELETE CASCADE); the photo is purged later.
  DELETE FROM public.feed_posts WHERE id = p_post AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.delete_my_feed_post(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_feed_post(uuid) TO authenticated;

CREATE FUNCTION public.update_my_feed_post(p_post uuid, p_visibility text, p_comments_enabled boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('feed-bookmark');
  UPDATE public.feed_posts SET visibility = COALESCE(p_visibility, visibility),
    comments_enabled = COALESCE(p_comments_enabled, comments_enabled)
  WHERE id = p_post AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.update_my_feed_post(uuid, text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.update_my_feed_post(uuid, text, boolean) TO authenticated;

-- ── Likes, reactions, comments, bookmarks ─────────────────────────────────
CREATE FUNCTION public.toggle_feed_reaction(p_post uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE p public.feed_posts%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  p := vibra_private.require_visible_post(p_post);
  PERFORM public.consume_action_limit('feed-reaction');
  DELETE FROM public.feed_post_reactions WHERE post_id = p_post AND user_id = auth.uid() AND reaction = p_reaction;
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.feed_post_reactions (post_id, user_id, reaction) VALUES (p_post, auth.uid(), p_reaction);
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_feed_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_feed_reaction(uuid, text) TO authenticated;

CREATE FUNCTION public.add_feed_comment(p_post uuid, p_body text, p_parent uuid DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE p public.feed_posts%ROWTYPE; v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  p := vibra_private.require_visible_post(p_post);
  IF NOT p.comments_enabled AND p.user_id <> auth.uid() THEN
    RAISE insufficient_privilege USING MESSAGE = 'comments_off';
  END IF;
  PERFORM public.consume_action_limit('feed-comment');
  PERFORM vibra_private.community_text_guard(p_body);
  IF p_parent IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM public.feed_comments c WHERE c.id = p_parent AND c.post_id = p_post AND c.parent_id IS NULL
        AND public.may_access_message(auth.uid(), c.author_id)) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_parent';
  END IF;
  IF (SELECT count(*) FROM public.feed_comments WHERE author_id = auth.uid() AND created_at > now() - interval '1 day') >= 300 THEN
    RAISE check_violation USING MESSAGE = 'feed_comment_daily_limit';
  END IF;
  -- The same comment on the same post twice is spam, not conversation.
  IF EXISTS (SELECT 1 FROM public.feed_comments c WHERE c.post_id = p_post AND c.author_id = auth.uid()
      AND vibra_private.normalize_text(c.body) = vibra_private.normalize_text(p_body)) THEN
    RAISE check_violation USING MESSAGE = 'duplicate_comment';
  END IF;
  INSERT INTO public.feed_comments (post_id, author_id, parent_id, body)
  VALUES (p_post, auth.uid(), p_parent, btrim(p_body)) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.add_feed_comment(uuid, text, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_feed_comment(uuid, text, uuid) TO authenticated;

-- The author, or the post's owner, deletes a comment.
CREATE FUNCTION public.delete_feed_comment(p_comment uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  DELETE FROM public.feed_comments c
  WHERE c.id = p_comment AND (c.author_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.feed_posts p WHERE p.id = c.post_id AND p.user_id = auth.uid()));
END;
$$;
REVOKE ALL ON FUNCTION public.delete_feed_comment(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_feed_comment(uuid) TO authenticated;

CREATE FUNCTION public.set_feed_bookmark(p_post uuid, p_saved boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('feed-bookmark');
  IF p_saved THEN
    PERFORM vibra_private.require_visible_post(p_post);
    IF (SELECT count(*) FROM public.feed_bookmarks WHERE user_id = auth.uid()) >= 1000 THEN
      RAISE check_violation USING MESSAGE = 'bookmark_limit';
    END IF;
    INSERT INTO public.feed_bookmarks (user_id, post_id) VALUES (auth.uid(), p_post) ON CONFLICT DO NOTHING;
  ELSE
    DELETE FROM public.feed_bookmarks WHERE user_id = auth.uid() AND post_id = p_post;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_feed_bookmark(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_feed_bookmark(uuid, boolean) TO authenticated;

-- Posts the app showed (anti-repetition) and "not interested".
CREATE FUNCTION public.mark_feed_seen(p_posts uuid[])
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('feed-seen');
  INSERT INTO public.feed_impressions AS i (user_id, post_id)
  SELECT auth.uid(), p.id FROM public.feed_posts p
  WHERE p.id = ANY (p_posts[1:50]) AND p.user_id <> auth.uid()
  ON CONFLICT (user_id, post_id) DO UPDATE SET
    -- One showing per hour at most, so scrolling back and forth is not "repeated".
    shown_count = i.shown_count + CASE WHEN i.last_shown_at < now() - interval '1 hour' THEN 1 ELSE 0 END,
    last_shown_at = CASE WHEN i.last_shown_at < now() - interval '1 hour' THEN now() ELSE i.last_shown_at END;
END;
$$;
REVOKE ALL ON FUNCTION public.mark_feed_seen(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_feed_seen(uuid[]) TO authenticated;

CREATE FUNCTION public.set_feed_not_interested(p_post uuid, p_dismissed boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('feed-bookmark');
  PERFORM vibra_private.require_visible_post(p_post);
  INSERT INTO public.feed_impressions (user_id, post_id, dismissed) VALUES (auth.uid(), p_post, p_dismissed)
  ON CONFLICT (user_id, post_id) DO UPDATE SET dismissed = EXCLUDED.dismissed;
END;
$$;
REVOKE ALL ON FUNCTION public.set_feed_not_interested(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_feed_not_interested(uuid, boolean) TO authenticated;

-- ── Reads ─────────────────────────────────────────────────────────────────
-- One row per post, with the shared original nested (if still visible) and
-- the caller's own state. Used by every read below.
CREATE FUNCTION public.feed_post_rows(p_ids uuid[])
RETURNS TABLE (
  id uuid, user_id uuid, username text, display_name text, avatar_url text,
  kind text, provider text, item_type text, item_id text, title text, subtitle text, artwork_url text,
  external_url text, media_path text, event_id uuid, event_name text, body text, rating smallint,
  genre_keys text[], visibility text, comments_enabled boolean, created_at timestamptz,
  like_count bigint, reactions jsonb, my_reactions text[], comment_count bigint, share_count bigint,
  bookmarked boolean, held_for_review boolean, shared jsonb
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT p.id, p.user_id, d.username::text, d.display_name, d.avatar_url,
    p.kind, p.provider, p.item_type, p.item_id, p.title, p.subtitle, p.artwork_url,
    p.external_url, p.media_path, p.event_id, e.name, p.body, p.rating,
    p.genre_keys, p.visibility, p.comments_enabled, p.created_at,
    (SELECT count(*) FROM public.feed_post_reactions r WHERE r.post_id = p.id AND r.reaction = 'like'),
    COALESCE((SELECT jsonb_object_agg(x.reaction, x.n) FROM (
      SELECT r.reaction, count(*) AS n FROM public.feed_post_reactions r
      WHERE r.post_id = p.id AND r.reaction <> 'like' GROUP BY r.reaction) x), '{}'::jsonb),
    ARRAY(SELECT r.reaction FROM public.feed_post_reactions r WHERE r.post_id = p.id AND r.user_id = auth.uid()),
    (SELECT count(*) FROM public.feed_comments c WHERE c.post_id = p.id),
    (SELECT count(*) FROM public.feed_posts s WHERE s.shared_post_id = p.id),
    EXISTS (SELECT 1 FROM public.feed_bookmarks b WHERE b.user_id = auth.uid() AND b.post_id = p.id),
    p.held_for_review,
    (SELECT jsonb_build_object('id', o.id, 'user_id', o.user_id, 'username', od.username,
        'display_name', od.display_name, 'avatar_url', od.avatar_url, 'kind', o.kind,
        'provider', o.provider, 'item_type', o.item_type, 'item_id', o.item_id, 'title', o.title,
        'subtitle', o.subtitle, 'artwork_url', o.artwork_url, 'external_url', o.external_url,
        'media_path', o.media_path, 'body', o.body, 'rating', o.rating, 'created_at', o.created_at)
      FROM public.feed_posts o LEFT JOIN public.profile_discovery od ON od.id = o.user_id
      WHERE o.id = p.shared_post_id)
  FROM public.feed_posts p
  JOIN public.profile_discovery d ON d.id = p.user_id
  LEFT JOIN public.events e ON e.id = p.event_id
  WHERE p.id = ANY (p_ids)
    -- A share whose original is gone or no longer visible is not shown.
    AND (p.shared_post_id IS NULL OR EXISTS (SELECT 1 FROM public.feed_posts o WHERE o.id = p.shared_post_id));
$$;
REVOKE ALL ON FUNCTION public.feed_post_rows(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.feed_post_rows(uuid[]) TO authenticated;

-- The feed.
--   'for_you'   relevance-ranked (below); page with p_exclude (ids already shown)
--   'following' people I follow, my connections and me, newest first
--   'latest'    every post visible to me, newest first
-- Chronological pages use p_before (created_at of the last post).
-- Each row has a `reason` so the app can say why a post is shown.
CREATE FUNCTION public.get_feed(
  p_mode text DEFAULT 'for_you', p_before timestamptz DEFAULT NULL,
  p_exclude uuid[] DEFAULT '{}', p_limit integer DEFAULT 20
)
RETURNS TABLE (post_id uuid, score double precision, reason text)
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
#variable_conflict use_column
DECLARE
  me uuid := auth.uid();
  lim integer := LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50);
  my_genres text[]; my_artists text[]; my_community_genres text[];
BEGIN
  IF me IS NULL THEN RAISE SQLSTATE 'PT401' USING MESSAGE = 'Authentication required'; END IF;

  IF p_mode = 'following' OR p_mode = 'latest' THEN
    RETURN QUERY
    SELECT p.id, 0::double precision, CASE WHEN p.user_id = me THEN 'mine' ELSE 'chronological' END
    FROM public.feed_posts p
    WHERE (p_before IS NULL OR p.created_at < p_before)
      AND (p_mode = 'latest'
        OR p.user_id = me
        OR EXISTS (SELECT 1 FROM public.follows f WHERE f.follower_id = me AND f.following_id = p.user_id)
        OR EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
          AND ((f.requester_id = me AND f.receiver_id = p.user_id) OR (f.requester_id = p.user_id AND f.receiver_id = me))))
      AND NOT EXISTS (SELECT 1 FROM public.feed_impressions i WHERE i.user_id = me AND i.post_id = p.id AND i.dismissed)
    ORDER BY p.created_at DESC
    LIMIT lim;
    RETURN;
  END IF;

  -- My musical interests: the latest Musical DNA (families, subgenres,
  -- artists), the genres I picked, and the genres of communities I joined.
  SELECT
    ARRAY(SELECT f.key FROM jsonb_to_recordset(COALESCE(s.dna->'families', '[]')) AS f(key text)
      UNION SELECT g.key FROM jsonb_to_recordset(COALESCE(s.dna->'subgenres', '[]')) AS g(key text)),
    ARRAY(SELECT lower(a.name) FROM jsonb_to_recordset(COALESCE(s.dna->'artists', '[]')) AS a(name text))
  INTO my_genres, my_artists
  FROM public.musical_dna_snapshots s WHERE s.user_id = me ORDER BY s.captured_on DESC LIMIT 1;
  my_genres := COALESCE(my_genres, '{}') || ARRAY(SELECT g.genre_key FROM public.user_genre_preferences g WHERE g.user_id = me);
  my_community_genres := ARRAY(
    SELECT DISTINCT x
    FROM public.community_members m
    JOIN public.communities c ON c.id = m.community_id
    CROSS JOIN LATERAL unnest(ARRAY[c.genre_key, c.genre_family]) AS x
    WHERE m.user_id = me AND c.archived_at IS NULL AND x IS NOT NULL);
  my_artists := COALESCE(my_artists, '{}');

  RETURN QUERY
  WITH candidates AS (
    SELECT p.id, p.user_id, p.created_at, p.genre_keys, p.artist_keys,
      COALESCE(p.item_id, p.external_url, p.shared_post_id::text, p.id::text) AS item_key,
      COALESCE(i.shown_count, 0) AS shown
    FROM public.feed_posts p
    LEFT JOIN public.feed_impressions i ON i.user_id = me AND i.post_id = p.id
    WHERE p.created_at > now() - interval '14 days'
      AND p.user_id <> me
      AND NOT (p.id = ANY (COALESCE(p_exclude, '{}')))
      AND NOT COALESCE(i.dismissed, false)
      AND COALESCE(i.shown_count, 0) < 4
    ORDER BY p.created_at DESC
    LIMIT 1500
  ), signals AS (
    SELECT c.*,
      EXISTS (SELECT 1 FROM public.follows f WHERE f.follower_id = me AND f.following_id = c.user_id) AS followed,
      EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
        AND ((f.requester_id = me AND f.receiver_id = c.user_id) OR (f.requester_id = c.user_id AND f.receiver_id = me))) AS connected,
      COALESCE((SELECT m.compatibility FROM public.user_matches m
        WHERE m.user_id_a = LEAST(me, c.user_id) AND m.user_id_b = GREATEST(me, c.user_id)), 0)::double precision AS compat,
      EXISTS (SELECT 1 FROM public.community_members a JOIN public.community_members b ON b.community_id = a.community_id
        WHERE a.user_id = me AND b.user_id = c.user_id) AS co_member,
      cardinality(ARRAY(SELECT unnest(c.genre_keys) INTERSECT SELECT unnest(my_genres))) AS genre_hits,
      cardinality(ARRAY(SELECT unnest(c.genre_keys) INTERSECT SELECT unnest(my_community_genres))) AS community_genre_hits,
      cardinality(ARRAY(SELECT unnest(c.artist_keys) INTERSECT SELECT unnest(my_artists))) AS artist_hits,
      -- My own recent likes/reactions and comments on this author's posts.
      ((SELECT count(*) FROM public.feed_post_reactions r JOIN public.feed_posts q ON q.id = r.post_id
         WHERE r.user_id = me AND q.user_id = c.user_id AND r.created_at > now() - interval '30 days')
       + (SELECT count(*) FROM public.feed_comments x JOIN public.feed_posts q ON q.id = x.post_id
         WHERE x.author_id = me AND q.user_id = c.user_id AND x.created_at > now() - interval '30 days'))::double precision AS my_interactions,
      -- Distinct people (not the author) who engaged: a small, capped
      -- quality signal, never raw counts.
      (SELECT count(DISTINCT u) FROM (
        SELECT r.user_id AS u FROM public.feed_post_reactions r WHERE r.post_id = c.id AND r.user_id <> c.user_id
        UNION SELECT x.author_id FROM public.feed_comments x WHERE x.post_id = c.id AND x.author_id <> c.user_id) e
      )::double precision AS engagers
    FROM candidates c
  ), scored AS (
    SELECT s.*,
      (CASE WHEN s.followed THEN 3.0 ELSE 0 END
       + CASE WHEN s.connected THEN 2.5 ELSE 0 END
       + 1.5 * LEAST(s.compat, 100) / 100
       + CASE WHEN s.co_member THEN 1.0 ELSE 0 END
       + 2.0 * LEAST(s.genre_hits, 3) / 3.0
       + 0.8 * LEAST(s.community_genre_hits, 2) / 2.0
       + 1.0 * LEAST(s.artist_hits, 1)
       + 1.5 * LEAST(ln(1 + s.my_interactions) / ln(11), 1)
       + 0.5 * LEAST(ln(1 + s.engagers) / ln(51), 1)
       + 0.2) -- every visible post can surface, so new people are reachable
      -- Freshness: half the weight after ~33 hours.
      * exp(-extract(epoch FROM now() - s.created_at) / 3600.0 / 48.0)
      -- Already shown: less each time (hidden after 4 showings).
      * power(0.6, s.shown) AS base,
      CASE
        WHEN s.followed THEN 'following'
        WHEN s.connected THEN 'connection'
        WHEN s.artist_hits > 0 THEN 'artists'
        WHEN s.genre_hits > 0 THEN 'genres'
        WHEN s.co_member OR s.community_genre_hits > 0 THEN 'community'
        WHEN s.compat > 0 THEN 'match'
        WHEN s.my_interactions > 0 THEN 'interaction'
        ELSE 'new'
      END AS why
    FROM signals s
  ), diversified AS (
    SELECT s.id, s.why,
      -- The same author or the same song/album again in one feed: halved
      -- for each repeat, so one person or one release cannot fill it.
      s.base * power(0.5, (row_number() OVER (PARTITION BY s.user_id ORDER BY s.base DESC)) - 1)
             * power(0.35, (row_number() OVER (PARTITION BY s.item_key ORDER BY s.base DESC)) - 1) AS final
    FROM scored s
  )
  SELECT d.id, d.final, d.why FROM diversified d
  ORDER BY d.final DESC, d.id
  LIMIT lim;
END;
$$;
REVOKE ALL ON FUNCTION public.get_feed(text, timestamptz, uuid[], integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_feed(text, timestamptz, uuid[], integer) TO authenticated;

-- A person's posts (their profile), newest first. RLS decides visibility.
CREATE FUNCTION public.get_user_feed_posts(p_user uuid, p_before timestamptz DEFAULT NULL, p_limit integer DEFAULT 20)
RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT p.id FROM public.feed_posts p
  WHERE p.user_id = p_user AND (p_before IS NULL OR p.created_at < p_before)
  ORDER BY p.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 20), 1), 50);
$$;
REVOKE ALL ON FUNCTION public.get_user_feed_posts(uuid, timestamptz, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_user_feed_posts(uuid, timestamptz, integer) TO authenticated;

-- My bookmarks, most recently saved first.
CREATE FUNCTION public.get_feed_bookmarks(p_before timestamptz DEFAULT NULL, p_limit integer DEFAULT 30)
RETURNS TABLE (post_id uuid, saved_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT b.post_id, b.created_at FROM public.feed_bookmarks b
  JOIN public.feed_posts p ON p.id = b.post_id
  WHERE b.user_id = auth.uid() AND (p_before IS NULL OR b.created_at < p_before)
  ORDER BY b.created_at DESC
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 30), 1), 50);
$$;
REVOKE ALL ON FUNCTION public.get_feed_bookmarks(timestamptz, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_feed_bookmarks(timestamptz, integer) TO authenticated;

CREATE FUNCTION public.get_feed_comments(p_post uuid)
RETURNS TABLE (id uuid, parent_id uuid, author_id uuid, username text, display_name text, avatar_url text, body text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT c.id, c.parent_id, c.author_id, d.username::text, d.display_name, d.avatar_url, c.body, c.created_at
  FROM public.feed_comments c
  LEFT JOIN public.profile_discovery d ON d.id = c.author_id
  WHERE c.post_id = p_post
  ORDER BY c.created_at
  LIMIT 500;
$$;
REVOKE ALL ON FUNCTION public.get_feed_comments(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_feed_comments(uuid) TO authenticated;

-- Photos no post uses (deleted, or uploaded and never posted within an
-- hour). The media-purge worker deletes them through Storage's API.
CREATE FUNCTION public.list_orphan_feed_media(p_limit integer DEFAULT 200)
RETURNS TABLE (name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT o.name FROM storage.objects o
  WHERE o.bucket_id = 'feed-media' AND o.created_at < now() - interval '1 hour'
    AND NOT EXISTS (SELECT 1 FROM public.feed_posts p WHERE p.media_path = o.name)
  ORDER BY o.created_at
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 200), 1), 1000);
$$;
REVOKE ALL ON FUNCTION public.list_orphan_feed_media(integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.list_orphan_feed_media(integer) TO service_role;

-- Impressions older than 30 days no longer matter for repetition.
CREATE FUNCTION vibra_private.purge_feed_impressions()
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $$
  DELETE FROM public.feed_impressions WHERE NOT dismissed AND last_shown_at < now() - interval '30 days';
  DELETE FROM vibra_private.feed_post_log WHERE posted_at < now() - interval '2 days';
$$;
REVOKE ALL ON FUNCTION vibra_private.purge_feed_impressions() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('purge-feed-impressions', '41 3 * * *', 'SELECT vibra_private.purge_feed_impressions();');

-- ── Reports ───────────────────────────────────────────────────────────────
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS feed_post_id uuid REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS feed_comment_id uuid REFERENCES public.feed_comments(id) ON DELETE CASCADE;

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
      IF NEW.music_story_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.music_stories s WHERE s.id=NEW.music_story_id AND s.user_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible stories may be reported';
      END IF;
      IF NEW.music_story_reply_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.music_story_replies r WHERE r.id=NEW.music_story_reply_id
          AND r.sender_id=NEW.reported_id AND r.recipient_id=auth.uid()
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only received replies may be reported';
      END IF;
      IF NEW.feed_post_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.feed_posts p WHERE p.id=NEW.feed_post_id AND p.user_id=NEW.reported_id
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only visible posts may be reported';
      END IF;
      IF NEW.feed_comment_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.feed_comments c WHERE c.id=NEW.feed_comment_id AND c.author_id=NEW.reported_id
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

CREATE FUNCTION vibra_private.hold_reported_feed_content()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.feed_post_id IS NOT NULL AND (SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE feed_post_id = NEW.feed_post_id AND status = 'pending') >= 3 THEN
    UPDATE public.feed_posts SET held_for_review = true WHERE id = NEW.feed_post_id;
  END IF;
  IF NEW.feed_comment_id IS NOT NULL AND (SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE feed_comment_id = NEW.feed_comment_id AND status = 'pending') >= 3 THEN
    UPDATE public.feed_comments SET held_for_review = true WHERE id = NEW.feed_comment_id;
  END IF;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.hold_reported_feed_content() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_hold_reported_feed_content AFTER INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION vibra_private.hold_reported_feed_content();

-- ── Notifications: comments and replies ───────────────────────────────────
-- Likes and reactions deliberately do not notify: no engagement bait.
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update',
  'circle_invite', 'circle_message', 'circle_plan', 'vibe_comment', 'story_reply', 'feed_comment'
));
CREATE TRIGGER feed_comments_notify AFTER INSERT ON public.feed_comments
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
    'discovery_collection', COALESCE((SELECT jsonb_agg(to_jsonb(d) ORDER BY d.saved_at) FROM public.discovery_collection d WHERE d.user_id = uid), '[]'::jsonb),
    'music_stories', COALESCE((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.created_at) FROM public.music_stories s WHERE s.user_id = uid), '[]'::jsonb),
    'music_story_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.music_story_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'music_story_replies', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.music_story_replies r WHERE r.sender_id = uid OR r.recipient_id = uid), '[]'::jsonb),
    'music_story_views', COALESCE((SELECT jsonb_agg(to_jsonb(v) ORDER BY v.viewed_at) FROM public.music_story_views v WHERE v.viewer_id = uid), '[]'::jsonb),
    'story_settings', (SELECT to_jsonb(s) FROM public.story_settings s WHERE s.user_id = uid),
    'story_hidden_viewers', COALESCE((SELECT jsonb_agg(to_jsonb(h) ORDER BY h.created_at) FROM public.story_hidden_viewers h WHERE h.owner_id = uid), '[]'::jsonb),
    'story_mutes', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at) FROM public.story_mutes m WHERE m.user_id = uid), '[]'::jsonb),
    'feed_posts', COALESCE((SELECT jsonb_agg(to_jsonb(p) ORDER BY p.created_at) FROM public.feed_posts p WHERE p.user_id = uid), '[]'::jsonb),
    'feed_comments', COALESCE((SELECT jsonb_agg(to_jsonb(c) ORDER BY c.created_at) FROM public.feed_comments c WHERE c.author_id = uid), '[]'::jsonb),
    'feed_reactions', COALESCE((SELECT jsonb_agg(to_jsonb(r) ORDER BY r.created_at) FROM public.feed_post_reactions r WHERE r.user_id = uid), '[]'::jsonb),
    'feed_bookmarks', COALESCE((SELECT jsonb_agg(to_jsonb(b) ORDER BY b.created_at) FROM public.feed_bookmarks b WHERE b.user_id = uid), '[]'::jsonb),
    'feed_impressions', COALESCE((SELECT jsonb_agg(to_jsonb(i) ORDER BY i.last_shown_at) FROM public.feed_impressions i WHERE i.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
