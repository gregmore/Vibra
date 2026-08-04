/*
  Vibra — Schema DB + RLS (Supabase / PostgreSQL)

  NOTE IMPORTANTI:
  - In Supabase l’identità utente è in auth.users (UUID).
  - La tabella public.users è un profilo applicativo: PK = auth.users.id.
  - I campi sensibili (spotify_access_token/refresh_token) NON sono leggibili da altri utenti
    grazie a RLS e alla separazione tramite view pubblica.
*/

-- ─────────────────────────────────────────────────────────────
-- Extensions
-- ─────────────────────────────────────────────────────────────
create extension if not exists "pgcrypto";
create extension if not exists "citext";
create extension if not exists "postgis";

-- ─────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ─────────────────────────────────────────────────────────────
-- Tables
-- ─────────────────────────────────────────────────────────────

-- Utenti (profilo applicativo + credenziali spotify per sync)
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email citext unique,
  username citext unique,
  display_name text,
  avatar_url text,
  bio text,
  spotify_id text,
  spotify_access_token text,
  spotify_refresh_token text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

-- Profilo musicale (1:1 con utente)
create table if not exists public.music_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  top_artists jsonb not null default '[]'::jsonb,
  top_tracks jsonb not null default '[]'::jsonb,
  top_genres jsonb not null default '[]'::jsonb,
  last_synced_at timestamptz,
  constraint music_profiles_user_id_unique unique (user_id)
);

-- Eventi (cache normalizzata da fonti esterne)
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  external_id text not null,
  source text not null check (source in ('ticketmaster', 'songkick', 'bandsintown')),
  name text not null,
  artist_name text,
  artist_spotify_id text,
  venue_name text,
  city text,
  country text,
  latitude double precision,
  longitude double precision,
  -- Colonna ausiliaria per query geografiche veloci (non rompe la struttura richiesta)
  location geography(point, 4326),
  event_date timestamptz not null,
  ticket_url text,
  price_min double precision,
  price_max double precision,
  image_url text,
  description text,
  created_at timestamptz not null default now(),
  constraint events_source_external_unique unique (source, external_id)
);

create or replace function public.events_sync_location()
returns trigger
language plpgsql
as $$
begin
  if new.latitude is not null and new.longitude is not null then
    new.location = st_setsrid(st_makepoint(new.longitude, new.latitude), 4326)::geography;
  else
    new.location = null;
  end if;
  return new;
end;
$$;

create trigger trg_events_location
before insert or update of latitude, longitude on public.events
for each row execute function public.events_sync_location();

-- Partecipazione eventi
create table if not exists public.event_attendees (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  event_id uuid not null references public.events(id) on delete cascade,
  status text not null check (status in ('going', 'maybe', 'not_going')),
  created_at timestamptz not null default now(),
  constraint event_attendees_user_event_unique unique (user_id, event_id)
);

-- Amicizie (direzionale requester -> receiver)
create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.users(id) on delete cascade,
  receiver_id uuid not null references public.users(id) on delete cascade,
  status text not null check (status in ('pending', 'accepted', 'rejected')),
  created_at timestamptz not null default now(),
  constraint friendships_requester_receiver_unique unique (requester_id, receiver_id),
  constraint friendships_no_self check (requester_id <> receiver_id)
);

-- Messaggi diretti 1:1
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.users(id) on delete cascade,
  receiver_id uuid not null references public.users(id) on delete cascade,
  content text not null,
  read_at timestamptz,
  created_at timestamptz not null default now(),
  constraint messages_no_self check (sender_id <> receiver_id)
);

-- Chat live evento (realtime)
create table if not exists public.live_messages (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

-- Notifiche (push/in-app)
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  type text not null check (type in ('event_alert', 'match', 'friend_request', 'ticket_low')),
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────
-- Indexes (performance)
-- ─────────────────────────────────────────────────────────────

-- users
create index if not exists idx_users_created_at on public.users (created_at desc);

-- music_profiles
create index if not exists idx_music_profiles_user_id on public.music_profiles (user_id);

-- events
create index if not exists idx_events_event_date on public.events (event_date asc);
create index if not exists idx_events_artist_spotify_id on public.events (artist_spotify_id);
create index if not exists idx_events_city_country on public.events (city, country);
create index if not exists idx_events_source on public.events (source);
create index if not exists idx_events_location_gist on public.events using gist (location);

-- event_attendees
create index if not exists idx_event_attendees_event_id on public.event_attendees (event_id);
create index if not exists idx_event_attendees_user_id on public.event_attendees (user_id);
create index if not exists idx_event_attendees_status on public.event_attendees (status);

-- friendships
create index if not exists idx_friendships_requester on public.friendships (requester_id);
create index if not exists idx_friendships_receiver on public.friendships (receiver_id);
create index if not exists idx_friendships_status on public.friendships (status);

-- messages
create index if not exists idx_messages_sender_created on public.messages (sender_id, created_at desc);
create index if not exists idx_messages_receiver_created on public.messages (receiver_id, created_at desc);

-- live_messages
create index if not exists idx_live_messages_event_created on public.live_messages (event_id, created_at desc);
create index if not exists idx_live_messages_user_created on public.live_messages (user_id, created_at desc);

-- notifications
create index if not exists idx_notifications_user_created on public.notifications (user_id, created_at desc);
create index if not exists idx_notifications_user_read on public.notifications (user_id, read, created_at desc);

-- ─────────────────────────────────────────────────────────────
-- RLS
-- ─────────────────────────────────────────────────────────────

alter table public.users enable row level security;
alter table public.music_profiles enable row level security;
alter table public.events enable row level security;
alter table public.event_attendees enable row level security;
alter table public.friendships enable row level security;
alter table public.messages enable row level security;
alter table public.live_messages enable row level security;
alter table public.notifications enable row level security;

-- USERS: accesso completo SOLO al proprietario.
create policy "users_select_own"
on public.users for select
to authenticated
using (id = auth.uid());

create policy "users_insert_own"
on public.users for insert
to authenticated
with check (id = auth.uid());

create policy "users_update_own"
on public.users for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "users_delete_own"
on public.users for delete
to authenticated
using (id = auth.uid());

-- View pubblica: permette di vedere i profili (campi NON sensibili).
-- NB: chiunque autenticato può leggere; i token restano protetti nella tabella.
drop view if exists public.users_public cascade;
create view public.users_public
with (security_invoker = true)
as
select
  id,
  username,
  display_name,
  avatar_url,
  bio,
  spotify_id,
  created_at,
  updated_at
from public.users;

revoke all on table public.users_public from public;
grant select on table public.users_public to authenticated;

-- MUSIC_PROFILES: solo proprietario.
create policy "music_profiles_select_own"
on public.music_profiles for select
to authenticated
using (user_id = auth.uid());

create policy "music_profiles_insert_own"
on public.music_profiles for insert
to authenticated
with check (user_id = auth.uid());

create policy "music_profiles_update_own"
on public.music_profiles for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "music_profiles_delete_own"
on public.music_profiles for delete
to authenticated
using (user_id = auth.uid());

-- EVENTS: lettura pubblica. Inserimento/Aggiornamento permesso agli utenti autenticati per salvare gli eventi dalla mappa.
create policy "events_select_all"
on public.events for select
to anon, authenticated
using (true);

create policy "events_insert_authenticated"
on public.events for insert
to authenticated
with check (true);

create policy "events_update_authenticated"
on public.events for update
to authenticated
using (true)
with check (true);

-- EVENT_ATTENDEES:
-- - select: per utenti autenticati (serve a mostrare partecipanti)
-- - insert/update/delete: solo su righe proprie
create policy "event_attendees_select_authenticated"
on public.event_attendees for select
to authenticated
using (true);

create policy "event_attendees_insert_own"
on public.event_attendees for insert
to authenticated
with check (user_id = auth.uid());

create policy "event_attendees_update_own"
on public.event_attendees for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "event_attendees_delete_own"
on public.event_attendees for delete
to authenticated
using (user_id = auth.uid());

-- FRIENDSHIPS:
-- - select: solo se coinvolto
-- - insert: solo requester = auth.uid()
-- - update: receiver può accettare/rifiutare; requester può annullare (set rejected)
create policy "friendships_select_involved"
on public.friendships for select
to authenticated
using (requester_id = auth.uid() or receiver_id = auth.uid());

create policy "friendships_insert_requester"
on public.friendships for insert
to authenticated
with check (requester_id = auth.uid());

create policy "friendships_update_receiver_accept_reject"
on public.friendships for update
to authenticated
using (receiver_id = auth.uid())
with check (receiver_id = auth.uid() and status in ('accepted', 'rejected'));

create policy "friendships_update_requester_cancel"
on public.friendships for update
to authenticated
using (requester_id = auth.uid())
with check (requester_id = auth.uid() and status = 'rejected');

create policy "friendships_delete_involved"
on public.friendships for delete
to authenticated
using (requester_id = auth.uid() or receiver_id = auth.uid());

-- MESSAGES:
-- - select: solo sender/receiver
-- - insert: solo se sender = auth.uid()
-- - update: solo receiver (per set read_at)
create policy "messages_select_involved"
on public.messages for select
to authenticated
using (sender_id = auth.uid() or receiver_id = auth.uid());

create policy "messages_insert_sender"
on public.messages for insert
to authenticated
with check (sender_id = auth.uid());

create policy "messages_update_receiver_read"
on public.messages for update
to authenticated
using (receiver_id = auth.uid())
with check (receiver_id = auth.uid());

-- LIVE_MESSAGES:
-- - select: solo autenticati
-- - insert: solo se user_id = auth.uid() e l’utente risulta partecipante all’evento (going/maybe)
create policy "live_messages_select_authenticated"
on public.live_messages for select
to authenticated
using (true);

create policy "live_messages_insert_if_attending"
on public.live_messages for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.event_attendees ea
    where ea.event_id = live_messages.event_id
      and ea.user_id = auth.uid()
      and ea.status in ('going', 'maybe')
  )
);

-- NOTIFICATIONS:
-- - select/update: solo proprietario
-- - insert: tipicamente via Edge Function/service role (bypass RLS)
create policy "notifications_select_own"
on public.notifications for select
to authenticated
using (user_id = auth.uid());

create policy "notifications_update_own"
on public.notifications for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "notifications_delete_own"
on public.notifications for delete
to authenticated
using (user_id = auth.uid());

