# VIBRA Concert Groups

Groups organised around one event. A concert group is a circle based on
an event (`docs/circles.md`), so it inherits the chat, invitations and
consent, the shared playlist, events and plans, and notifications. This
section adds participation, moderation and reporting.
Server: `20261112000000_circles.sql` (extended; not yet deployed) and
`20261115000000_concert_match.sql`. Guarantees are pinned by
`test/core/concert_groups_moderation_test.dart`.

## 1. What a group shows

| Requirement | Implementation |
|---|---|
| Event details | the concert card at the top of the group (it opens the event) |
| Group members | the members list shows role and participation |
| Group chat | the circle chat (live) |
| Participation status | "Your status": Interested / Maybe / Going, stored on the membership and **visible only to the group's members**. It's separate from your public "Who's going" visibility. |
| Group invitations | circle invitations: consent-based, people join only if they accept |
| Shared information | shared events, the playlist and plans |
| Notifications | invitations, new messages and **new plans**, through `send-social-notification`. Members who muted the group, or who are in a block with the sender, are skipped. |

**Ways in from the event screen:** "Who's going?" → "Your groups for
this event" lists your groups, and "Start a concert group" opens Concert
Match, which creates the group and sends invitations.

## 2. Moderation

* **Admins manage membership:** invite, remove, make admin and **ban**.
  A ban removes the person, cancels pending invitations and blocks
  future invitations and accepts.
* **Messages:**
  * a sender deletes their own message;
  * an admin removes any message, and its pending reports become
    `action_taken`;
  * an admin restores a held message.
* **Auto-hold.** **Two** distinct reports hold a message, because groups
  are small. Only the sender and the admins still see it, marked as
  hidden.

## 3. Reporting

* **What can be reported:** long-press a message → Report, or a member's
  menu → Report member. Both go to the shared `reports` table, which has
  the existing rate limit (5 a minute).
* **Validation:**
  * a reported message must be visible to the reporter and sent by the
    reported person;
  * a reported member must share a group with the reporter;
  * nobody can report themselves.
* **Blocking** uses the existing block, from the same menus.

## 4. Note on migrations

None of these database changes are deployed yet, so the circles
migration was extended in place instead of re-declaring its functions in
a new file.
