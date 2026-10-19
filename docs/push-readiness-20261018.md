# Notifiche push — verifica del 18 ottobre 2026

**Il collaudo di consegna su telefono non è completo.** Sono state verificate
configurazione, autenticazione FCM e componenti automatici; nessuna notifica
reale è stata inviata ai profili hosted.

## Riscontri aggiornati

- Android e iOS usano il progetto Firebase `vibra-3f307` e l'identificatore
  `com.vibra.app`; `push_probe.py --local-only` conferma la corrispondenza.
- La console Firebase consultata in questa sessione mostra FCM HTTP v1 attivo;
  per `com.vibra.app` mancano ancora chiavi APNs development/production e
  certificati APNs.
- Un'invocazione FCM con `validate_only: true` e token volutamente invalido
  restituisce HTTP 400 `INVALID_ARGUMENT`, senza un errore di autenticazione.
  Questa prova usa l'OAuth dell'operatore Firebase CLI, rinnovato nella sessione;
  **non verifica la credenziale service-account della funzione hosted, APNs o
  la ricezione di una notifica**. Il secret hosted
  `FIREBASE_SERVICE_ACCOUNT_JSON` è presente; il suo valore non è stato letto.
- Query aggregate hosted: 3 profili, 0 token FCM registrati, 0 profili in
  opt-out e 0 token conservati nonostante l'opt-out. Non sono stati estratti
  nomi, indirizzi email, token o contenuti dei profili.
- Tutte le cinque funzioni notifiche risultano `ACTIVE`; migrazioni webhook e
  consenso applicate. I trigger su messaggi, Live, amicizie, affinità e consenso
  sono abilitati. In Vault esistono endpoint e credenziale dei webhook; i tre
  cron delle notifiche sono attivi.
- Il titolare conferma l'assenza di account Apple Developer e Google Play
  attivi. Il solo provisioning locale è Personal Team per
  `com.vibra.app.dev`, scaduto il 16 ottobre, privo di
  `aps-environment`; manca Apple Distribution.
- L'iPhone compare nell'inventario memorizzato, ma l'ultima connessione è del
  15 ottobre e le richieste correnti di app/stato dispositivo falliscono con
  errori 4000/4016. Non è considerato un dispositivo operativo collegato.

## Difetto trovato nell'autenticazione dei worker

Il successo di `cron.job_run_details` certificava l'accodamento della richiesta,
senza dimostrare il successo HTTP. Le risposte `pg_net` disponibili nelle ultime
24 ore includevano sette HTTP 401 `{"error":"Unauthorized"}`. Sei sono correlate
temporalmente alle invocazioni di `retention-notifications`, una a
`send-notifications` (finestra di un secondo rispetto al run cron). L'unica HTTP
200 disponibile riguardava l'importazione del catalogo eventi.

La credenziale `vibra_service_role_key` di Vault coincide con la chiave
`service_role` corrente ottenuta dai metadati Management, appartiene al progetto
corretto e il suo JWT non è scaduto. Il digest di questa chiave differisce dal
digest di `SUPABASE_SERVICE_ROLE_KEY` nella **configurazione Edge** restituita da
`supabase secrets list`; non è stato letto il valore effettivo dentro un isolate
Edge in esecuzione. Una richiesta webhook `UPDATE`, ignorata prima di accedere
al database, restituisceva HTTP 401 anche usando la chiave corrente.

Il codice ora usa `notificationWorkerAuthorized`: confronta la chiave ricevuta
con `VIBRA_NOTIFICATION_WORKER_KEY`, esplicitamente condivisa con lo scheduler.
In assenza della nuova configurazione conserva il comportamento precedente.
Configurazione esplicita vuota o troppo corta fallisce chiusa. Il confronto usa
digest di lunghezza fissa; il gateway mantiene `verify_jwt = true`. Non cambiano
destinatari, consenso, categorie o limiti. `event-reminders` ora rifiuta i metodi
diversi da POST prima di interrogare il database.

**Correzione distribuita e verificata.** Dopo revisione del responsabile della
sessione, la nuova variabile è stata impostata al valore della credenziale Vault
già usata dai cron, senza creare identità o ruotare chiavi. Distribuiti soltanto
i cinque worker, tutti `ACTIVE` e con `verify_jwt = true`:

| Funzione | Versione verificata |
| --- | --- |
| `send-notifications` | 16 |
| `event-reminders` | 9 |
| `retention-notifications` | 10 |
| `send-chat-notification` | 9 |
| `send-social-notification` | 10 |

Sono passate **18 prove HTTP dirette e 2 prove del percorso
Vault → pg_net → worker**:

- Webhook social/Live con `UPDATE`: HTTP 200 `ignored`.
- GET ai tre job: HTTP 405, prima di qualsiasi interrogazione operativa.
- Credenziale assente o anon a tutte le cinque funzioni: HTTP 401.
- Social con destinatario sintetico UUID zero, prima verificato assente dal
  database: HTTP 200, `in_app_created = 0`, `pushes_sent = 0`. Questa prova
  esercita il client database runtime senza restituire righe di utenti.
- POST dei due job Spotify dipendenti: HTTP 200, skipped per funzionalità
  sospesa; `SPOTIFY_ENABLED = false` è stato prima verificato dal digest della
  configurazione. Stesso risultato con due richieste `pg_net` che ricostruiscono
  endpoint e header dei cron, leggendo la credenziale da Vault.

Non è stato eseguito un POST operativo di `event-reminders`. Le prove non hanno
creato notifiche in-app né richiesto invii a dispositivi reali.
Il secret nuovo non compare nell'asset `.env.public` o nella allowlist del suo
generatore.

Evidenza JSON redatta: `release/qa-20261018/push-verification.json` (locale,
esclusa da Git). I sorgenti hosted precedenti sono conservati nella directory
privata `release/qa-20261018/push-rollback`, una copia indipendente per funzione.
Il rollback consiste nel ridistribuire da ciascuna copia la relativa funzione,
mantenendo la verifica JWT, e rimuovere la sola variabile
`VIBRA_NOTIFICATION_WORKER_KEY`. Non ripristinare valori di credenziali nei
comandi o nel repository.

## Verifiche automatiche

Comandi eseguiti senza Flutter e senza invii a utenti:

```sh
npx --yes deno test \
  --allow-env=FCM_SERVICE_ACCOUNT_JSON,FIREBASE_SERVICE_ACCOUNT_JSON,VIBRA_NOTIFICATION_WORKER_KEY,SUPABASE_SERVICE_ROLE_KEY \
  supabase/functions/_shared/fcm.test.ts \
  supabase/functions/_shared/notification_worker_auth.test.ts \
  supabase/functions/event-reminders/reminder.test.ts
npx --yes deno check \
  supabase/functions/send-chat-notification/index.ts \
  supabase/functions/send-social-notification/index.ts \
  supabase/functions/event-reminders/index.ts \
  supabase/functions/send-notifications/index.ts \
  supabase/functions/retention-notifications/index.ts
python3 script/release/push_probe.py --local-only
```

Esito: **5 test Deno e 6 sottocasi FCM superati**, tutti e cinque gli entrypoint
TypeScript validi. Coperti RSA/OAuth, cache e rinnovo, errore provider/rete,
assenza e riservatezza delle credenziali, giorni italiani e cambio ora,
consenso e chiave scheduler diversa da quella runtime. Nessun test automatico
certifica la ricezione sul telefono.

Il nuovo probe Python è stato verificato anche con fixture locali: default
`validate_only`, blocco dell'invio senza selezione esplicita del dispositivo,
nessuna richiesta con target assente, firma RSA realmente verificata con
OpenSSL. Il controllo della firma usa un trasporto simulato e non FCM.

## Collaudo mirato predisposto

`script/release/push_probe.py` legge service account e singolo token di prova
da file locali o variabili di ambiente; non accetta token in argomento e non
interroga gli utenti. Service account e token devono restare fuori da Git.

```sh
python3 script/release/push_probe.py \
  --service-account /percorso-privato/service-account.json \
  --token-file /percorso-privato/token-dispositivo.txt
```

Il comando valida senza inviare. Per un invio al proprio dispositivo occorrono
anche `--send --confirm-test-device`, dopo aver verificato il consenso push ON.
`--event-id UUID` e `--sender-id UUID` preparano i percorsi evento o chat. Una
risposta FCM accettata è riportata come `send_accepted`: il report lascia sempre
`device_delivery_verified: false`, perché la consegna deve essere osservata.

## Prove sul telefono ancora necessarie

| Prova | Stato al 18 ottobre | Condizione necessaria |
| --- | --- | --- |
| Foreground e background | Non eseguita | Telefono operativo e token FCM registrato |
| Apertura evento e chat | Non eseguita | Ricezione di push mirata e navigazione osservata |
| Avvio da app terminata | Non eseguita | Push visibile sul dispositivo di collaudo |
| OFF: token nullo e nessuna consegna | Non eseguita | Prima consegna di riferimento verificata |
| ON: nuova registrazione e consegna | Non eseguita | Consenso e provisioning validi |
| iOS/APNs | Bloccata | Team Apple abilitato, firma valida e chiave APNs in Firebase |

Non impostare `push_delivery_verified` finché queste prove non sono documentate
sul dispositivo. Configurazione di riferimento e limiti esistenti della coda:
[notifiche-20261010.md](notifiche-20261010.md).

Fonti ufficiali consultate nella sessione:
[FCM validate_only](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages/send),
[Firebase Flutter/APNs](https://firebase.google.com/docs/cloud-messaging/flutter/get-started),
[credenziali runtime Supabase](https://supabase.com/docs/guides/functions/secrets).
