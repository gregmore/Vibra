-- Migration: 0007_delete_user_account.sql
-- Description: Adds RPC to delete auth.users and trigger to sync public.users deletion to auth.users

-- 1. Create a function that deletes the current user from auth.users
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Delete the user from auth.users. 
  -- Due to ON DELETE CASCADE on public.users(id), this will also delete the public profile and related data.
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- 2. Create a function and trigger to delete auth.users when public.users is deleted
CREATE OR REPLACE FUNCTION public.delete_auth_user_on_profile_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Delete the corresponding auth.users row
  DELETE FROM auth.users WHERE id = OLD.id;
  RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS trg_delete_auth_user ON public.users;
CREATE TRIGGER trg_delete_auth_user
AFTER DELETE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.delete_auth_user_on_profile_delete();
