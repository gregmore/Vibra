// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Vibra';

  @override
  String get appSlogan => 'Non ascoltare la musica. Vivila.';

  @override
  String get welcomeTitle => 'Benvenuto in Vibra';

  @override
  String get onboardingConnectTitle => 'Connetti i tuoi gusti';

  @override
  String get onboardingConnectBody =>
      'Collega Spotify, analizza artisti, brani e generi preferiti e trasforma l’ascolto in raccomandazioni più intelligenti.';

  @override
  String get onboardingDiscoverTitle => 'Scopri i live giusti';

  @override
  String get onboardingDiscoverBody =>
      'Vibra unisce posizione, eventi e compatibilità musicale per suggerirti concerti davvero rilevanti.';

  @override
  String get onboardingCommunityTitle => 'Vivi la community';

  @override
  String get onboardingCommunityBody =>
      'Trova persone con il tuo stesso sound, entra in Live Mode durante i concerti e partecipa alla conversazione in tempo reale.';

  @override
  String get onboardingContinue => 'Continua';

  @override
  String get onboardingGoToLogin => 'Vai al login';

  @override
  String get loginTitle => 'Accedi a Vibra';

  @override
  String get loginSubtitle =>
      'Accedi con il tuo account o connettiti usando uno dei provider supportati per sbloccare le raccomandazioni reali.';

  @override
  String get loginConsent =>
      'Autenticandoti accetti consenso dati, gestione sessioni JWT e preferenze privacy GDPR.';

  @override
  String get loginWithSpotify => 'Continua con Spotify';

  @override
  String get loginWithGoogle => 'Continua con Google';

  @override
  String get loginWithApple => 'Continua con Apple';

  @override
  String get loginWithEmail => 'Email';

  @override
  String get authFailed => 'Autenticazione fallita';

  @override
  String get authErrorOccurred => 'Si è verificato un errore';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsHeaderNotificationsPrivacy => 'Notifiche e privacy';

  @override
  String get settingsSubtitleNotificationsPrivacy =>
      'Preferenze, account e gestione dati';

  @override
  String get settingsOptionCompatibleEvents => 'Notifiche eventi compatibili';

  @override
  String get settingsOptionHighMatchAlerts => 'Alert utenti con match alto';

  @override
  String get settingsOptionLiveChat => 'Chat Live durante i concerti';

  @override
  String get settingsOptionDiscoverVisible => 'Profilo visibile in Discover';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsNotificationsSub =>
      'Controlla permessi dispositivo e stato consegna push';

  @override
  String get settingsNotificationsSnackbar =>
      'Le notifiche dipendono dai permessi del dispositivo, dalla configurazione Firebase e da un account autenticato.';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySub =>
      'Uso dei dati, consensi e diritti dell’utente';

  @override
  String get settingsTermsOfService => 'Termini di servizio';

  @override
  String get settingsTermsOfServiceSub =>
      'Regole d’uso, responsabilità e condizioni del servizio';

  @override
  String get settingsSupport => 'Supporto';

  @override
  String get settingsSupportSub => 'Aiuto, contatti e tipologie di assistenza';

  @override
  String get settingsAbout => 'Informazioni su Vibra';

  @override
  String get settingsAboutSub =>
      'Versione app, identificativi e panoramica prodotto';

  @override
  String get settingsLogout => 'Esci';

  @override
  String get settingsLogoutConfirmTitle => 'Esci';

  @override
  String get settingsLogoutConfirmBody => 'Sei sicuro di voler uscire?';

  @override
  String get settingsLogoutAll => 'Esci da tutti i dispositivi';

  @override
  String get settingsLogoutAllConfirmTitle => 'Esci da tutti i dispositivi';

  @override
  String get settingsLogoutAllConfirmBody =>
      'Sei sicuro di voler uscire da tutti i dispositivi? Verrai disconnesso ovunque.';

  @override
  String get settingsCancel => 'Annulla';

  @override
  String get settingsDeleteAccount => 'Cancella account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Cancella Account';

  @override
  String get settingsDeleteAccountConfirmBody =>
      'Sei sicuro di voler cancellare definitivamente il tuo account? Questa azione è irreversibile.';

  @override
  String get settingsDelete => 'Elimina';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSub =>
      'Seleziona la lingua preferita per l\'applicazione';

  @override
  String get settingsLanguageSystem => 'Predefinita di sistema';

  @override
  String homeGreeting(String username) {
    return 'Ciao $username, stasera si ascolta forte.';
  }

  @override
  String get homeSearchHint => 'Artisti, venue, città';

  @override
  String get homeForYouTitle => 'Per Te';

  @override
  String get homeForYouSubtitle =>
      'Eventi con score compatibilità superiore a 70';

  @override
  String get homeNearYouTitle => 'Vicino a Te';

  @override
  String get homeNearYouSubtitle => 'Selezionati con raggio GPS 50 km';

  @override
  String get homeNearYouAction => 'Apri mappa';

  @override
  String get homeTrendingTitle => 'Trend';

  @override
  String get homeTrendingSubtitle => 'Gli eventi più seguiti della settimana';

  @override
  String get homeTrendingAction => 'Vedi tutto';

  @override
  String get settingsSpotifyAccount => 'Account Spotify';

  @override
  String get settingsSpotifyDisconnected =>
      'Scollegato — Collega per raccomandazioni';

  @override
  String get settingsSpotifyDisconnect => 'Scollega';

  @override
  String get settingsSpotifyDisconnectConfirmTitle => 'Scollega Spotify';

  @override
  String get settingsSpotifyDisconnectConfirmBody =>
      'Sei sicuro di voler scollegare il tuo account Spotify? Le raccomandazioni dei concerti non saranno più personalizzate.';

  @override
  String get settingsSpotifyDisconnectedSuccess =>
      'Spotify scollegato con successo';

  @override
  String get settingsGenerateCompatibleUsers => 'Genera Utenti Compatibili';

  @override
  String get settingsGenerateCompatibleUsersSub =>
      'Crea bot con gusti musicali simili';

  @override
  String get settingsGenerateCompatibleUsersLoading =>
      'Generazione in corso... Attendi.';

  @override
  String get settingsGenerateCompatibleUsersSuccess => 'Generati con successo!';

  @override
  String settingsError(String error) {
    return 'Errore: $error';
  }

  @override
  String settingsLogoutError(String error) {
    return 'Errore durante il logout: $error';
  }

  @override
  String settingsSpotifyConnected(String username) {
    return 'Collegato come @$username';
  }

  @override
  String get settingsDeleteAccountError =>
      'Impossibile eliminare l\'account. Assicurati che l\'RPC sia stato caricato nel database.';

  @override
  String get eventDetailChat => 'Chat';

  @override
  String get eventDetailTicketsUnavailable =>
      'Link per i biglietti non disponibile.';

  @override
  String get eventDetailTicketsError =>
      'Impossibile aprire il link del biglietto.';

  @override
  String get eventDetailBuyTickets => 'Acquista Biglietti';

  @override
  String get eventDetailAttendanceConfirmed => 'Presenza confermata!';

  @override
  String get eventDetailAttend => 'Partecipo';

  @override
  String get eventDetailAttendanceMaybe => 'Presenza impostata su Forse';

  @override
  String get eventDetailMaybe => 'Forse';

  @override
  String get eventDetailAttendanceNotGoing =>
      'Hai indicato che non parteciperai';

  @override
  String get eventDetailNotGoing => 'Non vado';

  @override
  String get eventDetailCopied => 'Dettagli evento copiati!';

  @override
  String get exploreSearchEvents => 'Cerca eventi';

  @override
  String get exploreSearchInArea => 'Cerca in quest\'area';

  @override
  String get exploreSearchingEvents => 'Cerco eventi...';

  @override
  String exploreRadius(String radius) {
    return '$radius km';
  }

  @override
  String get friendsTitle => 'Amici';

  @override
  String get chatSendFailed => 'Invio non riuscito';

  @override
  String get socialTitle => 'Social';

  @override
  String socialRequestFrom(String userId) {
    return 'Richiesta da $userId';
  }

  @override
  String get socialOpen => 'Apri';

  @override
  String get userProfileTitle => 'Profilo utente';

  @override
  String userProfileCompatibility(String percentage) {
    return '$percentage% compatibilità';
  }

  @override
  String get userProfileTopArtists => 'Top artisti';

  @override
  String get userProfileFriendRequestSent => 'Richiesta d\'amicizia inviata!';

  @override
  String get userProfileSendRequest => 'Invia richiesta';

  @override
  String get userProfileOpenChat => 'Apri chat';

  @override
  String socialMatchVibraSent(String name) {
    return 'Vibra inviata a $name! 🎉';
  }

  @override
  String get socialMatchViewProfile => 'Vedi profilo completo';

  @override
  String get socialMatchIgnore => 'Ignora';

  @override
  String get userProfileNotAvailableTitle => 'Profilo non disponibile';

  @override
  String get userProfileNotAvailableMessage =>
      'Nessun utente selezionato o nessun match disponibile al momento.';

  @override
  String get userProfileEvents => 'Concerti passati/in programma';

  @override
  String get socialDiscoverUsers => 'Scopri utenti';

  @override
  String get socialHighCompatibility =>
      'Utenti con compatibilità musicale alta';

  @override
  String socialRequestsCount(int count) {
    return 'Richieste ($count)';
  }

  @override
  String get socialPendingFriendships => 'Amicizie in attesa';

  @override
  String get socialRequestsToManage => 'Richieste da gestire';

  @override
  String get navHome => 'Home';

  @override
  String get navEvents => 'Eventi';

  @override
  String get navVibra => 'Vibra';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profilo';

  @override
  String get friendsYourFriends => 'I tuoi amici';

  @override
  String get friendsYourConnections => 'Le tue connessioni su Vibra';

  @override
  String get friendsNoFriendsYet => 'Nessun amico ancora';

  @override
  String get friendsGoToExplore =>
      'Vai nella sezione Esplora o usa il Social Match per trovare persone con i tuoi stessi gusti.';

  @override
  String get friendsSentRequests => 'Richieste inviate';

  @override
  String get friendsWaitingForReply => 'In attesa di risposta';

  @override
  String get friendsPendingApproval => 'In attesa di approvazione';

  @override
  String get socialMatchNewAffinity => 'NUOVA AFFINITÀ';

  @override
  String get socialMatchScore => 'MATCH SCORE';

  @override
  String get socialMatchWhyMatched => 'PERCHÉ MATCHATE';

  @override
  String socialMatchCommonEvents(String count) {
    return 'Live nearby • $count eventi in comune';
  }

  @override
  String get socialMatchSendVibra => 'Invia Vibra';

  @override
  String get exploreSearchHint => 'Cerca per nome o città (es. Milano)';

  @override
  String get exploreInteractiveMap => 'Mappa interattiva';

  @override
  String get exploreLiveAroundYou =>
      'Esplora i live intorno a te in tempo reale';

  @override
  String get exploreSearchRadius => 'Raggio di ricerca';

  @override
  String get exploreFindEventsNearYou => 'Trova eventi vicino a te';

  @override
  String get exploreMusicGenre => 'Genere musicale';

  @override
  String get exploreFilterByGenre => 'Filtra per i tuoi generi preferiti';

  @override
  String get exploreGenreAll => 'Tutti';

  @override
  String get friendsReceivedRequests => 'Richieste ricevute';

  @override
  String get friendsAcceptOrReject => 'Accetta o rifiuta nuove connessioni';

  @override
  String get friendsWantsToConnect => 'Vuole connettersi con te';

  @override
  String socialMatchListenBoth(String artists) {
    return 'Ascoltate entrambi $artists';
  }

  @override
  String socialMatchCityEvents(String city, String count) {
    return '$city • $count eventi in comune';
  }

  @override
  String get myProfileConnectSpotify => 'Collega Spotify';

  @override
  String get myProfileOverview => 'Panoramica';

  @override
  String get myProfileOverviewSubtitle => 'Accesso rapido alle aree profilo';

  @override
  String get myProfileSettings => 'Impostazioni';

  @override
  String get myProfileMusicStats => 'Statistiche musicali';

  @override
  String get myProfileMusicStatsSubtitle =>
      'Top artisti, generi e heatmap ascolti';

  @override
  String get myProfileMyEvents => 'I miei eventi';

  @override
  String myProfileMyEventsSubtitle(String count) {
    return '$count eventi salvati, in arrivo e passati';
  }

  @override
  String get myProfileSettingsSubtitle =>
      'Privacy, notifiche, account e logout';

  @override
  String get myEventsTitle => 'I miei eventi';

  @override
  String get myEventsGoing => 'Parteciperò';

  @override
  String get myEventsGoingSubtitle => 'Eventi confermati o in arrivo';

  @override
  String get myEventsGoingEmpty =>
      'Non hai ancora confermato la tua presenza a nessun evento.\\nEsplora e trova i tuoi prossimi concerti!';

  @override
  String get myEventsSaved => 'Salvati';

  @override
  String get myEventsSavedSubtitle => 'Da tenere d’occhio';

  @override
  String get myEventsSavedEmpty =>
      'Nessun evento salvato.\\nSalva gli eventi che ti interessano per non perderli.';

  @override
  String get chatEmptyTitle => 'Nessun messaggio';

  @override
  String get chatEmptyMessage => 'Inizia la conversazione!';

  @override
  String get chatInputHint => 'Scrivi un messaggio...';

  @override
  String get socialMatchScanningTitle => 'ANALISI VIBRAZIONI';

  @override
  String get socialMatchScanningSubtitle =>
      'Ricerca persone con affinità musicale vicine a te...';

  @override
  String get socialMatchEmptyTitle => 'Nessuna affinità nelle vicinanze';

  @override
  String get socialMatchEmptyMessage =>
      'Le tue vibrazioni musicali sono uniche! Non ci sono persone con affinità simili vicine a te in questo momento...';

  @override
  String get socialMatchEmptyAction => 'Scopri eventi vicino a te';

  @override
  String get socialMatchEmptySecondary => 'Cerca di nuovo';

  @override
  String get musicStatsTitle => 'Statistiche Musicali';

  @override
  String musicStatsSyncError(String error) {
    return 'Errore sincronizzazione: $error';
  }

  @override
  String get musicStatsTopArtists => 'Top artisti';

  @override
  String get musicStatsTopArtistsSub => 'Score basato sulle preferenze Spotify';

  @override
  String get musicStatsHeatmap => 'Heatmap ascolti';

  @override
  String get musicStatsHeatmapSub =>
      'Distribuzione settimanale dei tuoi ascolti';

  @override
  String get liveScreenTitle => 'Live Vibra';

  @override
  String get liveScreenSendFailed =>
      'Invio non riuscito. Verifica sessione e presenza al live.';

  @override
  String get liveScreenActivateMode => 'Attiva Modalità Live';

  @override
  String get liveScreenPresentNowTitle => 'Presenti adesso';

  @override
  String get liveScreenPresentNowSub =>
      'Partecipanti con compatibilità musicale';

  @override
  String get liveScreenChatTitle => 'Chat evento';

  @override
  String get liveScreenChatSub => 'Realtime Supabase con auto-chiusura a 24h';

  @override
  String get eventDetailNotAvailableTitle => 'Evento non disponibile';

  @override
  String get eventDetailNotAvailableMsg =>
      'Questo evento non è più disponibile o non è stato ancora caricato.';

  @override
  String get eventDetailMapTitle => 'Mappa della venue';

  @override
  String get eventDetailMapSub => 'Posizione dellevento';

  @override
  String get eventDetailAttendeesTitle => 'Chi partecipa';

  @override
  String get eventDetailAttendeesSub =>
      'Utenti con match musicale e presenza confermata';

  @override
  String get spotifyAuthStep1Title => '1. Autorizzazione OAuth';

  @override
  String get spotifyAuthStep1Sub =>
      'Accedi in sicurezza sul sito ufficiale di Spotify';

  @override
  String get spotifyAuthStep2Title => '2. Scambio Credenziali';

  @override
  String get spotifyAuthStep2Sub =>
      'Generazione chiavi di sicurezza e crittografia token';

  @override
  String get spotifyAuthStep3Title => '3. Sincronizzazione Gusti';

  @override
  String get spotifyAuthStep3Sub =>
      'Analisi di top artisti, brani ascoltati e playlist';

  @override
  String get spotifyAuthCancelled =>
      'Connessione annullata. Devi autorizzare Vibra per ricevere consigli personalizzati.';

  @override
  String spotifyAuthError(String error) {
    return 'Si è verificato un errore: $error';
  }

  @override
  String get commonRetry => 'Riprova';

  @override
  String get legalPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get legalPrivacySec1 => 'Quali dati raccoglie Vibra';

  @override
  String get legalPrivacySec2 => 'Perché Vibra li usa';

  @override
  String get legalPrivacySec3 => 'I tuoi controlli';

  @override
  String get legalPrivacySec4 => 'Contatto privacy';

  @override
  String get legalTermsTitle => 'Termini di servizio';

  @override
  String get legalTermsSec1 => 'Uso di Vibra';

  @override
  String get legalTermsSec2 => 'Servizi terzi';

  @override
  String get legalTermsSec3 => 'Contenuti e comportamento';

  @override
  String get legalTermsSec4 => 'Contatto legale';

  @override
  String get legalSupportTitle => 'Supporto';

  @override
  String get legalSupportSec1 => 'Email supporto';

  @override
  String get legalSupportSec2 => 'Problemi coperti';

  @override
  String get legalSupportSec3 => 'Cosa verificare prima';

  @override
  String get legalAboutTitle => 'Informazioni su Vibra';

  @override
  String get legalAboutSec1 => 'Versione';

  @override
  String get legalAboutSec2 => 'Identificativi piattaforma';

  @override
  String get legalAboutSec3 => 'Cosa fa Vibra';

  @override
  String get legalAboutSec4 => 'Supporto';

  @override
  String get langEnglish => 'English';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langSpanish => 'Español';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get spotifyAuthCancelledTitle => 'Autenticazione Fallita';

  @override
  String get errorTitle => 'Errore di Sistema';

  @override
  String get legalPrivacyBody1 =>
      'Dati account, profilo musicale, partecipazione agli eventi, messaggi, attività in live chat, posizione quando autorizzata e token push.';

  @override
  String get legalPrivacyBody2 =>
      'Per autenticare gli utenti, generare raccomandazioni musicali, abilitare funzioni social, inviare notifiche e migliorare l’affidabilità del servizio.';

  @override
  String get legalPrivacyBody3 =>
      'Puoi revocare permessi, scollegare servizi, richiedere la cancellazione e gestire visibilità e preferenze privacy dalle impostazioni account.';

  @override
  String legalPrivacyBody4(String email) {
    return 'Richieste privacy e dati personali: $email';
  }

  @override
  String get legalTermsBody1 =>
      'Usando Vibra, gli utenti accettano di utilizzare l’app in modo lecito, mantenere dati accurati ed evitare comportamenti abusivi o dannosi.';

  @override
  String get legalTermsBody2 =>
      'Spotify, Supabase, Firebase e i provider eventi possono essere usati per erogare le funzioni principali. Si applicano anche i loro termini e privacy policy.';

  @override
  String get legalTermsBody3 =>
      'Gli utenti sono responsabili dei contenuti pubblicati e dei messaggi inviati. Vibra può sospendere o rimuovere account che violano le regole della piattaforma.';

  @override
  String legalTermsBody4(String email) {
    return 'Richieste legali e comunicazioni formali: $email';
  }

  @override
  String legalSupportBody1(String email) {
    return '$email';
  }

  @override
  String get legalSupportBody2 =>
      'Problemi di login, collegamento Spotify, scoperta eventi, notifiche, chat, richieste privacy e cancellazione account.';

  @override
  String get legalSupportBody3 =>
      'Permessi, stato del collegamento Spotify, configurazione Firebase e presenza di un utente autenticato.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Android package: $android\niOS bundle: $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra aiuta a collegare Spotify, scoprire eventi live rilevanti, vedere dettagli evento, incontrare persone compatibili ed entrare nelle chat live durante i concerti.';

  @override
  String legalAboutBody4(String email) {
    return '$email';
  }

  @override
  String get homeGreetingMorning => 'Buongiorno 👋';

  @override
  String get homeGreetingAfternoon => 'Buon pomeriggio 👋';

  @override
  String get homeGreetingEvening => 'Buonasera 🌙';

  @override
  String get eventCardTBA => 'Venue da definire';

  @override
  String get eventCardCity => 'Città';

  @override
  String get legalPrivacySubtitle =>
      'Una sintesi delle informazioni privacy disponibili nell’app, incluse le categorie di dati trattati e le finalità d’uso.';

  @override
  String get legalTermsSubtitle =>
      'Una sintesi delle regole, responsabilità e condizioni del servizio applicabili all’uso di Vibra.';

  @override
  String get legalSupportSubtitle =>
      'Informazioni di supporto per accesso account, notifiche, collegamento Spotify e funzioni live.';

  @override
  String get legalAboutSubtitle =>
      'Vibra unisce gusto musicale, scoperta eventi e interazione sociale attorno alle esperienze live.';

  @override
  String get exploreShowAllEvents => 'Mostra tutti gli eventi';

  @override
  String get musicStatsSyncSpotify => 'Sincronizza Spotify';

  @override
  String get liveModeDisabled => 'La modalità Live è disattivata';

  @override
  String get authCreateAccount => 'Crea un Account';

  @override
  String get authLoginWithEmail => 'Accedi con Email';

  @override
  String get authUsername => 'Nome utente';

  @override
  String get authUsernameHint => 'Inserisci un nome utente';

  @override
  String get authEmail => 'Indirizzo Email';

  @override
  String get authEmailHint => 'Inserisci la tua email';

  @override
  String get authEmailInvalid => 'Inserisci una email valida';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Inserisci la tua password';

  @override
  String get authPasswordShort =>
      'La password deve contenere almeno 6 caratteri';

  @override
  String get authRegister => 'Registrati';

  @override
  String get authLogin => 'Accedi';

  @override
  String get authAlreadyHaveAccount => 'Hai già un account? Accedi';

  @override
  String get authDontHaveAccount => 'Non hai un account? Registrati';

  @override
  String get authGenericError => 'Si è verificato un errore';

  @override
  String get eventCardLocation => 'Location';

  @override
  String get matchScore => 'MATCH SCORE';

  @override
  String get userGeneric => 'Utente';

  @override
  String get spotifyConnectTitle => 'Connetti Spotify';

  @override
  String get spotifyConnectSubtitle =>
      'Collega il tuo account per sincronizzare i tuoi artisti preferiti e sbloccare raccomandazioni personalizzate per i concerti.';

  @override
  String get spotifyConnectOnboarding => 'Flusso di Onboarding';

  @override
  String get spotifyConnectPrivacyDesc =>
      'Leggeremo i tuoi artisti e generi più ascoltati per personalizzare i consigli ed elaborare la tua affinità (Match Score) con altri utenti. I dati storici aggregati verranno utilizzati solo a questo scopo.';

  @override
  String get spotifyConnectContinue => 'Continua ed Esplora';

  @override
  String get spotifyConnectRetry => 'Riprova Collegamento';

  @override
  String get spotifyConnectAction => 'Collega il mio Spotify';

  @override
  String get spotifyConnectSkip => 'Salta per ora';

  @override
  String get homeSpotifySyncTitle => 'Sblocca Consigli Personalizzati';

  @override
  String get homeSpotifySyncSub => 'Sincronizza i tuoi ascolti musicali';

  @override
  String get homeSpotifySyncDesc =>
      'Collega Spotify per ricevere consigli su eventi e trovare persone con i tuoi stessi gusti.';

  @override
  String get homeSpotifySyncAction => 'COLLEGA SPOTIFY';
}
