-- Istruzioni per l'uso:
-- 1. Copia tutto questo testo.
-- 2. Apri la tua Dashboard Supabase -> SQL Editor (https://supabase.com/dashboard/project/_/sql).
-- 3. Crea una nuova Query e incolla questo testo.
-- 4. SOSTITUISCI il valore della variabile `my_uid` (riga 10) con il tuo VERO user_id.
--    (Puoi trovarlo in Authentication -> Users).
-- 5. Clicca su "Run" per eseguire lo script.

DO $$ 
DECLARE
  -- SOSTITUISCI QUESTO UUID CON IL TUO VERO USER ID
  my_uid uuid := 'INSERISCI_QUI_IL_TUO_USER_ID'; 

  -- UUID Fissi per i 5 Bot
  bot_1 uuid := '11111111-1111-1111-1111-111111111111'; -- Amico 1 (Chat attiva)
  bot_2 uuid := '22222222-2222-2222-2222-222222222222'; -- Amico 2 (Nuovo messaggio)
  bot_3 uuid := '33333333-3333-3333-3333-333333333333'; -- Richiesta inviata a te
  bot_4 uuid := '44444444-4444-4444-4444-444444444444'; -- Richiesta inviata da te
  bot_5 uuid := '55555555-5555-5555-5555-555555555555'; -- Match perfetto (Nessuna azione ancora)
BEGIN
  -- 0. Controllo di sicurezza
  IF my_uid = 'INSERISCI_QUI_IL_TUO_USER_ID' THEN
    RAISE EXCEPTION 'ERRORE: Devi inserire il tuo VERO user_id alla riga 10 prima di eseguire lo script!';
  END IF;

  -- 1. CREAZIONE BOT NELLA TABELLA AUTH (Supabase)
  INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
  VALUES 
    (bot_1, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bot1@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now()),
    (bot_2, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bot2@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now()),
    (bot_3, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bot3@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now()),
    (bot_4, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bot4@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now()),
    (bot_5, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bot5@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now())
  ON CONFLICT (id) DO NOTHING;

  -- 2. CREAZIONE PROFILI PUBBLICI (users)
  INSERT INTO public.users (id, email, username, display_name, avatar_url, bio, last_latitude, last_longitude, last_location)
  VALUES 
    (bot_1, 'bot1@vibra.app', 'martina_live', 'Martina Rossi', 'https://i.pravatar.cc/150?u=martina', 'Sempre in prima fila ai concerti Indie 🎸', 45.4642, 9.1900, ST_SetSRID(ST_MakePoint(9.1900, 45.4642), 4326)::geography),
    (bot_2, 'bot2@vibra.app', 'ale_techno', 'Alessandro B.', 'https://i.pravatar.cc/150?u=ale', 'Techno, rave e weekend in giro per l''Europa.', 45.4700, 9.1850, ST_SetSRID(ST_MakePoint(9.1850, 45.4700), 4326)::geography),
    (bot_3, 'bot3@vibra.app', 'giulia_pop', 'Giulia Bianchi', 'https://i.pravatar.cc/150?u=giulia', 'Taylor Swift & Pop vibes ✨', 45.4500, 9.2000, ST_SetSRID(ST_MakePoint(9.2000, 45.4500), 4326)::geography),
    (bot_4, 'bot4@vibra.app', 'leo_rock', 'Leonardo', 'https://i.pravatar.cc/150?u=leo', 'Rock classico e chitarre distorte.', 45.4800, 9.1950, ST_SetSRID(ST_MakePoint(9.1950, 45.4800), 4326)::geography),
    (bot_5, 'bot5@vibra.app', 'elena_dj', 'Elena (DJ Set)', 'https://i.pravatar.cc/150?u=elena', 'Producer emergente.', 45.4600, 9.1800, ST_SetSRID(ST_MakePoint(9.1800, 45.4600), 4326)::geography)
  ON CONFLICT (id) DO UPDATE SET 
    display_name = EXCLUDED.display_name,
    avatar_url = EXCLUDED.avatar_url,
    bio = EXCLUDED.bio;

  -- 3. PROFILI MUSICALI (music_profiles)
  INSERT INTO public.music_profiles (user_id, top_artists, top_genres, top_tracks, last_synced_at)
  VALUES 
    (bot_1, '[{"id": "calcutta", "name": "Calcutta", "imageUrl": ""}]', '[{"name": "indie italia", "count": 10}]', '[]', now()),
    (bot_2, '[{"id": "daftpunk", "name": "Daft Punk", "imageUrl": ""}]', '[{"name": "techno", "count": 15}, {"name": "house", "count": 12}]', '[]', now()),
    (bot_3, '[{"id": "taylor", "name": "Taylor Swift", "imageUrl": ""}]', '[{"name": "pop", "count": 20}]', '[]', now()),
    (bot_4, '[{"id": "pinkfloyd", "name": "Pink Floyd", "imageUrl": ""}]', '[{"name": "classic rock", "count": 8}]', '[]', now()),
    (bot_5, '[{"id": "fred", "name": "Fred again..", "imageUrl": ""}]', '[{"name": "electronic", "count": 25}]', '[]', now())
  ON CONFLICT (user_id) DO NOTHING;

  -- 4. AFFINITA' (user_matches)
  DELETE FROM public.user_matches WHERE (user_id_a = my_uid OR user_id_b = my_uid) AND (user_id_a IN (bot_1, bot_2, bot_3, bot_4, bot_5) OR user_id_b IN (bot_1, bot_2, bot_3, bot_4, bot_5));
  INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility, shared_artists, shared_genres)
  VALUES
    (my_uid, bot_1, 95.0, 3, 5), -- Affinità molto alta
    (my_uid, bot_2, 82.5, 1, 4),
    (my_uid, bot_3, 60.0, 0, 2),
    (my_uid, bot_4, 75.2, 1, 3),
    (my_uid, bot_5, 98.9, 5, 8); -- Match perfetto

  -- 5. AMICIZIE (friendships)
  DELETE FROM public.friendships WHERE (requester_id = my_uid OR receiver_id = my_uid) AND (requester_id IN (bot_1, bot_2, bot_3, bot_4, bot_5) OR receiver_id IN (bot_1, bot_2, bot_3, bot_4, bot_5));
  INSERT INTO public.friendships (requester_id, receiver_id, status, created_at)
  VALUES
    (bot_1, my_uid, 'accepted', now() - interval '2 days'), -- Amico confermato
    (my_uid, bot_2, 'accepted', now() - interval '5 hours'), -- Amico confermato
    (bot_3, my_uid, 'pending', now() - interval '1 hour'),   -- Richiesta RICEVUTA da te
    (my_uid, bot_4, 'pending', now() - interval '3 hours');  -- Richiesta INVIATA da te
    -- bot_5 non ha ancora inviato/ricevuto richieste (serve per testare il tasto "Aggiungi")

  -- 6. MESSAGGI (messages)
  DELETE FROM public.messages WHERE (sender_id = my_uid OR receiver_id = my_uid) AND (sender_id IN (bot_1, bot_2) OR receiver_id IN (bot_1, bot_2));
  
  -- Chat con Bot 1 (Già letta e interattiva)
  INSERT INTO public.messages (sender_id, receiver_id, content, read_at, created_at)
  VALUES
    (bot_1, my_uid, 'Ehi ciao! Ho visto che andiamo allo stesso concerto!', now() - interval '1 day', now() - interval '1 day'),
    (my_uid, bot_1, 'Ciao Martina! Sì non vedo l''ora, tu in che settore sei?', now() - interval '23 hours', now() - interval '23 hours'),
    (bot_1, my_uid, 'Parterre! Ci becchiamo per una birra prima?', now() - interval '22 hours', now() - interval '22 hours');

  -- Chat con Bot 2 (Messaggi non letti per testare il badge)
  INSERT INTO public.messages (sender_id, receiver_id, content, read_at, created_at)
  VALUES
    (bot_2, my_uid, 'Bro ho trovato dei biglietti per sabato!', NULL, now() - interval '5 minutes'),
    (bot_2, my_uid, 'Ci sei o no???', NULL, now() - interval '2 minutes');

END $$;
