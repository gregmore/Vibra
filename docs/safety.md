# Social safety and privacy

One set of safety rules across VIBRA (spec section 21). Every check runs on
the server (RLS, SECURITY DEFINER functions, triggers). The app only calls
it.

## Safety Center

Settings → **Safety & privacy** (also on Profile). It shows every control
and its current state:

- **People:** blocked people (list, unblock).
- **What others see:** profile privacy per section, Musical DNA visibility,
  story audience and hidden viewers, event attendance.
- **Location:** precise location consent, and Music Radar (off, on and
  visible, or on and hidden). The exact position is never shown to anyone.
- **Your data:** taste history, VIBRA AI, and all privacy controls
  (consents, notifications, data export).
- **Reporting:** how reporting works, and a link to contact support.

## Blocking

Block from a person's profile (new menu: Report this person / Block), or
from any post, comment, story, reply, vibe, community or circle menu. All of
them go through `block_user`, which is rate-limited (20 a minute).

**What a block does, everywhere:**

- **Hidden in both directions:** messages and message requests, event live
  chat, circle chat, community posts and comments, Daily Vibes, stories,
  story replies, feed posts and comments, Who's Going, Music Radar, Same
  Frequency, musical matches, profiles, notifications.
- **New in this section:** the two people can no longer follow each other,
  send connection requests, invite each other to circles or save each
  other's profile (`reject_blocked_pair` triggers on `follows`,
  `friendships`, `circle_invitations`, `saved_profiles`).
- **Also new:** blocking removes existing follows and connections in both
  directions, revokes pending circle invitations between them, and removes
  saved profiles (`apply_block`).
- **The blocked person is never told.** Refusals return a single generic
  "user unavailable", so a block can't be detected. The blocked-people list
  only ever shows people you blocked.
- **Unblocking** doesn't restore what the block removed.

## Reporting

- **People:** from their profile.
- **Content:** messages, community posts and comments, circle messages and
  members, Daily Vibes and comments, stories and story replies, feed posts
  and comments.

Each content report is checked server-side (`protect_report_submission`):
you can only report content you can actually see, or a message or reply
sent to you, and never yourself. Content is held for review after several
reports (3 for posts, stories, vibes and comments; 2 in circles; 1 for a
private story reply).

**New:** the same report twice within 7 days is refused ("you already
reported this"), on top of the existing 5 reports a minute, with a cap of 30
a day.

## Moderation and spam

These were already in place:

- **Communities:** moderators and owners remove content and ban members;
  there's a moderation queue.
- **Circles:** admins remove members, ban, and hide or restore messages.
- **Text checks** on all user text: link limits, suspicious links, flooding.
- **No repeats:** duplicate posts, comments and shares are refused.
- **Rate limits** on every write: messages, reactions, comments, posts,
  stories, invitations, searches, feedback, the AI assistant, privacy
  changes.

## Privacy

- **The app reads only the user's own `users` row.** Other people come
  through `profile_discovery` and purpose-built functions that return only
  what the owner allows.
- **Owner-only tables:** blocks, bookmarks, feedback, impressions, saved
  songs, settings and history.
- **Profile visibility** (section 20) and Musical DNA visibility are set per
  section. Attendance is per event.
- **Location:** consent-based; the radar uses coarse cells only.

## Data

Migration `20261124000000_social_safety.sql`:

- block functions: `blocked_between`, `reject_blocked_pair` and its 4
  triggers, `apply_block`;
- `block_user`, `unblock_user`, `get_my_blocked_users`;
- `limit_reports`, `get_my_safety_overview`, and the `blocks` rate limit.
