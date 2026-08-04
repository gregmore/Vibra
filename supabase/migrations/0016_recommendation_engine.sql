-- Enable pgvector
create extension if not exists vector;

-- Modifiche music_profiles
alter table public.music_profiles 
add column if not exists audio_features jsonb,
add column if not exists embedding vector(10);

-- Modifiche events
alter table public.events
add column if not exists embedding vector(10);

-- Indici per la ricerca di similarità (usa HNSW per performance a scala)
-- Se i dati sono pochi all'inizio andrebbe bene anche ricerca esatta senza indice, ma prepariamo per scalare.
create index if not exists idx_music_profiles_embedding on public.music_profiles using hnsw (embedding vector_cosine_ops);
create index if not exists idx_events_embedding on public.events using hnsw (embedding vector_cosine_ops);

-- Tabella log interazioni per il miglioramento dell'algoritmo
create table if not exists public.user_interactions_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  entity_type text not null check (entity_type in ('event', 'user')),
  entity_id uuid not null,
  interaction_type text not null check (interaction_type in ('event_view', 'event_save', 'ticket_click', 'match_proposed', 'match_accepted', 'match_rejected')),
  score_at_time double precision, -- lo score predetto dal modello al momento dell'interazione
  metadata jsonb, -- eventuali dettagli aggiuntivi (es. pesi A/B testing attivi in quel momento)
  created_at timestamptz not null default now()
);

-- Indici utili per analytics e filtering
create index if not exists idx_user_interactions_user on public.user_interactions_log(user_id);
create index if not exists idx_user_interactions_type on public.user_interactions_log(interaction_type);

-- Tabella di configurazione pesi dell'algoritmo (per A/B testing e tuning in tempo reale)
create table if not exists public.algorithm_config (
  id text primary key, -- ex. 'default', 'variant_a', 'variant_b'
  content_weight double precision not null default 0.5,
  collab_weight double precision not null default 0.2,
  geo_weight double precision not null default 0.2,
  social_weight double precision not null default 0.1,
  serendipity_factor double precision not null default 0.1,
  active boolean not null default false,
  updated_at timestamptz not null default now()
);

-- Inserisci configurazione di default
insert into public.algorithm_config (id, content_weight, collab_weight, geo_weight, social_weight, serendipity_factor, active)
values ('default', 0.6, 0.1, 0.2, 0.1, 0.15, true)
on conflict (id) do nothing;
