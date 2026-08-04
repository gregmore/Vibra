# Vibra

**Non ascoltare la musica. Vivila.**

## Setup rapido

1. Crea un file `.env` a partire da `.env.example` e compila le chiavi:
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`
   - `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`
   - (opzionali) `TICKETMASTER_API_KEY`, `SONGKICK_API_KEY`, `BANDSINTOWN_APP_ID`

2. Installa dipendenze:
   ```bash
   flutter pub get
   ```

3. Genera i file di codegen (Freezed/JSON/Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## Testing

### Unit + Widget tests
```bash
flutter test
```

### Integration test (emulator/device)
```bash
flutter test integration_test/spotify_oauth_flow_test.dart
```

Nota: il test di OAuth Spotify è **simulato lato UI** (non apre realmente il browser AppAuth).

## Database (Supabase)

La migrazione SQL iniziale è in:
- `supabase/migrations/0001_init_vibra.sql`
- `supabase/migrations/0002_user_matches_and_push_tokens.sql`

## Edge Functions

Funzioni principali collegate ai servizi:
- `recommend-events`
- `calculate-match`
- `send-notifications`
- `spotify-token-exchange`
- `sync-music-profile`

Per il deploy e l’esecuzione reale servono anche le env Supabase lato Edge:
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_ANON_KEY`
- `SPOTIFY_CLIENT_SECRET`
- `FCM_SERVER_KEY` (solo se vuoi push FCM reali)

Checklist completa di pubblicazione:
- `RELEASE.md`
- `PRIVACY_POLICY.md`
- `TERMS_OF_SERVICE.md`
- `SUPPORT.md`
- `STORE_METADATA.md`
- `QA_CHECKLIST.md`
- `SUBMISSION_CHECKLIST.md`

## Note

- La cartella `lib/data/models/` usa **Freezed + json_serializable**: i file `*.g.dart` e `*.freezed.dart`
  vengono creati dal comando build_runner.
