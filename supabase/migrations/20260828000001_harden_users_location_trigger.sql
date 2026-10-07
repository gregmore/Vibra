-- Trigger functions are not RPC endpoints. Prevent direct client execution
-- while keeping the location synchronization trigger available to the table.
REVOKE ALL ON FUNCTION public.users_sync_last_location()
FROM PUBLIC, anon, authenticated;
