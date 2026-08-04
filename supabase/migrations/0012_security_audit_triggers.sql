/*
  Vibra — Security Audit Migration
  - IDOR prevention via Column-Level Update Triggers.
  - Ensures users cannot modify immutable data (like message content or sender IDs)
    even if RLS policies allow the row update.
*/

CREATE OR REPLACE FUNCTION public.prevent_immutable_columns_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_TABLE_NAME = 'messages' THEN
    IF NEW.sender_id IS DISTINCT FROM OLD.sender_id OR
       NEW.receiver_id IS DISTINCT FROM OLD.receiver_id OR
       NEW.content IS DISTINCT FROM OLD.content THEN
       RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (sender, receiver, content) in messages.';
    END IF;

  ELSIF TG_TABLE_NAME = 'friendships' THEN
    IF NEW.requester_id IS DISTINCT FROM OLD.requester_id OR
       NEW.receiver_id IS DISTINCT FROM OLD.receiver_id THEN
       RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (requester, receiver) in friendships.';
    END IF;

  ELSIF TG_TABLE_NAME = 'event_attendees' THEN
    IF NEW.event_id IS DISTINCT FROM OLD.event_id OR
       NEW.user_id IS DISTINCT FROM OLD.user_id THEN
       RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (event, user) in event_attendees.';
    END IF;

  ELSIF TG_TABLE_NAME = 'notifications' THEN
    IF NEW.user_id IS DISTINCT FROM OLD.user_id OR
       NEW.title IS DISTINCT FROM OLD.title OR
       NEW.body IS DISTINCT FROM OLD.body OR
       NEW.type IS DISTINCT FROM OLD.type OR
       NEW.data IS DISTINCT FROM OLD.data THEN
       RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns in notifications. Only "read" status can be updated.';
    END IF;

  ELSIF TG_TABLE_NAME = 'user_matches' THEN
    IF NEW.user_id_a IS DISTINCT FROM OLD.user_id_a OR
       NEW.user_id_b IS DISTINCT FROM OLD.user_id_b THEN
       RAISE EXCEPTION 'Vibra Security: Cannot update immutable columns (user_a, user_b) in user_matches.';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_messages_immutable ON public.messages;
CREATE TRIGGER trg_messages_immutable 
BEFORE UPDATE ON public.messages 
FOR EACH ROW EXECUTE FUNCTION public.prevent_immutable_columns_update();

DROP TRIGGER IF EXISTS trg_friendships_immutable ON public.friendships;
CREATE TRIGGER trg_friendships_immutable 
BEFORE UPDATE ON public.friendships 
FOR EACH ROW EXECUTE FUNCTION public.prevent_immutable_columns_update();

DROP TRIGGER IF EXISTS trg_event_attendees_immutable ON public.event_attendees;
CREATE TRIGGER trg_event_attendees_immutable 
BEFORE UPDATE ON public.event_attendees 
FOR EACH ROW EXECUTE FUNCTION public.prevent_immutable_columns_update();

DROP TRIGGER IF EXISTS trg_notifications_immutable ON public.notifications;
CREATE TRIGGER trg_notifications_immutable 
BEFORE UPDATE ON public.notifications 
FOR EACH ROW EXECUTE FUNCTION public.prevent_immutable_columns_update();

DROP TRIGGER IF EXISTS trg_user_matches_immutable ON public.user_matches;
CREATE TRIGGER trg_user_matches_immutable 
BEFORE UPDATE ON public.user_matches 
FOR EACH ROW EXECUTE FUNCTION public.prevent_immutable_columns_update();

COMMIT;
