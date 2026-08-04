ALTER TABLE public.users ADD COLUMN IF NOT EXISTS push_enabled boolean not null default true;
