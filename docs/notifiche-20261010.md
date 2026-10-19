# Notifiche — verifica del 10 ottobre 2026

## Correzioni applicate

- Il bootstrap installa i listener prima di recuperare il token. Su Apple attende
  `getAPNSToken()` prima di chiamare `getToken()`, con massimo 20 tentativi a
  distanza di 3 secondi. Login, ritorno in foreground e riattivazione del consenso
  riavviano la sincronizzazione. La dismissione cancella timer e listener.
- L'interruttore salva `users.push_enabled` sul server; il token viene cancellato
  quando il consenso è disabilitato. Le preferenze locali sono per account, con
  migrazione conservativa dell'eventuale vecchio opt-out.
- Un trigger PostgreSQL impedisce che un refresh tardivo reintroduca un token
  mentre `push_enabled` è falso. La migrazione è applicata al progetto hosted.
- Le notifiche relative a eventi aprono il dettaglio dell'evento recuperato dal
  database, con ripiego su Esplora se non più disponibile.
- Il payload FCM include priorità e suono per Android e APNs.
- I promemoria rispettano consenso globale e categoria eventi, calcolano i giorni
  nel fuso Europe/Rome, escludono gli eventi già iniziati e conservano l'inbox
  anche senza token. Una chiave univoca impedisce duplicati dello stesso evento
  e traguardo (oggi/domani/tra sette giorni). `count` riporta gli inserimenti
  effettivi, `sent` le richieste accettate da FCM.

Aggiornati sul server `event-reminders`, `send-chat-notification`,
`send-social-notification`, `send-notifications`, `retention-notifications`.
Migrazione: `20261010000002_notification_consent_and_reminders.sql`.

## Configurazione verificata

Il service account locale appartiene al progetto `vibra-3f307` e corrisponde
al secret hosted `FIREBASE_SERVICE_ACCOUNT_JSON` (confronto del digest, senza
esposizione del contenuto). Google accetta l'asserzione OAuth RSA. Una richiesta
FCM `validate_only: true` con token volutamente invalido restituisce
`INVALID_ARGUMENT`, non un errore di autenticazione. Questa verifica non prova
la consegna a un dispositivo, né l'autorizzazione APNs.

La console Firebase del progetto mostra FCM HTTP v1 attivo. Per l'app Apple
`com.vibra.app` non sono configurate chiavi APNs di sviluppo/produzione né
certificati APNs. Non è stata trovata una chiave `.p8` in Downloads/Documents.

È collegato un iPhone fisico. Il provisioning disponibile per la build Debug
`com.vibra.app.dev` è un Personal Team gratuito, privo di
`aps-environment`. Debug usa appositamente entitlements vuoti; Release/Profile
usano `com.vibra.app` e gli entitlements APNs. Il debug attuale non è una build
con cui provare la consegna APNs. Questo non certifica lo stato di eventuali
altri abbonamenti Apple dell'utente.

Al controllo, i tre profili hosted non avevano token FCM registrati. Nessuna
notifica di prova è stata inviata agli utenti.

## Passi necessari per la prova reale iPhone

1. Usare un team Apple Developer che supporti Push Notifications e registrare
   `com.vibra.app` con tale capability. Generare un provisioning coerente con
   il team, il bundle e l'ambiente APNs della build.
2. Creare/fornire una chiave APNs `.p8` e configurarla nella console Firebase,
   Project settings → Cloud Messaging → Apple app configuration → `com.vibra.app`,
   con Key ID e Team ID corretti e gli ambienti necessari. Conservare la chiave
   fuori dal repository.
3. Installare sul telefono una build firmata con quel provisioning (Profile o
   Release/TestFlight), accedere e autorizzare le notifiche. Verificare che il
   proprio profilo abbia `push_enabled = true` e un token FCM non vuoto.
4. Inviare una notifica di prova solo al dispositivo scelto. Verificare ricezione
   in foreground/background, apertura dell'evento/chat e avvio da app terminata.
   Disabilitare le push e verificare `push_enabled = false`, token nullo e mancata
   consegna; riabilitare e verificare la nuova registrazione.

La parte iOS resta aperta fino a questa prova. I test automatici e l'accettazione
HTTP di FCM non equivalgono alla ricezione sul telefono. I promemoria sono
accodati una volta per traguardo; non è implementata una coda di retry persistente
per le consegne FCM fallite dopo la creazione dell'inbox.

## Verifiche automatiche

- Analisi Flutter senza problemi; suite Flutter completa e test su token tardivo,
  errore temporaneo, logout durante la lettura e migrazione delle preferenze.
- 12 test Edge, con 6 sottocasi FCM, superati; tutti gli entrypoint TypeScript validi.
- 30 test pgTAP sul database hosted superati; fixture e grant sono in transazioni
  annullate. Inclusi opt-out, refresh concorrente e deduplicazione dei promemoria.
- La query REST con le relazioni usate dai promemoria è verificata senza leggere
  dati utente (`limit=0`).

Documentazione ufficiale:
[Firebase Flutter/APNs](https://firebase.google.com/docs/cloud-messaging/flutter/get-started)
e [ricezione messaggi Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages).
