-- VIBRA Music Stories (docs/music-stories.md): temporary music stories.
--
-- * Kinds: now_playing (a track), artist, album, playlist, concert_photo
--   and opinion (text on a VIBRA background).
-- * Music items come from Spotify (metadata re-fetched by the music-stories
--   Edge Function) or a link to another provider with a typed title. Only
--   metadata, the provider-hosted artwork URL and a link back are stored;
--   no audio or previews, ever.
-- * Concert photos are re-encoded by upload-image (metadata such as GPS is
--   stripped) into the private story-media bucket. Clients cannot write to
--   the bucket and can only read a photo while its story is visible to them.
-- * Every story expires after 24 hours: every read checks it, an hourly job
--   deletes the rows and the media-purge worker deletes the photos.
-- * Privacy: per-story visibility ('connections' default, or 'everyone'),
--   replies on/off, a "hide my stories from" list, muting someone's stories,
--   blocks and test segments. Views are visible to the author only.
-- * Reactions, private replies (author ↔ viewer), reports (3 hold a story,
--   1 hides a reply), rate limits and reply notifications.
BEGIN;

-- ── Storage ───────────────────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('story-media', 'story-media', false, 10485760, ARRAY['image/png'])
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Only the upload-image Edge Function (service role) writes story photos.
CREATE POLICY story_media_upload_requires_backend ON storage.objects
AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK (bucket_id <> 'story-media');
CREATE POLICY story_media_replace_requires_backend ON storage.objects
AS RESTRICTIVE FOR UPDATE TO authenticated USING (bucket_id <> 'story-media')
WITH CHECK (bucket_id <> 'story-media');
CREATE POLICY story_media_delete_requires_backend ON storage.objects
AS RESTRICTIVE FOR DELETE TO authenticated USING (bucket_id <> 'story-media');

CREATE OR REPLACE FUNCTION public.guard_account_storage_write()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog AS $$
DECLARE uid uuid;
BEGIN
  IF NEW.bucket_id NOT IN ('avatars','chat-media','support-attachments','story-media') THEN RETURN NEW; END IF;
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
CREATE TABLE public.music_stories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN ('now_playing', 'artist', 'album', 'playlist', 'concert_photo', 'opinion')),
  provider text CHECK (provider IN ('spotify', 'link')),
  item_id text CHECK (item_id ~ '^[A-Za-z0-9]{22}$'),
  title text CHECK (char_length(title) BETWEEN 1 AND 200),
  subtitle text CHECK (char_length(subtitle) <= 300),
  artwork_url text CHECK (artwork_url ~ '^https://(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)/'),
  external_url text CHECK (char_length(external_url) <= 300 AND external_url ~ '^https://'),
  media_path text UNIQUE CHECK (media_path ~ '^[0-9a-f-]{36}/[0-9a-f-]{36}\.png$'),
  event_id uuid REFERENCES public.events(id) ON DELETE SET NULL,
  body text CHECK (char_length(btrim(body)) BETWEEN 1 AND 300),
  background text NOT NULL DEFAULT 'aurora' CHECK (background IN ('aurora', 'sunset', 'ocean', 'ember', 'mono')),
  visibility text NOT NULL DEFAULT 'connections' CHECK (visibility IN ('connections', 'everyone')),
  allow_replies boolean NOT NULL DEFAULT true,
  expires_at timestamptz NOT NULL DEFAULT now() + interval '24 hours',
  held_for_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (expires_at <= created_at + interval '24 hours'),
  -- A music story names a provider item; a photo has a photo; an opinion has text.
  CHECK (CASE kind
    WHEN 'concert_photo' THEN media_path IS NOT NULL AND provider IS NULL
    WHEN 'opinion' THEN body IS NOT NULL AND provider IS NULL AND media_path IS NULL
    ELSE provider IS NOT NULL AND title IS NOT NULL AND external_url IS NOT NULL AND media_path IS NULL
      AND (provider <> 'spotify' OR item_id IS NOT NULL)
  END)
);
CREATE INDEX music_stories_author_idx ON public.music_stories (user_id, created_at);
CREATE INDEX music_stories_expiry_idx ON public.music_stories (expires_at);

CREATE TABLE public.music_story_views (
  story_id uuid NOT NULL REFERENCES public.music_stories(id) ON DELETE CASCADE,
  viewer_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  viewed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (story_id, viewer_id)
);
CREATE INDEX music_story_views_viewer_idx ON public.music_story_views (viewer_id);

CREATE TABLE public.music_story_reactions (
  story_id uuid NOT NULL REFERENCES public.music_stories(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reaction text NOT NULL CHECK (reaction IN ('fire', 'heart', 'headphones', 'clap', 'mind_blown')),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (story_id, user_id, reaction)
);

-- A private reply: between the story's author and one viewer.
CREATE TABLE public.music_story_replies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id uuid NOT NULL REFERENCES public.music_stories(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  recipient_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  body text NOT NULL CHECK (char_length(btrim(body)) BETWEEN 1 AND 500),
  held_for_review boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (sender_id <> recipient_id)
);
CREATE INDEX music_story_replies_idx ON public.music_story_replies (story_id, created_at);

CREATE TABLE public.story_settings (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  default_visibility text NOT NULL DEFAULT 'connections' CHECK (default_visibility IN ('connections', 'everyone')),
  allow_replies boolean NOT NULL DEFAULT true,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- The owner hides their stories from a viewer. The viewer is never told.
CREATE TABLE public.story_hidden_viewers (
  owner_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  viewer_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (owner_id, viewer_id),
  CHECK (owner_id <> viewer_id)
);

-- A viewer stops seeing someone's stories. The author is never told.
CREATE TABLE public.story_mutes (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  muted_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, muted_id),
  CHECK (user_id <> muted_id)
);

CREATE TABLE vibra_private.music_story_posts (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  posted_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX music_story_posts_idx ON vibra_private.music_story_posts (user_id, posted_at);
REVOKE ALL ON vibra_private.music_story_posts FROM PUBLIC, anon, authenticated;

-- ── Visibility ────────────────────────────────────────────────────────────
-- Same audience rules as Daily Vibe (connections and mutual musical matches,
-- or everyone; blocks and test segments), plus expiry and the hidden list.
CREATE FUNCTION public.can_see_music_story(
  p_author uuid, p_visibility text, p_expires timestamptz, p_held boolean
)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT p_author = auth.uid() OR (
    p_expires > now()
    AND public.can_see_daily_vibe(p_author, p_visibility, p_expires, p_held)
    AND NOT EXISTS (SELECT 1 FROM public.story_hidden_viewers h
      WHERE h.owner_id = p_author AND h.viewer_id = auth.uid())
  );
$$;
REVOKE ALL ON FUNCTION public.can_see_music_story(uuid, text, timestamptz, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.can_see_music_story(uuid, text, timestamptz, boolean) TO authenticated;

ALTER TABLE public.music_stories ENABLE ROW LEVEL SECURITY;
CREATE POLICY music_stories_read ON public.music_stories FOR SELECT TO authenticated
  USING (public.can_see_music_story(user_id, visibility, expires_at, held_for_review));

-- Views: only the story's author reads who viewed it (and a viewer their own).
ALTER TABLE public.music_story_views ENABLE ROW LEVEL SECURITY;
CREATE POLICY music_story_views_read ON public.music_story_views FOR SELECT TO authenticated
  USING (viewer_id = (SELECT auth.uid()) OR EXISTS (
    SELECT 1 FROM public.music_stories s WHERE s.id = story_id AND s.user_id = (SELECT auth.uid())));

ALTER TABLE public.music_story_reactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY music_story_reactions_read ON public.music_story_reactions FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.music_stories s WHERE s.id = story_id));

ALTER TABLE public.music_story_replies ENABLE ROW LEVEL SECURITY;
CREATE POLICY music_story_replies_read ON public.music_story_replies FOR SELECT TO authenticated
  USING ((sender_id = (SELECT auth.uid()))
    OR (recipient_id = (SELECT auth.uid()) AND NOT held_for_review
      AND public.may_access_message((SELECT auth.uid()), sender_id)));

ALTER TABLE public.story_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY story_settings_owner ON public.story_settings FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));
ALTER TABLE public.story_hidden_viewers ENABLE ROW LEVEL SECURITY;
CREATE POLICY story_hidden_viewers_owner ON public.story_hidden_viewers FOR SELECT TO authenticated
  USING (owner_id = (SELECT auth.uid()));
ALTER TABLE public.story_mutes ENABLE ROW LEVEL SECURITY;
CREATE POLICY story_mutes_owner ON public.story_mutes FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()));

REVOKE ALL ON public.music_stories, public.music_story_views, public.music_story_reactions,
  public.music_story_replies, public.story_settings, public.story_hidden_viewers, public.story_mutes
  FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.music_stories, public.music_story_views, public.music_story_reactions,
  public.music_story_replies, public.story_settings, public.story_hidden_viewers, public.story_mutes
  TO authenticated;
GRANT ALL ON public.music_stories, public.music_story_views, public.music_story_reactions,
  public.music_story_replies, public.story_settings, public.story_hidden_viewers, public.story_mutes
  TO service_role;

-- A photo is readable only while its story is visible to the caller
-- (the EXISTS runs under music_stories RLS).
CREATE POLICY story_media_select_visible ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'story-media' AND EXISTS (
  SELECT 1 FROM public.music_stories s WHERE s.media_path = storage.objects.name));

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

-- ── Posting (service role: called by the music-stories Edge Function) ─────
-- p_story: kind, provider, item_id, title, subtitle, artwork_url,
-- external_url, media_path, event_id, body, background, visibility,
-- allow_replies. At most 5 stories a minute and 30 a day.
CREATE FUNCTION public.create_music_story(p_user_id uuid, p_story jsonb)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_id uuid; v_media text := p_story->>'media_path'; v_event uuid; v_settings public.story_settings%ROWTYPE;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE insufficient_privilege USING MESSAGE = 'Service role required';
  END IF;
  PERFORM vibra_private.community_text_guard(p_story->>'body');
  PERFORM 1 FROM public.users WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE no_data_found USING MESSAGE = 'user_not_found'; END IF;
  IF (SELECT count(*) FROM vibra_private.music_story_posts WHERE user_id = p_user_id AND posted_at > now() - interval '1 minute') >= 5
     OR (SELECT count(*) FROM vibra_private.music_story_posts WHERE user_id = p_user_id AND posted_at > now() - interval '1 day') >= 30 THEN
    RAISE SQLSTATE 'PT429' USING MESSAGE = 'story_rate_limit';
  END IF;
  -- A photo must be the author's own upload (written by upload-image).
  IF v_media IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM storage.objects o WHERE o.bucket_id = 'story-media' AND o.name = v_media
        AND split_part(o.name, '/', 1) = p_user_id::text) THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_media';
  END IF;
  IF p_story->>'event_id' ~ '^[0-9a-f-]{36}$' THEN
    SELECT id INTO v_event FROM public.events WHERE id = (p_story->>'event_id')::uuid;
  END IF;
  SELECT * INTO v_settings FROM public.story_settings WHERE user_id = p_user_id;
  INSERT INTO vibra_private.music_story_posts (user_id) VALUES (p_user_id);
  INSERT INTO public.music_stories (user_id, kind, provider, item_id, title, subtitle, artwork_url,
    external_url, media_path, event_id, body, background, visibility, allow_replies)
  VALUES (p_user_id, p_story->>'kind', p_story->>'provider', p_story->>'item_id',
    NULLIF(btrim(p_story->>'title'), ''), NULLIF(btrim(p_story->>'subtitle'), ''),
    p_story->>'artwork_url', p_story->>'external_url', v_media, v_event,
    NULLIF(btrim(p_story->>'body'), ''), COALESCE(p_story->>'background', 'aurora'),
    COALESCE(p_story->>'visibility', v_settings.default_visibility, 'connections'),
    COALESCE((p_story->>'allow_replies')::boolean, v_settings.allow_replies, true))
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.create_music_story(uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_music_story(uuid, jsonb) TO service_role;

CREATE FUNCTION public.delete_my_music_story(p_story uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  -- The photo becomes an orphan and is deleted by the media-purge worker.
  DELETE FROM public.music_stories WHERE id = p_story AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.delete_my_music_story(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_music_story(uuid) TO authenticated;

-- A story the caller can see (RLS-equivalent check for DEFINER writes).
CREATE FUNCTION vibra_private.require_visible_story(p_story uuid)
RETURNS public.music_stories LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE s public.music_stories%ROWTYPE;
BEGIN
  SELECT * INTO s FROM public.music_stories WHERE id = p_story;
  IF NOT FOUND OR NOT public.can_see_music_story(s.user_id, s.visibility, s.expires_at, s.held_for_review) THEN
    RAISE no_data_found USING MESSAGE = 'story_not_found';
  END IF;
  RETURN s;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.require_visible_story(uuid) FROM PUBLIC, anon, authenticated;

-- ── Views, reactions, replies ─────────────────────────────────────────────
CREATE FUNCTION public.mark_music_story_viewed(p_story uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE s public.music_stories%ROWTYPE;
BEGIN
  PERFORM public.require_active_session();
  s := vibra_private.require_visible_story(p_story);
  IF s.user_id = auth.uid() THEN RETURN; END IF;
  PERFORM public.consume_action_limit('story-view');
  INSERT INTO public.music_story_views (story_id, viewer_id) VALUES (p_story, auth.uid())
  ON CONFLICT DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.mark_music_story_viewed(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_music_story_viewed(uuid) TO authenticated;

CREATE FUNCTION public.toggle_music_story_reaction(p_story uuid, p_reaction text)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM vibra_private.require_visible_story(p_story);
  PERFORM public.consume_action_limit('story-reaction');
  DELETE FROM public.music_story_reactions WHERE story_id = p_story AND user_id = auth.uid() AND reaction = p_reaction;
  IF FOUND THEN RETURN false; END IF;
  INSERT INTO public.music_story_reactions (story_id, user_id, reaction) VALUES (p_story, auth.uid(), p_reaction);
  RETURN true;
END;
$$;
REVOKE ALL ON FUNCTION public.toggle_music_story_reaction(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.toggle_music_story_reaction(uuid, text) TO authenticated;

-- A viewer replies to the author (if the story allows replies); the author
-- answers a viewer only in a thread that viewer started.
CREATE FUNCTION public.send_music_story_reply(p_story uuid, p_body text, p_recipient uuid DEFAULT NULL)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE s public.music_stories%ROWTYPE; v_to uuid; v_id uuid;
BEGIN
  PERFORM public.require_active_session();
  s := vibra_private.require_visible_story(p_story);
  PERFORM public.consume_action_limit('story-reply');
  PERFORM vibra_private.community_text_guard(p_body);
  IF s.user_id = auth.uid() THEN
    IF p_recipient IS NULL OR NOT EXISTS (SELECT 1 FROM public.music_story_replies r
        WHERE r.story_id = p_story AND r.sender_id = p_recipient AND r.recipient_id = auth.uid())
       OR NOT public.may_access_message(auth.uid(), p_recipient) THEN
      RAISE invalid_parameter_value USING MESSAGE = 'invalid_recipient';
    END IF;
    v_to := p_recipient;
  ELSE
    IF NOT s.allow_replies THEN RAISE insufficient_privilege USING MESSAGE = 'replies_off'; END IF;
    v_to := s.user_id;
  END IF;
  IF (SELECT count(*) FROM public.music_story_replies WHERE sender_id = auth.uid() AND created_at > now() - interval '1 day') >= 200 THEN
    RAISE check_violation USING MESSAGE = 'story_reply_daily_limit';
  END IF;
  INSERT INTO public.music_story_replies (story_id, sender_id, recipient_id, body)
  VALUES (p_story, auth.uid(), v_to, btrim(p_body)) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;
REVOKE ALL ON FUNCTION public.send_music_story_reply(uuid, text, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.send_music_story_reply(uuid, text, uuid) TO authenticated;

-- ── Privacy settings ──────────────────────────────────────────────────────
CREATE FUNCTION public.set_story_settings(p_default_visibility text, p_allow_replies boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('story-settings');
  INSERT INTO public.story_settings (user_id, default_visibility, allow_replies)
  VALUES (auth.uid(), COALESCE(p_default_visibility, 'connections'), COALESCE(p_allow_replies, true))
  ON CONFLICT (user_id) DO UPDATE SET default_visibility = EXCLUDED.default_visibility,
    allow_replies = EXCLUDED.allow_replies, updated_at = now();
END;
$$;
REVOKE ALL ON FUNCTION public.set_story_settings(text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_story_settings(text, boolean) TO authenticated;

-- Changes visibility or replies of one of my live stories.
CREATE FUNCTION public.update_my_music_story(p_story uuid, p_visibility text, p_allow_replies boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('story-settings');
  UPDATE public.music_stories SET visibility = COALESCE(p_visibility, visibility),
    allow_replies = COALESCE(p_allow_replies, allow_replies)
  WHERE id = p_story AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.update_my_music_story(uuid, text, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.update_my_music_story(uuid, text, boolean) TO authenticated;

CREATE FUNCTION public.set_story_hidden_from(p_viewer uuid, p_hidden boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('story-settings');
  IF p_viewer IS NULL OR p_viewer = auth.uid() THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_user';
  END IF;
  IF p_hidden THEN
    IF (SELECT count(*) FROM public.story_hidden_viewers WHERE owner_id = auth.uid()) >= 1000 THEN
      RAISE check_violation USING MESSAGE = 'hidden_limit';
    END IF;
    INSERT INTO public.story_hidden_viewers (owner_id, viewer_id) VALUES (auth.uid(), p_viewer)
    ON CONFLICT DO NOTHING;
  ELSE
    DELETE FROM public.story_hidden_viewers WHERE owner_id = auth.uid() AND viewer_id = p_viewer;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_story_hidden_from(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_story_hidden_from(uuid, boolean) TO authenticated;

CREATE FUNCTION public.set_story_muted(p_user uuid, p_muted boolean)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  PERFORM public.consume_action_limit('story-settings');
  IF p_user IS NULL OR p_user = auth.uid() THEN
    RAISE invalid_parameter_value USING MESSAGE = 'invalid_user';
  END IF;
  IF p_muted THEN
    INSERT INTO public.story_mutes (user_id, muted_id) VALUES (auth.uid(), p_user) ON CONFLICT DO NOTHING;
  ELSE
    DELETE FROM public.story_mutes WHERE user_id = auth.uid() AND muted_id = p_user;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.set_story_muted(uuid, boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.set_story_muted(uuid, boolean) TO authenticated;

-- People I have hidden my stories from (profile_discovery fields only).
CREATE FUNCTION public.get_story_hidden_viewers()
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT h.viewer_id, d.username::text, d.display_name, d.avatar_url
  FROM public.story_hidden_viewers h
  LEFT JOIN public.profile_discovery d ON d.id = h.viewer_id
  WHERE h.owner_id = auth.uid()
  ORDER BY h.created_at DESC;
$$;
REVOKE ALL ON FUNCTION public.get_story_hidden_viewers() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_story_hidden_viewers() TO authenticated;

-- Candidates for the hidden list: my accepted connections.
CREATE FUNCTION public.get_story_audience_candidates()
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text, hidden boolean)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT d.id, d.username::text, d.display_name, d.avatar_url,
    EXISTS (SELECT 1 FROM public.story_hidden_viewers h WHERE h.owner_id = auth.uid() AND h.viewer_id = d.id)
  FROM public.friendships f
  JOIN public.profile_discovery d ON d.id = CASE WHEN f.requester_id = auth.uid() THEN f.receiver_id ELSE f.requester_id END
  WHERE f.status = 'accepted' AND (f.requester_id = auth.uid() OR f.receiver_id = auth.uid())
    AND public.may_access_message(auth.uid(), d.id)
  ORDER BY d.display_name NULLS LAST, d.username
  LIMIT 500;
$$;
REVOKE ALL ON FUNCTION public.get_story_audience_candidates() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_story_audience_candidates() TO authenticated;

-- ── Reads ─────────────────────────────────────────────────────────────────
-- The story ring: me first, then connections, matches and people I follow
-- with a live story I can see, unseen first. Muted authors are left out.
CREATE FUNCTION public.get_story_ring()
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text,
  story_count bigint, latest_at timestamptz, all_seen boolean)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT s.user_id, d.username::text, d.display_name, d.avatar_url,
    count(*), max(s.created_at),
    bool_and(s.user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.music_story_views v
      WHERE v.story_id = s.id AND v.viewer_id = auth.uid()))
  FROM public.music_stories s
  JOIN public.profile_discovery d ON d.id = s.user_id
  WHERE s.expires_at > now()
    AND NOT EXISTS (SELECT 1 FROM public.story_mutes m WHERE m.user_id = auth.uid() AND m.muted_id = s.user_id)
    AND (s.user_id = auth.uid()
      OR EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
        AND ((f.requester_id = auth.uid() AND f.receiver_id = s.user_id) OR (f.requester_id = s.user_id AND f.receiver_id = auth.uid())))
      OR EXISTS (SELECT 1 FROM public.user_matches m
        WHERE m.user_id_a = LEAST(auth.uid(), s.user_id) AND m.user_id_b = GREATEST(auth.uid(), s.user_id))
      OR EXISTS (SELECT 1 FROM public.follows fo WHERE fo.follower_id = auth.uid() AND fo.following_id = s.user_id))
  GROUP BY s.user_id, d.username, d.display_name, d.avatar_url
  ORDER BY (s.user_id = auth.uid()) DESC, 7 ASC, max(s.created_at) DESC
  LIMIT 100;
$$;
REVOKE ALL ON FUNCTION public.get_story_ring() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_story_ring() TO authenticated;

-- One person's live stories I can see, oldest first. View and reply
-- counts are returned to the author only.
CREATE FUNCTION public.get_user_music_stories(p_user uuid)
RETURNS TABLE (
  id uuid, user_id uuid, username text, display_name text, avatar_url text,
  kind text, provider text, item_id text, title text, subtitle text, artwork_url text,
  external_url text, media_path text, event_id uuid, event_name text, body text, background text,
  visibility text, allow_replies boolean, expires_at timestamptz, created_at timestamptz,
  reactions jsonb, my_reactions text[], seen boolean, view_count bigint, reply_count bigint,
  held_for_review boolean
)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT s.id, s.user_id, d.username::text, d.display_name, d.avatar_url,
    s.kind, s.provider, s.item_id, s.title, s.subtitle, s.artwork_url,
    s.external_url, s.media_path, s.event_id, e.name, s.body, s.background,
    s.visibility, s.allow_replies, s.expires_at, s.created_at,
    COALESCE((SELECT jsonb_object_agg(x.reaction, x.n) FROM (
      SELECT r.reaction, count(*) AS n FROM public.music_story_reactions r WHERE r.story_id = s.id GROUP BY r.reaction) x), '{}'::jsonb),
    ARRAY(SELECT r.reaction FROM public.music_story_reactions r WHERE r.story_id = s.id AND r.user_id = auth.uid()),
    s.user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.music_story_views v WHERE v.story_id = s.id AND v.viewer_id = auth.uid()),
    CASE WHEN s.user_id = auth.uid() THEN (SELECT count(*) FROM public.music_story_views v WHERE v.story_id = s.id) END,
    CASE WHEN s.user_id = auth.uid() THEN (SELECT count(*) FROM public.music_story_replies r WHERE r.story_id = s.id AND r.recipient_id = auth.uid()) END,
    s.held_for_review
  FROM public.music_stories s
  JOIN public.profile_discovery d ON d.id = s.user_id
  LEFT JOIN public.events e ON e.id = s.event_id
  WHERE s.user_id = p_user AND s.expires_at > now()
  ORDER BY s.created_at
  LIMIT 50;
$$;
REVOKE ALL ON FUNCTION public.get_user_music_stories(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_user_music_stories(uuid) TO authenticated;

-- Who viewed my story (author only; blocked people are left out).
CREATE FUNCTION public.get_music_story_viewers(p_story uuid)
RETURNS TABLE (user_id uuid, username text, display_name text, avatar_url text, viewed_at timestamptz, reactions text[])
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT v.viewer_id, d.username::text, d.display_name, d.avatar_url, v.viewed_at,
    ARRAY(SELECT r.reaction FROM public.music_story_reactions r WHERE r.story_id = v.story_id AND r.user_id = v.viewer_id)
  FROM public.music_story_views v
  JOIN public.music_stories s ON s.id = v.story_id AND s.user_id = auth.uid()
  LEFT JOIN public.profile_discovery d ON d.id = v.viewer_id
  WHERE v.story_id = p_story AND public.may_access_message(auth.uid(), v.viewer_id)
  ORDER BY v.viewed_at DESC
  LIMIT 500;
$$;
REVOKE ALL ON FUNCTION public.get_music_story_viewers(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_music_story_viewers(uuid) TO authenticated;

-- Replies I can read on a story: all threads for the author, my own thread
-- for a viewer. RLS on music_story_replies decides.
CREATE FUNCTION public.get_music_story_replies(p_story uuid)
RETURNS TABLE (id uuid, sender_id uuid, recipient_id uuid, username text, display_name text,
  avatar_url text, body text, created_at timestamptz)
LANGUAGE sql STABLE SECURITY INVOKER SET search_path = pg_catalog AS $$
  SELECT r.id, r.sender_id, r.recipient_id, d.username::text, d.display_name, d.avatar_url, r.body, r.created_at
  FROM public.music_story_replies r
  LEFT JOIN public.profile_discovery d ON d.id = r.sender_id
  WHERE r.story_id = p_story
  ORDER BY r.created_at
  LIMIT 500;
$$;
REVOKE ALL ON FUNCTION public.get_music_story_replies(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_music_story_replies(uuid) TO authenticated;

-- ── Expiry ────────────────────────────────────────────────────────────────
CREATE FUNCTION vibra_private.purge_expired_music_stories()
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $$
  DELETE FROM public.music_stories WHERE expires_at < now();
  DELETE FROM vibra_private.music_story_posts WHERE posted_at < now() - interval '2 days';
$$;
REVOKE ALL ON FUNCTION vibra_private.purge_expired_music_stories() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('purge-expired-music-stories', '3 * * * *', 'SELECT vibra_private.purge_expired_music_stories();');

-- Photos no live story uses (expired, deleted or never posted after an hour).
-- The media-purge worker deletes them through Storage's API.
CREATE FUNCTION public.list_orphan_story_media(p_limit integer DEFAULT 200)
RETURNS TABLE (name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT o.name FROM storage.objects o
  WHERE o.bucket_id = 'story-media' AND o.created_at < now() - interval '1 hour'
    AND NOT EXISTS (SELECT 1 FROM public.music_stories s WHERE s.media_path = o.name)
  ORDER BY o.created_at
  LIMIT LEAST(GREATEST(COALESCE(p_limit, 200), 1), 1000);
$$;
REVOKE ALL ON FUNCTION public.list_orphan_story_media(integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.list_orphan_story_media(integer) TO service_role;

CREATE FUNCTION vibra_private.enqueue_media_purge()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE endpoint text; credential text;
BEGIN
  SELECT decrypted_secret INTO endpoint FROM vault.decrypted_secrets WHERE name='vibra_functions_url';
  SELECT decrypted_secret INTO credential FROM vault.decrypted_secrets WHERE name='vibra_catalogue_job_secret';
  IF NULLIF(btrim(endpoint), '') IS NULL OR NULLIF(btrim(credential), '') IS NULL THEN RETURN; END IF;
  PERFORM net.http_post(url:=rtrim(endpoint,'/')||'/media-purge',
    headers:=jsonb_build_object('Content-Type','application/json','x-vibra-job-secret',credential),
    body:='{}'::jsonb, timeout_milliseconds:=60000);
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.enqueue_media_purge() FROM PUBLIC, anon, authenticated;
SELECT cron.schedule('invoke-media-purge', '13 * * * *', 'SELECT vibra_private.enqueue_media_purge();');

-- ── Reports ───────────────────────────────────────────────────────────────
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS music_story_id uuid REFERENCES public.music_stories(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS music_story_reply_id uuid REFERENCES public.music_story_replies(id) ON DELETE CASCADE;

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

CREATE FUNCTION vibra_private.hold_reported_music_story()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF NEW.music_story_id IS NOT NULL AND (SELECT count(DISTINCT reporter_id) FROM public.reports
      WHERE music_story_id = NEW.music_story_id AND status = 'pending') >= 3 THEN
    UPDATE public.music_stories SET held_for_review = true WHERE id = NEW.music_story_id;
  END IF;
  -- Only the recipient can see a reply, so one report hides it.
  IF NEW.music_story_reply_id IS NOT NULL THEN
    UPDATE public.music_story_replies SET held_for_review = true WHERE id = NEW.music_story_reply_id;
  END IF;
  RETURN NULL;
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.hold_reported_music_story() FROM PUBLIC, anon, authenticated;
CREATE TRIGGER trg_hold_reported_music_story AFTER INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION vibra_private.hold_reported_music_story();

-- ── Notifications: replies ────────────────────────────────────────────────
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update',
  'circle_invite', 'circle_message', 'circle_plan', 'vibe_comment', 'story_reply'
));
CREATE TRIGGER music_story_replies_notify AFTER INSERT ON public.music_story_replies
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
    'story_mutes', COALESCE((SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at) FROM public.story_mutes m WHERE m.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
