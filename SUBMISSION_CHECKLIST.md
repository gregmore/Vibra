# Invio agli store — Vibra 1.0.0+3

Stato attuale: **candidata in verifica finale; invio non ancora pronto**.
Correzioni correnti e verifiche pendenti: [chiusura del 18 ottobre](docs/launch-closure-20261018.md).
Il [report del 15 ottobre](docs/bugfixes-20261015.md) conserva le prove precedenti.
Risultati della candidata precedente: [report del 13 ottobre](docs/launch-readiness-20261013.md).
Materiali aggiornati al 10 ottobre: [store/README.md](store/README.md).

Aggiornamento del 18 ottobre: 295 test Flutter superati e analisi pulita; corretto
il flusso di cancellazione account. Nessuna prova fisica o conferma di presidio
è stata dichiarata completata. Protocollo: [telefoni](docs/device-acceptance-20261018.md),
[push](docs/push-readiness-20261018.md), [procedure operative](docs/operations-runbook.md).
Le verifiche hosted del 18 ottobre rilevano inoltre l’assenza del job di
retention dei dati: riscontro e piano nel [verbale operativo](docs/operations-verification-20261018.md).

## Codice e bundle

- [x] Rimossi generatori demo, bot e flussi seeded.
- [x] Rimosso l'endpoint demo dal Supabase collegato.
- [x] Rimossi bypass di prova da router, sincronizzazione Spotify e bootstrap.
- [x] Configurazione pubblica separata dai segreti server.
- [x] Font locali con licenze incluse.
- [x] Manifest privacy iOS incluso nell'app.
- [x] Rimosso il permesso iOS di localizzazione in background inutilizzato.
- [x] Configurate entitlements Apple/push e ambiente APNs per build.
- [x] Eliminata la firma debug dalle release Android.
- [x] Aggiornato invio push a FCM HTTP v1, verificato con test automatici.
- [x] Versione 1.0.0, build 3, identificatore `com.vibra.app`.

## Backend e firma

Aggiornamento del 13 ottobre: [correzioni e verifica](docs/launch-readiness-20261013.md).
Le nuove protezioni sono attive nel backend di lancio, dopo backup e approvazione.
Riscontri: [backend del 13 ottobre](docs/backend-20261013.md).

Aggiornamento del 15 ottobre: [segnalazioni, messaggi, traduzioni e catalogo eventi](docs/bugfixes-20261015.md).

- [x] Applicate le migrazioni `20261014000000`, `20261014000001`, `20261015000000`; distribuiti ricerca geografica e job catalogo autenticato. Importazione verificata: 449 eventi italiani dal provider, 450 futuri reali nel catalogo.

- [x] Applicate le due migrazioni del 13 ottobre e distribuite le tre funzioni Spotify aggiornate.

- [x] Applicate le 17 migrazioni mancanti e due correzioni successive, dopo dry run e backup (10 ottobre).
- [x] Distribuite tutte le 16 funzioni, incluse `upload-image` e `resolve-event` (10 ottobre).
- [x] Collegato il service account backend `FIREBASE_SERVICE_ACCOUNT_JSON` all’invio FCM HTTP v1.
- [ ] Configurare/verificare APNs in Firebase e provare la consegna push su device.
- [x] Prima release pubblica senza Spotify e affinità: blocco client/backend/SQL distribuito e verificato.
- [ ] Eventuale futura riattivazione Spotify: approvazione pubblica e QA del provider.
- [x] Creata e verificata chiave di upload Android ufficiale, con copia locale protetta (13 ottobre).
- [x] Registrate SHA-1 e SHA-256 della chiave Android in Firebase.
- [x] Creato client OAuth Android della nuova chiave e configurato pubblico Google In production.
- [ ] Provare login Google con il certificato ufficiale e da test interno Play.
- [ ] Attivare Play App Signing e registrare il certificato di distribuzione.
- [ ] Registrare gli account Google Play Console e Apple Developer (il titolare conferma di non averli ancora).
- [ ] Completare il test chiuso richiesto per nuovi account personali Play.
- [ ] Configurare firma e profilo App Store Apple con le capability necessarie.
- [x] Ottenuto e verificato AAB Android firmato; APK release firmato per QA.
- [ ] Ottenere IPA firmata per App Store.
- [x] Verificati ELF da 16 KB nel bundle e allineamento ZIP dell'APK release.
- [ ] Provare la release su dispositivo con pagine native da 16 KB.

## Materiali e operatività

- [x] Confermati titolare legale {{LEGAL_NAME}} e indirizzo; privacy/termini pubblicati aggiornati.
- [ ] Confermare presidio dei contatti email.
- [x] Pubblicate privacy, termini, supporto, eliminazione account e sicurezza community.
- [x] Allineati documenti, contatto email nell'app e link alle pagine complete.
- [x] Preparate tabelle App Privacy / Data safety e questionari età/review.
- [ ] Completare App Privacy / Data safety usando [l’inventario tecnico](docs/store-privacy-data.md).
- [ ] Verificare consensi, revoca e opt-out delle campagne dopo il deploy.
- [ ] Completare questionari età, contenuti utenti e obblighi regionali del venditore.
- [x] Preparate 18 catture dei widget reali con fixture locali fittizie; nessun dato utente reale o demo backend.
- [ ] Confermare moderazione, segnalazioni e blocco utenti funzionanti.
- [ ] Verificare OAuth reale, revoca, account deletion, push e riconnessione su dispositivi fisici.
- [ ] Fornire istruzioni e accesso necessari alla review degli store.

## Controllo finale

```bash
python3 script/release/preflight.py --platform all --online
```

`--technical-only` verifica i file del progetto, escludendo firma e requisiti
operativi: un suo esito positivo non significa che la pubblicazione sia pronta.
