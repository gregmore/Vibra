# VIBRA Who's Going?

Social discovery on the event screen. Migration
`20261114000000_whos_going.sql`; app `WhosGoingSection` on event detail.
Guarantees are pinned by `test/core/whos_going_privacy_test.dart`.

## 1. Participation states

**Interested** (saved), **Maybe** and **Going** are the buttons on the
event screen. Tapping the selected one again removes it.

* "Not going" rows from earlier versions stay valid but are never shown
  to anyone.
* The "Saved" list in My events now covers both interested and maybe.

## 2. Visibility (the attendee decides)

| Choice | Who sees you on the event |
|---|---|
| Only me (**default**) | nobody |
| Friends | your accepted connections |
| Friends & matches | connections, plus people with a mutual musical-affinity pair (both consented to matching) |
| Everyone | anyone signed in |

* **Default, plus per event.** There's a default for all events
  (`privacy_preferences.attendance_visibility`) and an optional override
  per event (`event_attendees.visibility`). Once you've set a state, the
  event screen shows "Who can see your plans". From there you can change
  this event or use the choice for all your events.
* **Nothing changes until you choose.** Attendance has been private since
  `20260830000000`. With the default "Only me", nobody's attendance
  becomes visible until they choose otherwise.

## 3. What the event screen shows (`get_event_social`)

* **Counts:** going, maybe and interested, counting **only the people you
  can see**. Private rows are never counted.
* **People, in three groups:**
  * friends;
  * compatible people, with their affinity %;
  * others.
* **Each person shows:** their state, and Send Vibra (the existing
  connection request) when you aren't connected yet. Tapping them opens
  their profile, where messaging follows the existing message rules.
* **Communities for this event:** the artist's community and the
  family-wide genre community.

## 4. Privacy rules

* **The function never returns:** private attendance, "not going", the
  caller themself, timestamps, or people blocked in either direction or
  in another test segment (`may_access_message`).
* **The table stays owner-only.** `event_attendees` itself keeps its
  owner-only RLS; this function is the only other way in.
* **Same Frequency.** Its shared-event signal (still opt-in on both
  sides) now also counts "interested".
* **Concert recommendations** now also count "interested" as a past
  interest.
