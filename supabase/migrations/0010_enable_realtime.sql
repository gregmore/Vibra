-- Migration 0010: Enable Realtime for chat

BEGIN;

-- La publication supabase_realtime di solito esiste già in Supabase. 
-- In locale o in test potrebbe non esistere, quindi la creiamo in modo safe.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
END
$$;

-- Aggiungiamo le tabelle messaggi alla publication per abilitare le sottoscrizioni realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.live_messages;

COMMIT;
