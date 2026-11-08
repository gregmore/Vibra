# Vibra — candidata di lancio del 13 ottobre 2026

> Rapporto storico della candidata `1.0.0+2`. Per le correzioni, il catalogo eventi
> e lo stato della candidata corrente `1.0.0+3`, vedere il
> [report del 15 ottobre](bugfixes-20261015.md).

Versione **1.0.0+2**, Android/iOS `com.vibra.app`. Le correzioni sono nel repository;
la pubblicazione negli store richiede ancora la firma iOS, configurazione degli
account store e prove operative. La chiave Android e il bundle firmato sono pronti. Su scelta del titolare,
questa prima release pubblica ha **Spotify e affinità musicali disattivati**.
La ricerca della community usa nome e username, senza profili musicali.
Il 14 ottobre Premium ha sbloccato le chiamate Spotify di applicazione verificate
con HTTP 200; Vibra resta in Development mode, limitata a cinque utenti
autorizzati. La candidata pubblica mantiene quindi la sospensione musicale;
[verifica aggiornata del provider](provider-readiness-20261013.md).
Il titolare ha richiesto l'accesso pubblico Spotify: modulo ufficiale
ispezionato e [bozza della candidatura preparata](spotify-public-access-draft-20261014.md),
poi ha confermato di non raggiungere i 250.000 utenti attivi mensili richiesti.
La candidatura standard non soddisfa quindi questo requisito e non è stata
inviata. Il percorso di lancio resta la release pubblica con Spotify sospeso;
la modalità Spotify e i pacchetti consegnati sono quelli verificati sopra.
Il backend hosted è stato aggiornato dopo backup e autorizzazione esplicita;
[esiti della verifica](backend-20261013.md).

## Correzioni verificate

- **Mappa:** posizione GPS ricevuta dopo l'apertura, ricerca iniziale per artista,
  ricerche geografiche obsolete, raggio dei preset, marker che aprono l'evento,
  indicazioni stradali, coordinate invalide, cache associata all'area e al raggio,
  stati di errore con Riprova. Attribuzione OpenStreetMap visibile e collegata,
  identificazione HTTP dell'app e cache delle tile secondo la
  [policy del servizio](https://operations.osmfoundation.org/policies/tiles/).
- **Comunicazione:** messaggi recenti filtrati per conversazione, cancellazioni,
  riconnessione, invii pendenti durante aggiornamenti realtime, recupero bozze,
  risposte alle proposte d'incontro, conteggi follow e richieste di amicizia con
  gestione degli errori. Le risposte di una vecchia conversazione non modificano
  quella appena aperta.
- **Live:** evento corretto anche dalla notifica, posizione effettiva entro 500 m,
  finestra di 24 ore prima/dopo il concerto, partecipazione esplicita, messaggi
  ordinati ed errori di invio/caricamento recuperabili.
- **Foto e impostazioni:** galleria e fotocamera, anteprima prima del salvataggio,
  rimozione, annullamento, errori di permesso e formato, recupero Android,
  protezione da invii simultanei. Un cambio account interrompe upload e salvataggio;
  la cache non ripristina la vecchia foto dopo un aggiornamento. Username occupati
  e conflitti concorrenti hanno un messaggio preciso. Digest e cache private sono
  invalidati al cambio account. Il bootstrap non invia colonne Spotify eliminate.
- **Grafica e logo:** nuova V a doppia onda, SVG e icone native generate dalla stessa
  geometria; icone e feature graphic Google Play opache senza canale alpha. Accesso e benvenuto adattabili,
  pulsanti e campi senza gli overflow riprodotti con testo al 200%, avatar coerente
  col tema. Privacy e termini accessibili anche prima del login. Corrette anche
  le stringhe del login/email/età/accessibilità rimaste italiane nelle altre lingue,
  rilevate durante la prova nativa Android.
- **Sicurezza backend:** blocchi bilaterali, media privati, messaggi cancellati,
  consenso e revoca GPS, affinità rispettose dell'opt-out; connessione/rinnovo/
  disconnessione Spotify transazionali, senza ricreare dati dopo la revoca.
  Dettagli e prove: [report sicurezza](security/launch-20261013.md).

## Risultati

| Controllo | Esito |
|---|---|
| `flutter analyze --no-pub` | Nessuna segnalazione |
| Suite Flutter principale | **222 test superati nella configurazione pubblica** |
| Funzioni Spotify conservate | **15 test superati** con feature esplicitamente abilitata solo nei test |
| Package cluster mappa | **9 test superati** |
| Database Supabase isolato | **148 test SQL superati**, 11 file |
| Edge Functions | 16 entrypoint controllati, **19 test e 13 sottocasi superati** |
| Catture widget | **54 catture pubbliche**, 9 schermate × 3 formati × 2 temi |
| Generazione icone | Superata; PNG store senza canale alpha |
| Android QA | APK Debug compilato |
| Android Release | AAB e APK compilati con chiave ufficiale RSA 4096; firma verificata |
| Bundle Android definitivo | Firma verificata, scansione senza rilevamenti; librerie ELF e ZIP APK allineati da 16 KB |
| Backend hosted | Tre migrazioni applicate; otto funzioni aggiornate per la sospensione Spotify |
| iOS Release | `.app` compilata senza firma |
| Scansione APK Android Release | Nessun rilevamento fra i 4 segreti noti cercati; password della firma assenti |
| Scansione `.app` iOS | 219 file, nessun rilevamento fra i 4 segreti noti cercati |
| Preflight tecnico | Superato |
| Configurazione titolare | Nome e indirizzo confermati; pagine ufficiali aggiornate, versione Sites 5 |
| Certificato Android / Google | SHA-1/SHA-256 Firebase, client OAuth Android e pubblico Google In production verificati |
| Materiali store | **116/116 controlli superati**, incluse 6 pagine online; 18 screenshot e tre grafiche nel ZIP |
| Preflight store | Firma Android e indirizzo superati; restano i requisiti sotto |

Le catture usano widget dell'app con fixture locali fittizie e nessun dato personale
reale; verificano il layout e non attestano l'esecuzione dei servizi di produzione.
La release Android è stata anche installata su emulatore Android 16 e verificata
nei percorsi pubblici welcome, login, email, route Spotify sospesa e pagine legali, senza nuovi account
o dati di prova nel backend.
Le scansioni dei bundle verificano valori/formati noti e non certificano l'assenza
universale di vulnerabilità. Non sono state eseguite nuove prove su telefoni fisici.

## Artefatti per la verifica

In `release/qa-20261013/` (esclusa da Git): **`artifacts/vibra-android-signed.aab`**
per Play Console, **`artifacts/vibra-android-release.apk`** per la prova Android,
simboli Dart/R8, `.app` iOS senza firma, log dei test/build, preflight, scansioni,
logo e anteprime nei due temi. Restano anche gli artefatti precedenti per confronto.
La `.app` iOS senza firma non è un pacchetto caricabile su App Store.

La chiave privata Android e le password sono escluse da Git, con permessi `0600`;
una copia locale è in `android-signing-backup/` con directory `0700`. Conservare
anche una copia esterna cifrata: quella locale non protegge dalla perdita del Mac.
I certificati pubblici e i riscontri Firebase sono in `android-signing/`.

## Requisiti per il lancio

1. **Backend e Spotify:** le tre migrazioni e le funzioni aggiornate sono attive.
   La prima release ha Spotify e affinità sospesi nel client, nelle funzioni e
   nel database; i client precedenti non possono aggirare questa scelta. Nessun
   dato musicale preesistente o consenso è stato cancellato; disconnessione ed
   esportazione restano disponibili. La ricerca pubblica usa solo nome/username,
   rispetta sessioni, segmenti e blocchi bilaterali.
   [Controlli e deploy della sospensione](backend-spotify-pause-20261013.md).
   I vincoli Spotify restano rilevanti per un'eventuale futura riattivazione;
   [controllo dei portali](provider-readiness-20261013.md).
2. **Android:** nuova chiave di upload creata su richiesta e firme verificate.
   Attivare Play App Signing in Play Console; quando disponibile, registrare
   anche il certificato di distribuzione. Il client OAuth Android della chiave
   di upload è stato creato, i link ufficiali salvati e il pubblico Google è
   **In production**; [riscontri Google](google-android-launch-20261013.md).
   Provare ancora il login e lo scambio Supabase sulla release firmata e dal
   test interno Play: la configurazione da sola non verifica questo accesso.
3. **iOS:** manca il certificato Apple Distribution; serve il profilo App Store
   con le capability Apple/push. La compilazione senza firma non produce un'IPA
   pubblicabile.
4. **Operatività:** verificare accesso Google/email reale, consegna push/APNs,
   moderazione, consensi/revoca e QA su dispositivi fisici con due account.
5. **Configurazione store:** nome e indirizzo forniti dal titolare sono allineati
   in `release/store-config.json`, `store/owner.json` e nelle pagine pubblicate.
   Restano stato trader, presidio email, attestazioni operative e questionari
   nelle console; poi eseguire il preflight completo. Il portale Play dell'account
   Vibra ispezionato mostra ancora la creazione dell'account sviluppatore: serve
   registrazione o accesso a un account aziendale già attivo. Lo stato di altri
   account non è stato dedotto; il titolare ha confermato che non ha ancora gli
   account sviluppatore. Non sono state effettuate iscrizioni o pagamenti.
   Per un nuovo account personale Google Play sono richiesti almeno 12 tester
   iscritti al test chiuso per 14 giorni consecutivi prima della richiesta di
   accesso alla produzione. [Requisito Google](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-en).
   Apple richiede iscrizione al programma, accordo e acquisto della membership;
   [registrazione Apple](https://developer.apple.com/programs/enroll/).

Procedura di rilascio firmato: [RELEASE.md](../RELEASE.md). Le tre migrazioni e le
funzioni aggiornate sono verificabili nei diff e sono state distribuite con
autorizzazione. Nessun requisito operativo mancante è stato segnato come completato.
