/*
  Vibra — Supporto Edge Functions
  - Persistenza compatibilità utenti
  - Token push + ultima posizione (per proximity e notifiche)
*/

-- Colonne aggiuntive su users (profilo applicativo)
alter table public.users
  add column if not exists fcm_token text,
  add column if not exists last_latitude double precision,
  add column if not exists last_longitude double precision;

-- Tabella compatibilità utenti (calcolata da Edge Function)
create table if not exists public.user_matches (
  id uuid primary key default gen_random_uuid(),
  user_id_a uuid not null references public.users(id) on delete cascade,
  user_id_b uuid not null references public.users(id) on delete cascade,
  compatibility double precision not null check (compatibility >= 0 and compatibility <= 100),
  shared_artists int not null default 0,
  shared_genres int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_matches_no_self check (user_id_a <> user_id_b),
  constraint user_matches_unique_pair unique (user_id_a, user_id_b)
);

create index if not exists idx_user_matches_user_a on public.user_matches (user_id_a);
create index if not exists idx_user_matches_user_b on public.user_matches (user_id_b);
create index if not exists idx_user_matches_compat on public.user_matches (compatibility desc);

create trigger trg_user_matches_updated_at
before update on public.user_matches
for each row execute function public.set_updated_at();

alter table public.user_matches enable row level security;

-- Selezione consentita se l'utente è coinvolto.
create policy "user_matches_select_involved"
on public.user_matches for select
to authenticated
using (user_id_a = auth.uid() or user_id_b = auth.uid());

-- Insert/Update/Delete: nessuna policy per authenticated (solo service role / Edge Function).

