# Vibra Support

## Support Contact and SLA

Before release, replace these placeholders with real production contacts:

- Support email: `support@vibra.app`
- Privacy contact: `privacy@vibra.app`
- Legal contact: `legal@vibra.app`

The in-app support queue (`support_reports`) and `support@vibra.app` must be
monitored on business days. Initial response target: **within 48 hours**.

## In-app support workflow

- **Centro assistenza** offers searchable FAQ grouped by Account, Eventi,
  Chat/Match, Spotify and Privacy.
- **Segnala un problema** creates a row in `support_reports`; screenshot
  attachments stay in the private `support-attachments` bucket.
- Diagnostic payloads contain app/OS version, latest failed endpoint and a
  30-entry local log buffer. The client redacts bearer tokens, passwords,
  token query values and UUID-like identifiers before upload. Do not add a
  service-role key or raw HTTP request bodies to this payload.
- Low satisfaction is routed to the same report flow. Positive feedback may
  use the native store review dialog only after seven days, once per 90 days.
- To communicate a confirmed incident, add an `investigating` row to
  `service_incidents` (for example a Spotify or Ticketmaster outage). The app
  shows its message as a global banner; mark it `resolved` when closed.

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
