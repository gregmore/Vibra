# Flutter UI architecture

How the VIBRA app's screens are built (spec section 25): the reusable
feature components, the states every screen handles, responsive layout,
and where each feature sits in the navigation. State management is
Riverpod throughout, and this section added no dependencies.

## Feature components

`lib/presentation/widgets/vibra_feature_components.dart` exports all of
them, so a screen needs one import. Each component lives with its feature's
other widgets. Five components already existed under good names; for those
the spec name is a `typedef`, the same convention as `VibraEmptyState` in
`vibra_state_views.dart`. So there is one implementation per component and
no duplicates.

| Spec name | Implementation | File | Used in |
| --- | --- | --- | --- |
| MusicalDNAWidget | `MusicalDnaPreviewCard` (+ `DnaStrip`) | `musical_dna_widgets.dart` | profiles, Taste Evolution |
| MusicAffinityCard | `VibraUserMatchCard` | `common/vibra_user_match_card.dart` | Friends, event attendees |
| WhyYouMatchCard | `AffinityExplanationCard` | `affinity_explanation_card.dart` | user profile |
| SameFrequencyCard | `SameFrequencyCard` (was `FrequencyPersonCard`) | `same_frequency_widgets.dart` | Same Frequency, Music Radar |
| MusicRadarMap | `MusicRadarMap` (new) | `music_radar_widgets.dart` | Music Radar |
| CommunityCard | `CommunityCard` (was `CommunityTile`) | `community_widgets.dart` | Communities, Music Radar |
| VibraCircleCard | `VibraCircleCard` (extracted) | `circle_widgets.dart` | Circles |
| ConcertEventCard | `VibraEventCard` (+ `VibraEventRow`) | `common/vibra_event_card.dart` | My events, Radar, Home |
| ConcertMatchCard | `ConcertMatchCard` (extracted) | `concert_widgets.dart` | Concert Match |
| DailyVibeCard | `DailyVibeCard` (was `VibeCard`) | `daily_vibe_widgets.dart` | Daily Vibe |
| MusicStoryCard | `MusicStoryCard` (new) + `UserStoriesStrip` | `music_story_widgets.dart` | user profile |
| MusicFeedCard | `FeedPostCard` | `feed_widgets.dart` | Feed, saved posts, a person's posts |
| ArtistRecommendationCard | `ArtistRecommendationCard` (moved) | `artist_discovery_widgets.dart` | Discover my next artist |
| TasteEvolutionChart | `TasteEvolutionChart` (extracted) | `taste_evolution_widgets.dart` | Taste Evolution |
| NotificationCard | `NotificationCard` (extracted) | `notification_widgets.dart` | Notification Center |

Notes:

- **MusicRadarMap** is a radar of *musical affinity*, not a map of places.
  The distance from the centre is the affinity score, and the angle comes
  from a hash of the user id, so the picture is stable. To avoid overlaps,
  only the angle is turned. The widget is given no coordinates or
  distances, which keeps the radar's privacy rule (music-radar.md): the
  server returns none. The caption says so.
- **MusicStoryCard** scales the real `StoryCanvas` down to a 9:16
  thumbnail, so it can't drift from what the viewer shows. The ring means
  unseen. A person's profile shows their active stories when the server
  says I can see them.
- **Widgets never import screens.** Moving the cards also moved the
  helpers that widgets had been importing from screens
  (`pickReportReason`, `openOnProvider`, the comments sheet) into
  `daily_vibe_widgets.dart`.

## Screen states

Every data screen renders the provider's `AsyncValue` with the shared state
views from `common/vibra_state_views.dart`:

| State | Component | Rule |
| --- | --- | --- |
| Loading | `VibraLoadingView` (page) or `VibraLoadingIndicator` (section, list end) | never a blank screen |
| Empty | `VibraEmptyView` | says what is missing and offers the next action when there is one |
| Error | `VibraErrorView(error: e, …, onRetry:)` | localized text, never raw errors; Retry re-runs the provider |
| Offline | `VibraErrorView` given an offline error | it switches itself to "You're offline" with the network icon and keeps Retry |
| More pages | `VibraPagedList` | a failed page shows Retry instead of looping (performance.md) |

**Offline** is detected from the failed request itself
(`core/errors/offline.dart`, `isOfflineError`), so no connectivity plugin
is needed and it works on every platform. `userFacingError` uses the same
definition. Every `error:` branch passes its error to `VibraErrorView`, so
each screen gets the offline state without its own code. Sections that
refresh in place show a short inline message instead; for example the
inbox shows "Connection unavailable" while keeping the cached list. Writes
that fail offline show a snackbar and leave the screen unchanged.

Secondary sections (a strip on Home, the stories row on a profile) show
nothing on error rather than an error card, so a single failing section
never takes over the page.

## Responsive layout

- `VibraPageScaffold` centres content and caps it at 720 px
  (`defaultMaxContentWidth`). Phones are unaffected; on tablets, landscape
  and desktop, lists and cards keep a readable width while the background
  fills the window. The Explore map passes `maxContentWidth: null` to stay
  full-bleed.
- Components size themselves from their constraints: `MusicRadarMap` uses
  `min(width, 360)`, story thumbnails keep 9:16, and text truncates with
  ellipsis. No component assumes a phone width.
- Text scales with the system font size. Touch targets are at least 48 px
  (`VibraSpacing.minTouchTarget`).

## Navigation and information architecture

The bottom navigation keeps its **five destinations** (Home, Events,
Social, Chat, Profile). None of the new features added one. Each is
reached from the tab where it belongs:

| Tab | Features reached from it |
| --- | --- |
| Home | story ring, notification bell (Notification Center), **the signature section** (below), Daily Vibe, Feed, Discover my next artist, VIBRA AI, concerts for you |
| Events (Explore) | map and list of events → event detail → Who's Going, Concert Match, concert groups |
| Social | Same Frequency, Music Radar, Communities, Circles, friends and requests |
| Chat | conversations, message requests |
| Profile | Musical DNA → Taste Evolution, Discoveries, saved posts and artists, my posts, profile privacy, Safety Center, settings (notification and privacy settings) |

**Signature section.** The product's most recognizable features sit one
tap from Home, near the top, under "Find your people through music"
(`HomeSignatureSection`, `widgets/home_signature.dart`). It has four tiles,
each showing one live fact from the user's real data, with Concert Match
and Vibra Circles reachable from the tiles:

| Tile | Live fact | Opens | With no data |
| --- | --- | --- | --- |
| Musical DNA | the leading genre family, plus the DNA strip | Musical DNA | "Build it from the genres you love" → genre picker |
| Same Frequency | how many people are on your frequency, with avatars | Same Frequency | invitation to discover |
| Concert Match | the next concert you're going to | Concert Match for that event | Concert Finder |
| Vibra Circles | waiting invitations first, otherwise your circles | Circles | "Start a small music group" |

The tiles read the same providers as the feature screens. The Same
Frequency tile uses a preview that records no views, so people only count
as "shown" on the Same Frequency screen. A failing tile falls back to its
invitation text, and the section appears only when music features are on.

Detail screens are pushed on top of their tab with `context.push`, so Back
returns to where you were and the tab keeps its own stack (GoRouter
`StatefulShellRoute`). Notifications deep-link through one function
(`openNotificationTarget`), so tapping a push notification or an inbox row
opens the same screen.
