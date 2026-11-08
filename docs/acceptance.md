# Acceptance criteria

The ten criteria from spec section 27, checked feature by feature on
2026-11-08. A feature counts only when every column has evidence: a screen
alone is not enough.

## How each criterion is met and checked

| # | Criterion | How it is met | How it is checked |
| --- | --- | --- | --- |
| 1 | Functional frontend | one screen or component per feature, reachable from the navigation (ui-architecture.md) | screen widget tests |
| 2 | Working backend integration | datasources call real RPCs and Edge Functions; no mock in `lib/` | `test/core/rpc_contract_test.dart`: every app RPC exists with matching parameter names and is granted; every invoked Edge Function exists. pgTAP: every read RPC runs for a signed-in user |
| 3 | Correct database structure | migrations follow architecture.md (foreign keys with delete rules, indexes, constraints) | `schema_audit_test.dart`; all 85 migrations apply from scratch |
| 4 | Appropriate authorization | RLS on every table, SECURITY DEFINER writes with session, limit and visibility checks, server-only functions | pgTAP (17 files, 322 assertions), `security_idor_test.dart`, per-feature guarantee tests |
| 5 | Loading states | `VibraLoadingView` / `VibraLoadingIndicator` on every `AsyncValue` | code audit (ui-architecture.md) |
| 6 | Error handling | `VibraErrorView(error:)` with Retry; offline detected; localized text only | `states` group in each feature screen test |
| 7 | Empty states | `VibraEmptyView` with the next action | `states` group in each feature screen test |
| 8 | Automated tests | Flutter, Deno and pgTAP per feature | matrix below |
| 9 | Documentation | one document per feature, plus architecture, performance, UI and roadmap | matrix below |
| 10 | Integration with existing functionality | reuses existing tables, notifications, reports and blocks | the full suites (implementation-roadmap.md, phase 9) |

## Feature matrix

"States" means the feature's screen test has a `states` group: offline
error with Retry, and empty data. Where noted, a failure followed by Retry
shows the content.

| Feature | Screen / component | Server | Migration | Authorization tests | Feature tests | Doc |
| --- | --- | --- | --- | --- | --- | --- |
| Smart Music Affinity, Why You Match | affinity feed, `AffinityExplanationCard` | calculate-match | 20261107 | pgTAP 15; IDOR | unit/music_affinity, widgets/affinity_explanation_card, Deno music_affinity | music-affinity-engine.md |
| Musical DNA, genre normalization | MusicalDnaScreen | `_shared/musical_dna.ts` | 20261108 | pgTAP 16 | screen (states), domain, Deno musical_dna, genres | musical-dna.md |
| Same Frequency | SameFrequencyScreen | RPCs | 20261109 | pgTAP 16 (blocks) | screen (states, Retry), domain | same-frequency.md |
| Music Radar | MusicRadarScreen, `MusicRadarMap` | RPCs | 20261110 | core/music_radar_privacy, pgTAP 16 | screen (states), components | music-radar.md |
| Communities | CommunitiesScreen, CommunityScreen | RPCs | 20261111 | core/communities_security | screen (states), domain | communities.md |
| Vibra Circles | CirclesScreen, CircleScreen | RPCs | 20261112 | core/circles_consent | screen (states, Retry), domain | circles.md |
| Concert Groups | CircleScreen (concert) | RPCs | 20261112 | core/concert_groups_moderation | screen (states) | concert-groups.md |
| Smart Concert Finder, event recommendations | ConcertFinderScreen | recommend-events, ticketmaster-sync | 20261113 | Deno event_recommendation, ticketmaster | screen, usecase | concert-intelligence.md |
| Who's Going? | `WhosGoingSection` | event-reminders | 20261114 | core/whos_going_privacy | widget, Deno reminder | whos-going.md |
| Concert Match | ConcertMatchScreen, `ConcertMatchCard` | RPCs | 20261115 | core/concert_match_privacy | screen (states) | concert-match.md |
| Daily Vibe | DailyVibeScreen, Discoveries | daily-vibe | 20261116 | core/daily_vibe_licensing, pgTAP 16 | screen (states) | daily-vibe.md |
| Music Stories | story ring, viewer, composer, `MusicStoryCard` | music-stories, media-purge | 20261117 | core/music_stories_privacy, pgTAP 16 | screen, domain, Deno music_stories | music-stories.md |
| Vibra Feed | FeedScreen and post lists | feed-posts | 20261118 | core/vibra_feed_guarantees, pgTAP 16 | screen (states), domain, Deno feed_posts | vibra-feed.md |
| Track Reactions | `ReactionChips`, save song | RPCs | 20261119 | core/track_reactions | widgets/music_reactions | track-reactions.md |
| VIBRA AI | VibraAiScreen | vibra-ai | 20261120 | core/vibra_ai_guarantees | screen (unavailable, error), Deno ai | vibra-ai.md |
| Discover My Next Artist | DiscoverArtistsScreen | discover-artists | 20261121 | core/artist_discovery_guarantees, pgTAP 16 | screen (states), Deno artist_discovery | artist-discovery.md |
| Taste Evolution | TasteEvolutionScreen, `TasteEvolutionChart` | RPC | 20261122 | core/taste_evolution_guarantees | screen (states), domain | taste-evolution.md |
| Profile identity and privacy | profiles, ProfilePrivacyScreen | RPC | 20261123 | core/profile_identity_guarantees | widgets/profile_identity | profile-identity.md |
| Blocking, reporting, moderation | SafetyCenterScreen, report flows | RPCs, triggers | 20261124 | core/social_safety_guarantees, pgTAP 16 (blocks, report limits) | screen (states) | safety.md |
| Notification Center | NotificationCenterScreen, settings | `notification_delivery.ts` and the workers | 20261125 | core/notification_center_guarantees, pgTAP 04/05/16 | screen (states), Deno notification_delivery | notification-center.md |
| Performance, pagination | `VibraPagedList`, keyset batches | `user_batches.ts` | 20261127 | pgTAP 16 (server-only cursors) | core/performance, widgets/vibra_paged_list, Deno user_batches | performance.md |

## Data and integrations

- **No fake production data.**
  - The only rows a migration inserts are the official genre communities.
    They are empty spaces, with no members, posts or activity.
  - Test users and test events are marked `is_test_user` /
    `is_test_data`. RLS keeps them apart from real users (pgTAP 03).
  - The `seed-compatible-users` function was removed earlier; only an
    unused `.npmrc` remains in its folder.
- **Fixtures only in tests.** Fixtures live in `test/`, `integration_test/`
  and pgTAP files, and pgTAP runs inside a transaction that is rolled back.
- **No silent mocks.** `lib/` contains no mock or demo data.
  - A missing provider key returns an explicit
    `503 provider_not_configured`; the app then shows "unavailable" (for
    VIBRA AI, the Spotify pause, the event providers). It never shows
    invented results.
  - Spotify, Ticketmaster, FCM and Anthropic are called for real, and only
    from the server.

## Found while checking

- **The Safety Center hid failures.** If the overview failed to load, it
  silently dropped the status lines. It now shows a compact error with
  Retry, and the links stay usable.
- **Error and empty paths had little coverage.** 13 feature screens now
  have `states` tests: circles, communities, concert groups, concert match,
  Daily Vibe, artist discovery, feed, Musical DNA, Music Radar,
  notifications, Safety Center, Same Frequency and Taste Evolution.
- **Nothing guarded against app–database drift.** `rpc_contract_test.dart`
  now checks every RPC call in the app. A deliberately renamed parameter
  was confirmed to fail it.

## Known limits

- **Loading states are checked in code, not by tests.** Testing them
  would mean holding an animated spinner open, which the widget tests'
  `pumpAndSettle` cannot do. Every screen uses the shared loading views.
- **Device and end-to-end checks are pending.** Runs on physical devices
  and against hosted Supabase and the real providers need the deploy (see
  implementation-roadmap.md, Open items).
