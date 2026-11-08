# VIBRA Musical Communities

Communities around genres, artists and interests. Server: migration
`20261111000000_communities.sql`. App: `/communities` (opened from the
Social tab), `/community`, `/community-post`, `/community-moderation`.
Guarantees are pinned by `test/core/communities_security_test.dart`.

## 1. Kinds

| Kind | Example | Defined by |
|---|---|---|
| Genre | Underground Rap, Alternative R&B | a catalogue key (`genre_key`) and its family |
| Artist | Travis Scott Fans | `artist_name`, one community per artist |
| Interest | Vinyl Collectors | free topic |

* **Official communities.** 25 are seeded: one per genre family plus key
  scenes (Underground Rap, Trap, Drill, Alternative R&B, Techno, House,
  Indie).
* **User communities.** Anyone can create one and becomes its owner.

## 2. Features

* **Discover:** search, the "For you" recommendations (§4), your
  communities, and Explore (official first, then by size).
* **Join / leave.** If the owner leaves, the longest-standing moderator
  takes over, or else the longest-standing member.
* **Members:** owner and moderators first. Blocked people and other test
  segments are never listed.
* **Posts:**
  * **post:** text;
  * **discussion:** needs a title;
  * **music:** shares a Spotify / Apple Music / YouTube (Music) /
    SoundCloud / Bandcamp link, with optional title and artist. Only
    `https` links to those hosts are accepted;
  * **event:** links a catalogue event.
* **Comments and reactions.** Reactions are 🔥 ❤️ 🎧 👏 🤯. Only members
  can post, comment and react; anyone signed in can read.
* **Events:** upcoming events (90 days) by the community's artist, or
  matching the genre family. The genre match is the same coarse
  Ticketmaster comparison used by Music Radar.

## 3. Moderation and abuse protection

| Need | Implementation |
|---|---|
| Report content | `reports` gains `community_post_id` / `community_comment_id`. The existing trigger validates them (the content must be by the reported person and visible to the reporter, and you can't report yourself). The existing per-minute limit applies. |
| Auto-hold | 3 distinct pending reports set `held_for_review`. Only the author and moderators still see it, marked as hidden, until a moderator restores or removes it. |
| Block users | The existing block. Under RLS, posts, comments and members of blocked people (either direction) disappear, and you can't comment on or react to a blocked author's post. |
| Remove content | Moderators remove (soft, with an optional reason) or restore. Pending reports on it become `action_taken`. Authors delete their own content. |
| Permissions | owner > moderator > member. Moderators remove, restore and ban members. Only the owner bans moderators and promotes or demotes them. Nobody can ban the owner. |
| Bans | Membership is removed, rejoining is refused, and posting, commenting and reacting are refused |
| Rate limits | Shared per-minute limiter: create 2, join 20, post 5, comment 10, reaction 60, moderation 30 |
| Spam | Daily caps (3 new communities, 30 posts, 200 comments; at most 10 owned communities and 200 memberships). The same text within 10 minutes is refused. At most 2 links. The existing suspicious-domain list applies. Long single-character floods are refused. |
| No bypass | Clients have `SELECT` only. Every write is a `SECURITY DEFINER` function that checks the session, membership, ban and block state. Reads use RLS. |

## 4. Recommendations (`lib/domain/usecases/community_recommendations.dart`)

From the user's current Musical DNA:
* **Artist community:** the artist is in the user's Spotify top artists.
  The reason reads "Travis Scott is one of your top artists."
* **Family community:** the family's share of the DNA is at least 8%.
  The reason reads "Hip-Hop is 62% of your Musical DNA."
* **Subgenre community:** the subgenre's share is at least 8%. It gets a
  small boost over a family community of the same weight.

Joined communities are skipped, at most 2 come from one family, and size
is only a tiebreaker. Top artists without a community are offered as
"Start the X community". The headline reads "Based on your musical
profile, you might enjoy X." No DNA means no recommendations.

## 5. Links to other features

* **Same Frequency:** communities two people share are a signal (weight
  0.05) and a reason ("You're both in Underground Rap").
* **Music Radar:** shows communities for the area's top genre families.

## 6. Not included yet

* Images or video in posts. Only text, music links and event links are
  supported.
* Editing posts.
* A platform-wide review console for reports. Reports are stored for the
  existing moderation process.
* Push notifications for comments.
