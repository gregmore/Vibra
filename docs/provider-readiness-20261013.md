# Dipendenze esterne — aggiornamento del 14 ottobre 2026

Il 14 ottobre, dopo l'attivazione di Premium comunicata dal titolare, il portale
Spotify autenticato di **Vibra** non mostra più l'avviso che bloccava la Web API.
Il Client ID coincide con la configurazione locale e lo stato rimane
**Development mode**. Una verifica diretta ha ottenuto **HTTP 200** sia per il
token di applicazione Client Credentials sia per la lettura di un artista
pubblico. Non sono stati memorizzati token, letti profili personali o modificati
dati nel backend. Questa prova conferma l'accesso di applicazione al catalogo;
il collegamento OAuth di un utente e l'importazione dei suoi ascolti richiedono
ancora una prova distinta. I redirect visualizzati corrispondono alla callback
Supabase e a `com.vibra.app://callback`.

Premium soddisfa il prerequisito della modalità sviluppo; non concede
l'accesso pubblico. La documentazione
Spotify attuale limita tale modalità a cinque utenti autorizzati. Le nuove
richieste di quota estesa sono riservate alle organizzazioni e includono fra i
requisiti un servizio già lanciato e almeno 250.000 utenti attivi mensili. Non è
stata presentata alcuna richiesta di quota estesa. L'acquisto Premium è stato
effettuato dal titolare, senza intervento dell'agente.
[Regole ufficiali delle quote Spotify](https://developer.spotify.com/documentation/web-api/concepts/quota-modes).

La candidata pubblica conserva Spotify e affinità disattivati, secondo la scelta
del titolare. Premium non modifica i flag del client, delle funzioni o del
database. Per una beta Spotify restano necessari utenti autorizzati entro il
limite del provider; per la riattivazione pubblica serve l'approvazione di quota
estesa. Il riscontro iniziale del 13 ottobre, quando il blocco Premium era ancora
presente, rimane come evidenza storica.

Sempre il 14 ottobre il titolare ha chiesto il passaggio di Spotify alla modalità
pubblica. Il portale mostra ancora Development mode e il relativo collegamento
informativo, senza un comando per attivare direttamente la quota estesa. Il
modulo ufficiale Partner Application è stato aperto e letto fino ai campi azienda
e contatto. Richiede documenti di registrazione, prove analytics/store dei MAU
entro 30 giorni, mercati e ricavi degli ultimi 12 mesi. Questi dati non sono
documentati nel progetto e sono stati richiesti al titolare. Nessun campo è
stato compilato, nessun allegato caricato e nessuna richiesta inviata.
La [bozza della candidatura](spotify-public-access-draft-20261014.md) raccoglie
i fatti tecnici e i campi mancanti. Il titolare ha poi confermato di **non avere
250.000 utenti attivi mensili**; non ha indicato il valore effettivo. La soglia
della candidatura standard è quindi un requisito non soddisfatto, anziché una
prova semplicemente da fornire. Nessuna richiesta è stata inviata.
L'integrazione Spotify della candidata pubblica resta sospesa; gli altri flussi
dell'app non dipendono da questa approvazione. La modalità del provider non
impedisce di preparare e pubblicare Vibra senza l'integrazione Spotify, dopo il
completamento dei requisiti store e delle verifiche operative.

Il portale Google Play, aperto con l'account già presente **Vibra**, mostra la
schermata iniziale di creazione dell'account sviluppatore. Per questo account
non è accessibile un account sviluppatore attivo né un elenco di app. Non è
stato avviato l'iter di registrazione, accettato un contratto o effettuato un
pagamento. Lo stato di eventuali altri account personali o aziendali rimane
sconosciuto: questa verifica non li esclude.

La configurazione Google OAuth completata e la firma Android sono documentate
separatamente in [Google Android](google-android-launch-20261013.md). Nessuna
delle due sostituisce un account Play sviluppatore, l'accesso pubblico Spotify
o la verifica reale dei flussi sui dispositivi.

Gli esiti aggregati iniziali, senza segreti o dati degli utenti autorizzati
Spotify, sono in `release/qa-20261013/external-provider-readiness.json`.
La nuova verifica è in
`release/qa-20261013/spotify-premium-readiness-20261014.json`; entrambe le prove
sono escluse da Git.
