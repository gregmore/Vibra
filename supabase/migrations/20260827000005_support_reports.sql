-- In-app support queue. Review this table from the Supabase dashboard at least
-- every business day; first response target is 48 hours.
create table if not exists public.support_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  description text not null check (char_length(description) between 8 and 4000),
  screenshot_path text,
  diagnostics jsonb not null default '{}'::jsonb,
  status text not null default 'open' check (status in ('open', 'in_progress', 'resolved')),
  created_at timestamptz not null default now(),
  responded_at timestamptz
);

create index if not exists support_reports_status_created_at_idx
  on public.support_reports (status, created_at desc);

alter table public.support_reports enable row level security;

create policy "support_reports_insert_own"
  on public.support_reports for insert to authenticated
  with check (auth.uid() = user_id);

-- Reports are intentionally not readable/editable from the app after sending.
-- Support staff accesses them with the Supabase dashboard/service role.

insert into storage.buckets (id, name, public)
values ('support-attachments', 'support-attachments', false)
on conflict (id) do nothing;

create policy "support_attachments_upload_own"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Messaggi operativi brevi, pubblicati dal team quando un fornitore o una
-- funzionalità critica è degradata. Chiudere l'incidente porta a nasconderlo.
create table if not exists public.service_incidents (
  id uuid primary key default gen_random_uuid(),
  message text not null check (char_length(message) between 3 and 280),
  status text not null default 'investigating' check (status in ('investigating', 'resolved')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

alter table public.service_incidents enable row level security;

create policy "service_incidents_read_active"
  on public.service_incidents for select to anon, authenticated
  using (status = 'investigating');
