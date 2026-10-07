-- Retention is deliberately kept separate from transactional notifications:
-- messages and friend requests bypass this table's caps and quiet hours.
BEGIN;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS last_active_at timestamptz NOT NULL DEFAULT now();

CREATE TABLE IF NOT EXISTS public.notification_preferences (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  retention_enabled boolean NOT NULL DEFAULT true,
  digest_frequency text NOT NULL DEFAULT 'weekly'
    CHECK (digest_frequency IN ('weekly', 'monthly', 'never')),
  retention_max_per_week smallint NOT NULL DEFAULT 2
    CHECK (retention_max_per_week BETWEEN 0 AND 7),
  timezone text NOT NULL DEFAULT 'Europe/Rome',
  quiet_hours_start smallint NOT NULL DEFAULT 22 CHECK (quiet_hours_start BETWEEN 0 AND 23),
  quiet_hours_end smallint NOT NULL DEFAULT 8 CHECK (quiet_hours_end BETWEEN 0 AND 23),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "notification_preferences_owner" ON public.notification_preferences;
CREATE POLICY "notification_preferences_owner" ON public.notification_preferences
  FOR ALL TO authenticated USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE TABLE IF NOT EXISTS public.notification_campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  notification_id uuid REFERENCES public.notifications(id) ON DELETE SET NULL,
  category text NOT NULL CHECK (category IN ('retention', 'digest', 'event_trigger')),
  trigger_key text NOT NULL,
  variant text NOT NULL DEFAULT 'control',
  channel text NOT NULL DEFAULT 'push' CHECK (channel IN ('push', 'email', 'in_app')),
  sent_at timestamptz NOT NULL DEFAULT now(),
  delivered_at timestamptz,
  opened_at timestamptz,
  returned_at timestamptz,
  opted_out_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS idx_notification_campaigns_user_sent
  ON public.notification_campaigns (user_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_campaigns_analytics
  ON public.notification_campaigns (category, trigger_key, variant, sent_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS notification_campaigns_dedupe
  ON public.notification_campaigns (user_id, category, trigger_key, ((sent_at AT TIME ZONE 'UTC')::date));

ALTER TABLE public.notification_campaigns ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "notification_campaigns_owner_read" ON public.notification_campaigns;
CREATE POLICY "notification_campaigns_owner_read" ON public.notification_campaigns
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

-- The client writes activity through a narrowly scoped RPC; it cannot modify
-- another profile or fabricate campaign metrics.
CREATE OR REPLACE FUNCTION public.touch_my_activity()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required'; END IF;
  UPDATE public.users SET last_active_at = now() WHERE id = uid;
  UPDATE public.notification_campaigns
    SET returned_at = now()
  WHERE user_id = uid AND returned_at IS NULL
    AND sent_at >= now() - interval '72 hours';
END;
$$;
REVOKE ALL ON FUNCTION public.touch_my_activity() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.touch_my_activity() TO authenticated;

CREATE OR REPLACE FUNCTION public.record_notification_open(campaign uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  UPDATE public.notification_campaigns
  SET opened_at = COALESCE(opened_at, now())
  WHERE id = campaign AND user_id = auth.uid();
END;
$$;
REVOKE ALL ON FUNCTION public.record_notification_open(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_notification_open(uuid) TO authenticated;

-- The existing settings screen stores granular switches in users.push_settings.
-- Mirror a retention opt-out into analytics without granting clients write access
-- to campaign records.
CREATE OR REPLACE FUNCTION public.track_retention_opt_out()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  IF COALESCE(OLD.push_settings->>'retention', 'true') <> 'false'
     AND COALESCE(NEW.push_settings->>'retention', 'true') = 'false' THEN
    UPDATE public.notification_campaigns
    SET opted_out_at = now()
    WHERE user_id = NEW.id AND opted_out_at IS NULL;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_users_track_retention_opt_out ON public.users;
CREATE TRIGGER trg_users_track_retention_opt_out
AFTER UPDATE OF push_settings ON public.users
FOR EACH ROW EXECUTE FUNCTION public.track_retention_opt_out();
REVOKE ALL ON FUNCTION public.track_retention_opt_out() FROM PUBLIC, anon, authenticated;

-- A compact operations/dashboard source. Conversion is an app return within 72h.
CREATE OR REPLACE VIEW public.notification_campaign_metrics AS
SELECT category, trigger_key, variant, date_trunc('day', sent_at) AS day,
       count(*) AS sent,
       count(*) FILTER (WHERE delivered_at IS NOT NULL) AS delivered,
       count(*) FILTER (WHERE opened_at IS NOT NULL) AS opened,
       count(*) FILTER (WHERE returned_at IS NOT NULL) AS returned,
       count(*) FILTER (WHERE opted_out_at IS NOT NULL) AS opted_out
FROM public.notification_campaigns
GROUP BY 1, 2, 3, 4;
REVOKE ALL ON public.notification_campaign_metrics FROM PUBLIC, anon, authenticated;

-- Include the new in-app notification types in the immutable notification domain.
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN (
  'event_alert', 'match', 'friend_request', 'message_request', 'chat_message',
  'live_chat', 'ticket_low', 'retention', 'digest', 'artist_concert', 'event_update'
));

COMMIT;
