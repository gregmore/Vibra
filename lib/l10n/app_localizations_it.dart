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
  String get loginSubtitle => 'Scopri concerti e persone con cui viverli.';

  @override
  String get loginConsent =>
      'Puoi leggere i termini e la privacy prima di continuare. Gestisci le preferenze facoltative nelle impostazioni.';

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
      'Per ricevere notifiche, accedi e abilita le notifiche di Vibra nelle impostazioni del dispositivo.';

  @override
  String get settingsPrivacyPolicy => 'Informativa sulla privacy';

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
      'Impossibile eliminare l’account. Riprova oppure contatta il supporto.';

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
      'Esplora la community per trovare persone e inviare richieste di amicizia.';

  @override
  String get friendsSentRequests => 'Richieste inviate';

  @override
  String get friendsWaitingForReply => 'In attesa di risposta';

  @override
  String get friendsPendingApproval => 'In attesa di approvazione';

  @override
  String get socialMatchNewAffinity => 'NUOVA AFFINITÀ';

  @override
  String get socialMatchScore => 'AFFINITÀ MUSICALE';

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
  String exploreSearchRadius(int radius) {
    return 'RAGGIO DI RICERCA: $radius KM';
  }

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
  String get myEventsUpcoming => 'In arrivo';

  @override
  String get myEventsPast => 'Passati';

  @override
  String get myEventsPastSubtitle => 'Il tuo storico concerti';

  @override
  String get myEventsPastEmpty => 'Non hai ancora eventi passati.';

  @override
  String get myEventsSearchHint => 'Cerca eventi, artisti o luoghi';

  @override
  String get myEventsSearchEmpty => 'Nessun evento corrisponde alla ricerca.';

  @override
  String get myEventsClearSearch => 'Cancella ricerca';

  @override
  String get myEventsExplore => 'Esplora eventi';

  @override
  String get inboxUnread => 'Non letti';

  @override
  String get inboxNoResults => 'Nessuna conversazione trovata.';

  @override
  String get inboxNoResultsBody =>
      'Prova un altro nome o rimuovi i filtri per vedere tutti i messaggi.';

  @override
  String get inboxClearFilters => 'Rimuovi filtri';

  @override
  String get homeFeedError => 'Gli eventi non si sono caricati.';

  @override
  String get homeFeedErrorBody =>
      'Riprova tra poco. Puoi comunque esplorare la mappa.';

  @override
  String get homeFeedEmpty => 'C’è spazio per una nuova serata.';

  @override
  String get homeFeedEmptyBody =>
      'Esplora la mappa per trovare il prossimo live.';

  @override
  String get socialSearchHint => 'Cerca persone o artisti';

  @override
  String get socialSearchEmpty => 'Nessuna persona trovata.';

  @override
  String get socialSearchEmptyBody => 'Prova un altro nome o artista.';

  @override
  String get socialDiscoverEmpty => 'Le nuove connessioni partono da qui.';

  @override
  String get socialDiscoverEmptyBody =>
      'Completa il profilo e collega Spotify per trovare persone con gusti simili.';

  @override
  String get chatSendMessage => 'Invia messaggio';

  @override
  String get chatLoadError =>
      'Non è stato possibile caricare la conversazione.';

  @override
  String get chatDraftRecovered =>
      'Il messaggio non è stato inviato. Il testo è stato recuperato nel campo di scrittura.';

  @override
  String get eventLocationUnknown =>
      'La posizione esatta non è ancora disponibile.';

  @override
  String get eventDirections => 'Indicazioni stradali';

  @override
  String get eventDirectionsError =>
      'Non è stato possibile aprire le indicazioni.';

  @override
  String get inboxDeleteTitle => 'Eliminare la conversazione?';

  @override
  String get inboxDeleteBody =>
      'La conversazione verrà rimossa dalla tua casella. I messaggi dell’altra persona non verranno eliminati.';

  @override
  String get inboxDeleteAction => 'Elimina conversazione';

  @override
  String get inboxDeleteSuccess => 'Conversazione eliminata.';

  @override
  String get inboxDeleteError =>
      'La conversazione non è stata eliminata. Riprova.';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get eventCopyDetails => 'Copia i dettagli dell’evento';

  @override
  String get eventCopyError => 'Non è stato possibile copiare i dettagli.';

  @override
  String get eventCancelled => 'Evento cancellato';

  @override
  String get eventTicketsOffsale => 'Biglietti non in vendita';

  @override
  String get socialMatchSendFailed =>
      'Vibra non inviata. Riprova: il profilo è ancora disponibile.';

  @override
  String get myEventsTitle => 'I miei eventi';

  @override
  String get myEventsGoing => 'Parteciperò';

  @override
  String get myEventsGoingSubtitle => 'Eventi confermati o in arrivo';

  @override
  String get myEventsGoingEmpty =>
      'Non hai ancora confermato la tua presenza a nessun evento.\nEsplora e trova i tuoi prossimi concerti!';

  @override
  String get myEventsSaved => 'Salvati';

  @override
  String get myEventsSavedSubtitle => 'Da tenere d’occhio';

  @override
  String get myEventsSavedEmpty =>
      'Nessun evento salvato.\nSalva gli eventi che ti interessano per non perderli.';

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
  String get legalPrivacyPolicyTitle => 'Informativa sulla privacy';

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
      'Controlla connessione, permessi del dispositivo e stato di accesso. Se il problema continua, invia una segnalazione dalle impostazioni.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Versione $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Pacchetto Android: $android\nIdentificativo iOS: $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra ti aiuta a scoprire eventi dal vivo, esplorare la mappa, salvare concerti, incontrare persone e partecipare alle chat. Le funzionalità Spotify sono disponibili solo quando il servizio è abilitato.';

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
      'Eventi dal vivo, mappa e community per condividere nuove serate.';

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
  String get matchScore => 'AFFINITÀ MUSICALE';

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

  @override
  String get loginBackToWelcome => 'Torna alla schermata di benvenuto';

  @override
  String get authOr => 'oppure';

  @override
  String get authEmailLoginSubtitle =>
      'Inserisci le tue credenziali per accedere ed esplorare concerti.';

  @override
  String get authEmailRegisterSubtitle =>
      'Inserisci le tue credenziali per registrarti e iniziare a vivere i live.';

  @override
  String get authAgeConfirmation => 'Confermo di avere almeno 18 anni.';

  @override
  String get authAgeExplanation =>
      'Vibra facilita incontri tra persone e non è destinata ai minori.';

  @override
  String get authAgeRequired =>
      'Devi confermare di avere almeno 18 anni per creare un account.';

  @override
  String get authShowPassword => 'Mostra password';

  @override
  String get authHidePassword => 'Nascondi password';

  @override
  String get spotifyUnavailableTitle => 'Spotify in pausa';

  @override
  String get spotifyUnavailableBody =>
      'Spotify e le affinità musicali sono temporaneamente disattivati. Eventi, amici e chat restano disponibili.';

  @override
  String get launchExploreTitle => 'Trova il tuo prossimo concerto';

  @override
  String get launchExploreBody =>
      'Cerca artisti, esplora la mappa e salva gli eventi vicino a te.';

  @override
  String get launchCommunityTitle => 'Vivi la community';

  @override
  String get launchCommunityBody =>
      'Trova persone, aggiungi amici e organizza i concerti nelle chat.';

  @override
  String get launchSavedTitle => 'La tua agenda live';

  @override
  String get launchSavedBody =>
      'Salva i concerti e ritrova quelli a cui vuoi partecipare.';

  @override
  String get launchCommunitySubtitle => 'Cerca persone per nome o username';

  @override
  String get launchCommunityEmptyTitle => 'Nessuna persona trovata';

  @override
  String get launchCommunityEmptyBody =>
      'Prova un altro nome o controlla più tardi.';

  @override
  String get launchCommunityLoadError =>
      'Impossibile caricare le persone. Riprova.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonLoading => 'Caricamento in corso…';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonAll => 'Tutti';

  @override
  String get commonConnect => 'Collega';

  @override
  String get commonActive => 'Attivo';

  @override
  String get commonNotNow => 'Non ora';

  @override
  String get commonSkip => 'Salta';

  @override
  String get commonTryLater => 'Riprova più tardi.';

  @override
  String get commonConnectionError => 'Errore di connessione';

  @override
  String commonLoadingLabel(String label) {
    return '$label, caricamento in corso';
  }

  @override
  String commonSelectedLabel(String label) {
    return '$label selezionato';
  }

  @override
  String commonNotSelectedLabel(String label) {
    return '$label non selezionato';
  }

  @override
  String get commonOnline => 'Online';

  @override
  String get commonAvatar => 'Avatar';

  @override
  String commonPercentLabel(int percentage, String label) {
    return '$percentage percento $label';
  }

  @override
  String commonAvatarAffinity(String name, int percentage) {
    return '$name, affinità $percentage percento';
  }

  @override
  String get commonRegistrationComplete => 'Registrazione completata';

  @override
  String get profileEditTitle => 'Modifica Profilo';

  @override
  String get profileBack => 'Torna al profilo';

  @override
  String get profilePersonalSpace => 'SPAZIO PERSONALE';

  @override
  String get profileSpotifyConnected => 'Spotify collegato';

  @override
  String get profileFollowers => 'Follower';

  @override
  String get profileFollowing => 'Seguiti';

  @override
  String get profileOpenMusicStats => 'Apri statistiche musicali';

  @override
  String get profileYourVibra => 'LA TUA VIBRA';

  @override
  String get profileInRotation => 'In rotazione';

  @override
  String get profileSyncMusicBody =>
      'Sincronizza Spotify per vedere la tua impronta musicale.';

  @override
  String get profileShapeTitle => 'Dai forma alla tua Vibra';

  @override
  String get profileShapeBody =>
      'Collega Spotify per rendere il tuo profilo musicale riconoscibile.';

  @override
  String get profileUsernameEmpty => 'L’username non può essere vuoto';

  @override
  String get profileUsernameShort => 'Minimo 3 caratteri';

  @override
  String get profileUsernameCharacters => 'Usa solo lettere, numeri, _ o .';

  @override
  String get profileUsernameCharactersOnboarding =>
      'Solo lettere, numeri e underscore';

  @override
  String get profileUsernameTaken => 'Username già in uso';

  @override
  String get profileUsernameTakenRetry =>
      'Username già in uso. Scegline un altro.';

  @override
  String get profilePhotoPermission =>
      'Consenti l’accesso alle foto nelle impostazioni del dispositivo e riprova.';

  @override
  String get profilePhotoPickError =>
      'Impossibile selezionare l’immagine. Riprova.';

  @override
  String get profilePhotoTitle => 'Foto Profilo';

  @override
  String get profilePhotoGallery => 'Scegli dalla galleria';

  @override
  String get profilePhotoGalleryBody =>
      'Seleziona una foto dal tuo dispositivo';

  @override
  String get profilePhotoCamera => 'Scatta una foto';

  @override
  String get profilePhotoCameraBody => 'Usa la fotocamera per un nuovo scatto';

  @override
  String get profilePhotoRemove => 'Rimuovi foto';

  @override
  String get profilePhotoRestore => 'Ripristina l’avatar predefinito';

  @override
  String get profileSaved => 'Profilo aggiornato con successo!';

  @override
  String get profileSaveError =>
      'Impossibile salvare il profilo. Riprova tra poco.';

  @override
  String get profilePhotoChange => 'Cambia immagine profilo';

  @override
  String get profileUsernameExample => 'es. musica_fan';

  @override
  String get profileName => 'Nome';

  @override
  String get profileNameHint => 'Il tuo nome o nickname';

  @override
  String get profileNameEmpty => 'Il nome non può essere vuoto';

  @override
  String get profileDescription => 'Descrizione';

  @override
  String get profileDescriptionHint => 'Racconta qualcosa di te…';

  @override
  String get profileMusicStreaming => 'Musica e streaming';

  @override
  String get profileAccountConnected => 'Account connesso';

  @override
  String get profileConnectSuggestions =>
      'Collega il tuo account per suggerimenti migliori';

  @override
  String get profileSaveChanges => 'Salva Modifiche';

  @override
  String get homeYourSoundToday => 'IL TUO SUONO, OGGI';

  @override
  String get homeSpotifySynced =>
      'Spotify sincronizzato · i suggerimenti imparano da te';

  @override
  String get homeSpotifyPersonalize =>
      'Collega Spotify per rendere i suggerimenti davvero tuoi';

  @override
  String get homeCompleteProfile => 'Completa il profilo';

  @override
  String get homeShapeVibra => 'Dai più forma alla tua vibra';

  @override
  String get homeNextEvent => 'IL PROSSIMO';

  @override
  String get homeNearbyEyebrow => 'NELLE VICINANZE';

  @override
  String get homeTrendingEyebrow => 'SI MUOVE ORA';

  @override
  String get settingsPrivateMessages => 'Messaggi e richieste private';

  @override
  String get settingsPersonalizedUpdates =>
      'Aggiornamenti personalizzati e ritorno su Vibra';

  @override
  String get settingsMusicWeek => 'La tua settimana musicale';

  @override
  String get settingsMusicWeekBody => 'Eventi e affinità selezionati per te';

  @override
  String get settingsWeekly => 'Settimanale';

  @override
  String get settingsMonthly => 'Mensile';

  @override
  String get settingsNever => 'Mai';

  @override
  String get settingsPrivacyData => 'Privacy e dati personali';

  @override
  String get settingsPrivacyDataBody =>
      'Consensi, esportazione e cancellazione dati';

  @override
  String get settingsHelpCenter => 'Centro assistenza';

  @override
  String get settingsHelpCenterBody => 'FAQ su account, eventi, chat e Spotify';

  @override
  String get settingsReportProblem => 'Segnala un problema';

  @override
  String get settingsReportProblemBody =>
      'Invia dettagli tecnici anonimizzati e uno screenshot';

  @override
  String get privacySaveError => 'Impossibile salvare la preferenza. Riprova.';

  @override
  String get privacyExportTitle => 'La tua esportazione dati';

  @override
  String get privacySaveJSON => 'Salva JSON';

  @override
  String get privacyCopyJSON => 'Copia JSON';

  @override
  String get privacyCopiedJSON => 'JSON copiato negli appunti.';

  @override
  String get privacyExportError =>
      'Esportazione non disponibile. Riprova più tardi.';

  @override
  String privacyExportSaved(String path) {
    return 'Esportazione salvata in $path';
  }

  @override
  String get privacyIntro =>
      'Scegli separatamente i trattamenti opzionali. Puoi cambiare idea in qualunque momento.';

  @override
  String get privacyPreciseLocation => 'Posizione precisa';

  @override
  String get privacyPreciseLocationBody =>
      'Per eventi vicini e funzionalità Live. Conservata al massimo 30 giorni.';

  @override
  String get privacySpotifyMatching => 'Spotify per matching';

  @override
  String get privacySpotifyMatchingBody =>
      'Usa artisti, generi e ascolti sincronizzati per suggerimenti e affinità.';

  @override
  String get privacyServiceNotifications => 'Notifiche di servizio';

  @override
  String get privacyServiceNotificationsBody =>
      'Match, messaggi ed eventi salvati.';

  @override
  String get privacyMarketing => 'Comunicazioni marketing';

  @override
  String get privacyMarketingBody =>
      'Sempre opzionali; non condizionano l’uso dell’app.';

  @override
  String get privacyExportAction => 'Esporta i miei dati';

  @override
  String get privacyExportBody =>
      'Genera una copia JSON leggibile dei tuoi dati, inclusi profilo, chat, eventi e interazioni; i dati Spotify precedenti sono inclusi se presenti.';

  @override
  String get privacyDeletionBody =>
      'Cancellando l’account vengono eliminati i suoi dati. I messaggi inviati diventano anonimi e il loro contenuto e i media vengono rimossi. I backup seguono i tempi di conservazione indicati nell’informativa privacy.';

  @override
  String get appearanceTitle => 'Aspetto';

  @override
  String get appearanceBody =>
      'Scegli il tema dell’app o segui il dispositivo.';

  @override
  String get appearanceDark => 'Scuro';

  @override
  String get appearanceDarkBody =>
      'Riduce la luminosità in ambienti poco illuminati';

  @override
  String get appearanceLight => 'Chiaro';

  @override
  String get appearanceLightBody => 'Superfici luminose e ombre morbide';

  @override
  String get appearanceSystem => 'Automatico (segui sistema)';

  @override
  String get appearanceSystemBody =>
      'Si aggiorna quando cambia l’impostazione del dispositivo';

  @override
  String get onboardingBack => 'Torna al passaggio precedente';

  @override
  String get onboardingStart => 'Iniziamo';

  @override
  String get onboardingProfileTitle => 'Il tuo profilo';

  @override
  String get onboardingProfileBody => 'Come ti vedranno gli altri utenti';

  @override
  String get onboardingSkipToHome => 'Salta il resto e vai alla Home';

  @override
  String get onboardingPhotoUploading => 'Caricamento foto profilo in corso';

  @override
  String get onboardingPhotoSelect => 'Scegli o modifica la foto profilo';

  @override
  String get onboardingUsernameExample => 'es. vibra_user';

  @override
  String get onboardingRequired => 'OBBLIGATORIO';

  @override
  String get onboardingSpotifyBody =>
      'Trova eventi basati sui tuoi ascolti e scopri la tua affinità musicale con gli altri utenti.';

  @override
  String get onboardingSpotifyCancelled =>
      'Collegamento annullato. Puoi riprovare o saltare per ora.';

  @override
  String get onboardingSpotifyError =>
      'Errore durante il collegamento. Riprova più tardi.';

  @override
  String get onboardingLocationTitle => 'Eventi vicino a te';

  @override
  String get onboardingLocationBody =>
      'Attiva la posizione per scoprire i concerti e i locali nella tua zona.';

  @override
  String get onboardingLocationDenied =>
      'Permesso negato permanentemente. Puoi abilitarlo in seguito nelle impostazioni del dispositivo.';

  @override
  String get onboardingAllowLocation => 'Consenti posizione';

  @override
  String get onboardingNotificationsTitle => 'Rimani aggiornato';

  @override
  String get onboardingNotificationsBody =>
      'Ricevi notifiche per eventi salvati, richieste di amicizia e messaggi.';

  @override
  String get onboardingNotificationsDenied =>
      'Notifiche negate. Puoi abilitarle nelle impostazioni del dispositivo.';

  @override
  String get onboardingAllowNotifications => 'Attiva notifiche';

  @override
  String get liveAttendanceError =>
      'Impossibile confermare la partecipazione. Riprova.';

  @override
  String get liveEventsLoadError => 'Impossibile caricare gli eventi Live.';

  @override
  String get liveLocationHelp =>
      'La chat Live è disponibile entro 500 m da un evento, nelle 24 ore prima e dopo il concerto. Attiva la posizione nelle impostazioni privacy.';

  @override
  String get liveUnavailableHere =>
      'La chat di questo evento non è disponibile dalla tua posizione o in questo momento.';

  @override
  String get liveRefreshLocation => 'Aggiorna posizione';

  @override
  String get liveEventTitle => 'Evento Live';

  @override
  String get liveConnectionInterrupted =>
      'Connessione alla chat Live interrotta.';

  @override
  String get liveEmpty => 'Nessun messaggio. Inizia la conversazione!';

  @override
  String get liveRetryAttendance => 'Riprova a verificare la partecipazione';

  @override
  String get liveConfirmingAttendance => 'Conferma in corso…';

  @override
  String get liveJoinToChat => 'Partecipa per scrivere nella chat';

  @override
  String get liveInputHint => 'Scrivi in chat Live…';

  @override
  String get liveSendMessage => 'Invia messaggio Live';

  @override
  String get musicReconnect => 'Ricollega';

  @override
  String get musicReconnectBody =>
      'Ricollega Spotify per aggiornare le statistiche musicali.';

  @override
  String get musicStatsUpdated => 'Statistiche musicali aggiornate.';

  @override
  String get musicStatsRefreshing => 'Aggiornamento statistiche musicali';

  @override
  String get musicStatsNoArtists =>
      'Nessun artista disponibile dopo l’ultima sincronizzazione.';

  @override
  String get musicStatsEmptyTitle => 'Dai un suono al tuo profilo.';

  @override
  String get musicStatsEmptyBody =>
      'Collega Spotify per vedere gli artisti e il ritmo che ti definiscono.';

  @override
  String get musicStatsYourSound => 'IL TUO SUONO';

  @override
  String get musicStatsHeroTitle => 'Ascolti che fanno segnale.';

  @override
  String get musicStatsArtists => 'Artisti';

  @override
  String get musicStatsRhythm => 'Ritmo';

  @override
  String get spotifyBackToLogin => 'Torna al login';

  @override
  String get spotifyConsentBody =>
      'Collegando Spotify autorizzi Vibra a leggere il tuo profilo, artisti, brani e generi principali. Li usiamo per suggerire eventi e affinità musicali; puoi scollegare Spotify e cancellare questi dati nelle impostazioni.';

  @override
  String get eventBackToEvents => 'Torna agli eventi';

  @override
  String get eventPrice => 'Prezzo';

  @override
  String get eventVenueTBA => 'Luogo da definire';

  @override
  String eventOpenSemantics(String name, String date, String place) {
    return 'Apri evento $name, $date, $place';
  }

  @override
  String eventAffinitySemantics(int percentage) {
    return 'Affinità $percentage percento';
  }

  @override
  String eventForYouScore(int percentage) {
    return '$percentage% PER TE';
  }

  @override
  String eventCommonSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventi in comune o salvati',
      one: '$count evento in comune o salvato',
    );
    return '$_temp0';
  }

  @override
  String get supportReportTitle => 'Segnala un problema';

  @override
  String get supportReportIntro =>
      'Descrivi cosa non funziona. Includeremo versione dell’app, sistema operativo e pochi dati tecnici ripuliti da informazioni sensibili.';

  @override
  String get supportDescriptionLabel => 'Descrizione del problema';

  @override
  String get supportDescriptionHint =>
      'Indica la schermata, i passaggi e cosa ti aspettavi.';

  @override
  String get supportAddScreenshot => 'Aggiungi screenshot';

  @override
  String get supportScreenshotAttached => 'Screenshot allegato';

  @override
  String get supportRemoveScreenshot => 'Rimuovi screenshot';

  @override
  String get supportScreenshotPrivacy =>
      'Controlla che lo screenshot non mostri password, messaggi privati o altri dati sensibili.';

  @override
  String get supportSending => 'Invio in corso…';

  @override
  String get supportSendReport => 'Invia segnalazione';

  @override
  String get supportDescriptionTooShort =>
      'Descrivi il problema con almeno 8 caratteri.';

  @override
  String get supportDescriptionTooLong =>
      'La descrizione può contenere al massimo 4000 caratteri.';

  @override
  String get supportReportSentTitle => 'Segnalazione inviata';

  @override
  String get supportReportSentBody =>
      'Abbiamo ricevuto la tua segnalazione. Il supporto risponde entro 48 ore lavorative.';

  @override
  String supportReportSendFailed(String email) {
    return 'Invio non riuscito. Riprova oppure scrivi a $email.';
  }

  @override
  String get supportReportAuthRequired =>
      'Accedi di nuovo per inviare la segnalazione.';

  @override
  String get supportReportRateLimited =>
      'Hai inviato troppe segnalazioni. Attendi un minuto e riprova.';

  @override
  String get supportScreenshotTooLarge =>
      'Lo screenshot deve essere più piccolo di 5 MB.';

  @override
  String get supportScreenshotUnsupported =>
      'Scegli uno screenshot in formato JPG o PNG.';

  @override
  String get supportScreenshotPickFailed =>
      'Impossibile selezionare lo screenshot. Riprova.';

  @override
  String get supportScreenshotPermissionDenied =>
      'Consenti l’accesso alle foto nelle impostazioni del dispositivo per allegare uno screenshot.';

  @override
  String supportAlternativeContact(String email) {
    return 'Puoi anche scrivere a $email. Rispondiamo entro 48 ore lavorative.';
  }

  @override
  String get supportFeedbackTitle => 'Come sta andando con Vibra?';

  @override
  String get supportFeedbackBody => 'Il tuo parere ci aiuta a migliorare.';

  @override
  String get supportFeedbackNegative => 'Non bene';

  @override
  String get supportFeedbackNeutral => 'Così così';

  @override
  String get supportFeedbackPositive => 'Bene!';

  @override
  String get supportFeedbackDescriptionPrefix => 'Feedback:';

  @override
  String get chatSendFriendshipRequired =>
      'Per scrivere a questa persona, invia una richiesta di amicizia e attendi che venga accettata.';

  @override
  String get chatSendFirstContactLimit =>
      'Hai già inviato 3 messaggi. Attendi una risposta prima di inviarne altri.';

  @override
  String get chatSendUnavailable => 'Questa conversazione non è disponibile.';

  @override
  String get chatSendRateLimited =>
      'Stai inviando troppi messaggi. Attendi un minuto e riprova.';

  @override
  String get chatSendSignInRequired =>
      'Accedi di nuovo per inviare il messaggio.';

  @override
  String get chatRequestFriendship => 'Richiedi amicizia';

  @override
  String get chatFriendshipRequestSent => 'Richiesta di amicizia inviata';

  @override
  String get chatFriendshipRequestFailed =>
      'Impossibile inviare la richiesta di amicizia. Riprova.';

  @override
  String get chatMessageTooLong =>
      'Il messaggio può contenere al massimo 2000 caratteri.';

  @override
  String get chatPermissionChecking => 'Verifica della conversazione…';

  @override
  String get chatFriendshipRequestPending =>
      'Richiesta di amicizia in attesa di accettazione';

  @override
  String get chatAcceptFriendship => 'Accetta amicizia';

  @override
  String get chatFriendshipAccepted =>
      'Amicizia accettata. Ora puoi inviare messaggi.';

  @override
  String get socialReportUser => 'Segnala utente';

  @override
  String get socialReportSpam => 'Spam';

  @override
  String get socialReportHarassment => 'Molestie';

  @override
  String get socialReportInappropriate => 'Contenuto inappropriato';

  @override
  String get socialReportDetailsHint => 'Dettagli aggiuntivi (opzionale)';

  @override
  String get socialReportSent => 'Utente segnalato con successo';

  @override
  String get socialReportFailed =>
      'Impossibile inviare la segnalazione. Riprova.';

  @override
  String get socialReportAction => 'Segnala';

  @override
  String get socialBlockUser => 'Blocca utente';

  @override
  String get socialBlockConfirm =>
      'Sei sicuro di voler bloccare questo utente? Non potrete più scambiarvi messaggi.';

  @override
  String get socialBlockSuccess => 'Utente bloccato';

  @override
  String get socialBlockFailed =>
      'Impossibile bloccare questo utente. Riprova.';

  @override
  String get socialBlockAction => 'Blocca';

  @override
  String get chatRequestTitle => 'Richiesta di messaggio';

  @override
  String chatRequestBody(String name) {
    return '$name vorrebbe messaggiare con te. Rispondi per accettare la conversazione.';
  }

  @override
  String get chatRequestRejected => 'Richiesta rifiutata ed eliminata';

  @override
  String get chatRequestRejectFailed =>
      'Impossibile eliminare la richiesta. Riprova.';

  @override
  String get commonReject => 'Rifiuta';

  @override
  String get commonReply => 'Rispondi';

  @override
  String get userProfileView => 'Vedi profilo';

  @override
  String get chatConnectionInterrupted => 'Connessione alla chat interrotta.';

  @override
  String get chatMeetupTitle => 'Proposta di incontro';

  @override
  String get chatMeetupAccept => 'Ci Sto';

  @override
  String get chatMeetupDecline => 'Non Posso';

  @override
  String chatMeetupAcceptMessage(String message) {
    return 'Ci sto! $message';
  }

  @override
  String chatMeetupDeclineMessage(String message) {
    return 'Non posso partecipare. $message';
  }

  @override
  String get helpIntro =>
      'Risposte rapide e assistenza. Ti rispondiamo entro 48 ore lavorative.';

  @override
  String get helpSearchHint => 'Cerca nelle domande frequenti';

  @override
  String get helpSearchEmpty =>
      'Nessuna risposta trovata. Prova con un’altra ricerca.';

  @override
  String get helpNeedMore => 'Hai ancora bisogno di aiuto?';

  @override
  String get helpCategoryAll => 'Tutte';

  @override
  String get helpCategoryAccount => 'Account';

  @override
  String get helpCategoryChatMatch => 'Chat e affinità';

  @override
  String get helpCategoryPrivacy => 'Privacy';

  @override
  String get helpLoginQuestion => 'Non riesco ad accedere';

  @override
  String get helpLoginAnswer =>
      'Controlla email e password, poi chiudi e riapri Vibra. Se il problema continua, usa “Segnala un problema” e indica il metodo di accesso usato.';

  @override
  String get helpLogoutQuestion => 'Come esco dall’account?';

  @override
  String get helpLogoutAnswer =>
      'Vai in Profilo > Impostazioni > Esci. Per rimuovere la sessione da tutti i dispositivi, scegli “Esci da tutti i dispositivi”.';

  @override
  String get helpDeleteQuestion => 'Come cancello il mio account?';

  @override
  String get helpDeleteAnswer =>
      'Vai in Profilo > Impostazioni > Elimina account. La conferma rimuove i dati dell’account secondo l’informativa privacy.';

  @override
  String get helpEventsQuestion => 'Perché non vedo eventi vicino a me?';

  @override
  String get helpEventsAnswer =>
      'Verifica la posizione e amplia il raggio di ricerca. La disponibilità dipende dalle fonti degli eventi nella zona; puoi anche cercare una città.';

  @override
  String get helpTicketsQuestion => 'Un evento o i biglietti non si aprono';

  @override
  String get helpTicketsAnswer =>
      'Gli eventi e i biglietti provengono da partner esterni. Riprova più tardi; se il problema continua, invia una segnalazione indicando l’evento.';

  @override
  String get helpAffinityQuestion => 'Come viene calcolata l’affinità?';

  @override
  String get helpAffinityAnswer =>
      'Il punteggio confronta artisti e generi in comune, con un piccolo bonus per gusti meno diffusi. È un’indicazione di affinità, non una garanzia.';

  @override
  String get helpBlockQuestion => 'Come blocco o segnalo un utente?';

  @override
  String get helpBlockAnswer =>
      'Apri la conversazione e usa il menu per bloccare o segnalare l’utente. Il blocco impedisce le interazioni future; le segnalazioni sono inviate al team.';

  @override
  String get helpSpotifyConnectQuestion => 'Come collego Spotify?';

  @override
  String get helpSpotifyConnectAnswer =>
      'Vai in Profilo > Impostazioni > Account Spotify e completa l’autorizzazione nella finestra Spotify. Tornerai automaticamente in Vibra.';

  @override
  String get helpSpotifyDisconnectQuestion => 'Come scollego Spotify?';

  @override
  String get helpSpotifyDisconnectAnswer =>
      'Vai in Profilo > Impostazioni > Account Spotify e scegli “Scollega”.';

  @override
  String get helpSpotifyErrorQuestion => 'Il collegamento Spotify non riesce';

  @override
  String get helpSpotifyErrorAnswer =>
      'Verifica la connessione e completa l’autorizzazione. Non condividere password o token con il supporto: le segnalazioni includono solo dati tecnici ripuliti.';

  @override
  String get helpReportDataQuestion => 'Quali dati invia una segnalazione?';

  @override
  String get helpReportDataAnswer =>
      'Versione app e sistema operativo, ultimo endpoint in errore e pochi log tecnici ripuliti da dati sensibili. Lo screenshot è opzionale: controlla tu che non contenga informazioni private.';

  @override
  String get helpPrivacyQuestion => 'Come esercito i miei diritti sui dati?';

  @override
  String helpPrivacyAnswer(String email) {
    return 'Vai in Profilo > Impostazioni > Privacy e dati personali per gestire consensi ed esportare i dati. Per altre richieste scrivi a $email.';
  }

  @override
  String get exploreEyebrow => 'EVENTI, INTORNO A TE';

  @override
  String get exploreClearSearch => 'Cancella ricerca';

  @override
  String exploreEventsVisible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count EVENTI IN VISTA',
      one: '$count EVENTO IN VISTA',
    );
    return '$_temp0';
  }

  @override
  String get commonReset => 'Ripristina';

  @override
  String get exploreLoadErrorTitle => 'Gli eventi non si sono caricati.';

  @override
  String get exploreLoadErrorBody =>
      'Controlla la connessione e riprova la ricerca in questa zona.';

  @override
  String get exploreEmptyTitle => 'Nessun evento trovato in questa zona.';

  @override
  String get exploreEmptyBody => 'Allarga il raggio o modifica i filtri.';

  @override
  String get exploreZoomIn => 'Ingrandisci mappa';

  @override
  String get exploreZoomOut => 'Riduci ingrandimento mappa';

  @override
  String exploreOpenEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Apri elenco di $count eventi',
      one: 'Apri elenco di $count evento',
    );
    return '$_temp0';
  }

  @override
  String get exploreMoveMapHint => 'Muovi la mappa per cercare eventi';

  @override
  String exploreEventsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventi in questa zona',
      one: '$count evento in questa zona',
    );
    return '$_temp0';
  }

  @override
  String get exploreCloseEvents => 'Chiudi elenco eventi';

  @override
  String get exploreGenreElectronic => 'Elettronica';

  @override
  String get exploreGenreAlternative => 'Alternativa';

  @override
  String get commonLinkOpenError => 'Impossibile aprire il collegamento.';

  @override
  String get authConfirmEmail =>
      'Ti abbiamo inviato un’email di conferma. Controlla la posta prima di accedere.';

  @override
  String get authEmailNotConfirmed =>
      'Conferma prima il tuo indirizzo email. Controlla la casella di posta.';

  @override
  String get authInvalidCredentials =>
      'Email o password non corretti. Controllali e riprova.';

  @override
  String get authProviderUnavailable =>
      'Questo metodo di accesso non è disponibile. Usa l’email oppure riprova più tardi.';

  @override
  String get authEmailAlreadyRegistered =>
      'Questo indirizzo email è già registrato. Prova ad accedere.';

  @override
  String get authWeakPassword => 'Scegli una password più sicura e riprova.';

  @override
  String get errorNetwork =>
      'Connessione non disponibile. Controlla la rete e riprova.';

  @override
  String get errorSessionChanged =>
      'La sessione è cambiata. Accedi di nuovo e riprova.';

  @override
  String get errorRateLimited =>
      'Troppe richieste. Attendi un minuto e riprova.';

  @override
  String get errorActionFailed => 'Operazione non riuscita. Riprova tra poco.';

  @override
  String get socialAffinity => 'Affinità';

  @override
  String get socialFollow => 'Segui';

  @override
  String get socialFollowing => 'Seguito';

  @override
  String get socialFollowUpdateError =>
      'Impossibile aggiornare il seguito. Riprova.';

  @override
  String get socialMessageAction => 'Messaggia';

  @override
  String get socialFriendRequestSentShort => 'Inviata';

  @override
  String get socialFriendRequestError =>
      'Impossibile inviare la richiesta. Riprova.';

  @override
  String get socialAddFriend => 'Aggiungi';

  @override
  String get socialCommonArtists => 'Artisti in comune';

  @override
  String get socialUsersLoadError => 'Impossibile caricare gli utenti.';

  @override
  String socialFollowersCount(int count) {
    return 'Follower ($count)';
  }

  @override
  String socialFollowingCount(int count) {
    return 'Seguiti ($count)';
  }

  @override
  String get socialNoFollowers => 'Nessun follower';

  @override
  String get socialNoFollowersBody =>
      'Gli utenti che inizieranno a seguire questo profilo appariranno qui.';

  @override
  String get socialNoFollowing => 'Nessun utente seguito';

  @override
  String get socialNoFollowingBody => 'I profili seguiti appariranno qui.';

  @override
  String get friendsRequestUpdateError =>
      'Impossibile aggiornare la richiesta. Riprova.';

  @override
  String get friendsRemoveTitle => 'Rimuovi dagli amici';

  @override
  String friendsRemoveBody(String name) {
    return 'Vuoi rimuovere $name dai tuoi amici?';
  }

  @override
  String friendsRemoved(String name) {
    return '$name rimosso dagli amici';
  }

  @override
  String get friendsRemoveError =>
      'Impossibile rimuovere questo amico. Riprova.';

  @override
  String get commonRemove => 'Rimuovi';

  @override
  String get friendsConnectionsTitle => 'Amici e connessioni';

  @override
  String friendsCount(int count) {
    return 'Amici ($count)';
  }

  @override
  String get friendsReceived => 'Ricevute';

  @override
  String friendsSentCount(int count) {
    return 'Inviate ($count)';
  }

  @override
  String get friendsSearchHint => 'Cerca tra i tuoi amici…';

  @override
  String get friendsNoneFound => 'Nessun amico trovato';

  @override
  String get friendsFindBody =>
      'Esplora i profili, invia richieste di amicizia e condividi eventi.';

  @override
  String get friendsFindPeople => 'Trova persone';

  @override
  String get friendsNoReceived => 'Nessuna richiesta ricevuta';

  @override
  String get friendsNoReceivedBody =>
      'Quando qualcuno ti invierà una richiesta di amicizia la troverai qui.';

  @override
  String get friendsVibraUser => 'Utente Vibra';

  @override
  String get friendsNoSent => 'Nessuna richiesta inviata';

  @override
  String get friendsNoSentBody =>
      'Le richieste di amicizia inviate in attesa di risposta appariranno qui.';

  @override
  String inboxOpenConversation(String name) {
    return 'Apri conversazione con $name';
  }

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi non letti',
      one: '$count messaggio non letto',
    );
    return '$_temp0';
  }

  @override
  String get inboxEyebrow => 'IN CONTATTO';

  @override
  String get inboxMessages => 'Messaggi';

  @override
  String get inboxDirect => 'Diretti';

  @override
  String get inboxRequests => 'Richieste';

  @override
  String get inboxSearchHint => 'Cerca una conversazione';

  @override
  String get inboxClearSearch => 'Cancella ricerca conversazioni';

  @override
  String get inboxRefreshError => 'Impossibile aggiornare le conversazioni.';

  @override
  String get inboxEmptyTitle => 'Nessuna conversazione, ancora.';

  @override
  String get inboxEmptyBody =>
      'Trova qualcuno con cui condividere un concerto e inizia a parlare.';

  @override
  String get inboxNoRequests => 'Nessuna richiesta in attesa.';

  @override
  String get inboxNoRequestsBody =>
      'Le nuove richieste di messaggio compariranno qui.';

  @override
  String get socialMatchSend => 'INVIA';

  @override
  String get socialMatchPass => 'PASSA';

  @override
  String get socialMatchSharedListening =>
      'Il tuo ascolto ha trovato una linea comune.';

  @override
  String get socialYou => 'Tu';

  @override
  String get socialMatchFrequencyNow => 'stessa frequenza, adesso';

  @override
  String get socialMatchSharedSound => 'ASCOLTO CONDIVISO';

  @override
  String get socialMatchSameArea => 'STESSA ZONA';

  @override
  String get friendsLoadError => 'Impossibile caricare gli amici. Riprova.';
}
