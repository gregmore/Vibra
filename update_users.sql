UPDATE public.users 
SET onboarding_completed = true 
WHERE created_at < NOW() - INTERVAL '1 day';
