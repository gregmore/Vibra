# App Store Connect — App Privacy

Risposte proposte, 10 ottobre 2026. Fonte tecnica: manifest
`ios/Runner/PrivacyInfo.xcprivacy`, inventario `docs/store-privacy-data.md`,
funzioni Supabase e codice Flutter. Non inviate nella console.

**Raccogli dati? Sì.** Tutte le categorie sotto sono collegate all'account.
**Tracking? No secondo il codice attuale:** nessun SDK ads, IDFA, broker dati
o collegamento a dati terzi per pubblicità tra app. Confermare i trattamenti
dei partner prima di attestarlo. Una scelta opzionale non elimina la necessità
di dichiarare la raccolta. Il manifest non compila automaticamente la console.
[Definizioni Apple](https://developer.apple.com/app-store/app-privacy-details/).

Nella colonna Finalità: F = App Functionality; P = Product Personalization;
A = Analytics; M = Developer's Advertising or Marketing.

| Categoria da selezionare | Dato effettivo | Finalità | Linked | Tracking |
|---|---|---|---|---|
| Contact Info → Name | Nome visualizzato | F | Sì | No |
| Contact Info → Email Address | Email account/assistenza | F | Sì | No |
| Identifiers → User ID | Account, username, ID Spotify | F, M | Sì | No |
| Identifiers → Device ID | Token push/identificatori Firebase | F, M | Sì | No |
| Location → Precise Location | Coordinate autorizzate, prossimità Live | F, P, M | Sì | No |
| Location → Coarse Location | Città/area | F, P, M | Sì | No |
| Contacts | Grafo amici/follower | F, P | Sì | No |
| User Content → Photos or Videos | Foto profilo/chat/supporto | F | Sì | No |
| User Content → Emails or Text Messages | Chat dirette/Live | F | Sì | No |
| User Content → Other User Content | Bio e contenuti liberi | F | Sì | No |
| User Content → Customer Support | Segnalazioni/supporto | F | Sì | No |
| Usage Data → Product Interaction | Ascolti Spotify, salvataggi, clic e campagne | F, P, A, M | Sì | No |
| Diagnostics → Other Diagnostic Data | Versioni, endpoint/log di supporto | F | Sì | No |
| Other Data → Other Data Types | Preferenze e profilo musicale derivato | F, P, M | Sì | No |

Le finalità seguono il manifest attuale, comprese le campagne proprie
facoltative. Non selezionare pubblicità di terzi solo perché M è presente.
Contacts riguarda le relazioni sociali salvate, senza accesso alla rubrica del
telefono. Il nome della categoria Photos or Videos non implica upload video.

Nessuna raccolta intenzionale nel codice di dati sanitari, biometria, pagamenti,
acquisti di biglietti, audio, rubrica OS, cronologia browser o app installate.
I metadati degli ascolti Spotify sono dichiarati come Product Interaction;
non vengono scaricati file musicali.

La ricerca locale non viene registrata come cronologia autonoma. Verificare
che log di produzione/SDK non conservino ricerche o nuove categorie prima
dell'invio. Rivedere anche raccolta IP e retention dei fornitori cartografici,
traduzione, OAuth e hosting: questa tabella non certifica i loro accordi.

Privacy URL: https://vibra-assistenza.newrobin4.chatgpt.site/privacy.html

User privacy choices URL, se richiesto:
https://vibra-assistenza.newrobin4.chatgpt.site/elimina-account.html
