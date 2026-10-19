# Configurazione Google Android del 13 ottobre 2026

Il nuovo certificato ufficiale di upload Android è registrato su Firebase e il
client OAuth Android corrispondente è stato creato nel progetto esistente
`vibra-3f307`. La schermata Google Auth Platform mostra **In production**, stato
ricontrollato dopo un ricaricamento della pagina.

## Interventi verificati

- Firebase Android app: `1:495632436565:android:e3cf0cccacd849918173dc`, package
  `com.vibra.app`. Registrate SHA-1 e SHA-256 della nuova chiave e rilette dal
  Management API; nessun certificato esistente rimosso.
- Nuovo client Google: **Vibra Android Release Upload 20261013**, tipo Android,
  package `com.vibra.app`, SHA-1
  `47:3D:96:59:60:41:9B:BE:E4:F5:62:57:E3:8A:7C:BA:9D:80:8A:D5`.
  ID pubblico:
  `495632436565-21mv24qjb4k1ebvohasbsjbmumkeilnl.apps.googleusercontent.com`.
  Creazione confermata e package/impronta riletti dalla scheda salvata.
- Preservati i tre client precedenti: web, iOS e Android della vecchia impronta.
  I client web e iOS remoti coincidono con quelli già configurati nell'app.
- Salvati sito, privacy e termini ufficiali:
  `{{PUBLIC_SITE_URL}}`, `/privacy.html`,
  `/termini.html`. Google ha richiesto il dominio autorizzato
  `newrobin4.chatgpt.site`, che è stato aggiunto conservando il dominio Supabase.
  Il dominio padre `chatgpt.site` non è stato aggiunto e non è stata presentata
  alcuna dichiarazione di proprietà o richiesta di verifica del dominio.
- Passaggio da Testing a **In production** completato e verificato. Nome e
  contatti esistenti di Vibra preservati; nessun logo caricato su Google, nessun
  ambito di accesso modificato, nessuna attivazione di servizi a pagamento.

L'app richiede solamente `email`, `profile` e `openid`. Le liste di ambiti
sensibili e con restrizioni nella console erano vuote. Google documenta inoltre
un'eccezione alle restrizioni degli utenti di test per il solo accesso con questi
ambiti: lo stato Testing precedente, da solo, non provava un errore di login.
[Regole del pubblico OAuth](https://support.google.com/cloud/answer/15549945?hl=en).

## Verifiche ancora necessarie

La configurazione non costituisce una prova di login reale: restano da provare
Google Sign-In e lo scambio del token con Supabase su release firmata e su una
build installata tramite test interno Play. Dopo l'attivazione di Play App
Signing, registrare anche le impronte del certificato di distribuzione Google,
che può differire dalla chiave di upload.
[Firma e certificati Android](https://developer.android.com/studio/publish/app-signing#api-providers).

I metadati verificabili sono in
`release/qa-20261013/android-signing/firebase-certificates.json` (escluso da Git).
Nessun token o password è stato inserito nel report o in tale evidenza; il rinnovo
delle credenziali Firebase è rimasto in memoria.

Riferimenti della configurazione:
[certificati Firebase](https://firebase.google.com/docs/reference/firebase-management/rest/v1beta1/projects.androidApps.sha/create),
[client OAuth](https://support.google.com/cloud/answer/15549257?hl=en),
[console del progetto](https://console.cloud.google.com/auth/audience?project=vibra-3f307).
