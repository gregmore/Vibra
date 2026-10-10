# Google Play — Data safety

Risposte preparate dal codice 1.0.0+2 il 10 ottobre 2026, non inviate.
Raccolta dati: **Sì**. I dati persistenti del backend non sono effimeri.
Non dichiarare “nessun dato raccolto”.

| Tipo console | Raccolto | Obbligatorio/facoltativo | Finalità proposte |
|---|---|---|---|
| Personal info → Name | Sì | Facoltativo | App functionality, Account management |
| Personal info → Email address | Sì | Obbligatorio per account | App functionality, Account management |
| Personal info → User IDs | Sì | Account obbligatorio; Spotify facoltativo | App functionality, Account management, Advertising or marketing per campagne |
| Location → Approximate location | Sì | Facoltativo | App functionality, Personalization, Advertising or marketing per campagne |
| Location → Precise location | Sì | Facoltativo | App functionality, Personalization, Advertising or marketing per campagne |
| Messages → Other in-app messages | Sì | Facoltativo | App functionality, Fraud prevention/security/compliance |
| Photos and videos → Photos | Sì | Facoltativo | App functionality |
| Contacts → Contacts | Sì | Facoltativo | App functionality, Personalization |
| App activity → App interactions | Sì | Dipende dalla funzione | App functionality, Personalization, Analytics, Advertising or marketing |
| App activity → Other user-generated content | Sì | Facoltativo | App functionality; assistenza/sicurezza |
| App activity → Other actions | Sì | Facoltativo | Personalization, App functionality; preferenze musicali derivate |
| App info and performance → Diagnostics | Sì | Facoltativo con invio supporto | Analytics, App functionality |
| Device or other IDs | Sì | Facoltativo con push | App functionality, Developer communications, Advertising or marketing per campagne |

Contacts comprende il grafo sociale, non solo una rubrica. Chat dell'app non
sono SMS/MMS. Spotify invia metadati e preferenze, non file audio. Clic su link
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
| Spotify | Connessione OAuth e sincronizzazione musicale | Verificare finalità proprie del provider e categorie trasmesse |
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
- Eliminazione parziale: Spotify può essere scollegato; non promettere un
  meccanismo generale di eliminazione selettiva di qualsiasi categoria.
- Dati cifrati in transito: HTTPS presente nei flussi censiti; risposta “Sì”
  finale subordinata a verifica completa SDK, media e servizi in produzione.
- Revisione di sicurezza indipendente: No, nessun audit documentato.
- Ads: nessun SDK o banner pubblicitario; le campagne proprie facoltative
  restano marketing per le finalità dei dati.
- Nessuna raccolta intenzionale di dati salute/finanza, file audio, video,
  calendario OS, cronologia browser o inventario delle app nel codice attuale.

Privacy: https://vibra-assistenza.newrobin4.chatgpt.site/privacy.html

Eliminazione: https://vibra-assistenza.newrobin4.chatgpt.site/elimina-account.html
