BEGIN;
-- Keep extension-owned objects out of the client API even on managed projects
-- where postgres cannot change the extension owner's table grants.
CREATE FUNCTION public.check_api_request()
RETURNS void LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path=pg_catalog AS $$
DECLARE path text:=current_setting('request.path',true); obj text;
BEGIN
  PERFORM public.require_active_session();
  IF auth.role() NOT IN ('anon','authenticated') THEN RETURN; END IF;
  IF path='/' THEN RETURN; END IF;
  IF path LIKE '/rpc/%' THEN
    obj:=substring(path from 6);
    IF NOT EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
      WHERE n.nspname='public' AND p.proname=obj AND NOT EXISTS
      (SELECT 1 FROM pg_depend d WHERE d.classid='pg_proc'::regclass AND d.objid=p.oid AND d.deptype='e')) THEN
      RAISE SQLSTATE 'PT403' USING MESSAGE='Endpoint is not part of the application API';
    END IF;
  ELSE
    obj:=substring(path from 2);
    IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE n.nspname='public' AND c.relname=obj AND c.relkind IN ('r','v','m','p')
      AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.classid='pg_class'::regclass AND d.objid=c.oid AND d.deptype='e')) THEN
      RAISE SQLSTATE 'PT403' USING MESSAGE='Endpoint is not part of the application API';
    END IF;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.check_api_request() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_api_request() TO anon,authenticated,service_role;
ALTER ROLE authenticator SET pgrst.db_pre_request='public.check_api_request';

CREATE TABLE vibra_private.account_erasures (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now()
);
REVOKE ALL ON vibra_private.account_erasures FROM PUBLIC,anon,authenticated;

CREATE FUNCTION public.begin_account_erasure(p_user_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog AS $$
BEGIN
  PERFORM pg_advisory_xact_lock(hashtextextended(p_user_id::text,4721));
  INSERT INTO vibra_private.account_erasures(user_id) VALUES(p_user_id) ON CONFLICT DO NOTHING;
END;
$$;
REVOKE ALL ON FUNCTION public.begin_account_erasure(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.begin_account_erasure(uuid) TO service_role;

-- Serialize each object registration against the erasure marker. An upload
-- begun earlier cannot insert a new object after erasure has started.
CREATE FUNCTION public.guard_account_storage_write()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog AS $$
DECLARE uid uuid;
BEGIN
  IF NEW.bucket_id NOT IN ('avatars','chat-media','support-attachments') THEN RETURN NEW; END IF;
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
CREATE TRIGGER vibra_account_storage_write BEFORE INSERT OR UPDATE OF name,bucket_id
ON storage.objects FOR EACH ROW EXECUTE FUNCTION public.guard_account_storage_write();

CREATE FUNCTION public.erase_account_diagnostics()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog AS $$
BEGIN
  DELETE FROM public.auth_errors_log WHERE user_id=OLD.id;
  RETURN OLD;
END;
$$;
REVOKE ALL ON FUNCTION public.erase_account_diagnostics() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER vibra_erase_diagnostics BEFORE DELETE ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.erase_account_diagnostics();
NOTIFY pgrst,'reload config';
NOTIFY pgrst,'reload schema';
COMMIT;
