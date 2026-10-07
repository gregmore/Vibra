-- ============================================================
--  VIBRA -- Seed Bot per testare la sezione AMICI + CHAT
-- ============================================================
-- Istruzioni:
--   1. Vai su Authentication -> Users e copia il tuo user_id
--   2. Sostituisci INSERISCI_QUI_IL_TUO_USER_ID alla riga 15
--   3. Esegui nel SQL Editor -> New Query -> Run
-- ============================================================
-- Scenari coperti:
--   Bot 1 Martina   -> Amica confermata + chat letta
--   Bot 2 Alessandro-> Amico confermato + 2 msg NON LETTI (badge)
--   Bot 3 Giulia    -> Richiesta RICEVUTA (puoi accettare/rifiutare)
--   Bot 4 Leonardo  -> Richiesta INVIATA (in attesa)
--   Bot 5 Elena     -> Nessuna relazione (appare in Esplora)
--   Bot 6 Marco     -> Amico confermato, nessun messaggio
-- ============================================================

DO $seed$
DECLARE
  -- !! SOSTITUISCI CON IL TUO VERO USER ID !!
  my_uid uuid := 'INSERISCI_QUI_IL_TUO_USER_ID';

  bot_1  uuid := '11111111-1111-1111-1111-111111111111';
  bot_2  uuid := '22222222-2222-2222-2222-222222222222';
  bot_3  uuid := '33333333-3333-3333-3333-333333333333';
  bot_4  uuid := '44444444-4444-4444-4444-444444444444';
  bot_5  uuid := '55555555-5555-5555-5555-555555555555';
  bot_6  uuid := '66666666-6666-6666-6666-666666666666';
BEGIN

  -- 0. CONTROLLO SICUREZZA
  IF my_uid::text = 'INSERISCI_QUI_IL_TUO_USER_ID' THEN
    RAISE EXCEPTION 'Devi sostituire my_uid con il tuo vero User ID alla riga 20!';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = my_uid) THEN
    RAISE EXCEPTION 'User ID non trovato in public.users. Controlla di aver copiato bene.';
  END IF;

  -- 1. CREAZIONE BOT IN auth.users
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
  ) VALUES
    (bot_1,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','bot1_martina@vibra.test','',now(),'{"provider":"email","providers":["email"]}','{}',now(),now()),
    (bot_2,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','bot2_ale@vibra.test','',now(),'{"provider":"email","providers":["email"]}','{}',now(),now()),
    (bot_3,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','bot3_giulia@vibra.test','',now(),'{"provider":"email","providers":["email"]}','{}',now(),now()),
    (bot_4,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','bot4_leo@vibra.test','',now(),'{"provider":"email","providers":["email"]}','{}',now(),now()),
    (bot_5,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','bot5_elena@vibra.test','',now(),'{"provider":"email","providers":["email"]}','{}',now(),now()),
    (bot_6,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','bot6_marco@vibra.test','',now(),'{"provider":"email","providers":["email"]}','{}',now(),now())
  ON CONFLICT (id) DO NOTHING;

  -- 2. PROFILI PUBBLICI (public.users)
  INSERT INTO public.users (
    id, email, username, display_name, avatar_url, bio,
    last_latitude, last_longitude, last_location, onboarding_completed
  ) VALUES
    (bot_1,'bot1_martina@vibra.test','martina_live','Martina Rossi',
     'https://i.pravatar.cc/150?img=47',
     'Sempre in prima fila ai concerti Indie | Milano',
     45.4642,9.1900,ST_SetSRID(ST_MakePoint(9.1900,45.4642),4326)::geography,true),

    (bot_2,'bot2_ale@vibra.test','ale_techno','Alessandro B.',
     'https://i.pravatar.cc/150?img=12',
     'Techno, rave e weekend in giro per l''Europa',
     45.4700,9.1850,ST_SetSRID(ST_MakePoint(9.1850,45.4700),4326)::geography,true),

    (bot_3,'bot3_giulia@vibra.test','giulia_pop','Giulia Bianchi',
     'https://i.pravatar.cc/150?img=44',
     'Taylor Swift e pop vibes | Eras Tour survivor',
     45.4500,9.2000,ST_SetSRID(ST_MakePoint(9.2000,45.4500),4326)::geography,true),

    (bot_4,'bot4_leo@vibra.test','leo_rock','Leonardo M.',
     'https://i.pravatar.cc/150?img=7',
     'Rock classico e chitarre distorte | Metallica forever',
     45.4800,9.1950,ST_SetSRID(ST_MakePoint(9.1950,45.4800),4326)::geography,true),

    (bot_5,'bot5_elena@vibra.test','elena_dj','Elena DJ',
     'https://i.pravatar.cc/150?img=56',
     'Producer emergente | Fred again.. addict',
     45.4600,9.1800,ST_SetSRID(ST_MakePoint(9.1800,45.4600),4326)::geography,true),

    (bot_6,'bot6_marco@vibra.test','marco_hiphop','Marco D.',
     'https://i.pravatar.cc/150?img=33',
     'Hip-hop e R&B. Sempre a caccia di nuovi drop',
     45.4650,9.2050,ST_SetSRID(ST_MakePoint(9.2050,45.4650),4326)::geography,true)
  ON CONFLICT (id) DO UPDATE SET
    display_name         = EXCLUDED.display_name,
    avatar_url           = EXCLUDED.avatar_url,
    bio                  = EXCLUDED.bio,
    onboarding_completed = true;

  -- 3. PROFILI MUSICALI (public.music_profiles)
  INSERT INTO public.music_profiles (
    user_id, top_artists, top_genres, top_tracks, listening_heatmap, last_synced_at
  ) VALUES
    (bot_1,
     '[{"id":"calcutta","name":"Calcutta","score":100},{"id":"cosmo","name":"Cosmo","score":85}]',
     '[{"genre":"indie italia","weight":1.0},{"genre":"cantautorato","weight":0.7}]',
     '[{"id":"t1","name":"Kati","artist":"Calcutta","score":100}]',
     '[{"day":"Lun","value":0.5},{"day":"Mar","value":0.8},{"day":"Mer","value":0.3},{"day":"Gio","value":0.9},{"day":"Ven","value":1.0},{"day":"Sab","value":0.7},{"day":"Dom","value":0.4}]',
     now()),
    (bot_2,
     '[{"id":"daftpunk","name":"Daft Punk","score":100},{"id":"bicep","name":"Bicep","score":90}]',
     '[{"genre":"techno","weight":1.0},{"genre":"house","weight":0.9}]',
     '[{"id":"t2","name":"Glue","artist":"Bicep","score":100}]',
     '[{"day":"Lun","value":0.2},{"day":"Mar","value":0.3},{"day":"Mer","value":0.4},{"day":"Gio","value":0.6},{"day":"Ven","value":0.9},{"day":"Sab","value":1.0},{"day":"Dom","value":0.8}]',
     now()),
    (bot_3,
     '[{"id":"taylor","name":"Taylor Swift","score":100},{"id":"ariana","name":"Ariana Grande","score":80}]',
     '[{"genre":"pop","weight":1.0},{"genre":"teen pop","weight":0.8}]',
     '[{"id":"t3","name":"Anti-Hero","artist":"Taylor Swift","score":100}]',
     '[{"day":"Lun","value":0.6},{"day":"Mar","value":0.7},{"day":"Mer","value":0.5},{"day":"Gio","value":0.8},{"day":"Ven","value":1.0},{"day":"Sab","value":0.9},{"day":"Dom","value":0.6}]',
     now()),
    (bot_4,
     '[{"id":"metallica","name":"Metallica","score":100},{"id":"pinkfloyd","name":"Pink Floyd","score":95}]',
     '[{"genre":"classic rock","weight":1.0},{"genre":"metal","weight":0.9}]',
     '[{"id":"t4","name":"The Wall","artist":"Pink Floyd","score":100}]',
     '[{"day":"Lun","value":0.7},{"day":"Mar","value":0.5},{"day":"Mer","value":0.8},{"day":"Gio","value":0.4},{"day":"Ven","value":0.9},{"day":"Sab","value":1.0},{"day":"Dom","value":0.3}]',
     now()),
    (bot_5,
     '[{"id":"fredagain","name":"Fred again..","score":100},{"id":"bonobo","name":"Bonobo","score":88}]',
     '[{"genre":"electronic","weight":1.0},{"genre":"ambient","weight":0.7}]',
     '[{"id":"t5","name":"Delilah","artist":"Fred again..","score":100}]',
     '[{"day":"Lun","value":0.4},{"day":"Mar","value":0.6},{"day":"Mer","value":0.5},{"day":"Gio","value":0.7},{"day":"Ven","value":0.8},{"day":"Sab","value":1.0},{"day":"Dom","value":0.9}]',
     now()),
    (bot_6,
     '[{"id":"kendrick","name":"Kendrick Lamar","score":100},{"id":"frankocean","name":"Frank Ocean","score":92}]',
     '[{"genre":"hip-hop","weight":1.0},{"genre":"r&b","weight":0.85}]',
     '[{"id":"t6","name":"HUMBLE.","artist":"Kendrick Lamar","score":100}]',
     '[{"day":"Lun","value":0.3},{"day":"Mar","value":0.5},{"day":"Mer","value":0.7},{"day":"Gio","value":0.6},{"day":"Ven","value":0.9},{"day":"Sab","value":1.0},{"day":"Dom","value":0.8}]',
     now())
  ON CONFLICT (user_id) DO UPDATE SET
    top_artists       = EXCLUDED.top_artists,
    top_genres        = EXCLUDED.top_genres,
    top_tracks        = EXCLUDED.top_tracks,
    listening_heatmap = EXCLUDED.listening_heatmap,
    last_synced_at    = EXCLUDED.last_synced_at;

  -- 4. COMPATIBILITA' (user_matches)
  DELETE FROM public.user_matches
    WHERE (user_id_a = my_uid OR user_id_b = my_uid)
      AND (user_id_a IN (bot_1,bot_2,bot_3,bot_4,bot_5,bot_6)
        OR user_id_b IN (bot_1,bot_2,bot_3,bot_4,bot_5,bot_6));

  INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility, shared_artists, shared_genres)
  VALUES
    (my_uid,bot_1,95.0,3,5),
    (my_uid,bot_2,82.5,1,4),
    (my_uid,bot_3,60.0,0,2),
    (my_uid,bot_4,75.2,1,3),
    (my_uid,bot_5,98.9,5,8),
    (my_uid,bot_6,70.0,2,3);

  -- 5. AMICIZIE (friendships)
  --   bot_1 -> accepted (lei ha inviato a te)
  --   bot_2 -> accepted (tu hai inviato a lui)
  --   bot_3 -> pending ricevuta (lei ti chiede amicizia, vedi pulsanti)
  --   bot_4 -> pending inviata (tu hai chiesto a lui)
  --   bot_5 -> nessuna relazione
  --   bot_6 -> accepted, nessun messaggio
  DELETE FROM public.friendships
    WHERE (requester_id = my_uid OR receiver_id = my_uid)
      AND (requester_id IN (bot_1,bot_2,bot_3,bot_4,bot_5,bot_6)
        OR receiver_id  IN (bot_1,bot_2,bot_3,bot_4,bot_5,bot_6));

  INSERT INTO public.friendships (requester_id, receiver_id, status, created_at)
  VALUES
    (bot_1, my_uid, 'accepted', now() - interval '3 days'),
    (my_uid,bot_2,  'accepted', now() - interval '1 day'),
    (bot_3, my_uid, 'pending',  now() - interval '2 hours'),
    (my_uid,bot_4,  'pending',  now() - interval '5 hours'),
    (my_uid,bot_6,  'accepted', now() - interval '7 days');

  -- 6. MESSAGGI (messages)
  DELETE FROM public.messages
    WHERE (sender_id = my_uid OR receiver_id = my_uid)
      AND (sender_id   IN (bot_1,bot_2,bot_6)
        OR receiver_id IN (bot_1,bot_2,bot_6));

  -- Chat con Martina (bot_1) -- tutti letti
  INSERT INTO public.messages (sender_id, receiver_id, content, read_at, created_at)
  VALUES
    (bot_1, my_uid,'Ehi! Ho visto che andiamo allo stesso concerto!',
     now()-interval'2 days 23 hours', now()-interval'3 days'),
    (my_uid,bot_1, 'Ciao Martina! Si non vedo l''ora. Tu in che settore sei?',
     now()-interval'2 days 22 hours', now()-interval'2 days 23 hours'),
    (bot_1, my_uid,'Parterre! Ci becchiamo prima per una birra?',
     now()-interval'2 days 21 hours', now()-interval'2 days 22 hours'),
    (my_uid,bot_1, 'Perfetto, ci sono!',
     now()-interval'2 days 20 hours', now()-interval'2 days 21 hours'),
    (bot_1, my_uid,'Top! Ci vediamo all''ingresso alle 20',
     now()-interval'2 days 19 hours', now()-interval'2 days 20 hours');

  -- Chat con Alessandro (bot_2) -- 2 messaggi NON LETTI
  INSERT INTO public.messages (sender_id, receiver_id, content, read_at, created_at)
  VALUES
    (my_uid,bot_2, 'Ehi Ale, sabato esci?',
     now()-interval'1 hour', now()-interval'2 hours'),
    (bot_2, my_uid,'Bro ho trovato biglietti per il rave di sabato!',
     NULL, now()-interval'30 minutes'),
    (bot_2, my_uid,'Ci sei o no??? rispondi',
     NULL, now()-interval'5 minutes');

  -- Marco (bot_6): nessun messaggio (testa empty state chat)

  RAISE NOTICE 'Seed completato con successo!';
  RAISE NOTICE 'Bot 1 Martina   -> amica + chat letta';
  RAISE NOTICE 'Bot 2 Alessandro-> amico + 2 msg non letti (badge)';
  RAISE NOTICE 'Bot 3 Giulia    -> richiesta RICEVUTA (accetta/rifiuta)';
  RAISE NOTICE 'Bot 4 Leonardo  -> richiesta INVIATA (in attesa)';
  RAISE NOTICE 'Bot 5 Elena     -> nessuna relazione (Esplora)';
  RAISE NOTICE 'Bot 6 Marco     -> amico confermato, nessun msg';

END $seed$;
