-- Run this once in the Supabase SQL Editor *after* creating the
-- `vibra_service_role_key` secret in Vault. It is safe to re-run.
--
-- Create the secret from the dashboard (Vault > New secret), never by
-- committing it to this repository or adding it to a migration.

select cron.unschedule(jobid)
from cron.job
where jobname = 'invoke-send-notifications';

select cron.schedule(
  'invoke-send-notifications',
  '0 */6 * * *',
  $cron$
    select net.http_post(
      url := 'https://your-project-ref.supabase.co/functions/v1/send-notifications',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (
          select decrypted_secret
          from vault.decrypted_secrets
          where name = 'vibra_service_role_key'
        )
      ),
      body := '{}'::jsonb
    );
  $cron$
);

select cron.unschedule(jobid)
from cron.job
where jobname = 'invoke-retention-notifications';

-- Runs hourly so the worker can respect each user's local quiet hours. It
-- applies its own weekly cap and never handles transactional chat/friend pushes.
select cron.schedule(
  'invoke-retention-notifications',
  '7 * * * *',
  $cron$
    select net.http_post(
      url := 'https://your-project-ref.supabase.co/functions/v1/retention-notifications',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (
          select decrypted_secret
          from vault.decrypted_secrets
          where name = 'vibra_service_role_key'
        )
      ),
      body := '{}'::jsonb
    );
  $cron$
);

select cron.unschedule(jobid)
from cron.job
where jobname = 'invoke-event-reminders';

-- Saved/going events are operational reminders, intentionally outside the
-- retention cap. The function honours the user's event-alert setting.
select cron.schedule(
  'invoke-event-reminders',
  '15 9 * * *',
  $cron$
    select net.http_post(
      url := 'https://your-project-ref.supabase.co/functions/v1/event-reminders',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (
          select decrypted_secret from vault.decrypted_secrets
          where name = 'vibra_service_role_key'
        )
      ),
      body := '{}'::jsonb
    );
  $cron$
);
