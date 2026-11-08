# VIBRA Circles

Small, invite-only music groups (2–12 people). Server: migration
`20261112000000_circles.sql` and `send-social-notification`. App:
`/circles` and `/circle`, opened from the Social tab. Consent guarantees
are pinned by `test/core/circles_consent_test.dart`.

## 1. What a circle has

| Feature | Implementation |
|---|---|
| Group profile and description | name, description and basis: genre, artist, concert (one of your saved events), interest or activity. Admins edit them. |
| Members | up to 12, with admins and members |
| Group chat | `circle_messages`, delivered live through Supabase Realtime. Only members can read it, and messages from people you blocked are hidden. |
| Shared playlist | a shared list of music links (Spotify, Apple Music, YouTube, SoundCloud, Bandcamp). The person who added a track, or an admin, removes it. Up to 200 tracks. |
| Shared events | members share their saved or "going" events. A concert circle starts with its event. |
| Invitations | admins invite. Invitations expire after 14 days and can be revoked. |
| Member management | admins remove members and promote admins. The last admin to leave hands over to the longest-standing member, and an empty circle is archived. |
| Notifications | in-app and push for invitations and new messages, through the existing worker. Each member can mute a circle, and the push setting key is `circles`. |

## 2. Consent

* **Membership comes only from creating a circle or accepting an
  invitation.** No server function adds another person; the test checks
  that only `create_circle` (the creator) and
  `respond_circle_invitation` (the invitee) insert members.
* **Who can be invited.** Only people you have a relationship with: an
  accepted connection, or a mutual musical-affinity pair (both consented
  to musical matching). Blocks and test segments always apply, and a
  block made after the invitation still stops the accept.
* **Declines are respected.** A declined invitation can't be re-sent to
  the same circle for 30 days.
* **Abuse limits:** 10 invitations a minute and 40 a day, 5 new circles a
  day, 30 circles per person, and the shared spam checks on names and
  messages.

## 3. Automatic suggestions (`lib/domain/usecases/circle_suggestions.dart`)

VIBRA proposes circles to **one** user, for example "A circle of 5 people
who share Trap." Nothing is created or sent until that user taps "Create
and invite". Then each person gets an invitation they can accept or
decline.

* **Who can be proposed.** Same Frequency people (mutual consent, already
  visible to the user) with affinity ≥ 65.
* **Themes, in order:**
  1. artists shared with at least 2 of those people;
  2. the user's strong subgenres (≥ 15% of their DNA);
  3. their top 3 genre families.
* **Shape.** 2–4 invitees per suggestion and at most 3 suggestions. Each
  person appears in at most 2 suggestions, and two suggestions never
  contain exactly the same group.

## 4. Not included yet

* Circles around a shared activity have no special tools; the topic is
  free text.
* Playlists are lists of links, not synced streaming playlists. That would
  need extra Spotify scopes and the user's write access.
* Message editing, deleting and attachments.
