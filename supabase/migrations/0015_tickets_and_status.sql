-- Migrazione 0015: Aggiunta colonna status su events e tabella per analytics ticket_clicks

-- 1. Aggiungiamo status alla tabella events
alter table public.events
add column if not exists status text default 'onsale'
check (status in ('onsale', 'offsale', 'canceled', 'postponed', 'rescheduled'));

-- 2. Creiamo la tabella per tracciare i click sui ticket (analytics)
create table if not exists public.ticket_clicks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  event_id uuid not null references public.events(id) on delete cascade,
  clicked_at timestamptz not null default now()
);

-- Indici per performance analytics
create index if not exists idx_ticket_clicks_event_id on public.ticket_clicks (event_id);
create index if not exists idx_ticket_clicks_user_id on public.ticket_clicks (user_id);
create index if not exists idx_ticket_clicks_clicked_at on public.ticket_clicks (clicked_at);

-- Abilitiamo RLS e policy (solo insert per gli utenti autenticati)
alter table public.ticket_clicks enable row level security;

create policy "ticket_clicks_insert"
on public.ticket_clicks for insert
to authenticated
with check (auth.uid() = user_id);

-- La visualizzazione (select) potrebbe essere limitata ad admin, 
-- per ora non la esponiamo agli utenti, dato che serve solo internamente.
