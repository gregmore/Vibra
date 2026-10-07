-- GDPR technical controls: portable access, granular choices, retention and
-- account erasure.  The policy for direct messages is pseudonymous retention:
-- a deleted sender's message body/media are erased, while a neutral marker is
-- kept for the remaining participant so a conversation does not silently break.

BEGIN;

CREATE TABLE IF NOT EXISTS public.privacy_preferences (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  location_processing boolean NOT NULL DEFAULT false,
  spotify_matching boolean NOT NULL DEFAULT false,
  product_notifications boolean NOT NULL DEFAULT false,
  marketing_notifications boolean NOT NULL DEFAULT false,
  policy_version text NOT NULL DEFAULT '2026-08-27',
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.privacy_preferences ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "privacy_preferences_owner" ON public.privacy_preferences;
CREATE POLICY "privacy_preferences_owner" ON public.privacy_preferences
  FOR ALL TO authenticated USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- Location is an optional feature.  Its freshness is recorded separately so
-- retention does not infer activity from an unrelated profile update.
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS location_updated_at timestamptz;
CREATE OR REPLACE FUNCTION public.update_user_location(lon double precision, lat double precision)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  UPDATE public.users
  SET last_location = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography,
      last_latitude = lat, last_longitude = lon, location_updated_at = now()
  WHERE id = auth.uid();
END;
$$;

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
    'ticket_clicks', COALESCE((SELECT jsonb_agg(to_jsonb(t) ORDER BY t.clicked_at) FROM public.ticket_clicks t WHERE t.user_id = uid), '[]'::jsonb)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.export_my_personal_data() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_my_personal_data() TO authenticated;

-- Preserve the other participant's conversation without retaining the erased
-- user's content or identity. Existing FK constraints are replaced explicitly.
ALTER TABLE public.messages DROP CONSTRAINT IF EXISTS messages_sender_id_fkey;
ALTER TABLE public.messages DROP CONSTRAINT IF EXISTS messages_receiver_id_fkey;
ALTER TABLE public.messages ALTER COLUMN sender_id DROP NOT NULL;
ALTER TABLE public.messages ALTER COLUMN receiver_id DROP NOT NULL;
ALTER TABLE public.messages ADD CONSTRAINT messages_sender_id_fkey
  FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE SET NULL;
ALTER TABLE public.messages ADD CONSTRAINT messages_receiver_id_fkey
  FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION public.prepare_my_account_erasure()
RETURNS TABLE(media_path text)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  PERFORM set_config('app.vibra_gdpr_erasure', 'true', true);
  RETURN QUERY
    WITH erased AS (
      SELECT id, media_path FROM public.messages WHERE sender_id = uid FOR UPDATE
    )
    UPDATE public.messages m
    SET content = 'Messaggio rimosso dall''utente', media_path = NULL, sender_id = NULL,
        metadata = NULL, reactions = NULL
    FROM erased
    WHERE m.id = erased.id
    RETURNING erased.media_path;
END;
$$;
REVOKE ALL ON FUNCTION public.prepare_my_account_erasure() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.prepare_my_account_erasure() TO authenticated;

-- Called daily by a trusted scheduler (service_role only). Retention periods:
-- precise location 30 days; live chat 30 days; recommendation and ticket logs
-- 12 months; inactive direct-message content 24 months.
CREATE OR REPLACE FUNCTION public.apply_data_retention()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  PERFORM set_config('app.vibra_gdpr_erasure', 'true', true);
  UPDATE public.users SET last_location = NULL, last_latitude = NULL, last_longitude = NULL
  WHERE location_updated_at < now() - interval '30 days';
  DELETE FROM public.live_messages WHERE created_at < now() - interval '30 days';
  DELETE FROM public.user_interactions_log WHERE created_at < now() - interval '12 months';
  DELETE FROM public.ticket_clicks WHERE clicked_at < now() - interval '12 months';
  UPDATE public.messages
  SET content = 'Messaggio scaduto secondo la policy di conservazione', media_path = NULL, metadata = NULL
  WHERE created_at < now() - interval '24 months';
END;
$$;
REVOKE ALL ON FUNCTION public.apply_data_retention() FROM PUBLIC, anon, authenticated;

-- The immutable-message guard remains in force for all ordinary client
-- updates. It permits only the two server-side erasure routines above.
CREATE OR REPLACE FUNCTION public.prevent_immutable_columns_update()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  IF TG_TABLE_NAME = 'messages' AND current_setting('app.vibra_gdpr_erasure', true) = 'true' THEN
    RETURN NEW;
  END IF;
  IF TG_TABLE_NAME = 'messages' THEN
    IF NEW.sender_id IS DISTINCT FROM OLD.sender_id OR NEW.receiver_id IS DISTINCT FROM OLD.receiver_id OR NEW.content IS DISTINCT FROM OLD.content THEN
      RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (sender, receiver, content) in messages.';
    END IF;
  ELSIF TG_TABLE_NAME = 'friendships' THEN
    IF NEW.requester_id IS DISTINCT FROM OLD.requester_id OR NEW.receiver_id IS DISTINCT FROM OLD.receiver_id THEN RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (requester, receiver) in friendships.'; END IF;
  ELSIF TG_TABLE_NAME = 'event_attendees' THEN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR NEW.user_id IS DISTINCT FROM OLD.user_id THEN RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (event, user) in event_attendees.'; END IF;
  ELSIF TG_TABLE_NAME = 'notifications' THEN
    IF NEW.user_id IS DISTINCT FROM OLD.user_id OR NEW.title IS DISTINCT FROM OLD.title OR NEW.body IS DISTINCT FROM OLD.body OR NEW.type IS DISTINCT FROM OLD.type OR NEW.data IS DISTINCT FROM OLD.data THEN RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns in notifications. Only "read" status can be updated.'; END IF;
  ELSIF TG_TABLE_NAME = 'user_matches' THEN
    IF NEW.user_id_a IS DISTINCT FROM OLD.user_id_a OR NEW.user_id_b IS DISTINCT FROM OLD.user_id_b THEN RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (user_a, user_b) in user_matches.'; END IF;
  END IF;
  RETURN NEW;
END;
$$;

COMMIT;
