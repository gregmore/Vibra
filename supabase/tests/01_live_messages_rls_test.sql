BEGIN;
\ir pgtap_setup.inc

-- Utilizziamo pgTAP (estensione standard per i test unitari in PostgreSQL/Supabase)
CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(2);

-- ==========================================
-- 1. SETUP AMBIENTE DI TEST
-- ==========================================
-- Mock Utente
INSERT INTO auth.users (id, email) 
VALUES ('00000000-0000-0000-0000-000000000001', 'test_user@vibra.local');

INSERT INTO public.users (id, username, last_location) 
VALUES (
    '00000000-0000-0000-0000-000000000001', 
    'TestUser', 
    ST_SetSRID(ST_MakePoint(9.1900, 45.4642), 4326)
) ON CONFLICT (id) DO UPDATE
SET username = EXCLUDED.username, last_location = EXCLUDED.last_location;

-- Mock Evento (Posizionato in centro a Milano)
INSERT INTO public.events (id, external_id, source, name, latitude, longitude, event_date)
VALUES ('00000000-0000-0000-0000-000000000099', 'evt-test-1', 'ticketmaster', 'Vibra Live Test', 45.4642, 9.1900, now());


-- ==========================================
-- 2. SCENARIO 1: Utente a 450 metri
-- ==========================================
-- Spostiamo l'utente a ~443 metri di distanza (9.1957, 45.4642)
UPDATE public.users 
SET last_location = ST_SetSRID(ST_MakePoint(9.1957, 45.4642), 4326) 
WHERE id = '00000000-0000-0000-0000-000000000001';

INSERT INTO public.event_attendees (user_id,event_id,status) VALUES ('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000099','going');

-- Impostiamo il contesto JWT come se l'utente fosse loggato
INSERT INTO auth.sessions (id,user_id) SELECT id,id FROM auth.users ON CONFLICT DO NOTHING;
SET LOCAL role = authenticated;
SET LOCAL request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims TO '{"sub":"00000000-0000-0000-0000-000000000001","session_id":"00000000-0000-0000-0000-000000000001","role":"authenticated"}';

-- Questo inserimento DEVE avere successo
SELECT lives_ok(
  $$ 
  INSERT INTO public.live_messages (event_id, user_id, content) 
  VALUES ('00000000-0000-0000-0000-000000000099', '00000000-0000-0000-0000-000000000001', 'Sono qui al concerto!');
  $$,
  'RLS PERMIT: Utente a 443m (< 500m) può inserire un messaggio live'
);


-- ==========================================
-- 3. SCENARIO 2: Utente a 550 metri
-- ==========================================
-- Ripristiniamo i permessi admin per l'update
SET LOCAL ROLE postgres;

-- Spostiamo l'utente a ~545 metri di distanza (9.1970, 45.4642)
UPDATE public.users 
SET last_location = ST_SetSRID(ST_MakePoint(9.1970, 45.4642), 4326) 
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Ri-logghiamo l'utente
SET LOCAL role = authenticated;
SET LOCAL request.jwt.claim.sub = '00000000-0000-0000-0000-000000000001';
SET LOCAL request.jwt.claims TO '{"sub":"00000000-0000-0000-0000-000000000001","session_id":"00000000-0000-0000-0000-000000000001","role":"authenticated"}';

-- Questo inserimento DEVE fallire violando la RLS
SELECT throws_ok(
  $$ 
  INSERT INTO public.live_messages (event_id, user_id, content) 
  VALUES ('00000000-0000-0000-0000-000000000099', '00000000-0000-0000-0000-000000000001', 'Sono al bar lontano!');
  $$,
  'new row violates row-level security policy for table "live_messages"',
  'RLS DENY: Utente a 545m (> 500m) riceve eccezione di sicurezza PostGIS'
);

-- Pulizia e conclusione
SELECT * FROM finish();
ROLLBACK;
