# Invio agli store — Vibra 1.0.0+2

Stato attuale: **preparazione tecnica completata; invio non ancora pronto**.
Risultati e blocchi: [report del 7 ottobre](docs/store-readiness-20261007.md).
Materiali aggiornati al 10 ottobre: [store/README.md](store/README.md).

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
- [x] Versione 1.0.0, build 2, identificatore `com.vibra.app`.

## Backend e firma

- [x] Applicate le 17 migrazioni mancanti e due correzioni successive, dopo dry run e backup (10 ottobre).
- [x] Distribuite tutte le 16 funzioni, incluse `upload-image` e `resolve-event` (10 ottobre).
- [x] Collegato il service account backend `FIREBASE_SERVICE_ACCOUNT_JSON` all’invio FCM HTTP v1.
- [ ] Configurare/verificare APNs in Firebase e provare la consegna push su device.
- [ ] Confermare accesso Spotify per utenti pubblici.
- [ ] Configurare chiave Android e Play App Signing.
- [ ] Configurare firma e profilo App Store Apple con le capability necessarie.
- [ ] Ottenere AAB e IPA firmati con la procedura di rilascio.
- [ ] Verificare pagine native da 16 KB sul bundle Android finale.

## Materiali e operatività

- [ ] Confermare titolare legale, indirizzo e contatti monitorati.
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
