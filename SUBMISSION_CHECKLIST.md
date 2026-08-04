# Vibra Submission Checklist

## Required Before Upload
- real `key.properties` created
- real `android/app/google-services.json` added
- real `ios/Runner/GoogleService-Info.plist` added
- `.env` filled with production values
- Supabase migrations applied
- Supabase Edge Functions deployed
- Spotify redirect URI registered as `com.vibra.app://callback`

## Quality Gates
- `flutter analyze` passes
- `flutter test` passes
- Android release build succeeds
- iOS release build succeeds
- login flow works on physical device
- push token is stored in `users.fcm_token`

## Store Materials
- Privacy Policy URL is public
- Terms of Service URL is public
- Support URL or support email is real
- screenshots are prepared
- app icon is final
- release notes are ready

## Metadata Checks
- app name: `Vibra`
- Android package: `com.vibra.app`
- iOS bundle: `com.vibra.app`
- version: `0.1.0`
- build: `1`

## Final Functional Checks
- Spotify connection works
- home recommendations load
- event detail opens correctly
- settings legal/support screens open
- no crash on startup without optional services

## Final Decision
- ready for TestFlight / internal testing
- ready for Play internal testing
- ready for production submission

