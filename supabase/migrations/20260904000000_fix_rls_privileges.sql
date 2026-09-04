BEGIN;

-- PostgreSQL privileges are checked before row-level security policies. Grant
-- only the operations for which the application already defines RLS policies.
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON TABLE public.event_attendees TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE public.event_attendees TO authenticated;

GRANT SELECT, INSERT ON TABLE public.live_messages TO authenticated;

-- These reads are required by the live_messages policy expressions.
GRANT SELECT ON TABLE public.events, public.users TO authenticated;

-- Attendance is private: authenticated users may only read their own rows.
DROP POLICY IF EXISTS "event_attendees_select_authenticated"
ON public.event_attendees;

CREATE POLICY "event_attendees_select_own"
ON public.event_attendees
FOR SELECT
TO authenticated
USING (user_id = (SELECT auth.uid()));

COMMIT;
