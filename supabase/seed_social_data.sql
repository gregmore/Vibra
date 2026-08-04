DO $$ 
DECLARE
  my_uid uuid; 
  bot_marco uuid := '287cec0c-635a-4d43-b6c6-c197c619700e';
  bot_sofia uuid := '27d41cbb-944a-4f1b-86df-544301b45105';
  bot_luca uuid := '8e6d114a-d341-4e9e-97de-284fe8e90933';
  bot_alessia uuid := 'e7460cb2-f280-46ce-82a8-5057a76849e8';
  bot_chiara uuid := '0c341445-4a36-4609-ab2c-00aca8b615d2';
  bot_davide uuid := '6fafaf58-eebe-42d5-b0d6-eabd83b21233';
BEGIN

  -- Trova automaticamente il TUO ID utente (escludendo i bot in base all'email)
  SELECT id INTO my_uid 
  FROM public.users 
  WHERE email NOT LIKE '%@vibra.local' AND email NOT LIKE '%@vibra.app'
  LIMIT 1;

  IF my_uid IS NULL THEN
    RAISE EXCEPTION 'Non ho trovato il tuo utente nel database! Sicuro di aver fatto il login nell''app?';
  END IF;

  -- 1. Imposta la posizione per tutti i bot (vicino a Milano)
  UPDATE public.users 
  SET 
    last_latitude = 45.4642 + (random() * 0.05 - 0.025),
    last_longitude = 9.1900 + (random() * 0.05 - 0.025),
    last_location = ST_SetSRID(ST_MakePoint(9.1900 + (random() * 0.05 - 0.025), 45.4642 + (random() * 0.05 - 0.025)), 4326)::geography
  WHERE id IN (bot_marco, bot_sofia, bot_luca, bot_alessia, bot_chiara, bot_davide);

  -- 2. Affinità (user_matches)
  DELETE FROM public.user_matches WHERE (user_id_a = my_uid OR user_id_b = my_uid);
  
  INSERT INTO public.user_matches (user_id_a, user_id_b, compatibility, shared_artists, shared_genres)
  VALUES
    (LEAST(my_uid, bot_marco), GREATEST(my_uid, bot_marco), 92.5, 3, 5),
    (LEAST(my_uid, bot_sofia), GREATEST(my_uid, bot_sofia), 85.0, 1, 4),
    (LEAST(my_uid, bot_luca), GREATEST(my_uid, bot_luca), 65.2, 0, 2),
    (LEAST(my_uid, bot_alessia), GREATEST(my_uid, bot_alessia), 78.4, 2, 3),
    (LEAST(my_uid, bot_chiara), GREATEST(my_uid, bot_chiara), 88.9, 4, 6),
    (LEAST(my_uid, bot_davide), GREATEST(my_uid, bot_davide), 95.1, 5, 8)
  ON CONFLICT DO NOTHING;

  -- 3. Amicizie (friendships)
  DELETE FROM public.friendships WHERE (requester_id = my_uid OR receiver_id = my_uid);
  
  INSERT INTO public.friendships (requester_id, receiver_id, status, created_at)
  VALUES
    (bot_marco, my_uid, 'accepted', now() - interval '2 days'), -- Marco è già amico
    (my_uid, bot_sofia, 'accepted', now() - interval '5 hours'), -- Sofia è già amica
    (bot_alessia, my_uid, 'pending', now() - interval '1 hour'),   -- Alessia ti ha inviato una richiesta
    (my_uid, bot_chiara, 'pending', now() - interval '3 hours');  -- Tu hai inviato una richiesta a Chiara

  -- 4. Messaggi (messages)
  DELETE FROM public.messages WHERE (sender_id = my_uid OR receiver_id = my_uid);
  
  -- Chat con Marco (Letta)
  INSERT INTO public.messages (sender_id, receiver_id, content, read_at, created_at)
  VALUES
    (bot_marco, my_uid, 'Ehi ciao! Ho visto che ascolti tanta musica Indie!', now() - interval '1 day', now() - interval '1 day'),
    (my_uid, bot_marco, 'Ciao! Sì, andiamo allo stesso concerto settimana prossima?', now() - interval '23 hours', now() - interval '23 hours'),
    (bot_marco, my_uid, 'Assolutamente! Ci organizziamo!', now() - interval '22 hours', now() - interval '22 hours');

  -- Chat con Sofia (Non letta, per mostrare il badge di notifica)
  INSERT INTO public.messages (sender_id, receiver_id, content, read_at, created_at)
  VALUES
    (bot_sofia, my_uid, 'Ehi, hai sentito il nuovo pezzo di Peggy Gou?', NULL, now() - interval '5 minutes'),
    (bot_sofia, my_uid, 'È una hit pazzesca 🎧🔥', NULL, now() - interval '2 minutes');

END $$;
