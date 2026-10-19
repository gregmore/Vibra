# Rilascio Vibra 1.0.0+3

Package Android e bundle iOS: `com.vibra.app`. I controlli tecnici completati e
le mancanze effettive sono in [docs/launch-closure-20261018.md](docs/launch-closure-20261018.md).

## Prima release pubblica senza Spotify

La scelta confermata dal titolare disattiva collegamento Spotify, importazioni,
affinità e raccomandazioni musicali. Eventi, mappa, salvataggi, ricerca utenti,
amici e chat restano disponibili; dati precedenti, export e disconnessione
rimangono gestibili. Client `SPOTIFY_ENABLED=false`, secret backend omonimo
`false` e riga SQL `launch_features.spotify=false` sono allineati. La sospensione
è distribuita: [riscontri](docs/backend-spotify-pause-20261013.md).
Lo script compila la disponibilità scelta in `release/store-config.json`.
La riattivazione richiede approvazione e QA del provider, un nuovo bundle e
materiali store corrispondenti; non basta cambiare un solo controllo.

## Configurazione

Copiare `script/release/store_config.example.json` in `release/store-config.json`
e compilare titolare, indirizzo, contatti attivi e URL HTTPS pubblici. Allineare
le email in `lib/core/constants/app_constants.dart` e i documenti legali con il
titolare reale. Confermare le verifiche operative solo dopo averle eseguite.
`release/` è esclusa da Git.

Il file `.env` contiene la configurazione locale. Generare `.env.public` con
`python3 script/security/prepare_client_env.py`: solo i valori pubblici entrano
nel bundle. La chiave Supabase deve essere anon/publishable; nessun segreto server
va passato come `--dart-define`.

## Backend

Il progetto attualmente collegato è `your-project-ref`.
Le migrazioni sono allineate dopo l'aggiornamento autorizzato del 13 ottobre;
[esiti hosted](docs/backend-20261013.md). Per successivi cambiamenti esaminare
`supabase db push --linked --dry-run`, conservare un backup e applicare il piano
verificato. Non riscrivere la cronologia delle migrazioni già applicate.

Distribuire tutte le funzioni presenti in `supabase/functions`, rispettando
`supabase/config.toml`. In particolare servono `upload-image` e `resolve-event`,
oltre alle versioni aggiornate di autenticazione, cancellazione account e push.
Il generatore `seed-compatible-users` è stato eliminato sia dal repository sia
dal progetto collegato.

Configurare i segreti descritti in `supabase/PRODUCTION_SETUP.md`. Le push usano
FCM HTTP v1: abilitare Firebase Cloud Messaging API, creare un service account
con autorizzazione di invio e salvare il suo JSON **solo** nel secret Supabase
`FCM_SERVICE_ACCOUNT_JSON`. La vecchia `FCM_SERVER_KEY` non viene più usata.

Controllare in Supabase i provider Google/Apple, gli ID client, conferma email,
SMTP, redirect `com.vibra.app://callback`, job di sincronizzazione/retention e
policy Storage. In Spotify confermare che l'accesso sia disponibile agli utenti
pubblici e non limitato alla lista degli sviluppatori. Il controllo del 13 ottobre
ha trovato la Web API dell'app configurata bloccata per assenza di Premium del
proprietario e nessuna quota pubblica approvata; [riscontri e vincoli](docs/provider-readiness-20261013.md).

Per inventariare eventuali dati demo su un progetto con le migrazioni aggiornate:

```bash
python3 script/release/purge_demo_data.py --project-ref <progetto>
```

Richiede `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` nell'ambiente della shell;
non stampa le credenziali. `--apply` cancella soltanto account con marcatura
esplicita o identità legacy note e gli eventi `is_test_data=true`, usando le
procedure di cancellazione e pulizia Storage. Non usa il nome visibile di una
persona o la parola “test” come criterio generico.

## Firma Android

Per il primo lancio è stata creata, su richiesta del titolare, la chiave RSA 4096
`android/keystore/vibra-upload.p12`, alias `vibra-upload`; `android/key.properties`
è configurato. Questi file sono privati e ignorati da Git. La copia locale protetta
è in `release/qa-20261013/android-signing-backup/`: conservarne anche una copia
esterna cifrata. Non rigenerare la chiave per gli aggiornamenti futuri.
Le impronte SHA-1 e SHA-256 sono registrate in Firebase, il client OAuth Android
è configurato e il pubblico Google è In production; [riscontri Google](docs/google-android-launch-20261013.md).
Resta da provare l'accesso reale su release e sul certificato di Play App Signing.

Su un altro Mac ripristinare la stessa chiave e configurare `android/key.properties`
con i dati privati della copia protetta. `storeFile` relativo si risolve da
`android/app/`; quello attuale punta a `../keystore/vibra-upload.p12`.
Il template `key.properties.example` è disponibile per nuove configurazioni.

Le release richiedono la chiave ufficiale: non esiste più il fallback al
certificato debug. Attivare Play App Signing in Play Console e registrare il
certificato corretto per OAuth Google. Il target SDK è API 36 con Flutter 3.44.2.
Verificare anche la compatibilità delle librerie native con pagine da 16 KB sul
bundle finale e su dispositivo compatibile.

## Configurazione pubblica dell’app

`python3 script/release/app_config.py` legge il file privato
`release/store-config.json` e genera `release/app-public-defines.json`.
Lo script di build passa questo file a Flutter tramite `--dart-define-from-file`.
I contatti e i link nel codice pubblico rimangono esempi; il preflight verifica
che i valori generati corrispondano alla configurazione privata.

## Firma iOS

Controllo locale senza modifiche: `python3 script/release/ios_signing.py`.
Il preflight verifica profilo App Store, scadenza, team, bundle, capability e
corrispondenza con un’identità di firma disponibile nel portachiavi.


Copiare `ios/Flutter/Signing.example.xcconfig` in `Signing.local.xcconfig`,
impostare `VIBRA_DEVELOPMENT_TEAM` con il team effettivo e allineare
`apple_team_id` nella configurazione store. Servono certificato Apple Distribution
e profilo App Store per `com.vibra.app` con **Sign in with Apple** e **Push
Notifications**. Caricare la chiave APNs su Firebase e verificare una push su
un iPhone fisico. Debug usa APNs development; Release/Profile usano production.

`ios/ExportOptions.plist` esporta per App Store Connect. Il manifest
`PrivacyInfo.xcprivacy` è incluso nelle risorse e descrive dati e API utilizzati;
le dichiarazioni vanno allineate alle risposte App Privacy e Data safety.

## Build e caricamento

```bash
script/release/build_store_release.sh android
script/release/build_store_release.sh ios
```

Lo script controlla prerequisiti, URL pubblici e backend, esegue analisi e test,
compila AAB/IPA, controlla il bundle per segreti e conserva i simboli.
Android usa R8 per rimuovere codice e risorse inutilizzati. Conservare anche
`release/symbols/android-r8/mapping.txt` insieme ai simboli Dart della release.
Le dimensioni misurate dopo la pulizia sono nel
[report di alleggerimento](docs/app-size-20261008.md).
Incrementare sempre il build number per una nuova versione caricata.

Caricare l'AAB in Play Console e l'IPA in App Store Connect; prima della
produzione eseguire le verifiche fisiche di `QA_CHECKLIST.md`, completare schede
store, questionari privacy/età, istruzioni review e screenshot dell'app reale.
La compilazione da sola non certifica OAuth, push o moderazione operativi.

Requisiti verificati nelle fonti ufficiali:
[Google Play target SDK](https://developer.android.com/google/play/requirements/target-sdk),
[pagine Android da 16 KB](https://developer.android.com/guide/practices/page-sizes),
[invio App Store](https://developer.apple.com/app-store/submitting/),
[privacy manifest Apple](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files),
[FCM HTTP v1](https://firebase.google.com/docs/cloud-messaging/send/v1-api).
