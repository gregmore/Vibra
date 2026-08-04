ALTER TABLE music_profiles ADD COLUMN IF NOT EXISTS top_genres jsonb not null default '[]'::jsonb;
ALTER TABLE music_profiles ADD COLUMN IF NOT EXISTS top_tracks jsonb not null default '[]'::jsonb;
