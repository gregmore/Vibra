# Implementation roadmap and status

The technical plan for the VIBRA social music platform (spec section 26),
written from an audit of the repository on 2026-11-08. The work was done
in independent, testable phases. Each phase is one or more migrations,
Edge Functions and app screens, each with its own document and tests. This
page records what exists, what each phase changed, which external services
it depends on, how it was verified, and what is still open.

**Status: phases 1–9 are implemented and tested locally. Nothing from this
cycle is deployed or committed** (see [Open items](#open-items)).

## Phase 1 — Audit and architecture

Before the feature work, the repository already had:

- the Flutter app (Riverpod, GoRouter, gen-l10n in 5 languages);
- Supabase auth, chat, friends and follows, events from Ticketmaster;
- Spotify sync, push notifications, reports, the test-data segment, and
  support and legal pages;
- 65 migrations and 16 pgTAP security tests.

Every phase below reuses those structures (see the entity → table map in
[architecture.md](architecture.md)): no parallel tables, no second
notification system, one visibility function per content type. Rules for
every migration (RLS, foreign keys with delete rules, indexes, constraints,
authorization, documentation) are in architecture.md and enforced by
`test/core/schema_audit_test.dart`.

## Phases 2–7: what was built

| Phase | Feature | Database (migration) | Backend (Edge Functions) | App | Doc |
| --- | --- | --- | --- | --- | --- |
| 2 Music intelligence | Smart Music Affinity, Why You Match | 20261107 music_affinity_engine | calculate-match, sync-music-profile, spotify-sync-worker (`_shared/music_affinity.ts`) | `AffinityExplanationCard`, affinity feed | music-affinity-engine.md |
| | Genre normalization | (catalogue in code, no table) | `_shared/genre_catalog.ts` | `core/music/genre_catalog.dart` (one generator: `script/music/build_genre_catalog.py`) | musical-dna.md |
| | Musical DNA | 20261108 musical_dna | `_shared/musical_dna.ts` | Musical DNA screen, `DnaStrip` | musical-dna.md |
| | Same Frequency | 20261109 same_frequency | — | Same Frequency screen, `SameFrequencyCard` | same-frequency.md |
| | Discover My Next Artist | 20261121 artist_discovery | discover-artists | Discover artists, saved artists | artist-discovery.md |
| 3 Social discovery | Music Radar | 20261110 music_radar | — | Music Radar, `MusicRadarMap` | music-radar.md |
| | Musical Communities | 20261111 communities | — | Communities, community, posts, moderation | communities.md |
| | Vibra Circles | 20261112 circles | — | Circles, circle (chat, plans, playlist) | circles.md |
| | Improved user discovery | 20261123 profile_identity (+ existing profile_discovery) | — | Discover users, profile identity | profile-identity.md |
| 4 Concert ecosystem | Smart Concert Finder, event recommendations | 20261113 concert_intelligence | recommend-events, ticketmaster-sync, search-events | Concert Finder | concert-intelligence.md |
| | Who's Going? | 20261114 whos_going | event-reminders | `WhosGoingSection` | whos-going.md |
| | Concert Match | 20261115 concert_match | — | Concert Match, `ConcertMatchCard` | concert-match.md |
| | Concert Groups | 20261112 (circles with `basis = 'concert'`) | — | circle concert header | concert-groups.md |
| 5 Social content | Daily Vibe | 20261116 daily_vibe | daily-vibe | Daily Vibe, Discoveries | daily-vibe.md |
| | Music Stories | 20261117 music_stories | music-stories, media-purge, upload-image | story ring, viewer, composer, `MusicStoryCard` | music-stories.md |
| | Vibra Feed | 20261118 vibra_feed | feed-posts | Feed (for you / following / latest), composer | vibra-feed.md |
| | Track Reactions | 20261119 track_reactions | — | `ReactionChips`, save to Discoveries | track-reactions.md |
| 6 AI and personalization | VIBRA AI | 20261120 vibra_ai | vibra-ai (`_shared/ai/`, optional provider) | assistant screen | vibra-ai.md |
| | Taste Evolution | 20261122 taste_evolution | — | Taste Evolution, `TasteEvolutionChart` | taste-evolution.md |
| | Personalized recommendations | artist, event, feed and same-frequency rankings above | | | |
| 7 Safety and notifications | Notification Center | 20261125 notification_center | `_shared/notification_delivery.ts`, all notification workers | Notification Center, settings, bell | notification-center.md |
| | Privacy controls | `privacy_preferences` columns in each phase | — | privacy controls, profile privacy | safety.md |
| | Moderation and reporting | report columns per content type, hold-for-review, `limit_reports` | — | report flows on every content type | safety.md |
| | Blocking | 20261124 social_safety | — | Safety Center, blocked users | safety.md |
| | Security improvements | 20261126 schema_hardening, 20261127 performance | `spotifyApi` limits, keyset batches | — | architecture.md, performance.md |
| 8 UI/UX polish | components, states, offline, responsive | — | — | `vibra_feature_components.dart` | ui-architecture.md |

## External API dependencies

| Provider | Used by | Requirement before public launch |
| --- | --- | --- |
| Spotify Web API | sync, DNA, affinity, Daily Vibe, stories, feed, artist discovery, AI | Public access (extended quota): the app is still in Development mode with no approval yet — see spotify-public-access-draft-20261014.md. No audio is stored or played. |
| Ticketmaster Discovery API | concert catalogue, search | API key in Edge secrets; 5 pages per query, sync every 6 h |
| Firebase Cloud Messaging | push | service account in Edge secrets |
| Anthropic (optional) | VIBRA AI | `ANTHROPIC_API_KEY`; without it the assistant shows "unavailable" and everything else works |
| OpenStreetMap tiles | Explore map | attribution shown (`VibraOpenStreetMapAttribution`) |

## Phase 9 — Testing (2026-11-08)

All suites were run against the current working tree:

| Suite | Command | Result |
| --- | --- | --- |
| Static analysis | `flutter analyze` | no issues |
| Formatting | `dart format --set-exit-if-changed .` | clean |
| Unit, widget and app integration tests (incl. the IDOR security tests and schema audit) | `flutter test` | 505 passed (7 skipped, as before) |
| Map package | `flutter test` in `packages/flutter_map_marker_cluster` | 9 passed |
| Edge Function tests | `deno test --allow-env --allow-read supabase/functions/_shared/ …` | 129 passed |
| Edge Function type check | `deno check supabase/functions/*/index.ts` | no errors |
| **Migrations from scratch** | `supabase start` on a fresh local project | all 85 migrations apply |
| **RLS and security (pgTAP)** | `supabase test db` | 17 files, 322 assertions, all pass |

`supabase/tests/database/16_social_cycle_test.sql` is the new pgTAP file
for this cycle:

- it calls every new client read as a signed-in user, which catches
  run-time SQL errors that applying a migration cannot;
- it checks that server-only functions refuse clients and that internal
  tables can't be reached;
- it checks that direct writes are refused, that blocks apply across
  follows, the feed, profiles and Same Frequency, that page sizes are
  capped, and the report rules.

**Found and fixed by these runs:**

- **`limit_reports` never ran.** It checked `current_user`, which inside
  a SECURITY DEFINER function is the owner, so duplicate reports and the
  daily report cap were never enforced. It now uses `auth.role()`, and the
  schema audit fails if a definer function ever uses `current_user` again.
- **CI ran only 4 of the Deno test files.** It now runs all of
  `_shared/` plus every function test, including `search-events`, which
  had been skipped.
- **Six icon-only buttons had no accessible label** (chat, accept, decline,
  clear and cancel). Each now has a localized tooltip.

**Not run here:**

- **Native device tests.** `script/security/native/` needs a physical
  device or simulator build. They are listed in
  `docs/manual_testing_checklist.md`.
- **End-to-end runs against hosted Supabase and the real providers.**
  These need the deploy below.

## Open items

1. **Deploy (needs your approval).** Apply 20 migrations, 20261108 to
   20261127, in order, on staging first. Then deploy the 16 Edge
   Functions:
   - new: vibra-ai, discover-artists, feed-posts, music-stories,
     media-purge;
   - changed: daily-vibe, upload-image, send-social-notification,
     recommend-events, ticketmaster-sync, calculate-match,
     sync-music-profile, spotify-sync-worker, send-chat-notification,
     send-notifications, event-reminders, retention-notifications.

   Ship `get_discoveries(p_limit, p_before)` together with the matching
   app build.
2. **Secrets and schedules.** Set `ANTHROPIC_API_KEY` if you want VIBRA
   AI. Check that the Vault entries `vibra_functions_url` and
   `vibra_catalogue_job_secret` exist for the new cron jobs (story and feed
   media purge, notification purge).
3. **Spotify public access.** The app is in Development mode, and Spotify must approve extended quota before a public launch.
4. **Device pass:** run the native harness and the manual checklist on
   iOS and Android, including the new screens and the offline state.
5. **Commit:** nothing from this cycle is committed yet.
