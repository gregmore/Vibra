BEGIN;
CREATE OR REPLACE FUNCTION public.react_to_message(p_message_id uuid,p_user_id uuid,p_reaction text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM public.require_active_session();
  IF auth.uid() IS NULL OR auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE insufficient_privilege USING MESSAGE='Reactions belong to the authenticated participant';
  END IF;
  IF p_reaction IS NULL OR char_length(p_reaction) NOT BETWEEN 1 AND 32 THEN
    RAISE invalid_parameter_value USING MESSAGE='Invalid reaction length';
  END IF;
  PERFORM public.consume_action_limit('reactions');
  UPDATE public.messages
  SET reactions=COALESCE(reactions,'{}'::jsonb)||jsonb_build_object(p_user_id::text,p_reaction)
  WHERE id=p_message_id AND (sender_id=auth.uid() OR receiver_id=auth.uid());
END;
$$;
REVOKE ALL ON FUNCTION public.react_to_message(uuid,uuid,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.react_to_message(uuid,uuid,text) TO authenticated;

NOTIFY pgrst,'reload schema';
COMMIT;
