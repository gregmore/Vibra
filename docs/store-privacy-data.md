# Dati per App Privacy e Data safety

Inventario tecnico basato sul codice della versione 1.0.0+2. Serve a compilare
le console; il titolare deve confermare anche i trattamenti dei fornitori e la
configurazione di produzione. Tutti i dati sottostanti sono collegabili
all'account. Il codice non include SDK pubblicitari o tracciamento tra app.

La prima versione pubblica disattiva temporaneamente nuovi collegamenti
Spotify e affinità musicali. La gestione dei dati dei collegamenti precedenti,
la revoca e la cancellazione rimangono rilevanti; verificare le sincronizzazioni
backend preesistenti prima di attestare l’assenza di nuovi flussi musicali.

| Dati | Uso nel servizio | Facoltativi |
|---|---|---|
| Nome, username, email, ID account | Registrazione, autenticazione e profilo | Account richiesto; nome completo non obbligatorio |
| Città, coordinate e posizione evento | Ricerca, vicinanza e accesso alla modalità Live | Posizione dispositivo facoltativa |
| Foto, bio e altri campi del profilo | Profilo e funzioni sociali | Sì |
| Eventuali preferenze Spotify e dati musicali preesistenti | Gestione del collegamento già presente, revoca ed eliminazione; affinità disattivate | Nessun nuovo collegamento nella prima release pubblica |
| Messaggi, allegati e chat evento | Comunicazione e moderazione | Sì |
| Token push e preferenze notifiche | Consegna delle notifiche richieste | Sì |
| Salvataggi, interazioni, clic biglietti e campagne | Funzioni, ricerca eventi e metriche interne | Dipende dalla funzione |
| Versioni app/OS, log depurati e allegati di supporto | Diagnostica e assistenza | Invio con la segnalazione |

Il manifest iOS dichiara uso per funzionalità, personalizzazione e analytics
interni; include marketing proprio per i dati usati dalle campagne facoltative.
Il worker retention richiede `privacy_preferences.marketing_notifications=true`
oltre alle impostazioni push/retention. Verificare opt-in, opt-out e revoca dopo
il deploy; non confermare `privacy_controls_verified` prima di questa prova.

Specificare nelle console le differenze tra raccolta, condivisione con
responsabili/fornitori e tracking: questi termini hanno definizioni proprie.
Verificare i dati transitati a Supabase, Firebase, mappe, provider eventi
e traduzione; le relative policy dipendono anche dagli accordi e dalle
configurazioni effettive. Il manifest non sostituisce questi questionari.

Confermare HTTPS, cancellazione account in-app e URL esterno di richiesta,
retention e backup, email monitorate e titolare nei documenti pubblici.

Fonti: [App Privacy Apple](https://developer.apple.com/app-store/app-privacy-details/),
[Data safety Google Play](https://support.google.com/googleplay/android-developer/answer/10787469).
