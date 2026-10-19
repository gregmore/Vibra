BEGIN;

-- RLS on blocked_users intentionally hides who blocked the caller. Evaluate
-- both directions as the owner, returning only a caller-scoped permission.
CREATE FUNCTION public.may_access_message(p_sender_id uuid, p_receiver_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT public.has_active_session()
    AND (auth.uid() = p_sender_id OR auth.uid() = p_receiver_id)
    AND NOT EXISTS (
      SELECT 1 FROM public.blocked_users b
      WHERE (b.blocker_id = p_sender_id AND b.blocked_id = p_receiver_id)
         OR (b.blocker_id = p_receiver_id AND b.blocked_id = p_sender_id)
    );
$$;
REVOKE ALL ON FUNCTION public.may_access_message(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.may_access_message(uuid, uuid) TO authenticated;

-- The old policy joined users under caller RLS: the receiver's private
-- location was invisible, preventing every initial nearby contact.
CREATE FUNCTION public.can_message_user(p_receiver_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
  SELECT auth.uid() IS NOT NULL AND auth.uid() <> p_receiver_id
    AND public.may_access_message(auth.uid(), p_receiver_id)
    AND EXISTS (
      SELECT 1 FROM public.users sender JOIN public.users receiver ON receiver.id = p_receiver_id
      WHERE sender.id = auth.uid() AND sender.is_test_user = receiver.is_test_user
        AND (
          EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
            AND ((f.requester_id = sender.id AND f.receiver_id = receiver.id)
              OR (f.receiver_id = sender.id AND f.requester_id = receiver.id)))
          -- An authentic received message authorizes a reply, even after the
          -- participants move. The first-contact trigger still caps strangers.
          OR EXISTS (SELECT 1 FROM public.messages m
            WHERE m.sender_id = receiver.id AND m.receiver_id = sender.id
              AND NOT (sender.id = ANY(COALESCE(m.deleted_by, '{}'::uuid[]))))
          OR (sender.last_location IS NOT NULL AND receiver.last_location IS NOT NULL
            AND public.ST_DWithin(sender.last_location, receiver.last_location, 500))
        )
    );
$$;
REVOKE ALL ON FUNCTION public.can_message_user(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.can_message_user(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.first_contact_limiter()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
    AND ((f.requester_id = NEW.sender_id AND f.receiver_id = NEW.receiver_id)
      OR (f.receiver_id = NEW.sender_id AND f.requester_id = NEW.receiver_id))) THEN
    RETURN NEW;
  END IF;
  -- Serialize concurrent first contacts so parallel requests cannot all
  -- observe the same count and bypass the stranger-message cap.
  PERFORM pg_advisory_xact_lock(hashtextextended(
    least(NEW.sender_id::text, NEW.receiver_id::text) || ':' ||
    greatest(NEW.sender_id::text, NEW.receiver_id::text), 0));
  IF NOT EXISTS (SELECT 1 FROM public.messages
    WHERE sender_id = NEW.receiver_id AND receiver_id = NEW.sender_id)
    AND (SELECT count(*) FROM public.messages
      WHERE sender_id = NEW.sender_id AND receiver_id = NEW.receiver_id) >= 3 THEN
    RAISE EXCEPTION 'Cannot send more than 3 messages before receiving a reply.';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.first_contact_limiter() FROM PUBLIC, anon, authenticated;

DROP POLICY IF EXISTS messages_select_without_blocks ON public.messages;
CREATE POLICY messages_select_without_blocks ON public.messages FOR SELECT TO authenticated
USING (public.may_access_message(sender_id, receiver_id)
  AND NOT (auth.uid() = ANY(COALESCE(deleted_by, '{}'::uuid[]))));
DROP POLICY IF EXISTS messages_insert_without_blocks ON public.messages;
CREATE POLICY messages_insert_without_blocks ON public.messages FOR INSERT TO authenticated
WITH CHECK (sender_id = auth.uid() AND public.can_message_user(receiver_id));
CREATE POLICY messages_update_requires_visible_participant ON public.messages
AS RESTRICTIVE FOR UPDATE TO authenticated
USING (public.may_access_message(sender_id, receiver_id)
  AND NOT (auth.uid() = ANY(COALESCE(deleted_by, '{}'::uuid[]))))
WITH CHECK (public.may_access_message(sender_id, receiver_id));

DROP POLICY IF EXISTS chat_media_select_participants ON storage.objects;
CREATE POLICY chat_media_select_participants ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'chat-media' AND EXISTS (
  SELECT 1 FROM public.messages m WHERE m.media_path = storage.objects.name
    AND public.may_access_message(m.sender_id, m.receiver_id)
    AND NOT (auth.uid() = ANY(COALESCE(m.deleted_by, '{}'::uuid[])))
));

CREATE POLICY live_messages_private_visibility ON public.live_messages
AS RESTRICTIVE FOR SELECT TO authenticated
USING (public.may_access_message(auth.uid(), user_id)
  AND public.user_is_in_current_test_segment(user_id));
ALTER TABLE public.live_messages ADD CONSTRAINT live_messages_content_length
CHECK (char_length(btrim(content)) BETWEEN 1 AND 2000) NOT VALID;

CREATE OR REPLACE FUNCTION public.get_user_conversations()
RETURNS TABLE (
  other_user_id uuid, other_username text, other_display_name text,
  other_avatar_url text, last_message_content text,
  last_message_created_at timestamptz, last_message_sender_id uuid,
  unread_count bigint, is_friend boolean, is_message_request boolean
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_uid uuid := auth.uid();
BEGIN
  PERFORM public.require_active_session();
  IF v_uid IS NULL THEN RAISE insufficient_privilege USING MESSAGE = 'Authentication required'; END IF;
  RETURN QUERY
  WITH visible_messages AS (
    SELECT m.*, CASE WHEN m.sender_id = v_uid THEN m.receiver_id ELSE m.sender_id END AS partner_id
    FROM public.messages m
    WHERE public.may_access_message(m.sender_id, m.receiver_id)
      AND NOT (v_uid = ANY(COALESCE(m.deleted_by, '{}'::uuid[])))
  ), last_msgs AS (
    SELECT DISTINCT ON (m.partner_id) m.* FROM visible_messages m
    ORDER BY m.partner_id, m.created_at DESC, m.id DESC
  )
  SELECT u.id, u.username::text, u.display_name, u.avatar_url,
    lm.content, lm.created_at, lm.sender_id,
    (SELECT count(*) FROM visible_messages unread
      WHERE unread.partner_id = lm.partner_id AND unread.receiver_id = v_uid AND unread.read_at IS NULL),
    friendship.are_friends,
    NOT friendship.are_friends AND NOT EXISTS (
      SELECT 1 FROM visible_messages replied WHERE replied.partner_id = lm.partner_id AND replied.sender_id = v_uid
    )
  FROM last_msgs lm
  JOIN public.profile_discovery u ON u.id = lm.partner_id
    AND u.is_test_user = public.current_user_is_test()
  CROSS JOIN LATERAL (
    SELECT EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
      AND ((f.requester_id = v_uid AND f.receiver_id = lm.partner_id)
        OR (f.receiver_id = v_uid AND f.requester_id = lm.partner_id))) AS are_friends
  ) friendship
  ORDER BY lm.created_at DESC, lm.id DESC;
END;
$$;
REVOKE ALL ON FUNCTION public.get_user_conversations() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_user_conversations() TO authenticated;

CREATE OR REPLACE FUNCTION public.soft_delete_chat(p_user_id uuid, p_other_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  IF auth.uid() IS NULL OR auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE insufficient_privilege USING MESSAGE = 'You can only delete your own chats';
  END IF;
  UPDATE public.messages SET deleted_by = array_append(COALESCE(deleted_by, '{}'::uuid[]), p_user_id)
  WHERE ((sender_id = p_user_id AND receiver_id = p_other_user_id)
      OR (sender_id = p_other_user_id AND receiver_id = p_user_id))
    AND NOT (p_user_id = ANY(COALESCE(deleted_by, '{}'::uuid[])));
END;
$$;
REVOKE ALL ON FUNCTION public.soft_delete_chat(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.soft_delete_chat(uuid, uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.react_to_message(p_message_id uuid, p_user_id uuid, p_reaction text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  IF auth.uid() IS NULL OR auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE insufficient_privilege USING MESSAGE = 'Reactions belong to the authenticated participant';
  END IF;
  IF p_reaction IS NULL OR char_length(p_reaction) NOT BETWEEN 1 AND 32 THEN
    RAISE invalid_parameter_value USING MESSAGE = 'Invalid reaction length';
  END IF;
  PERFORM public.consume_action_limit('reactions');
  UPDATE public.messages SET reactions = COALESCE(reactions, '{}'::jsonb) || jsonb_build_object(p_user_id::text, p_reaction)
  WHERE id = p_message_id AND public.may_access_message(sender_id, receiver_id)
    AND NOT (p_user_id = ANY(COALESCE(deleted_by, '{}'::uuid[])));
END;
$$;
REVOKE ALL ON FUNCTION public.react_to_message(uuid, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.react_to_message(uuid, uuid, text) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
