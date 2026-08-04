BEGIN;

-- 1. Aggiungiamo push_settings in JSONB per avere granularità notifiche (es. { "match": true, "chat": false })
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS push_settings jsonb NOT NULL DEFAULT '{}'::jsonb;

-- 2. Aggiungiamo le tabelle mancanti alla publication supabase_realtime
-- (messages e live_messages sono state già aggiunte nella 0010)
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_matches;
ALTER PUBLICATION supabase_realtime ADD TABLE public.friendships;

-- 3. Funzione generica per inviare webhook a Edge Function in caso di azioni social
create or replace function public.notify_social_action()
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
    ) || '/send-social-notification',
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

drop trigger if exists messages_notify_trigger on public.messages;
create trigger messages_notify_trigger
after insert on public.messages
for each row execute function public.notify_social_action();

drop trigger if exists friendships_notify_trigger on public.friendships;
create trigger friendships_notify_trigger
after insert on public.friendships
for each row execute function public.notify_social_action();

drop trigger if exists user_matches_notify_trigger on public.user_matches;
create trigger user_matches_notify_trigger
after insert on public.user_matches
for each row execute function public.notify_social_action();

COMMIT;
