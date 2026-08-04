-- Migration: 0008_fix_delete_user.sql
-- Description: Fix recursion on user deletion by removing the trigger on public.users. Deleting from auth.users cascades to public.users automatically.

-- 1. Drop the trigger that causes recursion
DROP TRIGGER IF EXISTS trg_delete_auth_user ON public.users;

-- 2. Drop the trigger function
DROP FUNCTION IF EXISTS public.delete_auth_user_on_profile_delete();

-- 3. Replace the delete_user_account function to just delete auth.users 
-- (this will cascade down to public.users because of the ON DELETE CASCADE constraint)
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;
