# Materiali store — Vibra 1.0.0+3

Aggiornati il 13 ottobre 2026 per il progetto personale di {{LEGAL_NAME}}.
Riferimento della candidata aggiornato al 15 ottobre: `1.0.0+3`.
Contatto pubblico: **{{SUPPORT_EMAIL}}**. Le dichiarazioni proposte sono
basate sul codice e devono corrispondere alla configurazione del bundle inviato.
Questa preparazione non costituisce un invio nelle console Apple o Google.
Il titolare ha confermato che gli account sviluppatore non sono ancora creati.

La prima versione pubblica offre eventi, mappa, salvataggi, amicizie, messaggi
e chat Live. **Spotify e affinità musicali sono temporaneamente disattivati.**
I dati di eventuali collegamenti precedenti conservano le procedure di revoca,
esportazione e cancellazione.

| Campo da copiare | Valore |
|---|---|
| Nome app | Vibra |
| Identificatore | com.vibra.app |
| Titolare | {{LEGAL_NAME}} |
| Indirizzo ufficiale confermato dal titolare | {{LEGAL_ADDRESS}} |
| Paese | Italia |
| Tipo progetto | Personale |
| Assistenza, privacy, sicurezza, contatto legale | {{SUPPORT_EMAIL}} |
| Sito | {{PUBLIC_SITE_URL}} |
| Privacy | {{PUBLIC_SITE_URL}}/privacy.html |
| Termini | {{PUBLIC_SITE_URL}}/termini.html |
| Supporto | {{PUBLIC_SITE_URL}}/supporto.html |
| Eliminazione account | {{PUBLIC_SITE_URL}}/elimina-account.html |
| Standard sicurezza minori | {{PUBLIC_SITE_URL}}/sicurezza.html |
| Copyright proposto | 2026 {{LEGAL_NAME}} |

Le descrizioni italiane e inglesi sono in [STORE_METADATA.md](../STORE_METADATA.md).
I questionari sono in [questionnaires](questionnaires). L'archivio da caricare
è generato in `release/store-materials/vibra-store-materials.zip`, insieme al
manifest delle immagini e al rapporto delle verifiche.

## Screenshot

Sei schermate per ciascuno dei tre formati: Home, scoperta utenti, dettaglio
evento, agenda, messaggi, profilo. Dopo la sospensione di Spotify e affinità,
le catture e il pacchetto devono essere rigenerati dalla versione che le
disattiva, senza badge Spotify o percentuali di affinità. Acquisite dai widget di produzione tramite
`script/store/capture_screenshots_test.dart`, con fixture locali completamente
fittizie e senza query o modifiche al backend. Nessun testo promozionale aggiunto
alle immagini. Non sono prove di funzionamento su dispositivi fisici.

| Cartella | Dimensioni | Uso |
|---|---|---|
| ios-medium | 1206 × 2622 | iPhone con Dynamic Island medio |
| android-phone | 1080 × 1920 | Google Play, telefono |
| ipad-13 | 2064 × 2752 | App Store, iPad 13 pollici |

I file finali sono PNG RGB senza canale alpha. L'iPad è incluso perché il
progetto dichiara supporto per iPhone e iPad. Specifiche verificate nelle
[istruzioni Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
e nelle [istruzioni Google](https://support.google.com/googleplay/android-developer/answer/9866151).

Per rigenerare le sei immagini store: acquisire le schermate con
`flutter test script/store/capture_screenshots_test.dart` in una cartella QA
tramite `VIBRA_SCREENSHOT_DIR`, copiare solo `01`–`06` per ciascun formato in
`release/store-materials/screenshots`, poi
`python3 script/store/package_materials.py` con Pillow disponibile. Il test
usa esclusivamente i font locali dell'app. La Home mostra gli eventi dopo
un normale scorrimento della pagina.

## Dati e conferme ancora necessari

- Completare i dati dell'account sviluppatore con nome, paese e indirizzo
  confermati dal titolare e riportati nella tabella sopra.
- Telefono/recapito del referente review e, se applicabile, del trader.
- Trader/non-trader UE: “progetto personale” non basta a determinare lo stato.
  Il titolare deve confermare finalità e attività commerciali effettive.
  [Criteri Apple DSA](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/).
- Presidio effettivo della casella email, procedura di cancellazione via email,
  moderazione e gestione dei casi di sicurezza; obiettivo di prima risposta
  entro 48 ore lavorative da attivare, non certificato tramite una prova email.
- Accordi e trattamenti dei fornitori, condivisione Data safety, retention e
  backup di produzione: vedere le condizioni nei questionari.
- Account di review reale e prove su device. Il reviewer non necessita di
  Spotify per questa release; eventuale riattivazione richiede nuove verifiche.
- Verificare le attività backend degli eventuali collegamenti Spotify già
  presenti prima di escludere i flussi musicali dalle dichiarazioni privacy.

I flag operativi in `release/store-config.json` restano separati dai materiali:
pubblicare le pagine non certifica la conformità legale o la readiness dell'app.

## Sorgenti delle pagine

`store/owner.example.json` contiene esclusivamente segnaposto. Copiarlo nel
file locale ignorato `store/owner.json` e compilare i dati effettivi.
`script/store/build_site.py` genera HTML in `store/site/dist` e documenti
personalizzati in `release/store-documents`, entrambi esclusi da Git.
I file Markdown versionati sono modelli pubblici. Anche i metadati di hosting
`store/site/.openai` e il checkout `release/store-site` rimangono privati.
Non caricare i file di esempio sul sito operativo.
