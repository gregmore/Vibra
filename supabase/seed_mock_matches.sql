-- Istruzioni:
-- 1. Vai nella tua dashboard Supabase (https://supabase.com/dashboard)
-- 2. Vai nella sezione SQL Editor e crea una nuova query
-- 3. Sostituisci la stringa 'INSERISCI_QUI_IL_TUO_USER_ID' alla riga 7 con il tuo vero user_id (lo trovi nella sezione Authentication -> Users)
-- 4. Esegui la query (Run)

DO $$ 
DECLARE
  my_uid uuid := 'INSERISCI_QUI_IL_TUO_USER_ID'; -- <=== INSERISCI QUI IL TUO ID
  
  mock_id_1 uuid := '11111111-1111-1111-1111-111111111111';
  mock_id_2 uuid := '22222222-2222-2222-2222-222222222222';
  mock_id_3 uuid := '33333333-3333-3333-3333-333333333333';
BEGIN
  -- Esci se l'utente non ha modificato l'ID
  IF my_uid = 'INSERISCI_QUI_IL_TUO_USER_ID' THEN
    RAISE EXCEPTION 'Devi inserire il tuo user_id reale alla riga 7!';
  END IF;

  -- 1. Inserisci in auth.users se non esistono
  INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
  VALUES 
    (mock_id_1, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mock1@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now()),
    (mock_id_2, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mock2@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now()),
    (mock_id_3, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mock3@vibra.app', '', now(), '{"provider": "email", "providers": ["email"]}', '{}', now(), now())
  ON CONFLICT (id) DO NOTHING;

  -- 2. Inserisci in public.users
  INSERT INTO public.users (id, email, username, display_name, avatar_url, bio, last_latitude, last_longitude, last_location)
  VALUES 
    (mock_id_1, 'mock1@vibra.app', 'mock1_user', 'Giulia Rossi', 'https://i.pravatar.cc/150?u=mock1', 'Amo la musica indie e i concerti live!', 45.4642, 9.1900, ST_SetSRID(ST_MakePoint(9.1900, 45.4642), 4326)::geography),
    (mock_id_2, 'mock2@vibra.app', 'mock2_user', 'Marco Bianchi', 'https://i.pravatar.cc/150?u=mock2', 'Elettronica, techno e festival in giro per l''Europa.', 45.4700, 9.1850, ST_SetSRID(ST_MakePoint(9.1850, 45.4700), 4326)::geography),
    (mock_id_3, 'mock3@vibra.app', 'mock3_user', 'Ale Verdi', 'https://i.pravatar.cc/150?u=mock3', 'Sempre alla ricerca di nuovi artisti emergenti.', 45.4500, 9.2000, ST_SetSRID(ST_MakePoint(9.2000, 45.4500), 4326)::geography)
  ON CONFLICT (id) DO UPDATE SET 
    last_latitude = EXCLUDED.last_latitude, 
    last_longitude = EXCLUDED.last_longitude,
    last_location = EXCLUDED.last_location;

  -- 3. Inserisci in public.music_profiles
  INSERT INTO public.music_profiles (user_id, top_artists, top_genres, top_tracks, last_synced_at)
  VALUES 
    (mock_id_1, '[{"id": "fred", "name": "Fred again..", "imageUrl": ""}]', '[{"name": "indie pop", "count": 10}]', '[]', now()),
    (mock_id_2, '[{"id": "daft", "name": "Daft Punk", "imageUrl": ""}]', '[{"name": "techno", "count": 15}]', '[]', now()),
    (mock_id_3, '[{"id": "arctic", "name": "Arctic Monkeys", "imageUrl": ""}]', '[{"name": "rock", "count": 8}]', '[]', now())
  ON CONFLICT (user_id) DO NOTHING;

  -- 4. Inserisci i match finti con il tuo utente
  -- Elimina prima eventuali match precedenti con questi mock
  DELETE FROM public.user_matches WHERE (user_id_a = my_uid OR user_id_b = my_uid) AND (user_id_a IN (mock_id_1, mock_id_2, mock_id_3) OR user_id_b IN (mock_id_1, mock_id_2, mock_id_3));

  INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility, shared_artists, shared_genres)
  VALUES
    (my_uid, mock_id_1, 92.5, 3, 5),
    (my_uid, mock_id_2, 85.0, 1, 4),
    (my_uid, mock_id_3, 78.2, 0, 2);

END $$;
