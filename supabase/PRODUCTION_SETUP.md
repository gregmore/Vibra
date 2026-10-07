# Configurazione Supabase di produzione

Il progetto collegato a questo repository e' `dxgqovzlvmhcmpvlkxgi` (Vibra,
`eu-west-2`). Le migrazioni sono la fonte di verita': applicarle sempre con
`supabase db push`, mai incollando modifiche manuali allo schema.

## Credenziali

- Nell'app Flutter usare soltanto `SUPABASE_URL`, la publishable/anon key e i
  client ID pubblici OAuth. Il file `.env` e' incluso negli asset: qualsiasi
  valore al suo interno e' recuperabile da chi installa l'app.
- Conservare `SUPABASE_SERVICE_ROLE_KEY`, `SPOTIFY_CLIENT_SECRET` e le chiavi
  Firebase esclusivamente in `supabase secrets`. Non esporli nel client, nei
  log o nelle migrazioni.
- Impostare anche `SPOTIFY_TOKEN_ENCRYPTION_KEY`: una chiave casuale di 32 byte
  codificata base64. I token OAuth vengono salvati solo in
  `spotify_connections` come envelope AES-GCM; la tabella non ha policy per
  i client e viene raggiunta esclusivamente dalle Edge Functions.
- Ruotare subito ogni segreto che sia stato condiviso fuori dal gestore segreti.

## Auth Dashboard

In **Authentication > URL Configuration** impostare i redirect effettivi:

- `com.vibra.app://callback`
- gli URL HTTPS di staging e produzione, se verranno aggiunti

In produzione abilitare la conferma email, CAPTCHA (Turnstile o hCaptcha) e
una password policy forte. Il file `config.toml` definisce il comportamento
locale, non sostituisce le impostazioni del progetto hosted.

## Edge Functions e cron

Le funzioni usano i secret gia' presenti nel progetto. Dopo un cambiamento:

```bash
supabase functions deploy send-notifications
supabase functions deploy retention-notifications
supabase functions deploy event-reminders
supabase functions deploy spotify-token-exchange
supabase functions deploy sync-music-profile
supabase functions deploy spotify-disconnect
supabase functions deploy delete-account
supabase functions deploy ticketmaster-sync --no-verify-jwt
```

`ticketmaster-sync` accetta esclusivamente il bearer `SUPABASE_SERVICE_ROLE_KEY`:
richiamarla da pg_cron/Vault o da un job esterno, mai dal client. Per generare
la chiave cifrante: `openssl rand -base64 32`, poi
`supabase secrets set SPOTIFY_TOKEN_ENCRYPTION_KEY='...'`.

Le email ospitate vanno personalizzate in **Authentication > Email Templates**
con i template `supabase/templates`; `config.toml` serve il flusso locale.
Abilitare Apple quando si distribuisce su iOS insieme a provider social e
configurare Google solo se il relativo login viene esposto nell'app.

Per il job `send-notifications`, creare in **Database > Vault** un secret
denominato `vibra_service_role_key`, con valore pari alla service-role key.
Poi eseguire [`setup_notification_cron.sql`](setup_notification_cron.sql) nel
SQL Editor. La chiave verra' letta da Vault a ogni esecuzione, non salvata in
chiaro nel job.

Il medesimo script programma anche `retention-notifications`: registra le
campagne in `notification_campaigns` e usa la view privata
`notification_campaign_metrics` per open, return entro 72 ore e opt-out. Il
worker applica cap, timezone e quiet hours lato server; non invia un messaggio
di ritorno quando non trova un evento o un artista realmente rilevante.

`seed-compatible-users` crea utenti demo: non va esposto in produzione. Prima
del rilascio eliminarlo dal progetto oppure limitarlo a un ambiente di staging.

Le RPC esposte dall'app sono disponibili solo al ruolo `authenticated`; le
funzioni trigger e le routine interne non sono invocabili tramite l'API.

## Verifica

```bash
supabase migration list --linked
supabase functions list
supabase secrets list
supabase db lint --linked
supabase test db
```

Gli avvisi del lint relativi a funzioni PostGIS di sistema non provengono dallo
schema di Vibra; verificare invece eventuali nuovi errori riferiti a `public`.

### PostGIS legacy (`spatial_ref_sys`)

Se Security Advisor segnala `public.spatial_ref_sys`, non tentare di concedere
accesso al client. È una tabella di metadati posseduta dall'estensione PostGIS,
quindi le normali migrazioni applicative non possono abilitarne RLS. Aprire un
ticket Supabase chiedendo lo spostamento/aggiornamento dell'estensione PostGIS
nello schema `extensions`; nel frattempo la tabella non è esposta dalla Data API
e non contiene dati utente.
