# Rilascio Vibra 1.0.0+2

Package Android e bundle iOS: `com.vibra.app`. I controlli tecnici completati e
le mancanze effettive sono in [docs/store-readiness-20261007.md](docs/store-readiness-20261007.md).

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

Il progetto attualmente collegato è `dxgqovzlvmhcmpvlkxgi`.
Prima del deploy esaminare `supabase db push --linked --dry-run`: al controllo del
7 ottobre mancano 17 migrazioni. Dopo verifica del piano e backup, applicare con
`supabase db push --linked`. Le migrazioni mantengono le protezioni RLS che
escludono eventuali dati sintetici residui; non riscrivere la cronologia già applicata.

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
pubblici e non limitato alla lista degli sviluppatori.

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

Creare o recuperare la chiave di upload ufficiale e conservarla con un backup
sicuro. Copiare `key.properties.example` in **`android/key.properties`** e
compilare i quattro campi. `storeFile` relativo si risolve da `android/app/`;
l'esempio punta quindi a `android/keystore/upload-keystore.jks`.

Le release richiedono la chiave ufficiale: non esiste più il fallback al
certificato debug. Attivare Play App Signing in Play Console e registrare il
certificato corretto per OAuth Google. Il target SDK è API 36 con Flutter 3.44.2.
Verificare anche la compatibilità delle librerie native con pagine da 16 KB sul
bundle finale e su dispositivo compatibile.

## Firma iOS

Selezionare in Xcode il team Apple Developer effettivo e allineare
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
