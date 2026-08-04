# Vibra - Manual Testing Checklist

Questa checklist contiene gli scenari critici che sono complessi da automatizzare (es. interagiscono con app esterne o hardware di sistema) e devono essere verificati **manualmente prima di ogni rilascio in produzione**.

## 1. Integrazione Spotify (OAuth Reale)
- [ ] **Login Spotify Corretto**: Aprire "Collega Spotify", completare il flusso in un browser/in-app webview e verificare il redirect in app.
- [ ] **Negazione Permessi**: Nel flusso di login Spotify, cliccare "Annulla/Nega" e verificare che l'app Vibra gestisca l'errore senza crash.
- [ ] **Token Scaduto/Revocato**: 
  - Effettuare il login a Spotify con successo.
  - Andare nelle impostazioni account di Spotify (sul web) e revocare l'accesso a Vibra.
  - Aprire l'app Vibra e ricaricare una schermata che richiede dati Spotify (es. refresh match score).
  - Verificare che l'app proponga di ricollegare l'account o mostri un avviso, senza crashare.
- [ ] **Scollegamento**: Dalle impostazioni profilo, cliccare "Scollega Spotify" e verificare che i dati associati (top artisti, generi) vengano rimossi sia dal client che dal server (DB).

## 2. Flusso Acquisto Biglietti (Ticketmaster / Redirect Esterni)
- [ ] **Deep Linking Ticketmaster**: Cliccare "GET TICKETS" su un evento reale e verificare l'apertura corretta della pagina specifica dell'evento su Ticketmaster (browser in-app o Safari/Chrome), non semplicemente la homepage di Ticketmaster.
- [ ] **Ritorno all'app**: Dopo aver aperto il link esterno, chiudere il browser in-app e assicurarsi che l'utente venga riportato all'app Vibra mantenendo lo stato precedente (nessun crash o refresh sgradito).

## 3. Comportamenti di Sistema e Permessi
- [ ] **Notifiche Push**:
  - Inviare una richiesta di amicizia da un account secondario.
  - Verificare la ricezione della notifica push sull'account principale a schermo bloccato.
  - Tappare la notifica e verificare che apra la schermata corretta (Chat o Amici).
- [ ] **Permessi Negati (Geolocalizzazione)**:
  - Nelle impostazioni del dispositivo, negare l'accesso alla Posizione per Vibra.
  - Aprire l'app (tab Esplora/Mappa).
  - Verificare che venga mostrato un messaggio amichevole che richiede la posizione, senza crash.

## 4. Gestione Rete e Offline
- [ ] **Chat Offline**:
  - Togliere connessione dati/Wi-Fi (modalità aereo).
  - Inviare un messaggio in chat.
  - Verificare che appaia un indicatore di "invio in corso" o "in attesa di rete".
  - Ripristinare la connessione e verificare che il messaggio venga inviato con successo.
- [ ] **Sync Eventi**:
  - Salvare un evento nei preferiti mentre in modalità aereo.
  - Verificare gestione errore o salvataggio locale temporaneo (ottimistico).
  - Alla riconnessione, verificare l'effettiva sincronizzazione con il server.
