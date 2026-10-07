# Utenti e dati di test Vibra

Questo set è riservato a sviluppo, test e staging. Lo script rifiuta
`production`, blocca i target remoti per default e, su staging remoto, richiede
che il project ref sia esplicitamente allowlistato.

## Preparazione e comandi

1. Applica le migrazioni, inclusa
   `20260830000000_test_data_segmentation.sql`.
2. Esporta variabili server-side in una shell dedicata (non inserirle nel file
   `.env` distribuito con l'app):

   ```bash
   export VIBRA_ENV=local
   export SUPABASE_URL=http://127.0.0.1:54321
   export SUPABASE_SERVICE_ROLE_KEY='<service-role locale>'
   ```

3. Crea o riallinea idempotentemente il set:

   ```bash
node script/seed_test_data.mjs seed
```

Per avviare l'app contro lo stesso Supabase locale, senza modificare `.env`:

```bash
./script/run_test_app.sh
```

Lo script recupera automaticamente URL e chiave pubblica dal Supabase locale.
Accedi con `vibra_test_01_complete@example.com` e la password predefinita
`Vibra-Test!2026` per vedere gli altri profili seed. Un account reale non li
vede intenzionalmente, perché l'isolamento `is_test_user` separa i due segmenti.

4. Prima di una sessione, cancella soltanto il namespace
   `vibra_e2e_v1` e ricrealo da zero:

   ```bash
   node script/seed_test_data.mjs reset --confirm RESET_TEST_DATA
   ```

   È disponibile anche il flag equivalente:

   ```bash
   node script/seed_test_data.mjs seed --reset --confirm RESET_TEST_DATA
   ```

Per uno staging ospitato servono entrambe le protezioni aggiuntive:

```bash
export VIBRA_ENV=staging
export SUPABASE_URL=https://<staging-ref>.supabase.co
export SUPABASE_SERVICE_ROLE_KEY='<service-role staging>'
export VIBRA_TEST_PROJECT_REF='<staging-ref>'
node script/seed_test_data.mjs seed --allow-remote
```

Non usare mai il project ref o la service role di produzione. Il reset remoto
richiede anche `--confirm RESET_TEST_DATA`. Una verifica senza rete è disponibile
con `--dry-run`.

### Parametri per geografia e carico

Il set base non può scendere sotto i dieci profili. Gli utenti aggiuntivi hanno
musica, coordinate distribuite attorno alla città base e match score variati.

```bash
node script/seed_test_data.mjs seed \
  --users 100 \
  --city Torino --lat 45.0703 --lon 7.6869 \
  --far-city Napoli --far-lat 40.8518 --far-lon 14.2681
```

Per stampare le fixture in JSON senza collegarsi a Supabase:

```bash
node script/seed_test_data.mjs fixtures
```

La password comune predefinita è `Vibra-Test!2026`. Per cambiarla, usare
`VIBRA_TEST_PASSWORD` nel seed e lo stesso valore in
`VIBRA_E2E_PASSWORD` nei test.

### Spotify nei dati sintetici

I profili musicali sincronizzati sono completi e deterministici; nessun token
Spotify reale viene committato. Se `SPOTIFY_TOKEN_ENCRYPTION_KEY` è presente, lo
script cifra token sintetici con la stessa busta AES-GCM usata dalle Edge
Functions. Senza la chiave, salva volutamente una busta non decifrabile: è
comunque sufficiente per lo scenario revocato/scaduto e la Home usa
`spotify_id` più `music_profiles` per lo stato sincronizzato.

## Credenziali e stato atteso

Tutte le email iniziano con `vibra_test_`, gli utenti Auth hanno
`app_metadata.is_test_user=true` e `seed_namespace=vibra_e2e_v1`; i profili
pubblici hanno `users.is_test_user=true`. Gli eventi hanno
`events.is_test_data=true` e un `external_id` che inizia con `vibra-e2e-`.

| # | Scenario | Email | Stato principale |
|---|---|---|---|
| 1 | Completo | `vibra_test_01_complete@example.com` | Onboarding finito, avatar, Spotify e musica, posizione/push, eventi, chat |
| 2 | Minimale | `vibra_test_02_minimal@example.com` | Solo username; nessun avatar, Spotify, posizione o push |
| 3 | Metà onboarding | `vibra_test_03_half_onboarding@example.com` | Avatar e username; `onboarding_step=spotify` |
| 4 | Molti match | `vibra_test_04_many_matches@example.com` | Score 94/84/61/43/28 e amicizie accepted/pending/rejected |
| 5 | Chat attive | `vibra_test_05_active_chat@example.com` | Tre conversazioni, almeno quattro non letti, richiesta e condivisione evento |
| 6 | Bloccante | `vibra_test_06_blocker@example.com` | Blocco reciproco con utente 7 |
| 7 | Spotify scaduto | `vibra_test_07_spotify_expired@example.com` | Token scaduto da 30 giorni; blocco reciproco con utente 6 |
| 8 | Eventi misti | `vibra_test_08_mixed_events@example.com` | Futuri/passato, sold-out, cancellato, rinviato e notifiche update |
| 9 | Appena registrato | `vibra_test_09_brand_new@example.com` | Solo `auth.users`, nessun profilo o dato applicativo prima del primo avvio |
| 10 | Geografico lontano | `vibra_test_10_far_away@example.com` | Roma di default e solo evento della città lontana salvato |

## Checklist manuale per profilo

Prima dell'intera sessione eseguire un solo reset. Non resettare tra singoli
test, salvo quando si deve riportare l'utente 9 allo stato auth-only.

### 1 — Profilo completo

- [ ] Login diretto alla Home, senza riapertura dell'onboarding.
- [ ] Avatar fotografico, nome e bio sono presenti; niente fallback a iniziali.
- [ ] Home mostra “Spotify sincronizzato” e non il CTA di collegamento.
- [ ] Consigli coerenti con indie italiano/electropop (Calcutta, Cosmo, Ariete).
- [ ] Profilo/Music Stats mostra artisti, generi, brani e heatmap coerenti.
- [ ] Posizione e notifiche risultano abilitate; nessun prompt iniziale indebito.
- [ ] “I miei eventi” contiene TEST Indie Frequencies e TEST Neon Warehouse.
- [ ] Chat con l'utente 5 presente e leggibile.

### 2 — Profilo minimale

- [ ] Home/profilo usa avatar a iniziali e un nome di fallback senza crash.
- [ ] Il CTA Spotify è visibile; i consigli generici non richiedono un profilo musicale.
- [ ] Mappa/eventi non assume coordinate e mostra la richiesta posizione/empty state previsto.
- [ ] Nessun prompt notifiche già accettato e nessun token FCM presente.
- [ ] Username `test_minimal` resta valido; provare `<3` caratteri, spazi/caratteri
      non ammessi e duplicato per verificare tutti i messaggi di validazione.
- [ ] “I miei eventi”, chat e statistiche musicali mostrano empty state puliti.

### 3 — Onboarding interrotto

- [ ] Dopo il login si apre direttamente lo step Spotify (pagina 3 di 5), non l'inizio.
- [ ] Tornando indietro, username e avatar già salvati sono ancora presenti.
- [ ] “Salta” porta allo step successivo corretto e persiste `onboarding_step`.
- [ ] Chiudere e riaprire l'app a uno step successivo: la ripresa è idempotente.
- [ ] Completare il flusso e verificare `onboarding_completed=true` senza duplicare profilo.

### 4 — Molti match/affinità

- [ ] La tab Vibra carica una coda, ordinata dal punteggio maggiore.
- [ ] Gauge/score rende correttamente fascia alta (94/84), media (61/43) e bassa (28).
- [ ] Accepted, pending ricevuta, pending inviata e rejected hanno azioni/UI coerenti.
- [ ] “Ignora” rimuove solo la card corrente; “Invia Vibra” aggiorna lo stato corretto.
- [ ] Riavvio/refresh non ripristina ottimisticamente una card già gestita per errore.

### 5 — Chat attive

- [ ] Badge totale non letti è almeno 4 e coincide con le righe conversazione.
- [ ] Messaggi corti e lunghi vanno a capo senza overflow.
- [ ] La conversazione con utente 8 rende il messaggio `event_share` e apre l'evento giusto.
- [ ] La conversazione iniziata dall'utente 3 compare tra le richieste, non tra le chat dirette.
- [ ] Aprire una chat marca soltanto i relativi messaggi come letti e aggiorna i badge.
- [ ] Inviare un messaggio, riaprire l'app e verificare ordine e persistenza.
- [ ] Lo stato “sta scrivendo” è **N/A nel codice attuale**: Presence traccia solo
      `online` e il seed non può persistere uno stato Realtime. Quando verrà
      implementato, simularlo con un secondo client che pubblica `typing` sul canale.

### 6 e 7 — Blocco reciproco e Spotify revocato

- [ ] Gli utenti 6 e 7 non si vedono reciprocamente in match, liste o conversazioni.
- [ ] Un tentativo di invio diretto fallisce lato backend, anche bypassando la UI.
- [ ] Sbloccando un solo lato, il blocco opposto continua a impedire il contatto.
- [ ] Con utente 7, una sincronizzazione Spotify fallisce senza crash e propone
      esplicitamente il ricollegamento.
- [ ] Home non deve continuare a dichiarare “sincronizzato” dopo che il backend ha
      rilevato scadenza/revoca. Se accade, registrare il difetto: il seed espone
      intenzionalmente questa condizione.
- [ ] Dopo il ricollegamento, token expiry e `last_synced_at` vengono aggiornati e
      non nasce un secondo profilo musicale.

### 8 — Eventi salvati misti

- [ ] “I miei eventi” divide TEST Memories Festival nei Passati e gli altri in Arrivo.
- [ ] TEST Sold Out Pop Night mostra sold-out (`status=offsale`) **prima** del tap.
- [ ] TEST Canceled Live mostra cancellato e impedisce un acquisto non valido.
- [ ] TEST Postponed Electronic Day mostra rinviato con data/stato coerenti.
- [ ] Le due notifiche `event_update` sono non lette e aprono l'evento corretto.
- [ ] Un refresh non elimina un salvataggio solo perché lo stato non è `onsale`.

### 9 — Appena registrato / isolamento dati

- [ ] Subito dopo il reset esiste in Auth ma non in `public.users`; il primo avvio
      crea un solo profilo bootstrap e apre l'onboarding.
- [ ] Nessun evento salvato, messaggio, match, notifica o statistica di un utente
      precedente compare prima o dopo login/logout.
- [ ] Le cache locali sono vuote e le query private RLS restituiscono zero righe.
- [ ] Salvare un dato, fare logout, entrare come utente 1 e verificare che non sia condiviso.
- [ ] I profili pubblici visibili nella funzione esplicita “scopri utenti” non sono
      un leak; non devono però comparire come match, chat o dati personali senza
      una relazione dedicata.

### 10 — Geografia lontana

- [ ] Con città base Milano, l'utente 10 non compare nei risultati a raggio breve.
- [ ] TEST Far City Sessions non compare sulla mappa milanese ma compare vicino a Roma.
- [ ] Pan/zoom verso la città lontana aggiorna marker e lista senza marker residui.
- [ ] Cambiare filtri distanza/genere mantiene coerenti mappa, lista e conteggio.
- [ ] L'evento lontano salvato compare comunque in “I miei eventi”.

## Checklist trasversale

- [ ] Le card evento mostrano `onsale`, `offsale`/sold-out, `canceled` e `postponed`.
- [ ] I marker vengono ricalcolati dopo pan e non usano coordinate della città hardcoded.
- [ ] I filtri genere distinguono indie, elettronica, rock e pop.
- [ ] Analytics/retention escludono `users.is_test_user=true`; le query ad hoc
      applicano sempre `WHERE NOT is_test_user`.
- [ ] Utenti reali/beta non vedono profili o eventi test; un edge sociale
      real↔test viene rifiutato anche con service role.
- [ ] Rieseguire `seed` due volte non cambia i conteggi; `reset` ripristina non letti,
      stati amicizia, blocchi e date relative allo stato noto.

## E2E con fixture stabili

Il repository usa Flutter `integration_test` (non contiene al momento una suite
Detox, Maestro o Appium). I test seeded sono disabilitati per default, così la CI
unit/widget non può contattare uno staging per errore.

1. Verificare che il file `.env` dell'app punti allo stesso Supabase appena
   popolato.
2. Avviare su device/emulatore:

   ```bash
   flutter test integration_test/ \
     --dart-define=RUN_SEEDED_E2E=true \
     --dart-define=VIBRA_E2E_SUPABASE_URL='http://127.0.0.1:54321' \
     --dart-define=VIBRA_E2E_SUPABASE_ANON_KEY='<anon-key locale>'
   ```

3. Per staging remoto aggiungere l'allowlist E2E:

   ```bash
   flutter test integration_test/ \
     --dart-define=RUN_SEEDED_E2E=true \
     --dart-define=VIBRA_E2E_SUPABASE_URL='https://<staging-ref>.supabase.co' \
     --dart-define=VIBRA_E2E_SUPABASE_ANON_KEY='<anon-key staging>' \
     --dart-define=VIBRA_E2E_PROJECT_REF='<staging-ref>'
   ```

4. Se la password è stata personalizzata:

   ```bash
   --dart-define=VIBRA_E2E_PASSWORD='<stessa password del seed>'
   ```

Le fixture sono centralizzate in
`integration_test/fixtures/seeded_test_users.dart`. I test non creano né
cancellano account: validano login/Home, isolamento dell'utente nuovo, stati
onboarding/fallback, fasce di match, eventi, chat/non letti/event share e blocco
backend. Per Maestro/Appium è possibile consumare lo stesso elenco JSON prodotto
dal comando `fixtures`.
