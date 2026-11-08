# VIBRA Feed

A personalized, music-focused feed (spec section 15).

## What people can publish

| Kind | Content |
| --- | --- |
| Recommendation | a song, album, artist or playlist, and why to listen |
| Song / Album / Playlist | that item, with optional text |
| Review | a song or album, a 1–5 rating and text (both required) |
| Discovery | a song, album, artist or playlist you just found |
| Opinion | text only (up to 2000 characters) |
| Concert photo | a photo, optionally tagged with a concert you saved or are going to |
| Share | someone else's public post, with an optional comment |

Music items come from Spotify search (re-fetched by the `feed-posts` Edge
Function, so title, artwork and link are Spotify's) or a link to Apple
Music, YouTube, SoundCloud or Bandcamp with typed text. Only metadata,
artwork on Spotify's CDN and a link back are stored. No audio, ever.
Spotify items show the attribution line and "Listen on Spotify".

Concert photos go through `upload-image?bucket=feed-media` (re-encoded, so
GPS and camera metadata are stripped) into the private `feed-media` bucket,
readable only while the post is visible to the reader. The hourly
`media-purge` worker deletes photos no post uses.

## Interactions

- **Like** (heart, with a count) and **reactions** (the five VIBRA emoji).
- **Comments** with one level of replies. The author can turn comments off,
  and delete any comment on their post.
- **Share**: repost to your own feed with an optional comment, or copy the
  link to the music. A share is shown only while its original is still
  visible to the reader, and sharing the same post twice is refused.
- **Bookmarks**: private, in "Saved posts" (from the feed and from Profile).
- **Not interested**: removes a post from your feed.
- **Profiles**: a person's latest posts appear on their profile, with "See
  all". Profile → "Your posts" lists yours.
- **Reporting**: posts and comments (3 different reporters hold them for
  review), plus blocking from any post or comment.

## Ranking ("For you")

`get_feed('for_you')` scores visible posts from the last 14 days. Every
signal is bounded, so none can dominate:

| Signal | Weight |
| --- | --- |
| You follow the author | 3.0 |
| Accepted connection | 2.5 |
| Musical affinity with the author | up to 1.5 |
| You share a community with the author | 1.0 |
| Post genres in your Musical DNA or picked genres | up to 2.0 |
| Post genres match communities you joined | up to 0.8 |
| An artist in your Musical DNA | 1.0 |
| Your own likes/comments on the author's posts (30 days, log-scaled) | up to 1.5 |
| Distinct people who engaged, excluding the author (log-scaled) | up to 0.5 |
| Baseline, so new people can surface | 0.2 |

Then: freshness decay (half after ~33 hours), ×0.6 for each time you were
already shown the post (hidden after 4), and ×0.5 for each extra post from
the same author or ×0.35 for each repeat of the same song or album in one
feed. Post genres are catalogue keys classified on the server from the
provider's artist genres.

**Avoiding engagement manipulation:** popularity is a small capped signal,
never raw counts; the author's own engagement doesn't count; likes and
reactions never send notifications; the same link or text twice in a day,
or the same comment twice on a post, is refused; there are rate limits;
and every post shows why it is in "For you".

## Chronological options

- **Following**: people you follow, your connections and you, newest first.
- **Latest**: every post visible to you, newest first.

## Privacy

Posts are visible to everyone (default, chosen in the composer) or to
connections and musical matches only, using the same audience rules as
Daily Vibe and Stories. Blocks and test segments always apply. Impressions
and bookmarks are private, and impressions are deleted after 30 days.

## Limits

Posts: 5 a minute, 50 a day. Comments 10 a minute (300 a day), reactions 60,
bookmarks and post settings 30, impression updates 60 a minute. Text goes
through the same link and flood checks as communities.

## Notifications

A comment notifies the post's author, and a reply notifies the comment's
author (`feed_comment`, push category `feed`), unless one of them blocked
the other. Tapping it opens the post.

## Data

Migration `20261118000000_vibra_feed.sql`: `feed_posts`,
`feed_post_reactions`, `feed_comments`, `feed_bookmarks`, `feed_impressions`,
the `feed-media` bucket, reports (`feed_post_id`, `feed_comment_id`),
notification type `feed_comment`, and personal data export. Edge Functions:
`feed-posts` (new), `media-purge` (renamed from `story-media-purge`, now
cleans both buckets), `upload-image`, `send-social-notification`.
