BEGIN;
CREATE TABLE vibra_private.password_attempts (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  failures integer NOT NULL DEFAULT 0,
  window_start timestamptz NOT NULL DEFAULT now()
);
REVOKE ALL ON vibra_private.password_attempts FROM PUBLIC, anon, authenticated;
CREATE FUNCTION public.hook_password_verification_attempt(event jsonb)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE attempts vibra_private.password_attempts; uid uuid := (event->>'user_id')::uuid;
BEGIN
  INSERT INTO vibra_private.password_attempts(user_id) VALUES(uid) ON CONFLICT DO NOTHING;
  SELECT * INTO attempts FROM vibra_private.password_attempts WHERE user_id=uid FOR UPDATE;
  IF attempts.window_start <= clock_timestamp()-interval '15 minutes' THEN
    UPDATE vibra_private.password_attempts SET failures=0,window_start=clock_timestamp() WHERE user_id=uid;
    attempts.failures := 0;
  END IF;
  IF attempts.failures >= 5 THEN
    RETURN jsonb_build_object('error',jsonb_build_object('http_code',429,'message','Too many attempts. Try again later.'));
  END IF;
  IF (event->>'valid')::boolean THEN
    UPDATE vibra_private.password_attempts SET failures=0,window_start=clock_timestamp() WHERE user_id=uid;
  ELSE
    UPDATE vibra_private.password_attempts SET failures=failures+1 WHERE user_id=uid;
  END IF;
  RETURN '{"decision":"continue"}'::jsonb;
END;
$$;
REVOKE ALL ON FUNCTION public.hook_password_verification_attempt(jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.hook_password_verification_attempt(jsonb) TO supabase_auth_admin;
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;
COMMIT;
