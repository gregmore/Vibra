# Età, contenuti, review e dati regionali

Scheda di compilazione per Apple e Google, aggiornata il 13 ottobre 2026. Non inviata.

| Domanda/funzione | Risposta proposta dal codice |
|---|---|
| App o gioco | App |
| Destinatari dichiarati | Adulti 18+ |
| Contenuti generati dagli utenti | Sì: profilo, foto, chat dirette/Live |
| Messaggistica/chat | Sì |
| Funzioni sociali/scoperta persone | Sì |
| Condivisione posizione | Funzioni di prossimità e zona evento; non dichiarare un tracker continuo di altri utenti |
| Pubblicità/banner di terzi | No nel codice attuale |
| Acquisti in-app, abbonamenti, loot box | No |
| Biglietti | Link a fornitori esterni; pagamento non gestito dall'app |
| Scommesse/casino/giochi d'azzardo | No |
| Contenuti editoriali medici, violenti o sessuali | Nessuna funzione dedicata prevista |
| Accesso web non limitato | Nessun browser generalista; link esterni circoscritti, da ricontrollare nel bundle |
| Verifica forte dell'età | Non presente; requisito 18+ autodichiarato |
| Parental controls dedicati | Non presenti |

Il requisito di utilizzo 18+ non determina automaticamente il rating Apple o
IARC. Compilare le domande nella console e accettare il rating calcolato,
valutando un override adulto dove disponibile. Per frequenza/intensità di
contenuti maturi verificare anche i contenuti effettivamente disponibili e
moderati. Il divieto nei termini non equivale all'assenza tecnica di UGC.
Non attestare “Social Media Disabled for Users Under 13” senza il meccanismo
richiesto da Apple, incluso Declared Age Range API.
[Definizioni del rating Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/).

## Sicurezza minori e moderazione Google

Standard pubblicati:
{{PUBLIC_SITE_URL}}/sicurezza.html

Referente designato nella pagina: {{LEGAL_NAME}}, {{SUPPORT_EMAIL}}.
La pagina vieta CSAE, indica la segnalazione e la gestione secondo legge.
Confermare strumenti in-app, presa in carico, rimozione, procedura verso le
autorità e presidio del referente prima di attestare i requisiti operativi.
Non spuntare automaticamente tutte le certificazioni perché la pagina esiste.
[Requisiti Google](https://support.google.com/googleplay/android-developer/answer/14747720).

## Accesso per la review

Parte dell'app richiede un account: dichiarare **accesso limitato**.
Contatto email review: {{SUPPORT_EMAIL}}. Nome proposto: {{LEGAL_NAME}}.
Telefono, account reviewer e password restano da fornire in una scheda privata
della console. Non inserirli nel repository, nel sito o negli screenshot.

Note da copiare dopo aver predisposto l'accesso:

> Vibra is a live-events app for adults. Sign in with the review account
> supplied in the private credentials fields. Browse concerts on the map,
> save events, manage friendships and exchange messages. Live chat requires
> being near an eligible event. Device location is optional for browsing.
> Spotify connection and music affinity are temporarily disabled in this
> first public release. Tickets open the external provider website; Vibra
> does not process payment. Account deletion and data export are available
> in Settings → Privacy and personal data. Public support and privacy pages
> use the URLs provided in the listing.

Non richiedere un account Spotify al reviewer: collegamento e affinità sono
disattivati in questa release. Non promettere credenziali demo, bypass o accesso
alle funzioni tramite un account non predisposto.

## Crittografia/export Apple

Il client usa HTTPS/TLS; il backend conserva l’uso di AES-GCM standard per
eventuali token Spotify preesistenti.
`ITSAppUsesNonExemptEncryption` nel progetto va riconciliato con il questionario
del bundle e l'eventuale documentazione richiesta. Non è presente un algoritmo
crittografico proprietario, ma non attestare un'esenzione legale soltanto dal
nome dell'algoritmo. Nessuna modifica automatica alle dichiarazioni export.

## DSA e identità sviluppatore

Progetto personale dichiarato dall’autore. Il titolare ha confermato Italia e
{{LEGAL_ADDRESS}}. Gli account sviluppatore
Apple e Google non sono ancora stati creati, come confermato dal titolare.
Trader/non-trader deve essere determinato dal titolare in base
all'attività effettiva, non dall'assenza di una società. Se trader individuale,
Apple richiede recapito/indirizzo o casella postale, telefono ed email da
verificare. Non inventare questi valori.
[Criteri e campi Apple](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/).
