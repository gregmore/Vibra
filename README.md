# Vibra

Non ascoltare la musica. Vivila.

App Flutter per iOS e Android: concerti, mappa, community,
chat e modalità Live. Candidata di lancio: **1.0.0+3**. Spotify e affinità musicali
restano temporaneamente disattivati nella prima release pubblica. Identificatore mobile:
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

Su iPhone, la configurazione iOS Debug usa `RunnerDebug.entitlements` e
l'identificatore `com.gregoriomorelli.vibra.dev` per consentire la firma con un
Personal Team gratuito. In questa build non sono
disponibili Sign in with Apple e notifiche push. Avviare con
`flutter run -d <id-iPhone>`. Release e Profile mantengono le capability complete
e richiedono un team iscritto all'Apple Developer Program. Per provare queste
capability anche in Debug con un team abilitato, impostare in Xcode il valore
Debug di `CODE_SIGN_ENTITLEMENTS` a `Runner/Runner.entitlements`.
I servizi che verificano l'identificatore iOS (ad esempio Firebase/Google login)
richiedono una configurazione dedicata per l'app di sviluppo.
Il passaggio `sign_debug_framework.sh` firma il framework App completo con
l'identificatore del suo plist, evitando il mismatch prodotto dallo SDK Flutter
locale che conserva l'identificatore del binario stub durante la firma.

## Verifiche

```bash
flutter analyze --no-pub
flutter test --no-pub
npx --yes deno check supabase/functions/*/index.ts
npx --yes deno test --allow-env=FCM_SERVICE_ACCOUNT_JSON,FIREBASE_SERVICE_ACCOUNT_JSON supabase/functions/_shared/fcm.test.ts supabase/functions/calculate-match/index.test.ts supabase/functions/sync-music-profile/genres.test.ts
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

Correzioni e verifiche correnti: [chiusura del 18 ottobre](docs/launch-closure-20261018.md).
Il [report del 15 ottobre](docs/bugfixes-20261015.md) conserva le prove della candidata precedente.
La [candidata del 13 ottobre](docs/launch-readiness-20261013.md) rimane documentata
come riferimento storico.
