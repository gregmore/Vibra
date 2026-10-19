BEGIN;

-- Keep hosted URLs and credentials in Vault, rather than embedding secrets in
-- trigger source or relying on development-only database settings.
CREATE FUNCTION vibra_private.enqueue_notification(p_function text, p_payload jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE endpoint text; credential text;
BEGIN
  IF p_function NOT IN ('send-chat-notification', 'send-social-notification') THEN
    RAISE invalid_parameter_value USING MESSAGE = 'Unknown notification worker';
  END IF;
  SELECT decrypted_secret INTO endpoint FROM vault.decrypted_secrets
    WHERE name = 'vibra_functions_url';
  SELECT decrypted_secret INTO credential FROM vault.decrypted_secrets
    WHERE name = 'vibra_service_role_key';
  -- Local test databases intentionally have no production delivery secrets.
  IF endpoint IS NULL OR credential IS NULL THEN RETURN; END IF;
  PERFORM net.http_post(
    url := rtrim(endpoint, '/') || '/' || p_function,
    headers := jsonb_build_object('Content-Type', 'application/json',
      'Authorization', 'Bearer ' || credential),
    body := p_payload
  );
END;
$$;
REVOKE ALL ON FUNCTION vibra_private.enqueue_notification(text, jsonb)
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.notify_live_message()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM vibra_private.enqueue_notification('send-chat-notification',
    jsonb_build_object('type', TG_OP, 'table', TG_TABLE_NAME,
      'schema', TG_TABLE_SCHEMA, 'record', to_jsonb(NEW)));
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.notify_live_message() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.notify_social_action()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  PERFORM vibra_private.enqueue_notification('send-social-notification',
    jsonb_build_object('type', TG_OP, 'table', TG_TABLE_NAME,
      'schema', TG_TABLE_SCHEMA, 'record', to_jsonb(NEW)));
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.notify_social_action() FROM PUBLIC, anon, authenticated;

COMMIT;
