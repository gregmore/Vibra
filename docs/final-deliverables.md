# VIBRA social music platform: final deliverables

The closing report for the implementation (spec section 28), written
2026-11-08 from the working tree and the test runs of that day.

> **Status at a glance.** All features of the spec are implemented in code
> and pass their tests locally, including a run of all migrations and the
> security suite on a real local Postgres. **Nothing is deployed and
> nothing is committed.** No feature is only a visual prototype, but
> several depend on external credentials or scheduled jobs before they work
> for real users (sections 13–14).

## 1. Repository architecture

- **App:** Flutter, layered as
  `domain/entities → data/datasources → presentation/providers →
  presentation/screens`.
  - State management is Riverpod; navigation is GoRouter with a
    five-tab `StatefulShellRoute`.
  - Localization is gen-l10n in en, it, es, fr and de.
  - Reusable components are in `lib/presentation/widgets`, exported
    together by `vibra_feature_components.dart`.
- **Backend:** Supabase.
  - Postgres with RLS on every public table. Writes go through
    SECURITY DEFINER functions, and internal state lives in the private
    `vibra_private` schema.
  - Edge Functions in Deno, with shared and tested logic in
    `supabase/functions/_shared`.
  - Scheduled jobs use pg_cron and pg_net, with secrets in Vault.
  - Private Storage buckets for media.
- **Design rules:**
  - Reuse existing tables, with one visibility function per content type.
  - One notification policy (`record_notification`).
  - Identity always comes from the session.
  - Provider credentials stay on the server only.

  Details are in [architecture.md](architecture.md),
  [ui-architecture.md](ui-architecture.md) and
  [performance.md](performance.md).

## 2. Implemented features

Each feature has a screen, backend, migration, authorization, loading,
error and empty states, tests and a document. The evidence is in
[acceptance.md](acceptance.md).

| Area | Features |
| --- | --- |
| Music intelligence | Musical DNA; genre normalization (one generated catalogue for app and server); Smart Music Affinity; Why You Match; Same Frequency; Discover My Next Artist |
| Social discovery | Music Radar (with an affinity-only radar view); Musical Communities with moderation; Vibra Circles (chat, plans, playlist, invitations); improved user discovery and complete profile identity |
| Concerts | Smart Concert Finder and event recommendations; Who's Going? with per-event visibility and reminders; Concert Match; Concert Groups |
| Social content | Daily Vibe and Discoveries; Music Stories (24 h, private media); Vibra Feed (for you / following / latest); Track Reactions |
| AI and personalization | VIBRA AI (optional, consent-gated, tool-grounded); Taste Evolution; personalized ranking across feed, artists, events and people |
| Safety and notifications | Notification Center with categories, grouping, quiet hours and daily caps; privacy controls per section; blocking everywhere; reporting with limits; community and circle moderation |
| Product cohesion | the signature features (Musical DNA, Same Frequency, Concert Match, Vibra Circles) one tap from Home under "Find your people through music", with live facts (ui-architecture.md) |
| Platform | keyset pagination and batch workers, incremental affinity updates, offline states, responsive layout, accessibility fixes |

## 3. Modified files

585 files differ from the last commit: 375 new, 209 modified and 1
deleted (plus this report and its appendix). The complete list, grouped by area, is in
[final-deliverables-files.md](final-deliverables-files.md).

| Area | Files |
| --- | --- |
| Database migrations / pgTAP tests | 30 / 13 |
| Edge Functions (incl. `_shared`) | 68 |
| App: core, data, domain | 78 |
| App: screens, widgets, providers, l10n | 141 |
| Flutter tests | 94 |
| Documentation | 47 |
| Android, iOS, assets, store, scripts, CI, Supabase config, root | 114 |

**Two cautions before committing:**

- **Earlier uncommitted work is mixed in.** 110 files predate this cycle:
  the October launch round (migrations 20261013–20261015 and pgTAP
  06–14) was never committed either. The appendix marks those files.
  Commit them separately.
- **`ios/Runner.xcodeproj/project.pbxproj`** has local debug-signing
  changes: bundle id `com.gregoriomorelli.vibra.dev`, debug entitlements
  and a signing script. This is device setup, not feature work. Review it
  before committing.

## 4. Database migrations

24 new migrations in this cycle. Each has a header comment and its own
document. All of them, together with every earlier migration, apply from
scratch on a fresh database.

| Migration | Purpose |
| --- | --- |
| 20261105000000 event_map_result_limit | map returns every event in the visible radius |
| 20261105000001 spotify_sync_and_matching | server-side listening history, scheduled sync |
| 20261106000000 enable_spotify_public | Spotify features in the public app |
| 20261107000000 music_affinity_engine | affinity scores and explanations |
| 20261108000000 musical_dna | DNA snapshots |
| 20261109000000 same_frequency | recommendations, saved profiles, view memory |
| 20261110000000 music_radar | private presence, area sound, settings |
| 20261111000000 communities | communities, posts, comments, reactions, moderation |
| 20261112000000 circles | circles, invitations, chat, plans, playlist, concert groups |
| 20261113000000 concert_intelligence | event recommendation inputs and cache |
| 20261114000000 whos_going | attendance with visibility, reminders |
| 20261115000000 concert_match | people for a concert, invitations |
| 20261116000000 daily_vibe | daily songs, reactions, comments, Discoveries |
| 20261117000000 music_stories | stories, views, reactions, replies, settings, private media |
| 20261118000000 vibra_feed | posts, reactions, comments, bookmarks, impressions, ranking |
| 20261119000000 track_reactions | reaction sets, saving songs from every share |
| 20261120000000 vibra_ai | consent, request limits |
| 20261121000000 artist_discovery | recommendations and feedback |
| 20261122000000 taste_evolution | history setting, evolution read |
| 20261123000000 profile_identity | per-section profile visibility |
| 20261124000000 social_safety | blocks everywhere, report limits, safety overview |
| 20261125000000 notification_center | categories, grouping, quiet hours, caps |
| 20261126000000 schema_hardening | about 50 missing foreign-key indexes |
| 20261127000000 performance | job cursors, affinity freshness, faster feed ranking, paged lists |

**Deploy status:** none of the migrations from 20261108 onward are
applied to hosted Supabase. Earlier notes say 20261105–20261107 were
already applied during the Spotify alignment. Confirm with
`supabase migration list` before deploying.

## 5. New backend services

| Edge Function | Role |
| --- | --- |
| vibra-ai | the optional assistant, using tools over real user data (Anthropic) |
| discover-artists | artist recommendations from the Spotify catalogue, cached 12 h |
| feed-posts | publishes feed posts with server-side validation |
| music-stories | creates stories with server-side validation |
| daily-vibe | song search and the daily pick (Spotify catalogue) |
| media-purge | removes orphaned story and feed photos (scheduled) |
| spotify-sync-worker | hourly listening sync, daily full sync |
| search-events | catalogue search across providers (Ticketmaster) |

**Changed:** calculate-match (incremental), sync-music-profile,
recommend-events, ticketmaster-sync, event-reminders, upload-image (two
new private buckets), and every notification worker. The notification
workers now go through one delivery policy, and two of them page through
all users.

**New shared modules:** affinity, DNA, genre catalogue, Spotify API and
tracks, Ticketmaster, artist discovery, feed, stories, notification
delivery, job batching, AI (provider, tools, answer schema).

## 6. New Flutter components

- **Feature components (spec section 25):**
  - `SameFrequencyCard`, `MusicRadarMap`, `CommunityCard`,
    `VibraCircleCard`, `ConcertMatchCard`, `DailyVibeCard`;
  - `MusicStoryCard`, `ArtistRecommendationCard`, `TasteEvolutionChart`,
    `NotificationCard`;
  - aliases for the ones that already existed: `MusicalDNAWidget`,
    `MusicAffinityCard`, `WhyYouMatchCard`, `ConcertEventCard`,
    `MusicFeedCard`.
- **Shared widgets:** `VibraPagedList`, the offline-aware `VibraErrorView`,
  and `VibraPageScaffold` with a width cap for tablets.
- **Feature widgets:** reactions, story widgets, feed widgets, profile
  identity and the Who's Going section.
- **Screens:** 25 new, including Musical DNA, Same Frequency, Music Radar,
  Communities (4), Circles (2), Concert Finder, Concert Match, Daily Vibe
  and Discoveries, Stories (3), Feed (2), VIBRA AI, Discover artists, Taste
  Evolution, Notification Center, Safety Center and Profile privacy.

## 7. External integrations

| Provider | Used for | Credentials | Notes |
| --- | --- | --- | --- |
| Spotify Web API | user sync (OAuth/PKCE), catalogue (client credentials) | client id/secret; user tokens encrypted with AES-GCM in the database | no audio stored or played; deprecated endpoints not used; app in Development mode |
| Ticketmaster Discovery | event catalogue and search | API key | 5 pages per query, sync every 6 h |
| Bandsintown (optional) | resolving shared event links | app id | returns "not configured" when absent |
| Firebase Cloud Messaging | push | service account | one delivery policy with caps and quiet hours |
| Anthropic | VIBRA AI | API key | optional: without it the assistant shows "unavailable" and nothing else is affected |
| OpenStreetMap | map tiles | none | attribution shown |

## 8. Security and privacy changes

- **RLS on every new table.** Clients mostly have SELECT only, and writes
  go through checked functions (session, rate limit, visibility).
- **Server-only writers.** These only the service role can call: feed
  posts, stories, DNA, matches, recommendations, notifications and job
  state.
- **Internal schema.** Rate limits, logs, radar presence, job cursors and
  affinity state are in `vibra_private`, which the API can't reach.
- **Blocks apply everywhere:** messages, follows, connections, circles,
  communities, stories, feed, Daily Vibe, radar, Same Frequency and
  notifications. A block removes links between the two people, and the
  other person isn't told.
- **Reports** are available on every content type, limited to one per
  target per week and 30 a day. Content can be held for review, and
  communities and circles have moderators.
- **Privacy controls:**
  - per-section profile visibility;
  - DNA and attendance visibility;
  - radar visibility and precision;
  - consent for AI and taste history;
  - who can see stories.
- **Location:** exact location is never exposed, and the radar shows
  affinity, never positions.
- **Private media:** in private buckets, re-encoded with EXIF stripped,
  and readable only while the content is visible; orphaned files are
  purged.
- **Spotify tokens:** encrypted and never returned to the app. Spotify
  calls follow Retry-After and degrade gracefully.
- **Guards in tests:**
  - a schema audit (RLS, delete rules, foreign-key indexes, no secrets in
    the app, no `current_user` in definer functions);
  - an RPC contract test;
  - IDOR tests;
  - pgTAP.

## 9. Tests executed

| Suite | What it covers |
| --- | --- |
| `flutter analyze`, `dart format --set-exit-if-changed` | static analysis, formatting |
| `flutter test` | unit, domain, provider, widget and screen tests, plus the app-level integration tests (`test/integration`, IDOR), schema audit, RPC contract, and per-feature guarantee and state tests |
| `flutter test` in `packages/flutter_map_marker_cluster` | map package |
| `deno test` (all of `_shared/` plus function tests) | server logic: affinity, DNA, feed, stories, AI, notification delivery, batching, providers |
| `deno check supabase/functions/*/index.ts` | Edge Function types |
| `supabase start` on a fresh project | every migration applies from scratch |
| `supabase test db` | RLS and security (pgTAP) |

## 10. Test results (2026-11-08)

| Suite | Result |
| --- | --- |
| Analyzer, formatting | clean |
| Flutter | **534 passed**, 7 skipped (they cover the Spotify-disabled launch mode and skip themselves in the Spotify-enabled build) |
| Map package | 9 passed |
| Deno | **129 passed** |
| Deno type check | no errors |
| Migrations | all 85 apply on a fresh database |
| pgTAP | **17 files, 322 assertions, all pass** |

Bugs these runs found and fixed:

- report limits that never ran (`limit_reports`);
- CI running only 4 of the Deno test files;
- six icon-only buttons with no accessible label;
- overlapping avatars on the radar view;
- the Safety Center hiding failures;
- a layout overflow on the live chat.

## 11. Known limitations

- **Not deployed, not committed.** No end-to-end run against hosted
  Supabase or the real providers yet.
- **No device runs.** The native security harness
  (`script/security/native/`) and the manual checklist were not run on
  iOS or Android.
- **Loading states are checked by code audit, not by automated tests.**
  Error and empty states are tested for 13 feature screens.
- **Spotify is in Development mode.** Public access needs Spotify's
  approval. The recommendations, related-artists and audio-features
  endpoints are deprecated, so artist discovery uses search and genres,
  and affinity uses top artists and genres.
- **The Music Radar is deliberately approximate.** People appear by
  affinity, never by position, and it needs location consent.
- **VIBRA AI only answers from its tools** (the user's data and the
  catalogue). It does not invent events or discographies, and it is
  unavailable without a key.
- **Event coverage depends on Ticketmaster's catalogue** in each market.
- **Your local development database** (project `vibra`) is stopped and at
  migration 20260728. Restart or reset it as you prefer; the verification
  used a separate throwaway project.

## 12. Remaining implementation tasks

1. **Commit** in reviewable pieces: the October launch work, then this
   cycle by phase. Leave out the local iOS signing changes.
2. **Staging deploy** (needs approval):
   - check `supabase migration list`;
   - apply the pending migrations in order;
   - deploy the 16 new and changed Edge Functions;
   - ship the app build that matches `get_discoveries(p_limit, p_before)`.
3. **Secrets and infrastructure:**
   - Spotify, Ticketmaster and FCM credentials; Anthropic is optional;
   - the Vault entries `vibra_functions_url` and
     `vibra_catalogue_job_secret`;
   - check that the pg_cron jobs exist on staging.
4. **Device pass** on iOS and Android: push delivery, stories with photos,
   offline states, tablets, and the native security harness.
5. **Spotify public access application.**
6. **Production deploy** after staging sign-off, then watch
   `vibra_private.job_cursors` (full passes) and the error logs.

## 13. Feature classification

| Category | Features |
| --- | --- |
| **Fully implemented and verified locally** (works without third-party keys once deployed) | Musical DNA and Smart Music Affinity from hand-picked genres; Why You Match; Same Frequency; Music Radar; Communities; Circles; Concert Groups; Who's Going? (on existing catalogue events); Concert Match; Track Reactions; Taste Evolution; profile identity and privacy; blocking, reporting and moderation; in-app Notification Center; Feed posts without songs (opinions, concert photos, shares); pagination, offline states, responsive layout |
| **Partially implemented** | None in code: no feature is a visual prototype, and every one has backend, database, authorization, states, tests and documentation. What is incomplete is *verification on real devices and hosted infrastructure* (sections 11–12). |
| **Requires external API credentials** | Spotify: account sync, Spotify-derived DNA and affinity, Daily Vibe song search, songs in stories and the feed, Discover My Next Artist. Ticketmaster: Concert Finder catalogue, event search and sync. FCM: push delivery for every notification type. Anthropic: VIBRA AI. Bandsintown (optional): resolving shared links. |
| **Requires additional infrastructure** | pg_cron, pg_net and Vault for the scheduled jobs (Spotify sync, Ticketmaster sync, event reminders, notification workers, media purge, expiry purges); private Storage buckets (`story-media`, `feed-media`, created by the migrations); deployed Edge Functions with their secrets |
