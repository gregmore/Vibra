-- 1. FIX RPC VULNERABILITIES IN MODERATION
CREATE OR REPLACE FUNCTION public.soft_delete_chat(p_user_id uuid, p_other_user_id uuid)
RETURNS void AS $$
BEGIN
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Vibra Security: You can only delete your own chats.';
  END IF;

  UPDATE public.messages
  SET deleted_by = array_append(deleted_by, p_user_id)
  WHERE ((sender_id = p_user_id AND receiver_id = p_other_user_id)
     OR (sender_id = p_other_user_id AND receiver_id = p_user_id))
    AND NOT (p_user_id = ANY(deleted_by));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.react_to_message(p_message_id uuid, p_user_id uuid, p_reaction text)
RETURNS void AS $$
BEGIN
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Vibra Security: You can only add reactions for yourself.';
  END IF;

  UPDATE public.messages
  SET reactions = COALESCE(reactions, '{}'::jsonb) || jsonb_build_object(p_user_id::text, p_reaction)
  WHERE id = p_message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. FIX MISSING RLS
ALTER TABLE public.user_interactions_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_interactions_select_own"
ON public.user_interactions_log FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "user_interactions_insert_own"
ON public.user_interactions_log FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

ALTER TABLE public.algorithm_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "algorithm_config_read_only"
ON public.algorithm_config FOR SELECT
TO authenticated
USING (true);
-- Update and Insert allowed only to service_role (automatically bypasses RLS)

-- 3. FIX EVENTS UPDATE VULNERABILITY
-- The old policy allowed anyone to update any event. We drop it and restrict it.
DROP POLICY IF EXISTS "events_update_authenticated" ON public.events;

-- If updates are needed by clients (e.g., upserting missing fields),
-- we use a column-level trigger instead of a full policy to prevent malicious edits
-- Or we just leave the policy dropped (only edge functions/backend can update).

-- 4. MISSING INDEXES FOR OPTIMIZATION
-- messages table
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at);

-- friendships
CREATE INDEX IF NOT EXISTS idx_friendships_requester ON public.friendships(requester_id);
CREATE INDEX IF NOT EXISTS idx_friendships_receiver ON public.friendships(receiver_id);

-- user_matches
CREATE INDEX IF NOT EXISTS idx_user_matches_users ON public.user_matches(user_id_a, user_id_b);

-- event_attendees
CREATE INDEX IF NOT EXISTS idx_event_attendees_event ON public.event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_user ON public.event_attendees(user_id);
