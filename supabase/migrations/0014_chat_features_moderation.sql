-- 1. Aggiornamento tabella messages
ALTER TABLE public.messages
ADD COLUMN IF NOT EXISTS message_type text NOT NULL DEFAULT 'text',
ADD COLUMN IF NOT EXISTS metadata jsonb,
ADD COLUMN IF NOT EXISTS reactions jsonb,
ADD COLUMN IF NOT EXISTS deleted_by uuid[] DEFAULT '{}';

-- Check constraint per i tipi di messaggio consentiti
ALTER TABLE public.messages
ADD CONSTRAINT valid_message_type CHECK (message_type IN ('text', 'image', 'event_share', 'meetup_proposal'));

-- 2. Nuova tabella per gli utenti bloccati
CREATE TABLE IF NOT EXISTS public.blocked_users (
  blocker_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  blocked_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id)
);

-- RLS per blocked_users
ALTER TABLE public.blocked_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own blocks"
ON public.blocked_users FOR SELECT
USING (auth.uid() = blocker_id OR auth.uid() = blocked_id);

CREATE POLICY "Users can block others"
ON public.blocked_users FOR INSERT
WITH CHECK (auth.uid() = blocker_id);

CREATE POLICY "Users can unblock"
ON public.blocked_users FOR DELETE
USING (auth.uid() = blocker_id);

-- 3. Nuova tabella per le segnalazioni
CREATE TABLE IF NOT EXISTS public.reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reported_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  message_id uuid REFERENCES public.messages(id) ON DELETE CASCADE,
  reason text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'action_taken')),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- RLS per reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create reports"
ON public.reports FOR INSERT
WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can view their own reports"
ON public.reports FOR SELECT
USING (auth.uid() = reporter_id);

-- 4. Triggers di moderazione
-- A. Blocca invio se uno dei due ha bloccato l'altro
CREATE OR REPLACE FUNCTION public.check_block_before_message()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.blocked_users
    WHERE (blocker_id = NEW.sender_id AND blocked_id = NEW.receiver_id)
       OR (blocker_id = NEW.receiver_id AND blocked_id = NEW.sender_id)
  ) THEN
    RAISE EXCEPTION 'Cannot send message. A block exists between the users.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_check_block_before_message ON public.messages;
CREATE TRIGGER tr_check_block_before_message
BEFORE INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.check_block_before_message();

-- B. First contact limiter: impedisce spam (più di 3 messaggi) verso uno sconosciuto
CREATE OR REPLACE FUNCTION public.first_contact_limiter()
RETURNS TRIGGER AS $$
DECLARE
  replies_count int;
  sent_count int;
BEGIN
  -- Conta quante risposte il receiver ha mai inviato al sender
  SELECT COUNT(*) INTO replies_count
  FROM public.messages
  WHERE sender_id = NEW.receiver_id AND receiver_id = NEW.sender_id;

  IF replies_count = 0 THEN
    -- Conta quanti messaggi ha mandato finora il sender
    SELECT COUNT(*) INTO sent_count
    FROM public.messages
    WHERE sender_id = NEW.sender_id AND receiver_id = NEW.receiver_id;

    IF sent_count >= 3 THEN
      RAISE EXCEPTION 'Cannot send more than 3 messages before receiving a reply.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_first_contact_limiter ON public.messages;
CREATE TRIGGER tr_first_contact_limiter
BEFORE INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.first_contact_limiter();

-- C. Filtro contenuti base (Anti-spam / Anti-malware links)
CREATE OR REPLACE FUNCTION public.content_filter()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.message_type = 'text' THEN
    -- Simple block for common suspicious links or extremely bad words
    -- In a real scenario, this regex would be much larger
    IF NEW.content ~* '(http|https)://.*(ngrok|bit\.ly|tinyurl|free-money|adult|casino|scam)' THEN
      RAISE EXCEPTION 'Message blocked by content filter: suspicious link detected.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_content_filter ON public.messages;
CREATE TRIGGER tr_content_filter
BEFORE INSERT OR UPDATE ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.content_filter();

-- 5. RPC Functions per Soft Delete e Reazioni
CREATE OR REPLACE FUNCTION public.soft_delete_chat(p_user_id uuid, p_other_user_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.messages
  SET deleted_by = array_append(deleted_by, p_user_id)
  WHERE (sender_id = p_user_id AND receiver_id = p_other_user_id)
     OR (sender_id = p_other_user_id AND receiver_id = p_user_id)
    AND NOT (p_user_id = ANY(deleted_by));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.react_to_message(p_message_id uuid, p_user_id uuid, p_reaction text)
RETURNS void AS $$
BEGIN
  UPDATE public.messages
  SET reactions = COALESCE(reactions, '{}'::jsonb) || jsonb_build_object(p_user_id::text, p_reaction)
  WHERE id = p_message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
