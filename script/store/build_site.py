#!/usr/bin/env python3
"""Build public pages and private legal copies from local owner configuration."""
import argparse
import hashlib
import html
import json
import os
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SITE = ROOT / 'store/site'
parser = argparse.ArgumentParser(description=__doc__)
source = parser.add_mutually_exclusive_group()
source.add_argument('--owner-config', type=Path,
                    help='Private owner JSON (default: store/owner.json or VIBRA_OWNER_CONFIG)')
source.add_argument('--example', action='store_true',
                    help='Build an explicitly marked preview from owner.example.json; never package it')
parser.add_argument('--output-dir', type=Path, default=SITE / 'dist')
parser.add_argument('--documents-dir', type=Path,
                    default=ROOT / 'release/store-documents')
options = parser.parse_args()
config_path = (ROOT / 'store/owner.example.json' if options.example else
               options.owner_config or Path(os.environ.get(
                   'VIBRA_OWNER_CONFIG', str(ROOT / 'store/owner.json'))))
try:
    config_bytes = config_path.read_bytes()
    CONFIG = json.loads(config_bytes)
except FileNotFoundError:
    parser.error('Owner configuration is missing. Copy store/owner.example.json '
                 'to ignored store/owner.json and fill it, pass --owner-config, '
                 'or use --example for a preview.')
except (OSError, ValueError):
    parser.error('Unable to read owner configuration as a JSON object.')
required_fields = ('legal_name', 'legal_address', 'support_email', 'privacy_email',
                   'legal_email', 'public_site_url')
if not isinstance(CONFIG, dict) or any(
        not isinstance(CONFIG.get(key), str) for key in required_fields):
    parser.error('Owner configuration must contain text fields: ' +
                 ', '.join(required_fields))
if not options.example:
    from urllib.parse import urlparse
    invalid = [key for key in required_fields if not CONFIG[key].strip()
               or re.search(r'YOUR_|PLACEHOLDER|\{\{', CONFIG[key], re.I)]
    invalid += [key for key in ('support_email', 'privacy_email', 'legal_email')
                if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', CONFIG[key])
                or re.search(r'(?:^|\.)(?:example\.(?:com|org|net)|invalid|test|example)$',
                             CONFIG[key].split('@')[-1], re.I)]
    public_url = urlparse(CONFIG['public_site_url'])
    if (public_url.scheme != 'https' or not public_url.hostname or
            re.search(r'(?:^|\.)(?:localhost|example\.(?:com|org|net)|invalid|test|example)$',
                      public_url.hostname, re.I)):
        invalid.append('public_site_url')
    if invalid:
        parser.error('Complete private owner fields before building release pages: ' +
                     ', '.join(sorted(set(invalid))) + '. Use --example for a preview.')
OUT = options.output_dir
DOCUMENTS = options.documents_dir
OUT.mkdir(parents=True, exist_ok=True)
DOCUMENTS.mkdir(parents=True, exist_ok=True)
mail = CONFIG['support_email']
name = CONFIG['legal_name']
address = html.escape(CONFIG['legal_address'])
document_date = '13 ottobre 2026'
contact = f'<a href="mailto:{html.escape(mail)}">{html.escape(mail)}</a>'

def request(subject):
    from urllib.parse import quote
    return f'mailto:{mail}?subject={quote(subject)}'

pages = {
'index': ('La tua musica.\nLe tue persone.', 'Vibra è un progetto personale per scoprire concerti, salvare eventi e organizzare serate con gli amici.', '''
<div class="cards">
<a class="card" href="supporto.html"><span>01 / ASSISTENZA</span><h2>Una mano, quando serve.</h2><p>Account, mappa, eventi, messaggi e notifiche: trovi qui le risposte e il contatto diretto.</p><b>Apri il centro assistenza ↗</b></a>
<a class="card" href="privacy.html"><span>02 / DATI PERSONALI</span><h2>I tuoi dati, le tue scelte.</h2><p>Scopri quali informazioni usa Vibra, per quali funzioni e come esercitare i tuoi diritti.</p><b>Leggi l’informativa ↗</b></a>
<a class="card" href="termini.html"><span>03 / COMMUNITY</span><h2>Condividere, con rispetto.</h2><p>Le regole del servizio e le condizioni per partecipare alla community.</p><b>Leggi i termini ↗</b></a>
</div><section class="callout"><h2>Vuoi eliminare il tuo account?</h2><p>Puoi richiederlo anche senza reinstallare l’app.</p><a class="button" href="elimina-account.html">Account e cancellazione ↗</a></section>'''),
'privacy': ('Privacy, senza giri di parole.', f'Informativa sul trattamento dei dati personali di Vibra · versione {document_date}', f'''
<section><h2>1. Titolare e contatti</h2><p>Il titolare del trattamento è {html.escape(name)}, autore del progetto personale Vibra, con indirizzo ufficiale in {address}. Per richieste sui tuoi dati scrivi a {contact} indicando “Privacy Vibra”.</p></section>
<section><h2>2. Quali dati utilizziamo</h2><div class="table-wrap"><table><thead><tr><th>Dati</th><th>Funzione e scelta</th></tr></thead><tbody>
<tr><td>Email, identificativo account, username e profilo</td><td>Accesso, gestione dell’account e profilo. Nome visualizzato, foto e bio sono facoltativi.</td></tr>
<tr><td>Dati Spotify da collegamenti preesistenti</td><td>Il collegamento Spotify e le affinità musicali sono disattivati nella prima versione pubblica. Eventuali artisti, brani, generi e credenziali già associati al tuo account restano soggetti alle tue scelte, alla revoca e alla cancellazione. Le credenziali OAuth sono protette sul server.</td></tr>
<tr><td>Posizione precisa e città</td><td>La posizione del dispositivo è facoltativa: eventi vicini e verifica della prossimità nella modalità Live. Puoi negare il permesso e usare le altre funzioni.</td></tr>
<tr><td>Eventi salvati, relazioni sociali e interazioni</td><td>Raccolta personale, amicizie, messaggi e funzionamento delle funzioni richieste.</td></tr>
<tr><td>Messaggi, foto e contenuti delle chat</td><td>Conversazioni e chat degli eventi; gestione delle segnalazioni e protezione della community.</td></tr>
<tr><td>Token push e preferenze</td><td>Notifiche facoltative. Il token viene rimosso al logout o alla disattivazione delle push nell’app.</td></tr>
<tr><td>Clic sui biglietti e interazioni con notifiche</td><td>Funzionamento, personalizzazione e misurazione interna. Le campagne promozionali richiedono la scelta dedicata.</td></tr>
<tr><td>Segnalazioni, allegati e diagnostica</td><td>Assistenza richiesta dall’utente: versione app/sistema, endpoint fallito e un buffer di log ripulito da credenziali e identificativi tecnici.</td></tr>
</tbody></table></div></section>
<section><h2>3. Finalità e basi del trattamento</h2><p>Gestione dell’account, eventi salvati e messaggi sono necessari a erogare le funzioni richieste (esecuzione del servizio). Posizione e comunicazioni promozionali dipendono dalle tue scelte e dal consenso quando richiesto. Per eventuali collegamenti Spotify preesistenti continuano ad applicarsi le scelte e il consenso precedentemente espresso; la prima versione pubblica non offre nuovi collegamenti o affinità musicali. Sicurezza, prevenzione degli abusi e gestione delle segnalazioni rispondono all’interesse legittimo a proteggere gli utenti, nei limiti dei loro diritti; gli obblighi di legge si applicano quando necessari.</p><p>La mancata attivazione di una funzione facoltativa limita quella funzione. Puoi modificare le scelte da Impostazioni → Privacy e dati personali e revocare i permessi del dispositivo. Per un eventuale collegamento Spotify preesistente puoi usare il comando di scollegamento, dove disponibile, oppure contattare l’assistenza per revoca e rimozione. Revocare il consenso non pregiudica la liceità del trattamento precedente.</p></section>
<section><h2>4. Fornitori e visibilità dei contenuti</h2><p>Vibra usa Supabase per autenticazione, database, archiviazione e funzioni server; Google/Firebase per accesso e notifiche; Apple per l’accesso Apple; Google per la traduzione delle descrizioni pubbliche degli eventi; Spotify per la gestione e revoca degli eventuali collegamenti preesistenti; Ticketmaster e Bandsintown e, se attivato, Songkick per i dati degli eventi. Le mappe sono fornite da servizi cartografici indicati nell’app: le richieste possono includere indirizzo IP e area visualizzata.</p><p>Il profilo può essere visibile agli altri utenti secondo le funzioni e impostazioni dell’app. Le affinità musicali sono disattivate nella prima versione pubblica. I messaggi diretti sono destinati ai partecipanti; le chat Live ai partecipanti alla chat dell’evento. I fornitori di biglietti ricevono la visita quando apri un link esterno e applicano le proprie informative. Vibra non vende i dati personali e non include SDK pubblicitari per tracciare gli utenti tra app.</p><p>Il database applicativo hosted è nella regione Supabase eu-west-2 (Regno Unito). Alcuni fornitori operano anche fuori dallo Spazio economico europeo. I trasferimenti sono soggetti alle garanzie applicabili, come decisioni di adeguatezza e clausole contrattuali standard, ove previste dai contratti dei fornitori. Puoi chiedere dettagli e informazioni sulle garanzie a {contact}.</p></section>
<section><h2>5. Conservazione e cancellazione</h2><p>I dati dell’account sono conservati finché mantieni l’account o fino a una richiesta di cancellazione, salvo obblighi di legge o necessità documentate di sicurezza. Le eventuali credenziali e il profilo musicale di un collegamento Spotify preesistente vengono rimossi quando scolleghi il servizio o ne richiedi la rimozione. Le preferenze restano fino alla modifica o cancellazione dell’account. Segnalazioni e informazioni necessarie a gestire controversie o abusi possono essere conservate per il tempo necessario alla gestione del caso e ai relativi obblighi.</p><p>Alla cancellazione vengono rimossi account, profilo, salvataggi, notifiche e relativi record applicativi, inclusi eventuali collegamenti Spotify, profili musicali e affinità già presenti. I messaggi inviati vengono privati di identità, testo, media e metadati e sostituiti da un indicatore neutro; i contenuti degli altri partecipanti restano loro dati. Le copie di backup possono persistere fino al ciclo di scadenza configurato dal fornitore: non sono usate per il funzionamento ordinario e il loro periodo effettivo è comunicabile su richiesta.</p><p>Le regole tecniche di pulizia prevedono finestre specifiche per posizione, chat Live e log; la loro operatività e le impostazioni di backup sono oggetto dei controlli prima del rilascio. Non considerare queste finestre una garanzia di cancellazione automatica già verificata.</p></section>
<section><h2>6. Diritti e richieste</h2><p>Puoi chiedere accesso, rettifica, cancellazione, limitazione, portabilità e opposizione nei casi previsti. Nell’app sono disponibili modifica profilo, esportazione dei dati, revoca delle scelte facoltative ed eliminazione account. Puoi anche scrivere a {contact}, senza fornire password o token: potremmo chiedere una verifica proporzionata dell’identità.</p><p>Le richieste relative ai diritti sono gestite entro i termini di legge, normalmente un mese; eventuali proroghe consentite vengono comunicate. Puoi proporre reclamo all’autorità di controllo competente, incluso il <a href="https://www.garanteprivacy.it/">Garante per la protezione dei dati personali</a> per gli utenti italiani.</p><a class="button" href="elimina-account.html">Richiedi eliminazione account ↗</a></section>
<section><h2>7. Età, sicurezza e modifiche</h2><p>Vibra è destinata a persone di almeno 18 anni. Se ritieni che un account appartenga a un minore, segnalalo a {contact}. Il servizio usa HTTPS e controlli di accesso; le chat non sono dichiarate cifrate da punto a punto. Le indicazioni sugli eventi sono suggerimenti e non decisioni automatizzate con effetti giuridici o analogamente significativi.</p><p>Eventuali modifiche sostanziali a questa informativa saranno comunicate attraverso i canali del servizio. Questo sito informativo non usa cookie pubblicitari o analytics applicativi; il servizio di hosting può trattare dati tecnici necessari a erogare le pagine e proteggerle.</p></section>'''),
 'termini': ('Le regole per stare bene insieme.', f'Termini di utilizzo di Vibra · versione {document_date}', f'''
<section><h2>1. Servizio e gestore</h2><p>Vibra è il progetto personale di {html.escape(name)}, con indirizzo ufficiale in {address}. Aiuta a scoprire eventi sulla mappa, salvare concerti, gestire amicizie e comunicare con altri utenti, anche nelle chat Live degli eventi. Contatto: {contact}. Le funzioni dipendono anche da servizi esterni e dalle disponibilità dei loro dati.</p></section>
<section><h2>2. Età e account</h2><p>Per utilizzare Vibra devi avere almeno 18 anni. Fornisci dati corretti e proteggi le credenziali. Non impersonare altre persone. Se sospetti un accesso non autorizzato, contatta l’assistenza.</p></section>
<section><h2>3. Contenuti e community</h2><p>Conservi i diritti sui contenuti che inserisci; autorizzi il trattamento e la visualizzazione necessari a fornire il servizio ai destinatari scelti. Devi avere il diritto di condividere i materiali caricati.</p><p>Sono vietati molestie, minacce, discriminazione, contenuti illegali, sessualmente espliciti, spam, frodi, violazioni della privacy e tentativi di accesso non autorizzato. Sono tassativamente vietati abusi e sfruttamento sessuale di minori. Leggi gli <a href="sicurezza.html">standard di sicurezza della community</a>.</p><p>Puoi segnalare contenuti e utenti e usare il blocco dove disponibile. Il gestore può rimuovere contenuti o limitare/sospendere account per violazioni, sicurezza o obblighi di legge. Per contestare un intervento scrivi a {contact} con gli elementi utili.</p></section>
<section><h2>4. Funzioni disponibili, eventi e biglietti</h2><p>Il collegamento Spotify e le affinità musicali sono temporaneamente disattivati nella prima versione pubblica. Per eventuali collegamenti precedenti resta possibile revocare il collegamento e chiedere la rimozione dei dati nelle impostazioni, dove disponibile, o tramite assistenza. Disponibilità e limiti delle integrazioni dipendono dai fornitori. Eventi, date, luoghi e prezzi possono cambiare: verifica sempre sul sito dell’organizzatore. Vibra apre i siti esterni per i biglietti e non gestisce il pagamento o il contratto di acquisto del biglietto.</p></section>
<section><h2>5. Privacy e sicurezza personale</h2><p>Il trattamento dei dati è descritto nell’<a href="privacy.html">informativa privacy</a>. Rispetta le scelte e la sicurezza delle altre persone. Non condividere dati sensibili, password o informazioni di terzi senza autorizzazione. Gli incontri e gli spostamenti sono decisioni dell’utente; in caso di emergenza rivolgiti ai servizi competenti.</p></section>
<section><h2>6. Disponibilità e responsabilità</h2><p>Il servizio può subire interruzioni o modifiche. Le informazioni degli eventi non garantiscono risultati o disponibilità di biglietti. Restano salvi i diritti inderogabili previsti dalla legge; questi termini non escludono responsabilità che non possano essere escluse secondo la normativa applicabile.</p></section>
<section><h2>7. Cancellazione e aggiornamenti</h2><p>Puoi smettere di usare Vibra ed eliminare l’account dall’app o attraverso la <a href="elimina-account.html">pagina dedicata</a>. Per modifiche sostanziali dei termini verranno fornite informazioni aggiornate tramite i canali del servizio. L’utilizzo della versione del servizio cui si applicano questi termini comporta l’accettazione delle relative condizioni.</p></section>'''),
 'supporto': ('Ci siamo. Scrivici.', 'Assistenza diretta per il progetto personale Vibra.', f'''
<section class="callout"><span class="eyebrow">CONTATTO UFFICIALE</span><h2>{html.escape(mail)}</h2><p>Descrivi il problema e indica versione dell’app e dispositivo. Non inviare password, codici di accesso o token. L’obiettivo è una prima risposta entro 48 ore lavorative.</p><a class="button" href="{request('Assistenza Vibra')}">Scrivi all’assistenza ↗</a></section>
<section><h2>Risposte veloci</h2>
<details><summary>Non riesco ad accedere</summary><p>Usa lo stesso metodo della registrazione: email, Google o Apple. Per email controlla anche la cartella spam. Se il problema continua, scrivi dal recapito associato all’account.</p></details>
<details><summary>Perché non vedo il collegamento Spotify e le affinità musicali?</summary><p>Sono temporaneamente disattivati nella prima versione pubblica. Puoi usare ricerca eventi, mappa, salvataggi, amicizie, messaggi e chat Live. Se avevi collegato Spotify in precedenza, puoi revocarlo nelle impostazioni, dove disponibile, o scrivere all’assistenza per la rimozione dei dati musicali.</p></details>
<details><summary>Non vedo concerti nella mia zona</summary><p>Controlla la zona e i filtri in Esplora. Posizione e disponibilità degli eventi dipendono dai permessi e dai fornitori. Dati e biglietti vanno sempre confermati sul sito dell’organizzatore.</p></details>
<details><summary>Non ricevo notifiche</summary><p>Verifica il permesso nelle impostazioni del telefono e l’interruttore notifiche di Vibra. Se il permesso era disabilitato, riapri l’app dopo averlo riattivato.</p></details>
<details><summary>Come segnalo una persona o un contenuto?</summary><p>Usa Segnala nell’app dove disponibile o scrivi all’assistenza indicando il contesto. Per contenuti riguardanti minori usa le istruzioni della <a href="sicurezza.html">pagina sicurezza</a>. Non inoltrare materiale illegale.</p></details>
<details><summary>Come gestisco o cancello i miei dati?</summary><p>Apri Impostazioni → Privacy e dati personali per le scelte e l’esportazione. Per eliminare l’account usa l’app oppure la <a href="elimina-account.html">richiesta esterna</a>.</p></details></section>
<section><h2>Inviare una segnalazione dall’app</h2><p>Dal centro assistenza puoi inviare una descrizione e uno screenshot facoltativo. La segnalazione include diagnostica essenziale e log ripuliti. Se non hai più l’app, puoi sempre contattarci via email.</p></section>'''),
 'elimina-account': ('Puoi lasciare Vibra, anche da qui.', 'Richiedi l’eliminazione del tuo account e dei dati associati senza reinstallare l’app.', f'''
<section class="callout"><h2>Richiesta via email</h2><p>Scrivi a {contact} dal recapito collegato al tuo account, con oggetto “Eliminazione account Vibra”. Indica il tuo username, se lo ricordi. Non inviare password, documenti o token.</p><a class="button" href="{request('Eliminazione account Vibra')}">Richiedi eliminazione ↗</a><p class="small">Se non hai un’app email configurata, copia l’indirizzo e invia la richiesta dal tuo servizio di posta.</p></section>
<section><h2>Cosa succede dopo</h2><p>Verifichiamo che la richiesta provenga dal titolare dell’account; se necessario ti chiediamo una verifica proporzionata. Le richieste vengono gestite entro i termini di legge e riceverai una conferma. Puoi scriverci anche se non hai più accesso al vecchio recapito: non cancelleremo dati di un’altra persona senza verificarne la legittimità.</p></section>
<section><h2>Quali dati vengono eliminati</h2><p>Account, profilo, salvataggi, notifiche e relativi record applicativi, inclusi eventuali credenziali Spotify, profili musicali e affinità dei collegamenti precedenti. I messaggi inviati vengono privati del contenuto e dell’identità del mittente, mantenendo un indicatore neutro nella conversazione degli altri partecipanti. I loro messaggi restano loro dati.</p><p>Gli eventuali dati da conservare per obblighi di legge o casi di sicurezza e le copie di backup sono descritti nell’<a href="privacy.html">informativa privacy</a>. La revoca di un eventuale collegamento Spotify preesistente elimina la connessione musicale, ma non l’intero account.</p></section>
<section><h2>Alternativa nell’app</h2><p>Se usi ancora Vibra, puoi avviare l’eliminazione dalle impostazioni dell’account. La richiesta via email resta disponibile anche senza l’app.</p></section>'''),
 'sicurezza': ('Una community sicura, prima di tutto.', 'Standard contro abusi e sfruttamento sessuale dei minori e regole per la sicurezza degli utenti.', f'''
<section><h2>Divieti e tutela dei minori</h2><p>Vibra è riservata ai maggiorenni. Vietiamo qualsiasi contenuto o comportamento che rappresenti, promuova o faciliti l’abuso o lo sfruttamento sessuale dei minori (CSAE), inclusi materiale di abuso sessuale, adescamento, sessualizzazione di minori e richieste di contatto o materiale a fini sessuali.</p></section>
<section><h2>Come segnalare</h2><p>Usa gli strumenti di segnalazione dell’app o contatta {contact} con oggetto “Sicurezza minori Vibra”. Indica il contesto e gli identificativi disponibili. Non scaricare, copiare o inoltrare materiale illegale; non allegarlo alla segnalazione. Per un pericolo immediato contatta le autorità o i servizi di emergenza competenti.</p><a class="button" href="{request('Sicurezza minori Vibra')}">Contatta il referente sicurezza ↗</a></section>
<section><h2>Gestione delle segnalazioni</h2><p>Il referente del progetto è {html.escape(name)}, contattabile all’indirizzo sopra. Le segnalazioni vengono valutate per rimuovere contenuti vietati, limitare account e proteggere gli utenti. I casi rilevanti sono gestiti secondo gli obblighi di legge, inclusa la collaborazione con le autorità competenti. Non è consentito usare il servizio per molestie, minacce o condivisione non autorizzata di dati personali.</p></section>'''),
}
# Availability is explicit on every public page and in generated Markdown copies.
availability_note = '<p class="small">Il collegamento Spotify e le affinità musicali sono temporaneamente disattivati nella prima versione pubblica. Sono disponibili eventi, mappa, salvataggi, amicizie, messaggi e chat Live.</p>'
pages = {slug: (title, intro, availability_note + body)
         for slug, (title, intro, body) in pages.items()}
css = '''@font-face{font-family:Inter;src:url(assets/Inter-Regular.ttf)}@font-face{font-family:Syne;src:url(assets/Syne-Bold.ttf);font-weight:700}*{box-sizing:border-box}body{margin:0;background:#faf9fc;color:#20182d;font-family:Inter,system-ui,sans-serif;line-height:1.65}a{color:#6230c4;text-underline-offset:4px}a:focus-visible,summary:focus-visible{outline:3px solid #7c3aed;outline-offset:5px}header{max-width:1120px;margin:auto;padding:28px 24px;display:flex;align-items:center;justify-content:space-between;gap:24px;border-bottom:1px solid #ddd6e8}.logo{font-family:Syne,sans-serif;font-size:32px;text-decoration:none;color:#20182d;letter-spacing:-1px}nav{display:flex;gap:22px;flex-wrap:wrap}nav a{font-size:14px;text-decoration:none}main{max-width:1120px;padding:64px 24px 80px;margin:auto}.eyebrow,.card span{font-size:11px;font-weight:bold;letter-spacing:1.6px;color:#6230c4}h1{font-family:Syne,sans-serif;font-size:clamp(38px,6vw,72px);line-height:1.05;letter-spacing:-2.8px;white-space:pre-line;max-width:850px;margin:22px 0}h2{font-family:Syne,sans-serif;font-size:26px;line-height:1.25;letter-spacing:-.5px}.intro{font-size:19px;color:#665b75;max-width:720px;margin-bottom:52px}section{max-width:860px;margin:42px 0}section p{max-width:800px}.cards{display:grid;grid-template-columns:repeat(3,1fr);gap:20px}.card{border:1px solid #ddd6e8;border-radius:20px;padding:28px;text-decoration:none;color:inherit;background:white;display:block}.card:hover{border-color:#7c3aed}.card b{color:#6230c4;font-size:14px}.callout{padding:32px;border-radius:20px;background:#ece6f7}.callout h2{overflow-wrap:anywhere}.button{display:inline-block;padding:13px 20px;border-radius:28px;background:#7c3aed;color:#fff;text-decoration:none;font-size:14px}.small{font-size:13px;color:#665b75}.table-wrap{overflow-x:auto}table{border-collapse:collapse;font-size:14px;min-width:500px;width:100%}th,td{text-align:left;vertical-align:top;border-bottom:1px solid #ddd6e8;padding:14px 12px}th{background:#ece6f7}details{border-bottom:1px solid #ddd6e8;padding:18px 0}summary{cursor:pointer;font-weight:bold}footer{border-top:1px solid #ddd6e8;max-width:1120px;margin:auto;padding:32px 24px;display:flex;gap:20px;justify-content:space-between;color:#665b75;font-size:13px}footer div{display:flex;gap:18px;flex-wrap:wrap}.skip{position:absolute;left:12px;top:-100px}.skip:focus{top:12px;z-index:10;background:white;padding:12px}@media(max-width:740px){header{align-items:flex-start;flex-direction:column;gap:12px}nav{gap:14px}.cards{grid-template-columns:1fr}main{padding-top:32px}h1{letter-spacing:-1.5px}footer{flex-direction:column}.callout{padding:22px}}'''
(OUT/'style.css').write_text(css)
(OUT/'assets').mkdir(exist_ok=True)
for font in ['Inter-Regular.ttf','Syne-Bold.ttf','inter-OFL.txt','syne-OFL.txt']:
    shutil.copy2(ROOT/'assets/fonts'/font,OUT/'assets'/font)
for slug,(title,intro,body) in pages.items():
    navigation = '<a href="supporto.html">Assistenza</a><a href="privacy.html">Privacy</a><a href="termini.html">Termini</a>'
    document = f'''<!doctype html><html lang="it"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{html.escape(title.replace(chr(10),' '))} · Vibra</title><meta name="description" content="{html.escape(intro)}"><link rel="stylesheet" href="style.css"></head><body><a class="skip" href="#contenuto">Vai al contenuto</a><header><a class="logo" href="index.html" aria-label="Vibra, pagina iniziale">vibra<span style="color:#7c3aed">.</span></a><nav aria-label="Navigazione principale">{navigation}</nav></header><main id="contenuto"><span class="eyebrow">VIBRA / {html.escape(slug.upper().replace('-',' '))}</span><h1>{html.escape(title)}</h1><p class="intro">{html.escape(intro)}</p>{body}</main><footer><span>© 2026 Vibra · {html.escape(name)}</span><div><a href="elimina-account.html">Elimina account</a><a href="sicurezza.html">Sicurezza</a>{contact}</div></footer></body></html>'''
    (OUT/f'{slug}.html').write_text(document)
(OUT/'robots.txt').write_text('User-agent: *\nAllow: /\n')
print(f'Built {len(pages)} pages' + (' (EXAMPLE PREVIEW; not release materials).' if options.example else '.'))

# Personalized documents stay in ignored release output, never repository templates.
from html.parser import HTMLParser
class MarkdownCopy(HTMLParser):
    def __init__(self):
        super().__init__(); self.parts = []
    def handle_starttag(self, tag, attrs):
        if tag == 'h2': self.parts.append('\n\n## ')
        elif tag in ('p','details'): self.parts.append('\n\n')
        elif tag == 'tr': self.parts.append('\n|')
        elif tag in ('td','th'): self.parts.append(' ')
        elif tag == 'a':
            href = dict(attrs).get('href','')
            from urllib.parse import urljoin
            self.parts.append('['); self.href = urljoin(CONFIG.get('public_site_url','')+'/',href)
    def handle_endtag(self, tag):
        if tag == 'a': self.parts.append('](' + self.href + ')')
        elif tag in ('td','th'): self.parts.append(' |')
        elif tag == 'thead': self.parts.append('\n|---|---|')
        elif tag in ('p','h2','section','table'): self.parts.append('\n')
    def handle_data(self, data):
        if data.strip(): self.parts.append(data)
generated_documents = []
for slug, target in [('privacy','PRIVACY_POLICY.md'),('termini','TERMS_OF_SERVICE.md'),('supporto','SUPPORT.md')]:
    parser = MarkdownCopy(); parser.feed(pages[slug][2])
    title = pages[slug][0].replace('\n',' ')
    url = CONFIG.get('public_site_url','') + '/' + slug + '.html'
    content = re.sub(r'\n{3,}', '\n\n', ''.join(parser.parts)).strip()
    (DOCUMENTS/target).write_text('# '+title+' — Vibra\n\nVersione '+document_date+'. Titolare: '+name+'. Contatto: '+mail+'\n\n[Testo pubblico completo]('+url+'). Copia generata da `script/store/build_site.py`.\n\n'+content+'\n')
    generated_documents.append(target)

# Listing prose remains versioned; owner/contact tokens are resolved only locally.
metadata = (ROOT / 'STORE_METADATA.md').read_text()
metadata = re.sub(r'^> Modello pubblico:[^\n]*\n\n', '', metadata)
tokens = {'LEGAL_NAME': 'legal_name', 'LEGAL_ADDRESS': 'legal_address',
          'SUPPORT_EMAIL': 'support_email', 'PRIVACY_EMAIL': 'privacy_email',
          'LEGAL_EMAIL': 'legal_email', 'PUBLIC_SITE_URL': 'public_site_url'}
for token, key in tokens.items():
    metadata = metadata.replace('{{' + token + '}}', CONFIG[key])
(DOCUMENTS / 'STORE_METADATA.md').write_text(metadata)
generated_documents.append('STORE_METADATA.md')
generation = {'example_mode': options.example,
              'owner_config_sha256': hashlib.sha256(config_bytes).hexdigest(),
              'documents': {name: hashlib.sha256((DOCUMENTS / name).read_bytes()).hexdigest()
                            for name in generated_documents}}
(DOCUMENTS / 'generation.json').write_text(json.dumps(generation, indent=2) + '\n')
print('Personalized document copies and their generation manifest were written to the documents directory.')
