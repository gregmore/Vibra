-- Resolve Supabase Advisor findings without weakening profile isolation.
-- Public-facing views read from explicitly safe projections, not public.users.

BEGIN;

-- `spatial_ref_sys` belongs to the PostGIS extension (`supabase_admin`), not
-- to the migration role. On existing projects PostgreSQL therefore rejects an
-- RLS change here. It contains only public coordinate-system metadata and is
-- not exposed to the Data API because no API grants are made for it. New
-- Supabase projects install PostGIS into the extensions schema. See the
-- production runbook for the one-off owner-level remediation of this legacy
-- extension object.

CREATE TABLE IF NOT EXISTS public.profile_discovery (
  id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  username citext,
  display_name text,
  avatar_url text,
  bio text,
  spotify_id text,
  onboarding_completed boolean NOT NULL DEFAULT false,
  onboarding_step text,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL
);
ALTER TABLE public.profile_discovery ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "profile_discovery_authenticated_read" ON public.profile_discovery;
CREATE POLICY "profile_discovery_authenticated_read"
ON public.profile_discovery FOR SELECT TO authenticated USING (true);

INSERT INTO public.profile_discovery (
  id, username, display_name, avatar_url, bio, spotify_id,
  onboarding_completed, onboarding_step, created_at, updated_at
)
SELECT id, username, display_name, avatar_url, bio, spotify_id,
       onboarding_completed, onboarding_step, created_at, updated_at
FROM public.users
ON CONFLICT (id) DO UPDATE SET
  username = EXCLUDED.username,
  display_name = EXCLUDED.display_name,
  avatar_url = EXCLUDED.avatar_url,
  bio = EXCLUDED.bio,
  spotify_id = EXCLUDED.spotify_id,
  onboarding_completed = EXCLUDED.onboarding_completed,
  onboarding_step = EXCLUDED.onboarding_step,
  updated_at = EXCLUDED.updated_at;

CREATE OR REPLACE FUNCTION public.sync_profile_discovery()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  INSERT INTO public.profile_discovery (
    id, username, display_name, avatar_url, bio, spotify_id,
    onboarding_completed, onboarding_step, created_at, updated_at
  ) VALUES (
    NEW.id, NEW.username, NEW.display_name, NEW.avatar_url, NEW.bio, NEW.spotify_id,
    NEW.onboarding_completed, NEW.onboarding_step, NEW.created_at, NEW.updated_at
  ) ON CONFLICT (id) DO UPDATE SET
    username = EXCLUDED.username, display_name = EXCLUDED.display_name,
    avatar_url = EXCLUDED.avatar_url, bio = EXCLUDED.bio, spotify_id = EXCLUDED.spotify_id,
    onboarding_completed = EXCLUDED.onboarding_completed,
    onboarding_step = EXCLUDED.onboarding_step, updated_at = EXCLUDED.updated_at;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_users_sync_profile_discovery ON public.users;
CREATE TRIGGER trg_users_sync_profile_discovery
AFTER INSERT OR UPDATE OF username, display_name, avatar_url, bio, spotify_id,
  onboarding_completed, onboarding_step ON public.users
FOR EACH ROW EXECUTE FUNCTION public.sync_profile_discovery();
REVOKE ALL ON FUNCTION public.sync_profile_discovery() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE VIEW public.users_public
WITH (security_invoker = true)
AS SELECT * FROM public.profile_discovery;
REVOKE ALL ON TABLE public.users_public FROM PUBLIC;
GRANT SELECT ON TABLE public.users_public TO authenticated;

CREATE TABLE IF NOT EXISTS public.music_profile_discovery (
  user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  top_artists jsonb NOT NULL DEFAULT '[]'::jsonb,
  top_genres jsonb NOT NULL DEFAULT '[]'::jsonb,
  listening_heatmap jsonb,
  last_synced_at timestamptz
);
ALTER TABLE public.music_profile_discovery ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "music_profile_discovery_authenticated_read" ON public.music_profile_discovery;
CREATE POLICY "music_profile_discovery_authenticated_read"
ON public.music_profile_discovery FOR SELECT TO authenticated USING (true);

INSERT INTO public.music_profile_discovery (user_id, top_artists, top_genres, listening_heatmap, last_synced_at)
SELECT user_id, top_artists, top_genres, listening_heatmap, last_synced_at
FROM public.music_profiles
ON CONFLICT (user_id) DO UPDATE SET
  top_artists = EXCLUDED.top_artists, top_genres = EXCLUDED.top_genres,
  listening_heatmap = EXCLUDED.listening_heatmap, last_synced_at = EXCLUDED.last_synced_at;

CREATE OR REPLACE FUNCTION public.sync_music_profile_discovery()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
  INSERT INTO public.music_profile_discovery (user_id, top_artists, top_genres, listening_heatmap, last_synced_at)
  VALUES (NEW.user_id, NEW.top_artists, NEW.top_genres, NEW.listening_heatmap, NEW.last_synced_at)
  ON CONFLICT (user_id) DO UPDATE SET
    top_artists = EXCLUDED.top_artists, top_genres = EXCLUDED.top_genres,
    listening_heatmap = EXCLUDED.listening_heatmap, last_synced_at = EXCLUDED.last_synced_at;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_music_profiles_sync_discovery ON public.music_profiles;
CREATE TRIGGER trg_music_profiles_sync_discovery
AFTER INSERT OR UPDATE OF top_artists, top_genres, listening_heatmap, last_synced_at ON public.music_profiles
FOR EACH ROW EXECUTE FUNCTION public.sync_music_profile_discovery();
REVOKE ALL ON FUNCTION public.sync_music_profile_discovery() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE VIEW public.music_profiles_public
WITH (security_invoker = true)
AS SELECT * FROM public.music_profile_discovery;
REVOKE ALL ON TABLE public.music_profiles_public FROM PUBLIC;
GRANT SELECT ON TABLE public.music_profiles_public TO authenticated;

COMMIT;
