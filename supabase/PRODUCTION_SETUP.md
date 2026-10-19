# Configurazione Supabase di produzione

Il progetto collegato a questo repository e' `your-project-ref` (Vibra,
`eu-west-2`). Le migrazioni sono la fonte di verita': applicarle sempre con
`supabase db push`, mai incollando modifiche manuali allo schema.

## Credenziali

- Nell'app Flutter usare soltanto `SUPABASE_URL`, la publishable/anon key e i
  client ID pubblici OAuth. Generare `.env.public` con `script/security/prepare_client_env.py`: soltanto
  questo asset pubblico viene incluso nell'app, mai il file `.env`.
- Conservare `SUPABASE_SERVICE_ROLE_KEY`, `SPOTIFY_CLIENT_SECRET` e le chiavi
  Firebase esclusivamente in `supabase secrets`. Non esporli nel client, nei
  log o nelle migrazioni.
- Impostare anche `SPOTIFY_TOKEN_ENCRYPTION_KEY`: una chiave casuale di 32 byte
  codificata base64. I token OAuth vengono salvati solo in
  `spotify_connections` come envelope AES-GCM; la tabella non ha policy per
  i client e viene raggiunta esclusivamente dalle Edge Functions.
- Ruotare subito ogni segreto che sia stato condiviso fuori dal gestore segreti.

## Push Firebase

Le funzioni inviano con FCM HTTP v1. Configurare `FCM_SERVICE_ACCOUNT_JSON`
nei secret Edge con il JSON del service account del progetto Firebase,
autorizzato per Firebase Cloud Messaging. È supportato anche il nome già usato
`FIREBASE_SERVICE_ACCOUNT_JSON`; `FCM_SERVICE_ACCOUNT_JSON` ha precedenza.
Abilitare la Cloud Messaging API.
La vecchia `FCM_SERVER_KEY` non viene usata. Su iOS configurare la chiave APNs
in Firebase e la capability Push Notifications nel profilo Apple. Verificare
la consegna reale su dispositivo: gli in-app notification record da soli non
dimostrano che una push sia arrivata.

## Auth Dashboard

In **Authentication > URL Configuration** impostare i redirect effettivi:

- `com.vibra.app://callback`
- gli URL HTTPS di staging e produzione, se verranno aggiunti

In produzione abilitare la conferma email, CAPTCHA (Turnstile o hCaptcha) e
una password policy forte. Il file `config.toml` definisce il comportamento
locale, non sostituisce le impostazioni del progetto hosted.

## Edge Functions e cron

Le funzioni usano i secret gia' presenti nel progetto. Dopo un cambiamento:

```bash
supabase functions deploy send-notifications
supabase functions deploy retention-notifications
supabase functions deploy event-reminders
supabase functions deploy send-chat-notification
supabase functions deploy send-social-notification
supabase functions deploy spotify-token-exchange
supabase functions deploy sync-music-profile
supabase functions deploy spotify-disconnect
supabase functions deploy delete-account
supabase functions deploy search-events
supabase functions deploy ticketmaster-sync --no-verify-jwt
```

`ticketmaster-sync` accetta esclusivamente la credenziale dedicata descritta
nella sezione Catalogo eventi: richiamarla da pg_cron/Vault o da un job esterno,
mai dal client. Per generare la chiave cifrante Spotify: `openssl rand -base64 32`, poi
`supabase secrets set SPOTIFY_TOKEN_ENCRYPTION_KEY='...'`.

Le email ospitate vanno personalizzate in **Authentication > Email Templates**
con i template `supabase/templates`; `config.toml` serve il flusso locale.
Abilitare Apple quando si distribuisce su iOS insieme a provider social e
configurare Google solo se il relativo login viene esposto nell'app.

Per il job `send-notifications`, creare in **Database > Vault** un secret
denominato `vibra_service_role_key`, con valore pari alla service-role key.
Creare anche `vibra_functions_url` con il valore HTTPS della base
`https://<project-ref>.supabase.co/functions/v1`: i trigger chat/social leggono
URL e credenziale da Vault. Nessuna consegna parte nei database locali senza
questi secret. Poi eseguire [`setup_notification_cron.sql`](setup_notification_cron.sql) nel
SQL Editor. La chiave verra' letta da Vault a ogni esecuzione, non salvata in
chiaro nel job.

Configurare inoltre nei **Secret Edge** `VIBRA_NOTIFICATION_WORKER_KEY`, con
valore identico a `vibra_service_role_key` di Vault. È la stessa credenziale già
usata dallo scheduler, senza creare una nuova identità. Il valore riservato
`SUPABASE_SERVICE_ROLE_KEY` fornito automaticamente al runtime può differire
dalla chiave API di progetto; non usarne l'uguaglianza come unica verifica del
chiamante. Le cinque funzioni push leggono l'override esplicito e mantengono
`verify_jwt = true`; non distribuire questi worker con `--no-verify-jwt`.
Una variabile esplicita vuota o troppo corta fallisce chiusa.

Impostare il valore dal gestore segreti o tramite un file temporaneo privato
passato a `supabase secrets set --env-file`, eliminandolo subito dopo. Non
inserire il valore nella riga di comando, nel repository, nei log o in
`.env.public`. Quando si ruota la credenziale dello scheduler, aggiornare anche
l'override Edge. Il preflight di pubblicazione ne richiede la presenza.

Verificare le risposte HTTP effettive in `net._http_response`: un run cron
`succeeded` dimostra soltanto l'accodamento della richiesta. Per una prova
senza effetti, i webhook social/Live con operazione `UPDATE` devono rispondere
200 `ignored`; i tre job con metodo GET devono rispondere 405, mentre
credenziali assenti/errate restano 401. Non invocare un POST operativo di
`event-reminders` per un semplice controllo. Il
[report push del 18 ottobre](../docs/push-readiness-20261018.md) documenta
diagnosi, prove e limiti del collaudo reale.

Il medesimo script programma anche `retention-notifications`: registra le
campagne in `notification_campaigns` e usa la view privata
`notification_campaign_metrics` per open, return entro 72 ore e opt-out. Il
worker applica cap, timezone e quiet hours lato server; non invia un messaggio
di ritorno quando non trova un evento o un artista realmente rilevante.

`seed-compatible-users` e i generatori demo sono stati eliminati. Non
ridistribuirli. Le policy di separazione dei dati restano attive per proteggere
gli utenti reali da eventuali fixture residue.

Le RPC esposte dall'app sono disponibili solo al ruolo `authenticated`; le
funzioni trigger e le routine interne non sono invocabili tramite l'API.

## Catalogo eventi

Le migrazioni `20261014000001_events_catalogue.sql` e
`20261015000000_catalogue_worker_auth.sql` configurano la cache delle ricerche e
il job `invoke-ticketmaster-sync`, eseguito ogni sei ore con paesi `IT`.
La funzione privata `vibra_private.enqueue_catalogue_sync()` legge endpoint e
credenziale da Vault a ogni esecuzione; nessun segreto compare nel comando cron
o nel codice della migrazione.

Configurare dai gestori di segreti del backend, senza inserire valori nel
repository o nell’asset pubblico dell’app:

| Gestore | Nome | Contenuto |
|---|---|---|
| Secret Edge | `TICKETMASTER_API_KEY` | Chiave del fornitore eventi |
| Secret Edge | `VIBRA_CATALOGUE_JOB_SECRET` | Credenziale casuale dedicata, da 32 a 256 caratteri |
| Database Vault | `vibra_catalogue_job_secret` | La stessa credenziale dedicata del secret Edge |
| Database Vault | `vibra_functions_url` | Base HTTPS `https://<project-ref>.supabase.co/functions/v1` |

Il job usa l’header `x-vibra-job-secret`; non invia il bearer della service-role
key. `verify_jwt = false` per questo solo worker consente il passaggio del job
al suo controllo dedicato: la funzione verifica sempre la credenziale prima di
leggere la richiesta o avviare l’importazione. Il suo confronto non ammette
chiavi utente o service-role come alternativa. Configurazione assente o vuota
non avvia alcun lavoro; una credenziale mancante o errata riceve HTTP 401.
Per la rotazione aggiornare entrambi i gestori con lo stesso nuovo valore.

`search-events` è invece una funzione per utenti autenticati, con sessione
valida e limiti di richiesta. Aggiorna l’area richiesta e restituisce i risultati
attraverso i permessi del chiamante. La cache condivisa conserva soltanto aree
geografiche approssimate e tempi di aggiornamento; nessuna identità o cronologia
della posizione dell’utente. I client non possono leggere o modificare la tabella
`event_provider_search_cache` o invocare la sua funzione interna di acquisizione.

Per verificare il worker senza scrivere dati, una richiesta con credenziale
corretta e lista paesi volutamente invalida deve restituire HTTP 400; richieste
anonime o con credenziale errata devono restituire 401. Una richiesta valida
effettua invece un’importazione reale. Verificare poi codice HTTP, numero di
eventi importati, pagine, indicatore di troncamento e conteggi geografici.
Non stampare header o contenuti di Vault nei log di verifica.

Il deploy e l’importazione del 15 ottobre sono documentati nel
[rapporto corrente](../docs/bugfixes-20261015.md).

## Verifica

```bash
supabase migration list --linked
supabase functions list
supabase secrets list
supabase db lint --linked
supabase test db
```

Gli avvisi del lint relativi a funzioni PostGIS di sistema non provengono dallo
schema di Vibra; verificare invece eventuali nuovi errori riferiti a `public`.

### PostGIS legacy (`spatial_ref_sys`)

Se Security Advisor segnala `public.spatial_ref_sys`, non tentare di concedere
accesso al client. È una tabella di metadati posseduta dall'estensione PostGIS,
quindi le normali migrazioni applicative non possono abilitarne RLS. Aprire un
ticket Supabase chiedendo lo spostamento/aggiornamento dell'estensione PostGIS
nello schema `extensions`; nel frattempo la tabella non è esposta dalla Data API
e non contiene dati utente.

## Aggiornamento hosted del 10 ottobre 2026

Esiti e limiti della verifica: [report backend](../docs/backend-20261010.md).

## Correzioni distribuite il 13 ottobre 2026

Le migrazioni `20261013000000` e `20261013000001` correggono messaggi/blocchi,
posizione con consenso e collegamento Spotify. Applicarle prima di distribuire
le versioni aggiornate di `spotify-token-exchange`, `spotify-disconnect` e
`sync-music-profile`, che usano le nuove RPC transazionali. Le due migrazioni e le tre funzioni sono state distribuite dopo backup e
autorizzazione. Esiti hosted: [report backend](../docs/backend-20261013.md).
Prove isolate di sicurezza: [report sicurezza](../docs/security/launch-20261013.md).
