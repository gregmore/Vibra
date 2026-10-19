-- Scheduled requests must never store a service-role key in a database
-- setting. The key is read from Supabase Vault at execution time instead.
create extension if not exists pg_cron;
create extension if not exists pg_net;

do $$
begin
  if exists (select 1 from vault.secrets where name = 'vibra_service_role_key') then
    perform cron.schedule(
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
  else
    raise notice 'Notification cron not scheduled: add the vibra_service_role_key Vault secret, then run supabase/setup_notification_cron.sql.';
  end if;
end;
$$;
