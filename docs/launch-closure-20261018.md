# Vibra — chiusura delle verifiche del 18 ottobre 2026

**Candidata 1.0.0+3; invio agli store ancora bloccato.** Il titolare ha
confermato in questa conversazione che né Apple Developer né Play Console
sono attivi. Le prove fisiche e le conferme di presidio non vengono dedotte
dai test automatici o dall'esistenza dei documenti.

## Stato delle quattro attività

| Attività richiesta | Lavoro completato | Requisito ancora aperto |
|---|---|---|
| Login, chat, foto, segnalazioni e cancellazione su telefoni | Protocollo di 17 casi e registro vuoto; fix cancellazione; suite Flutter corrente | iPhone associato ma non raggiungibile, Android assente, due identità di collaudo da indicare/creare; nessun caso fisico completato |
| Notifiche push | FCM v1 attivo e configurazioni locali coerenti; verifiche worker/backend e probe dedicato | Nessun token FCM; APNs senza chiave/certificato; consegna e navigazione sul telefono da provare |
| Account, Play e firma Apple | Chiave Android esistente conservata; verifica rigorosa profilo Apple; iscrizioni ufficiali aperte | Iscrizioni, identità e pagamenti del titolare; Play App Signing; profilo/certificato Apple e IPA |
| Privacy, moderazione e assistenza | Pagine pubbliche verificate, runbook con query e procedure, riscontri tecnici | Referente e presidio casella/code, prove operative, job retention assente e pulizia Storage da definire, conferme fornitori/backup |

## Correzione della cancellazione account

Il client richiede ora HTTP 200 con `deleted: true` dal server. Un errore
locale di cache o logout successivo alla cancellazione remota non lascia
volontariamente attiva la vecchia sessione né induce a ripetere un'eliminazione
già confermata. Una risposta tardiva non disconnette un altro account che ha
nel frattempo effettuato l'accesso.

Le nove regressioni nuove usano un servizio HTTP simulato: nessun account
reale è stato cancellato. La suite Flutter completa del checkout aggiornato
ha superato **295 test**; `flutter analyze --no-pub` non riporta problemi.
Log: `release/qa-20261018/flutter-tests.txt` e `flutter-analyze.txt`.

## Correzione dei worker push in produzione

I cron accodavano le chiamate, ma sette risposte HTTP recenti erano 401.
La chiave usata dallo scheduler coincideva con la chiave corrente del progetto;
il confronto con la configurazione Edge non coincideva. I cinque worker
ora usano una configurazione esplicita allineata alla credenziale già in Vault.
Il gateway continua a verificare i JWT e non sono cambiate identità, privilegi,
destinatari o preferenze. È stato aggiunto il controllo POST a `event-reminders`.

La correzione è distribuita: **18 controlli diretti e 2 tramite Vault/pg_net
superati**. Le prove verificano richieste ignorate, rifiuto dei metodi errati,
rifiuto delle credenziali anonime/assenti, accesso al database con destinatario
sintetico assente e pausa dei job Spotify. Nessuna notifica o riga inbox è
stata creata dalle prove. Il nuovo secret non entra nella configurazione mobile.

Tutti e cinque i worker sono attivi con `verify_jwt=true`. I cinque test Deno
con sei sottocasi FCM e la compilazione dei cinque entrypoint passano.
[Prove di deploy e HTTP](../release/qa-20261018/push-verification.json) e
[verbale push](push-readiness-20261018.md). Il backup precedente e la procedura
di rollback sono conservati privatamente. Questo risultato risolve
l'autenticazione dei worker; **non certifica la consegna a un telefono**.

## Artefatti rigenerati con la correzione

| Artefatto 1.0.0+3 | Esito |
|---|---|
| [Android APK](../release/qa-20261018/artifacts/vibra-android-release.apk) | 60.527.385 byte; firma v2 ufficiale verificata, non debuggabile, SDK target 36 |
| [Android AAB](../release/qa-20261018/artifacts/vibra-android-signed.aab) | 58.963.470 byte; tutti i 443 contenuti firmati verificati contro il certificato ufficiale |
| [iOS .app](../release/qa-20261018/artifacts/vibra-ios-unsigned.app) | Compilata, bundle/versione/build verificati, 219 file; senza firma di distribuzione |

Le librerie Dart di AAB e APK coincidono per tutte e tre le ABI. Le 12 librerie
ELF dell'AAB e lo ZIP dell'APK sono allineati a 16 KB. Le scansioni dei tre
artefatti non rilevano i quattro segreti server noti controllati. Questi controlli
sono statici: nessuno degli artefatti è stato collaudato oggi su telefoni reali.
Nessun pacchetto è stato caricato negli store.

Hash e comandi: [Android](../release/qa-20261018/android-artifacts.json),
[firma AAB](../release/qa-20261018/android-aab-signature.json),
[controlli Android](../release/qa-20261018/android-static-verification.json),
[iOS](../release/qa-20261018/ios-artifact.json). Il manifesto sorgente privato
include anche i file modificati e non committati; il solo commit Git non
identifica la candidata. Le build storiche sono conservate nella loro directory.

## Firma iOS

`python3 script/release/ios_signing.py` produce un rapporto senza modificare
portachiavi o profili. Il preflight store ora richiede un profilo App Store
non scaduto del team configurato, per `com.vibra.app`, con push production,
Sign in with Apple e certificato corrispondente a un'identità locale con chiave
privata. Un certificato di un altro team o un profilo development non bastano.
Il controllo gestisce anche App ID prefix legacy distinti dal Team ID.

I sette test del verificatore sono superati. Il controllo reale fallisce:
l'unico profilo è Personal Team per `com.vibra.app.dev`, scaduto
il 16 ottobre alle 16:53:07 UTC e senza capability push/Apple. Non esiste
un'IPA App Store nuova e firmata. Riscontro: `release/qa-20261018/ios-signing.json`.

## Passaggi del titolare per gli account

1. [Google Play Console](https://play.google.com/console/signup): scegliere
   l'account adatto al soggetto reale, verificare identità/contatti e completare
   contratto e quota. La sessione Google dell'app è disponibile; la navigazione
   preparatoria non ha registrato un account o accettato accordi.
2. [Apple Developer](https://developer.apple.com/enroll/): accedere con il
   proprio Apple Account e completare l'iscrizione del titolare. La pagina
   attuale richiede accesso. Non sono stati inviati documenti o pagamenti.
3. Dopo l'attivazione Apple, impostare il Team ID effettivo in Xcode e
   `release/store-config.json`; registrare `com.vibra.app`, abilitarne le
   capability, ottenere certificato/profilo App Store e configurare APNs in
   Firebase. Non sostituire il Team ID con un valore inventato.
4. In Play creare la scheda `com.vibra.app`, attivare Play App Signing,
   registrare SHA-1/SHA-256 di distribuzione in Firebase/OAuth e distribuire
   prima in test interno. Conservare la chiave di upload Android esistente.
5. Per un nuovo account personale Play, completare il test chiuso con almeno
   **12 tester per 14 giorni consecutivi** e chiedere accesso alla produzione.
   Il conteggio inizia dalle adesioni effettive; nessun periodo è già trascorso.

Le fonti ufficiali consultate il 18 ottobre indicano **25 USD una tantum** per
[Play Console](https://support.google.com/googleplay/android-developer/answer/6112435?hl=it)
e **99 USD per anno**, con prezzo locale durante l'iscrizione, per
[Apple Developer](https://developer.apple.com/programs/enroll/).
Le verifiche identità e i contratti richiedono la partecipazione del titolare.
I [requisiti del test chiuso](https://support.google.com/googleplay/android-developer/answer/14151465?hl=it)
non possono essere soddisfatti da test locali o emulatori.

## Prove fisiche e presidio

Collegare e sbloccare i telefoni, usare due identità esplicitamente destinate
al collaudo e applicare [il protocollo](device-acceptance-20261018.md).
L'identità da eliminare deve essere quella di prova, dopo tutti gli altri casi.
Nessuna prova invia messaggi o notifiche a utenti estranei al collaudo.

Per le push applicare [il verbale specifico](push-readiness-20261018.md).
Per supporto, moderazione e privacy adottare [il runbook](operations-runbook.md)
e completare [le attestazioni operative](operations-verification-20261018.md).
La sola dichiarazione di disponibilità del referente non chiude i collaudi
tecnici di ricezione, presa in carico, blocco, revoca e cancellazione.

Il preflight tecnico positivo verifica i file del progetto; i flag operativi
di `release/store-config.json` restano falsi fino alle rispettive evidenze.
Le registrazioni e le firme non sono state simulate o considerate completate.
