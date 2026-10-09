BEGIN;

-- Qualify the column against the output parameter; client execution remains revoked.
CREATE OR REPLACE FUNCTION public.prepare_my_account_erasure()
RETURNS TABLE(media_path text)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  PERFORM set_config('app.vibra_gdpr_erasure', 'true', true);
  RETURN QUERY
    WITH erased AS (
      SELECT msg.id, msg.media_path FROM public.messages AS msg WHERE msg.sender_id = uid FOR UPDATE
    )
    UPDATE public.messages m
    SET content = 'Messaggio rimosso dall''utente', media_path = NULL, sender_id = NULL,
        metadata = NULL, reactions = NULL
    FROM erased
    WHERE m.id = erased.id
    RETURNING erased.media_path;
END;
$$;
REVOKE ALL ON FUNCTION public.prepare_my_account_erasure() FROM PUBLIC, anon, authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
