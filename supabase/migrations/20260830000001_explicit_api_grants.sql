-- Supabase projects created with auto_expose_new_tables=false do not add Data
-- API privileges automatically. RLS is evaluated only after the SQL privilege
-- check, so grant the minimum operations used by the app and let the existing
-- policies continue to decide row visibility.

BEGIN;

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- Public/anonymous reads and pre-auth error reporting.
GRANT SELECT ON TABLE public.events, public.service_incidents TO anon;
GRANT SELECT ON TABLE public.event_attendees TO anon;
GRANT INSERT ON TABLE public.auth_errors_log TO anon;

-- Authenticated profile and preference ownership (all constrained by RLS).
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  public.users,
  public.music_profiles,
  public.event_attendees,
  public.friendships,
  public.privacy_preferences,
  public.notification_preferences
TO authenticated;

GRANT SELECT, INSERT, UPDATE ON TABLE public.messages TO authenticated;
GRANT SELECT, INSERT ON TABLE public.live_messages TO authenticated;
GRANT SELECT, UPDATE, DELETE ON TABLE public.notifications TO authenticated;

-- Discovery and read-only calculated state.
GRANT SELECT ON TABLE
  public.users_public,
  public.profile_discovery,
  public.music_profiles_public,
  public.music_profile_discovery,
  public.user_matches,
  public.algorithm_config,
  public.service_incidents,
  public.spotify_connections,
  public.notification_campaigns
TO authenticated;

-- Events can be cached by the client, but only the backend may update an
-- existing canonical event. The RLS insert policy forbids synthetic rows.
GRANT SELECT, INSERT ON TABLE public.events TO authenticated;

-- Social/moderation operations.
GRANT SELECT, INSERT, DELETE ON TABLE
  public.blocked_users,
  public.follows
TO authenticated;
GRANT SELECT, INSERT ON TABLE public.reports TO authenticated;

-- Narrow write-only/read-own features.
GRANT INSERT ON TABLE public.auth_errors_log TO authenticated;
GRANT SELECT, INSERT ON TABLE public.user_interactions_log TO authenticated;
GRANT INSERT ON TABLE public.ticket_clicks TO authenticated;
GRANT INSERT ON TABLE public.support_reports TO authenticated;

-- Trusted Edge Functions and the opt-in seed need complete table access. RLS
-- is bypassed only for the service_role, as intended by Supabase.
GRANT ALL PRIVILEGES ON TABLE
  public.users,
  public.profile_discovery,
  public.users_public,
  public.music_profiles,
  public.music_profile_discovery,
  public.music_profiles_public,
  public.spotify_connections,
  public.events,
  public.event_attendees,
  public.friendships,
  public.messages,
  public.live_messages,
  public.notifications,
  public.user_matches,
  public.blocked_users,
  public.reports,
  public.follows,
  public.privacy_preferences,
  public.notification_preferences,
  public.notification_campaigns,
  public.user_interactions_log,
  public.ticket_clicks,
  public.auth_errors_log,
  public.support_reports,
  public.service_incidents,
  public.algorithm_config
TO service_role;

COMMIT;
