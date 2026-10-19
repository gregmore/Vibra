# Google Play — Data safety

Risposte preparate il 13 ottobre 2026, non inviate. Riferimento della candidata
aggiornato al 15 ottobre: `1.0.0+3`; confermare i dati nella console prima dell’invio.
Raccolta dati: **Sì**. I dati persistenti del backend non sono effimeri.
Non dichiarare “nessun dato raccolto”.

## Disponibilità della prima versione pubblica

Il collegamento Spotify e le affinità musicali sono temporaneamente disattivati.
Le righe musicali descrivono solo eventuali dati e collegamenti preesistenti,
che restano soggetti a revoca e cancellazione. Le altre categorie sono ancora
usate dalle funzioni disponibili. Verificare anche i job backend prima di
attestare l’assenza di nuovi flussi Spotify su collegamenti già esistenti.

| Tipo console | Raccolto | Obbligatorio/facoltativo | Finalità proposte |
|---|---|---|---|
| Personal info → Name | Sì | Facoltativo | App functionality, Account management |
| Personal info → Email address | Sì | Obbligatorio per account | App functionality, Account management |
| Personal info → User IDs | Sì | Account obbligatorio; eventuali ID Spotify preesistenti | App functionality, Account management, Advertising or marketing per campagne |
| Location → Approximate location | Sì | Facoltativo | App functionality, Personalization, Advertising or marketing per campagne |
| Location → Precise location | Sì | Facoltativo | App functionality, Personalization, Advertising or marketing per campagne |
| Messages → Other in-app messages | Sì | Facoltativo | App functionality, Fraud prevention/security/compliance |
| Photos and videos → Photos | Sì | Facoltativo | App functionality |
| Contacts → Contacts | Sì | Facoltativo | App functionality, Personalization |
| App activity → App interactions | Sì | Dipende dalla funzione | App functionality, Personalization, Analytics, Advertising or marketing |
| App activity → Other user-generated content | Sì | Facoltativo | App functionality; assistenza/sicurezza |
| App activity → Other actions | Sì | Facoltativo | Personalization, App functionality; preferenze dell’app ed eventuali dati musicali preesistenti |
| App info and performance → Diagnostics | Sì | Facoltativo con invio supporto | Analytics, App functionality |
| Device or other IDs | Sì | Facoltativo con push | App functionality, Developer communications, Advertising or marketing per campagne |

Contacts comprende il grafo sociale, non solo una rubrica. Chat dell'app non
sono SMS/MMS. I dati Spotify eventualmente già presenti sono metadati e
preferenze, non file audio. Clic su link
biglietti non sono dati di pagamento. Dichiarare la raccolta di una funzione
opzionale anche se l'utente può disattivarla.
[Definizioni e guida Google](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).

## Condivisione: campi da confermare prima di salvare

Non selezionare “nessuna condivisione” automaticamente. Per ciascuna riga
sopra verificare contratti e attività dei destinatari effettivi:

| Destinatario | Flusso | Decisione da documentare |
|---|---|---|
| Supabase | Account, profili, contenuti e record applicativi | Verificare ruolo di responsabile/fornitore di servizio |
| Firebase/Google/Apple | OAuth, identificatori, token e payload push | Verificare trattamenti SDK, configurazione e accordi |
| Spotify | Nuovi collegamenti disattivati; gestione/revoca di eventuali collegamenti preesistenti | Verificare i flussi effettivi, compresi job di sincronizzazione preesistenti, finalità del provider e categorie trasmesse |
| OpenStreetMap/provider mappe | IP, richieste tile e area visualizzata | Verificare raccolta/retention; posizione e identificatori da dichiarare se applicabile |
| Google traduzione | Descrizioni pubbliche di eventi e richieste tecniche | Non viene inviato il testo delle chat; verificare metadati di rete |
| Altri utenti | Profilo e messaggi indirizzati tramite azioni dell'utente | Verificare l'eccezione per trasferimenti avviati dall'utente |
| Provider biglietti | Apertura del link esterno | Verificare eventuali dati nei parametri, non dati di pagamento |

La condivisione con responsabili e i trasferimenti avviati dall'utente possono
avere eccezioni nelle definizioni Google; servono riscontri, non una semplice
etichetta “backend”. Questa colonna rimane **da confermare**, non un “No” finale.

## Altre risposte

- Creazione account: Sì, email/password, Google OAuth, Apple OAuth secondo
  piattaforma. Non dichiarare autenticazione esclusivamente aziendale.
- Richiesta cancellazione: Sì, dall'app e dalla pagina esterna sottostante.
  Confermare il presidio operativo delle richieste email prima dell'invio.
- Eliminazione parziale: un eventuale collegamento Spotify preesistente può
  essere revocato e rimosso; non promettere un meccanismo generale di
  eliminazione selettiva di qualsiasi categoria.
- Dati cifrati in transito: HTTPS presente nei flussi censiti; risposta “Sì”
  finale subordinata a verifica completa SDK, media e servizi in produzione.
- Revisione di sicurezza indipendente: No, nessun audit documentato.
- Ads: nessun SDK o banner pubblicitario; le campagne proprie facoltative
  restano marketing per le finalità dei dati.
- Nessuna raccolta intenzionale di dati salute/finanza, file audio, video,
  calendario OS, cronologia browser o inventario delle app nel codice attuale.

Privacy: {{PUBLIC_SITE_URL}}/privacy.html

Eliminazione: {{PUBLIC_SITE_URL}}/elimina-account.html
