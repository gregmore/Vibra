# Vibra Support

## Support Contact

Before release, replace these placeholders with real production contacts:

- Support email: `support@vibra.app`
- Privacy contact: `privacy@vibra.app`
- Legal contact: `legal@vibra.app`

## Recommended Support Scope

Support should cover at least:
- login and account issues
- Spotify connection issues
- event discovery problems
- live chat and messaging problems
- notification and permission issues
- privacy and data deletion requests

## Recommended Response Flows

### Account Access
- verify the user’s registered email
- check authentication provider used
- confirm whether the issue is login, redirect, or token related

### Spotify Connection
- verify Spotify permissions were granted
- confirm redirect URI is configured correctly
- confirm Edge Functions and secrets are deployed

### Notifications
- confirm system notification permission is enabled
- confirm Firebase files are installed
- confirm `users.fcm_token` is populated in Supabase

### Privacy Requests
- route data access, correction, export, and deletion requests through a dedicated privacy contact

## Public Support URL

Before app store submission, publish a real support page and add its URL to store metadata.

## Internal Note

If you ship without a website, at minimum provide:
- a working support email
- a working privacy policy URL
- a working legal contact

