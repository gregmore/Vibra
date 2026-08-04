// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Vibra';

  @override
  String get appSlogan => 'Höre Musik nicht nur. Lebe sie.';

  @override
  String get welcomeTitle => 'Willkommen bei Vibra';

  @override
  String get onboardingConnectTitle => 'Verbinde deinen Geschmack';

  @override
  String get onboardingConnectBody =>
      'Verbinde Spotify, analysiere deine Lieblingskünstler, -titel und -genres und verwandle deine Hörgewohnheiten in intelligentere Empfehlungen.';

  @override
  String get onboardingDiscoverTitle => 'Entdecke die richtigen Live-Shows';

  @override
  String get onboardingDiscoverBody =>
      'Vibra kombiniert Standort, Events und musikalische Kompatibilität, um dir Konzerte vorzuschlagen, die wirklich zu dir passen.';

  @override
  String get onboardingCommunityTitle => 'Lebe die Community';

  @override
  String get onboardingCommunityBody =>
      'Finde Leute mit demselben Sound, aktiviere den Live-Modus bei Konzerten und nimm in Echtzeit am Austausch teil.';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get onboardingGoToLogin => 'Zum Login';

  @override
  String get loginTitle => 'Bei Vibra anmelden';

  @override
  String get loginSubtitle =>
      'Melde dich mit deinem Konto an oder verbinde dich über einen der unterstützten Anbieter, um echte Empfehlungen freizuschalten.';

  @override
  String get loginConsent =>
      'Mit der Authentifizierung akzeptieren Sie die Dateneinwilligung, die Verwaltung von JWT-Sitzungen und die DSGVO-Datenschutzeinstellungen.';

  @override
  String get loginWithSpotify => 'Weiter mit Spotify';

  @override
  String get loginWithGoogle => 'Weiter mit Google';

  @override
  String get loginWithApple => 'Weiter mit Apple';

  @override
  String get loginWithEmail => 'E-Mail';

  @override
  String get authFailed => 'Authentifizierung fehlgeschlagen';

  @override
  String get authErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsHeaderNotificationsPrivacy =>
      'Benachrichtigungen und Datenschutz';

  @override
  String get settingsSubtitleNotificationsPrivacy =>
      'Präferenzen, Konto und Datenverwaltung';

  @override
  String get settingsOptionCompatibleEvents =>
      'Benachrichtigungen über kompatible Events';

  @override
  String get settingsOptionHighMatchAlerts =>
      'Meldungen bei hoher Übereinstimmung';

  @override
  String get settingsOptionLiveChat => 'Live-Chat während Konzerten';

  @override
  String get settingsOptionDiscoverVisible => 'Profil in Entdecken sichtbar';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsNotificationsSub =>
      'Überprüfe Geräteberechtigungen und den Status der Push-Zustellung';

  @override
  String get settingsNotificationsSnackbar =>
      'Benachrichtigungen hängen von den Geräteberechtigungen, der Firebase-Konfiguration und einem angemeldeten Konto ab.';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingsPrivacyPolicySub =>
      'Datennutzung, Einwilligungen und Nutzerrechte';

  @override
  String get settingsTermsOfService => 'Nutzungsbedingungen';

  @override
  String get settingsTermsOfServiceSub =>
      'Nutzungsregeln, Haftung und Servicebedingungen';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsSupportSub => 'Hilfe, Kontakte und Support-Optionen';

  @override
  String get settingsAbout => 'Über Vibra';

  @override
  String get settingsAboutSub => 'App-Version, IDs und Produktübersicht';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsLogoutConfirmTitle => 'Abmelden';

  @override
  String get settingsLogoutConfirmBody =>
      'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get settingsLogoutAll => 'Von allen Geräten abmelden';

  @override
  String get settingsLogoutAllConfirmTitle => 'Von allen Geräten abmelden';

  @override
  String get settingsLogoutAllConfirmBody =>
      'Möchten Sie sich wirklich von allen Geräten abmelden? Sie werden überall abgemeldet.';

  @override
  String get settingsCancel => 'Abbrechen';

  @override
  String get settingsDeleteAccount => 'Konto löschen';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Konto löschen';

  @override
  String get settingsDeleteAccountConfirmBody =>
      'Bist du sicher, dass du dein Konto dauerhaft löschen möchtest? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get settingsDelete => 'Löschen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSub => 'Wähle deine bevorzugte App-Sprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

  @override
  String homeGreeting(String username) {
    return 'Hallo $username, heute wird laut gehört.';
  }

  @override
  String get homeSearchHint => 'Künstler, Veranstaltungsorte, Städte';

  @override
  String get homeForYouTitle => 'Für Dich';

  @override
  String get homeForYouSubtitle =>
      'Events mit einer Übereinstimmung von über 70';

  @override
  String get homeNearYouTitle => 'In Deiner Nähe';

  @override
  String get homeNearYouSubtitle =>
      'Ausgewählt im Umkreis von 50 km GPS-Radius';

  @override
  String get homeNearYouAction => 'Karte öffnen';

  @override
  String get homeTrendingTitle => 'Trends';

  @override
  String get homeTrendingSubtitle => 'Die meistbeachteten Events der Woche';

  @override
  String get homeTrendingAction => 'Alle ansehen';

  @override
  String get settingsSpotifyAccount => 'Spotify-Konto';

  @override
  String get settingsSpotifyDisconnected =>
      'Getrennt — Verbinden für Empfehlungen';

  @override
  String get settingsSpotifyDisconnect => 'Trennen';

  @override
  String get settingsSpotifyDisconnectConfirmTitle => 'Spotify trennen';

  @override
  String get settingsSpotifyDisconnectConfirmBody =>
      'Bist du sicher, dass du dein Spotify-Konto trennen möchtest? Konzertempfehlungen werden nicht mehr personalisiert sein.';

  @override
  String get settingsSpotifyDisconnectedSuccess =>
      'Spotify erfolgreich getrennt';

  @override
  String get settingsGenerateCompatibleUsers =>
      'Kompatible Benutzer generieren';

  @override
  String get settingsGenerateCompatibleUsersSub =>
      'Erstelle Bots mit ähnlichem Musikgeschmack';

  @override
  String get settingsGenerateCompatibleUsersLoading =>
      'Wird generiert... Bitte warten.';

  @override
  String get settingsGenerateCompatibleUsersSuccess => 'Erfolgreich generiert!';

  @override
  String settingsError(String error) {
    return 'Fehler: $error';
  }

  @override
  String settingsLogoutError(String error) {
    return 'Fehler beim Abmelden: $error';
  }

  @override
  String settingsSpotifyConnected(String username) {
    return 'Verbunden als @$username';
  }

  @override
  String get settingsDeleteAccountError =>
      'Konto konnte nicht gelöscht werden. Stelle sicher, dass der RPC in der Datenbank geladen wurde.';

  @override
  String get eventDetailChat => 'Chat';

  @override
  String get eventDetailTicketsUnavailable => 'Ticket-Link nicht verfügbar.';

  @override
  String get eventDetailTicketsError =>
      'Ticket-Link kann nicht geöffnet werden.';

  @override
  String get eventDetailBuyTickets => 'Tickets kaufen';

  @override
  String get eventDetailAttendanceConfirmed => 'Teilnahme bestätigt!';

  @override
  String get eventDetailAttend => 'Ich nehme teil';

  @override
  String get eventDetailAttendanceMaybe => 'Teilnahme auf Vielleicht gesetzt';

  @override
  String get eventDetailMaybe => 'Vielleicht';

  @override
  String get eventDetailAttendanceNotGoing =>
      'Du hast angegeben, dass du nicht gehst';

  @override
  String get eventDetailNotGoing => 'Gehe nicht';

  @override
  String get eventDetailCopied => 'Eventdetails kopiert!';

  @override
  String get exploreSearchEvents => 'Ereignisse suchen';

  @override
  String get exploreSearchInArea => 'In diesem Bereich suchen';

  @override
  String get exploreSearchingEvents => 'Suche nach Ereignissen...';

  @override
  String exploreRadius(String radius) {
    return '$radius km';
  }

  @override
  String get friendsTitle => 'Freunde';

  @override
  String get chatSendFailed => 'Senden fehlgeschlagen';

  @override
  String get socialTitle => 'Sozial';

  @override
  String socialRequestFrom(String userId) {
    return 'Anfrage von $userId';
  }

  @override
  String get socialOpen => 'Öffnen';

  @override
  String get userProfileTitle => 'Benutzerprofil';

  @override
  String userProfileCompatibility(String percentage) {
    return '$percentage% Kompatibilität';
  }

  @override
  String get userProfileTopArtists => 'Top-Künstler';

  @override
  String get userProfileFriendRequestSent => 'Freundschaftsanfrage gesendet!';

  @override
  String get userProfileSendRequest => 'Anfrage senden';

  @override
  String get userProfileOpenChat => 'Chat öffnen';

  @override
  String socialMatchVibraSent(String name) {
    return 'Vibra an $name gesendet! 🎉';
  }

  @override
  String get socialMatchViewProfile => 'Vollständiges Profil ansehen';

  @override
  String get socialMatchIgnore => 'Ignorieren';

  @override
  String get userProfileNotAvailableTitle => 'Profil nicht verfügbar';

  @override
  String get userProfileNotAvailableMessage =>
      'Kein Benutzer ausgewählt oder derzeit kein Match verfügbar.';

  @override
  String get userProfileEvents => 'Vergangene/kommende Konzerte';

  @override
  String get socialDiscoverUsers => 'Benutzer entdecken';

  @override
  String get socialHighCompatibility =>
      'Benutzer mit hoher musikalischer Kompatibilität';

  @override
  String socialRequestsCount(int count) {
    return 'Anfragen ($count)';
  }

  @override
  String get socialPendingFriendships => 'Ausstehende Freundschaften';

  @override
  String get socialRequestsToManage => 'Zu verwaltende Anfragen';

  @override
  String get navHome => 'Start';

  @override
  String get navEvents => 'Events';

  @override
  String get navVibra => 'Vibra';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get friendsYourFriends => 'Deine Freunde';

  @override
  String get friendsYourConnections => 'Deine Vibra-Verbindungen';

  @override
  String get friendsNoFriendsYet => 'Noch keine Freunde';

  @override
  String get friendsGoToExplore =>
      'Gehe zum Bereich Entdecken oder nutze Social Match, um Leute mit dem gleichen Geschmack zu finden.';

  @override
  String get friendsSentRequests => 'Gesendete Anfragen';

  @override
  String get friendsWaitingForReply => 'Warten auf Antwort';

  @override
  String get friendsPendingApproval => 'Warten auf Genehmigung';

  @override
  String get socialMatchNewAffinity => 'NEUE AFFINITÄT';

  @override
  String get socialMatchScore => 'MATCH-SCORE';

  @override
  String get socialMatchWhyMatched => 'WARUM IHR MATCHT';

  @override
  String socialMatchCommonEvents(String count) {
    return 'Live nearby • $count gemeinsame Events';
  }

  @override
  String get socialMatchSendVibra => 'Vibra senden';

  @override
  String get exploreSearchHint => 'Nach Name oder Stadt suchen (z.B. Mailand)';

  @override
  String get exploreInteractiveMap => 'Interaktive Karte';

  @override
  String get exploreLiveAroundYou =>
      'Entdecke Live-Events in deiner Nähe in Echtzeit';

  @override
  String get exploreSearchRadius => 'Suchradius';

  @override
  String get exploreFindEventsNearYou => 'Finde Events in deiner Nähe';

  @override
  String get exploreMusicGenre => 'Musikgenre';

  @override
  String get exploreFilterByGenre => 'Nach Lieblingsgenres filtern';

  @override
  String get exploreGenreAll => 'Alle';

  @override
  String get friendsReceivedRequests => 'Erhaltene Anfragen';

  @override
  String get friendsAcceptOrReject =>
      'Neue Verbindungen akzeptieren oder ablehnen';

  @override
  String get friendsWantsToConnect => 'Möchte sich mit dir verbinden';

  @override
  String socialMatchListenBoth(String artists) {
    return 'Ihr hört beide $artists';
  }

  @override
  String socialMatchCityEvents(String city, String count) {
    return '$city • $count gemeinsame Events';
  }

  @override
  String get myProfileConnectSpotify => 'Spotify verbinden';

  @override
  String get myProfileOverview => 'Übersicht';

  @override
  String get myProfileOverviewSubtitle => 'Schnellzugriff auf Profilbereiche';

  @override
  String get myProfileSettings => 'Einstellungen';

  @override
  String get myProfileMusicStats => 'Musikstatistiken';

  @override
  String get myProfileMusicStatsSubtitle =>
      'Top-Künstler, Genres und Hör-Heatmap';

  @override
  String get myProfileMyEvents => 'Meine Events';

  @override
  String myProfileMyEventsSubtitle(String count) {
    return '$count gespeicherte, kommende und vergangene Events';
  }

  @override
  String get myProfileSettingsSubtitle =>
      'Datenschutz, Benachrichtigungen, Konto und Abmelden';

  @override
  String get myEventsTitle => 'Meine Events';

  @override
  String get myEventsGoing => 'Ich gehe';

  @override
  String get myEventsGoingSubtitle => 'Bestätigte oder kommende Events';

  @override
  String get myEventsGoingEmpty =>
      'Du hast deine Teilnahme an keinem Event bestätigt.\\nEntdecke und finde deine nächsten Konzerte!';

  @override
  String get myEventsSaved => 'Gespeichert';

  @override
  String get myEventsSavedSubtitle => 'Im Auge behalten';

  @override
  String get myEventsSavedEmpty =>
      'Keine gespeicherten Events.\\nSpeichere die Events, die dich interessieren, um sie nicht zu verpassen.';

  @override
  String get chatEmptyTitle => 'Keine Nachrichten';

  @override
  String get chatEmptyMessage => 'Beginne das Gespräch!';

  @override
  String get chatInputHint => 'Schreibe eine Nachricht...';

  @override
  String get socialMatchScanningTitle => 'VIBE-ANALYSE';

  @override
  String get socialMatchScanningSubtitle =>
      'Suche nach Personen mit ähnlichem Musikgeschmack in der Nähe...';

  @override
  String get socialMatchEmptyTitle => 'Keine Übereinstimmungen in der Nähe';

  @override
  String get socialMatchEmptyMessage =>
      'Deine Musik-Vibes sind einzigartig! Im Moment gibt es keine Leute mit ähnlichem Geschmack in deiner Nähe...';

  @override
  String get socialMatchEmptyAction => 'Entdecke Events in der Nähe';

  @override
  String get socialMatchEmptySecondary => 'Erneut suchen';

  @override
  String get musicStatsTitle => 'Musikstatistiken';

  @override
  String musicStatsSyncError(String error) {
    return 'Synchronisierungsfehler: $error';
  }

  @override
  String get musicStatsTopArtists => 'Top Künstler';

  @override
  String get musicStatsTopArtistsSub =>
      'Bewertung basierend auf Spotify-Vorlieben';

  @override
  String get musicStatsHeatmap => 'Hör-Heatmap';

  @override
  String get musicStatsHeatmapSub =>
      'Wöchentliche Verteilung deiner Hörgewohnheiten';

  @override
  String get liveScreenTitle => 'Live Vibra';

  @override
  String get liveScreenSendFailed =>
      'Senden fehlgeschlagen. Überprüfe deine Verbindung.';

  @override
  String get liveScreenActivateMode => 'Live-Modus aktivieren';

  @override
  String get liveScreenPresentNowTitle => 'Jetzt anwesend';

  @override
  String get liveScreenPresentNowSub =>
      'Teilnehmer mit hoher musikalischer Kompatibilität';

  @override
  String get liveScreenChatTitle => 'Event-Chat';

  @override
  String get liveScreenChatSub => 'Der Chat schließt automatisch nach 24h';

  @override
  String get eventDetailNotAvailableTitle => 'Event nicht verfügbar';

  @override
  String get eventDetailNotAvailableMsg =>
      'Dieses Event ist nicht mehr verfügbar.';

  @override
  String get eventDetailMapTitle => 'Veranstaltungsort';

  @override
  String get eventDetailMapSub => 'Veranstaltungsort';

  @override
  String get eventDetailAttendeesTitle => 'Teilnehmer';

  @override
  String get eventDetailAttendeesSub =>
      'Benutzer mit musikalischer Übereinstimmung';

  @override
  String get spotifyAuthStep1Title => '1. OAuth-Autorisierung';

  @override
  String get spotifyAuthStep1Sub => 'Sichere Anmeldung auf der Spotify-Website';

  @override
  String get spotifyAuthStep2Title => '2. Anmeldeinformationen austauschen';

  @override
  String get spotifyAuthStep2Sub => 'Generierung sicherer Schlüssel';

  @override
  String get spotifyAuthStep3Title => '3. Geschmackssynchronisierung';

  @override
  String get spotifyAuthStep3Sub => 'Analyse von Top-Künstlern und Playlists';

  @override
  String get spotifyAuthCancelled => 'Verbindung abgebrochen.';

  @override
  String spotifyAuthError(String error) {
    return 'Ein Fehler ist aufgetreten: $error';
  }

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get legalPrivacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get legalPrivacySec1 => 'Welche Daten Vibra sammelt';

  @override
  String get legalPrivacySec2 => 'Warum Vibra es verwendet';

  @override
  String get legalPrivacySec3 => 'Deine Kontrollen';

  @override
  String get legalPrivacySec4 => 'Datenschutzkontakt';

  @override
  String get legalTermsTitle => 'Nutzungsbedingungen';

  @override
  String get legalTermsSec1 => 'Verwendung von Vibra';

  @override
  String get legalTermsSec2 => 'Dienste von Drittanbietern';

  @override
  String get legalTermsSec3 => 'Inhalt und Verhalten';

  @override
  String get legalTermsSec4 => 'Rechtlicher Kontakt';

  @override
  String get legalSupportTitle => 'Support';

  @override
  String get legalSupportSec1 => 'Support-E-Mail';

  @override
  String get legalSupportSec2 => 'Behandelte Probleme';

  @override
  String get legalSupportSec3 => 'Was zuerst zu überprüfen ist';

  @override
  String get legalAboutTitle => 'Über Vibra';

  @override
  String get legalAboutSec1 => 'Version';

  @override
  String get legalAboutSec2 => 'Plattformkennungen';

  @override
  String get legalAboutSec3 => 'Was Vibra macht';

  @override
  String get legalAboutSec4 => 'Support';

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
  String get spotifyAuthCancelledTitle => 'Authentifizierung fehlgeschlagen';

  @override
  String get errorTitle => 'Systemfehler';

  @override
  String get legalPrivacyBody1 =>
      'Kontodaten, Musikprofil, Teilnahme an Events, Nachrichten, Standort und Push-Token.';

  @override
  String get legalPrivacyBody2 =>
      'Zur Authentifizierung und Generierung von Empfehlungen.';

  @override
  String get legalPrivacyBody3 =>
      'Du kannst Berechtigungen widerrufen, Dienste trennen und das Konto löschen lassen.';

  @override
  String legalPrivacyBody4(String email) {
    return 'Datenschutzanfragen: $email';
  }

  @override
  String get legalTermsBody1 =>
      'Durch die Nutzung stimmst du zu, die App rechtmäßig zu nutzen.';

  @override
  String get legalTermsBody2 =>
      'Spotify, Supabase, Firebase können verwendet werden.';

  @override
  String get legalTermsBody3 =>
      'Benutzer sind für veröffentlichte Inhalte verantwortlich.';

  @override
  String legalTermsBody4(String email) {
    return 'Rechtliche Anfragen: $email';
  }

  @override
  String legalSupportBody1(String email) {
    return '$email';
  }

  @override
  String get legalSupportBody2 =>
      'Anmeldeprobleme, Spotify-Verbindung, Events entdecken.';

  @override
  String get legalSupportBody3 =>
      'Berechtigungen, Spotify-Verbindungsstatus, Firebase-Konfiguration.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Android-Paket: $android\niOS-Bundle: $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra hilft, Spotify zu verbinden und Live-Events zu entdecken.';

  @override
  String legalAboutBody4(String email) {
    return '$email';
  }

  @override
  String get homeGreetingMorning => 'Guten Morgen 👋';

  @override
  String get homeGreetingAfternoon => 'Guten Tag 👋';

  @override
  String get homeGreetingEvening => 'Guten Abend 🌙';

  @override
  String get eventCardTBA => 'Noch offen';

  @override
  String get eventCardCity => 'Stadt';

  @override
  String get legalPrivacySubtitle =>
      'Eine Zusammenfassung der in der App verfügbaren Datenschutzinformationen, einschließlich Kategorien verarbeiteter Daten und Verwendungszwecke.';

  @override
  String get legalTermsSubtitle =>
      'Eine Zusammenfassung der Regeln, Verantwortlichkeiten und Nutzungsbedingungen für die Verwendung von Vibra.';

  @override
  String get legalSupportSubtitle =>
      'Support-Informationen für Kontozugriff, Benachrichtigungen, Spotify-Verbindung und Live-Funktionen.';

  @override
  String get legalAboutSubtitle =>
      'Vibra kombiniert Musikgeschmack, Event-Entdeckung und soziale Interaktion rund um Live-Erlebnisse.';

  @override
  String get exploreShowAllEvents => 'Alle Events anzeigen';

  @override
  String get musicStatsSyncSpotify => 'Spotify synchronisieren';

  @override
  String get liveModeDisabled => 'Der Live-Modus ist deaktiviert';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authLoginWithEmail => 'Mit E-Mail anmelden';

  @override
  String get authUsername => 'Benutzername';

  @override
  String get authUsernameHint => 'Gib einen Benutzernamen ein';

  @override
  String get authEmail => 'E-Mail-Adresse';

  @override
  String get authEmailHint => 'Gib deine E-Mail ein';

  @override
  String get authEmailInvalid => 'Gib eine gültige E-Mail ein';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authPasswordHint => 'Gib dein Passwort ein';

  @override
  String get authPasswordShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authLogin => 'Anmelden';

  @override
  String get authAlreadyHaveAccount => 'Hast du bereits ein Konto? Anmelden';

  @override
  String get authDontHaveAccount => 'Hast du kein Konto? Registrieren';

  @override
  String get authGenericError => 'Ein Fehler ist aufgetreten';

  @override
  String get eventCardLocation => 'Ort';

  @override
  String get matchScore => 'MATCH-SCORE';

  @override
  String get userGeneric => 'Benutzer';

  @override
  String get spotifyConnectTitle => 'Spotify Verbinden';

  @override
  String get spotifyConnectSubtitle =>
      'Verbinde dein Konto, um deine Lieblingskünstler zu synchronisieren und personalisierte Empfehlungen für Konzerte freizuschalten.';

  @override
  String get spotifyConnectOnboarding => 'Onboarding-Ablauf';

  @override
  String get spotifyConnectPrivacyDesc =>
      'Deine Daten sind durch AES-GCM-Verschlüsselung auf dem Server geschützt.';

  @override
  String get spotifyConnectContinue => 'Weiter und Entdecken';

  @override
  String get spotifyConnectRetry => 'Verbindung erneut versuchen';

  @override
  String get spotifyConnectAction => 'Mein Spotify verbinden';

  @override
  String get spotifyConnectSkip => 'Vorerst überspringen';

  @override
  String get homeSpotifySyncTitle =>
      'Personalisierte Empfehlungen Freischalten';

  @override
  String get homeSpotifySyncSub => 'Synchronisiere dein Musikhören';

  @override
  String get homeSpotifySyncDesc =>
      'Verbinde Spotify, um Event-Empfehlungen zu erhalten und Leute mit dem gleichen Geschmack zu finden.';

  @override
  String get homeSpotifySyncAction => 'SPOTIFY VERBINDEN';
}
