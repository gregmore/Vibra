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
      'Vibra cancellerà il collegamento Spotify, gli artisti e i generi sincronizzati, la cronologia degli ascolti e le affinità musicali. I consigli sugli eventi non saranno più personalizzati.';

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
  String get socialPeopleSection => 'Persone';

  @override
  String get socialAffinityTitle => 'Trova la tua affinità musicale';

  @override
  String socialRequestsPreview(String name, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$name e altre $others persone vogliono connettersi',
      one: '$name e un\'altra persona vogliono connettersi',
      zero: '$name vuole connettersi con te',
    );
    return '$_temp0';
  }

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
  String get eventDetailMapSub => 'Posizione dell’evento';

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
      'Vibra legge il tuo profilo Spotify, i tuoi artisti, brani e generi più ascoltati degli ultimi ~6 mesi e gli orari dei tuoi ascolti recenti. Li usiamo per le statistiche musicali, i consigli sugli eventi e l\'affinità musicale. Le credenziali Spotify restano cifrate sui nostri server, mai su questo dispositivo. Puoi scollegare Spotify e cancellare questi dati in qualsiasi momento dalle Impostazioni.';

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

  @override
  String get matchTierHigh => 'Alta affinità';

  @override
  String get matchTierMedium => 'Buona affinità';

  @override
  String get matchTierLow => 'Affinità bassa';

  @override
  String get eventStatusUpcoming => 'In arrivo';

  @override
  String get eventStatusToday => 'Oggi';

  @override
  String get eventStatusSoldOut => 'Sold out';

  @override
  String get eventStatusCancelled => 'Annullato';

  @override
  String get eventStatusPostponed => 'Rinviato';

  @override
  String get eventStatusPast => 'Concluso';

  @override
  String eventPriceFrom(String price) {
    return 'Da $price';
  }

  @override
  String get offlineTitle => 'Sei offline';

  @override
  String get homeSpotifyBannerTitle => 'Collega il tuo sound';

  @override
  String get homeUpNext => 'IN ARRIVO';

  @override
  String get homeSpotifyConnectedTitle => 'Spotify collegato';

  @override
  String get spotifyConsentSharing =>
      'Le persone con l\'affinità musicale attiva vedono solo il punteggio di affinità e gli artisti e i generi che avete in comune, mai la tua cronologia d\'ascolto.';

  @override
  String get spotifySyncFailedTitle =>
      'Spotify è collegato, ma la tua musica non è ancora stata caricata.';

  @override
  String get spotifySyncRetry => 'Riprova sincronizzazione';

  @override
  String get spotifyRevokedBody =>
      'L\'accesso di Vibra è stato rimosso dal tuo account Spotify: lo abbiamo scollegato e abbiamo cancellato i dati sincronizzati. Ricollegalo per ripristinare statistiche e affinità.';

  @override
  String get spotifyRateLimited =>
      'Spotify è occupato in questo momento. Riprova tra un minuto.';

  @override
  String get settingsSpotifyDisconnectError =>
      'Non è stato possibile scollegare Spotify. Riprova.';

  @override
  String get socialConnectSpotifyBody =>
      'Collega Spotify per conoscere persone che ascoltano la musica che ami.';

  @override
  String socialAffinityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone condividono i tuoi gusti',
      one: '1 persona condivide i tuoi gusti',
      zero: 'Ancora nessuna nuova affinità',
    );
    return '$_temp0';
  }

  @override
  String get spotifyAccessNotGranted =>
      'Spotify non ha ancora abilitato Vibra per il tuo account. Il resto di Vibra funziona normalmente; riprova a collegarlo più tardi.';

  @override
  String get spotifyConnectFailed =>
      'Spotify non ha completato il collegamento. Riprova tra poco.';

  @override
  String get settingsSectionMusic => 'Musica';

  @override
  String get settingsSectionGeneral => 'Generali';

  @override
  String get settingsSectionHelp => 'Assistenza';

  @override
  String get settingsSectionLegal => 'Informazioni legali';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsDeleteAccountSub =>
      'Elimina definitivamente account e dati';

  @override
  String get settingsEditProfileSub => 'Nome, foto, bio e username';

  @override
  String settingsVersion(String version, String build) {
    return 'Versione $version ($build)';
  }

  @override
  String get profileStatEvents => 'Eventi';

  @override
  String get profileSpotifyBenefits => 'Statistiche · Affinità · Per te';

  @override
  String get appearanceAuto => 'Automatico';

  @override
  String get affinityCategoryExceptional => 'Affinità musicale eccezionale';

  @override
  String get affinityCategoryVeryHigh => 'Affinità molto alta';

  @override
  String get affinityCategoryHigh => 'Affinità alta';

  @override
  String get affinityCategoryModerate => 'Affinità moderata';

  @override
  String get affinityCategoryLow => 'Suoni diversi';

  @override
  String get affinityCategoryVeryLow => 'Nuovi mondi musicali';

  @override
  String affinityHeadline(int percent) {
    return '$percent% di affinità musicale';
  }

  @override
  String get affinitySharedGenres => 'I vostri generi in comune';

  @override
  String get affinityTheirGenres => 'I suoi generi principali';

  @override
  String get affinityArtistsInCommon => 'Artisti in comune';

  @override
  String get affinityWhy => 'Perché siete affini';

  @override
  String get affinityQuoteExceptional =>
      'Sembra che ascoltiate la musica con le stesse orecchie.';

  @override
  String get affinityQuoteVeryHigh =>
      'I vostri gusti musicali hanno moltissimo in comune.';

  @override
  String get affinityQuoteHigh =>
      'I vostri gusti musicali hanno molto in comune.';

  @override
  String get affinityQuoteModerate =>
      'Avete alcuni suoni in comune e altri da scoprire.';

  @override
  String get affinityQuoteDiscovery =>
      'Mondi diversi: un’occasione per scoprire musica nuova.';

  @override
  String affinityReasonSharedFamilies(String genres) {
    return 'Entrambi ascoltate soprattutto $genres.';
  }

  @override
  String affinityReasonSharedSubgenres(String genres) {
    return 'Condividete la passione per $genres.';
  }

  @override
  String affinityReasonDifferentSubgenres(String genre) {
    return 'Amate entrambi il genere $genre, ma preferite sottogeneri diversi.';
  }

  @override
  String affinityReasonRelatedFamilies(String first, String second) {
    return '$first e $second sono mondi musicali vicini.';
  }

  @override
  String affinityReasonSharedArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Condividete $count artisti preferiti.',
      one: 'Condividete 1 artista preferito.',
    );
    return '$_temp0';
  }

  @override
  String get affinityReasonDiscovery =>
      'Gusti diversi: un buon modo per scoprire musica nuova.';

  @override
  String get affinityListSeparator => ' e ';

  @override
  String get genreFamilyHipHop => 'Hip-Hop';

  @override
  String get genreFamilyRnb => 'R&B';

  @override
  String get genreFamilyElectronic => 'Elettronica';

  @override
  String get genreFamilyRock => 'Rock';

  @override
  String get genreFamilyMetal => 'Metal';

  @override
  String get genreFamilyPunk => 'Punk';

  @override
  String get genreFamilyPop => 'Pop';

  @override
  String get genreFamilyJazz => 'Jazz';

  @override
  String get genreFamilyBlues => 'Blues';

  @override
  String get genreFamilyReggae => 'Reggae';

  @override
  String get genreFamilyLatin => 'Latina';

  @override
  String get genreFamilyAfro => 'Afro';

  @override
  String get genreFamilyCountry => 'Country';

  @override
  String get genreFamilyFolk => 'Folk';

  @override
  String get genreFamilyClassical => 'Classica';

  @override
  String get genreFamilySoundtrack => 'Colonne sonore';

  @override
  String get genreFamilyGospel => 'Gospel e cristiana';

  @override
  String get genreFamilyWorld => 'World music';

  @override
  String get musicGenresTitle => 'I tuoi generi';

  @override
  String get musicGenresSubtitle =>
      'Scegli i generi che ami: ci aiutano a trovare persone con gusti affini, con o senza Spotify.';

  @override
  String get musicGenresSpotifyNote =>
      'Spotify è collegato: questi generi si aggiungono a quelli dei tuoi ascolti.';

  @override
  String get musicGenresSearchHint => 'Cerca un genere';

  @override
  String get musicGenresNoResults => 'Nessun genere trovato';

  @override
  String musicGenresSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count generi scelti',
      one: '1 genere scelto',
      zero: 'Nessun genere scelto',
    );
    return '$_temp0';
  }

  @override
  String get musicGenresYourPicks => 'Le tue scelte';

  @override
  String get musicGenresLevelLike => 'Mi piace';

  @override
  String get musicGenresLevelMuch => 'Molto';

  @override
  String get musicGenresLevelLove => 'Lo adoro';

  @override
  String get musicGenresIntensityHint =>
      'Tocca un genere scelto per dire quanto ti piace.';

  @override
  String musicGenresRemove(String genre) {
    return 'Rimuovi $genre';
  }

  @override
  String get musicGenresLimit => 'Puoi scegliere fino a 30 generi.';

  @override
  String get musicGenresMatching => 'Mostrami alle persone con gusti affini';

  @override
  String get musicGenresMatchingBody =>
      'Vedranno solo il punteggio di affinità e i generi e gli artisti in comune.';

  @override
  String get musicGenresSave => 'Salva';

  @override
  String get musicGenresSaved =>
      'Generi salvati. Stiamo aggiornando le tue affinità.';

  @override
  String get musicGenresSaveError => 'Impossibile salvare i generi. Riprova.';

  @override
  String get musicGenresLoadError => 'Impossibile caricare i tuoi generi.';

  @override
  String get musicGenresEntry => 'Generi preferiti';

  @override
  String get musicGenresEntrySub =>
      'Scegli i generi che ami, anche senza Spotify';

  @override
  String get socialAffinityPickGenres => 'Oppure scegli i tuoi generi';

  @override
  String get socialAffinityPickGenresBody =>
      'Scegli i generi che ami per conoscere persone con gusti affini.';

  @override
  String get privacyMusicAffinity => 'Affinità musicale';

  @override
  String get privacyMusicAffinityBody =>
      'Usa i dati Spotify e i generi che scegli per suggerimenti e affinità.';

  @override
  String get musicalDnaTitle => 'DNA musicale';

  @override
  String get musicalDnaEyebrow => 'La tua identità musicale';

  @override
  String musicalDnaUserTitle(String name) {
    return 'DNA musicale di $name';
  }

  @override
  String get musicalDnaUserEyebrow => 'Identità musicale';

  @override
  String get musicalDnaDistribution => 'Distribuzione dei generi';

  @override
  String get musicalDnaDistributionSub =>
      'Come si divide il tuo gusto tra le famiglie di generi';

  @override
  String musicalDnaArtistsVia(String artists) {
    return 'Attraverso $artists';
  }

  @override
  String get musicalDnaDiversity => 'Varietà';

  @override
  String get musicalDnaDiversityFocused => 'Concentrato';

  @override
  String get musicalDnaDiversityBalanced => 'Equilibrato';

  @override
  String get musicalDnaDiversityEclectic => 'Eclettico';

  @override
  String get musicalDnaDiversityFocusedBody =>
      'La tua identità vive in pochi suoni vicini tra loro.';

  @override
  String get musicalDnaDiversityBalancedBody =>
      'Un nucleo chiaro, con spazio per altri mondi.';

  @override
  String get musicalDnaDiversityEclecticBody =>
      'Il tuo gusto si muove libero tra mondi molto diversi.';

  @override
  String musicalDnaDiversityCounts(String families, String subgenres) {
    return '$families famiglie · $subgenres sottogeneri';
  }

  @override
  String get musicalDnaEvolution => 'Evoluzione';

  @override
  String get musicalDnaEvolutionSub =>
      'Come cambia il tuo DNA insieme ai tuoi ascolti';

  @override
  String musicalDnaEvolutionEmpty(String date) {
    return 'Monitorato dal $date. Qui vedrai i cambiamenti man mano che i tuoi ascolti evolvono.';
  }

  @override
  String musicalDnaShiftSince(String date) {
    return 'Dal $date';
  }

  @override
  String get musicalDnaNoShift =>
      'Stabile: nessuna famiglia si è mossa di oltre 3 punti.';

  @override
  String musicalDnaShiftSemantics(String family, String from, String to) {
    return '$family, dal $from al $to per cento';
  }

  @override
  String get musicalDnaSources => 'Basato su';

  @override
  String musicalDnaSourceArtists(String classified, String total) {
    return '$classified dei tuoi $total artisti Spotify più ascoltati (ultimi 6 mesi)';
  }

  @override
  String get musicalDnaSourceSpotifyGenres =>
      'I generi dei tuoi artisti Spotify più ascoltati (ultimi 6 mesi)';

  @override
  String musicalDnaSourceTracks(String count) {
    return 'I tuoi $count brani Spotify più ascoltati';
  }

  @override
  String musicalDnaSourceGenres(String count) {
    return '$count generi scelti da te';
  }

  @override
  String get musicalDnaEditGenres => 'Modifica i tuoi generi';

  @override
  String get musicalDnaVisibility => 'Chi può vederlo';

  @override
  String get musicalDnaVisibilityPublic => 'Tutti';

  @override
  String get musicalDnaVisibilityMatches => 'Affinità';

  @override
  String get musicalDnaVisibilityPrivate => 'Solo io';

  @override
  String get musicalDnaVisibilityPublicBody =>
      'Chiunque su Vibra può vedere il tuo DNA musicale sul tuo profilo.';

  @override
  String get musicalDnaVisibilityMatchesBody =>
      'Solo le persone con cui hai un\'affinità musicale o un collegamento.';

  @override
  String get musicalDnaVisibilityPrivateBody =>
      'Lo vedi solo tu. Continua comunque a guidare i tuoi suggerimenti.';

  @override
  String get musicalDnaVisibilityError =>
      'Impossibile salvare la scelta. Riprova.';

  @override
  String get musicalDnaEmptyTitle => 'Nessun DNA musicale per ora';

  @override
  String get musicalDnaEmptyBody =>
      'Collega Spotify o scegli qualche genere che ami: il tuo DNA si costruisce da lì.';

  @override
  String get musicalDnaPickGenres => 'Scegli i generi';

  @override
  String get musicalDnaLoadError => 'Impossibile caricare il tuo DNA musicale.';

  @override
  String musicalDnaUpdated(String date) {
    return 'Aggiornato il $date';
  }

  @override
  String musicalDnaFamilySemantics(String family, String percent) {
    return '$family, $percent per cento';
  }

  @override
  String get musicalDnaProfileTile => 'DNA musicale';

  @override
  String get musicalDnaProfileTileSubtitle =>
      'I tuoi generi, la tua varietà e come evolvono';

  @override
  String get musicalDnaSeeFull => 'Vedi DNA completo';

  @override
  String affinityReasonCommonGround(String genres) {
    return 'Ascoltate entrambi $genres, in quantità diverse.';
  }

  @override
  String get affinityReasonBothEclectic =>
      'Siete entrambi ascoltatori eclettici, tra generi molto diversi.';

  @override
  String get affinityReasonBothFocused =>
      'Restate entrambi vicini al vostro suono di riferimento.';

  @override
  String get affinityReasonDiversityContrast =>
      'Uno di voi esplora tanto, l\'altro resta concentrato: c\'è molto da scambiarsi.';

  @override
  String affinityHeadlineSentence(int percent) {
    return 'Tra voi c\'è un\'affinità musicale: $percent%.';
  }

  @override
  String get sameFrequencyTitle => 'Same Frequency';

  @override
  String get sameFrequencyHeadline => 'Siete sulla stessa frequenza.';

  @override
  String sameFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hai scoperto $count persone con una forte connessione musicale.',
      one: 'Hai scoperto 1 persona con una forte connessione musicale.',
      zero: 'Ancora nessuna connessione musicale forte.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyTabForYou => 'Per te';

  @override
  String get sameFrequencyTabSaved => 'Salvati';

  @override
  String get sameFrequencyEmptyTitle => 'Ancora nessuno sulla tua frequenza';

  @override
  String get sameFrequencyEmptyBody =>
      'Le persone compaiono qui quando Vibra trova chi condivide il tuo suono. Scegli altri generi o sincronizza Spotify per ampliare il segnale.';

  @override
  String get sameFrequencySavedEmptyTitle => 'Nessun profilo salvato';

  @override
  String get sameFrequencySavedEmptyBody =>
      'Salva le persone su cui vuoi tornare. Restano qui finché non le rimuovi.';

  @override
  String get sameFrequencySave => 'Salva';

  @override
  String get sameFrequencySaved => 'Salvato';

  @override
  String get sameFrequencySaveError =>
      'Impossibile aggiornare i profili salvati. Riprova.';

  @override
  String get sameFrequencyWhy => 'Perché siete sulla stessa frequenza';

  @override
  String sameFrequencyReasonDiscoveries(String artists) {
    return 'Avete scoperto da poco entrambi $artists.';
  }

  @override
  String sameFrequencyReasonDirection(String genres) {
    return 'Vi state muovendo entrambi verso $genres.';
  }

  @override
  String sameFrequencyReasonEvent(String event, String date) {
    return 'Andate entrambi a $event · $date.';
  }

  @override
  String sameFrequencyReasonEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Avete salvato $count eventi in comune.',
      one: 'Avete salvato 1 evento in comune.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyDiscoverArtists => 'Scopri gli artisti in comune';

  @override
  String sameFrequencySharedArtistsTitle(String name) {
    return 'Artisti che condividi con $name';
  }

  @override
  String get sameFrequencyFindEvents => 'Trova eventi';

  @override
  String get sameFrequencyEventsOptIn => 'Confronta gli eventi salvati';

  @override
  String get sameFrequencyEventsOptInBody =>
      'Trova chi va ai tuoi stessi concerti. Funziona solo con chi l\'ha attivato a sua volta; altrimenti i tuoi eventi salvati restano privati.';

  @override
  String get sameFrequencyEntryBody =>
      'Persone con cui hai una vera connessione musicale';

  @override
  String get sameFrequencyLoadError => 'Impossibile caricare Same Frequency.';

  @override
  String sameFrequencyPersonSemantics(String name, String percent) {
    return '$name, affinità musicale del $percent per cento';
  }

  @override
  String get musicRadarTitle => 'Music Radar';

  @override
  String get musicRadarHeadline =>
      'Persone vicino a te che condividono i tuoi gusti musicali.';

  @override
  String musicRadarCount(int count, int distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone compatibili entro $distance km.',
      one: '1 persona compatibile entro $distance km.',
      zero: 'Ancora nessuna persona compatibile entro $distance km.',
    );
    return '$_temp0';
  }

  @override
  String get musicRadarAreaSound => 'Il suono della tua zona';

  @override
  String get musicRadarAreaSoundSub => 'Cosa si ascolta di più qui intorno';

  @override
  String get musicRadarAreaTooFew =>
      'Visibile quando abbastanza persone vicine usano il radar.';

  @override
  String get musicRadarPeople => 'Profili compatibili';

  @override
  String get musicRadarEvents => 'Prossimi eventi per il tuo suono';

  @override
  String get musicRadarEventYourArtist => 'Uno dei tuoi artisti';

  @override
  String get musicRadarEventSharedArtist =>
      'Un artista che condividi con persone vicine';

  @override
  String get musicRadarEventYourGenre => 'I tuoi generi';

  @override
  String get musicRadarEventAreaGenre => 'Popolare nella tua zona';

  @override
  String get musicRadarIntroTitle =>
      'Scopri persone vicine attraverso la musica';

  @override
  String get musicRadarIntroBody =>
      'Music Radar mostra le persone intorno a te con gusti simili. Resta spento finché non lo attivi.';

  @override
  String get musicRadarPrivacy1 =>
      'Nessuno vede la tua posizione né la tua distanza: solo che sei nel suo raggio.';

  @override
  String get musicRadarPrivacy2 =>
      'La tua posizione è arrotondata a un\'area di circa 5 km (o 20 km) e si sposta al massimo ogni 6 ore.';

  @override
  String get musicRadarPrivacy3 =>
      'Puoi nascondere il profilo, cambiare la distanza o spegnere il radar quando vuoi.';

  @override
  String get musicRadarTurnOn => 'Attiva Music Radar';

  @override
  String get musicRadarLocationTitle => 'Serve la posizione';

  @override
  String get musicRadarLocationBody =>
      'Music Radar usa la tua posizione approssimativa. Attiva la posizione nei Controlli privacy, poi torna qui.';

  @override
  String get musicRadarOpenPrivacy => 'Apri controlli privacy';

  @override
  String get musicRadarMatchingNote =>
      'Attiva Affinità musicale nei Controlli privacy per vedere le persone compatibili.';

  @override
  String get musicRadarSettings => 'Impostazioni radar';

  @override
  String get musicRadarEnabled => 'Music Radar';

  @override
  String get musicRadarVisible => 'Mostrami sul radar';

  @override
  String get musicRadarVisibleBody =>
      'Se spento, puoi comunque guardarti intorno, ma nessuno ti vede.';

  @override
  String get musicRadarDistance => 'Distanza di scoperta';

  @override
  String musicRadarDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get musicRadarPrecision => 'Precisione della posizione';

  @override
  String get musicRadarPrecisionArea => 'Area (~5 km)';

  @override
  String get musicRadarPrecisionRegion => 'Regione (~20 km)';

  @override
  String get musicRadarPrecisionBody =>
      'Quanto approssimativamente vieni collocato rispetto agli altri. La posizione esatta non viene mai condivisa.';

  @override
  String get musicRadarSaveError =>
      'Impossibile salvare l\'impostazione. Riprova.';

  @override
  String get musicRadarLoadError => 'Impossibile caricare Music Radar.';

  @override
  String get musicRadarEntryBody => 'Persone vicine con i tuoi gusti';

  @override
  String get musicRadarEmptyPeople =>
      'Nessuna persona compatibile qui vicino al momento. Prova una distanza maggiore o riprova più tardi.';

  @override
  String get communitiesTitle => 'Community';

  @override
  String get communitiesEntryBody => 'Generi, artisti e scene che ami';

  @override
  String get communitiesSearchHint => 'Cerca community o artisti';

  @override
  String get communitiesForYou => 'Per te';

  @override
  String get communitiesForYouSub => 'In base al tuo profilo musicale';

  @override
  String get communitiesMine => 'Le tue community';

  @override
  String get communitiesExplore => 'Esplora';

  @override
  String get communitiesEmptySearch =>
      'Nessuna community corrisponde alla ricerca.';

  @override
  String communitiesRecommendation(String name) {
    return 'In base al tuo profilo musicale, potrebbe piacerti $name.';
  }

  @override
  String communitiesReasonArtist(String artist) {
    return '$artist è uno dei tuoi artisti più ascoltati.';
  }

  @override
  String communitiesReasonGenre(String genre, int percent) {
    return '$genre è il $percent% del tuo DNA musicale.';
  }

  @override
  String communitiesStartArtist(String artist) {
    return 'Avvia la community di $artist';
  }

  @override
  String get communitiesStartArtistBody =>
      'Uno dei tuoi artisti preferiti non ha ancora una community.';

  @override
  String communitiesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get communitiesOfficial => 'Ufficiale';

  @override
  String get communitiesKindGenre => 'Genere';

  @override
  String get communitiesKindArtist => 'Artista';

  @override
  String get communitiesKindInterest => 'Interesse';

  @override
  String get communitiesJoin => 'Unisciti';

  @override
  String get communitiesJoined => 'Iscritto';

  @override
  String get communitiesLeave => 'Esci';

  @override
  String communitiesLeaveConfirm(String name) {
    return 'Uscire da $name?';
  }

  @override
  String get communitiesCreate => 'Crea una community';

  @override
  String get communitiesCreateName => 'Nome';

  @override
  String get communitiesCreateDescription => 'Descrizione (facoltativa)';

  @override
  String get communitiesCreateArtist => 'Artista';

  @override
  String get communitiesCreateGenre => 'Genere';

  @override
  String get communitiesCreateAction => 'Crea';

  @override
  String get communitiesTabPosts => 'Post';

  @override
  String get communitiesTabDiscussions => 'Discussioni';

  @override
  String get communitiesTabEvents => 'Eventi';

  @override
  String get communitiesTabMembers => 'Membri';

  @override
  String get communitiesNewPost => 'Nuovo post';

  @override
  String get communitiesComposerPost => 'Post';

  @override
  String get communitiesComposerDiscussion => 'Discussione';

  @override
  String get communitiesComposerMusic => 'Condividi musica';

  @override
  String get communitiesComposerBodyHint => 'A cosa stai pensando?';

  @override
  String get communitiesComposerTitleHint => 'Tema della discussione';

  @override
  String get communitiesComposerLinkHint =>
      'Link Spotify, Apple Music, YouTube, SoundCloud o Bandcamp';

  @override
  String get communitiesComposerTrackHint => 'Brano o album (facoltativo)';

  @override
  String get communitiesComposerArtistHint => 'Artista (facoltativo)';

  @override
  String get communitiesPublish => 'Pubblica';

  @override
  String get communitiesJoinToPost =>
      'Unisciti per pubblicare, commentare e reagire.';

  @override
  String get communitiesEmptyFeed =>
      'Ancora nessun post. Inizia tu la conversazione.';

  @override
  String get communitiesEmptyDiscussions => 'Ancora nessuna discussione.';

  @override
  String get communitiesEmptyEvents =>
      'Nessun evento in programma per questa community.';

  @override
  String communitiesComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commenti',
      one: '1 commento',
      zero: 'Commenta',
    );
    return '$_temp0';
  }

  @override
  String get communitiesCommentHint => 'Aggiungi un commento';

  @override
  String get communitiesEmptyComments => 'Ancora nessun commento.';

  @override
  String get communitiesOpenMusic => 'Ascolta';

  @override
  String get communitiesHeld =>
      'Nascosto mentre i moderatori esaminano le segnalazioni';

  @override
  String get communitiesDelete => 'Elimina';

  @override
  String get communitiesRemove => 'Rimuovi (moderatore)';

  @override
  String get communitiesRestore => 'Ripristina';

  @override
  String get communitiesBan => 'Escludi dalla community';

  @override
  String communitiesBanConfirm(String name) {
    return 'Escludere $name da questa community?';
  }

  @override
  String get communitiesMakeModerator => 'Rendi moderatore';

  @override
  String get communitiesRemoveModerator => 'Rimuovi moderatore';

  @override
  String get communitiesRoleOwner => 'Proprietario';

  @override
  String get communitiesRoleModerator => 'Moderatore';

  @override
  String get communitiesModeration => 'Moderazione';

  @override
  String get communitiesModerationEmpty => 'Niente da esaminare.';

  @override
  String communitiesReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segnalazioni',
      one: '1 segnalazione',
    );
    return '$_temp0';
  }

  @override
  String get communitiesReported => 'Grazie, i moderatori la esamineranno.';

  @override
  String get communitiesError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get communitiesErrorRate =>
      'Stai andando troppo veloce. Aspetta un momento.';

  @override
  String get communitiesErrorSpam =>
      'Sembra spam: troppi link, un link sospetto o un contenuto ripetuto.';

  @override
  String get communitiesErrorBanned => 'Sei stato escluso da questa community.';

  @override
  String get communitiesErrorLink =>
      'Usa un link Spotify, Apple Music, YouTube, SoundCloud o Bandcamp.';

  @override
  String get communitiesErrorExists =>
      'Esiste già una community per questo artista.';

  @override
  String get communitiesErrorLimit => 'Hai raggiunto il limite di oggi.';

  @override
  String get communitiesLoadError => 'Impossibile caricare le community.';

  @override
  String sameFrequencyReasonCommunities(String communities) {
    return 'Siete entrambi in $communities.';
  }

  @override
  String get musicRadarCommunities => 'Community per il suono della tua zona';

  @override
  String get circlesTitle => 'Circle';

  @override
  String get circlesSubtitle => 'Piccoli gruppi per la musica che ami';

  @override
  String get circlesInvitations => 'Inviti';

  @override
  String circlesInvitedBy(String name) {
    return '$name ti ha invitato';
  }

  @override
  String get circlesAccept => 'Accetta';

  @override
  String get circlesDecline => 'Rifiuta';

  @override
  String get circlesInviteDeclined => 'Invito rifiutato';

  @override
  String get circlesSuggested => 'VIBRA suggerisce';

  @override
  String circlesSuggestionGenre(int count, String genre) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un circle di $count persone che condividono $genre.',
    );
    return '$_temp0';
  }

  @override
  String circlesSuggestionArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un circle di $count persone che ascoltano tutte $artist.',
    );
    return '$_temp0';
  }

  @override
  String get circlesSuggestionConsent =>
      'Ogni persona riceve un invito e decide se unirsi.';

  @override
  String get circlesCreateAndInvite => 'Crea e invita';

  @override
  String circlesSuggestionName(String topic) {
    return 'Circle $topic';
  }

  @override
  String circlesInvitesSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Circle creato. $count inviti inviati.',
      one: 'Circle creato. 1 invito inviato.',
      zero: 'Circle creato. Non è stato possibile inviare inviti.',
    );
    return '$_temp0';
  }

  @override
  String get circlesMine => 'I tuoi circle';

  @override
  String get circlesEmptyTitle => 'Ancora nessun circle';

  @override
  String get circlesEmptyBody =>
      'Crea un piccolo gruppo attorno a un genere, un artista o un concerto e invita persone che conosci.';

  @override
  String get circlesCreate => 'Nuovo circle';

  @override
  String get circlesBasisGenre => 'Genere';

  @override
  String get circlesBasisArtist => 'Artista';

  @override
  String get circlesBasisConcert => 'Concerto';

  @override
  String get circlesBasisInterest => 'Interesse';

  @override
  String get circlesBasisActivity => 'Attività';

  @override
  String get circlesName => 'Nome';

  @override
  String get circlesDescription => 'Descrizione (facoltativa)';

  @override
  String get circlesTopic => 'Tema';

  @override
  String get circlesNoSavedEvents =>
      'Salva prima un evento per creare un circle attorno a esso.';

  @override
  String get circlesCreateAction => 'Crea';

  @override
  String circlesMembers(int count, int max) {
    return '$count/$max membri';
  }

  @override
  String get circlesTabChat => 'Chat';

  @override
  String get circlesTabPlaylist => 'Playlist';

  @override
  String get circlesTabEvents => 'Eventi';

  @override
  String get circlesTabMembers => 'Membri';

  @override
  String get circlesMessageHint => 'Scrivi al circle';

  @override
  String get circlesChatEmpty => 'Saluta il tuo circle.';

  @override
  String get circlesPlaylistEmpty => 'Ancora nessun brano. Aggiungi il primo.';

  @override
  String get circlesAddTrack => 'Aggiungi un brano';

  @override
  String get circlesEventsEmpty => 'Ancora nessun evento condiviso.';

  @override
  String get circlesShareEvent => 'Condividi un evento';

  @override
  String get circlesInvite => 'Invita persone';

  @override
  String get circlesInviteHint =>
      'Puoi invitare i tuoi collegamenti e le persone con cui hai un\'affinità musicale. Sono loro a decidere se unirsi.';

  @override
  String get circlesInviteNone => 'Nessun altro da invitare al momento.';

  @override
  String get circlesInviteSend => 'Invia inviti';

  @override
  String get circlesPending => 'Invitato';

  @override
  String get circlesRevoke => 'Annulla invito';

  @override
  String get circlesAdmin => 'Admin';

  @override
  String get circlesMakeAdmin => 'Rendi admin';

  @override
  String get circlesRemoveMember => 'Rimuovi dal circle';

  @override
  String get circlesMute => 'Silenzia notifiche';

  @override
  String get circlesUnmute => 'Riattiva notifiche';

  @override
  String get circlesEdit => 'Modifica circle';

  @override
  String get circlesLeave => 'Esci dal circle';

  @override
  String circlesLeaveConfirm(String name) {
    return 'Uscire da $name?';
  }

  @override
  String get circlesSave => 'Salva';

  @override
  String get circlesError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get circlesErrorFull => 'Questo circle è al completo.';

  @override
  String get circlesErrorNotAllowed =>
      'Puoi invitare solo i tuoi collegamenti o le persone con cui hai un\'affinità musicale.';

  @override
  String get circlesErrorDeclined =>
      'Questa persona ha rifiutato di recente. Riprova più avanti.';

  @override
  String get circlesLoadError => 'Impossibile caricare i circle.';

  @override
  String get circlesRemove => 'Rimuovi';

  @override
  String get concertTitle => 'Concert Finder';

  @override
  String get concertHeadline => 'Potrebbero piacerti questi prossimi eventi.';

  @override
  String get concertWhy => 'Perché te lo consigliamo';

  @override
  String concertReasonTopArtist(String artist, int rank) {
    return '$artist è #$rank tra i tuoi artisti più ascoltati.';
  }

  @override
  String concertReasonTrackArtist(String artist) {
    return '$artist è nei tuoi brani più ascoltati.';
  }

  @override
  String concertReasonSavedArtist(String artist) {
    return 'Hai salvato un altro evento di $artist.';
  }

  @override
  String concertReasonGenre(String genre, int percent) {
    return '$genre è il $percent% del tuo DNA musicale.';
  }

  @override
  String concertReasonSimilarToSaved(String genre) {
    return 'Come altri eventi $genre che hai salvato.';
  }

  @override
  String concertReasonDistance(int km) {
    return 'A $km km da te.';
  }

  @override
  String concertReasonSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tra $days giorni.',
      one: 'Domani.',
      zero: 'Oggi.',
    );
    return '$_temp0';
  }

  @override
  String get concertFilterGenre => 'Genere';

  @override
  String get concertFilterAll => 'Tutti';

  @override
  String get concertArtistHint => 'Cerca un artista';

  @override
  String get concertFilterDate => 'Quando';

  @override
  String get concertDateAny => 'Qualsiasi data';

  @override
  String get concertDateWeek => 'Prossimi 7 giorni';

  @override
  String get concertDateMonth => 'Prossimi 30 giorni';

  @override
  String get concertDate3Months => 'Prossimi 3 mesi';

  @override
  String get concertFilterDistance => 'Distanza';

  @override
  String get concertDistanceAny => 'Qualsiasi distanza';

  @override
  String concertDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get concertFilterPrice => 'Prezzo';

  @override
  String get concertPriceAny => 'Qualsiasi prezzo';

  @override
  String concertPriceUpTo(String price) {
    return 'Fino a $price';
  }

  @override
  String get concertPriceNote =>
      'Solo eventi con un prezzo pubblicato in euro.';

  @override
  String get concertEmpty =>
      'Nessun evento consigliato corrisponde a questi filtri.';

  @override
  String get concertEmptyBody =>
      'Prova una distanza maggiore, un\'altra data o meno filtri.';

  @override
  String get concertNoProfileTitle => 'Dicci cosa ascolti';

  @override
  String get concertNoProfileBody =>
      'Collega Spotify o scegli qualche genere per ricevere consigli sui concerti.';

  @override
  String get concertLocationNote =>
      'Attiva la posizione per vedere distanze ed eventi vicini.';

  @override
  String get concertLoadError => 'Impossibile caricare i consigli.';

  @override
  String get concertSaved => 'Salvato';

  @override
  String get eventDetailInterested => 'Mi interessa';

  @override
  String get eventDetailAttendanceInterested => 'Salvato tra gli interessi';

  @override
  String get eventDetailAttendanceRemoved => 'Rimosso dai tuoi eventi';

  @override
  String get whosGoingTitle => 'Chi ci va?';

  @override
  String get whosGoingSubtitle =>
      'Persone che hanno scelto di condividere i loro piani con te';

  @override
  String whosGoingGoing(int count) {
    return '$count ci vanno';
  }

  @override
  String whosGoingMaybe(int count) {
    return '$count forse';
  }

  @override
  String whosGoingInterested(int count) {
    return '$count interessati';
  }

  @override
  String get whosGoingFriends => 'Amici';

  @override
  String get whosGoingCompatible => 'Persone compatibili';

  @override
  String get whosGoingOthers => 'Altri';

  @override
  String get whosGoingEmpty =>
      'Nessuno che puoi vedere ha condiviso piani per questo evento.';

  @override
  String get whosGoingPrivacyNote =>
      'Vedi solo chi ha scelto di condividere i suoi piani con te. I tuoi seguono la scelta qui sotto.';

  @override
  String get whosGoingCommunities => 'Community per questo evento';

  @override
  String whosGoingAffinity(int percent) {
    return '$percent% di affinità';
  }

  @override
  String get whosGoingRequested => 'Richiesta inviata';

  @override
  String get attendanceVisibility => 'Chi può vedere i tuoi piani';

  @override
  String get visibilityPrivate => 'Solo io';

  @override
  String get visibilityFriends => 'Amici';

  @override
  String get visibilityMatches => 'Amici e affinità';

  @override
  String get visibilityPublic => 'Tutti';

  @override
  String get attendanceVisibilityDefault => 'Usa per tutti i miei eventi';

  @override
  String get attendanceVisibilityHint =>
      'Gli altri vedono i tuoi piani solo se lo permetti. Tu vedi comunque chi condivide i propri.';

  @override
  String get attendanceVisibilitySaved => 'Visibilità aggiornata';

  @override
  String get concertMatchTitle => 'Concert Match';

  @override
  String concertMatchHeadlineMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu e altre $count persone siete interessati a questo concerto.',
      one: 'Tu e un\'altra persona siete interessati a questo concerto.',
      zero: 'Sei il primo che puoi vedere. Qui sotto chi ama questo artista.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchHeadlineOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count persone che puoi vedere sono interessate a questo concerto.',
      one: '1 persona che puoi vedere è interessata a questo concerto.',
      zero:
          'Nessuno che puoi vedere ha ancora condiviso piani per questo concerto.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchFan(String artist) {
    return 'Ama anche $artist';
  }

  @override
  String concertMatchCreateGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crea gruppo evento ($count)',
      zero: 'Crea gruppo evento',
    );
    return '$_temp0';
  }

  @override
  String get concertMatchGroupNote =>
      'Le persone entrano solo se accettano il tuo invito. La posizione e i piani di viaggio di nessuno vengono condivisi.';

  @override
  String get concertMatchShare => 'Condividi in un circle';

  @override
  String get concertMatchShared => 'Evento condiviso con il circle';

  @override
  String concertMatchSharedMessage(String event, String date) {
    return 'Ha condiviso un evento: $event · $date';
  }

  @override
  String get concertMatchNoCircles => 'Non hai ancora circle.';

  @override
  String get concertMatchEmpty => 'Ancora nessun match per questo concerto.';

  @override
  String get concertMatchSelectHint =>
      'Seleziona le persone da invitare in un gruppo evento';

  @override
  String get circlePlans => 'Piani';

  @override
  String get circlePlansEmpty =>
      'Ancora nessun piano. Proponine uno: cena, aperitivo prima del concerto, un punto d\'incontro.';

  @override
  String get circleAddPlan => 'Aggiungi un piano';

  @override
  String get circlePlanTitle => 'Cosa';

  @override
  String get circlePlanWhen => 'Quando (facoltativo)';

  @override
  String get circlePlanNote => 'Dettagli (facoltativi)';

  @override
  String get circlePlanIn => 'Ci sono';

  @override
  String get circlePlanJoined => 'Ci sei';

  @override
  String circlePlanPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipano',
      one: '1 partecipa',
    );
    return '$_temp0';
  }

  @override
  String get circlePlanPrivacy => 'Solo i membri del circle vedono i piani.';

  @override
  String get groupConcert => 'Il concerto';

  @override
  String get groupYourStatus => 'Il tuo stato';

  @override
  String get groupStatusHint => 'Lo vedono solo i membri di questo gruppo.';

  @override
  String get groupHeld => 'Nascosto mentre gli admin esaminano le segnalazioni';

  @override
  String get groupRemoveAdmin => 'Rimuovi (admin)';

  @override
  String get groupBan => 'Escludi dal gruppo';

  @override
  String groupBanConfirm(String name) {
    return 'Escludere $name da questo gruppo? Non potrà più rientrare.';
  }

  @override
  String get groupErrorBanned =>
      'Questa persona non può essere invitata in questo gruppo.';

  @override
  String get groupYourGroups => 'I tuoi gruppi per questo evento';

  @override
  String get groupStart => 'Crea un gruppo concerto';

  @override
  String get groupReportMember => 'Segnala membro';

  @override
  String get vibeTitle => 'Daily Vibe';

  @override
  String get vibeQuestion => 'Qual è il tuo vibe oggi?';

  @override
  String get vibeShare => 'Condividi il tuo vibe';

  @override
  String get vibeChange => 'Cambia il vibe di oggi';

  @override
  String get vibeSearchHint => 'Cerca un brano su Spotify';

  @override
  String get vibeTabSpotify => 'Spotify';

  @override
  String get vibeTabLink => 'Altro link';

  @override
  String get vibeLinkHint => 'Link Apple Music, YouTube, SoundCloud o Bandcamp';

  @override
  String get vibeTitleHint => 'Titolo del brano';

  @override
  String get vibeArtistHint => 'Artista';

  @override
  String get vibeCaptionHint => 'Aggiungi una didascalia (facoltativa)';

  @override
  String get vibeExpires => 'Scompare dopo 24 ore';

  @override
  String get vibeEveryone => 'Visibile a tutti';

  @override
  String get vibeVisibilityBody =>
      'Disattivato: lo vedono solo i tuoi collegamenti e le tue affinità musicali.';

  @override
  String get vibePost => 'Pubblica vibe';

  @override
  String get vibePosted => 'Il tuo vibe è online';

  @override
  String get vibeEmptyTitle => 'Ancora nessun vibe oggi';

  @override
  String get vibeEmptyBody =>
      'Condividi il tuo, e collegati o segui persone per vedere i loro.';

  @override
  String get vibeListen => 'Ascolta su Spotify';

  @override
  String get vibeOpen => 'Apri link';

  @override
  String get vibeSave => 'Aggiungi alle scoperte';

  @override
  String get vibeSaved => 'Nelle tue scoperte';

  @override
  String vibeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commenti',
      one: '1 commento',
      zero: 'Commenta',
    );
    return '$_temp0';
  }

  @override
  String get vibeCommentHint => 'Aggiungi un commento';

  @override
  String get vibeReply => 'Rispondi';

  @override
  String vibeReplyingTo(String name) {
    return 'Rispondi a $name';
  }

  @override
  String vibeExpiresIn(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours h rimaste',
      one: '1 h rimasta',
      zero: 'Meno di 1 h',
    );
    return '$_temp0';
  }

  @override
  String get vibeDelete => 'Elimina il mio vibe';

  @override
  String get vibeSearchEmpty => 'Nessun brano trovato.';

  @override
  String get vibeProviderUnavailable =>
      'La ricerca Spotify non è disponibile ora. Puoi incollare un link.';

  @override
  String get vibeError => 'Impossibile pubblicare il vibe. Riprova.';

  @override
  String get vibeAttribution => 'Info brano e copertina da Spotify';

  @override
  String get discoveriesTitle => 'Scoperte';

  @override
  String get discoveriesEmpty =>
      'Qui compaiono i brani che aggiungi da Daily Vibe, storie, post e community. Solo tu puoi vederli.';

  @override
  String get discoveriesSubtitle => 'Brani scoperti su VIBRA';

  @override
  String get vibeLoadError => 'Impossibile caricare Daily Vibe.';

  @override
  String get vibeHomeCta => 'Condividi il brano che è il tuo vibe di oggi';

  @override
  String get storyAdd => 'Aggiungi storia';

  @override
  String get storyYours => 'La tua storia';

  @override
  String get storyNew => 'Nuova storia musicale';

  @override
  String get storyKindNowPlaying => 'Sto ascoltando';

  @override
  String get storyKindArtist => 'Artista preferito';

  @override
  String get storyKindAlbum => 'Album consigliato';

  @override
  String get storyKindPlaylist => 'Playlist';

  @override
  String get storyKindConcertPhoto => 'Foto del concerto';

  @override
  String get storyKindOpinion => 'Opinione musicale';

  @override
  String get storyAttribution => 'Info e copertine da Spotify';

  @override
  String get storyPreview => 'Anteprima della storia';

  @override
  String get storySearchArtist => 'Cerca un artista su Spotify';

  @override
  String get storySearchAlbum => 'Cerca un album su Spotify';

  @override
  String get storySearchPlaylist => 'Cerca una playlist pubblica su Spotify';

  @override
  String get storySearchEmpty => 'Nessun risultato.';

  @override
  String get storyArtistNameHint => 'Nome dell\'artista';

  @override
  String get storyAlbumTitleHint => 'Titolo dell\'album';

  @override
  String get storyPlaylistTitleHint => 'Nome della playlist';

  @override
  String get storyPlaylistOwnerHint => 'Creata da (facoltativo)';

  @override
  String get storyPickPhoto => 'Scegli una foto del concerto';

  @override
  String get storyChangePhoto => 'Cambia foto';

  @override
  String get storyPhotoPrivacy =>
      'Posizione e dati della fotocamera vengono rimossi dalla foto prima della condivisione.';

  @override
  String get storyTagConcert => 'Concerto (facoltativo)';

  @override
  String get storyNoConcert => 'Nessun concerto';

  @override
  String get storyOpinionHint =>
      'La tua opinione: un album, una scena, un brano…';

  @override
  String get storyBackground => 'Sfondo';

  @override
  String get storyAudience => 'Chi può vederla';

  @override
  String get storyDefaultAudience => 'Chi vede le tue storie in automatico';

  @override
  String get storyAudienceConnections => 'Collegamenti';

  @override
  String get storyAudienceEveryone => 'Tutti';

  @override
  String get storyAudienceConnectionsBody =>
      'I tuoi collegamenti e le tue affinità musicali.';

  @override
  String get storyAudienceEveryoneBody =>
      'Anche chi ti segue. Le persone bloccate e chi hai escluso non la vedono mai.';

  @override
  String get storyAllowReplies => 'Consenti risposte';

  @override
  String get storyAllowRepliesBody =>
      'Le risposte sono private: le vedete solo tu e chi risponde.';

  @override
  String get storyExpires => 'Scompare dopo 24 ore.';

  @override
  String get storyShare => 'Condividi storia';

  @override
  String get storyPosted => 'La tua storia è online per 24 ore';

  @override
  String get storyError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get storyRateLimited =>
      'Stai condividendo molto. Attendi un momento e riprova.';

  @override
  String get storySpam => 'Sembra spam. Rimuovi i link e riprova.';

  @override
  String get storyPhotoError =>
      'Questa foto non può essere usata. Scegli un JPG o PNG fino a 10 MB.';

  @override
  String get storySettingsTitle => 'Privacy delle storie';

  @override
  String get storyHideFrom => 'Nascondi le tue storie a';

  @override
  String get storyHideFromBody =>
      'Non vedranno le tue storie e non verranno avvisati.';

  @override
  String get storyHidden => 'Non vede le tue storie';

  @override
  String get storyNoConnections =>
      'Quando avrai dei collegamenti, qui potrai scegliere chi non vede le tue storie.';

  @override
  String get storyJustNow => 'ora';

  @override
  String storyMinutesAgo(int minutes) {
    return '$minutes min';
  }

  @override
  String storyHoursAgo(int hours) {
    return '$hours h';
  }

  @override
  String get storyPrevious => 'Storia precedente';

  @override
  String get storyNext => 'Storia successiva';

  @override
  String get storyMore => 'Altre opzioni';

  @override
  String get storyLoadError => 'Impossibile caricare queste storie.';

  @override
  String get storyGone =>
      'Queste storie sono scadute o non sono più disponibili.';

  @override
  String get storyHeld =>
      'Nascosta in revisione dopo alcune segnalazioni. Solo tu puoi vederla.';

  @override
  String storyReplyHint(String name) {
    return 'Rispondi a $name…';
  }

  @override
  String get storySendReply => 'Invia';

  @override
  String get storyReplySent => 'Risposta inviata in privato';

  @override
  String get storyRepliesOff =>
      'Le risposte sono disattivate per questa storia';

  @override
  String get storyRepliesOffMine =>
      'Le risposte sono disattivate per questa storia.';

  @override
  String storyViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visualizzazioni',
      one: '1 visualizzazione',
      zero: 'Nessuna visualizzazione',
    );
    return '$_temp0';
  }

  @override
  String storyReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte',
      one: '1 risposta',
      zero: 'Risposte',
    );
    return '$_temp0';
  }

  @override
  String storyReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reazioni',
      one: '1 reazione',
    );
    return '$_temp0';
  }

  @override
  String get storyInsightsPrivate =>
      'Solo tu vedi chi ha visualizzato e risposto.';

  @override
  String get storyNoViewers => 'Ancora nessuna visualizzazione.';

  @override
  String get storyNoReplies => 'Ancora nessuna risposta.';

  @override
  String storyAnswerHint(String name) {
    return 'Rispondi a $name in privato…';
  }

  @override
  String get storyMakeEveryone => 'Mostra a tutti';

  @override
  String get storyMakeConnectionsOnly => 'Mostra solo ai collegamenti';

  @override
  String get storyNowEveryone => 'Ora tutti possono vedere questa storia';

  @override
  String get storyNowConnections =>
      'Ora solo i tuoi collegamenti vedono questa storia';

  @override
  String get storyTurnRepliesOff => 'Disattiva risposte';

  @override
  String get storyTurnRepliesOn => 'Attiva risposte';

  @override
  String get storyDelete => 'Elimina storia';

  @override
  String get storyDeleted => 'Storia eliminata';

  @override
  String storyMute(String name) {
    return 'Silenzia le storie di $name';
  }

  @override
  String storyMuted(String name) {
    return 'Non vedrai le storie di $name. Non riceverà alcun avviso.';
  }

  @override
  String get feedTitle => 'VIBRA Feed';

  @override
  String get feedHomeCta =>
      'Consigli, recensioni e scoperte dal tuo mondo musicale';

  @override
  String get feedForYou => 'Per te';

  @override
  String get feedFollowing => 'Seguiti';

  @override
  String get feedLatest => 'Più recenti';

  @override
  String get feedForYouBody =>
      'Ordinato in base a chi segui, ai tuoi collegamenti, alle community e alla musica che ami. Ogni post dice perché è qui.';

  @override
  String get feedFollowingBody =>
      'Dal più recente, da chi segui e dai tuoi collegamenti.';

  @override
  String get feedLatestBody => 'Dal più recente, tutti i post che puoi vedere.';

  @override
  String get feedCompose => 'Pubblica';

  @override
  String get feedNewPost => 'Nuovo post';

  @override
  String get feedPublish => 'Pubblica';

  @override
  String get feedPosted => 'Il tuo post è online';

  @override
  String get feedKindSong => 'Brano';

  @override
  String get feedKindAlbum => 'Album';

  @override
  String get feedKindPlaylist => 'Playlist';

  @override
  String get feedKindRecommendation => 'Consiglio';

  @override
  String get feedKindDiscovery => 'Scoperta';

  @override
  String get feedKindReview => 'Recensione';

  @override
  String get feedKindOpinion => 'Opinione';

  @override
  String get feedKindConcertPhoto => 'Foto del concerto';

  @override
  String get feedKindShare => 'Condiviso';

  @override
  String get feedItemTrack => 'Brano';

  @override
  String get feedItemAlbum => 'Album';

  @override
  String get feedItemArtist => 'Artista';

  @override
  String get feedItemPlaylist => 'Playlist';

  @override
  String get feedWhatAbout => 'Di cosa parla?';

  @override
  String get feedYourRating => 'Il tuo voto';

  @override
  String feedRatingLabel(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating stelle',
      one: '1 stella',
    );
    return '$_temp0';
  }

  @override
  String get feedReviewHint => 'Cosa ne pensi? Sii specifico.';

  @override
  String get feedDiscoveryHint => 'Come l\'hai scoperto?';

  @override
  String get feedRecommendationHint => 'Perché dovrebbero ascoltarlo?';

  @override
  String get feedBodyHint => 'Scrivi qualcosa (facoltativo)';

  @override
  String get feedAudienceEveryoneBody =>
      'Chiunque su VIBRA può vederlo, tranne le persone bloccate.';

  @override
  String get feedAllowComments => 'Consenti commenti';

  @override
  String get feedDuplicatePost => 'L\'hai già pubblicato oggi.';

  @override
  String get feedError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get feedLoadError => 'Impossibile caricare il feed.';

  @override
  String get feedEmptyTitle => 'Ancora niente qui';

  @override
  String get feedEmptyBody =>
      'Condividi un consiglio, oppure unisciti a community e segui persone per riempire il feed.';

  @override
  String get feedEmptyFollowing =>
      'Qui compaiono i post di chi segui e dei tuoi collegamenti.';

  @override
  String get feedEnd => 'Sei in pari';

  @override
  String get feedReasonFollowing => 'Segui questa persona';

  @override
  String get feedReasonConnection => 'Un tuo collegamento';

  @override
  String get feedReasonArtists => 'Un artista che ascolti';

  @override
  String get feedReasonGenres => 'Generi che ami';

  @override
  String get feedReasonCommunity => 'Dalle tue community';

  @override
  String get feedReasonMatch => 'Affinità musicale';

  @override
  String get feedReasonInteraction => 'Interagisci spesso con questa persona';

  @override
  String get feedReasonNew => 'Nuovo su VIBRA';

  @override
  String feedDaysAgo(int days) {
    return '$days g';
  }

  @override
  String get feedHeld =>
      'Nascosto in revisione dopo alcune segnalazioni. Solo tu puoi vederlo.';

  @override
  String get feedLike => 'Mi piace';

  @override
  String get feedUnlike => 'Togli mi piace';

  @override
  String get feedReact => 'Reagisci';

  @override
  String get feedComments => 'Commenti';

  @override
  String get feedShare => 'Condividi';

  @override
  String get feedSave => 'Salva';

  @override
  String get feedUnsave => 'Rimuovi dai salvati';

  @override
  String get feedSaved => 'Salvato';

  @override
  String get feedUnsaved => 'Rimosso dai salvati';

  @override
  String get feedShareToFeed => 'Condividi nel tuo feed';

  @override
  String get feedShareCommentHint => 'Aggiungi un commento (facoltativo)';

  @override
  String get feedShareOnlyPublic =>
      'Solo i post pubblici di altre persone possono essere condivisi nel tuo feed.';

  @override
  String get feedShared => 'Condiviso nel tuo feed';

  @override
  String get feedAlreadyShared => 'Hai già condiviso questo post.';

  @override
  String get feedCopyLink => 'Copia link musicale';

  @override
  String get feedLinkCopied => 'Link copiato';

  @override
  String get feedTurnCommentsOff => 'Disattiva commenti';

  @override
  String get feedTurnCommentsOn => 'Attiva commenti';

  @override
  String get feedDelete => 'Elimina post';

  @override
  String get feedDeleted => 'Post eliminato';

  @override
  String get feedNotInterested => 'Non mi interessa';

  @override
  String get feedNotInterestedDone => 'Vedrai meno post come questo';

  @override
  String get feedPostTitle => 'Post';

  @override
  String get feedPostGone => 'Post non disponibile';

  @override
  String get feedPostGoneBody => 'È stato eliminato o non puoi più vederlo.';

  @override
  String get feedCommentHint => 'Aggiungi un commento';

  @override
  String get feedCommentsOff => 'I commenti sono disattivati per questo post.';

  @override
  String get feedDuplicateComment => 'Hai già scritto questo commento.';

  @override
  String get feedNoComments => 'Ancora nessun commento. Inizia tu.';

  @override
  String get feedDeleteComment => 'Elimina commento';

  @override
  String get feedSavedTitle => 'Post salvati';

  @override
  String get feedSavedSubtitle => 'I post che hai salvato nel feed';

  @override
  String get feedSavedEmpty => 'Nessun post salvato';

  @override
  String get feedSavedEmptyBody =>
      'Tocca il segnalibro su un post per tenerlo qui. Solo tu vedi i tuoi salvati.';

  @override
  String get feedPostsTitle => 'Post';

  @override
  String feedPostsOf(String name) {
    return 'I post di $name';
  }

  @override
  String get feedSeeAllPosts => 'Vedi tutti';

  @override
  String get feedNoPosts => 'Ancora nessun post';

  @override
  String get feedNoPostsBody => 'Qui compariranno i post che puoi vedere.';

  @override
  String get feedYourPosts => 'I tuoi post';

  @override
  String get feedYourPostsSubtitle => 'Tutto ciò che hai pubblicato nel feed';

  @override
  String get reactionFire => 'Fuoco';

  @override
  String get reactionObsessed => 'Ossessione';

  @override
  String get reactionUnderrated => 'Sottovalutato';

  @override
  String get reactionClassic => 'Classico';

  @override
  String get reactionNewDiscovery => 'Nuova scoperta';

  @override
  String get reactionOnRepeat => 'In loop';

  @override
  String get reactionHeart => 'Amore';

  @override
  String get reactionHeadphones => 'In ascolto';

  @override
  String get reactionClap => 'Applausi';

  @override
  String get reactionMindBlown => 'Da brividi';

  @override
  String get reactionTrackTitle => 'Reagisci a questo brano';

  @override
  String get discoveryAdded => 'Aggiunto alle tue scoperte';

  @override
  String get discoveryAddFailed => 'Impossibile aggiungere il brano. Riprova.';

  @override
  String get discoveryOffer =>
      'Una nuova scoperta? Tienila nelle tue scoperte.';

  @override
  String discoveryFoundVia(String name) {
    return 'tramite $name';
  }

  @override
  String get aiTitle => 'VIBRA AI';

  @override
  String get aiHomeCta =>
      'Chiedi artisti, album, concerti e generi da scoprire';

  @override
  String get aiPrivacyTile =>
      'Assistente musicale facoltativo. Spento finché non lo attivi.';

  @override
  String get aiUnavailableTitle => 'VIBRA AI non è disponibile';

  @override
  String get aiUnavailableBody =>
      'L\'assistente non è disponibile ora. Tutto il resto di VIBRA funziona come sempre.';

  @override
  String get aiConsentTitle => 'Ecco il tuo assistente musicale';

  @override
  String get aiConsentIntro =>
      'Chiedi artisti simili, album per i tuoi gusti, concerti in linea con i tuoi interessi, community e nuovi generi. È facoltativo e resta spento finché non lo attivi.';

  @override
  String get aiConsentUses => 'Per rispondere usa';

  @override
  String get aiConsentUsesProfile =>
      'Il tuo Musical DNA, i tuoi artisti principali e i generi che hai scelto';

  @override
  String get aiConsentUsesChat =>
      'La tua domanda e gli ultimi messaggi di questa chat';

  @override
  String get aiConsentUsesCatalogue =>
      'Il catalogo pubblico di Spotify e i concerti e le community di VIBRA';

  @override
  String get aiConsentNever => 'Non usa mai';

  @override
  String get aiConsentNeverBody =>
      'I tuoi messaggi, la posizione, i contatti, i profili di altre persone o il tuo accesso Spotify. VIBRA non salva le chat.';

  @override
  String get aiConsentProvider =>
      'Le risposte sono generate da un fornitore di AI esterno (Anthropic), che riceve le informazioni sopra per ogni domanda. Puoi disattivare VIBRA AI in qualsiasi momento.';

  @override
  String get aiConsentAccept => 'Attiva VIBRA AI';

  @override
  String get aiConsentDecline => 'Non ora';

  @override
  String get aiTurnOff => 'Disattiva VIBRA AI';

  @override
  String get aiTurnedOff => 'VIBRA AI è disattivato';

  @override
  String get aiNewChat => 'Nuova conversazione';

  @override
  String get aiIntro => 'Cosa vuoi scoprire?';

  @override
  String get aiExampleSimilar => 'Consigliami artisti simili a Travis Scott';

  @override
  String get aiExampleUnderground => 'Trova artisti Hip-Hop underground';

  @override
  String get aiExampleAlbums =>
      'Consigliami album in base al mio profilo musicale';

  @override
  String get aiExampleExplain =>
      'Spiegami perché due artisti hanno un suono simile';

  @override
  String get aiExampleConcerts =>
      'Trova concerti in linea con i miei interessi';

  @override
  String get aiExampleCommunities =>
      'Suggeriscimi community che potrebbero piacermi';

  @override
  String get aiExampleGenres => 'Aiutami a scoprire nuovi generi';

  @override
  String get aiInputHint => 'Chiedi a VIBRA AI di musica';

  @override
  String get aiThinking => 'Ci sto lavorando…';

  @override
  String get aiGeneratedLabel => 'Generato dall\'AI · può contenere errori';

  @override
  String get aiVerifiedTitle => 'Risultati verificati';

  @override
  String get aiIdeasTitle => 'Idee da esplorare';

  @override
  String get aiIdeasBody => 'Suggerimenti generati, non verificati.';

  @override
  String get aiSourceSpotify => 'Verificato su Spotify';

  @override
  String get aiSourceEvents => 'Dai concerti di VIBRA';

  @override
  String get aiSourceCommunities => 'Community di VIBRA';

  @override
  String get aiSourceDna => 'Dal tuo Musical DNA';

  @override
  String get aiSourceGenres => 'Catalogo dei generi di VIBRA';

  @override
  String aiMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get aiRateLimited => 'Hai fatto molte domande. Riprova tra poco.';

  @override
  String get aiError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get aiRefused =>
      'VIBRA AI non può aiutarti con questo. Prova con una domanda sulla musica.';

  @override
  String get aiIncomplete =>
      'Non è stato possibile completare la risposta. Prova a chiedere in modo più semplice.';

  @override
  String get discoverTitle => 'Scopri il tuo prossimo artista';

  @override
  String get discoverHomeCta =>
      'Artisti simili, emergenti e underground scelti per te';

  @override
  String get discoverIntro =>
      'In base ai tuoi artisti preferiti, al tuo Musical DNA, ai brani scoperti e al tuo feedback. Le tue risposte guidano le prossime scelte.';

  @override
  String get discoverAll => 'Tutti';

  @override
  String get discoverSimilar => 'Simili';

  @override
  String get discoverCollaborations => 'Collaborazioni';

  @override
  String get discoverEmerging => 'Emergenti';

  @override
  String get discoverUnderground => 'Underground';

  @override
  String get discoverExploration => 'Nuovi generi';

  @override
  String discoverReasonCollab(String artist) {
    return 'Ha collaborato con $artist';
  }

  @override
  String discoverReasonExplore(String genre) {
    return 'Un passo verso: $genre';
  }

  @override
  String discoverReasonGenres(String genres) {
    return 'In linea con: $genres';
  }

  @override
  String get discoverLike => 'Mi piace';

  @override
  String get discoverSave => 'Salva per dopo';

  @override
  String get discoverKnown => 'Conosco già';

  @override
  String get discoverNotInterested => 'Non mi interessa';

  @override
  String get discoverLiked => 'Ricevuto: altri così';

  @override
  String get discoverUndone => 'Rimosso';

  @override
  String get discoverSaved => 'Salvato per dopo';

  @override
  String get discoverUnsaved => 'Rimosso dai salvati';

  @override
  String get discoverKnownDone =>
      'Annotato. Non ti suggeriremo più questo artista.';

  @override
  String get discoverNotInterestedDone =>
      'Non vedrai più questo artista, e meno artisti simili.';

  @override
  String get discoverRefresh => 'Nuove proposte';

  @override
  String get discoverRefreshLimited =>
      'Impossibile aggiornare ora. Riprova tra qualche minuto.';

  @override
  String get discoverError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get discoverEmptyTitle => 'Ancora nessun nuovo artista';

  @override
  String get discoverEmptyBody => 'Ripassa più tardi o tocca Nuove proposte.';

  @override
  String get discoverNoProfile =>
      'Collega Spotify o scegli qualche genere così VIBRA sa cosa ti piace.';

  @override
  String get discoverPickGenres => 'Scegli i generi';

  @override
  String get discoverSavedTitle => 'Artisti salvati';

  @override
  String get discoverSavedSubtitle => 'Artisti salvati da ascoltare più tardi';

  @override
  String get discoverSavedEmpty => 'Nessun artista salvato';

  @override
  String get discoverSavedEmptyBody =>
      'Tocca Salva per dopo su un suggerimento per tenerlo qui.';

  @override
  String get tasteTitle => 'Evoluzione dei gusti';

  @override
  String get tasteOpen => 'Guarda come sono cambiati i tuoi gusti';

  @override
  String get tastePeriodMonth => '1 mese';

  @override
  String get tastePeriodThreeMonths => '3 mesi';

  @override
  String get tastePeriodSixMonths => '6 mesi';

  @override
  String get tastePeriodYear => '1 anno';

  @override
  String tasteEvolved(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'I tuoi gusti musicali sono cambiati nell\'ultimo mese',
      'year': 'I tuoi gusti musicali sono cambiati nell\'ultimo anno',
      'three': 'I tuoi gusti musicali sono cambiati negli ultimi 3 mesi',
      'six': 'I tuoi gusti musicali sono cambiati negli ultimi 6 mesi',
      'other': 'I tuoi gusti musicali sono cambiati negli ultimi 3 mesi',
    });
    return '$_temp0';
  }

  @override
  String tasteSteady(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'I tuoi gusti musicali sono rimasti stabili nell\'ultimo mese',
      'year': 'I tuoi gusti musicali sono rimasti stabili nell\'ultimo anno',
      'three': 'I tuoi gusti musicali sono rimasti stabili negli ultimi 3 mesi',
      'six': 'I tuoi gusti musicali sono rimasti stabili negli ultimi 6 mesi',
      'other': 'I tuoi gusti musicali sono rimasti stabili negli ultimi 3 mesi',
    });
    return '$_temp0';
  }

  @override
  String tasteComparing(String from, String to) {
    return 'Confronto tra il tuo Musical DNA del $from e quello del $to.';
  }

  @override
  String tasteShortHistory(String from, String to) {
    return 'La tua cronologia inizia il $from: il confronto è tra $from e $to.';
  }

  @override
  String tasteChangePoints(int points) {
    return 'Si sono spostati $points punti percentuali del tuo mix di generi.';
  }

  @override
  String get tasteThenNow => 'Prima e adesso';

  @override
  String get tasteThen => 'Prima';

  @override
  String get tasteNow => 'Adesso';

  @override
  String get tasteTimeline => 'Nel tempo';

  @override
  String tasteTimelineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count istantanee',
      one: '1 istantanea',
    );
    return '$_temp0 del tuo Musical DNA in questo periodo.';
  }

  @override
  String get tasteNewGenres => 'Nuovi generi scoperti';

  @override
  String get tasteNoNewGenres => 'Nessun nuovo genere in questo periodo.';

  @override
  String get tasteEmergingArtists => 'Preferiti in ascesa';

  @override
  String get tasteNoEmergingArtists =>
      'I tuoi artisti preferiti sono gli stessi di prima.';

  @override
  String get tasteNoArtistData =>
      'Collega Spotify per vedere come cambiano i tuoi artisti preferiti.';

  @override
  String get tasteArtistNew => 'Nuovo';

  @override
  String tasteArtistRose(int from, int to) {
    return '#$from → #$to';
  }

  @override
  String get tastePrevious => 'Cosa ascoltavi di più prima';

  @override
  String get tasteNoPrevious => 'Niente di ciò che amavi è sbiadito.';

  @override
  String get tasteFormerTopArtist => 'Era tra i tuoi artisti principali';

  @override
  String get tasteCommunities => 'Community a cui hai aderito';

  @override
  String get tasteNoCommunities =>
      'Non hai aderito a nessuna community in questo periodo.';

  @override
  String tasteJoinedOn(String date) {
    return 'Iscrizione il $date';
  }

  @override
  String get tasteNoDnaTitle => 'Ancora nessun Musical DNA';

  @override
  String get tasteNoDnaBody =>
      'L\'evoluzione dei tuoi gusti inizia quando VIBRA ha il tuo Musical DNA.';

  @override
  String get tasteTooEarlyTitle => 'Cronologia ancora insufficiente';

  @override
  String tasteTooEarlyBody(String date) {
    return 'La tua cronologia inizia il $date. Torna tra qualche settimana per vedere come cambiano i tuoi gusti.';
  }

  @override
  String get tasteOffTitle => 'Cronologia dei gusti disattivata';

  @override
  String get tasteOffBody =>
      'VIBRA conserva solo il tuo Musical DNA attuale. Attiva la cronologia qui sotto per seguire i tuoi gusti da oggi.';

  @override
  String get tasteKeepHistory => 'Conserva la cronologia dei gusti';

  @override
  String get tasteKeepHistoryBody =>
      'Un\'istantanea del Musical DNA al giorno, conservata fino a 400 giorni e visibile solo a te.';

  @override
  String get tasteTurnOffTitle => 'Disattivare la cronologia dei gusti?';

  @override
  String get tasteTurnOffBody =>
      'Le istantanee passate verranno eliminate e sarà conservato solo il Musical DNA attuale. Le funzioni che confrontano i tuoi gusti nel tempo smetteranno di funzionare finché non la riattivi.';

  @override
  String get tasteTurnOffConfirm => 'Disattiva ed elimina';

  @override
  String get tasteError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get profileSectionGenres => 'Generi preferiti';

  @override
  String get profileSectionArtists => 'Artisti preferiti';

  @override
  String get profileSectionStats => 'Statistiche musicali';

  @override
  String get profileSectionSavedSongs => 'Brani salvati';

  @override
  String get profileSectionPlaylists => 'Playlist condivise';

  @override
  String get profileSectionEvents => 'Prossimi eventi';

  @override
  String get profileSectionCommunities => 'Community';

  @override
  String get profileSectionCircles => 'Circle';

  @override
  String get profileSectionActivity => 'Attività musicale';

  @override
  String get profileLevelPublic => 'Tutti';

  @override
  String get profileLevelConnections => 'Collegamenti';

  @override
  String get profileLevelPrivate => 'Solo io';

  @override
  String get profileRelationConnection => 'Tuo collegamento';

  @override
  String get profileRelationMatch => 'Affinità musicale';

  @override
  String profileMemberSince(String date) {
    return 'Su VIBRA da $date';
  }

  @override
  String profileSignatureSemantics(String name, String genres) {
    return '$name, firma sonora: $genres';
  }

  @override
  String get profileNoGenres => 'Ancora nessun genere preferito.';

  @override
  String get profileNoArtists => 'Ancora nessun artista preferito.';

  @override
  String get profileNoPlaylists => 'Ancora nessuna playlist condivisa.';

  @override
  String get profileNoEvents => 'Nessun evento in programma da mostrare.';

  @override
  String get profileNoCommunities => 'Non ancora in nessuna community.';

  @override
  String get profileNoCircles => 'Non sei ancora in nessun circle.';

  @override
  String get profileNoSharedCircles => 'Non siete in nessun circle insieme.';

  @override
  String get profileSharedCirclesNote => 'Circle in cui siete entrambi.';

  @override
  String get profileNoActivity => 'Nessuna attività recente.';

  @override
  String profileActivityPosted(String title) {
    return 'Ha pubblicato: $title';
  }

  @override
  String profileActivityVibe(String title) {
    return 'Daily Vibe: $title';
  }

  @override
  String profileActivityJoined(String name) {
    return 'Nuova community: $name';
  }

  @override
  String get profileEventGoing => 'Ci va';

  @override
  String get profileEventMaybe => 'Forse';

  @override
  String get profileEventInterested => 'Interesse';

  @override
  String get profileStatGenres => 'Generi';

  @override
  String get profileStatDiversity => 'Varietà';

  @override
  String get profileStatDiscoveries => 'Scoperte';

  @override
  String get profileStatPosts => 'Post';

  @override
  String get profileStatConcerts => 'Concerti visti';

  @override
  String get profileSomePrivate =>
      'Alcune sezioni di questo profilo sono private.';

  @override
  String get profilePrivacyTitle => 'Privacy del profilo';

  @override
  String get profilePrivacyTile =>
      'Scegli chi vede ogni parte del tuo profilo musicale';

  @override
  String get profilePrivacyIntro =>
      'Scegli chi può vedere ogni parte del tuo profilo. Foto, nome, username e bio sono sempre visibili alle persone con cui puoi interagire.';

  @override
  String get profilePrivacyEventsNote =>
      'Ogni evento mantiene anche la visibilità scelta in Chi partecipa.';

  @override
  String get profilePrivacyCirclesNote =>
      'Gli altri vedono solo i circle di cui fanno parte anche loro.';

  @override
  String get profilePrivacyPostsNote =>
      'Ogni post mantiene anche il proprio pubblico.';

  @override
  String get profilePrivacyDnaNote =>
      'Il Musical DNA ha una propria impostazione di visibilità.';

  @override
  String get profilePrivacyError => 'Impossibile salvare. Riprova.';

  @override
  String get safetyTitle => 'Sicurezza e privacy';

  @override
  String get safetySettingsSubtitle =>
      'Blocchi, segnalazioni, visibilità e posizione in un unico posto';

  @override
  String get safetyIntro =>
      'Tutto ciò che decide chi può contattarti e cosa vede. Queste regole sono applicate dai server di VIBRA, in tutta l\'app.';

  @override
  String get safetyPeople => 'Persone';

  @override
  String get safetyBlockedTitle => 'Persone bloccate';

  @override
  String safetyBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '1 persona',
      zero: 'Nessuno bloccato',
    );
    return '$_temp0';
  }

  @override
  String get safetyBlockExplain =>
      'Il blocco vale ovunque: messaggi, commenti, post, storie, community, circle, eventi e radar. Rimuove anche follow e collegamenti tra voi. L\'altra persona non viene avvisata.';

  @override
  String get safetyNoBlocked => 'Non hai bloccato nessuno';

  @override
  String safetyBlockedOn(String date) {
    return 'Blocco dal $date';
  }

  @override
  String get safetyUnblock => 'Sblocca';

  @override
  String safetyUnblockTitle(String name) {
    return 'Sbloccare $name?';
  }

  @override
  String get safetyUnblockBody =>
      'Potrà di nuovo trovarti e contattarti. I follow e i collegamenti rimossi dal blocco non tornano.';

  @override
  String safetyUnblocked(String name) {
    return 'Sblocco eseguito: $name';
  }

  @override
  String safetyBlockTitle(String name) {
    return 'Bloccare $name?';
  }

  @override
  String get safetyBlockBody =>
      'Non vi vedrete più da nessuna parte su VIBRA e follow e collegamenti tra voi verranno rimossi. Non verrà avvisato nessuno.';

  @override
  String get safetyReportUser => 'Segnala questa persona';

  @override
  String get safetyReported =>
      'Grazie. Il nostro team esaminerà la segnalazione.';

  @override
  String get safetyDuplicateReport => 'L\'hai già segnalato di recente.';

  @override
  String get safetyRateLimited => 'Troppi tentativi. Riprova più tardi.';

  @override
  String get safetyUserUnavailable => 'Questa persona non è disponibile.';

  @override
  String get safetyVisibility => 'Cosa vedono gli altri';

  @override
  String safetyHiddenFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nascoste a $count persone',
      one: 'nascoste a 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get safetyAttendance => 'Partecipazione agli eventi';

  @override
  String get safetyAttendanceBody => 'scelta per ogni evento in Chi partecipa';

  @override
  String get safetyLocation => 'Posizione';

  @override
  String get safetyLocationExplain =>
      'La tua posizione esatta non viene mai mostrata a nessuno. Il radar usa aree approssimative, e solo se lo attivi.';

  @override
  String get safetyRadarVisible => 'Attivo, visibile';

  @override
  String get safetyRadarHidden => 'Attivo, nascosto';

  @override
  String get safetyOn => 'Attivo';

  @override
  String get safetyOff => 'Disattivato';

  @override
  String get safetyData => 'I tuoi dati';

  @override
  String get safetyAllPrivacy => 'Tutti i controlli privacy';

  @override
  String get safetyAllPrivacyBody =>
      'Consensi, notifiche ed esportazione dei dati';

  @override
  String get safetyReporting => 'Segnalazioni';

  @override
  String get safetyReportingBody =>
      'Puoi segnalare una persona dal suo profilo e qualsiasi messaggio, post, commento, storia, risposta, vibe o contenuto di community dal suo menu. Le segnalazioni sono private. I contenuti segnalati da più persone vengono nascosti durante la revisione e i moderatori delle community possono rimuovere contenuti ed escludere membri.';

  @override
  String get safetyContact => 'Contatta l\'assistenza';

  @override
  String get notifTitle => 'Notifiche';

  @override
  String get notifCenterSubtitle =>
      'Tutto ciò che è successo, in un unico posto';

  @override
  String get notifSettingsTitle => 'Preferenze notifiche';

  @override
  String get notifSettingsSubtitle =>
      'Categorie, ore di silenzio e limite giornaliero';

  @override
  String get notifToday => 'Oggi';

  @override
  String get notifThisWeek => 'Questa settimana';

  @override
  String get notifEarlier => 'Prima';

  @override
  String get notifMarkAllRead => 'Segna tutte come lette';

  @override
  String get notifUnread => 'Non letta';

  @override
  String notifUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notifiche non lette',
      one: '1 notifica non letta',
    );
    return '$_temp0';
  }

  @override
  String notifGrouped(int count) {
    return '$count aggiornamenti';
  }

  @override
  String get notifEmptyTitle => 'Ancora nessuna notifica';

  @override
  String get notifEmptyBody =>
      'Richieste, messaggi, concerti e tutto il resto compariranno qui.';

  @override
  String get notifError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get notifPushAll => 'Notifiche push';

  @override
  String get notifPushAllBody =>
      'Disattivate: tutto compare comunque nel centro notifiche, ma nulla viene inviato al telefono.';

  @override
  String get notifNoDevice =>
      'Le notifiche push non sono ancora attive su questo dispositivo. Vedrai comunque ogni notifica qui.';

  @override
  String get notifCategoriesTitle => 'Cosa può inviare notifiche';

  @override
  String get notifCategoriesBody =>
      'Disattivare una categoria ferma le sue notifiche push. Resta comunque visibile nel centro notifiche.';

  @override
  String get notifOncePerDay => 'Al massimo una notifica push al giorno.';

  @override
  String get notifCatRequests => 'Richieste Vibra';

  @override
  String get notifCatRequestsBody => 'Nuove richieste e richieste accettate.';

  @override
  String get notifCatMessages => 'Messaggi';

  @override
  String get notifCatMessagesBody =>
      'Messaggi diretti, richieste di messaggio e chat live degli eventi.';

  @override
  String get notifCatCommunities => 'Attività nelle community';

  @override
  String get notifCatCommunitiesBody =>
      'Commenti ai tuoi post nelle community.';

  @override
  String get notifCatCircles => 'Circle';

  @override
  String get notifCatCirclesBody => 'Inviti, messaggi e piani.';

  @override
  String get notifCatConcerts => 'Annunci di concerti';

  @override
  String get notifCatConcertsBody =>
      'Nuovi concerti degli artisti che ascolti e aggiornamenti sugli eventi.';

  @override
  String get notifCatReminders => 'Promemoria eventi';

  @override
  String get notifCatRemindersBody =>
      'Una settimana prima, il giorno prima e il giorno degli eventi a cui partecipi.';

  @override
  String get notifCatRecommendations => 'Consigli';

  @override
  String get notifCatRecommendationsBody =>
      'Musica consigliata da chi segui e nuove affinità musicali.';

  @override
  String get notifCatSocial => 'Daily Vibe, storie e post';

  @override
  String get notifCatSocialBody => 'Commenti e risposte a ciò che condividi.';

  @override
  String get notifCatDiscoveries => 'Scoperte musicali';

  @override
  String get notifCatDiscoveriesBody =>
      'Quando qualcuno salva un brano che hai condiviso.';

  @override
  String get notifCatUpdates => 'Aggiornamenti VIBRA';

  @override
  String get notifCatUpdatesBody =>
      'La tua settimana musicale e qualche suggerimento.';

  @override
  String get notifQuietTitle => 'Ore di silenzio';

  @override
  String get notifQuietBody =>
      'Nessuna notifica push in queste ore, tranne i messaggi diretti. Tutto ti aspetta nel centro notifiche.';

  @override
  String get notifQuietFrom => 'Dalle';

  @override
  String get notifQuietTo => 'Alle';

  @override
  String notifDailyCap(int count) {
    return 'Al massimo $count notifiche push al giorno';
  }

  @override
  String get notifCalmExplain =>
      'Per mantenere utili le notifiche, VIBRA raggruppa le attività ripetute in un\'unica notifica (\"3 nuovi commenti\"), non reinvia lo stesso gruppo entro 30 minuti, trattiene le notifiche push nelle ore di silenzio, limita le categorie meno importanti a una notifica push al giorno e non ti avvisa mai di persone che hai bloccato.';

  @override
  String get circlesMuted => 'Notifiche silenziate';

  @override
  String get profileStories => 'Storie';

  @override
  String storyCardSemantics(String name, String kind, int hours) {
    return 'Storia musicale di $name: $kind, $hours h fa';
  }

  @override
  String musicRadarMapSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mappa delle affinità con $count persone',
      one: 'Mappa delle affinità con 1 persona',
      zero: 'Mappa delle affinità, ancora nessuno',
    );
    return '$_temp0';
  }

  @override
  String musicRadarMapPerson(String name, int percent) {
    return '$name, affinità $percent%';
  }

  @override
  String get musicRadarMapNote =>
      'Più vicino al centro significa più musica in comune. Le posizioni mostrano l’affinità, mai dove si trova qualcuno.';

  @override
  String get safetyOverviewError =>
      'Non è stato possibile caricare le impostazioni attuali. Puoi comunque aprire ogni sezione.';

  @override
  String get homeSignatureEyebrow => 'LA TUA MUSICA, LA TUA GENTE';

  @override
  String get homeSignatureTitle => 'Trova la tua gente attraverso la musica';

  @override
  String homeDnaTop(String family) {
    return '$family guida il tuo sound';
  }

  @override
  String get homeDnaEmpty => 'Crealo dai generi che ami';

  @override
  String homeFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone sulla tua frequenza',
      one: '1 persona sulla tua frequenza',
      zero: 'Scopri chi condivide i tuoi gusti',
    );
    return '$_temp0';
  }

  @override
  String homeConcertMatchNext(String name) {
    return 'Conosci chi va a $name';
  }

  @override
  String get homeConcertMatchNone =>
      'Scegli un concerto per conoscere chi ci va';

  @override
  String homeCirclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count circle',
      one: '1 circle',
      zero: 'Crea un piccolo gruppo musicale',
    );
    return '$_temp0';
  }

  @override
  String homeCirclesInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inviti in attesa',
      one: '1 invito in attesa',
    );
    return '$_temp0';
  }
}
