# Vibra — riscontri operativi del 18 ottobre 2026

Ambito: privacy, moderazione e assistenza della candidata `1.0.0+3`.
Il [runbook operativo](operations-runbook.md) è pronto per l'esecuzione del
titolare. **Presidio e collaudi operativi non sono attestati.** I documenti
pubblici, i questionari e i flag di release non sono stati modificati.

## Controlli eseguiti

| Controllo | Riscontro del 18 ottobre | Limite dell'evidenza |
|---|---|---|
| Titolare e contatti | `store/owner.json`, materiali store e pagine indicano {{LEGAL_NAME}}; contatti pubblici coerenti | Non prova accesso, ricezione posta o copertura |
| Pagine privacy/supporto/eliminazione/sicurezza | Quattro richieste GET HTTPS con User-Agent `Vibra-readiness-readonly/1.0`: HTTP 200; testo visibile corrispondente alle copie `store/site/dist`; contatto configurato presente | Nessuna prova di invio o risposta; HTML intero differente per contenuti aggiunti dall'hosting |
| Assistenza in-app | `SupportService.submit()` inserisce in `support_reports`, usa diagnostica limitata/depurata e screenshot facoltativo via `upload-image` | Ispezione del codice, nessun ticket di produzione creato |
| Accessi coda supporto | Hosted: RLS attiva, inserimento proprio, nessuna policy permissiva client SELECT/UPDATE; guard invio attivo. I grant hosted sono più ampi dei minimi del repository, ma la RLS ne limita l'esercizio | Ispezione ACL/policy/trigger effettivi; nessun account disposable disponibile per prova end-to-end |
| Moderazione | `reports`, blocchi bilaterali e controlli messaggi presenti; stato delle segnalazioni gestito dal backend | Nessun ruolo moderatore, interfaccia amministrativa dedicata o sospensione operativa dimostrata |
| Protezione immagini | Backend valida/decodifica i file; bucket supporto privato | Non è classificazione di abusi o contenuti illegali |
| Export | RPC autenticata `export_my_personal_data()` e salvataggio JSON in-app presenti | Alcune categorie richiedono integrazione/valutazione manuale; non prova richiesta di accesso completa o file recuperabile su device |
| Revoca posizione | Migrazione `20261013000001` condiziona salvataggio al consenso e cancella coordinate all'opt-out | Nessuna nuova prova su account/device in questa verifica |
| Eliminazione in-app | `delete-account`: verifica sessione, fence upload, API Storage in lotti, hard delete Auth; trigger neutralizza messaggi e pulisce dipendenze | Ispezione del codice, nessuna cancellazione di account effettuata |
| Eliminazione esterna | Pagina email pubblica presente; runbook descrive identità e sequenza amministrativa equivalente | Non esiste una prova operativa completa senza app; niente invio email o hard delete durante il controllo |
| Conservazione | Funzione presente hosted; zero job cron che la invochino e nessun ultimo run associato. Finestre codificate 30 giorni/12 mesi/24 mesi | **Blocco tecnico reale:** pulizia automatica non configurata nel cron consultato; la funzione non elimina oggetti Storage dei media scaduti |
| Sessioni | API/RLS/Edge Functions controllano esistenza sessione Auth | Ban e revoca amministrativi devono essere provati con più sessioni su account controllato |
| Backup/fornitori | Inventario e questionari identificano flussi e decisioni ancora necessarie | Nessuna nuova verifica piano backup, accordi, trasferimenti o restore |
| Account developer | Il titolare conferma in questa conversazione di non avere account developer attivi | La conferma non attiva account, accordi o referente Play |

Un client HTTP senza User-Agent dedicato ha ricevuto 403 dalla piattaforma di
hosting; le richieste con User-Agent indicato hanno ricevuto 200. Questa
osservazione non prova il comportamento di ogni browser o rete.

La differenza fra categorie dell'export e inventario è una **copertura da
valutare per la singola richiesta**, non una decisione di consegnare tutto.
Segnalazioni, identità dei segnalanti e informazioni di sicurezza possono
richiedere esclusione o oscuramento a tutela di terzi. Il runbook prescrive
revisione e motivazione prima della consegna.

## Verifica hosted in sola lettura

Progetto Supabase collegato a `supabase/.temp/project-ref`, controllato contro
l'identificatore atteso del progetto di lancio prima della richiesta. Usata la
Management API `POST /v1/projects/{ref}/database/query` con `read_only=true`,
`BEGIN TRANSACTION READ ONLY`, timeout SQL locale di 10 secondi e `ROLLBACK`.
La credenziale CLI è stata letta dal portachiavi solo in memoria, senza
stamparla o salvarla. Le query hanno restituito esclusivamente conteggi e
metadati di schema/ACL/policy: nessun UUID utente, email, contenuto, allegato,
coordinata o token è stato consultato o esportato.

Snapshot aggregato alle **23:27 Europe/Rome del 18 ottobre 2026**
(`21:27:38 UTC`):

| Misura hosted | Risultato |
|---|---|
| `support_reports`: open / in_progress / resolved | 0 / 0 / 0 |
| `reports`: pending / reviewed / action_taken | 0 / 0 / 0 |
| Cancellazioni avviate non concluse (`account_erasures`) | 0 |
| Job `cron.job` il cui comando contiene `apply_data_retention` | 0 totali; 0 attivi |
| Ultimo run associato ai job corrispondenti ancora presenti | Assente (`null`) |
| Live oltre 30 giorni / log interazioni oltre 12 mesi | 0 / 0 |
| Clic biglietti oltre 12 mesi / messaggi diretti oltre 24 mesi | 0 / 0 |

La coda vuota non dimostra presidio o un test di segnalazione riuscito. I
conteggi per età consultano soltanto timestamp e non dimostrano cancellazione
automatica; potrebbero non esistere dati abbastanza vecchi. La ricerca cron
non esclude uno scheduler esterno o job già rimossi: non ne è stata fornita
evidenza. Non è stata pianificata o eseguita alcuna pulizia.

Le seguenti funzioni sono tutte presenti nel runtime:

| Funzione | Esecuzione anon | Esecuzione authenticated | Esecuzione service_role |
|---|---|---|---|
| `export_my_personal_data()` | No | Sì | Sì, ma richiede un `auth.uid()` utente per il risultato |
| `begin_account_erasure(uuid)` | No | No | Sì |
| `list_account_storage_objects(uuid)` | No | No | Sì |
| `prepare_my_account_erasure()` — percorso legacy | No | No | Sì |
| `apply_data_retention()` | No | No | Sì |
| `erase_profile_dependencies()` — funzione trigger | No | No | Sì; uso previsto tramite trigger |

La presenza e i privilegi non attestano l'esecuzione riuscita. Il percorso
corrente resta `delete-account` più le routine amministrative descritte nel
runbook, senza usare la funzione legacy come sostituto.

Verifica aggiuntiva di privilegi **effettivi** delle code (ACL + RLS):

| Controllo | `support_reports` | `reports` |
|---|---|---|
| RLS abilitata | Sì | Sì |
| Grant authenticated SELECT/INSERT/UPDATE hosted | Sì/Sì/Sì | Sì/Sì/Sì |
| Policy permissive SELECT client | 0: nessuna lettura della coda | 1: solo `auth.uid() = reporter_id` |
| Policy permissive UPDATE client | 0: aggiornamento non ammesso | 0: aggiornamento non ammesso |
| Policy permissiva INSERT client | 1: solo `auth.uid() = user_id` | 1: solo `auth.uid() = reporter_id` |
| Policy restrittive aggiuntive | 1 | 1 |
| Trigger protezione invio specifico abilitato | Sì | Sì |
| service_role SELECT/UPDATE | Sì/Sì | Sì/Sì |

Le espressioni di ownership sono state confrontate con quelle attese e sono
risultate corrispondenti. In presenza di RLS, il solo grant SQL non concede
accesso senza una policy permissiva applicabile. Di conseguenza i grant
hosted SELECT/UPDATE più ampi non consentono al client di leggere la coda
supporto o modificare gli stati. Il client può leggere le proprie segnalazioni
di moderazione. Anche `DELETE public.users` risulta negato ad authenticated.
La prova non ha impersonato utenti reali, creato sessioni o esercitato scritture:
il collaudo completo richiede account controllati sacrificabili.

Evidenza locale con soli aggregati e metadati:
`release/qa-20261018/operations-hosted-readonly.json` (cartella release ignorata
da Git). Il runbook include un piano concreto di correzione retention e un
comando futuro, esplicitamente non eseguito e subordinato alla pulizia Storage.

## Esecuzione riproducibile della verifica pubblica

Il controllo ha confrontato testo senza tag, script o CSS, con spazi
normalizzati; nessun contenuto personale è stato scritto nel log.

```sh
python3 - <<'PY'
import hashlib, json, re, urllib.request
from pathlib import Path
owner = json.loads(Path('store/owner.json').read_text())
def text_visible(value):
    value = re.sub(r'<script\b[^>]*>.*?</script>', '', value, flags=re.S|re.I)
    value = re.sub(r'<style\b[^>]*>.*?</style>', '', value, flags=re.S|re.I)
    return re.sub(r'\s+', ' ', re.sub(r'<[^>]*>', ' ', value)).strip()
for page in ('privacy.html', 'supporto.html', 'elimina-account.html', 'sicurezza.html'):
    request = urllib.request.Request(
        owner['public_site_url'].rstrip('/') + '/' + page,
        headers={'User-Agent': 'Vibra-readiness-readonly/1.0'})
    with urllib.request.urlopen(request, timeout=20) as response:
        remote = response.read().decode()
        status, https = response.status, response.url.startswith('https://')
    local = Path('store/site/dist', page).read_text()
    print(json.dumps({'page': page, 'http': status, 'https': https,
        'visible_text_matches_repository': text_visible(remote) == text_visible(local),
        'contains_public_mailbox': owner['support_email'] in remote}))
PY
```

## Attestazioni che richiedono il titolare o prove controllate

Le caselle vuote sono intenzionali. Riempirle con data, responsabile e
riferimento privato all'evidenza; non inserire dati personali nel repository.

| Attestazione/prova | Stato | Evidenza minima richiesta |
|---|---|---|
| Accesso e presidio casella pubblica, inclusi spam e assenze | Da confermare | Ricezione/risposta di una prova e copertura decisa da il titolare |
| Obiettivo pubblico 48 ore lavorative sostenibile | Da confermare | Responsabile, frequenza controlli, gestione urgenze/assenze |
| Ricezione e gestione ticket in-app, anche screenshot | Da provare | Ticket sintetico, presa in carico, risposta reale, stato corretto |
| Segnalazione/blocco/azione su contenuto e ricorso | Da provare | Due account controllati, record e azione verificata sul server |
| Ban e revoca di tutte le sessioni | Da provare | Account controllato con due sessioni; nuovo login e vecchie richieste negati |
| Referente sicurezza minori disponibile e preparato | Da confermare | Accettazione il titolare, canale e procedura applicabile; designazione Play quando attiva |
| Export, revisione categorie/terzi e consegna protetta | Da provare | Pacchetto controllato, redazioni motivate, file recuperabile su device |
| Revoca consenso posizione/marketing/push | Da provare | Scelta persistita, effetto backend, nessun ripristino tardivo |
| Cancellazione da app e richiesta esterna | Da provare | Identità verificata, Storage vuoto, Auth/sessioni/profilo rimossi, messaggi neutralizzati |
| Pianificazione retention dei dati | **Assente nel cron hosted consultato: blocco tecnico** | Piano e comando futuro nel runbook; servono cleanup Storage, job effettivo, log e prova sintetica isolata |
| Eliminazione effettiva file scaduti | Da definire/provare | Percorso Storage provato, distinto dallo svuotamento dei riferimenti SQL |
| Durate email/supporto/moderazione/log/notifiche | Da decidere | Criteri, durata o revisione periodica, responsabile e modalità cancellazione |
| Backup/PITR/Storage/restore | Da verificare | Piano effettivo e durata; restore isolato e riapplicazione cancellazioni |
| Ruoli fornitori e trasferimenti; questionari store finali | Da confermare | Contratti/configurazioni effettive e revisione del titolare |

## Esito

Preparazione documentale completata: procedure, query aggregate in sola
lettura, triage e criteri di evidenza disponibili. Restano necessarie prove
controllate e attestazioni personali del titolare; nessuna di esse è stata
dedotta dall'esistenza del codice o delle pagine pubbliche. Nessuna email
inviata, nessuna modifica ai dati di produzione, nessun test Flutter avviato.

Riferimenti tecnici: `lib/core/services/support_service.dart`,
`lib/presentation/screens/profile/privacy_controls_screen.dart`,
`lib/data/datasources/supabase_social_datasource.dart`,
`supabase/functions/delete-account/index.ts`, migrazioni
`20260827000004`, `20260827000005`, `20260827000006`, `20260911000000`,
`20260912000000`, `20260912000001`, `20260912000007`, `20261013000000`,
`20261013000001`, `20261013000002`, e `supabase/setup_notification_cron.sql`.
Le [fonti ufficiali](operations-runbook.md#fonti-ufficiali-consultate-il-18-ottobre-2026)
sono state consultate per diritti privacy, incidenti, UGC e sicurezza minori.
