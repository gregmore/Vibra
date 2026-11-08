# VIBRA technical architecture

The reference for how VIBRA is built (spec section 23): stack, data model,
security model, provider integrations and migration rules. Each feature has
its own document, linked below.

## Stack

| Layer | Technology |
| --- | --- |
| App | Flutter, Riverpod, GoRouter, gen-l10n (en, it, es, fr, de) |
| Backend | Supabase: Postgres with RLS, Auth (PKCE), Storage, Edge Functions (Deno), pg_cron + pg_net, Vault |
| Providers | Spotify Web API, Ticketmaster Discovery API, Firebase Cloud Messaging, Anthropic (optional, VIBRA AI) |

The layers inside the app:

```
lib/
  domain/entities        plain Dart models (no Supabase types)
  data/datasources       Supabase calls (tables under RLS, RPCs, Edge Functions)
  presentation/providers Riverpod state
  presentation/widgets   reusable components (ui-architecture.md)
  presentation/screens   UI
supabase/
  migrations             schema, RLS, functions (applied in filename order)
  functions/_shared      server logic shared by Edge Functions (tested with Deno)
  functions/<name>       one Edge Function per integration or job
```

## Conceptual entities → actual tables

Nothing was duplicated: each conceptual entity maps to the existing table
that already holds that data.

| Conceptual entity | Table(s) | Notes |
| --- | --- | --- |
| user_music_profiles | `music_profiles` (+ `musical_dna_snapshots`) | Spotify sync results; DNA snapshots are the daily history |
| user_genre_preferences | `user_genre_preferences` | picked genres (catalogue keys) |
| music_genres | none: a versioned catalogue in code | `lib/core/music/genre_catalog.dart` and `_shared/genre_catalog.ts`, generated from one source (`script/music/build_genre_catalog.py`); static reference data needs no table |
| music_affinities | `user_matches` | one row per pair (`user_id_a < user_id_b`) |
| music_affinity_explanations | `user_matches.details` (jsonb) + `affinity_dismissals` | the explanation is computed with the score and stored with it |
| musical_communities | `communities` | |
| community_members | `community_members` (+ `community_bans`) | |
| community_posts | `community_posts`, `community_comments`, `community_reactions` | |
| vibra_circles | `circles` | |
| circle_members | `circle_members` (+ `circle_invitations`, `circle_bans`) | membership only by accepted invitation |
| events | `events` | catalogue (Ticketmaster and others), written server-side only |
| event_participants | `event_attendees` | status and per-attendance visibility (Who's Going) |
| concert_groups | `circles` with `basis = 'concert'` (+ `circle_plans`, `circle_events`) | a concert group is a circle about one event |
| daily_vibes | `daily_vibes`, `daily_vibe_reactions`, `daily_vibe_comments` | |
| music_stories | `music_stories` (+ views, reactions, replies, settings) | |
| feed_posts | `feed_posts`, `feed_comments`, `feed_bookmarks`, `feed_impressions` | |
| post_reactions | `feed_post_reactions`, `community_reactions`, `daily_vibe_reactions`, `music_story_reactions` | kept per content type: each has a different visibility rule and reaction set (see track-reactions.md) |
| artist_recommendations | `artist_recommendations` + `artist_feedback` | |
| music_discoveries | `discovery_collection` | saved songs from every song share |
| user_notifications | `notifications` (+ `notification_preferences`, `users.push_settings`) | |

Supporting tables: `profile_discovery` (public profile fields),
`privacy_preferences` (every privacy switch), `blocked_users`, `reports`,
`follows`, `friendships`, `saved_profiles`, `spotify_connections` (encrypted
tokens). The `vibra_private` schema holds internal state; it is not exposed
through the API: `action_limits`, quotas and logs, radar presence.

## Security model

- **RLS on every public table.** Owner-only tables (settings, bookmarks,
  feedback, impressions, saved songs, blocks) read `user_id = auth.uid()`.
  Social content uses one visibility function per feature
  (`can_see_daily_vibe`, `can_see_music_story`, `can_see_feed_post`,
  `is_circle_member`, …). All of them include `may_access_message`, which
  covers blocks and test segments.
- **Writes go through functions.** Clients mostly have SELECT only. Writes
  use SECURITY DEFINER RPCs that re-check visibility, rate limits
  (`consume_action_limit`) and spam rules. Server-only writes
  (`create_*`, `save_*`, `record_notification`) require the service role.
- **Identity always comes from the session** (`auth.uid()`), never from
  parameters (see the IDOR tests).
- **No private data in client queries.** The app reads only its own `users`
  row. Other people come through `profile_discovery` and purpose-built
  functions that apply the owner's section visibility.
- **Blocks apply everywhere** (safety.md). **Moderation:** report triggers,
  hold-for-review, community and circle moderators.
- **Storage:** private buckets (`chat-media`, `story-media`, `feed-media`,
  `support-attachments`) are written only by `upload-image`, which re-encodes
  images and strips EXIF. Files can be read only while the content that
  uses them is visible. A worker removes orphaned files.

## Secrets and provider integrations

| Provider | Where | Credentials | Limits respected |
| --- | --- | --- | --- |
| Spotify (user data) | `spotify-token-exchange`, `sync-music-profile`, `spotify-sync-worker` | PKCE in the app; refresh tokens AES-GCM encrypted in `spotify_connections`, never returned to clients | `_shared/spotify_api.ts`: Retry-After on 429, refresh on 401, hourly sync |
| Spotify (catalogue) | `daily-vibe`, `music-stories`, `feed-posts`, `discover-artists`, `vibra-ai` | app client-credentials token, server only | per-user rate limits; discovery cached 12 h; short Retry-After honoured once, otherwise degrade (`spotifyApi`) |
| Ticketmaster | `ticketmaster-sync`, `search-events` | API key in Edge secrets | 5 pages per query, sync every 6 h, results cached |
| FCM | `_shared/fcm.ts` via `notification_delivery.ts` | Firebase service account (Edge secrets) | one delivery policy: preferences, quiet hours, daily caps |
| Anthropic (optional) | `vibra-ai` | `ANTHROPIC_API_KEY` (Edge secrets) | consent-gated; 6/min and 40/day per user |

**Rules:**

- The app's `.env` contains only public values (Supabase URL and anon key,
  OAuth client ids). Every secret is in Supabase secrets or Vault.
- Edge Functions that are jobs authenticate with a dedicated job secret
  (`x-vibra-job-secret`).
- Spotify restrictions are respected: no audio or previews are stored or
  played, artwork is linked from Spotify's CDN, Spotify items carry its
  attribution, and the deprecated recommendations, related-artists and
  audio-features endpoints are not used.

## Migration rules

Every migration in this repository should:

1. **Reuse existing tables**: add columns instead of creating parallel
   structures (as reports, notifications and discovery_collection did).
2. **Foreign keys** with an explicit `ON DELETE` (`CASCADE` for owned data,
   `SET NULL` for references that may outlive their target).
3. **Index every foreign-key column** (partial indexes for nullable ones), plus
   the columns used by feeds and limits. `20261126000000_schema_hardening.sql`
   added the ones that were missing. `test/core/schema_audit_test.dart`
   checks new migrations. Paged lists get a `(user_id, time DESC)` index
   and a keyset cursor (performance.md).
4. **Constraints**: CHECK on enums, lengths and invariants; UNIQUE where
   the domain requires it.
5. **RLS**: enabled on every public table; REVOKE ALL, then GRANT only what
   is needed.
6. **Authorization**: `require_active_session()`, `auth.uid()`, a rate limit,
   and a visibility re-check in every SECURITY DEFINER write;
   `SET search_path = pg_catalog`.
7. **Personal data**: add new user data to `export_my_personal_data()`;
   deletion follows from the cascades.
8. **Documentation**: a header comment in the migration and a document in
   `docs/`.

## Migrations from this development cycle (not yet applied)

| Migration | Document |
| --- | --- |
| 20261108 musical_dna | musical-dna.md |
| 20261109 same_frequency | same-frequency.md |
| 20261110 music_radar | music-radar.md |
| 20261111 communities | communities.md |
| 20261112 circles | circles.md, concert-groups.md |
| 20261113 concert_intelligence | concert-intelligence.md |
| 20261114 whos_going | whos-going.md |
| 20261115 concert_match | concert-match.md |
| 20261116 daily_vibe | daily-vibe.md |
| 20261117 music_stories | music-stories.md |
| 20261118 vibra_feed | vibra-feed.md |
| 20261119 track_reactions | track-reactions.md |
| 20261120 vibra_ai | vibra-ai.md |
| 20261121 artist_discovery | artist-discovery.md |
| 20261122 taste_evolution | taste-evolution.md |
| 20261123 profile_identity | profile-identity.md |
| 20261124 social_safety | safety.md |
| 20261125 notification_center | notification-center.md |
| 20261126 schema_hardening | this document |
| 20261127 performance | performance.md |

Apply them in order, on a staging project first.
