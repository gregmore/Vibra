# Vibra QA Checklist

## Authentication
- splash opens correctly
- onboarding flows to login
- Spotify OAuth completes and returns to app
- authenticated user is redirected to home
- unauthenticated user is redirected to login for protected routes

## Profile and Music Sync
- profile is created after first login
- Spotify sync stores top artists, tracks, and genres
- music profile reloads correctly on next app start

## Event Discovery
- home shows recommended events
- explore shows events on the map and in the list
- event detail opens from home, explore, and my events
- empty state is shown cleanly when no events are available

## Social
- matched users load correctly
- friendships list loads
- direct chat opens and displays messages
- user profile screen does not crash when no match is available

## Live Mode
- live screen opens without crash
- live messages stream loads
- sending a live message works for authenticated users
- safe fallback is shown if no live event is available

## Notifications
- notification permission prompt is shown
- FCM token is requested
- `users.fcm_token` is updated in Supabase
- in-app notifications load and can be marked as read

## External Services
- Ticketmaster works when API key is configured
- app degrades safely when optional APIs are missing
- Firebase missing config does not crash startup

## Mobile Native
- Android deep link returns correctly from Spotify auth
- iOS URL scheme returns correctly from Spotify auth
- app remains portrait as expected
- app icon and launch screen are correct

## Release Validation
- `flutter analyze` passes
- `flutter test` passes
- Android release build succeeds
- iOS release build succeeds
- Privacy Policy URL is public
- Support email and URLs are real

