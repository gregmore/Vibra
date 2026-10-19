# Vibra — bozza per la richiesta di accesso pubblico Spotify

**Aggiornata il 14 ottobre 2026. Documento interno da completare e rivedere; non inviato a Spotify.**
I fatti sotto derivano dal codice e dai riscontri locali del progetto. Non attestano
l'idoneità a Extended Quota né sostituiscono la decisione di Spotify.

Il 14 ottobre il titolare ha confermato: «non ho 250.000 utenti attivi mensili».
La soglia minima MAU non è quindi raggiunta secondo il titolare: la candidatura
standard è attualmente non idonea per questo requisito. Il valore effettivo dei
MAU non è stato fornito e non viene dedotto come zero. Nessuna richiesta è stata inviata.

## Stato verificato

| Campo | Fatto documentato |
|---|---|
| Applicazione | Vibra, versione candidata 1.0.0+2; Android/iOS `com.vibra.app` |
| Titolare indicato | {{LEGAL_NAME}}; prima pubblicazione. Organizzazione candidata non confermata |
| Indirizzo confermato | {{LEGAL_ADDRESS}} |
| Contatto configurato | `{{SUPPORT_EMAIL}}`; è un indirizzo Gmail, non un'email su dominio aziendale |
| Sito pubblico disponibile | {{PUBLIC_SITE_URL}} |
| Pubblicazione store | Non documentata; il titolare ha confermato di non avere ancora account sviluppatore Google Play e Apple |
| Pacchetto Android | AAB e APK Release firmati con chiave di upload già preparati e verificati |
| Pacchetto Apple | Build `.app` senza firma; manca la firma di distribuzione per la pubblicazione |
| Modalità Spotify osservata | Development mode; approvazione per accesso pubblico non ricevuta |
| Verifica dopo Premium | Token applicazione Client Credentials e lettura di un artista pubblico: entrambi HTTP 200 |
| Portata della verifica Spotify | Solo catalogo pubblico; OAuth utente e importazione degli ascolti non verificati in questa prova |
| Prima candidata pubblica | Spotify e affinità musicali disattivati nel client, nelle funzioni e nel database; disconnessione e gestione dei dati preesistenti conservate |

Il pacchetto Android **Release** e la modalità **Development** dell'app registrata
in Spotify sono stati distinti. La firma Android non concede accesso pubblico
alle API Spotify. La verifica Premium non cambia la modalità o la quota del provider.

## Descrizione del servizio proposta

Vibra è un'app mobile per esplorare concerti ed eventi su una mappa, salvare eventi,
seguire e contattare altri utenti, gestire amicizie e partecipare alle conversazioni
Live associate a un evento. Include profilo, foto da galleria/fotocamera, impostazioni
privacy, notifiche facoltative, blocchi e segnalazioni. La ricerca della community
nella candidata pubblica usa nome e username, senza preferenze Spotify.

L'integrazione Spotify conservata nel codice, attualmente sospesa per il pubblico,
prevede un collegamento volontario dell'account per mostrare preferenze e statistiche
musicali, proporre concerti e calcolare affinità tra utenti che hanno prestato consenso.
**Descrivere questi usi nella richiesta e farne verificare l'ammissibilità al provider;
non sono funzioni già approvate per l'accesso pubblico.**

## API e dati Spotify previsti dal codice

- OAuth Authorization Code con PKCE S256, `state` casuale e validazione della callback;
  scambio/rinnovo tramite funzioni backend.
- Scope richiesti: `user-read-private`, `user-read-email`, `user-top-read`,
  `user-read-recently-played`.
- Lettura del profilo `/me`, dei primi 50 artisti e brani su `medium_term`, dei generi
  degli artisti e di un massimo di 50 ascolti recenti. Il codice aggrega gli ascolti
  recenti per giorno della settimana.
- Il codice tenta anche la lettura `/audio-features` per derivare un vettore numerico;
  il fallimento è gestito senza interrompere tutta la sincronizzazione. La prova
  HTTP 200 del catalogo **non dimostra** l'accesso a questo endpoint o agli altri
  endpoint dell'integrazione.
- Dati previsti: ID Spotify del collegamento, metadati di artisti/brani/generi,
  aggregati degli ascolti, eventuali caratteristiche audio e vettori/affinità derivati.
  La descrizione non deve ridurre questi trattamenti alla sola lettura di un nome.
- I token persistenti sul backend sono cifrati con AES-GCM. I segreti del client
  restano sul backend; nessuna chiave o credenziale va allegata alla richiesta.

## Privacy e controlli tecnici documentati

Sono presenti consenso e revoca per posizione e affinità, disconnessione Spotify,
cancellazione account, policy di accesso per account e blocchi bilaterali. Connessione,
rinnovo e salvataggio del profilo musicale usano controlli transazionali e generazioni
del collegamento per impedire che una risposta tardiva ripristini dati dopo la revoca.
La sospensione pubblica è controllata anche dal backend e dal database.

Privacy pubblica: {{PUBLIC_SITE_URL}}/privacy.html

Termini: {{PUBLIC_SITE_URL}}/termini.html

Eliminazione account: {{PUBLIC_SITE_URL}}/elimina-account.html

Questi controlli sono riscontri tecnici. Contratti dei fornitori, tempi effettivi di
conservazione/backup, presidio delle email, moderazione e prove reali su telefoni
restano da completare o confermare. Non risulta un audit indipendente; non dichiarare
certificazione di sicurezza o conformità legale già attestata.

## Campi ancora da fornire con prove

Il modulo ufficiale collegato dalla documentazione Spotify è stato aperto il
14 ottobre 2026, senza compilare, caricare allegati, inviare o accettare accordi.
La prima pagina richiede:

- Registrazione dell'azienda con numero identificativo.
- App o sito già pubblicamente attivi, con link.
- Almeno 250.000 MAU con prova analytics/store risalente a non più di 30 giorni.
- Tre mercati principali e prove della relativa quota di mercato.
- Prova dei ricavi degli ultimi 12 mesi.
- Rispetto di Terms e Policy del provider.

La pagina **Company & Contact** osservata richiede URL dell'azienda, nome
dell'azienda, nome del contatto, email aziendale, numero di registrazione/tax ID,
un solo Spotify Client ID, indirizzo registrato, informazioni sulla società madre
e sulle sedi; il rappresentante Spotify è facoltativo.
Questa è la trascrizione dei campi osservati, senza attribuire al progetto
idoneità, requisiti soddisfatti o un'organizzazione non documentata.

[Modulo ufficiale osservato](https://docs.google.com/forms/d/1O87xdPP1zWUDyHnduwbEFpcjA57JOaefCgBShKjAqlo/viewform).

| Informazione | Stato attuale |
|---|---|
| Ragione sociale, forma giuridica, registrazione e rappresentante dell'organizzazione candidata | **Sconosciuti**; è documentato soltanto il titolare personale sopra |
| Email aziendale e dominio dell'organizzazione | **Non forniti**; dominio proprio assente in `store/owner.json` |
| Servizio già lanciato, URL store o altro canale pubblico utilizzabile | **Non documentati**; esiste il sito di assistenza, non una pubblicazione store |
| Utenti attivi mensili (MAU), metodologia, periodo e prova analytics/store entro 30 giorni | **Soglia minima di 250.000 MAU non raggiunta**, secondo il titolare; valore effettivo e prove non forniti. Non dedurre zero utenti |
| Pubblico effettivo, tre mercati principali e prove della quota di mercato | **Non verificati** |
| Modello commerciale, monetizzazione e prova ricavi degli ultimi 12 mesi | **Sconosciuti** |
| Società madre, sedi e partner di distribuzione | **Sconosciuti**; non dedurre una struttura aziendale dal nome del titolare |
| Volumi API attuali/previsti, picchi e motivazione della quota richiesta | **Non misurati**; evitare numeri inventati |
| Ammissibilità degli usi derivati, affinità e raccomandazioni; endpoint disponibili alla quota richiesta | **Da verificare con Spotify** |
| Demo della versione con Spotify e prova completa OAuth/sync/disconnessione | **Da produrre**; la candidata pubblica sospende queste funzioni |
| Responsabile operativo privacy/sicurezza e contatto aziendale | **Da indicare**, senza attribuire ruoli a persone non confermate |

La documentazione Spotify consultata nel [report del provider](provider-readiness-20261013.md)
indica per le nuove richieste Extended Quota requisiti di organizzazione, servizio
già lanciato e almeno 250.000 MAU. Il titolare ha confermato che quest'ultima soglia
non è raggiunta; gli altri requisiti restano non documentati. La candidatura standard
è attualmente non idonea per il requisito MAU e non è stata inviata. Il dossier non
deve essere presentato come se i requisiti fossero soddisfatti. Il modulo ufficiale e le condizioni
vigenti devono essere ricontrollati prima di qualunque invio:
https://developer.spotify.com/documentation/web-api/concepts/quota-modes.

## Fonti interne e allegati consentiti

- [Stato del provider e verifica Premium](provider-readiness-20261013.md).
- [Report della candidata di lancio](launch-readiness-20261013.md).
- [Inventario dati](store-privacy-data.md) e [titolare configurato](../store/owner.json).
- Codice: `lib/core/constants/api_constants.dart`,
  `lib/data/datasources/spotify_auth_datasource.dart`, funzioni
  `spotify-token-exchange`, `sync-music-profile`, `calculate-match` e `recommend-events`.

Eventuali allegati dovranno essere descrizione del prodotto, schermate con dati
fittizi, URL pubblici e statistiche aggregate verificabili. Non allegare file `.env`,
chiavi di firma, password, token, backup del database o dati personali degli utenti.
