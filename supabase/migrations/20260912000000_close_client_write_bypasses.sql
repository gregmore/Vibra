BEGIN;

-- New Supabase projects can grant EXECUTE explicitly through default ACLs.
-- Revoking PUBLIC alone does not remove those grants.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
DO $$ DECLARE f record; BEGIN
  FOR f IN SELECT p.oid::regprocedure AS signature, p.proname
    FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.prosecdef
      AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.objid=p.oid AND d.deptype='e')
  LOOP
    IF f.proname NOT IN ('require_active_session','current_user_is_test') THEN
      EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC, anon',f.signature);
    END IF;
  END LOOP;
END $$;
ALTER FUNCTION public.notify_live_message() SET search_path = pg_catalog;
ALTER FUNCTION public.notify_social_action() SET search_path = pg_catalog;

CREATE FUNCTION public.protect_message_client_state()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog AS $$
BEGIN
  IF current_user IN ('authenticated','anon') THEN
    IF TG_OP='INSERT' THEN
      IF COALESCE(NEW.reactions,'{}'::jsonb) <> '{}'::jsonb
         OR cardinality(COALESCE(NEW.deleted_by,'{}'::uuid[])) <> 0
         OR NEW.read_at IS NOT NULL THEN
        RAISE insufficient_privilege USING MESSAGE='Message state must start empty';
      END IF;
    ELSE
      IF NEW.reactions IS DISTINCT FROM OLD.reactions OR NEW.deleted_by IS DISTINCT FROM OLD.deleted_by THEN
        RAISE insufficient_privilege USING MESSAGE='Use the participant-scoped message actions';
      END IF;
      IF NEW.read_at IS DISTINCT FROM OLD.read_at AND auth.uid() IS DISTINCT FROM OLD.receiver_id THEN
        RAISE insufficient_privilege USING MESSAGE='Only the recipient may change read status';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_message_client_state() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER trg_message_client_state BEFORE INSERT OR UPDATE ON public.messages
FOR EACH ROW EXECUTE FUNCTION public.protect_message_client_state();

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
  UPDATE public.messages
  SET reactions=COALESCE(reactions,'{}'::jsonb)||jsonb_build_object(p_user_id::text,p_reaction)
  WHERE id=p_message_id AND (sender_id=auth.uid() OR receiver_id=auth.uid());
END;
$$;
REVOKE ALL ON FUNCTION public.react_to_message(uuid,uuid,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.react_to_message(uuid,uuid,text) TO authenticated;

CREATE FUNCTION public.protect_report_submission()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog AS $$
BEGIN
  IF current_user IN ('authenticated','anon') THEN
    IF TG_TABLE_NAME='reports' THEN
      IF NEW.status <> 'pending' THEN
        RAISE insufficient_privilege USING MESSAGE='Moderation status is backend-managed';
      END IF;
      IF NEW.message_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.messages m WHERE m.id=NEW.message_id
          AND m.sender_id=NEW.reported_id AND m.receiver_id=auth.uid()
      ) THEN
        RAISE insufficient_privilege USING MESSAGE='Only received messages may be reported';
      END IF;
    ELSE
      IF NEW.status <> 'open' OR NEW.responded_at IS NOT NULL THEN
        RAISE insufficient_privilege USING MESSAGE='Support status is backend-managed';
      END IF;
      IF NEW.screenshot_path IS NOT NULL AND
         (split_part(NEW.screenshot_path,'/',1) IS DISTINCT FROM auth.uid()::text OR NEW.screenshot_path LIKE '%..%') THEN
        RAISE insufficient_privilege USING MESSAGE='Support attachment must belong to the sender';
      END IF;
    END IF;
    NEW.created_at=now();
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_report_submission() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER trg_report_submission BEFORE INSERT ON public.reports
FOR EACH ROW EXECUTE FUNCTION public.protect_report_submission();
CREATE TRIGGER trg_support_submission BEFORE INSERT ON public.support_reports
FOR EACH ROW EXECUTE FUNCTION public.protect_report_submission();
ALTER TABLE public.reports ADD CONSTRAINT report_text_limits
  CHECK (char_length(reason) BETWEEN 1 AND 200 AND char_length(COALESCE(description,''))<=4000) NOT VALID;
ALTER TABLE public.support_reports ADD CONSTRAINT support_diagnostics_limit
  CHECK (octet_length(diagnostics::text)<=32768) NOT VALID;

-- A client-supplied provider label does not prove an event came from a provider.
REVOKE INSERT,UPDATE,DELETE ON public.events FROM anon,authenticated;
DROP POLICY IF EXISTS events_insert_authenticated ON public.events;

-- Support screenshots need the same real decoding as chat/profile pictures.
DROP POLICY IF EXISTS support_attachments_upload_own ON storage.objects;
CREATE POLICY support_upload_requires_backend ON storage.objects
AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK (bucket_id<>'support-attachments');
CREATE POLICY support_replace_requires_backend ON storage.objects
AS RESTRICTIVE FOR UPDATE TO authenticated USING (bucket_id<>'support-attachments')
WITH CHECK (bucket_id<>'support-attachments');
UPDATE storage.buckets SET file_size_limit=5242880,allowed_mime_types=ARRAY['image/png']
WHERE id='support-attachments';
NOTIFY pgrst,'reload schema';
COMMIT;
