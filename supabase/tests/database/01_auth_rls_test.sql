BEGIN;
select plan(4);

-- Crea utenti fittizi per i test
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'user1@test.com'),
  ('22222222-2222-2222-2222-222222222222', 'user2@test.com');

insert into public.users (id, username) values
  ('11111111-1111-1111-1111-111111111111', 'user1'),
  ('22222222-2222-2222-2222-222222222222', 'user2');

-- Inserisci un evento salvato da user1
insert into saved_events (user_id, event_id) values
  ('11111111-1111-1111-1111-111111111111', 'event_xyz');

-- 1. Un utente non autenticato non dovrebbe poter leggere gli eventi salvati
set local role anon;
select is_empty(
  'select * from saved_events',
  'Anon cannot read saved events'
);

-- 2. L'utente 2 non dovrebbe poter leggere gli eventi dell'utente 1
set local role authenticated;
set local request.jwt.claim.sub to '22222222-2222-2222-2222-222222222222';
select is_empty(
  'select * from saved_events',
  'User 2 cannot read User 1 events'
);

-- 3. L'utente 2 non dovrebbe poter inserire a nome dell'utente 1 (IDOR)
select throws_like(
  $$ insert into saved_events (user_id, event_id) values ('11111111-1111-1111-1111-111111111111', 'event_abc') $$,
  '%new row violates row-level security policy%',
  'User 2 cannot insert for User 1'
);

-- 4. L'utente 1 dovrebbe leggere i propri eventi
set local role authenticated;
set local request.jwt.claim.sub to '11111111-1111-1111-1111-111111111111';
select results_eq(
  'select event_id from saved_events',
  $$values ('event_xyz')$$,
  'User 1 can read own events'
);

select * from finish();
ROLLBACK;
