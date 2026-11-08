# Notification Center

One notification system for all of VIBRA (spec section 22).

## In the app

- **Notification center** (`/notifications`): the bell on Home (with the
  unread count), also in Settings.
  - Notifications are grouped by Today / This week / Earlier, unread ones
    marked.
  - Grouped activity shows its count ("3 updates"). "Mark all read" clears
    the badge.
  - Tapping one opens where it leads (the same routing as a push tap).
- **Preferences** (`/notification-settings`, from the center or Settings):
  - master push switch;
  - a push switch per category;
  - quiet hours;
  - daily push limit (5–50, default 20).

  It also says when this device has no push registration: everything still
  appears in the center. Turning a category off stops its pushes. In-app
  notifications are always kept.

## Categories

| Category | Notifications |
| --- | --- |
| Vibra requests | new connection request, request accepted (new) |
| Messages | direct messages, message requests, event live chat |
| Community activity | comments on your community posts (new) |
| Circles | invitations, messages, plans |
| Concert announcements | new concerts by artists you listen to, event updates |
| Event reminders | a week before, the day before, the day of |
| Recommendations | public recommendations and discoveries from people you follow (new), new musical matches |
| Daily Vibe, stories and posts | comments and replies on what you share |
| Musical discoveries | someone saved a song you shared (new) |
| VIBRA updates | your music week, re-engagement suggestions |

## One delivery policy

Every worker (`send-social-notification`, `send-chat-notification`,
`send-notifications`, `event-reminders`, `retention-notifications`)
delivers through `_shared/notification_delivery.ts`. That calls
`record_notification` (SQL, service role), which:

1. refuses notifications from someone either person has blocked;
2. **groups** repeats: an unread notification with the same group key in
   the last 12 hours is updated ("3 updates") instead of a new one;
3. decides whether a push is allowed. It must pass all of these:
   - master push switch on;
   - the category's switch on;
   - outside quiet hours in the user's time zone (direct messages are
     exempt);
   - no push for the same group in the last 30 minutes;
   - under the daily push cap;
   - for low-priority categories (communities, recommendations,
     discoveries, updates), the first push of that category today.

Group keys group messages per sender, live chat per event, comments per
post or vibe, discoveries and recommendations per day.

**Push provider:** pushes are sent only through FCM, authorized with
Firebase's service account (`_shared/fcm.ts`) and a device token
registered by the app. Without that configuration, or without a device
token, notifications stay in-app.

## Data

Migration `20261125000000_notification_center.sql`:

- **notifications columns:** `category`, `group_key`, `group_count`,
  `actor_id`, `push_sent`, `read_at`;
- **types and categories:** new notification types and the
  `notification_category()` mapping;
- **preferences:** old per-feature push switches are migrated to category
  switches (anything off stays off); `notification_preferences.push_daily_cap`;
- **functions:** `record_notification`, `get_notifications`,
  `get_unread_notification_count`, `mark_notifications_read`,
  `get_notification_settings`, `set_notification_category`,
  `set_notification_schedule`;
- **triggers** for accepted requests, community comments, saved songs and
  recommendations, plus `get_recommendation_audience` (followers who can
  see the author, at most 300);
- **retention:** read notifications are deleted after 90 days, all after
  180.
