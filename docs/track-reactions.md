# Track Reactions

Music-specific reactions for shared songs (spec section 16), and a personal
collection of songs you discover.

## Reactions

When someone shares a song, others react with dedicated musical reactions:

| Key | Emoji | Label |
| --- | --- | --- |
| `fire` | 🔥 | Fire |
| `obsessed` | 😍 | Obsessed |
| `underrated` | 💎 | Underrated |
| `classic` | 🏆 | Classic |
| `new_discovery` | ✨ | New discovery |
| `on_repeat` | 🔁 | On repeat |

A **song share** is:

- a Daily Vibe (always a song);
- a "Now listening" story;
- a feed post about a track, or a share of one;
- a community music post linking a song (Spotify track, Apple Music,
  YouTube, SoundCloud or Bandcamp).

Everything else keeps the general reactions (🔥 ❤️ 🎧 👏 🤯). Feed posts keep
their like button on every post.

**The server decides which set applies.** Each toggle RPC checks the
reaction against the content (`vibra_private.require_reaction`), so a
client cannot put a track reaction on a non-song or the reverse. Existing
Daily Vibe reactions are mapped to the closest musical one (❤️ → Obsessed,
🎧 → On repeat, 👏 → Classic, 🤯 → New discovery).

## Reusable components

`lib/presentation/widgets/music_reactions.dart`:

- `ReactionChips`: chips with emoji, name (track reactions) and count; used
  by Daily Vibe and Communities.
- `ReactionButtonRow`: large buttons for the dark story viewer.
- `showReactionPicker`: a sheet to pick one reaction; used by the Feed.
- `SaveSongButton`: "Add to discoveries", anywhere a song is shared.
- `offerToSaveDiscovery`: after a "New discovery" reaction, offers to keep
  the song.

The sets and emoji live in `lib/domain/entities/music_reaction.dart`
(`MusicReactions`), matching `public.track_reactions()` and
`public.general_reactions()`.

## Discoveries (personal collection)

The existing Discoveries collection now accepts songs from every song
share through `save_track_to_discoveries(source, id)`, where source is
`vibe`, `story`, `post` or `community`. It saves only songs (`not_a_song`
otherwise) from content you can see, up to 500 songs, without duplicates.
Each song remembers where it was found and who shared it ("via Ana"). That
name disappears if either of you blocks the other.

The collection is private to its owner. Open it from Daily Vibe or
Profile → Discoveries. Each song opens on its provider and can be removed.

## Data

Migration `20261119000000_track_reactions.sql`: reaction constraints on
`daily_vibe_reactions`, `music_story_reactions`, `feed_post_reactions` and
`community_reactions`; the four toggle RPCs redefined with validation;
`discovery_collection` gains `source`, `from_story_id`, `from_post_id`,
`from_community_post_id` and `found_via`; `save_track_to_discoveries` and
`get_discoveries`; `save_vibe_to_discoveries` kept as a wrapper. No Edge
Function changes.
