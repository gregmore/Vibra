-- Migration 20260822000002: Follows System, Message Requests and Conversations RPC

-- ─────────────────────────────────────────────────────────────
-- 1. FOLLOWS TABLE & RLS
-- ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.follows (
  follower_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  following_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CONSTRAINT follows_no_self CHECK (follower_id <> following_id)
);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "follows_select_authenticated"
ON public.follows FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "follows_insert_own"
ON public.follows FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "follows_delete_own"
ON public.follows FOR DELETE
TO authenticated
USING (auth.uid() = follower_id);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);

-- ─────────────────────────────────────────────────────────────
-- 2. FOLLOW STATS RPC
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_user_follow_stats(p_user_id uuid)
RETURNS TABLE (
  followers_count bigint,
  following_count bigint,
  is_following boolean,
  is_follower boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM public.follows WHERE following_id = p_user_id) AS followers_count,
    (SELECT COUNT(*) FROM public.follows WHERE follower_id = p_user_id) AS following_count,
    EXISTS(SELECT 1 FROM public.follows WHERE follower_id = auth.uid() AND following_id = p_user_id) AS is_following,
    EXISTS(SELECT 1 FROM public.follows WHERE follower_id = p_user_id AND following_id = auth.uid()) AS is_follower;
END;
$$;

-- ─────────────────────────────────────────────────────────────
-- 3. FOLLOWERS / FOLLOWING LIST RPCs
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_user_followers(p_user_id uuid, p_limit int DEFAULT 50, p_offset int DEFAULT 0)
RETURNS TABLE (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  bio text,
  is_following boolean,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username::text,
    u.display_name,
    u.avatar_url,
    u.bio,
    EXISTS(SELECT 1 FROM public.follows f2 WHERE f2.follower_id = auth.uid() AND f2.following_id = u.id) AS is_following,
    f.created_at
  FROM public.follows f
  JOIN public.users_public u ON u.id = f.follower_id
  WHERE f.following_id = p_user_id
  ORDER BY f.created_at DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_user_following(p_user_id uuid, p_limit int DEFAULT 50, p_offset int DEFAULT 0)
RETURNS TABLE (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  bio text,
  is_following boolean,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username::text,
    u.display_name,
    u.avatar_url,
    u.bio,
    EXISTS(SELECT 1 FROM public.follows f2 WHERE f2.follower_id = auth.uid() AND f2.following_id = u.id) AS is_following,
    f.created_at
  FROM public.follows f
  JOIN public.users_public u ON u.id = f.following_id
  WHERE f.follower_id = p_user_id
  ORDER BY f.created_at DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$;

-- ─────────────────────────────────────────────────────────────
-- 4. CONVERSATIONS & MESSAGE REQUESTS SUMMARY RPC
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_user_conversations()
RETURNS TABLE (
  other_user_id uuid,
  other_username text,
  other_display_name text,
  other_avatar_url text,
  last_message_content text,
  last_message_created_at timestamptz,
  last_message_sender_id uuid,
  unread_count bigint,
  is_friend boolean,
  is_message_request boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  RETURN QUERY
  WITH partner_ids AS (
    SELECT DISTINCT
      CASE WHEN sender_id = v_uid THEN receiver_id ELSE sender_id END AS partner_id
    FROM public.messages
    WHERE (sender_id = v_uid OR receiver_id = v_uid)
      AND NOT (v_uid = ANY(deleted_by))
  ),
  last_msgs AS (
    SELECT DISTINCT ON (partner_id)
      p.partner_id,
      m.id AS msg_id,
      m.content,
      m.created_at,
      m.sender_id
    FROM partner_ids p
    JOIN public.messages m ON (
      (m.sender_id = v_uid AND m.receiver_id = p.partner_id)
      OR (m.sender_id = p.partner_id AND m.receiver_id = v_uid)
    )
    WHERE NOT (v_uid = ANY(m.deleted_by))
    ORDER BY p.partner_id, m.created_at DESC
  ),
  unreads AS (
    SELECT
      m.sender_id AS partner_id,
      COUNT(*) AS unread_count
    FROM public.messages m
    WHERE m.receiver_id = v_uid
      AND m.read_at IS NULL
      AND NOT (v_uid = ANY(m.deleted_by))
    GROUP BY m.sender_id
  ),
  friend_status AS (
    SELECT
      p.partner_id,
      EXISTS (
        SELECT 1 FROM public.friendships f
        WHERE ((f.requester_id = v_uid AND f.receiver_id = p.partner_id)
           OR (f.requester_id = p.partner_id AND f.receiver_id = v_uid))
          AND f.status = 'accepted'
      ) AS are_friends
    FROM partner_ids p
  )
  SELECT
    u.id AS other_user_id,
    u.username::text AS other_username,
    u.display_name AS other_display_name,
    u.avatar_url AS other_avatar_url,
    lm.content AS last_message_content,
    lm.created_at AS last_message_created_at,
    lm.sender_id AS last_message_sender_id,
    COALESCE(un.unread_count, 0) AS unread_count,
    COALESCE(fs.are_friends, false) AS is_friend,
    -- Message request if not friends and current user is receiver of the latest interaction or conversation initiated by other user without friendship
    (COALESCE(fs.are_friends, false) = false AND lm.sender_id != v_uid) AS is_message_request
  FROM last_msgs lm
  JOIN public.users_public u ON u.id = lm.partner_id
  LEFT JOIN unreads un ON un.partner_id = lm.partner_id
  LEFT JOIN friend_status fs ON fs.partner_id = lm.partner_id
  ORDER BY lm.created_at DESC;
END;
$$;
