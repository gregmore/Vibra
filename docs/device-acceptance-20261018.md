# Vibra — collaudo su telefoni del 18 ottobre 2026

**Stato: prove su telefoni non eseguite.** Questo documento è il protocollo di
accettazione, non un'attestazione di successo. Nessun account è stato creato,
modificato o eliminato nel backend durante la preparazione del protocollo.

L'inventario locale rileva un iPhone 16e con iOS 27.0.1, ma non una connessione
utilizzabile: le interrogazioni a stato di blocco e app falliscono con codici
4000/4016; l'ultima connessione registrata risale al 15 ottobre. Non risulta
collegato un telefono Android. Il profilo iOS debug Personal Team trovato è
scaduto il 16 ottobre e non abilita APNs o Sign in with Apple. Il rilevamento
del telefono e la compilazione iOS senza firma non sono prove di esecuzione.

## Ambiente e identità di collaudo

Usare un ambiente staging isolato con le migrazioni della candidata, Firebase
e provider OAuth abilitati per quel progetto. In alternativa, l'utilizzo di
account esplicitamente di test in un ambiente condiviso richiede prima la
verifica del segmento fidato `auth.users.raw_app_meta_data.is_test_user`: i
due account devono poter interagire fra loro e non con utenti reali.

| Alias riservato | Uso | Stato attuale |
|---|---|---|
| `QA_A` | Login, mittente, foto, segnalante e account da eliminare per ultimo | Identità non creata; UID da registrare privatamente |
| `QA_B` | Destinatario, risposte, soggetto delle segnalazioni di prova, controllo che l'account rimanga attivo dopo la cancellazione di A | Identità non creata; UID da registrare privatamente |

Gli alias sono dichiarazioni del piano, non credenziali esistenti. Usare caselle
e provider controllati dal titolare del collaudo. Password, token, codici OAuth,
device token APNs/FCM e chiavi non vanno inseriti nei report. Una segnalazione
deve riportare il prefisso `QA — test concordato` e riguardare solo `QA_B`.
Svolgere la cancellazione dopo gli altri casi. Per ripetere il ciclo sull'altra
piattaforma, ricreare l'identità eliminata e annotare il nuovo UID; non
riutilizzare un'esecuzione Android come prova iOS.

Installare una build release firmata e registrare SHA-256 dell'artefatto,
versione, numero build e manifesto delle modifiche sorgente. Una modifica
successiva al codice richiede una nuova build e una nuova registrazione delle
prove interessate. Il fix di cancellazione introdotto il 18 ottobre non è
contenuto negli APK/AAB storici del 15 ottobre.

## Matrice di accettazione

Eseguire ogni riga su Android e iOS fisici. `LOGIN-APPLE` si applica solo a iOS.
Per ciascuna esecuzione conservare timestamp, alias, video/screenshot e riscontro
server limitato alle identità di test. Un solo screenshot della schermata
iniziale non basta a dimostrare il completamento di un flusso.

| Caso | Passaggi su telefoni e due account | Prova attesa | Android / iOS |
|---|---|---|---|
| `LOGIN-EMAIL` | Da installazione pulita accedere via email con A; uscire e accedere con B. Se la registrazione è prevista, confermare email e ritorno in app. | Profilo del solo account corretto, sessione valida, nessun errore o schermata protetta accessibile da ospite. | Non eseguito / Non eseguito |
| `LOGIN-GOOGLE` | Aprire Google da welcome, scegliere l'identità di test, completare provider e ritorno all'app; ripetere dopo logout. Android: ripetere dalla build installata tramite Play quando disponibile. | Scambio Supabase riuscito; UID di test corretto. Video del ritorno e riscontro sessione; nessun token nel report. | Non eseguito / Non eseguito |
| `LOGIN-APPLE` | Su iPhone avviare Apple, completare nonce/provider e ritorno; uscire e ripetere. | Identità di test corretta, nome/email opzionali gestiti; nessun blocco del ritorno in app. Richiede firma/capability Apple valide. | Non applicabile / Non eseguito |
| `LOGIN-CANCEL-ERROR` | Annullare Google/Apple; tentare password errata per B dopo logout di A. | Nessun accesso involontario ad A, messaggio comprensibile, possibilità di riprovare. | Non eseguito / Non eseguito |
| `LOGIN-RESTORE` | Accedere con A, chiudere forzatamente e riaprire; ripetere dopo scadenza o revoca della sola sessione di test. | Ripristino della propria sessione valida; sessione revocata richiede accesso, senza mostrare dati riservati. | Non eseguito / Non eseguito |
| `ACCOUNT-SWITCH` | Su stesso telefono uscire da A e accedere come B; visitare chat, foto, profilo e bozze di supporto. | Nessun contenuto privato o bozza di A attribuito a B, token push non lasciato sull'account precedente. | Non eseguito / Non eseguito |
| `CHAT-ROUNDTRIP` | Accettare amicizia A/B; A invia un testo univoco, B risponde; chiudere/riaprire chat. | Entrambi vedono una sola copia di ogni messaggio, mittente e ordine corretti, persistenza dopo riapertura. Due riprese e ID messaggi di test. | Non eseguito / Non eseguito |
| `CHAT-PERMISSIONS` | Prima dell'amicizia provare contatto senza GPS; accettare amicizia e inviare senza GPS; bloccare B da A, poi provare da entrambi; sbloccare prima dei casi successivi. | Motivo di indisponibilità comprensibile; amici possono scriversi senza GPS; blocco impedisce nuovi invii in entrambe le direzioni. Nessuna posizione o direzione del blocco esposta. | Non eseguito / Non eseguito |
| `CHAT-RECOVERY` | A prepara testo, attiva modalità aereo, invia, ripristina rete e riprova una sola volta. | Errore recuperabile e testo conservato; dopo retry un solo messaggio, nessuna finta conferma durante offline. | Non eseguito / Non eseguito |
| `PHOTO-SAVE` | A apre Modifica profilo, sceglie un JPG/PNG di prova, verifica anteprima, annulla; ripete confermando; B riapre il profilo di A. | Annullamento conserva foto iniziale; conferma salva foto nuova, visibile anche dopo riapertura e a B; path Storage appartiene ad A. | Non eseguito / Non eseguito |
| `PHOTO-RECOVERY` | Negare permesso galleria, riprovare; interrompere upload in modalità aereo; ripristinare rete e salvare; su Android verificare anche ritorno dal picker dopo sospensione. | Indicazioni per il permesso negato; anteprima conservata dopo errore e nessun salvataggio falso; nessuna foto duplicata o attribuita a B dopo cambio account. | Non eseguito / Non eseguito |
| `REPORT-SUPPORT` | Da A aprire Segnala problema, testo `QA — test concordato` e screenshot sintetico; inviare. | Conferma solo dopo INSERT riuscito; riscontro nella coda privata con UID A e allegato privato. B non può accedere alla coda o all'allegato. | Non eseguito / Non eseguito |
| `REPORT-USER` | Dalla chat A/B aprire Segnala utente, motivo e descrizione di prova; verificare gestione nella coda di moderazione di staging. | Una segnalazione privata con reporter A e soggetto B, stato iniziale gestito dal backend; conferma e nessuna notifica pubblica al segnalato. | Non eseguito / Non eseguito |
| `REPORT-RECOVERY` | Negare galleria, usare solo testo; interrompere invio in modalità aereo, poi riprovare; cambiare da A a B mentre una bozza è aperta. | La segnalazione rimane utilizzabile; bozza conservata dopo errore; nessuna conferma falsa, duplicazione dell'allegato al retry o bozza di A visibile/attribuita a B. | Non eseguito / Non eseguito |
| `PRIVACY-CONSENT` | Da A attivare/revocare posizione e notifiche opzionali; riaprire schermata; B deve conservare le proprie preferenze; esportare i dati di A. | Scelta persistita, revoca rispettata anche dal server; JSON leggibile del solo A, senza segreti né dati privati di B. Per consegna push usare il protocollo notifiche. | Non eseguito / Non eseguito |
| `DELETE-CANCEL` | Da Impostazioni di A scegliere Elimina account e poi Annulla. | Nessuna richiesta al servizio di cancellazione, account/sessione/foto/chat ancora disponibili. | Non eseguito / Non eseguito |
| `DELETE-CONFIRM` | Dopo tutti gli altri casi, eliminare A con foto, chat in entrambe le direzioni e screenshot di supporto; riavviare app; provare vecchia sessione e credenziali; accedere come B. | Successo solo dopo `{deleted:true}`; uscita e cache pulita; Auth/profilo, oggetti Storage di A e diagnostica eliminati, vecchia sessione respinta; B resta attivo. Dati eventualmente conservati devono seguire la policy, senza riferimenti personali di A. | Non eseguito / Non eseguito |

Per `DELETE-CONFIRM` la prova client va accompagnata da controlli autorizzati e
ristretti agli UID/path di A nel backend di test: assenza delle righe previste,
assenza degli oggetti anche orfani nei bucket avatar/chat/supporto, rifiuto del
vecchio JWT e sopravvivenza di B. Non confermare una cancellazione solo perché
l'app mostra la schermata di accesso. Per un errore server, la prova attesa è
un errore recuperabile e nessuna attestazione di avvenuta cancellazione.

## Registro delle evidenze

Copiare [il registro vuoto](../script/release/device_qa.example.json) in
`release/qa-20261018/device-qa.json`, directory esclusa da Git. I campi
`builds`, `devices` e `runs` sono inizialmente vuoti: nessuna prova è registrata
come superata. Compilare prima l'ambiente e gli UID di test; aggiungere quindi
un record per ogni esecuzione e piattaforma. `physical` deve provenire dal
dispositivo realmente usato, non dal nome dell'emulatore.

In ogni `run` registrare `build_sha256`, `device_id`, `case_id`, alias dei
partecipanti, inizio/fine ISO 8601 con fuso, `result` ed `evidence`. Ogni evidenza
ha percorso locale relativo al registro, SHA-256 del file e descrizione del
riscontro. Oscurare dati e notifiche personali prima di salvare screenshot o
video. Il manifesto sorgente deve descrivere anche le modifiche non committate;
il solo SHA Git non identifica una build ottenuta da un checkout modificato.

Un esito `blocked`, `failed` o `not_executed` lascia aperto il requisito. Le
catture con fixture e i test automatici si registrano separatamente e non
riempiono i record fisici. Impostare `physical_device_qa_verified` nel file
privato di release solo dopo esiti positivi documentati delle due piattaforme.

## Copertura automatica e limiti

L'analisi del codice ha trovato copertura automatica per confine delle sessioni
(`test/core/auth_boundary_test.dart`), autorizzazioni/stream chat, galleria foto,
upload validato e invio di supporto con screenshot. Questi test usano mock o
fixture: non eseguono OAuth nativo, picker del sistema, rete mobile o due app
installate su telefoni. I test SQL esistenti verificano sessioni revocate,
segregazione, permessi dei messaggi e segnalazioni private in transazioni
annullate. Al controllo del 18 ottobre non risultano container Docker attivi;
non sono stati avviati servizi o eseguite nuove prove SQL in questa attività.

Per rieseguire i test SQL in un ambiente locale già disponibile usare
`script/security/test_database.sh LOCAL_SUPABASE_WORKDIR`: accetta solo il
container locale identificato dalla configurazione. La procedura di erasure
HTTP `script/security/probe_extended.py` crea e cancella identità sintetiche:
non è stata eseguita in questa attività e non va indirizzata alla produzione.

Il controllo del client ha individuato un difetto nella cancellazione:
qualunque risposta 2xx era considerata successo e un errore di pulizia locale
poteva impedire il logout dopo l'avvenuta cancellazione remota. Il client ora
richiede HTTP 200 e `deleted: true`, chiude la sessione anche se la cache fallisce
e preserva un altro account subentrato durante la richiesta. I test di
regressione in `test/core/account_deletion_test.dart` usano un server simulato;
non attestano una cancellazione su telefoni o sul backend pubblico.

Il 18 ottobre sono stati eseguiti con esito positivo **12 test** tramite
`flutter test test/core/account_deletion_test.dart test/core/auth_boundary_test.dart --reporter expanded`:
9 nuove regressioni di cancellazione e 3 verifiche dei confini di autenticazione.
Il comando è terminato con exit code 0. Il
[riscontro automatico](../release/qa-20261018/device-automated-verification.json)
registra comando, ambito e hash dei file coinvolti. Il registro JSON di esempio
è stato inoltre letto e verificato come vuoto, senza esecuzioni o UID inventati.

Il presente protocollo lascia aperti OAuth reale, consegna push/APNs,
registrazione/firma store, presidio di supporto e moderazione, oltre al
collaudo fisico. Gli esiti successivi devono essere aggiunti con artefatto,
dispositivo e data, senza attribuirli retroattivamente alle prove storiche.
