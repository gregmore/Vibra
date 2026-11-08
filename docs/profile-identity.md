# Profile — complete musical identity

The profile, rebuilt around musical identity (spec section 20). Both your
own profile (Profile tab) and other people's (`/user-profile`) use the same
server read and the same widgets (`profile_identity_widgets.dart`).

## What a profile shows

- **Sound signature:** the profile picture ringed by its owner's Musical
  DNA, one coloured arc per genre family sized by its share. Each family
  always has the same colour across VIBRA, so a profile is recognisable at a
  glance. Without a visible DNA the ring is the VIBRA gradient. Screen
  readers announce "Ana, sound signature: Hip-Hop, Electronic".
- **Identity:** name, @username, bio, top three families with percentages,
  "On VIBRA since", and the relation (your connection / musical match).
- **Sections**, in order:
  - Musical DNA;
  - Favourite genres;
  - Favourite artists;
  - Musical statistics;
  - Saved songs;
  - Shared playlists;
  - Upcoming events;
  - Communities;
  - Circles;
  - Musical activity.

## Who sees what

Each section has its own level, set in **Profile → Profile privacy** (also
linked from Privacy controls and from the lock icons on your own profile):

| Section | Default |
| --- | --- |
| Favourite genres, artists, statistics, shared playlists, communities, activity | Everyone |
| Upcoming events, circles | Connections |
| Saved songs | Only me |

"Connections" means accepted connections and mutual musical matches. The
photo, name, username and bio stay visible to anyone you can interact with.

Existing rules still apply inside each section, so the profile never
reveals more than before:

- **Musical DNA** keeps its own visibility setting.
- **Events:** each attendance keeps its Who's Going visibility (private by
  default), and concerts-attended counts are shown to the owner only.
- **Circles:** others only ever see circles they're in too.
- **Posts, playlists and vibes** keep their own audience.
- **Blocks and test segments** hide the whole profile.

Viewers see "Some sections of this profile are private" when something is
hidden, without saying which.

## Data

Migration `20261123000000_profile_identity.sql`:
`privacy_preferences.profile_sections`, `profile_section_level`,
`set_profile_section_visibility`, `get_profile_identity(user)` (SECURITY
DEFINER, gates each section as above). No Edge Function changes.
