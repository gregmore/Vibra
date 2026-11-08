# VIBRA Concert Match

Connect through one concert. Migration `20261115000000_concert_match.sql`.
App: `/concert-match`, opened from "Who's going?" → Concert Match on the
event screen. Guarantees are pinned by
`test/core/concert_match_privacy_test.dart`.

## 1. Who appears (`get_concert_matches`)

| Person | Shown as | Rule |
|---|---|---|
| Plans visible to you | Going / Maybe / Interested | the attendee's own visibility choice (Who's Going rules) |
| A mutual musical match who loves this artist | "Also loves {artist}", with the affinity % | both consented to matching, and the artist is in your cached shared artists. **Their attendance is not shown.** |

* **Order:** going, then maybe, interested, artist fans; then by affinity.
* **Blocks and test segments** always apply.
* **The headline counts only plans visible to you.** It reads "You and 4
  other people are interested in this concert." when you've saved the
  event, or "4 people you can see are interested…" otherwise.
* **Never returned:** location, distance, city, travel details or
  timestamps.

## 2. Actions

* **Send Vibra:** the existing connection request.
* **Message:** only after the connection was accepted (spec: "starting a
  conversation after acceptance").
* **Create event group:** a circle based on this concert (the event is
  already shared in it), plus an **invitation** to each selected person.
  * People join only if they accept.
  * Only people you may invite to a circle can be selected: connections
    and mutual musical matches.
* **Share to a circle:** adds the event to one of your circles and posts
  its name and date in the chat.
* **Group activities:** circle **plans**, such as "Dinner before the show"
  or a meeting point.
  * Each plan has a title, an optional time and optional free-text
    details. Members tap "I'm in".
  * The author or an admin removes a plan.
  * Only circle members can see plans.
  * Any place is text a member chose to write; nothing is derived from
    location.

## 3. Data

`circle_plans` and `circle_plan_participants` are readable only by
members. They're written through server functions that check
membership, the rate limit and the spam rules, and they're included in
the personal data export.
