# Materiali store — verifica del 10 ottobre 2026

Vibra 1.0.0+2, progetto personale di Gregorio Morelli. Contatto fornito dal
titolare: **vibra7341@gmail.com**, impostato in app, pagine e configurazione store.
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

URL: https://vibra-assistenza.newrobin4.chatgpt.site

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

Paese e indirizzo non sono stati forniti; telefono review/trader e stato DSA
restano da confermare. Il progetto personale non implica automaticamente
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
