BEGIN;
-- All client erasure requests must pass through the Storage-aware gateway.
REVOKE ALL ON FUNCTION public.delete_user_account() FROM PUBLIC,anon,authenticated;
-- Geographic reference metadata is used by backend SQL, not a client API.
REVOKE ALL ON TABLE public.spatial_ref_sys FROM anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.st_estimatedextent(text,text) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.st_estimatedextent(text,text,text) FROM PUBLIC,anon,authenticated;
REVOKE EXECUTE ON FUNCTION public.st_estimatedextent(text,text,text,boolean) FROM PUBLIC,anon,authenticated;
NOTIFY pgrst,'reload schema';
COMMIT;
