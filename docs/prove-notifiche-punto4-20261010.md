# Prove del punto 4 — 10 ottobre 2026

Esito: verifiche automatiche superate; collaudo push reale su iPhone bloccato
prima dell'invio. Il punto 4 non è completo.

## Controlli sul dispositivo e sul backend

- `flutter devices` e `devicectl` rilevano l'iPhone fisico di il titolare collegato.
- `devicectl device info apps --search vibra` identifica la sola app Vibra
  installata come `com.vibra.app.dev`, versione 1.0.0, build 2.
- Il provisioning locale corrispondente è un Personal Team gratuito
  (`LocalProvision = true`) e non contiene `aps-environment`.
- La query hosted sui tre profili restituisce **0 token FCM registrati** e
  0 profili con consenso globale disabilitato. Non sono stati letti né esposti
  token, credenziali o dati identificativi dei profili.
- La precedente verifica Firebase ha rilevato l'assenza di chiavi/certificati
  APNs per `com.vibra.app`; questa sessione non ha modificato la console Firebase.

## Matrice del collaudo reale

| Prova richiesta | Esito | Impedimento |
| --- | --- | --- |
| Ricezione con app in foreground | Non eseguita | Build senza APNs e nessun token destinatario |
| Ricezione con app in background | Non eseguita | Build senza APNs e nessun token destinatario |
| Apertura dell'evento dalla push | Non eseguita | Nessuna push reale ricevibile |
| Apertura della chat dalla push | Non eseguita | Nessuna push reale ricevibile |
| Avvio toccando la notifica ad app terminata | Non eseguita | Nessuna push reale ricevibile |
| Interruttore OFF e mancata consegna sul telefono | Non eseguita | Manca una consegna iniziale verificata e non è stato azionato l'interruttore sul telefono |
| Interruttore ON e nuova registrazione sul telefono | Non eseguita | Build senza APNs |

Non sono state inviate notifiche agli altri utenti né modificate le loro
preferenze. I risultati seguenti verificano componenti automatici; non
sostituiscono le prove della matrice.

## Verifiche automatiche eseguite

`flutter test test/core/push_token_registration_test.dart test/core/push_preferences_test.dart`:
**7 test superati**. Coprono token APNs tardivo, errore temporaneo, cancellazione
al dispose, logout durante la lettura, preservazione dell'opt-out, priorità delle
preferenze per account e una nuova sincronizzazione dopo l'esaurimento dei
retry. Quest'ultimo caso è stato aggiunto per verificare che un successivo
richiamo alla sincronizzazione possa registrare il token diventato disponibile.

`supabase test db --linked`: **30 test superati**, inclusi i sei controlli su
consenso e promemoria. Verificati azzeramento del token con consenso OFF,
impossibilità di reintrodurlo durante l'opt-out, accettazione con consenso ON,
accesso al trigger e deduplicazione. Fixture e modifiche sono annullate al
termine delle transazioni. La suite intera è necessaria perché l'invocazione
CLI con il solo file non monta il setup pgTAP condiviso nel container.

## Requisiti per riprendere

Installare sul telefono una build firmata da un team abilitato alle push,
con bundle e provisioning coerenti, e configurare APNs in Firebase. Dopo login
e autorizzazione delle notifiche deve comparire un token FCM sul proprio
profilo. Solo allora si può inviare una push a quel dispositivo e completare
la matrice, osservando anche ricezione e navigazione sul telefono.

Configurazione e procedura: [notifiche-20261010.md](notifiche-20261010.md).
