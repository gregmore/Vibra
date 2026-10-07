# Vibra Privacy Policy

Last updated: `2026-08-27` · Policy version: `2026-08-27`

This is the product-facing privacy notice for Vibra. It must be reviewed by a qualified privacy lawyer before launch, completed with the controller's legal identity/address and published at a stable public URL.

## What Vibra processes and why

| Data | Purpose | Basis / control | Retention |
|---|---|---|---|
| Account profile (email, username, display name, avatar, bio) | Create and secure the account | Service contract | Until account deletion |
| Spotify ID and music profile (top artists/tracks/genres, listening heatmap) | Music matching and event recommendations | Explicit optional Spotify/matching choice | Until disconnect or account deletion |
| Encrypted Spotify OAuth credentials | Refresh the voluntary Spotify connection | Service requested by the user | Until disconnect or account deletion |
| Precise/last location | Nearby events and Live proximity | Explicit optional location choice | Cleared after 30 days without a refresh |
| Saved events, matches, social actions and ticket clicks | Deliver features and improve recommendations | Service / optional recommendation processing | Interaction and ticket logs: 12 months; account data until deletion |
| Direct messages | Conversation service and user safety | Service contract | Message content: 24 months, then replaced with a retention marker |
| Live-event messages | Temporary event chat | Service contract | 30 days |
| Push token and notification choices | Send requested service notifications | Consent/device permission | Token cleared on logout; preferences until changed or deletion |

Vibra does not use a single forced “accept all” choice. Location, Spotify matching, service notifications and marketing notifications are controlled separately in **Settings → Privacy and personal data**. Marketing is optional and never required to use Vibra. Disconnecting Spotify deletes its stored credentials and music profile; withdrawing a device permission may require changing it in the device settings.

## Sharing and processors

We use Supabase for authentication, database, storage and edge functions; Spotify for the account connection and music data requested by the user; Firebase Cloud Messaging for push delivery; and Ticketmaster, Songkick and Bandsintown to retrieve event data. A provider processes only the data necessary for its service under its own terms and privacy notice. Vibra does not sell personal data.

## Your rights and how to use them

From **Settings → Privacy and personal data** you can immediately generate a readable JSON export containing your profile, Spotify connection metadata (never OAuth tokens), events, messages, matches and relevant interaction logs. This automated response is immediate; requests requiring manual review are answered within one month unless GDPR law permits an extension, which we will communicate.

You can correct profile information in the app, change optional processing at any time, disconnect Spotify, or request account deletion in Settings. For access, portability, correction, restriction, objection or a complaint, contact `privacy@vibra.app` after the controller contact is confirmed before release.

## Account deletion and backups

Account deletion revokes sessions, deletes the profile, Spotify credentials, music data, saved events, recommendation logs, matches, notifications and associated application records. Direct messages sent by the deleted user are anonymized: the sender identity, text, media and message metadata are removed and a neutral marker remains for the other participant. Messages received from another person remain their data. Chat-media objects are removed before deletion. The production backup schedule must enforce a maximum 30-day backup retention; deleted data may persist only in an access-restricted backup until its scheduled expiry and is not restored into the active service except for disaster recovery.

## Security

The app communicates with Supabase and providers over HTTPS/TLS. OAuth tokens are encrypted before server-side storage and are not exposed through client database policies. Row-level security isolates accounts and private data. Encryption at rest, key rotation, backup encryption, incident response and provider data-processing agreements are deployment obligations that must be verified in the production Supabase/Firebase configuration before release.

## Children

Vibra is not for people under 18. During registration users must confirm that they are at least 18. We will delete accounts identified as belonging to minors, subject to any applicable legal obligation.

## Operational controls

Run the trusted `apply_data_retention` database function daily using the production scheduler/service role, monitor failures, and document the backup retention configuration. The legal controller identity, DPO assessment, international-transfer assessment, records of processing and DPIA decision remain launch prerequisites.
