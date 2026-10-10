# Età, contenuti, review e dati regionali

Scheda di compilazione per Apple e Google, 10 ottobre 2026. Non inviata.

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
https://vibra-assistenza.newrobin4.chatgpt.site/sicurezza.html

Referente designato nella pagina: Gregorio Morelli, vibra7341@gmail.com.
La pagina vieta CSAE, indica la segnalazione e la gestione secondo legge.
Confermare strumenti in-app, presa in carico, rimozione, procedura verso le
autorità e presidio del referente prima di attestare i requisiti operativi.
Non spuntare automaticamente tutte le certificazioni perché la pagina esiste.
[Requisiti Google](https://support.google.com/googleplay/android-developer/answer/14747720).

## Accesso per la review

Parte dell'app richiede un account: dichiarare **accesso limitato**.
Contatto email review: vibra7341@gmail.com. Nome proposto: Gregorio Morelli.
Telefono, account reviewer e password restano da fornire in una scheda privata
della console. Non inserirli nel repository, nel sito o negli screenshot.

Note da copiare dopo aver predisposto l'accesso:

> Vibra is a music and live-events app for adults. Sign in with the review
> account supplied in the private credentials fields. Spotify and location
> are optional. Home, event browsing, saved events and messaging are available
> according to the account's data and permissions. Tickets open the external
> provider website; Vibra does not process payment. Account deletion and
> data export are available in Settings → Privacy and personal data. Public
> support and privacy pages use the URLs provided in the listing.

Per testare Spotify il reviewer deve poter essere autorizzato dal servizio;
l'accesso pubblico Spotify non è ancora verificato. Non promettere credenziali
demo, bypass o accesso alle funzioni tramite un account non predisposto.

## Crittografia/export Apple

Il client usa HTTPS/TLS; il backend usa AES-GCM standard per token Spotify.
`ITSAppUsesNonExemptEncryption` nel progetto va riconciliato con il questionario
del bundle e l'eventuale documentazione richiesta. Non è presente un algoritmo
crittografico proprietario, ma non attestare un'esenzione legale soltanto dal
nome dell'algoritmo. Nessuna modifica automatica alle dichiarazioni export.

## DSA e identità sviluppatore

Progetto personale dichiarato dall'autore. Il paese e l'indirizzo non sono
stati forniti. Trader/non-trader deve essere determinato dal titolare in base
all'attività effettiva, non dall'assenza di una società. Se trader individuale,
Apple richiede recapito/indirizzo o casella postale, telefono ed email da
verificare. Non inventare questi valori.
[Criteri e campi Apple](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/).
