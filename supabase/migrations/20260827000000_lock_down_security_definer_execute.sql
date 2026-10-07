-- SECURITY DEFINER routines keep their prior explicit grants when they are
-- replaced. Revoke the legacy client grants first, then expose only the RPCs
-- that the mobile app intentionally calls.

DO $$
DECLARE
  routine record;
BEGIN
  FOR routine IN
    SELECT p.oid::regprocedure AS identity
    FROM pg_proc AS p
    JOIN pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prosecdef
  LOOP
    EXECUTE format(
      'REVOKE EXECUTE ON FUNCTION %s FROM anon, authenticated',
      routine.identity
    );
  END LOOP;
END;
$$;

-- Public app RPCs: callers must have an authenticated Supabase session.
GRANT EXECUTE ON FUNCTION public.get_nearby_events_with_distance(double precision, double precision, double precision) TO authenticated;
GRANT EXECUTE ON FUNCTION public.soft_delete_chat(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.react_to_message(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_follow_stats(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_followers(uuid, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_following(uuid, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_conversations() TO authenticated;
