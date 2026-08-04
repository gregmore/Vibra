-- Funzione per trovare gli utenti compatibili usando pgvector
create or replace function public.find_compatible_users(
  p_user_id uuid,
  p_embedding vector(10),
  p_limit int default 50
)
returns table (
  user_id uuid,
  distance float,
  top_artists jsonb,
  top_genres jsonb
)
language plpgsql
security definer
as $$
begin
  return query
  select 
    m.user_id,
    -- distance is the cosine distance
    (m.embedding <-> p_embedding) as distance,
    m.top_artists,
    m.top_genres
  from public.music_profiles m
  where m.user_id != p_user_id
    and m.embedding is not null
  order by m.embedding <-> p_embedding
  limit p_limit;
end;
$$;
