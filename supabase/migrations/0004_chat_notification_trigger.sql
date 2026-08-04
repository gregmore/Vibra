/*
  Vibra — Chat Notification Trigger
  - Invia notifica agli utenti vicini quando viene inviato un messaggio chat live
*/

-- Assicurati che pg_net sia abilitato
create extension if not exists pg_net;

create or replace function public.notify_live_message()
returns trigger
language plpgsql
security definer
as $$
declare
  request_id bigint;
  payload jsonb;
begin
  payload := json_build_object(
    'type', TG_OP,
    'table', TG_TABLE_NAME,
    'schema', TG_TABLE_SCHEMA,
    'record', row_to_json(NEW)
  );

  select net.http_post(
    url := coalesce(
      current_setting('app.settings.edge_function_url', true), 
      'http://host.docker.internal:54321/functions/v1'
    ) || '/send-chat-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || coalesce(
        current_setting('app.settings.service_role_key', true), 
        'anon'
      )
    ),
    body := payload
  ) into request_id;

  return NEW;
end;
$$;

drop trigger if exists live_messages_notify_trigger on public.live_messages;

create trigger live_messages_notify_trigger
after insert on public.live_messages
for each row execute function public.notify_live_message();
