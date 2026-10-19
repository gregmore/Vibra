# Preparazione store — 7 ottobre 2026

Versione **1.0.0+2**, package e bundle **com.vibra.app**.
La preparazione del progetto è completata; la pubblicazione resta bloccata dai
requisiti sotto. Nessun AAB/IPA firmato è stato presentato come caricabile.

## Modifiche

Rimossi generatori SQL/Dart/Node di bot, utenti, eventi, chat e match fittizi,
script di avvio demo, documentazione dei login condivisi e suite seeded/mock
native. Rimossi gli override Supabase E2E e i bypass di router, sync Spotify e
bootstrap. Eliminato `seed-compatible-users` anche dal progetto Supabase collegato.

Conservati 134 test unitari/widget, test Edge e protezioni RLS di separazione dei
dati. I controlli nativi di secure storage/TLS sono conservati separatamente in
`script/security/native/`; il plugin `integration_test` non è più una dipendenza
dell'app. Le migrazioni già applicate non sono state riscritte.

Aggiornati firma Android obbligatoria senza fallback debug, APNs/entitlements
iOS, manifest privacy, permessi e query per link esterni. Inclusi Syne/Inter con
licenze e disabilitato download runtime. Allineati versione, namespace e file
MainActivity, rimossi il namespace Android duplicato e la configurazione Firebase
Mac di esempio. Invio server aggiornato a FCM HTTP v1 con autorizzazione RSA,
cache dei token, rinnovo su 401 e gestione degli errori senza log di credenziali.
Le campagne retention richiedono consenso marketing esplicito.

Aggiunti preflight store, configurazione di esempio, procedura AAB/IPA, scansione
contro segreti e residui demo, verifica ELF da 16 KB e pulizia amministrativa
limitata a fixture identificabili. Aggiornati metadata IT/EN e guida di rilascio.
I contatti legali preesistenti restano esempi da confermare.

Aggiornamento dell'8 ottobre: rimossi client e dipendenze inutilizzati, attivata
l'ottimizzazione R8 e ridotte le varianti dei font. Il download Android stimato
diminuisce del 31,23%; risultati e ambito delle misure sono nel
[report di alleggerimento](app-size-20261008.md). Rimossi due test relativi
all'interceptor Spotify dismesso.

## Verifiche

| Controllo | Risultato |
|---|---|
| Analisi Flutter | Nessuna segnalazione |
| Unit/widget | 134 superati |
| Deno check entrypoint Edge | Tutti superati |
| Edge unit test | 9 superati, inclusi 5 sottocasi FCM |
| Preflight tecnico | Superato |
| Protezioni preflight | Configurazione valida ammessa; segreto extra, JWT service-role, URL locale e configurazione store incompleta rifiutati |
| Selezione dati demo | 6 casi: esclusi record vuoti, account reali e email mock con ID diverso; riconosciute fixture esplicite |
| XML/plist e script Python/Bash | Validati |
| Limiti metadata | Sottotitoli ≤30, descrizioni brevi ≤80, promo ≤170 e keyword ≤100 caratteri |
| Build iOS Release | Compilata senza firma con Xcode 27 / SDK iOS 27 |
| Bundle iOS | Manifest privacy corrente e 7 font inclusi; 219 file scansionati senza segreti noti o plugin test |
| Android Release | Dart/Java/Kotlin e bundle intermedio compilati; firma finale bloccata dalla chiave mancante |
| Bundle Android intermedio | R8 completato; 443 file scansionati, 4 segreti noti cercati, nessun rilevamento demo/segreti |
| Librerie native Android | 12 librerie, segmenti ELF tutti allineati ad almeno 16 KB |
| APK Android QA | 5 split generati con bundletool, allineamento ZIP da 16 KB superato; avvio su emulatore API 36 verificato |
| Identità Android | target SDK 36, versione 1.0.0, build 2 |

L'allineamento ELF e la verifica ZIP degli APK QA non sostituiscono i controlli
sull'artefatto store firmato né l'esecuzione su un dispositivo con pagine da 16 KB. I test FCM simulano le
risposte HTTP: la consegna push reale resta da verificare. L'analisi dei segreti
cerca valori noti e formati sensibili; non certifica ogni possibile segreto.

## Backend collegato

Aggiornamento del 10 ottobre: migrazioni e funzioni sono state distribuite;
Vault e job periodici configurati. Questo paragrafo conserva lo stato storico
del 7 ottobre. Stato corrente: [report backend](backend-20261010.md).

Controllo amministrativo in sola lettura sul progetto `your-project-ref`:
35 migrazioni registrate, ultima `20260828000001`. **17 migrazioni del repository
mancanti**. Mancano anche le funzioni attive `upload-image` e `resolve-event` e
il secret `FCM_SERVICE_ACCOUNT_JSON`.

Non sono stati trovati account legacy corrispondenti alle email note dei bot,
ai mock conosciuti o alle marcature esplicite; zero eventi marcati o con gli
identificatori del seeder noto. Questo controllo non classifica persone reali
in base al nome visibile e non dimostra l'assenza di dati inseriti manualmente
senza marcatura. Non è stata necessaria alcuna cancellazione di account o eventi.

Le migrazioni di produzione e le funzioni operative aggiornate non sono state
distribuite durante la preparazione. L'unica modifica remota è stata la
rimozione richiesta dell'endpoint demo.

## Requisiti ancora necessari

1. Piano migrazioni, backup, applicazione dei 17 aggiornamenti e deploy delle funzioni correnti.
2. Service account FCM e APNs; prove reali delle push e dei consensi.
3. Keystore Android ufficiale, Play App Signing e certificati OAuth.
4. Apple Developer con certificato/profilo App Store e team coerente.
5. Titolare legale, indirizzo, email attive e pagine pubbliche di privacy, termini, assistenza e richiesta eliminazione account.
6. Accesso Spotify per utenti pubblici, moderazione e assistenza operative.
7. OAuth, account deletion, blocchi, permessi, offline e Live verificati su device fisici.
8. Screenshot reali, questionari privacy/età e istruzioni di review.

Per completare: [RELEASE.md](../RELEASE.md),
[checklist](../SUBMISSION_CHECKLIST.md),
[metadata](../STORE_METADATA.md),
[inventario privacy](store-privacy-data.md).

Artefatti e report locali sono in `release/` (esclusa da Git). Il bundle
`vibra-android-unsigned.aab` e `vibra-ios-unsigned.app` servono soltanto alla verifica tecnica. Le scansioni
JSON e i simboli devono essere rigenerati sul pacchetto firmato prima dell'invio.
Log della preparazione: `/tmp/vibra-release-*.log`.
