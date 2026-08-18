-- Abilita l'estensione pg_cron (se disponibile nel db)
create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Schedula l'invio delle notifiche per gli eventi vicini ogni 6 ore
select cron.schedule(
  'invoke-send-notifications',
  '0 */6 * * *', -- Ogni 6 ore
  $$
    select net.http_post(
      url := coalesce(
        current_setting('app.settings.edge_function_url', true), 
        'http://host.docker.internal:54321/functions/v1'
      ) || '/send-notifications',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || coalesce(
          current_setting('app.settings.service_role_key', true), 
          'anon'
        )
      ),
      body := '{}'::jsonb
    );
  $$
);
