# VIBRA Daily Vibe

One song a day that represents your vibe. Server: the `daily-vibe` Edge
Function, `_shared/spotify_tracks.ts` and migration
`20261116000000_daily_vibe.sql`. App: `/daily-vibe` (Home → "What's your
vibe today?") and `/discoveries`. Guarantees are pinned by
`test/core/daily_vibe_licensing_test.dart` and
`_shared/spotify_tracks.test.ts`.

## 1. Choosing a song

* **Spotify:** search runs through the `daily-vibe` function with
  Vibra's app credentials (client credentials, no user token). When
  posting, the function **re-fetches the track from Spotify by ID**, so
  the title, artists, album and artwork are Spotify's, not the client's.
* **Other providers:** a link (Apple Music, YouTube / YouTube Music,
  SoundCloud, Bandcamp) with the title and artist typed by the user.
  Nothing is fetched from the link: no artwork, no audio.

## 2. Licensing

* **No audio, ever.** Vibra never stores, proxies or plays audio, and
  doesn't use or return preview URLs. Listening opens the provider
  ("Listen on Spotify" / "Open link").
* **Artwork is referenced, never copied.** It's displayed from Spotify's
  CDN (`i.scdn.co`, enforced by a database check) and never re-hosted.
* **Attribution:** Spotify vibes show "Song info and artwork from
  Spotify" and a link back to the track.
* **Minimal storage.** Stored metadata is limited to what the post
  shows. Vibes expire by default, and expired ones are deleted hourly.

## 3. The post

* **Content:** song title, artist, album artwork, album, an optional
  caption (200 characters) and the time it was published.
* **One per person per day.** Posting again the same day replaces it,
  with at most 6 changes a day.
* **Optional 24-hour expiry** (on by default). Expired vibes disappear
  from every read immediately and are purged hourly (`pg_cron`).
* **Visibility:**
  * **connections** (default): accepted connections and mutual musical
    matches;
  * **everyone:** anyone signed in.

  Blocks and test segments always apply.
* **Feed:** your own vibe first, then vibes from your connections,
  matches and people you follow (each still subject to its owner's
  visibility).

## 4. Interactions

* **React:** 🔥 ❤️ 🎧 👏 🤯.
* **Comment and reply:** one level of replies. The comment's author, or
  the vibe's owner, can delete a comment.
* **Discover the song:** open it on the provider.
* **Add it to your discoveries:** a private collection on the
  Discoveries screen (up to 500 songs).
* **Notifications:** the vibe's owner, and the author of a comment being
  replied to, are notified through the existing worker. People in a
  block with the commenter are skipped.
* **Moderation:**
  * report a vibe or a comment (shared `reports` table, validated, rate
    limited); 3 reports hide the content;
  * block a person from the same menus;
  * rate limits: search 20 a minute, comments 10 a minute, reactions 60
    a minute, discoveries 30 a minute.

## 5. Notes

* **Day boundary.** The "day" is the database's UTC date.
* **Spotify quota.** Search works with app credentials, so it doesn't
  depend on the per-user Spotify allow-list. If Spotify is switched off
  or unavailable, the app suggests pasting a link instead.
