# Vibra — hardening e retest del 12 settembre 2026

## Perimetro e stato

Modifiche nel repository e rilascio esclusivamente sullo staging dedicato `ppecqwnctxygbofdmxkf`. Nessun test o rilascio in produzione. Account e file di prova sintetici. Il pentest complessivo non è concluso: i limiti sotto sono parte del risultato, non verifiche superate.

## Correzioni

- Messaggi: impedite modifiche dirette a reazioni, cancellazioni per altri partecipanti e stato di lettura; RPC con identità della sessione, lunghezza massima e quota di reazioni.
- Segnalazioni: stato di moderazione gestito dal backend, riferimenti ammessi solo ai messaggi ricevuti dal segnalante, limiti ai contenuti. Supporto: stato e timestamp protetti.
- Upload: allegati di supporto attraverso il gateway di validazione, accesso diretto in scrittura negato; corretta gestione dei JPEG malformati.
- Eventi: vietata la pubblicazione di eventi canonici dal client. `resolve-event` usa un evento già verificato o recupera i dati dal provider sul backend; ignora i dati descrittivi inviati dal client. Credenziali provider assenti su staging: recupero esterno non verificato.
- Cancellazione account: eliminazione degli oggetti Storage anche orfani in tutti i bucket, poi hard delete Auth; anonimizzazione delle conversazioni nella transazione del database. Revocati DELETE del profilo e RPC di cancellazione precedenti che aggiravano il gateway.
- Login/logout: rimozione della sessione precedente prima di un nuovo login, pulizia dei provider, cache e log; token isolati per ambiente e account. Le vecchie chiavi globali sono eliminate: è richiesto un nuovo login.
- Spotify: controllo rigoroso della callback OAuth e dello state; controllo del cambio account durante il collegamento. Dio dedicato, rinnovo e retry limitati all’host Spotify, niente logger HTTP dettagliato con segreti.
- Immagini private chat: rimossa la persistenza su cache disco del widget; pulizia delle cache al logout. Redazione dei token nei log e limiti ai log diagnostici sul server.
- Database: privilegi predefiniti restrittivi, ridotta esposizione delle funzioni SECURITY DEFINER, search_path esplicito per le funzioni di notifica e revoca delle RPC di statistiche geografiche PostGIS. Il tentativo di revocare i privilegi sulla tabella di riferimento geografico è invece rimasto inefficace su staging (vedere sotto).

## Evidenze

| Suite | Risultato | File |
| --- | --- | --- |
| Regressioni estese staging | 23/23 | `extended-staging-20260912.jsonl` |
| API/IDOR/sessioni staging | 41/41 | `http-staging-20260912.jsonl` |
| Realtime staging | 3/3 | `realtime-staging-20260912.jsonl` |
| Policy SQL staging | 21/21 | `pgtap-staging-20260912.txt` |
| Regressioni Flutter | 14/14 | `flutter-tests-20260912.txt` |
| Analisi Flutter | nessun errore/warning; un info preesistente in integration_test/auth_session_e2e_test.dart:57 | `flutter-analyze-20260912.txt` |

Pulizia finale verificata: zero utenti Auth, zero oggetti Storage, zero job cron; 51 migrazioni applicate. RPC legacy negata. La verifica effettiva mostra ancora accesso client a spatial_ref_sys: non considerarlo risolto.

Le prove estese e la pulizia finale sono registrate in `extended-staging-20260912.jsonl` e `staging-summary-20260912.json`. La baseline vulnerabile è in `extended-baseline-20260911.jsonl`. Le prove includono casi positivi per evitare che un servizio interamente bloccato venga considerato sicuro.

Le migrazioni del 12 settembre sono applicate in ordine; le funzioni rilasciate sono `delete-account`, `upload-image`, `resolve-event`, `spotify-token-exchange`. La CLI ha segnalato un errore nella cache locale pg-delta dopo il successo delle migrazioni: verifica dello schema e test remoti hanno confermato il risultato; non è stato ignorato un errore SQL. Separatamente, le revoche di spatial_ref_sys hanno prodotto avvisi di privilegi insufficienti: sono registrate come non risolte, anche se la migrazione è stata contabilizzata.

## Condizioni ancora aperte prima del rilascio

1. **Protezione login/password:** precedente retest Auth/Storage: 11 successi, 1 fallimento, 2 casi non verificabili. Il blocco per account dopo tentativi errati e il filtro password compromesse non sono operativi: l’API di configurazione ha restituito 402 sul piano Free. CAPTCHA non configurato. Nessun upgrade acquistato. Vedere `staging-20260911.md`.
2. **Provider:** configurare credenziali dedicate Spotify, Ticketmaster/Bandsintown, Firebase e SMTP e provare i flussi completi. Non sono state copiate né ruotate credenziali di produzione.
3. **Mobile reale:** ancora da verificare build firmate iOS/Android, ispezione dei bundle, backup, proxy TLS/certificati e comportamento su dispositivo. I test Flutter non sostituiscono queste prove.
4. **Concorrenza e privacy:** cancellazione Storage e database non costituiscono una singola transazione; resta da provare la concorrenza con nuovi upload. Gli URL firmati già emessi restano capability fino alla scadenza. Da verificare ulteriormente rinnovo Spotify durante cambio account, cache pregresse e conservazione dei log diagnostici dopo cancellazione.
5. **Advisor:** restano segnalazioni sulle estensioni nello schema pubblico e su RPC privilegiate intenzionali. `spatial_ref_sys` è metadato geografico, non una tabella utenti; il proprietario è supabase_admin e la CLI ha emesso WARNING 01006/01007: le REVOKE nelle migrazioni 00005/00006 non hanno rimosso i privilegi effettivi. La query finale conferma SELECT ancora consentita ad anon/authenticated; serve un intervento sullo schema/estensione con il proprietario corretto. Il rilievo rimane aperto. Nessuna dichiarazione di “zero vulnerabilità”.
6. **Produzione:** nessuna correzione qui descritta è stata distribuita in produzione. Servono completamento delle prove aperte e una procedura di rilascio verificata.

Il riferimento del repository rimane quello originario; ogni comando remoto di questo intervento usa il workdir separato e verifica esplicitamente il riferimento staging. Le credenziali sono conservate fuori repository, senza valori nei report.
