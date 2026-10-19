# Materiali store — verifica del 10 ottobre 2026

> Rapporto storico dei materiali `1.0.0+2`. La candidata corrente è `1.0.0+3`;
> catture aggiornate e verifiche correnti sono nel
> [report del 15 ottobre](bugfixes-20261015.md). I conteggi seguenti descrivono
> la verifica originale del 10 ottobre.

Vibra 1.0.0+2, progetto personale di {{LEGAL_NAME}}. Contatto fornito dal
titolare: **{{SUPPORT_EMAIL}}**, impostato in app, pagine e configurazione store.
Materiali e campi da copiare: [store/README.md](../store/README.md).

## Risultati

- Pubblicate sei pagine: home, privacy, termini, assistenza, eliminazione
  account e standard sicurezza minori. Accesso Sites impostato su pubblico.
- Verificate senza cookie o autenticazione tutte le pagine con HTTP 200 e
  corrispondenza del contenuto principale rispetto alla sorgente locale.
  L'hosting canonicalizza gli URL `.html` e aggiunge metadati fuori da `main`.
- Browser: controllati layout mobile/desktop, assenza di overflow orizzontale,
  contatti, percorso di eliminazione e apertura della FAQ notifiche.
- Creati 18 PNG RGB senza alpha: sei schermate ciascuno per iPhone 1206×2622,
  Android 1080×1920 e iPad 2064×2752. Widget di produzione, fixture locali
  fittizie, nessun caricamento di dati utenti o scrittura nel backend.
- Incluse grafica Play 1024×500, icona App Store 1024 e icona Play 512,
  ricavate dalle risorse di branding già presenti.
- Preparati App Privacy Apple (Markdown e JSON), Data safety Google,
  età/contenuti, sicurezza minori, review, export e identità regionale.
- Allineati contatti e link pubblici nelle schermate legali dell'app. Le
  pagine complete sono raggiungibili tramite il pulsante con icona esterna.
- Documenti Markdown privacy/termini/supporto generati dallo stesso contenuto
  delle pagine, evitando testi e promesse di retention discordanti.

Verifiche eseguite:

| Verifica | Esito |
|---|---|
| `flutter analyze` | Nessun problema |
| `flutter test --reporter expanded` | 141 test passati |
| Catture `script/store/capture_screenshots_test.dart` | 18 passate |
| `script/store/check_materials.py --online` | 112/112 controlli materiali passati |
| Preflight `--platform all --technical-only` | Passato; scope tecnico |
| `git diff --check` | Passato |

Artefatti locali in `release/store-materials`: ZIP, screenshot, grafica,
manifest con SHA-256 e `verification.json`. Il ZIP usa una allowlist e non
include credenziali, configurazione release, `.env`, cache font o Git.

## Pubblicazione pagine

URL: {{PUBLIC_SITE_URL}}

Progetto: `appgprj_6ac984dc38308191a9b4f39291dc2d2d`.
Versione Sites: 3. Commit sorgente pubblicata:
`a4c2627684ba8ab02ca56ffdd86d848298130b25`.
Deploy: `appgdep_6ac9890804f481919feed9c07f54cbe4`, stato `succeeded`.
I font serviti includono le rispettive licenze OFL.

Il controllo HTTP usa un User-Agent compatibile browser identificato come
VibraStoreMaterials. Il client urllib con User-Agent predefinito riceve un
403 dal filtro Cloudflare; la verifica compatibile browser è pubblica e non
usa cookie, token o bypass di autenticazione. Il preflight usa lo stesso
tipo di User-Agent per evitare questo falso negativo.

## Completamento prima dell'invio

Alla verifica del 10 ottobre paese e indirizzo non erano stati forniti;
sono stati confermati dal titolare il 13 ottobre e inseriti nei materiali.
Telefono review/trader e stato DSA restano da confermare. Il progetto personale non implica automaticamente
non-trader. Nessun valore è stato inventato per questi campi.

Le tabelle privacy sono preparate dal codice: resta da attestare il trattamento
dei fornitori, soprattutto la condivisione Data safety, e verificare le
procedure operative di assistenza, cancellazione email, moderazione, retention
e backup. I questionari non sono stati salvati o inviati nelle console.

Servono ancora credenziali private per reviewer, accesso pubblico Spotify,
configurazione APNs/firma e prove su dispositivi fisici documentate nella
[checklist di invio](../SUBMISSION_CHECKLIST.md) e nel report notifiche.
I flag operativi non verificati in `release/store-config.json` restano falsi.
Le catture dei widget non certificano queste prove, la conformità legale
complessiva o la readiness del bundle firmato.

## Aggiornamento materiali del 13 ottobre 2026

Il titolare ha confermato l'indirizzo ufficiale **Via Pasquale Modestino 29,
44123, Ferrara, Italia**. `store/owner.json`, le pagine privacy e termini e
le relative copie Markdown riportano questi dati; i documenti sono datati
13 ottobre 2026. Stato trader e presidio email restano da confermare.

Le 18 immagini store sono state sostituite con le schermate `01`–`06` delle
catture QA più recenti, in tema chiaro, per i tre formati originali. Mantengono
fixture fittizie locali, dimensioni previste e PNG RGB senza alpha. La nuova
icona e la feature graphic Google Play sono incluse nel pacchetto: condividono
la geometria V dell'app e il viola del marchio. La feature graphic usa il testo
“La tua musica. Le tue persone.” nei font Syne e Inter locali. Gli altri visual
promozionali precedenti restano da allineare prima di una nuova campagna.

Il pacchetto ZIP è rigenerato con manifest e verifiche aggiornati. Il rapporto
`release/store-materials/verification.json` indica l'esito corrente:
**116/116 controlli materiali passati**, incluse le sei pagine pubbliche
verificate senza cookie o autenticazione e con contenuto aggiornato corrispondente
alle sorgenti. La verifica dei materiali non certifica l'operatività di Spotify,
push, moderazione o le prove su dispositivi.
La situazione complessiva del lancio è nel
[report del 13 ottobre](launch-readiness-20261013.md).

## Prima versione pubblica senza Spotify

Il titolare ha scelto di lanciare con collegamento Spotify e affinità musicali
temporaneamente disattivati e ha confermato di non avere ancora account
sviluppatore Apple o Google. Le schede italiano/inglese, le sei pagine pubbliche
e i questionari ora descrivono eventi, mappa, salvataggi, amicizie, messaggi e
chat Live. I testi conservano revoca, esportazione e cancellazione dei dati
eventualmente già presenti da collegamenti Spotify precedenti.

Le catture e lo ZIP precedenti alla sospensione non rappresentano la release
senza Spotify: vanno rigenerati dalla versione aggiornata. I 116 controlli
sopra si riferiscono al pacchetto prima di questa scelta. La pubblicazione
delle nuove pagine e la verifica online vanno ripetute sul contenuto aggiornato.
Non viene attestata l'assenza di nuovi flussi musicali dei collegamenti
preesistenti finché non sono verificate anche le sincronizzazioni backend.
