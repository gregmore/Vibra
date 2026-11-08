# Lancio pubblico con Spotify temporaneamente sospeso

Le modifiche di questo report attuano la scelta del titolare di lanciare Vibra
con Spotify temporaneamente disattivato. Sono verificate nel database locale
isolato `/tmp/vibra-launch-security` e distribuite nel backend hosted dopo backup;
i riscontri della distribuzione sono riportati sotto.

## Controlli reversibili

Le funzioni Edge accettano Spotify solamente con il secret server
`SPOTIFY_ENABLED=true`. `false`, valore assente o non riconosciuto tengono la
funzione sospesa. Dopo l'autenticazione, collegamento, rinnovo, importazione,
calcolo delle affinità e raccomandazioni musicali restituiscono `503` con errore
`spotify_temporarily_unavailable`, prima di usare credenziali Spotify o profili
memorizzati. I worker interni sospesi restituiscono `200` con `ok: true` e
`skipped: spotify_temporarily_unavailable`, evitando tentativi ripetuti del job.

La migrazione `20261013000002_launch_spotify_pause.sql` crea il controllo
operativo `public.launch_features`, con riga `spotify` inizialmente `false`.
I client non hanno permessi sulla tabella e non possono riattivarla. Le policy
restrittive nascondono ai client precedenti abbinamenti, discovery musicale e
notifiche di affinità/personalizzazione già memorizzate. Le RPC di compatibilità
e affinità vicine non restituiscono candidati durante la sospensione.

I trigger bloccano anche scritture tardive di connessioni, importazioni,
abbinamenti, nuove notifiche musicali ed embedding Spotify degli eventi. Una
scrittura acquisisce il controllo operativo fino al termine della transazione:
la sospensione attende quelle già avviate e impedisce le successive. Non vengono
eliminati dati o azzerati consensi per questa sospensione. Dati propri ed export,
disconnessione esplicita, eliminazione account, registrazione, profilo e catalogo
ordinario rimangono disponibili.

Notifiche di messaggi e amicizie, chat Live, promemoria degli eventi, Ticketmaster
e risoluzione degli eventi restano indipendenti dalla sospensione musicale. Il
webhook sociale ignora solo `user_matches`; i worker di campagne Spotify vengono
saltati integralmente. Il token Spotify di applicazione viene scartato anche se
era presente in cache. Il worker delle campagne non invia una push se il database
rifiuta la relativa notifica.

## Discovery della community

`public.discover_public_users(p_query text default '', p_limit int default 30)`
usa `SECURITY INVOKER` ed è disponibile ai soli utenti autenticati. Restituisce
solo `id`, `username`, `display_name`, `avatar_url`, `bio`; conserva le policy
attuali di `users_public`, esclude se stessi e i blocchi in entrambe le direzioni.
Ricerca letterale senza distinzione maiuscole/minuscole, massimo 100 caratteri,
pagina limitata fra 1 e 50 e ordinamento deterministico. Non importa né restituisce
dati Spotify, posizione, email o percentuali di affinità.

## Verifica

- **148 asserzioni pgTAP in 11 file**, comprese le 95 precedenti e 53 nuove,
  tutte passate. I test precedenti attivano la funzionalità solo nella propria
  transazione poi annullata; i nuovi test coprono la sospensione, reversibilità,
  scritture tardive, signup/bootstrap/export/disconnessione e discovery pubblica.
- **19 test Deno e 13 sottopassi**, tutti passati; catturano gli handler reali con
  Auth/database/provider locali simulati e verificano che nessuna richiesta
  Spotify o scrittura di profilo venga eseguita durante la sospensione. La
  creazione delle notifiche ordinarie di chat e amicizia rimane funzionante.
- Controllo dei tipi su tutte le **16 funzioni** e sul nuovo test: passato.
- SQL lint: **zero segnalazioni applicative**; le 16 segnalazioni residue
  appartengono a funzioni dell'estensione PostGIS, proprietà verificata nel
  catalogo. La riga locale `spotify` rimane `false` dopo tutti i test annullati.

Evidenze in `release/qa-20261013/`: `spotify-pause-pgtap.txt`,
`spotify-pause-deno-tests.txt`, `spotify-pause-deno-check.txt`,
`spotify-pause-db-lint.json` e `spotify-pause-db-lint-ownership.json`.
Queste verifiche non attestano login/push reali su dispositivi o un'approvazione
Spotify pubblica. Il limite del provider è descritto in
[dipendenze esterne](provider-readiness-20261013.md).

## Distribuzione e riattivazione

Il backend richiede la migrazione verificata, il secret `SPOTIFY_ENABLED=false`
e le otto funzioni aggiornate:

```text
spotify-token-exchange
sync-music-profile
calculate-match
recommend-events
compute-event-embeddings
send-notifications
retention-notifications
send-social-notification
```

`spotify-disconnect` rimane disponibile e non richiede un nuovo deploy per il
flag. La distribuzione delle otto funzioni e del secret hosted è confermata
nella sezione finale di questo report.

La futura riattivazione richiede che l'accesso pubblico Spotify sia effettivamente
approvato e verificato, poi l'allineamento del secret server, del controllo SQL
e della configurazione della nuova release client. Il controllo SQL è reversibile:

```sql
UPDATE public.launch_features SET enabled = true WHERE feature = 'spotify';
```

Per sospenderlo di nuovo usare `enabled = false`, senza toccare dati e consensi.

## Distribuzione hosted completata

La migrazione e le otto funzioni sono state distribuite dopo il backup protetto
`release/qa-20261013/backend-pause-backup/` e un dry run con la sola migrazione
`20261013000002`. Il titolare ha autorizzato la release pubblica senza Spotify.
La lettura indipendente del database conferma la migrazione, flag `false`, cinque
trigger, tre policy restrittive e la nuova discovery disponibile solo ad
`authenticated`. Le otto funzioni risultano ACTIVE; il digest del secret
`SPOTIFY_ENABLED` corrisponde a `false`. Non sono stati creati account o dati QA
nel backend reale. La CLI ha segnalato il già noto problema del catalogo locale
pg-delta dopo il push: la verifica indipendente hosted conferma l'applicazione.

Evidenza: `release/qa-20261013/spotify-pause-production-verification.json`.
