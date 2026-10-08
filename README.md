# Vibra

Non ascoltare la musica. Vivila.

App Flutter per iOS e Android: concerti, profilo Spotify, affinità musicali,
chat e modalità Live. Versione di lancio: **1.0.0+2**. Identificatore mobile:
`com.vibra.app`.

## Avvio locale

1. Compilare `.env` usando `.env.example`.
2. Generare l'asset pubblico: `python3 script/security/prepare_client_env.py`.
3. Eseguire `flutter pub get`, quindi `flutter run`.

Solo `.env.public` entra nell'app. I segreti Spotify, dei provider di eventi e
Firebase restano sul backend. I font Syne e Inter sono inclusi con licenze OFL;
la UI non li scarica al primo avvio.

Il [report di alleggerimento](docs/app-size-20261008.md) documenta le dipendenze
rimosse, le verifiche e la riduzione del download Android stimato del 31,23%.

I modelli Freezed/JSON si rigenerano con
`dart run build_runner build --delete-conflicting-outputs`.

## Verifiche

```bash
flutter analyze --no-pub
flutter test --no-pub
npx --yes deno check supabase/functions/*/index.ts
npx --yes deno test --allow-env=FCM_SERVICE_ACCOUNT_JSON supabase/functions/_shared/fcm.test.ts supabase/functions/calculate-match/index.test.ts supabase/functions/sync-music-profile/genres.test.ts
python3 script/release/preflight.py --technical-only
```

Eseguire i comandi Flutter in sequenza: test e build possono rigenerare i
registrant nativi. I test automatici restano strumenti di verifica; generatori
demo, bot, credenziali condivise e flussi seeded sono stati rimossi.

## Pubblicazione

Seguire [RELEASE.md](RELEASE.md) e [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md).
La configurazione store parte da
[store_config.example.json](script/release/store_config.example.json).

```bash
script/release/build_store_release.sh android
script/release/build_store_release.sh ios
```

La procedura richiede configurazione completa, controlla il backend collegato,
esegue analisi/test e prepara artefatti firmati in `release/`. Senza i requisiti
necessari termina con un elenco delle mancanze. Una build iOS senza firma serve
alla verifica tecnica e non può essere caricata negli store.

Backend e migrazioni: [supabase/PRODUCTION_SETUP.md](supabase/PRODUCTION_SETUP.md).
Stato verificato della preparazione: [docs/store-readiness-20261007.md](docs/store-readiness-20261007.md).
