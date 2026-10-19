-- Keeps the visual mode coherent when the same Vibra account is used on a
-- second device. The client still stores its value locally for offline use.
alter table public.users
  add column if not exists theme_preference text not null default 'system'
  check (theme_preference in ('dark', 'light', 'system'));
