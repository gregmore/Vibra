# VIBRA UI/UX redesign — 5 Nov 2026

Complete visual redesign built on the existing Flutter + Riverpod + GoRouter +
Supabase architecture. No backend, schema, RLS, business logic, routing or
provider behaviour was changed. The match score, recommendations and all
data still come from the backend unchanged.

## 1. Audit (starting point)

* **Architecture:** Riverpod providers, GoRouter with a 5-branch
  `StatefulShellRoute` (Home, Events, Vibra/Social, Chat, Profile), clean
  domain/data layers. Spotify is behind `SPOTIFY_ENABLED` (off for launch).
* **Theme:** a token layer already existed (`VibraThemeTokens`) with a light
  "signal paper" and a purple-tinted dark palette; Syne + Inter.
* **Inconsistencies found:** the in-app logo was an old "two waves" mark
  unrelated to the VIBRA V; purple/pink gradients and glows on CTAs; neon
  shadows; Syne display font; rainbow icon colours in Settings; hardcoded
  colours in 6 screens; repeated ad-hoc empty states (animated sine waves);
  `onAccent` white text on `#8B5CF6` (4.2:1, below AA); infinite decorative
  animations; pill CTAs mixed with square ones; underline inputs.

## 2. Design system

All values live in `lib/core/theme/`:

| File | Contents |
|---|---|
| `vibra_colors.dart` (new) | Raw palette: ink `#000000 / #0A0A0A / #101010 / #181818 / #242424`, text `#FFFFFF / #A1A1AA / #71717A`, violet `#8B5CF6`, indigo `#6366F1`, status `#22C55E / #F59E0B / #EF4444`, Spotify brand green |
| `vibra_theme_tokens.dart` | Semantic roles for dark (default) and light. Adds `textMuted`, `accentFill`, match tiers, real colour `lerp` for smooth theme switches |
| `vibra_text_styles.dart` | Inter only. Display 40/34/32, H1 28, H2 24, H3 20, body 16/15, secondary 13, caption 12/11, tabular score numerals |
| `vibra_spacing.dart` | 4 px grid, radii 12/16/20/24, icon sizes, touch targets, button/input heights, elevation, nav clearance |
| `vibra_motion.dart` | House curve, durations, stagger, press scale, reduced-motion helpers |
| `vibra_theme.dart` | Full Material 3 theme from tokens (buttons, inputs, chips, switches, tabs, sheets, dialogs, snackbars, nav, page transitions) |

**Accessibility decision:** `#8B5CF6` with white text is 4.2:1. Violet is
kept for indicators, selection, icons and rings, while surfaces that carry
white copy (primary buttons, outgoing chat bubbles, badges) use
`accentFill #7C3AED` (5.7:1). `test/core/theme/vibra_contrast_test.dart`
still enforces AA for every token pair.

**Dark first:** without a stored choice the app now opens in dark. Users
can still choose Light or System in Settings (existing feature kept; the
light theme is the logo's black-on-white variant).

## 3. Logo and brand assets

* Your four logo files are stored unmodified in `assets/branding/source/`.
* `script/branding/generate_brand_assets_test.dart` now derives everything
  from `vibra_logo_white_on_black_1024.jpg` by crop/resample/luminance→alpha
  only (geometry never redrawn):
  `assets/branding/logo/vibra_mark.png` (in-app mark, tintable),
  `vibra_splash_mark.png`, all iOS AppIcon sizes, Android launcher mipmaps,
  `raster/vibra_app_icon_1024.png`, Play feature graphic.
* Native launch screen (iOS + Android incl. Android 12) regenerated with
  `flutter_native_splash`: `#000000` + white mark. The Flutter splash
  renders the identical frame, so the hand-off is invisible; the logo
  entrance animation then plays on Welcome/Login (navigation is still
  immediate, as the existing splash test requires).

## 4. Component library

Import `lib/presentation/widgets/vibra_components.dart`.

| Spec name | Implementation |
|---|---|
| VibraPrimaryButton / VibraSecondaryButton | `common/vibra_button.dart` (+ `VibraButton` tones, `VibraIconButton`) |
| VibraTextField | `common/vibra_input.dart` (+ compact `VibraInput`) |
| VibraEventCard | `common/vibra_event_card.dart` → `VibraEventFeature` / `VibraEventRow` |
| VibraUserCard | `common/vibra_user_match_card.dart` |
| VibraMatchIndicator | `common/vibra_match_indicator.dart` (+ `VibraMatchBadge`, `VibraMatchTierChip`) |
| VibraBottomNavigation | `common/vibra_bottom_navigation.dart` |
| VibraSectionHeader | `common/vibra_section_header.dart` |
| VibraAvatar | `common/vibra_avatar.dart` |
| VibraBadge | `common/vibra_badge.dart` (+ `VibraCountBadge`) |
| VibraLoadingIndicator / VibraEmptyState / VibraErrorState | `common/vibra_state_views.dart` |
| VibraBottomSheet | `common/vibra_bottom_sheet.dart` |
| Supporting | `vibra_logo.dart` (mark, wordmark, entrance), `vibra_image.dart` (cached image, branded fallback, scrim), `vibra_event_meta.dart` (status, price, dates), `vibra_auth_backdrop.dart` |

Legacy APIs (`VibraPillButton`, `VibraGlassmorphicCard`, `VibraAffinityScore`,
`VibraNeonAvatar`, `UserAvatar`) now render through the new components, so
every older call site picked up the new look.

**Match indicator:** animated ring filled to the backend score; tiers by
colour *and* weight — high ≥ 75 (violet→indigo sweep, thicker arc, echo
ring), medium ≥ 45 (indigo), low (neutral). The number is always printed in
primary ink, so it stays readable at any size.

## 5. Screens

| Area | What changed |
|---|---|
| Splash | Pure ink + original white mark, pixel-matched to native launch |
| Welcome | Wordmark header, logo hero with entrance animation, numbered slides, echo-ring icons, violet progress dots, primary CTA; no infinite orb animation |
| Login | Logo entrance, Google/Apple white provider buttons per their guidelines, outline Email, branded loading overlay |
| Email auth sheet (login/registration) | `VibraBottomSheet`, `VibraTextField`s with autofill hints, field-to-field keyboard flow, inline validation, loading primary button |
| Shell navigation | New `VibraBottomNavigation`: anchored, hairline, muted glyphs, violet selection with growing indicator, VIBRA mark as the Vibra tab glyph, count badges, haptics, safe areas |
| Home | Brand bar + avatar, greeting, compact Spotify status/connect row, hero carousel of recommended events with pager, your top artists (Spotify), nearby/trending rows, branded skeleton, error/empty card with retry |
| Events / map | H1 header, rounded search, taller rounded map, VIBRA-mark markers (selected = violet + echo), branded clusters, grouped zoom control, events bar with count, labelled distance/genre filter rails, empty/error states, restyled events sheet |
| Event cards | Status (upcoming/today/off-sale/sold-out/postponed/cancelled/past) with greyscale artwork when inactive, date stamp, artist, venue, time, price, match badge |
| Event detail | Hero artwork with date block and status, artist eyebrow, facts card (date/time, venue, price), full-width ticket CTA + attendance segmented row up front, description, map with VIBRA marker, people going |
| Vibra discovery | Match card: you/them portraits joined by the mark, animated compatibility ring + tier, shared artists as tags, area reason, Ignore / Send Vibra, swipe hints, one-shot "Vibra sent" burst + haptic, branded scanner |
| People discovery (launch build) | Header with badge actions, search, user cards, loading/empty/error states, pending requests |
| Chat list | H1 header, tabs with request count, unread filter chip, rows with unread count badges and violet timestamps, empty states |
| Chat | Header with initials avatar and live **online** status (existing Realtime Presence), grouped bubbles (violet outgoing / elevated incoming), day separators, newest-message entrance, composer in a bottom bar so snackbars never cover it |
| Profile | Centered identity hero with edit action, Spotify badge, stat strip, music identity (top artists + genres), upcoming events preview, grouped overview links |
| Other user profile | Compatibility ring + tier, AA-safe follow/friend buttons |
| Settings / edit profile / onboarding / Spotify connect | Rainbow icon colours unified to the accent; Spotify green centralised as a brand token; all other styling inherited from the theme |

## 6. Motion, performance, accessibility

* Motion goes through `VibraMotion`; core flows (splash/auth, home, map
  markers, discovery, chat, nav, states) collapse to static frames when the
  OS requests reduced motion. Infinite decorative animations were removed
  from Welcome, empty states, home cards and event posters.
* No blur/backdrop filters; dark surfaces use no shadows; images decode at
  display size (`memCacheWidth`); lists stay lazy; repaint boundaries on
  animated markers; chat animates only the newest bubble.
* Semantic labels on cards, nav, match indicators, badges; headers marked;
  48 px minimum targets; dynamic type respected (logo lockups excepted);
  AA contrast enforced by tests.

## 7. Validation

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `dart format --set-exit-if-changed lib test script` | Clean |
| `python3 script/l10n/audit_localizations.py` | PASS (694 messages × 5 languages) |
| `flutter test` (launch build, Spotify off) | **295 / 295 passed** |
| `flutter test --dart-define=SPOTIFY_ENABLED=true` | 289 passed, 7 skipped, 8 failed — all are launch-only tests without a Spotify skip (`public_friends_provider_test` ×3, "Public community…"/"Community…" ×4 that assert the public search provider) plus `music_stats_screen_test` "sync errors are visible", which exercises Spotify sync error mapping (screen logic unchanged). Home in Spotify mode was fixed during this work |
| `script/branding/generate_brand_assets_test.dart` | Passes; regenerates identical assets |
| Visual check | Production widgets rendered offline (dark + light) for Home, Login, Welcome, Event, Community, Messages, Profile, Vibra match, empty state |

The repository has no integration/E2E tests (`integration_test/` contains
only an empty `fixtures/` folder). Not verified on a physical device or
simulator in this pass.

## 8. Not redesignable without backend or new features

1. **Event genre** on cards and a real genre filter: events have no genre
   field; the existing Explore genre filter remains a client keyword match.
2. **Date and event-status filters** on the map: not part of the existing
   query/filters (only distance and genre are). Status is now visible on
   every card; adding filters is a feature follow-up.
3. **Sold out:** Ticketmaster sync stores `offsale` (not on sale), not a
   sold-out signal. The UI shows "Tickets not on sale" and would show
   "Sold out" if the backend ever sends `soldout`.
4. **Typing indicator:** Realtime Presence only tracks `online`; typing
   needs a presence/broadcast payload. Online status is shown.
5. **Event sharing cards in chat:** no event message type exists (text,
   image, meetup proposal only).
6. **Password recovery:** no reset flow exists; needs Supabase redirect URLs
   and a deep-link handler.
7. **Recommended artists / artist images:** the music profile has artist
   names only; Home shows your top artists, not recommendations.
   Discovery cards have no genres (`MatchedUserPreview` has none).
8. **Chat header photo:** `ChatScreen` only receives id + name, so it shows
   initials.
9. **Store screenshots** (`release/`, git-ignored) must be regenerated with
   `script/store/capture_screenshots_test.dart` (the harness was fixed to
   decode the logo).

## 9. Files changed by this redesign

**New:** `lib/core/theme/vibra_colors.dart`,
`lib/presentation/widgets/vibra_components.dart`,
`lib/presentation/widgets/common/{vibra_badge, vibra_bottom_navigation,
vibra_bottom_sheet, vibra_event_meta, vibra_image, vibra_match_indicator,
vibra_auth_backdrop}.dart`, `assets/branding/source/*` (4 originals),
`assets/branding/logo/{vibra_mark, vibra_splash_mark}.png`, Android
`drawable-*/{splash, android12splash}.png`, iOS `LaunchImageDark*.png`,
this document.

**Theme:** `lib/core/theme/{vibra_theme, vibra_theme_tokens,
vibra_text_styles, vibra_spacing, vibra_motion}.dart`.

**Components:** `lib/presentation/widgets/common/{vibra_logo, vibra_button,
vibra_input, vibra_surface, vibra_state_views, vibra_section_header,
vibra_event_card, vibra_editorial_event, vibra_user_match_card, vibra_avatar,
vibra_openstreetmap_layer}.dart`,
`lib/presentation/widgets/{vibra_pill_button, vibra_glassmorphic_card,
vibra_affinity_score, vibra_neon_avatar, vibra_map_beacon,
vibra_match_scanner, email_auth_sheet}.dart`.

**Screens:** `auth/{splash, welcome, login, spotify_connect}`,
`shell/vibra_shell`, `home/home`, `explore/explore`,
`event_detail/event_detail`, `social/{social_match, discover_users,
conversations, chat, user_profile}`, `profile/{my_profile, settings,
edit_profile}`, `onboarding/onboarding_wizard` (`*_screen.dart`).

**Other app code:** `lib/presentation/providers/app_state_providers.dart`
(dark default only), `lib/main.dart` (font licence list), `pubspec.yaml`
(logo asset; Syne removed), `lib/l10n/*.arb` + generated localizations
(14 new keys × 5 languages).

**Native / assets:** `flutter_native_splash.yaml`; iOS AppIcon set,
LaunchImage/LaunchBackground, `LaunchScreen.storyboard`; Android mipmaps,
`drawable*/launch_background.xml`, `drawable*/background.png`,
`values*/styles.xml`; `assets/branding/raster/{vibra_app_icon_1024,
vibra_play_feature_graphic_1024x500}.png`; `assets/branding/README.md`.

**Scripts / tests:** `script/branding/generate_brand_assets_test.dart`,
`script/store/{capture_screenshots_test, capture_map_report_test}.dart`,
`test/core/theme/vibra_theme_test.dart` (new token values).
