BEGIN;

-- Account deletion must go through the authenticated backend, not a profile
-- DELETE that leaves Auth, sessions and orphaned Storage objects behind.
REVOKE DELETE ON public.users FROM anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.prepare_my_account_erasure() FROM PUBLIC,anon,authenticated;

CREATE FUNCTION public.erase_profile_dependencies()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog AS $$
DECLARE previous_erasure text:=current_setting('app.vibra_gdpr_erasure',true);
BEGIN
  -- Runs inside the Auth hard-delete transaction, after the profile row is
  -- locked. An error rolls back the Auth deletion and every dependent change.
  PERFORM set_config('app.vibra_gdpr_erasure','true',true);
  UPDATE public.messages m SET
    content=CASE WHEN m.sender_id=OLD.id THEN 'Messaggio rimosso dall''utente' ELSE m.content END,
    media_path=CASE WHEN m.sender_id=OLD.id THEN NULL ELSE m.media_path END,
    metadata=CASE WHEN m.sender_id=OLD.id THEN NULL ELSE m.metadata END,
    reactions=CASE WHEN m.sender_id=OLD.id THEN NULL ELSE m.reactions-OLD.id::text END,
    deleted_by=array_remove(m.deleted_by,OLD.id),
    sender_id=CASE WHEN m.sender_id=OLD.id THEN NULL ELSE m.sender_id END,
    receiver_id=CASE WHEN m.receiver_id=OLD.id THEN NULL ELSE m.receiver_id END
  WHERE m.sender_id=OLD.id OR m.receiver_id=OLD.id
    OR OLD.id=ANY(m.deleted_by) OR m.reactions ? OLD.id::text;
  DELETE FROM public.notifications WHERE data::text LIKE '%'||OLD.id::text||'%';
  PERFORM set_config('app.vibra_gdpr_erasure',COALESCE(previous_erasure,''),true);
  RETURN OLD;
END;
$$;
REVOKE ALL ON FUNCTION public.erase_profile_dependencies() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER trg_erase_profile_dependencies BEFORE DELETE ON public.users
FOR EACH ROW EXECUTE FUNCTION public.erase_profile_dependencies();

-- Includes orphaned uploads and support screenshots, not just paths still
-- referenced by a message. Each batch is removed via Storage's API.
CREATE FUNCTION public.list_account_storage_objects(p_user_id uuid)
RETURNS TABLE(bucket_id text,name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog AS $$
  SELECT o.bucket_id,o.name FROM storage.objects o
  WHERE split_part(o.name,'/',1)=p_user_id::text OR o.owner_id=p_user_id::text
  ORDER BY o.bucket_id,o.name LIMIT 200;
$$;
REVOKE ALL ON FUNCTION public.list_account_storage_objects(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.list_account_storage_objects(uuid) TO service_role;
NOTIFY pgrst,'reload schema';
COMMIT;
