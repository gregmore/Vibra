# Spotify integration

Status: part of the public app (6 Nov 2026). There is one app for everyone;
connecting Spotify is optional. `SPOTIFY_ENABLED` (app build, default
`true`), the `SPOTIFY_ENABLED` Edge secret and `launch_features.spotify`
(migration `20261106000000`) stay as an emergency off-switch. Until Spotify
grants extended quota, only accounts listed in the Spotify dashboard can
connect; others get a clear "not enabled for your account yet" message
(`spotify_access_not_granted`) and the rest of the app is unaffected.

**Social graph:** friends, connections and people search come from the
public social graph for every user. Spotify adds a layer: the Social tab
shows a "New affinity" entry that opens the match deck (`/vibra-match`) when
Spotify is connected, or invites the user to connect it. Affinity rings and
shared artists appear only where real match data exists.

## 1. Authentication (Authorization Code + PKCE)

| Step | Where | Notes |
|---|---|---|
| Code verifier (43 chars, CSPRNG) + S256 challenge + random `state` | app, `SpotifyAuthDatasource` | |
| Consent screen | `accounts.spotify.com/authorize` via `flutter_web_auth_2` | `show_dialog=true` |
| Callback | `com.vibra.app://callback` (custom scheme, must match the Spotify dashboard and `SPOTIFY_REDIRECT_URI`) | `validateCallback` checks scheme/host/path, single `state`, single `code`, no fragment; `error=` → cancelled |
| Code exchange | Edge `spotify-token-exchange` | PKCE: `client_id` + `code_verifier`, **no client secret** |
| Identity guard | app repository | aborts if the Vibra account changed while Spotify was open |

**Scopes** (`ApiConstants.spotifyScopes`), the minimum:

* `user-top-read`: top artists and tracks (statistics, matching, events)
* `user-read-recently-played`: play timestamps (listening heatmap)

`/v1/me` (id, name, images) needs no scope; e-mail and private account fields
are not used, so `user-read-private`/`user-read-email` are no longer
requested. Playlist/library scopes are not requested: no feature uses them.

### Token storage and refresh

* Access and refresh tokens are stored **only on the server**, AES-GCM
  encrypted (`SPOTIFY_TOKEN_ENCRYPTION_KEY`) in `spotify_connections`
  (RLS on, no client policies). The exchange returns only
  `{connected, expires_in, scope}`; the device never holds Spotify
  credentials. On connect the app also deletes tokens that older versions
  kept in Keychain/Keystore (`flutter_secure_storage`).
* Every Spotify call goes through `_shared/spotify_api.ts`:
  * **proactive refresh** when the token expires within 5 minutes;
  * one **reactive refresh** on 401, then retry;
  * refresh uses the PKCE grant (`client_id`, no secret); the new pair is
    saved only if the connection is unchanged (`refresh_spotify_connection`),
    so a concurrent disconnect always wins.
* **Revocation** (user removes Vibra from their Spotify account): the refresh
  returns `invalid_grant` → `SpotifyRevokedError` → the backend calls
  `disconnect_spotify_account` (deletes tokens, profile, history, matches,
  clears `users.spotify_id`) and answers `409 spotify_not_connected` with
  `reason: "revoked"`. The app clears its caches, refreshes the profile and
  shows "Connect Spotify" again.

## 2. Synchronisation and storage

| Data | Endpoint | Range | Stored in |
|---|---|---|---|
| Top artists (50) | `/me/top/artists` | `medium_term` (~6 months) | `music_profiles.top_artists` |
| Top tracks (50) | `/me/top/tracks` | `medium_term` | `music_profiles.top_tracks` |
| Top genres | artist genres (`/artists/{id}` hydration if missing) | from top artists | `music_profiles.top_genres` |
| Plays | `/me/player/recently-played?after=<last stored>` | incremental | `spotify_listening_events` (play time only) |
| Heatmap | computed from stored plays, last 12 weeks, Mon–Sun (UTC) | | `music_profiles.listening_heatmap` |

**Time range decision:** `medium_term` everywhere (profile, matching,
events). `short_term` changes week to week and would make matches unstable;
`long_term` lags behind current taste. A range switch in the UI is not
offered: it would triple API usage and storage for a cosmetic difference,
and matching must use one range anyway.

**Heatmap source:** Spotify only exposes the last 50 plays, so a single call
cannot describe weeks of listening. The hourly worker keeps only new play
timestamps (no track, device or context data), dedupes them by
`(user_id, played_at)` and keeps 26 weeks.

**When it runs**

| Trigger | What | Function |
|---|---|---|
| First connection | full sync before "connected" is shown | `sync-music-profile` |
| Manual refresh (Music stats) | full sync | `sync-music-profile` |
| Every hour (pg_cron `invoke-spotify-sync`, minute 17) | plays for up to 25 users not polled in 50 min; full sync + match recompute when the last full sync is older than 24 h | `spotify-sync-worker` |

The worker is authenticated with the existing server-to-server job secret
(`x-vibra-job-secret`, Vault `vibra_catalogue_job_secret`), claims rows with
`FOR UPDATE SKIP LOCKED` (no double processing), stops on a 429 or after
100 s, and is a no-op while Spotify is paused.

**Rate limits:** a 429 waits `Retry-After` (up to 30 s, at most twice);
longer waits fail fast (`429 spotify_rate_limited` to the app, "Spotify is
busy, try again in a minute"), and the worker stops and resumes next hour.

## 3. Matching between people ("New affinity")

Moved to the music affinity engine (algorithm v2):
`docs/music-affinity-engine.md`. It compares two-level genre profiles (soft
cosine, 75%) and shared artists (25%), works with picked genres when Spotify
is not connected, and stores an explanation with every pair.

## 4. Event compatibility ("For you")

Implementation: `music_match.ts → eventCompatibility`, used by
`recommend-events`. Ticketmaster classification genres are now stored in
`events.genres` and mapped through the same family taxonomy (for example
"Hip-Hop/Rap" and "italian hip hop" are both hip-hop).

```
A = rank weight of the matching top artist        // Spotify ID, or normalised
                                                  // name in artist/title (word match)
G = max user family weight among the event's families
compatibility = round(100 × (1 − (1 − A) × (1 − 0.8 × G)))
```

A top artist alone gives 100; a perfect genre fit without a known artist
gives 80; neither gives 0. The "score above 70" threshold therefore means a
known artist, or a strong genre fit in the user's top families.

Ranking in "For you": `total = 0.60 × compatibility + 0.25 × proximity +
0.15 × time` (proximity and time as before: distance decay, and 0 after
180 days).

## 5. States in the app

| State | When | UI |
|---|---|---|
| `authorizing` | consent screen open | step 1, button disabled |
| `exchangingToken` | consent granted, server exchanging | step 2 |
| `syncingProfile` | first sync running | step 3; "connected" not shown yet |
| `success` | data synced | Continue |
| `userCancelled` | consent declined/closed | warning + Retry |
| `error` | OAuth/exchange failed | error + Retry (new OAuth) |
| `syncFailed` | connected, first sync failed | warning + **Retry sync** (no new OAuth) |
| `disconnected` | revoked or disconnected elsewhere | explanation + Connect |

## 6. Disconnect and account deletion

* **Settings → Spotify → Disconnect** calls `spotify-disconnect` →
  `disconnect_spotify_account` (one transaction, under the same lock as
  refresh/sync): matching consent off, matches, music profile, listening
  history and encrypted tokens deleted, `users.spotify_id` cleared. The app
  then clears its music caches and legacy device tokens. Failures now show
  an error instead of a false success.
* Spotify has no token-revocation endpoint: deleting the tokens ends
  Vibra's access, and users can also remove Vibra at
  spotify.com/account/apps.
* **Account deletion** cascades from `auth.users` → `users` →
  `spotify_connections`, `music_profiles`, `spotify_listening_events`,
  `user_matches`.

## 7. Privacy

* Consent screen copy (`spotifyConsentBody`, `spotifyConsentSharing`, all 5
  languages) states what is read (profile, top artists/tracks/genres over
  ~6 months, recent play times), why, where credentials are kept, and that
  other people see only the affinity score and artists/genres in common,
  never listening history.
* Data minimisation: only play timestamps are stored for the heatmap
  (26-week retention); no e-mail or private account scopes.
* Spotify Developer Terms: data is used only to provide the user-facing
  features above; it is deleted on disconnect, on revocation and with the
  account; no data is sold or used for advertising; Spotify content is
  attributed (Spotify green and name only next to Spotify actions).

## 8. Going live

1. Spotify extended quota approval (`docs/spotify-public-access-draft-20261014.md`).
2. Privacy policy, terms, support pages and store questionnaires are updated
   (source: `script/store/build_site.py`; regenerate with
   `python3 script/store/build_site.py` and publish `store/site/dist`).
3. Deploy in this order: migrations `20261105000000`, `20261105000001`; Edge
   functions `spotify-token-exchange`, `sync-music-profile`,
   `spotify-sync-worker`, `calculate-match`, `recommend-events`,
   `search-events`, `ticketmaster-sync`; then migration `20261106000000`
   (enables `launch_features.spotify`) and the app.
4. Set the Edge secret `SPOTIFY_ENABLED=true` and `spotify_enabled: true` +
   `spotify_public_access_verified: true` in `release/store-config.json`.
5. Existing connections keep working: their stored refresh tokens are
   refreshed with the PKCE grant. Users with an expired/revoked grant are
   disconnected cleanly and asked to connect again.

## 9. Tests

* Deno: `_shared/spotify_api.test.ts` (proactive refresh, 401 retry,
  Retry-After, revocation, disconnect race), `calculate-match/index.test.ts`
  (formulas and taxonomy), `_shared/spotify-feature.test.ts` (pause).
* Flutter: `test/core/spotify_connect_boundary_test.dart` (PKCE, no tokens
  on device, account switch), `test/unit/spotify_account_link_verification_test.dart`.
* The whole suite passes in both modes: default (Spotify on) and
  `--dart-define=SPOTIFY_ENABLED=false` (off-switch).
