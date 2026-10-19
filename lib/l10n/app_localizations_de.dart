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
      'Entdecke Konzerte und Menschen, mit denen du sie erleben kannst.';

  @override
  String get loginConsent =>
      'Lies die Nutzungsbedingungen und Datenschutzhinweise, bevor du fortfährst. Freiwillige Einstellungen verwaltest du in den Einstellungen.';

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
      'Melde dich an und aktiviere Vibra-Benachrichtigungen in den Geräteeinstellungen.';

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
      'Dein Konto konnte nicht gelöscht werden. Versuche es erneut oder kontaktiere den Support.';

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
      'Entdecke die Community, finde Menschen und sende Freundschaftsanfragen.';

  @override
  String get friendsSentRequests => 'Gesendete Anfragen';

  @override
  String get friendsWaitingForReply => 'Warten auf Antwort';

  @override
  String get friendsPendingApproval => 'Warten auf Genehmigung';

  @override
  String get socialMatchNewAffinity => 'NEUE AFFINITÄT';

  @override
  String get socialMatchScore => 'MUSIKALISCHE ÄHNLICHKEIT';

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
  String exploreSearchRadius(int radius) {
    return 'SUCHRADIUS: $radius KM';
  }

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
  String get myEventsUpcoming => 'Bevorstehend';

  @override
  String get myEventsPast => 'Vergangen';

  @override
  String get myEventsPastSubtitle => 'Deine Konzertchronik';

  @override
  String get myEventsPastEmpty => 'Du hast noch keine vergangenen Events.';

  @override
  String get myEventsSearchHint => 'Events, Künstler oder Orte suchen';

  @override
  String get myEventsSearchEmpty => 'Keine Events entsprechen deiner Suche.';

  @override
  String get myEventsClearSearch => 'Suche löschen';

  @override
  String get myEventsExplore => 'Events entdecken';

  @override
  String get inboxUnread => 'Ungelesen';

  @override
  String get inboxNoResults => 'Keine Unterhaltungen gefunden.';

  @override
  String get inboxNoResultsBody =>
      'Versuche einen anderen Namen oder entferne die Filter, um alle Nachrichten zu sehen.';

  @override
  String get inboxClearFilters => 'Filter entfernen';

  @override
  String get homeFeedError => 'Events konnten nicht geladen werden.';

  @override
  String get homeFeedErrorBody =>
      'Versuche es gleich erneut. Du kannst weiterhin die Karte erkunden.';

  @override
  String get homeFeedEmpty => 'Zeit für einen neuen Konzertabend.';

  @override
  String get homeFeedEmptyBody =>
      'Entdecke dein nächstes Konzert auf der Karte.';

  @override
  String get socialSearchHint => 'Personen oder Künstler suchen';

  @override
  String get socialSearchEmpty => 'Keine Personen gefunden.';

  @override
  String get socialSearchEmptyBody =>
      'Versuche einen anderen Namen oder Künstler.';

  @override
  String get socialDiscoverEmpty => 'Neue Kontakte beginnen hier.';

  @override
  String get socialDiscoverEmptyBody =>
      'Vervollständige dein Profil und verbinde Spotify, um Menschen mit ähnlichem Geschmack zu finden.';

  @override
  String get chatSendMessage => 'Nachricht senden';

  @override
  String get chatLoadError => 'Die Unterhaltung konnte nicht geladen werden.';

  @override
  String get chatDraftRecovered =>
      'Die Nachricht wurde nicht gesendet. Der Text wurde im Eingabefeld wiederhergestellt.';

  @override
  String get eventLocationUnknown =>
      'Der genaue Standort ist noch nicht verfügbar.';

  @override
  String get eventDirections => 'Route anzeigen';

  @override
  String get eventDirectionsError => 'Die Route konnte nicht geöffnet werden.';

  @override
  String get inboxDeleteTitle => 'Unterhaltung löschen?';

  @override
  String get inboxDeleteBody =>
      'Die Unterhaltung wird aus deinem Posteingang entfernt. Die Nachrichten der anderen Person werden nicht gelöscht.';

  @override
  String get inboxDeleteAction => 'Unterhaltung löschen';

  @override
  String get inboxDeleteSuccess => 'Unterhaltung gelöscht.';

  @override
  String get inboxDeleteError =>
      'Die Unterhaltung wurde nicht gelöscht. Bitte versuche es erneut.';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get eventCopyDetails => 'Eventdetails kopieren';

  @override
  String get eventCopyError => 'Die Eventdetails konnten nicht kopiert werden.';

  @override
  String get eventCancelled => 'Event abgesagt';

  @override
  String get eventTicketsOffsale => 'Tickets nicht im Verkauf';

  @override
  String get socialMatchSendFailed =>
      'Vibra wurde nicht gesendet. Versuche es erneut: Das Profil ist weiterhin verfügbar.';

  @override
  String get myEventsTitle => 'Meine Events';

  @override
  String get myEventsGoing => 'Ich gehe';

  @override
  String get myEventsGoingSubtitle => 'Bestätigte oder kommende Events';

  @override
  String get myEventsGoingEmpty =>
      'Du hast deine Teilnahme an keinem Event bestätigt.\nEntdecke und finde deine nächsten Konzerte!';

  @override
  String get myEventsSaved => 'Gespeichert';

  @override
  String get myEventsSavedSubtitle => 'Im Auge behalten';

  @override
  String get myEventsSavedEmpty =>
      'Keine gespeicherten Events.\nSpeichere die Events, die dich interessieren, um sie nicht zu verpassen.';

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
      'Prüfe Verbindung, Geräteberechtigungen und Anmeldestatus. Falls das Problem bleibt, melde es in den Einstellungen.';

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
      'Vibra hilft dir, Live-Events zu entdecken, die Karte zu erkunden, Konzerte zu speichern, Menschen zu treffen und zu chatten. Spotify-Funktionen sind nur bei aktiviertem Dienst verfügbar.';

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
      'Live-Events, Karte und Community für gemeinsame Erlebnisse.';

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
  String get matchScore => 'MUSIKALISCHE ÄHNLICHKEIT';

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

  @override
  String get loginBackToWelcome => 'Zurück zum Willkommensbildschirm';

  @override
  String get authOr => 'oder';

  @override
  String get authEmailLoginSubtitle =>
      'Gib deine Zugangsdaten ein, um dich anzumelden und Konzerte zu entdecken.';

  @override
  String get authEmailRegisterSubtitle =>
      'Gib deine Zugangsdaten ein, um dich zu registrieren und Live-Konzerte zu erleben.';

  @override
  String get authAgeConfirmation =>
      'Ich bestätige, dass ich mindestens 18 Jahre alt bin.';

  @override
  String get authAgeExplanation =>
      'Vibra hilft Menschen, sich kennenzulernen, und ist nicht für Minderjährige bestimmt.';

  @override
  String get authAgeRequired =>
      'Du musst bestätigen, dass du mindestens 18 Jahre alt bist, um ein Konto zu erstellen.';

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get spotifyUnavailableTitle => 'Spotify pausiert';

  @override
  String get spotifyUnavailableBody =>
      'Spotify und musikalische Übereinstimmungen sind vorübergehend deaktiviert. Events, Freunde und Chats bleiben verfügbar.';

  @override
  String get launchExploreTitle => 'Finde dein nächstes Konzert';

  @override
  String get launchExploreBody =>
      'Suche Künstler, erkunde die Karte und speichere Events in deiner Nähe.';

  @override
  String get launchCommunityTitle => 'Erlebe die Community';

  @override
  String get launchCommunityBody =>
      'Finde Menschen, füge Freunde hinzu und plane Konzerte in deinen Chats.';

  @override
  String get launchSavedTitle => 'Dein Live-Kalender';

  @override
  String get launchSavedBody =>
      'Speichere Konzerte und finde die Events, die du besuchen möchtest.';

  @override
  String get launchCommunitySubtitle =>
      'Personen nach Name oder Benutzername suchen';

  @override
  String get launchCommunityEmptyTitle => 'Keine Personen gefunden';

  @override
  String get launchCommunityEmptyBody =>
      'Versuche einen anderen Namen oder schaue später wieder vorbei.';

  @override
  String get launchCommunityLoadError =>
      'Personen konnten nicht geladen werden. Versuche es erneut.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonLoading => 'Wird geladen…';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonAll => 'Alle';

  @override
  String get commonConnect => 'Verbinden';

  @override
  String get commonActive => 'Aktiv';

  @override
  String get commonNotNow => 'Nicht jetzt';

  @override
  String get commonSkip => 'Überspringen';

  @override
  String get commonTryLater => 'Versuche es später erneut.';

  @override
  String get commonConnectionError => 'Verbindungsfehler';

  @override
  String commonLoadingLabel(String label) {
    return '$label, wird geladen';
  }

  @override
  String commonSelectedLabel(String label) {
    return '$label, ausgewählt';
  }

  @override
  String commonNotSelectedLabel(String label) {
    return '$label, nicht ausgewählt';
  }

  @override
  String get commonOnline => 'Online';

  @override
  String get commonAvatar => 'Avatar';

  @override
  String commonPercentLabel(int percentage, String label) {
    return '$percentage Prozent $label';
  }

  @override
  String commonAvatarAffinity(String name, int percentage) {
    return '$name, $percentage Prozent Übereinstimmung';
  }

  @override
  String get commonRegistrationComplete => 'Registrierung abgeschlossen';

  @override
  String get profileEditTitle => 'Profil bearbeiten';

  @override
  String get profileBack => 'Zurück zum Profil';

  @override
  String get profilePersonalSpace => 'PERSÖNLICHER BEREICH';

  @override
  String get profileSpotifyConnected => 'Spotify verbunden';

  @override
  String get profileFollowers => 'Follower';

  @override
  String get profileFollowing => 'Gefolgt';

  @override
  String get profileOpenMusicStats => 'Musikstatistik öffnen';

  @override
  String get profileYourVibra => 'DEINE VIBRA';

  @override
  String get profileInRotation => 'In Rotation';

  @override
  String get profileSyncMusicBody =>
      'Synchronisiere Spotify, um dein Musikprofil zu sehen.';

  @override
  String get profileShapeTitle => 'Gestalte deine Vibra';

  @override
  String get profileShapeBody =>
      'Verbinde Spotify, um deine musikalische Identität zu zeigen.';

  @override
  String get profileUsernameEmpty => 'Der Benutzername darf nicht leer sein';

  @override
  String get profileUsernameShort => 'Mindestens 3 Zeichen';

  @override
  String get profileUsernameCharacters =>
      'Verwende nur Buchstaben, Zahlen, _ oder .';

  @override
  String get profileUsernameCharactersOnboarding =>
      'Verwende nur Buchstaben, Zahlen und Unterstriche';

  @override
  String get profileUsernameTaken => 'Benutzername bereits vergeben';

  @override
  String get profileUsernameTakenRetry =>
      'Dieser Benutzername ist bereits vergeben. Wähle einen anderen.';

  @override
  String get profilePhotoPermission =>
      'Erlaube den Zugriff auf Fotos in den Geräteeinstellungen und versuche es erneut.';

  @override
  String get profilePhotoPickError =>
      'Das Foto konnte nicht ausgewählt werden. Versuche es erneut.';

  @override
  String get profilePhotoTitle => 'Profilfoto';

  @override
  String get profilePhotoGallery => 'Aus Galerie auswählen';

  @override
  String get profilePhotoGalleryBody => 'Wähle ein Foto auf deinem Gerät';

  @override
  String get profilePhotoCamera => 'Foto aufnehmen';

  @override
  String get profilePhotoCameraBody => 'Nimm mit der Kamera ein neues Foto auf';

  @override
  String get profilePhotoRemove => 'Foto entfernen';

  @override
  String get profilePhotoRestore => 'Standardavatar wiederherstellen';

  @override
  String get profileSaved => 'Profil aktualisiert!';

  @override
  String get profileSaveError =>
      'Dein Profil konnte nicht gespeichert werden. Versuche es gleich erneut.';

  @override
  String get profilePhotoChange => 'Profilfoto ändern';

  @override
  String get profileUsernameExample => 'z. B. musik_fan';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameHint => 'Dein Name oder Spitzname';

  @override
  String get profileNameEmpty => 'Der Name darf nicht leer sein';

  @override
  String get profileDescription => 'Beschreibung';

  @override
  String get profileDescriptionHint => 'Erzähle etwas über dich…';

  @override
  String get profileMusicStreaming => 'Musik und Streaming';

  @override
  String get profileAccountConnected => 'Konto verbunden';

  @override
  String get profileConnectSuggestions =>
      'Verbinde dein Konto für bessere Vorschläge';

  @override
  String get profileSaveChanges => 'Änderungen speichern';

  @override
  String get homeYourSoundToday => 'DEIN SOUND, HEUTE';

  @override
  String get homeSpotifySynced =>
      'Spotify synchronisiert · Vorschläge lernen von dir';

  @override
  String get homeSpotifyPersonalize =>
      'Verbinde Spotify für persönliche Vorschläge';

  @override
  String get homeCompleteProfile => 'Vervollständige dein Profil';

  @override
  String get homeShapeVibra => 'Gestalte deine Vibra';

  @override
  String get homeNextEvent => 'ALS NÄCHSTES';

  @override
  String get homeNearbyEyebrow => 'IN DER NÄHE';

  @override
  String get homeTrendingEyebrow => 'JETZT ANGESAGT';

  @override
  String get settingsPrivateMessages => 'Private Nachrichten und Anfragen';

  @override
  String get settingsPersonalizedUpdates =>
      'Persönliche Neuigkeiten und Erinnerungen';

  @override
  String get settingsMusicWeek => 'Deine Musikwoche';

  @override
  String get settingsMusicWeekBody => 'Events und Übereinstimmungen für dich';

  @override
  String get settingsWeekly => 'Wöchentlich';

  @override
  String get settingsMonthly => 'Monatlich';

  @override
  String get settingsNever => 'Nie';

  @override
  String get settingsPrivacyData => 'Datenschutz und persönliche Daten';

  @override
  String get settingsPrivacyDataBody =>
      'Einwilligungen, Datenexport und Löschung';

  @override
  String get settingsHelpCenter => 'Hilfe-Center';

  @override
  String get settingsHelpCenterBody =>
      'Hilfe zu Konto, Events, Chat und Spotify';

  @override
  String get settingsReportProblem => 'Problem melden';

  @override
  String get settingsReportProblemBody =>
      'Sende bereinigte Diagnosedaten und einen optionalen Screenshot';

  @override
  String get privacySaveError =>
      'Die Einstellung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get privacyExportTitle => 'Dein Datenexport';

  @override
  String get privacySaveJSON => 'JSON speichern';

  @override
  String get privacyCopyJSON => 'JSON kopieren';

  @override
  String get privacyCopiedJSON => 'JSON in die Zwischenablage kopiert.';

  @override
  String get privacyExportError =>
      'Datenexport nicht verfügbar. Versuche es später erneut.';

  @override
  String privacyExportSaved(String path) {
    return 'Export gespeichert unter $path';
  }

  @override
  String get privacyIntro =>
      'Wähle jede optionale Datennutzung einzeln. Du kannst deine Entscheidung jederzeit ändern.';

  @override
  String get privacyPreciseLocation => 'Genauer Standort';

  @override
  String get privacyPreciseLocationBody =>
      'Für Events in der Nähe und Live-Funktionen. Wird höchstens 30 Tage gespeichert.';

  @override
  String get privacySpotifyMatching =>
      'Spotify für musikalische Übereinstimmungen';

  @override
  String get privacySpotifyMatchingBody =>
      'Nutze synchronisierte Künstler, Genres und Hörgewohnheiten für Vorschläge und Übereinstimmungen.';

  @override
  String get privacyServiceNotifications => 'Service-Benachrichtigungen';

  @override
  String get privacyServiceNotificationsBody =>
      'Übereinstimmungen, Nachrichten und gespeicherte Events.';

  @override
  String get privacyMarketing => 'Marketing-Nachrichten';

  @override
  String get privacyMarketingBody =>
      'Immer optional; du kannst die App auch ohne sie nutzen.';

  @override
  String get privacyExportAction => 'Meine Daten exportieren';

  @override
  String get privacyExportBody =>
      'Erstelle eine lesbare JSON-Kopie von Profil, Chats, Events und Interaktionen, einschließlich früherer Spotify-Daten, falls vorhanden.';

  @override
  String get privacyDeletionBody =>
      'Beim Löschen deines Kontos werden dessen Daten entfernt. Gesendete Nachrichten werden anonymisiert; Inhalt und Medien werden entfernt. Backups folgen den Fristen der Datenschutzerklärung.';

  @override
  String get appearanceTitle => 'Darstellung';

  @override
  String get appearanceBody =>
      'Wähle das App-Design oder folge der Geräteeinstellung.';

  @override
  String get appearanceDark => 'Dunkel';

  @override
  String get appearanceDarkBody => 'Reduziert die Helligkeit bei wenig Licht';

  @override
  String get appearanceLight => 'Hell';

  @override
  String get appearanceLightBody => 'Helle Flächen und sanfte Schatten';

  @override
  String get appearanceSystem => 'Automatisch (System)';

  @override
  String get appearanceSystemBody =>
      'Passt sich an Änderungen der Geräteeinstellung an';

  @override
  String get onboardingBack => 'Zurück zum vorherigen Schritt';

  @override
  String get onboardingStart => 'Los geht’s';

  @override
  String get onboardingProfileTitle => 'Dein Profil';

  @override
  String get onboardingProfileBody => 'So sehen dich andere';

  @override
  String get onboardingSkipToHome => 'Rest überspringen und zur Startseite';

  @override
  String get onboardingPhotoUploading => 'Profilfoto wird hochgeladen';

  @override
  String get onboardingPhotoSelect => 'Profilfoto auswählen oder ändern';

  @override
  String get onboardingUsernameExample => 'z. B. vibra_user';

  @override
  String get onboardingRequired => 'ERFORDERLICH';

  @override
  String get onboardingSpotifyBody =>
      'Finde Events anhand deiner Hörgewohnheiten und entdecke musikalische Übereinstimmungen mit anderen.';

  @override
  String get onboardingSpotifyCancelled =>
      'Verbindung abgebrochen. Versuche es erneut oder überspringe den Schritt.';

  @override
  String get onboardingSpotifyError =>
      'Verbindung fehlgeschlagen. Versuche es später erneut.';

  @override
  String get onboardingLocationTitle => 'Events in deiner Nähe';

  @override
  String get onboardingLocationBody =>
      'Aktiviere den Standort, um Konzerte und Veranstaltungsorte in deiner Nähe zu entdecken.';

  @override
  String get onboardingLocationDenied =>
      'Berechtigung dauerhaft verweigert. Du kannst sie später in den Geräteeinstellungen aktivieren.';

  @override
  String get onboardingAllowLocation => 'Standort erlauben';

  @override
  String get onboardingNotificationsTitle => 'Bleib auf dem Laufenden';

  @override
  String get onboardingNotificationsBody =>
      'Erhalte Benachrichtigungen zu gespeicherten Events, Freundschaftsanfragen und Nachrichten.';

  @override
  String get onboardingNotificationsDenied =>
      'Benachrichtigungen verweigert. Du kannst sie in den Geräteeinstellungen aktivieren.';

  @override
  String get onboardingAllowNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get liveAttendanceError =>
      'Teilnahme konnte nicht bestätigt werden. Versuche es erneut.';

  @override
  String get liveEventsLoadError => 'Live-Events konnten nicht geladen werden.';

  @override
  String get liveLocationHelp =>
      'Live-Chat ist im Umkreis von 500 m eines Events während der 24 Stunden vor und nach dem Konzert verfügbar. Aktiviere den Standort in den Datenschutzeinstellungen.';

  @override
  String get liveUnavailableHere =>
      'Der Chat für dieses Event ist an deinem Standort oder zu diesem Zeitpunkt nicht verfügbar.';

  @override
  String get liveRefreshLocation => 'Standort aktualisieren';

  @override
  String get liveEventTitle => 'Live-Event';

  @override
  String get liveConnectionInterrupted =>
      'Verbindung zum Live-Chat unterbrochen.';

  @override
  String get liveEmpty => 'Noch keine Nachrichten. Starte die Unterhaltung!';

  @override
  String get liveRetryAttendance => 'Teilnahme erneut prüfen';

  @override
  String get liveConfirmingAttendance => 'Teilnahme wird bestätigt…';

  @override
  String get liveJoinToChat => 'Nimm am Event teil, um im Chat zu schreiben';

  @override
  String get liveInputHint => 'Schreibe im Live-Chat…';

  @override
  String get liveSendMessage => 'Live-Nachricht senden';

  @override
  String get musicReconnect => 'Erneut verbinden';

  @override
  String get musicReconnectBody =>
      'Verbinde Spotify erneut, um die Musikstatistik zu aktualisieren.';

  @override
  String get musicStatsUpdated => 'Musikstatistik aktualisiert.';

  @override
  String get musicStatsRefreshing => 'Musikstatistik wird aktualisiert';

  @override
  String get musicStatsNoArtists =>
      'Nach der letzten Synchronisierung sind keine Künstler verfügbar.';

  @override
  String get musicStatsEmptyTitle => 'Gib deinem Profil einen Sound.';

  @override
  String get musicStatsEmptyBody =>
      'Verbinde Spotify, um deine Künstler und Rhythmen zu sehen.';

  @override
  String get musicStatsYourSound => 'DEIN SOUND';

  @override
  String get musicStatsHeroTitle => 'Musik, die dich ausmacht.';

  @override
  String get musicStatsArtists => 'Künstler';

  @override
  String get musicStatsRhythm => 'Rhythmus';

  @override
  String get spotifyBackToLogin => 'Zurück zur Anmeldung';

  @override
  String get spotifyConsentBody =>
      'Durch die Verbindung mit Spotify darf Vibra dein Profil und deine wichtigsten Künstler, Titel und Genres lesen. Wir nutzen sie für Event-Vorschläge und musikalische Übereinstimmungen. Du kannst Spotify in den Einstellungen trennen und die Daten löschen.';

  @override
  String get eventBackToEvents => 'Zurück zu den Events';

  @override
  String get eventPrice => 'Preis';

  @override
  String get eventVenueTBA => 'Veranstaltungsort folgt';

  @override
  String eventOpenSemantics(String name, String date, String place) {
    return 'Event öffnen: $name, $date, $place';
  }

  @override
  String eventAffinitySemantics(int percentage) {
    return '$percentage Prozent Übereinstimmung';
  }

  @override
  String eventForYouScore(int percentage) {
    return '$percentage% FÜR DICH';
  }

  @override
  String eventCommonSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemeinsame oder gespeicherte Events',
      one: '$count gemeinsames oder gespeichertes Event',
    );
    return '$_temp0';
  }

  @override
  String get supportReportTitle => 'Problem melden';

  @override
  String get supportReportIntro =>
      'Beschreibe, was nicht funktioniert. Wir fügen App-Version, Betriebssystem und einige Diagnosedaten ohne sensible Informationen hinzu.';

  @override
  String get supportDescriptionLabel => 'Problembeschreibung';

  @override
  String get supportDescriptionHint =>
      'Nenne den Bildschirm, die Schritte und das erwartete Ergebnis.';

  @override
  String get supportAddScreenshot => 'Screenshot hinzufügen';

  @override
  String get supportScreenshotAttached => 'Screenshot angehängt';

  @override
  String get supportRemoveScreenshot => 'Screenshot entfernen';

  @override
  String get supportScreenshotPrivacy =>
      'Prüfe, dass der Screenshot keine Passwörter, privaten Nachrichten oder anderen sensiblen Daten zeigt.';

  @override
  String get supportSending => 'Wird gesendet…';

  @override
  String get supportSendReport => 'Meldung senden';

  @override
  String get supportDescriptionTooShort =>
      'Beschreibe das Problem mit mindestens 8 Zeichen.';

  @override
  String get supportDescriptionTooLong =>
      'Die Beschreibung darf höchstens 4000 Zeichen enthalten.';

  @override
  String get supportReportSentTitle => 'Meldung gesendet';

  @override
  String get supportReportSentBody =>
      'Wir haben deine Meldung erhalten. Der Support antwortet innerhalb von 48 Geschäftsstunden.';

  @override
  String supportReportSendFailed(String email) {
    return 'Die Meldung konnte nicht gesendet werden. Versuche es erneut oder schreibe an $email.';
  }

  @override
  String get supportReportAuthRequired =>
      'Melde dich erneut an, um die Meldung zu senden.';

  @override
  String get supportReportRateLimited =>
      'Du hast zu viele Meldungen gesendet. Warte eine Minute und versuche es erneut.';

  @override
  String get supportScreenshotTooLarge =>
      'Der Screenshot muss kleiner als 5 MB sein.';

  @override
  String get supportScreenshotUnsupported =>
      'Wähle einen Screenshot im JPG- oder PNG-Format.';

  @override
  String get supportScreenshotPickFailed =>
      'Der Screenshot konnte nicht ausgewählt werden. Versuche es erneut.';

  @override
  String get supportScreenshotPermissionDenied =>
      'Erlaube den Fotozugriff in den Geräteeinstellungen, um einen Screenshot anzuhängen.';

  @override
  String supportAlternativeContact(String email) {
    return 'Du kannst auch an $email schreiben. Wir antworten innerhalb von 48 Geschäftsstunden.';
  }

  @override
  String get supportFeedbackTitle => 'Wie läuft es mit Vibra?';

  @override
  String get supportFeedbackBody =>
      'Dein Feedback hilft uns, besser zu werden.';

  @override
  String get supportFeedbackNegative => 'Nicht gut';

  @override
  String get supportFeedbackNeutral => 'Geht so';

  @override
  String get supportFeedbackPositive => 'Gut!';

  @override
  String get supportFeedbackDescriptionPrefix => 'Feedback:';

  @override
  String get chatSendFriendshipRequired =>
      'Sende dieser Person eine Freundschaftsanfrage und warte auf ihre Annahme, um ihr zu schreiben.';

  @override
  String get chatSendFirstContactLimit =>
      'Du hast bereits 3 Nachrichten gesendet. Warte auf eine Antwort, bevor du weitere sendest.';

  @override
  String get chatSendUnavailable => 'Diese Unterhaltung ist nicht verfügbar.';

  @override
  String get chatSendRateLimited =>
      'Du sendest zu viele Nachrichten. Warte eine Minute und versuche es erneut.';

  @override
  String get chatSendSignInRequired =>
      'Melde dich erneut an, um die Nachricht zu senden.';

  @override
  String get chatRequestFriendship => 'Freundschaft anfragen';

  @override
  String get chatFriendshipRequestSent => 'Freundschaftsanfrage gesendet';

  @override
  String get chatFriendshipRequestFailed =>
      'Die Freundschaftsanfrage konnte nicht gesendet werden. Versuche es erneut.';

  @override
  String get chatMessageTooLong =>
      'Die Nachricht darf höchstens 2000 Zeichen enthalten.';

  @override
  String get chatPermissionChecking => 'Unterhaltung wird geprüft…';

  @override
  String get chatFriendshipRequestPending =>
      'Freundschaftsanfrage wartet auf Annahme';

  @override
  String get chatAcceptFriendship => 'Freundschaft annehmen';

  @override
  String get chatFriendshipAccepted =>
      'Freundschaft angenommen. Du kannst jetzt Nachrichten senden.';

  @override
  String get socialReportUser => 'Nutzer melden';

  @override
  String get socialReportSpam => 'Spam';

  @override
  String get socialReportHarassment => 'Belästigung';

  @override
  String get socialReportInappropriate => 'Unangemessener Inhalt';

  @override
  String get socialReportDetailsHint => 'Zusätzliche Details (optional)';

  @override
  String get socialReportSent => 'Nutzer gemeldet';

  @override
  String get socialReportFailed =>
      'Die Meldung konnte nicht gesendet werden. Versuche es erneut.';

  @override
  String get socialReportAction => 'Melden';

  @override
  String get socialBlockUser => 'Nutzer blockieren';

  @override
  String get socialBlockConfirm =>
      'Diese Person blockieren? Ihr könnt dann keine Nachrichten mehr austauschen.';

  @override
  String get socialBlockSuccess => 'Nutzer blockiert';

  @override
  String get socialBlockFailed =>
      'Diese Person konnte nicht blockiert werden. Versuche es erneut.';

  @override
  String get socialBlockAction => 'Blockieren';

  @override
  String get chatRequestTitle => 'Nachrichtenanfrage';

  @override
  String chatRequestBody(String name) {
    return '$name möchte dir schreiben. Antworte, um die Unterhaltung anzunehmen.';
  }

  @override
  String get chatRequestRejected => 'Anfrage abgelehnt und gelöscht';

  @override
  String get chatRequestRejectFailed =>
      'Die Anfrage konnte nicht gelöscht werden. Versuche es erneut.';

  @override
  String get commonReject => 'Ablehnen';

  @override
  String get commonReply => 'Antworten';

  @override
  String get userProfileView => 'Profil ansehen';

  @override
  String get chatConnectionInterrupted => 'Chat-Verbindung unterbrochen.';

  @override
  String get chatMeetupTitle => 'Treffvorschlag';

  @override
  String get chatMeetupAccept => 'Ich bin dabei';

  @override
  String get chatMeetupDecline => 'Ich kann nicht';

  @override
  String chatMeetupAcceptMessage(String message) {
    return 'Ich bin dabei! $message';
  }

  @override
  String chatMeetupDeclineMessage(String message) {
    return 'Ich kann nicht teilnehmen. $message';
  }

  @override
  String get helpIntro =>
      'Schnelle Antworten und Hilfe. Wir antworten innerhalb von 48 Geschäftsstunden.';

  @override
  String get helpSearchHint => 'Häufige Fragen durchsuchen';

  @override
  String get helpSearchEmpty =>
      'Keine Antwort gefunden. Versuche eine andere Suche.';

  @override
  String get helpNeedMore => 'Brauchst du noch Hilfe?';

  @override
  String get helpCategoryAll => 'Alle';

  @override
  String get helpCategoryAccount => 'Konto';

  @override
  String get helpCategoryChatMatch => 'Chat und Übereinstimmung';

  @override
  String get helpCategoryPrivacy => 'Datenschutz';

  @override
  String get helpLoginQuestion => 'Ich kann mich nicht anmelden';

  @override
  String get helpLoginAnswer =>
      'Prüfe E-Mail und Passwort und öffne Vibra erneut. Falls es weiter nicht klappt, nutze „Problem melden“ und nenne deine Anmeldemethode.';

  @override
  String get helpLogoutQuestion => 'Wie melde ich mich ab?';

  @override
  String get helpLogoutAnswer =>
      'Gehe zu Profil > Einstellungen > Abmelden. Wähle „Auf allen Geräten abmelden“, um alle Sitzungen zu beenden.';

  @override
  String get helpDeleteQuestion => 'Wie lösche ich mein Konto?';

  @override
  String get helpDeleteAnswer =>
      'Gehe zu Profil > Einstellungen > Konto löschen. Die Bestätigung entfernt Kontodaten gemäß der Datenschutzerklärung.';

  @override
  String get helpEventsQuestion =>
      'Warum sehe ich keine Events in meiner Nähe?';

  @override
  String get helpEventsAnswer =>
      'Prüfe den Standortzugriff und vergrößere den Suchradius. Die Verfügbarkeit hängt von den örtlichen Event-Quellen ab. Du kannst auch eine Stadt suchen.';

  @override
  String get helpTicketsQuestion =>
      'Ein Event oder Ticket-Link lässt sich nicht öffnen';

  @override
  String get helpTicketsAnswer =>
      'Events und Tickets stammen von externen Partnern. Versuche es später erneut. Falls das Problem bleibt, melde es mit Angabe des Events.';

  @override
  String get helpAffinityQuestion => 'Wie wird die Übereinstimmung berechnet?';

  @override
  String get helpAffinityAnswer =>
      'Der Wert vergleicht gemeinsame Künstler und Genres, mit einem kleinen Bonus für seltenere Vorlieben. Er zeigt Ähnlichkeiten, bietet aber keine Garantie.';

  @override
  String get helpBlockQuestion => 'Wie blockiere oder melde ich jemanden?';

  @override
  String get helpBlockAnswer =>
      'Öffne die Unterhaltung und nutze das Menü, um die Person zu blockieren oder zu melden. Blockieren verhindert künftige Interaktionen; Meldungen gehen an das Team.';

  @override
  String get helpSpotifyConnectQuestion => 'Wie verbinde ich Spotify?';

  @override
  String get helpSpotifyConnectAnswer =>
      'Gehe zu Profil > Einstellungen > Spotify-Konto und schließe die Autorisierung bei Spotify ab. Du kehrst automatisch zu Vibra zurück.';

  @override
  String get helpSpotifyDisconnectQuestion => 'Wie trenne ich Spotify?';

  @override
  String get helpSpotifyDisconnectAnswer =>
      'Gehe zu Profil > Einstellungen > Spotify-Konto und wähle „Trennen“.';

  @override
  String get helpSpotifyErrorQuestion => 'Spotify-Verbindung schlägt fehl';

  @override
  String get helpSpotifyErrorAnswer =>
      'Prüfe die Verbindung und schließe die Autorisierung ab. Teile keine Passwörter oder Tokens mit dem Support. Meldungen enthalten nur bereinigte Diagnosedaten.';

  @override
  String get helpReportDataQuestion =>
      'Welche Daten sendet eine Problemmeldung?';

  @override
  String get helpReportDataAnswer =>
      'App-Version, Betriebssystem, letzter fehlgeschlagener Endpoint und einige technische Logs ohne sensible Daten. Ein Screenshot ist optional. Prüfe, dass er keine privaten Informationen enthält.';

  @override
  String get helpPrivacyQuestion => 'Wie übe ich meine Datenschutzrechte aus?';

  @override
  String helpPrivacyAnswer(String email) {
    return 'Gehe zu Profil > Einstellungen > Datenschutz und persönliche Daten, um Einwilligungen zu verwalten und Daten zu exportieren. Schreibe für weitere Anfragen an $email.';
  }

  @override
  String get exploreEyebrow => 'EVENTS IN DEINER NÄHE';

  @override
  String get exploreClearSearch => 'Suche löschen';

  @override
  String exploreEventsVisible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count EVENTS IM BLICK',
      one: '$count EVENT IM BLICK',
    );
    return '$_temp0';
  }

  @override
  String get commonReset => 'Zurücksetzen';

  @override
  String get exploreLoadErrorTitle => 'Events konnten nicht geladen werden.';

  @override
  String get exploreLoadErrorBody =>
      'Prüfe deine Verbindung und suche erneut in diesem Bereich.';

  @override
  String get exploreEmptyTitle => 'Keine Events in diesem Bereich gefunden.';

  @override
  String get exploreEmptyBody =>
      'Vergrößere den Radius oder ändere die Filter.';

  @override
  String get exploreZoomIn => 'Karte vergrößern';

  @override
  String get exploreZoomOut => 'Karte verkleinern';

  @override
  String exploreOpenEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Liste mit $count Events öffnen',
      one: 'Liste mit $count Event öffnen',
    );
    return '$_temp0';
  }

  @override
  String get exploreMoveMapHint => 'Verschiebe die Karte, um Events zu suchen';

  @override
  String exploreEventsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Events in diesem Bereich',
      one: '$count Event in diesem Bereich',
    );
    return '$_temp0';
  }

  @override
  String get exploreCloseEvents => 'Event-Liste schließen';

  @override
  String get exploreGenreElectronic => 'Elektronisch';

  @override
  String get exploreGenreAlternative => 'Alternative';

  @override
  String get commonLinkOpenError => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get authConfirmEmail =>
      'Wir haben dir eine Bestätigungs-E-Mail gesendet. Prüfe dein Postfach, bevor du dich anmeldest.';

  @override
  String get authEmailNotConfirmed =>
      'Bestätige zuerst deine E-Mail-Adresse. Prüfe dein Postfach.';

  @override
  String get authInvalidCredentials =>
      'E-Mail oder Passwort ist falsch. Prüfe beides und versuche es erneut.';

  @override
  String get authProviderUnavailable =>
      'Diese Anmeldemethode ist nicht verfügbar. Nutze E-Mail oder versuche es später erneut.';

  @override
  String get authEmailAlreadyRegistered =>
      'Diese E-Mail-Adresse ist bereits registriert. Versuche dich anzumelden.';

  @override
  String get authWeakPassword =>
      'Wähle ein stärkeres Passwort und versuche es erneut.';

  @override
  String get errorNetwork =>
      'Keine Verbindung verfügbar. Prüfe dein Netzwerk und versuche es erneut.';

  @override
  String get errorSessionChanged =>
      'Deine Sitzung hat sich geändert. Melde dich erneut an und versuche es noch einmal.';

  @override
  String get errorRateLimited =>
      'Zu viele Anfragen. Warte eine Minute und versuche es erneut.';

  @override
  String get errorActionFailed =>
      'Die Aktion ist fehlgeschlagen. Versuche es gleich erneut.';

  @override
  String get socialAffinity => 'Übereinstimmung';

  @override
  String get socialFollow => 'Folgen';

  @override
  String get socialFollowing => 'Gefolgt';

  @override
  String get socialFollowUpdateError =>
      'Der Folgestatus konnte nicht aktualisiert werden. Versuche es erneut.';

  @override
  String get socialMessageAction => 'Nachricht senden';

  @override
  String get socialFriendRequestSentShort => 'Gesendet';

  @override
  String get socialFriendRequestError =>
      'Die Anfrage konnte nicht gesendet werden. Versuche es erneut.';

  @override
  String get socialAddFriend => 'Hinzufügen';

  @override
  String get socialCommonArtists => 'Gemeinsame Künstler';

  @override
  String get socialUsersLoadError => 'Personen konnten nicht geladen werden.';

  @override
  String socialFollowersCount(int count) {
    return 'Follower ($count)';
  }

  @override
  String socialFollowingCount(int count) {
    return 'Gefolgt ($count)';
  }

  @override
  String get socialNoFollowers => 'Keine Follower';

  @override
  String get socialNoFollowersBody =>
      'Personen, die diesem Profil folgen, erscheinen hier.';

  @override
  String get socialNoFollowing => 'Folgt noch niemandem';

  @override
  String get socialNoFollowingBody => 'Gefolgte Profile erscheinen hier.';

  @override
  String get friendsRequestUpdateError =>
      'Die Anfrage konnte nicht aktualisiert werden. Versuche es erneut.';

  @override
  String get friendsRemoveTitle => 'Freundschaft entfernen';

  @override
  String friendsRemoveBody(String name) {
    return '$name aus deinen Freunden entfernen?';
  }

  @override
  String friendsRemoved(String name) {
    return '$name aus Freunden entfernt';
  }

  @override
  String get friendsRemoveError =>
      'Diese Freundschaft konnte nicht entfernt werden. Versuche es erneut.';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get friendsConnectionsTitle => 'Freunde und Kontakte';

  @override
  String friendsCount(int count) {
    return 'Freunde ($count)';
  }

  @override
  String get friendsReceived => 'Empfangen';

  @override
  String friendsSentCount(int count) {
    return 'Gesendet ($count)';
  }

  @override
  String get friendsSearchHint => 'Freunde durchsuchen…';

  @override
  String get friendsNoneFound => 'Keine Freunde gefunden';

  @override
  String get friendsFindBody =>
      'Entdecke Profile, sende Freundschaftsanfragen und teile Events.';

  @override
  String get friendsFindPeople => 'Personen finden';

  @override
  String get friendsNoReceived => 'Keine Anfragen erhalten';

  @override
  String get friendsNoReceivedBody =>
      'Hier erscheinen Freundschaftsanfragen von anderen.';

  @override
  String get friendsVibraUser => 'Vibra-Nutzer';

  @override
  String get friendsNoSent => 'Keine Anfragen gesendet';

  @override
  String get friendsNoSentBody =>
      'Hier erscheinen gesendete Freundschaftsanfragen, die auf Antwort warten.';

  @override
  String inboxOpenConversation(String name) {
    return 'Unterhaltung mit $name öffnen';
  }

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Nachrichten',
      one: '$count ungelesene Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get inboxEyebrow => 'IN KONTAKT';

  @override
  String get inboxMessages => 'Nachrichten';

  @override
  String get inboxDirect => 'Direkt';

  @override
  String get inboxRequests => 'Anfragen';

  @override
  String get inboxSearchHint => 'Unterhaltung suchen';

  @override
  String get inboxClearSearch => 'Unterhaltungssuche löschen';

  @override
  String get inboxRefreshError =>
      'Unterhaltungen konnten nicht aktualisiert werden.';

  @override
  String get inboxEmptyTitle => 'Noch keine Unterhaltungen.';

  @override
  String get inboxEmptyBody =>
      'Finde jemanden für ein gemeinsames Konzert und starte eine Unterhaltung.';

  @override
  String get inboxNoRequests => 'Keine ausstehenden Anfragen.';

  @override
  String get inboxNoRequestsBody => 'Hier erscheinen neue Nachrichtenanfragen.';

  @override
  String get socialMatchSend => 'SENDEN';

  @override
  String get socialMatchPass => 'WEITER';

  @override
  String get socialMatchSharedListening =>
      'Deine Musik hat Gemeinsamkeiten gefunden.';

  @override
  String get socialYou => 'Du';

  @override
  String get socialMatchFrequencyNow => 'gleiche Frequenz, jetzt';

  @override
  String get socialMatchSharedSound => 'GEMEINSAME MUSIK';

  @override
  String get socialMatchSameArea => 'GLEICHE GEGEND';

  @override
  String get friendsLoadError =>
      'Freunde konnten nicht geladen werden. Versuche es erneut.';
}
