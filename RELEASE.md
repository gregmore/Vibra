# Vibra Release Checklist

## 1. Variabili ambiente app

Compilare `.env` con:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
SPOTIFY_CLIENT_ID=
SPOTIFY_REDIRECT_URI=com.vibra.app://callback
TICKETMASTER_API_KEY=
SONGKICK_API_KEY=
BANDSINTOWN_APP_ID=
```

## 2. Secrets Edge Functions

Configurare lato Supabase:

```bash
supabase secrets set \
  SUPABASE_URL=... \
  SUPABASE_ANON_KEY=... \
  SUPABASE_SERVICE_ROLE_KEY=... \
  SPOTIFY_CLIENT_ID=... \
  SPOTIFY_CLIENT_SECRET=... \
  SPOTIFY_REDIRECT_URI=com.vibra.app://callback \
  FCM_SERVER_KEY=...
```

`FCM_SERVER_KEY` è opzionale se non vuoi inviare push reali al day one.

## 3. Migrazioni database

Applicare:

```bash
supabase db push
```

Verificare che esistano:
- `users`
- `users_public`
- `music_profiles`
- `events`
- `event_attendees`
- `friendships`
- `messages`
- `live_messages`
- `notifications`
- `user_matches`

## 4. Deploy Edge Functions

```bash
supabase functions deploy spotify-token-exchange
supabase functions deploy sync-music-profile
supabase functions deploy recommend-events
supabase functions deploy calculate-match
supabase functions deploy send-notifications
```

## 5. Spotify Dashboard

Verificare in Spotify Developer Dashboard:
- package name / bundle id coerente con app mobile
- redirect URI registrata: `com.vibra.app://callback`
- scope abilitati coerenti con l’app

## 6. Mobile platform setup

### Android
- allineare intent-filter per `com.vibra.app://callback`
- namespace/applicationId: `com.vibra.app`
- configurare release keystore usando `key.properties` (vedi `key.properties.example`)
- verificare permessi rete, notifiche e deep link

### iOS
- allineare URL scheme `com.vibra.app`
- bundle identifier coerente con `com.vibra.app`
- verificare Associated Domains se necessari
- configurare permessi notifiche

## 7. Firebase / Push

Configurare:
- `google-services.json`
- `GoogleService-Info.plist`
- Firebase Cloud Messaging

Senza questi file l'app continua ad avviarsi, ma push/Firebase restano disabilitati.

Verificare registrazione token FCM su tabella `users`.

## 8. QA pre-release

Verificare almeno:
- login Spotify completo
- sync profilo musicale
- home con eventi reali
- discover utenti/match
- chat diretta
- live chat evento
- dettaglio evento
- notifiche inserite in tabella

## 9. Build release

Eseguire localmente:

```bash
flutter pub get
flutter test
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

## 10. Store readiness

Prima della pubblicazione:
- privacy policy pubblica
- termini d’uso
- schermate store
- icona app finale
- splash definitiva
- analytics/crash reporting verificati
- review contenuti GDPR / dati musicali / geolocalizzazione

Documenti preparati nel progetto:
- `PRIVACY_POLICY.md`
- `TERMS_OF_SERVICE.md`
- `SUPPORT.md`
- `STORE_METADATA.md`
- `QA_CHECKLIST.md`
- `SUBMISSION_CHECKLIST.md`
- `key.properties.example`
