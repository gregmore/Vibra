-- Vibra complete backend: sensitive Spotify credentials, chat-media storage
-- and defence-in-depth RLS.  This migration is additive and preserves the
-- existing public.users / user_matches naming used by the Flutter client.

BEGIN;

CREATE TABLE IF NOT EXISTS public.spotify_connections (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  spotify_user_id text NOT NULL UNIQUE,
  access_token_ciphertext text NOT NULL,
  refresh_token_ciphertext text,
  token_expires_at timestamptz NOT NULL,
  connected_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_spotify_connections_updated_at ON public.spotify_connections;
CREATE TRIGGER trg_spotify_connections_updated_at
BEFORE UPDATE ON public.spotify_connections
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.spotify_connections ENABLE ROW LEVEL SECURITY;
-- There deliberately are no authenticated policies on this table.  Spotify
-- tokens are encrypted by Edge Functions and are never returned by PostgREST.

-- Legacy tokens were plaintext columns in public.users. They cannot be safely
-- migrated without an encryption key in SQL, so invalidate them and require a
-- one-time Spotify reconnect after this migration instead of retaining secrets
-- that a client can query through the profile endpoint.
ALTER TABLE public.users
  DROP COLUMN IF EXISTS spotify_access_token,
  DROP COLUMN IF EXISTS spotify_refresh_token;

ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS media_path text,
  ADD CONSTRAINT messages_content_or_media CHECK (
    NULLIF(btrim(COALESCE(content, '')), '') IS NOT NULL OR media_path IS NOT NULL
  );

ALTER TABLE public.blocked_users
  DROP CONSTRAINT IF EXISTS blocked_users_no_self;
ALTER TABLE public.blocked_users
  ADD CONSTRAINT blocked_users_no_self CHECK (blocker_id <> blocked_id);

DROP POLICY IF EXISTS "Users can view their own blocks" ON public.blocked_users;
CREATE POLICY "blocked_users_select_owner"
ON public.blocked_users FOR SELECT TO authenticated
USING ((SELECT auth.uid()) = blocker_id);

DROP POLICY IF EXISTS "messages_select_secure" ON public.messages;
CREATE POLICY "messages_select_without_blocks"
ON public.messages FOR SELECT TO authenticated
USING (
  ((SELECT auth.uid()) = sender_id OR (SELECT auth.uid()) = receiver_id)
  AND NOT EXISTS (
    SELECT 1 FROM public.blocked_users b
    WHERE (b.blocker_id = messages.sender_id AND b.blocked_id = messages.receiver_id)
       OR (b.blocker_id = messages.receiver_id AND b.blocked_id = messages.sender_id)
  )
);

DROP POLICY IF EXISTS "messages_insert_secure" ON public.messages;
CREATE POLICY "messages_insert_without_blocks"
ON public.messages FOR INSERT TO authenticated
WITH CHECK (
  sender_id = (SELECT auth.uid())
  AND NOT EXISTS (
    SELECT 1 FROM public.blocked_users b
    WHERE (b.blocker_id = messages.sender_id AND b.blocked_id = messages.receiver_id)
       OR (b.blocker_id = messages.receiver_id AND b.blocked_id = messages.sender_id)
  )
  AND (
    EXISTS (
      SELECT 1 FROM public.friendships f
      WHERE ((f.requester_id = (SELECT auth.uid()) AND f.receiver_id = messages.receiver_id)
          OR (f.receiver_id = (SELECT auth.uid()) AND f.requester_id = messages.receiver_id))
        AND f.status = 'accepted'
    )
    OR EXISTS (
      SELECT 1 FROM public.users u1 JOIN public.users u2 ON u2.id = messages.receiver_id
      WHERE u1.id = (SELECT auth.uid())
        AND u1.last_location IS NOT NULL AND u2.last_location IS NOT NULL
        AND ST_DWithin(u1.last_location, u2.last_location, 500)
    )
  )
);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'chat-media', 'chat-media', false, 10485760,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "chat_media_insert_sender_folder" ON storage.objects;
CREATE POLICY "chat_media_insert_sender_folder"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'chat-media'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

DROP POLICY IF EXISTS "chat_media_delete_sender_folder" ON storage.objects;
CREATE POLICY "chat_media_delete_sender_folder"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'chat-media' AND (storage.foldername(name))[1] = (SELECT auth.uid()::text));

DROP POLICY IF EXISTS "chat_media_select_participants" ON storage.objects;
CREATE POLICY "chat_media_select_participants"
ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id = 'chat-media'
  AND EXISTS (
    SELECT 1 FROM public.messages m
    WHERE m.media_path = storage.objects.name
      AND ((SELECT auth.uid()) = m.sender_id OR (SELECT auth.uid()) = m.receiver_id)
      AND NOT EXISTS (
        SELECT 1 FROM public.blocked_users b
        WHERE (b.blocker_id = m.sender_id AND b.blocked_id = m.receiver_id)
           OR (b.blocker_id = m.receiver_id AND b.blocked_id = m.sender_id)
      )
  )
);

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.user_matches;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

COMMIT;
