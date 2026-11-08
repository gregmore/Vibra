# Music Stories

Temporary, music-focused stories (spec section 14). Every story disappears
after 24 hours.

## What people can share

| Kind | Content | Source |
| --- | --- | --- |
| Now listening | a track | Spotify search, or a link to Apple Music, YouTube, SoundCloud or Bandcamp |
| Favorite artist | an artist | same |
| Album pick | an album | same |
| Playlist | a public playlist | same (client-credentials search only returns public playlists) |
| Concert photo | a photo, optionally tagged with a concert you saved or are going to | the phone's gallery |
| Music opinion | up to 300 characters on one of five VIBRA backgrounds | typed |

Every kind also takes an optional caption (300 characters).

## Licensing (same rules as Daily Vibe)

- When a Spotify item is posted, the `music-stories` Edge Function fetches it
  again from Spotify by id. Title, subtitle, artwork and link are Spotify's,
  never what the client sent.
- Only metadata, the artwork URL on Spotify's CDN (`i.scdn.co`,
  `mosaic.scdn.co`, `image-cdn-*.spotifycdn.com`) and a link back are stored.
  Audio and preview URLs are never stored, returned or played.
- Spotify items show "Music info and artwork from Spotify" and a "Listen on
  Spotify" button. Other providers show "Open link", with no artwork.

## Concert photos

- The photo goes through `upload-image?bucket=story-media`, which decodes and
  re-encodes it. That strips EXIF metadata, so GPS position and camera data
  never reach other people.
- `story-media` is a private bucket. Clients cannot write, replace or delete
  in it (restrictive policies). A photo can only be read while its story is
  visible to the reader (the read policy runs under `music_stories` RLS).
- A story can only use a photo from the poster's own folder.
- `media-purge` runs every hour (pg_cron → pg_net, with the catalogue
  job secret). It deletes photos that no live story uses: expired, deleted,
  or uploaded and never posted within an hour.

## Privacy

- **Audience per story:** connections and mutual musical matches (default),
  or everyone, which also includes followers. Uses the same audience rules
  as Daily Vibe (`can_see_daily_vibe`), so blocks and test segments always
  apply.
- **Default audience and replies** can be set in Story privacy
  (`story_settings`). Each live story's audience and replies can also be
  changed from its menu.
- **Hide your stories from** specific connections (`story_hidden_viewers`).
  They are not told.
- **Mute** someone's stories (`story_mutes`). They are not told.
- **Views:** recorded so the ring knows what you've seen. Only the author
  can list who viewed a story, and people blocked either way are left out.
- **Replies are private:** a viewer replies to the author, and the author
  can answer only a viewer who replied first. Nobody else sees them. They
  are deleted with the story.
- **Expiry:** `expires_at` is at most 24 hours after posting (a CHECK
  constraint), every read checks it, and an hourly job deletes expired rows.

## Moderation and limits

- Report a story (3 different reporters hold it for review) or a reply you
  received (one report hides it, since only you can see it). Block from the
  story menu or from a reply thread.
- Rate limits: 5 stories a minute and 30 a day; replies 20 a minute (200 a
  day); reactions 60 a minute; views 120 a minute; privacy changes 30 a
  minute. Text goes through the same link and flood checks as communities.

## Notifications

A reply notifies its recipient (`story_reply`, push category `stories`),
unless one of them blocked the other. Tapping it opens the story, and for
the author, its replies.

## App

- **Home:** the story ring. Your bubble first (tap to add, or to watch yours;
  long-press to add another), then people with unseen stories, then seen ones.
- **Viewer** (`/stories`): full screen, progress bars, 6 seconds per story.
  Tap right for next, left for back, hold to pause, swipe down to close.
  Viewers get reactions and a private reply field. Authors see views and
  replies.
- **Composer** (`/story-composer`): pick a kind, search Spotify or paste a
  link, see a live 9:16 preview, choose the audience and replies, share.
- **Story privacy** (`/story-settings`).

## Data

Migration `20261117000000_music_stories.sql`: `music_stories`,
`music_story_views`, `music_story_reactions`, `music_story_replies`,
`story_settings`, `story_hidden_viewers`, `story_mutes`, the `story-media`
bucket, reports (`music_story_id`, `music_story_reply_id`), notification type
`story_reply`, and personal data export. Edge Functions: `music-stories`
(new), `media-purge` (new, `verify_jwt = false`), `upload-image`,
`send-social-notification`, `daily-vibe` (shared Spotify helper).
