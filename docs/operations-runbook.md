# Vibra — procedure operative prima del lancio

Versione del 18 ottobre 2026, candidata `1.0.0+3`. Responsabile del progetto e
titolare: **{{LEGAL_NAME}}**, già indicato nei materiali pubblici. Questo
documento prepara il lavoro del titolare; non attesta un servizio di assistenza
attivo, turni coperti, un SLA, conformità legale o un collaudo completato.
I riscontri disponibili e le attestazioni mancanti sono in
[operations-verification-20261018.md](operations-verification-20261018.md).

## 1. Accessi e responsabilità

| Attività | Responsabile esistente | Accesso necessario | Evidenza da conservare privatamente |
|---|---|---|---|
| Assistenza, segnalazioni e decisioni sui contenuti | {{LEGAL_NAME}} | Casella pubblica in `store/owner.json`; progetto Supabase di lancio | Accesso riuscito, prova di ricezione/risposta, decisione e data del caso |
| Richieste privacy, cancellazione ed esportazione | {{LEGAL_NAME}}, titolare | Stessa casella; Supabase Auth, Database e Storage | Identità verificata, operazione, verifica finale e risposta |
| Sicurezza minori | {{LEGAL_NAME}}, referente pubblico già designato | Canale pubblico della pagina sicurezza; accessi di moderazione | Presa in carico, contenimento, decisione sull'escalation |
| Incidenti e servizi esterni | {{LEGAL_NAME}} | Supabase, Firebase e portali dei fornitori realmente utilizzati | Incidente, impatto, azioni, conferma ripristino |

Non risultano un sostituto designato, un ruolo moderatore nell'app o una
dashboard di moderazione dedicata. Prima di accettare utenti pubblici, il
titolare deve decidere copertura e indisponibilità; se delega, assegnare accessi
nominativi e limitati, registrare la delega e provarne la revoca. Non condividere
password o chiavi di servizio. Abilitare MFA sugli account amministrativi e
conservare il recupero in un luogo protetto sotto il controllo del titolare.

Entrare nel [dashboard Supabase](https://supabase.com/dashboard), selezionare il
progetto di lancio corrispondente alla configurazione privata e verificare
l'identificatore prima di aprire **SQL Editor**, **Table Editor**,
**Authentication → Users**, **Storage** o i log delle Edge Functions.
Distinguere sempre progetto locale, staging e progetto di lancio.
Le query seguenti richiedono privilegi amministrativi: non eseguirle dal client
mobile e non incorporare una service-role key nell'app o nel sito.

## 2. Avvio del presidio e registro dei casi

Prima del lancio, eseguire una prova controllata della casella: invio da un
recapito del titolare, ricezione anche fuori dallo spam, risposta e ricezione
della risposta. La richiesta dell'utente di preparare il lancio non vale come
prova email. Nessuna email è stata inviata durante questa verifica.

La pagina assistenza pubblica presenta un **obiettivo** di prima risposta entro
48 ore lavorative. Non è uno SLA verificato. Il commento della migrazione
supporto propone controllo ogni giorno lavorativo: il titolare deve confermare
che può sostenerlo, indicare chi copre le assenze e definire come intercettare i
casi urgenti anche tra due controlli. Conservare data e risultato delle prove;
la sola pubblicazione dell'indirizzo non dimostra il presidio.

Usare un registro privato, accessibile soltanto a chi gestisce i casi, separato
dal repository e dalle pagine pubbliche. Campi minimi:

```text
id caso; canale; data/ora ricezione con fuso; id record Supabase se presente;
categoria; urgenza; responsabile; scadenza applicabile; identità verificata sì/no;
azioni e motivazione; dati consultati; prima risposta; verifica tecnica finale;
stato; prossima verifica; data/criterio di cancellazione del fascicolo.
```

Non copiare chat, indirizzi, coordinate, password, token, allegati o diagnostica
nei ticket pubblici, nei commit, nei messaggi del team o nei log del terminale.
Registrare gli identificativi e il contesto minimo; consultare il contenuto
soltanto nel pannello protetto quando necessario alla decisione. Non richiedere
password, codici OTP o documenti di identità come procedura ordinaria.

## 3. Controllo delle code senza contenuti personali

Nel SQL Editor eseguire prima questi conteggi. La transazione è in sola
lettura; se il progetto non ha le tabelle previste, fermarsi e verificare la
versione del backend, senza applicare migrazioni per tentativi.

```sql
begin transaction read only;
set local statement_timeout = '10s';

select status, count(*) as casi,
       min(created_at) as ricevuto_piu_vecchio,
       count(*) filter (where created_at < now() - interval '48 hours')
         as oltre_48_ore_di_calendario
from public.support_reports
where status in ('open', 'in_progress')
group by status order by status;

select status, count(*) as casi, min(created_at) as ricevuto_piu_vecchio
from public.reports
where status in ('pending', 'reviewed')
group by status order by status;

select count(*) as cancellazioni_avviate_non_concluse,
       min(started_at) as avvio_piu_vecchio
from vibra_private.account_erasures;

rollback;
```

`48 hours` misura ore di calendario, non l'obiettivo pubblico in ore lavorative.
`reviewed` significa esaminata; può anche rappresentare un caso concluso senza
provvedimento. Poiché `reports` non ha uno stato «archiviato senza azione», il
registro privato deve distinguere casi chiusi e casi ancora da seguire.

Per aprire un caso, nel Table Editor filtrare **un solo id** della tabella
corretta. Per supporto, consultare descrizione e diagnostica strettamente utili;
se serve lo screenshot, aprire il relativo oggetto nel bucket privato
`support-attachments`. Non rendere pubblico il bucket e non pubblicare URL
temporanei di accesso. L'app non può leggere questa coda dopo l'invio.

## 4. Triage, assistenza ed escalation

| Categoria | Prima azione operativa | Condizione di chiusura |
|---|---|---|
| Pericolo immediato, minacce credibili, sospetto CSAE/CSAM | Portare subito il caso al titolare; contenere la diffusione tramite accessi amministrativi; indirizzare un pericolo immediato alle autorità/servizi di emergenza competenti | Contenimento verificato e decisione documentata sugli obblighi e sull'escalation |
| Possibile accesso improprio o esposizione di dati | Trattare come incidente di sicurezza; preservare log minimi, limitare il flusso coinvolto e valutare il rischio | Cause e impatto valutati, rimedio verificato, comunicazioni dovute decise |
| Richiesta privacy o cancellazione | Registrare ricezione e scadenza, verificare identità in modo proporzionato | Risposta completa, eventuali eccezioni motivate, verifica finale |
| Abusi, molestie, contenuti vietati, account di minore | Consultare il contenuto segnalato e le regole pubbliche; valutare rimozione/limitazione | Esito e motivazione registrati, azione effettiva verificata |
| Login, chat, foto, notifiche, eventi | Raccogliere versione, sistema, ora e passi minimi; controllare fornitore/log senza copiare credenziali | Soluzione confermata o errore riproducibile con responsabile e prossimo passo |

Le priorità non costituiscono tempi di servizio già concordati. Il titolare
deve stabilire un contatto d'emergenza e la copertura effettiva. Non esiste in
questa verifica un'assistenza continuativa attestata.

Per un ticket di assistenza: associare il caso privato, impostare `in_progress`
nel Table Editor, inviare una risposta dal canale ufficiale soltanto a cura
dell'operatore autorizzato, registrare `responded_at` dopo l'invio reale, quindi
impostare `resolved` quando il caso è concluso. Il database non spedisce da solo
la risposta e non ha un thread di risposte in-app.

Prima risposta proposta, da adattare e inviare manualmente:

> Abbiamo ricevuto la richiesta. Il riferimento è [id caso]. Per verificare il
> problema servono [informazioni minime]. Non inviare password, codici o token.

## 5. Segnalazioni e moderazione

Le segnalazioni utente sono in `reports`, distinte da `support_reports`.
Il codice offre blocco tra utenti, segnalazione profilo/messaggio ricevuto,
limite dei primi contatti e un filtro base di alcuni link sospetti. La verifica
del formato delle immagini non riconosce contenuti abusivi. Non presentare
queste misure come filtro completo di testi, foto o chat Live.

1. Registrare il caso senza duplicare il materiale. Nel Table Editor aprire
   `reports` per id; verificare autore segnalato, eventuale `message_id`, motivo
   e contesto limitato al caso. Una segnalazione profilo non è prova automatica
   della violazione.
2. Se il caso è fondato, decidere l'azione proporzionata e annotare il motivo.
   Le azioni amministrative avvengono sul backend; il blocco personale del
   segnalante non sospende l'account dal servizio.
3. Per rimuovere un contenuto, identificare il record esatto di `messages`,
   `live_messages` o il campo del profilo; annotare nel fascicolo il riferimento
   prima della rimozione. Eliminare l'eventuale oggetto tramite Storage/API
   Storage, non mediante `DELETE` su `storage.objects`. Una cancellazione di
   messaggio può eliminare anche la relativa segnalazione tramite FK cascade:
   il registro privato deve conservare l'esito minimo, secondo retention decisa.
4. Per limitare un account usare le funzioni amministrative Auth disponibili e
   verificare sia l'impossibilità di nuovi accessi sia la revoca delle sessioni
   già esistenti. Non dedurre che un ban impedisca immediatamente ogni richiesta
   con un JWT ancora valido. Vibra verifica `auth.sessions` in API/RLS e nelle
   funzioni: verificare che le sessioni del caso siano effettivamente rimosse.
   Provare l'intera procedura prima su un account controllato; non improvvisare
   scritture nelle tabelle interne Auth. Se la console non offre la revoca
   necessaria, serve un percorso amministrativo provato prima di attestare la
   capacità di sospensione.
5. Registrare `reviewed` dopo la valutazione; usare `action_taken` soltanto dopo
   che il provvedimento è stato eseguito e controllato. Annotare anche le
   decisioni di non intervenire. Comunicare l'esito dal contatto ufficiale
   quando appropriato, senza rivelare dati del segnalante o di altre persone.
6. Per contestazioni, riesaminare evidenza e regola applicata; registrare la
   decisione. Non ripristinare materiale illegale o pregiudizievole per errore.

Per sospetto CSAM non scaricare, duplicare, inoltrare o inserire il materiale
in un'email. Limitare l'accesso e registrare soltanto contesto e identificativi
necessari; il titolare stabilisce con assistenza competente gli obblighi di
segnalazione e conservazione applicabili. Il referente pubblicato è il titolare;
la sua disponibilità e designazione effettiva nella Play Console devono essere
confermate. Gli standard Google richiedono anche un referente capace di gestire
questi casi, oltre alla pagina pubblica.

Prima del lancio eseguire con account controllati: segnalazione profilo,
segnalazione messaggio, blocco bilaterale e chat Live; controllare il record
server, la presa in carico, un provvedimento reversibile e la verifica su due
sessioni. Non usare contenuti illegali o dati di terzi per la prova.

## 6. Diritti privacy ed esportazione

Registrare la ricezione e pianificare la risposta entro **un mese**, come
indicato dall'EDPB. Un'eventuale estensione consentita va motivata e comunicata
entro il primo mese. La prima risposta di assistenza è un obiettivo distinto.
Verificare l'identità tramite sessione autenticata o recapito associato; in
caso di dubbio chiedere elementi proporzionati e non consegnare dati soltanto
in base a uno username. Non trattare il possesso di un numero caso come prova
di titolarità.

Il percorso automatico è **Impostazioni → Privacy e dati personali → Esporta**.
La RPC `export_my_personal_data()` usa `auth.uid()`, non accetta un id altrui ed
esclude token push del profilo, credenziali OAuth e embedding musicale.
Fornisce profilo, preferenze privacy, eventuali dati Spotify, eventi salvati,
messaggi diretti/Live, match, interazioni e clic biglietti. Il file JSON salvato
resta nella cartella documenti dell'app: verificarne accessibilità sul device.

Per una richiesta di accesso completa, confrontare il risultato con i dati
effettivamente presenti anche in Auth/identità, notifiche/preferenze/campagne,
amicizie/follows/blocchi, supporto, segnalazioni, allegati e log pertinenti.
Queste categorie non sono tutte comprese nella RPC. L'omissione non prova da
sola un difetto: alcune informazioni riguardano terzi, indagini o sicurezza e
richiedono valutazione e oscuramento. Non consegnare indiscriminatamente
segnalazioni ricevute sull'interessato, identità dei segnalanti, credenziali,
token o log amministrativi. Documentare cosa si consegna, cosa si oscura e il
motivo. L'export automatico non sostituisce questa valutazione né le informazioni
su finalità, destinatari, conservazione e garanzie dei trasferimenti.

Consegnare il pacchetto al destinatario verificato tramite un canale privato
con accesso controllato e scadenza decisa dal titolare. Evitare link pubblici.
Definire e registrare il termine di eliminazione delle copie di lavorazione.
Non usare la service-role key per fingere una sessione utente e chiamare la RPC.

Per rettifica, consenso e opposizione: usare preferenze/profilo dell'account
quando possibile, annotare la richiesta, verificare l'effetto server e gli
eventuali destinatari da informare. La revoca posizione deve svuotare coordinate
e data di aggiornamento; notifiche promozionali richiedono la preferenza
dedicata. La prima release mantiene Spotify e affinità disattivati: non
riattivarli per provare le scelte privacy.

## 7. Eliminazione account in-app e richiesta esterna

**In-app:** la funzione `delete-account` verifica utente/sessione, avvia il
blocco dei nuovi upload, rimuove gli oggetti tramite API Storage in lotti e
poi esegue hard delete Auth. Se Storage fallisce, non restituisce successo e
mantiene l'account per un tentativo successivo. La cancellazione Auth attiva le
cascade applicative e la neutralizzazione dei messaggi inviati; i contenuti
degli altri partecipanti restano loro dati.

**Via email, senza app:** dopo identità verificata e decisione del titolare,
l'operatore deve svolgere la stessa sequenza con accessi amministrativi.
Non basta cancellare `public.users` o un record del profilo.

1. Identificare privatamente **un singolo UUID** in Auth e registrare la
   decisione; valutare se esiste una conservazione specifica dovuta per legge o
   un caso di sicurezza. La cascade elimina anche supporto/segnalazioni legati
   all'account: un'eventuale conservazione eccezionale va motivata e limitata
   prima dell'operazione, non decisa automaticamente dal programma.
2. Avviare la procedura chiamando `begin_account_erasure(uuid)` dal contesto
   amministrativo previsto dal backend. È una modifica, da eseguire solo per
   la richiesta verificata: il marker impedisce nuovi upload e non va creato
   per una semplice consultazione.
3. Leggere i lotti restituiti da `list_account_storage_objects(uuid)` e
   rimuovere ogni oggetto tramite Storage/API Storage nel bucket indicato.
   Ripetere fino a zero; il criterio include prefisso UUID e `owner_id`, anche
   per upload orfani e screenshot di assistenza. Verificare ciascun esito.
4. Se un passaggio fallisce, tenere il caso aperto, registrare l'errore depurato
   e riprendere la stessa procedura. Non cancellare Auth per aggirare Storage.
5. Solo quando non restano oggetti, eseguire hard delete dell'utente tramite
   Auth amministrativo. Verificare assenza in Auth/profilo/Storage/sessioni,
   neutralizzazione dei messaggi inviati e mancato accesso con la sessione
   precedente, usando il collaudo controllato come riferimento.
6. Confermare la conclusione al richiedente dal canale verificato, spiegando
   eventuali eccezioni e backup reali. Non affermare eliminazione da backup
   immediata o universale senza riscontro della configurazione del fornitore.

Nessuno script di eliminazione amministrativa da UUID è stato aggiunto o
eseguito in questa verifica. Il percorso esterno deve essere provato su un
account controllato prima di dichiararlo operativo. La funzione mobile non
accetta la service-role key come sostituto del JWT di un utente.

## 8. Conservazione, scheduler e backup

Le finestre **codificate**, da confrontare con scelte e documentazione del
titolare, sono: posizione 30 giorni dall'aggiornamento, chat Live 30 giorni,
log interazioni/clic biglietti 12 mesi, testo/media/metadati messaggi diretti
24 mesi dalla creazione. L'età del singolo messaggio è il criterio SQL:
non viene calcolata l'inattività dell'intera conversazione.

La funzione `apply_data_retention()` esiste, ma nel repository non è presente
un job che la invochi. Il controllo hosted read-only del 18 ottobre 2026 ha
confermato **zero job cron corrispondenti e nessuna esecuzione registrata
associata a tali job**. Questo è un blocco tecnico della conservazione
automatica, non soltanto una conferma mancante del titolare.
`retention-notifications` gestisce campagne di ritorno
in app e **non** applica la conservazione dei dati. Non attivare un job in
produzione prima di aver verificato criteri, interessati coinvolti e pulizia
dei file: la funzione svuota i riferimenti dei media scaduti ma non elimina
gli oggetti Storage. Le durate dei fascicoli supporto/moderazione, email,
notifiche, log tecnici e backup devono essere documentate dal titolare secondo
necessità effettiva, senza inventare nuovi termini in questo runbook.

Query di ricognizione sicura per il SQL Editor; non espone il testo dei job,
che potrebbe contenere segreti:

```sql
begin transaction read only;
set local statement_timeout = '10s';

select exists (
  select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname = 'apply_data_retention'
) as funzione_retention_presente;

select jobid, jobname, schedule, active
from cron.job
where command ilike '%apply_data_retention%'
order by jobid;

select j.jobid, j.jobname, d.status, count(*) as esecuzioni,
       max(d.start_time) as ultimo_avvio, max(d.end_time) as ultima_fine
from cron.job j join cron.job_run_details d on d.jobid = j.jobid
where j.command ilike '%apply_data_retention%'
  and d.start_time >= now() - interval '7 days'
group by j.jobid, j.jobname, d.status;

select
  (select count(*) from public.users
   where location_updated_at < now() - interval '30 days'
     and (last_location is not null or last_latitude is not null
          or last_longitude is not null)) as posizioni_scadute_residue,
  (select count(*) from public.live_messages
   where created_at < now() - interval '30 days') as live_scaduti_residui,
  (select count(*) from public.user_interactions_log
   where created_at < now() - interval '12 months') as interazioni_scadute,
  (select count(*) from public.ticket_clicks
   where clicked_at < now() - interval '12 months') as clic_scaduti,
  (select count(*) from public.messages
   where created_at < now() - interval '24 months'
     and (content is distinct from 'Messaggio scaduto secondo la policy di conservazione'
          or media_path is not null or metadata is not null))
    as messaggi_da_neutralizzare;

rollback;
```

Se `cron` non è disponibile, non creare estensioni durante la consultazione:
registrare l'assenza e verificare eventuale scheduler esterno. Un risultato
zero può dipendere dall'assenza di dati vecchi e non prova un job funzionante;
richiedere anche log esecuzione e prova su ambiente isolato con dati sintetici.

Piano concreto di attivazione, **non eseguito** in questo controllo:

1. Confermare le durate con il titolare e provare la funzione su un database
   isolato con dati sintetici ai due lati di ogni scadenza; verificare anche
   consensi, contenuti dei terzi e marker delle conversazioni.
2. Preparare una pulizia Storage riservata al backend che registri i percorsi
   da eliminare prima di perderne il riferimento SQL; usare API Storage con
   lotti, tentativi idempotenti, esito osservabile e controllo finale. Non
   introdurre cancellazioni globali di oggetti «orfani» senza un criterio
   verificato. Provare separatamente media diretti/Live, avatar e allegati.
3. Verificare backup e ripristino isolato; definire un allarme per fallimento o
   mancata esecuzione e un controllo aggregato dei residui.
4. Solo dopo questi esiti, configurare il worker completo con scheduler
   fidato, documentando timezone e orario effettivi. Per la sola parte SQL,
   un comando futuro proposto è quello sotto; da solo non chiude il blocco
   Storage e **non deve essere eseguito prima dei punti precedenti**.

```sql
-- CONFIGURAZIONE FUTURA: modifica produzione, non eseguita.
-- Prerequisiti: prova isolata, decisione durate e pulizia Storage affidabile.
select cron.schedule(
  'apply-data-retention',
  '0 2 * * *',
  $job$ select public.apply_data_retention(); $job$
);
```

Prima di configurare, controllare che non esista un job equivalente e verificare
il fuso del servizio cron: `02:00` segue il timezone configurato del scheduler,
non implica automaticamente le `02:00 Europe/Rome`. Dopo l'attivazione,
controllare esecuzione reale, errori, residui SQL e oggetti Storage rimossi.

Per backup registrare da Supabase: piano attivo, backup disponibili, durata
effettiva, eventuale PITR, regione, accessi e procedura di ripristino. Il backup
del database non prova il backup dei file Storage. Prima di un ripristino,
valutare come riapplicare cancellazioni/revoche avvenute dopo lo snapshot;
conservare il minimo necessario per farlo. Verificare il ripristino in ambiente
isolato. Non pubblicare date di scadenza dedotte dal piano nominale.

## 9. Incidenti, fornitori e chiusura del controllo

Per incidente: registrare quando il titolare ne viene a conoscenza, categorie
e soggetti coinvolti, misure immediate, log pertinenti e valutazione del rischio.
L'EDPB indica notifica all'autorità entro 72 ore dalla conoscenza quando il
breach può comportare rischio; per rischio elevato può essere dovuta anche
comunicazione agli interessati senza ingiustificato ritardo. Documentare anche
la decisione motivata di non notificare. Il titolare decide con supporto
competente e usa il canale ufficiale dell'autorità; nessuna comunicazione è
stata inviata in questa verifica.

Per Supabase, Firebase/Google, Apple, mappe, hosting e provider eventi, il
titolare deve raccogliere configurazione effettiva, contratti/ruoli privacy,
subfornitori, trasferimenti e retention. Consultare l'inventario
[store-privacy-data.md](store-privacy-data.md) e i questionari senza convertire
automaticamente le proposte in dichiarazioni finali.

Evidenze minime per chiudere i gate operativi: prova casella con risposta,
gestione di un ticket e una segnalazione controllati, blocco/sospensione con
sessioni revocate, export esaminato, revoca consensi, cancellazione in-app e
esterna, riscontri scheduler/Storage/backup e decisioni del titolare sui
fornitori. Usare il verbale di verifica collegato all'inizio. Nessun flag di
release deve diventare `true` sulla sola base di questo documento.

## Fonti ufficiali consultate il 18 ottobre 2026

- [EDPB: gestione dei diritti](https://www.edpb.europa.eu/sme/be-compliant/respect-individuals-rights_en).
- [EDPB: data breach](https://www.edpb.europa.eu/sme/assess-the-risks/data-breaches_en).
- [Apple App Review Guidelines, 1.2](https://developer.apple.com/app-store/review/guidelines/#user-generated-content): filtro, segnalazione, risposta, blocco e contatto pubblico.
- [Google Play: UGC](https://support.google.com/googleplay/android-developer/answer/9876937?hl=en-TT).
- [Google Play: Child Safety Standards](https://support.google.com/googleplay/android-developer/answer/14747720?hl=en).
- [Supabase: sessioni](https://supabase.com/docs/guides/auth/sessions) e [sign out](https://supabase.com/docs/guides/auth/signout).
