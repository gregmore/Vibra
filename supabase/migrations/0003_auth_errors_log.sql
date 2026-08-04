-- ─────────────────────────────────────────────────────────────
-- Vibra — Auth Errors Logging Table
-- ─────────────────────────────────────────────────────────────

create table if not exists public.auth_errors_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  error_code text not null,
  error_message text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Abilita RLS
alter table public.auth_errors_log enable row level security;

-- Consenti inserimento a chiunque (anonimo o autenticato) per gestire errori prima del login completato
create policy "Consenti inserimento log errori auth a chiunque"
on public.auth_errors_log for insert
to authenticated, anon
with check (true);

-- Consenti lettura solo agli amministratori (o per semplicità nel prototipo disabilita lettura pubblica)
create policy "Consenti lettura log errori auth solo ad amministratore"
on public.auth_errors_log for select
to service_role
using (true);
