-- Enforce consent atomically, including token refresh racing with opt-out.
create or replace function vibra_private.enforce_push_consent()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if new.push_enabled is false then
    new.fcm_token := null;
  end if;
  return new;
end;
$$;
revoke all on function vibra_private.enforce_push_consent() from public, anon, authenticated;
create trigger enforce_push_consent
before insert or update of fcm_token, push_enabled on public.users
for each row execute function vibra_private.enforce_push_consent();
update public.users set fcm_token = null where push_enabled is false and fcm_token is not null;

-- New reminders carry a day offset, allowing one inbox/push per event milestone.
create unique index notifications_event_reminder_unique
on public.notifications (user_id, (data->>'event_id'), (data->>'reminder_days'))
where type = 'event_alert' and data->>'reminder' = 'true'
  and data->>'reminder_days' is not null;
