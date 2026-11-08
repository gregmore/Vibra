BEGIN;

-- This is a caller-scoped explanation of the existing RLS/first-contact rules.
-- It deliberately never reveals who blocked whom or a participant's location.
CREATE FUNCTION public.message_send_permission(p_receiver_id uuid)
RETURNS text LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_uid uuid := auth.uid(); v_friends boolean;
BEGIN
  PERFORM public.require_active_session();
  IF p_receiver_id IS NULL OR p_receiver_id = v_uid
    OR NOT public.may_access_message(v_uid, p_receiver_id)
    OR NOT EXISTS (SELECT 1 FROM public.users sender
      JOIN public.users receiver ON receiver.id = p_receiver_id
      WHERE sender.id = v_uid AND sender.is_test_user = receiver.is_test_user)
  THEN RETURN 'unavailable'; END IF;

  SELECT EXISTS (SELECT 1 FROM public.friendships f WHERE f.status = 'accepted'
    AND ((f.requester_id = v_uid AND f.receiver_id = p_receiver_id)
      OR (f.receiver_id = v_uid AND f.requester_id = p_receiver_id))) INTO v_friends;
  IF NOT public.can_message_user(p_receiver_id) THEN
    RETURN 'friendship_required';
  END IF;
  IF NOT v_friends
    AND NOT EXISTS (SELECT 1 FROM public.messages
      WHERE sender_id = p_receiver_id AND receiver_id = v_uid)
    AND (SELECT count(*) FROM public.messages
      WHERE sender_id = v_uid AND receiver_id = p_receiver_id) >= 3
  THEN RETURN 'awaiting_reply'; END IF;
  IF EXISTS (SELECT 1 FROM vibra_private.action_limits l
    WHERE l.user_id = v_uid AND l.action = 'messages' AND l.count >= 30
      AND l.window_start > clock_timestamp() - interval '1 minute')
  THEN RETURN 'rate_limited'; END IF;
  RETURN CASE WHEN v_friends THEN 'allowed_friend' ELSE 'allowed' END;
END;
$$;
REVOKE ALL ON FUNCTION public.message_send_permission(uuid) FROM PUBLIC, anon, service_role;
GRANT EXECUTE ON FUNCTION public.message_send_permission(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
