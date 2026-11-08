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
      'Vibra löscht deine Spotify-Verbindung, synchronisierte Künstler und Genres, deinen Hörverlauf und musikalische Übereinstimmungen. Event-Vorschläge sind dann nicht mehr personalisiert.';

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
  String get socialPeopleSection => 'Personen';

  @override
  String get socialAffinityTitle => 'Finde deine musikalischen Matches';

  @override
  String socialRequestsPreview(String name, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$name und $others weitere möchten sich verbinden',
      one: '$name und 1 weitere Person möchten sich verbinden',
      zero: '$name möchte sich mit dir verbinden',
    );
    return '$_temp0';
  }

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
      'Vibra liest dein Spotify-Profil, deine meistgehörten Künstler, Titel und Genres der letzten ~6 Monate sowie die Zeitpunkte deiner letzten Wiedergaben. Wir nutzen sie für Musikstatistiken, Event-Vorschläge und musikalische Übereinstimmung. Deine Spotify-Zugangsdaten bleiben verschlüsselt auf unseren Servern, nie auf diesem Gerät. Du kannst Spotify jederzeit in den Einstellungen trennen und diese Daten löschen.';

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

  @override
  String get matchTierHigh => 'Hohe Übereinstimmung';

  @override
  String get matchTierMedium => 'Gute Übereinstimmung';

  @override
  String get matchTierLow => 'Geringe Übereinstimmung';

  @override
  String get eventStatusUpcoming => 'Demnächst';

  @override
  String get eventStatusToday => 'Heute';

  @override
  String get eventStatusSoldOut => 'Ausverkauft';

  @override
  String get eventStatusCancelled => 'Abgesagt';

  @override
  String get eventStatusPostponed => 'Verschoben';

  @override
  String get eventStatusPast => 'Vorbei';

  @override
  String eventPriceFrom(String price) {
    return 'Ab $price';
  }

  @override
  String get offlineTitle => 'Du bist offline';

  @override
  String get homeSpotifyBannerTitle => 'Verbinde deinen Sound';

  @override
  String get homeUpNext => 'ALS NÄCHSTES';

  @override
  String get homeSpotifyConnectedTitle => 'Spotify verbunden';

  @override
  String get spotifyConsentSharing =>
      'Personen mit aktivierter musikalischer Übereinstimmung sehen nur deinen Übereinstimmungswert sowie gemeinsame Künstler und Genres, nie deinen Hörverlauf.';

  @override
  String get spotifySyncFailedTitle =>
      'Spotify ist verbunden, aber deine Musik wurde noch nicht geladen.';

  @override
  String get spotifySyncRetry => 'Synchronisierung wiederholen';

  @override
  String get spotifyRevokedBody =>
      'Der Zugriff von Vibra wurde in deinem Spotify-Konto entfernt. Wir haben die Verbindung getrennt und die synchronisierten Daten gelöscht. Verbinde dich erneut, um Statistiken und Übereinstimmungen wiederherzustellen.';

  @override
  String get spotifyRateLimited =>
      'Spotify ist gerade ausgelastet. Versuche es in einer Minute erneut.';

  @override
  String get settingsSpotifyDisconnectError =>
      'Spotify konnte nicht getrennt werden. Versuche es erneut.';

  @override
  String get socialConnectSpotifyBody =>
      'Verbinde Spotify, um Menschen zu treffen, die hören, was du liebst.';

  @override
  String socialAffinityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen teilen deinen Geschmack',
      one: '1 Person teilt deinen Geschmack',
      zero: 'Noch keine neuen Übereinstimmungen',
    );
    return '$_temp0';
  }

  @override
  String get spotifyAccessNotGranted =>
      'Spotify hat Vibra für dein Konto noch nicht freigeschaltet. Alles andere in Vibra funktioniert wie gewohnt; versuche es später erneut.';

  @override
  String get spotifyConnectFailed =>
      'Spotify konnte die Verbindung nicht abschließen. Versuche es gleich noch einmal.';

  @override
  String get settingsSectionMusic => 'Musik';

  @override
  String get settingsSectionGeneral => 'Allgemein';

  @override
  String get settingsSectionHelp => 'Hilfe';

  @override
  String get settingsSectionLegal => 'Rechtliches';

  @override
  String get settingsSectionAccount => 'Konto';

  @override
  String get settingsDeleteAccountSub => 'Konto und Daten endgültig löschen';

  @override
  String get settingsEditProfileSub => 'Name, Foto, Bio und Benutzername';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get profileStatEvents => 'Events';

  @override
  String get profileSpotifyBenefits =>
      'Statistiken · Übereinstimmung · Für dich';

  @override
  String get appearanceAuto => 'Automatisch';

  @override
  String get affinityCategoryExceptional =>
      'Außergewöhnliche musikalische Affinität';

  @override
  String get affinityCategoryVeryHigh => 'Sehr hohe Affinität';

  @override
  String get affinityCategoryHigh => 'Hohe Affinität';

  @override
  String get affinityCategoryModerate => 'Mittlere Affinität';

  @override
  String get affinityCategoryLow => 'Unterschiedliche Sounds';

  @override
  String get affinityCategoryVeryLow => 'Neue Musikwelten';

  @override
  String affinityHeadline(int percent) {
    return '$percent % musikalische Affinität';
  }

  @override
  String get affinitySharedGenres => 'Eure gemeinsamen Genres';

  @override
  String get affinityTheirGenres => 'Ihre Hauptgenres';

  @override
  String get affinityArtistsInCommon => 'Gemeinsame Künstler';

  @override
  String get affinityWhy => 'Warum ihr zusammenpasst';

  @override
  String get affinityQuoteExceptional => 'Ihr scheint Musik gleich zu hören.';

  @override
  String get affinityQuoteVeryHigh =>
      'Euer Musikgeschmack hat sehr viel gemeinsam.';

  @override
  String get affinityQuoteHigh => 'Euer Musikgeschmack hat viel gemeinsam.';

  @override
  String get affinityQuoteModerate =>
      'Ihr teilt einige Sounds und könnt andere entdecken.';

  @override
  String get affinityQuoteDiscovery =>
      'Verschiedene Welten: eine Chance, neue Musik zu entdecken.';

  @override
  String affinityReasonSharedFamilies(String genres) {
    return 'Ihr hört beide vor allem $genres.';
  }

  @override
  String affinityReasonSharedSubgenres(String genres) {
    return 'Ihr teilt die Liebe zu $genres.';
  }

  @override
  String affinityReasonDifferentSubgenres(String genre) {
    return 'Ihr liebt beide $genre, aber unterschiedliche Subgenres.';
  }

  @override
  String affinityReasonRelatedFamilies(String first, String second) {
    return '$first und $second liegen musikalisch nah beieinander.';
  }

  @override
  String affinityReasonSharedArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ihr teilt $count Lieblingskünstler.',
      one: 'Ihr teilt 1 Lieblingskünstler.',
    );
    return '$_temp0';
  }

  @override
  String get affinityReasonDiscovery =>
      'Unterschiedlicher Geschmack: gut, um Neues zu entdecken.';

  @override
  String get affinityListSeparator => ' und ';

  @override
  String get genreFamilyHipHop => 'Hip-Hop';

  @override
  String get genreFamilyRnb => 'R&B';

  @override
  String get genreFamilyElectronic => 'Elektronik';

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
  String get genreFamilyLatin => 'Latin';

  @override
  String get genreFamilyAfro => 'Afro';

  @override
  String get genreFamilyCountry => 'Country';

  @override
  String get genreFamilyFolk => 'Folk';

  @override
  String get genreFamilyClassical => 'Klassik';

  @override
  String get genreFamilySoundtrack => 'Soundtracks';

  @override
  String get genreFamilyGospel => 'Gospel & christlich';

  @override
  String get genreFamilyWorld => 'Weltmusik';

  @override
  String get musicGenresTitle => 'Deine Genres';

  @override
  String get musicGenresSubtitle =>
      'Wähle die Genres, die du liebst: So finden wir Menschen mit ähnlichem Geschmack, mit oder ohne Spotify.';

  @override
  String get musicGenresSpotifyNote =>
      'Spotify ist verbunden: Diese Genres ergänzen die aus deinem Hörverhalten.';

  @override
  String get musicGenresSearchHint => 'Genre suchen';

  @override
  String get musicGenresNoResults => 'Kein Genre gefunden';

  @override
  String musicGenresSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Genres gewählt',
      one: '1 Genre gewählt',
      zero: 'Kein Genre gewählt',
    );
    return '$_temp0';
  }

  @override
  String get musicGenresYourPicks => 'Deine Auswahl';

  @override
  String get musicGenresLevelLike => 'Mag ich';

  @override
  String get musicGenresLevelMuch => 'Sehr';

  @override
  String get musicGenresLevelLove => 'Liebe ich';

  @override
  String get musicGenresIntensityHint =>
      'Tippe auf ein gewähltes Genre, um anzugeben, wie sehr du es magst.';

  @override
  String musicGenresRemove(String genre) {
    return '$genre entfernen';
  }

  @override
  String get musicGenresLimit => 'Du kannst bis zu 30 Genres wählen.';

  @override
  String get musicGenresMatching =>
      'Mich Menschen mit ähnlichem Geschmack zeigen';

  @override
  String get musicGenresMatchingBody =>
      'Sie sehen nur euren Affinitätswert und gemeinsame Genres und Künstler.';

  @override
  String get musicGenresSave => 'Speichern';

  @override
  String get musicGenresSaved =>
      'Genres gespeichert. Deine Affinitäten werden aktualisiert.';

  @override
  String get musicGenresSaveError =>
      'Genres konnten nicht gespeichert werden. Versuche es erneut.';

  @override
  String get musicGenresLoadError =>
      'Deine Genres konnten nicht geladen werden.';

  @override
  String get musicGenresEntry => 'Lieblingsgenres';

  @override
  String get musicGenresEntrySub => 'Wähle deine Genres, auch ohne Spotify';

  @override
  String get socialAffinityPickGenres => 'Oder wähle deine Genres';

  @override
  String get socialAffinityPickGenresBody =>
      'Wähle deine Lieblingsgenres, um Menschen mit ähnlichem Geschmack zu treffen.';

  @override
  String get privacyMusicAffinity => 'Musikalische Affinität';

  @override
  String get privacyMusicAffinityBody =>
      'Nutzt deine Spotify-Daten und gewählten Genres für Vorschläge und Affinität.';

  @override
  String get musicalDnaTitle => 'Musik-DNA';

  @override
  String get musicalDnaEyebrow => 'Deine musikalische Identität';

  @override
  String musicalDnaUserTitle(String name) {
    return 'Musik-DNA von $name';
  }

  @override
  String get musicalDnaUserEyebrow => 'Musikalische Identität';

  @override
  String get musicalDnaDistribution => 'Genreverteilung';

  @override
  String get musicalDnaDistributionSub =>
      'Wie sich dein Geschmack auf Genrefamilien verteilt';

  @override
  String musicalDnaArtistsVia(String artists) {
    return 'Über $artists';
  }

  @override
  String get musicalDnaDiversity => 'Vielfalt';

  @override
  String get musicalDnaDiversityFocused => 'Fokussiert';

  @override
  String get musicalDnaDiversityBalanced => 'Ausgewogen';

  @override
  String get musicalDnaDiversityEclectic => 'Eklektisch';

  @override
  String get musicalDnaDiversityFocusedBody =>
      'Deine Identität lebt in wenigen, nahen Sounds.';

  @override
  String get musicalDnaDiversityBalancedBody =>
      'Ein klarer Kern, mit Raum für andere Welten.';

  @override
  String get musicalDnaDiversityEclecticBody =>
      'Dein Geschmack bewegt sich frei zwischen sehr verschiedenen Welten.';

  @override
  String musicalDnaDiversityCounts(String families, String subgenres) {
    return '$families Familien · $subgenres Subgenres';
  }

  @override
  String get musicalDnaEvolution => 'Entwicklung';

  @override
  String get musicalDnaEvolutionSub =>
      'Wie sich deine DNA mit deinem Hören verändert';

  @override
  String musicalDnaEvolutionEmpty(String date) {
    return 'Erfasst seit $date. Veränderungen erscheinen hier, sobald sich dein Hören entwickelt.';
  }

  @override
  String musicalDnaShiftSince(String date) {
    return 'Seit $date';
  }

  @override
  String get musicalDnaNoShift =>
      'Stabil: Keine Familie hat sich um mehr als 3 Punkte verändert.';

  @override
  String musicalDnaShiftSemantics(String family, String from, String to) {
    return '$family, von $from auf $to Prozent';
  }

  @override
  String get musicalDnaSources => 'Basierend auf';

  @override
  String musicalDnaSourceArtists(String classified, String total) {
    return '$classified deiner $total meistgehörten Spotify-Künstler (letzte 6 Monate)';
  }

  @override
  String get musicalDnaSourceSpotifyGenres =>
      'Den Genres deiner meistgehörten Spotify-Künstler (letzte 6 Monate)';

  @override
  String musicalDnaSourceTracks(String count) {
    return 'Deinen $count meistgehörten Spotify-Titeln';
  }

  @override
  String musicalDnaSourceGenres(String count) {
    return '$count von dir gewählten Genres';
  }

  @override
  String get musicalDnaEditGenres => 'Deine Genres bearbeiten';

  @override
  String get musicalDnaVisibility => 'Wer sie sehen kann';

  @override
  String get musicalDnaVisibilityPublic => 'Alle';

  @override
  String get musicalDnaVisibilityMatches => 'Matches';

  @override
  String get musicalDnaVisibilityPrivate => 'Nur ich';

  @override
  String get musicalDnaVisibilityPublicBody =>
      'Alle auf Vibra können deine Musik-DNA auf deinem Profil sehen.';

  @override
  String get musicalDnaVisibilityMatchesBody =>
      'Nur Personen, mit denen du eine musikalische Affinität oder eine Verbindung hast.';

  @override
  String get musicalDnaVisibilityPrivateBody =>
      'Nur du kannst sie sehen. Sie prägt trotzdem deine Vorschläge.';

  @override
  String get musicalDnaVisibilityError =>
      'Deine Auswahl konnte nicht gespeichert werden. Versuch es erneut.';

  @override
  String get musicalDnaEmptyTitle => 'Noch keine Musik-DNA';

  @override
  String get musicalDnaEmptyBody =>
      'Verbinde Spotify oder wähle ein paar Genres, die du liebst – daraus entsteht deine DNA.';

  @override
  String get musicalDnaPickGenres => 'Genres wählen';

  @override
  String get musicalDnaLoadError =>
      'Deine Musik-DNA konnte nicht geladen werden.';

  @override
  String musicalDnaUpdated(String date) {
    return 'Aktualisiert am $date';
  }

  @override
  String musicalDnaFamilySemantics(String family, String percent) {
    return '$family, $percent Prozent';
  }

  @override
  String get musicalDnaProfileTile => 'Musik-DNA';

  @override
  String get musicalDnaProfileTileSubtitle =>
      'Deine Genres, deine Vielfalt und ihre Entwicklung';

  @override
  String get musicalDnaSeeFull => 'Ganze DNA ansehen';

  @override
  String affinityReasonCommonGround(String genres) {
    return 'Ihr hört beide $genres, in unterschiedlichem Maß.';
  }

  @override
  String get affinityReasonBothEclectic =>
      'Ihr seid beide eklektische Hörer, zwischen sehr verschiedenen Genres.';

  @override
  String get affinityReasonBothFocused =>
      'Ihr bleibt beide nah an eurem Kernsound.';

  @override
  String get affinityReasonDiversityContrast =>
      'Eine:r von euch erkundet viel, die andere Person bleibt fokussiert: viel zu teilen.';

  @override
  String affinityHeadlineSentence(int percent) {
    return 'Ihr habt $percent % musikalische Affinität.';
  }

  @override
  String get sameFrequencyTitle => 'Same Frequency';

  @override
  String get sameFrequencyHeadline => 'Ihr seid auf derselben Frequenz.';

  @override
  String sameFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du hast $count Personen mit einer starken musikalischen Verbindung entdeckt.',
      one:
          'Du hast 1 Person mit einer starken musikalischen Verbindung entdeckt.',
      zero: 'Noch keine starken musikalischen Verbindungen.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyTabForYou => 'Für dich';

  @override
  String get sameFrequencyTabSaved => 'Gespeichert';

  @override
  String get sameFrequencyEmptyTitle => 'Noch niemand auf deiner Frequenz';

  @override
  String get sameFrequencyEmptyBody =>
      'Hier erscheinen Menschen, die deinen Sound teilen. Wähle mehr Genres oder synchronisiere Spotify, um dein Signal zu verstärken.';

  @override
  String get sameFrequencySavedEmptyTitle => 'Keine gespeicherten Profile';

  @override
  String get sameFrequencySavedEmptyBody =>
      'Speichere Menschen, zu denen du zurückkehren willst. Sie bleiben hier, bis du sie entfernst.';

  @override
  String get sameFrequencySave => 'Speichern';

  @override
  String get sameFrequencySaved => 'Gespeichert';

  @override
  String get sameFrequencySaveError =>
      'Deine gespeicherten Profile konnten nicht aktualisiert werden. Versuch es erneut.';

  @override
  String get sameFrequencyWhy => 'Warum ihr auf derselben Frequenz seid';

  @override
  String sameFrequencyReasonDiscoveries(String artists) {
    return 'Ihr habt beide vor Kurzem $artists entdeckt.';
  }

  @override
  String sameFrequencyReasonDirection(String genres) {
    return 'Ihr bewegt euch beide in Richtung $genres.';
  }

  @override
  String sameFrequencyReasonEvent(String event, String date) {
    return 'Ihr geht beide zu $event · $date.';
  }

  @override
  String sameFrequencyReasonEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ihr habt $count gemeinsame Events gespeichert.',
      one: 'Ihr habt 1 gemeinsames Event gespeichert.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyDiscoverArtists => 'Gemeinsame Künstler entdecken';

  @override
  String sameFrequencySharedArtistsTitle(String name) {
    return 'Künstler, die du mit $name teilst';
  }

  @override
  String get sameFrequencyFindEvents => 'Events finden';

  @override
  String get sameFrequencyEventsOptIn => 'Gespeicherte Events vergleichen';

  @override
  String get sameFrequencyEventsOptInBody =>
      'Finde Menschen, die zu denselben Konzerten gehen. Funktioniert nur mit Personen, die das ebenfalls aktiviert haben; sonst bleiben deine gespeicherten Events privat.';

  @override
  String get sameFrequencyEntryBody =>
      'Menschen, mit denen du eine echte musikalische Verbindung teilst';

  @override
  String get sameFrequencyLoadError =>
      'Same Frequency konnte nicht geladen werden.';

  @override
  String sameFrequencyPersonSemantics(String name, String percent) {
    return '$name, $percent Prozent musikalische Affinität';
  }

  @override
  String get musicRadarTitle => 'Music Radar';

  @override
  String get musicRadarHeadline =>
      'Menschen in deiner Nähe, die deinen Musikgeschmack teilen.';

  @override
  String musicRadarCount(int count, int distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kompatible Personen im Umkreis von $distance km.',
      one: '1 kompatible Person im Umkreis von $distance km.',
      zero: 'Noch keine kompatiblen Personen im Umkreis von $distance km.',
    );
    return '$_temp0';
  }

  @override
  String get musicRadarAreaSound => 'Der Sound deiner Gegend';

  @override
  String get musicRadarAreaSoundSub =>
      'Was Menschen in deiner Nähe am meisten hören';

  @override
  String get musicRadarAreaTooFew =>
      'Wird angezeigt, sobald genug Menschen in der Nähe das Radar nutzen.';

  @override
  String get musicRadarPeople => 'Kompatible Profile';

  @override
  String get musicRadarEvents => 'Kommende Events für deinen Sound';

  @override
  String get musicRadarEventYourArtist => 'Einer deiner Künstler';

  @override
  String get musicRadarEventSharedArtist =>
      'Ein Künstler, den du mit Menschen in der Nähe teilst';

  @override
  String get musicRadarEventYourGenre => 'Deine Genres';

  @override
  String get musicRadarEventAreaGenre => 'Beliebt in deiner Gegend';

  @override
  String get musicRadarIntroTitle =>
      'Entdecke Menschen in deiner Nähe über Musik';

  @override
  String get musicRadarIntroBody =>
      'Music Radar zeigt Menschen um dich herum mit ähnlichem Geschmack. Es bleibt aus, bis du es einschaltest.';

  @override
  String get musicRadarPrivacy1 =>
      'Niemand sieht deinen Standort oder deine Entfernung, nur dass du in seinem Umkreis bist.';

  @override
  String get musicRadarPrivacy2 =>
      'Deine Position wird auf ein Gebiet von etwa 5 km (oder 20 km) gerundet und ändert sich höchstens alle 6 Stunden.';

  @override
  String get musicRadarPrivacy3 =>
      'Verstecke dein Profil, ändere die Entfernung oder schalte das Radar jederzeit aus.';

  @override
  String get musicRadarTurnOn => 'Music Radar einschalten';

  @override
  String get musicRadarLocationTitle => 'Standort benötigt';

  @override
  String get musicRadarLocationBody =>
      'Music Radar nutzt deinen ungefähren Standort. Aktiviere den Standort in den Datenschutzeinstellungen und komm dann zurück.';

  @override
  String get musicRadarOpenPrivacy => 'Datenschutzeinstellungen öffnen';

  @override
  String get musicRadarMatchingNote =>
      'Aktiviere Musikalische Affinität in den Datenschutzeinstellungen, um kompatible Personen zu sehen.';

  @override
  String get musicRadarSettings => 'Radar-Einstellungen';

  @override
  String get musicRadarEnabled => 'Music Radar';

  @override
  String get musicRadarVisible => 'Mich auf dem Radar zeigen';

  @override
  String get musicRadarVisibleBody =>
      'Wenn aus, kannst du dich trotzdem umsehen, aber niemand sieht dich.';

  @override
  String get musicRadarDistance => 'Entdeckungsradius';

  @override
  String musicRadarDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get musicRadarPrecision => 'Standortgenauigkeit';

  @override
  String get musicRadarPrecisionArea => 'Gebiet (~5 km)';

  @override
  String get musicRadarPrecisionRegion => 'Region (~20 km)';

  @override
  String get musicRadarPrecisionBody =>
      'Wie ungefähr du im Verhältnis zu anderen platziert wirst. Dein genauer Standort wird nie geteilt.';

  @override
  String get musicRadarSaveError =>
      'Die Einstellung konnte nicht gespeichert werden. Versuch es erneut.';

  @override
  String get musicRadarLoadError => 'Music Radar konnte nicht geladen werden.';

  @override
  String get musicRadarEntryBody => 'Menschen in der Nähe mit deinem Geschmack';

  @override
  String get musicRadarEmptyPeople =>
      'Gerade niemand Kompatibles in der Nähe. Versuch einen größeren Umkreis oder schau später wieder vorbei.';

  @override
  String get communitiesTitle => 'Communities';

  @override
  String get communitiesEntryBody =>
      'Genres, Künstler und Szenen, die du liebst';

  @override
  String get communitiesSearchHint => 'Communities oder Künstler suchen';

  @override
  String get communitiesForYou => 'Für dich';

  @override
  String get communitiesForYouSub => 'Basierend auf deinem Musikprofil';

  @override
  String get communitiesMine => 'Deine Communities';

  @override
  String get communitiesExplore => 'Entdecken';

  @override
  String get communitiesEmptySearch => 'Keine Community passt zu deiner Suche.';

  @override
  String communitiesRecommendation(String name) {
    return 'Basierend auf deinem Musikprofil könnte dir $name gefallen.';
  }

  @override
  String communitiesReasonArtist(String artist) {
    return '$artist gehört zu deinen meistgehörten Künstlern.';
  }

  @override
  String communitiesReasonGenre(String genre, int percent) {
    return '$genre macht $percent % deiner Musik-DNA aus.';
  }

  @override
  String communitiesStartArtist(String artist) {
    return 'Starte die $artist-Community';
  }

  @override
  String get communitiesStartArtistBody =>
      'Einer deiner Lieblingskünstler hat noch keine Community.';

  @override
  String communitiesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get communitiesOfficial => 'Offiziell';

  @override
  String get communitiesKindGenre => 'Genre';

  @override
  String get communitiesKindArtist => 'Künstler';

  @override
  String get communitiesKindInterest => 'Interesse';

  @override
  String get communitiesJoin => 'Beitreten';

  @override
  String get communitiesJoined => 'Beigetreten';

  @override
  String get communitiesLeave => 'Verlassen';

  @override
  String communitiesLeaveConfirm(String name) {
    return '$name verlassen?';
  }

  @override
  String get communitiesCreate => 'Community erstellen';

  @override
  String get communitiesCreateName => 'Name';

  @override
  String get communitiesCreateDescription => 'Beschreibung (optional)';

  @override
  String get communitiesCreateArtist => 'Künstler';

  @override
  String get communitiesCreateGenre => 'Genre';

  @override
  String get communitiesCreateAction => 'Erstellen';

  @override
  String get communitiesTabPosts => 'Beiträge';

  @override
  String get communitiesTabDiscussions => 'Diskussionen';

  @override
  String get communitiesTabEvents => 'Events';

  @override
  String get communitiesTabMembers => 'Mitglieder';

  @override
  String get communitiesNewPost => 'Neuer Beitrag';

  @override
  String get communitiesComposerPost => 'Beitrag';

  @override
  String get communitiesComposerDiscussion => 'Diskussion';

  @override
  String get communitiesComposerMusic => 'Musik teilen';

  @override
  String get communitiesComposerBodyHint => 'Was beschäftigt dich?';

  @override
  String get communitiesComposerTitleHint => 'Thema der Diskussion';

  @override
  String get communitiesComposerLinkHint =>
      'Link zu Spotify, Apple Music, YouTube, SoundCloud oder Bandcamp';

  @override
  String get communitiesComposerTrackHint => 'Titel oder Album (optional)';

  @override
  String get communitiesComposerArtistHint => 'Künstler (optional)';

  @override
  String get communitiesPublish => 'Veröffentlichen';

  @override
  String get communitiesJoinToPost =>
      'Tritt bei, um zu posten, zu kommentieren und zu reagieren.';

  @override
  String get communitiesEmptyFeed =>
      'Noch keine Beiträge. Starte das Gespräch.';

  @override
  String get communitiesEmptyDiscussions => 'Noch keine Diskussionen.';

  @override
  String get communitiesEmptyEvents =>
      'Keine kommenden Events für diese Community.';

  @override
  String communitiesComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kommentare',
      one: '1 Kommentar',
      zero: 'Kommentieren',
    );
    return '$_temp0';
  }

  @override
  String get communitiesCommentHint => 'Kommentar hinzufügen';

  @override
  String get communitiesEmptyComments => 'Noch keine Kommentare.';

  @override
  String get communitiesOpenMusic => 'Anhören';

  @override
  String get communitiesHeld =>
      'Ausgeblendet, während Moderatoren Meldungen prüfen';

  @override
  String get communitiesDelete => 'Löschen';

  @override
  String get communitiesRemove => 'Entfernen (Moderator)';

  @override
  String get communitiesRestore => 'Wiederherstellen';

  @override
  String get communitiesBan => 'Aus der Community ausschließen';

  @override
  String communitiesBanConfirm(String name) {
    return '$name aus dieser Community ausschließen?';
  }

  @override
  String get communitiesMakeModerator => 'Zum Moderator machen';

  @override
  String get communitiesRemoveModerator => 'Moderatorrolle entziehen';

  @override
  String get communitiesRoleOwner => 'Inhaber';

  @override
  String get communitiesRoleModerator => 'Moderator';

  @override
  String get communitiesModeration => 'Moderation';

  @override
  String get communitiesModerationEmpty => 'Nichts zu prüfen.';

  @override
  String communitiesReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Meldungen',
      one: '1 Meldung',
    );
    return '$_temp0';
  }

  @override
  String get communitiesReported => 'Danke, die Moderatoren prüfen das.';

  @override
  String get communitiesError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get communitiesErrorRate => 'Du bist zu schnell. Warte einen Moment.';

  @override
  String get communitiesErrorSpam =>
      'Das sieht nach Spam aus: zu viele Links, ein verdächtiger Link oder eine Wiederholung.';

  @override
  String get communitiesErrorBanned =>
      'Du wurdest aus dieser Community ausgeschlossen.';

  @override
  String get communitiesErrorLink =>
      'Verwende einen Link zu Spotify, Apple Music, YouTube, SoundCloud oder Bandcamp.';

  @override
  String get communitiesErrorExists =>
      'Für diesen Künstler gibt es bereits eine Community.';

  @override
  String get communitiesErrorLimit => 'Du hast das heutige Limit erreicht.';

  @override
  String get communitiesLoadError =>
      'Communities konnten nicht geladen werden.';

  @override
  String sameFrequencyReasonCommunities(String communities) {
    return 'Ihr seid beide in $communities.';
  }

  @override
  String get musicRadarCommunities => 'Communities für den Sound deiner Gegend';

  @override
  String get circlesTitle => 'Circles';

  @override
  String get circlesSubtitle => 'Kleine Gruppen für die Musik, die du liebst';

  @override
  String get circlesInvitations => 'Einladungen';

  @override
  String circlesInvitedBy(String name) {
    return '$name hat dich eingeladen';
  }

  @override
  String get circlesAccept => 'Annehmen';

  @override
  String get circlesDecline => 'Ablehnen';

  @override
  String get circlesInviteDeclined => 'Einladung abgelehnt';

  @override
  String get circlesSuggested => 'VIBRA schlägt vor';

  @override
  String circlesSuggestionGenre(int count, String genre) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ein Circle aus $count Personen, die $genre teilen.',
    );
    return '$_temp0';
  }

  @override
  String circlesSuggestionArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ein Circle aus $count Personen, die alle $artist hören.',
    );
    return '$_temp0';
  }

  @override
  String get circlesSuggestionConsent =>
      'Jede Person erhält eine Einladung und entscheidet selbst, ob sie beitritt.';

  @override
  String get circlesCreateAndInvite => 'Erstellen und einladen';

  @override
  String circlesSuggestionName(String topic) {
    return '$topic-Circle';
  }

  @override
  String circlesInvitesSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Circle erstellt. $count Einladungen gesendet.',
      one: 'Circle erstellt. 1 Einladung gesendet.',
      zero: 'Circle erstellt. Es konnten keine Einladungen gesendet werden.',
    );
    return '$_temp0';
  }

  @override
  String get circlesMine => 'Deine Circles';

  @override
  String get circlesEmptyTitle => 'Noch keine Circles';

  @override
  String get circlesEmptyBody =>
      'Erstelle eine kleine Gruppe rund um ein Genre, einen Künstler oder ein Konzert und lade Menschen ein, die du kennst.';

  @override
  String get circlesCreate => 'Neuer Circle';

  @override
  String get circlesBasisGenre => 'Genre';

  @override
  String get circlesBasisArtist => 'Künstler';

  @override
  String get circlesBasisConcert => 'Konzert';

  @override
  String get circlesBasisInterest => 'Interesse';

  @override
  String get circlesBasisActivity => 'Aktivität';

  @override
  String get circlesName => 'Name';

  @override
  String get circlesDescription => 'Beschreibung (optional)';

  @override
  String get circlesTopic => 'Thema';

  @override
  String get circlesNoSavedEvents =>
      'Speichere zuerst ein Event, um einen Circle darum zu starten.';

  @override
  String get circlesCreateAction => 'Erstellen';

  @override
  String circlesMembers(int count, int max) {
    return '$count/$max Mitglieder';
  }

  @override
  String get circlesTabChat => 'Chat';

  @override
  String get circlesTabPlaylist => 'Playlist';

  @override
  String get circlesTabEvents => 'Events';

  @override
  String get circlesTabMembers => 'Mitglieder';

  @override
  String get circlesMessageHint => 'Schreib dem Circle';

  @override
  String get circlesChatEmpty => 'Sag hallo zu deinem Circle.';

  @override
  String get circlesPlaylistEmpty => 'Noch keine Titel. Füge den ersten hinzu.';

  @override
  String get circlesAddTrack => 'Titel hinzufügen';

  @override
  String get circlesEventsEmpty => 'Noch keine geteilten Events.';

  @override
  String get circlesShareEvent => 'Event teilen';

  @override
  String get circlesInvite => 'Personen einladen';

  @override
  String get circlesInviteHint =>
      'Du kannst deine Verbindungen und Menschen mit musikalischer Affinität einladen. Sie entscheiden selbst, ob sie beitreten.';

  @override
  String get circlesInviteNone => 'Gerade niemand weiteres zum Einladen.';

  @override
  String get circlesInviteSend => 'Einladungen senden';

  @override
  String get circlesPending => 'Eingeladen';

  @override
  String get circlesRevoke => 'Einladung zurückziehen';

  @override
  String get circlesAdmin => 'Admin';

  @override
  String get circlesMakeAdmin => 'Zum Admin machen';

  @override
  String get circlesRemoveMember => 'Aus dem Circle entfernen';

  @override
  String get circlesMute => 'Benachrichtigungen stummschalten';

  @override
  String get circlesUnmute => 'Benachrichtigungen aktivieren';

  @override
  String get circlesEdit => 'Circle bearbeiten';

  @override
  String get circlesLeave => 'Circle verlassen';

  @override
  String circlesLeaveConfirm(String name) {
    return '$name verlassen?';
  }

  @override
  String get circlesSave => 'Speichern';

  @override
  String get circlesError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get circlesErrorFull => 'Dieser Circle ist voll.';

  @override
  String get circlesErrorNotAllowed =>
      'Du kannst nur deine Verbindungen oder Menschen mit musikalischer Affinität einladen.';

  @override
  String get circlesErrorDeclined =>
      'Diese Person hat kürzlich abgelehnt. Versuch es später erneut.';

  @override
  String get circlesLoadError => 'Circles konnten nicht geladen werden.';

  @override
  String get circlesRemove => 'Entfernen';

  @override
  String get concertTitle => 'Concert Finder';

  @override
  String get concertHeadline => 'Diese kommenden Events könnten dir gefallen.';

  @override
  String get concertWhy => 'Warum wir es empfehlen';

  @override
  String concertReasonTopArtist(String artist, int rank) {
    return '$artist ist Nr. $rank deiner meistgehörten Künstler.';
  }

  @override
  String concertReasonTrackArtist(String artist) {
    return '$artist ist in deinen meistgehörten Titeln.';
  }

  @override
  String concertReasonSavedArtist(String artist) {
    return 'Du hast ein anderes Event von $artist gespeichert.';
  }

  @override
  String concertReasonGenre(String genre, int percent) {
    return '$genre macht $percent % deiner Musik-DNA aus.';
  }

  @override
  String concertReasonSimilarToSaved(String genre) {
    return 'Wie andere $genre-Events, die du gespeichert hast.';
  }

  @override
  String concertReasonDistance(int km) {
    return '$km km von dir entfernt.';
  }

  @override
  String concertReasonSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $days Tagen.',
      one: 'Morgen.',
      zero: 'Heute.',
    );
    return '$_temp0';
  }

  @override
  String get concertFilterGenre => 'Genre';

  @override
  String get concertFilterAll => 'Alle';

  @override
  String get concertArtistHint => 'Künstler suchen';

  @override
  String get concertFilterDate => 'Wann';

  @override
  String get concertDateAny => 'Jederzeit';

  @override
  String get concertDateWeek => 'Nächste 7 Tage';

  @override
  String get concertDateMonth => 'Nächste 30 Tage';

  @override
  String get concertDate3Months => 'Nächste 3 Monate';

  @override
  String get concertFilterDistance => 'Entfernung';

  @override
  String get concertDistanceAny => 'Jede Entfernung';

  @override
  String concertDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get concertFilterPrice => 'Preis';

  @override
  String get concertPriceAny => 'Jeder Preis';

  @override
  String concertPriceUpTo(String price) {
    return 'Bis $price';
  }

  @override
  String get concertPriceNote =>
      'Nur Events mit veröffentlichtem Preis in Euro.';

  @override
  String get concertEmpty =>
      'Keine empfohlenen Events passen zu diesen Filtern.';

  @override
  String get concertEmptyBody =>
      'Versuch eine größere Entfernung, ein anderes Datum oder weniger Filter.';

  @override
  String get concertNoProfileTitle => 'Erzähl uns, was du hörst';

  @override
  String get concertNoProfileBody =>
      'Verbinde Spotify oder wähle ein paar Genres, um Konzertempfehlungen zu bekommen.';

  @override
  String get concertLocationNote =>
      'Aktiviere den Standort, um Entfernungen und Events in der Nähe zu sehen.';

  @override
  String get concertLoadError => 'Empfehlungen konnten nicht geladen werden.';

  @override
  String get concertSaved => 'Gespeichert';

  @override
  String get eventDetailInterested => 'Interessiert';

  @override
  String get eventDetailAttendanceInterested => 'Als interessiert gespeichert';

  @override
  String get eventDetailAttendanceRemoved => 'Aus deinen Events entfernt';

  @override
  String get whosGoingTitle => 'Wer geht hin?';

  @override
  String get whosGoingSubtitle => 'Menschen, die ihre Pläne mit dir teilen';

  @override
  String whosGoingGoing(int count) {
    return '$count gehen hin';
  }

  @override
  String whosGoingMaybe(int count) {
    return '$count vielleicht';
  }

  @override
  String whosGoingInterested(int count) {
    return '$count interessiert';
  }

  @override
  String get whosGoingFriends => 'Freunde';

  @override
  String get whosGoingCompatible => 'Kompatible Personen';

  @override
  String get whosGoingOthers => 'Andere';

  @override
  String get whosGoingEmpty =>
      'Niemand, den du sehen kannst, hat Pläne für dieses Event geteilt.';

  @override
  String get whosGoingPrivacyNote =>
      'Du siehst nur Menschen, die ihre Pläne mit dir teilen. Deine folgen deiner Auswahl unten.';

  @override
  String get whosGoingCommunities => 'Communities zu diesem Event';

  @override
  String whosGoingAffinity(int percent) {
    return '$percent % Affinität';
  }

  @override
  String get whosGoingRequested => 'Anfrage gesendet';

  @override
  String get attendanceVisibility => 'Wer deine Pläne sehen kann';

  @override
  String get visibilityPrivate => 'Nur ich';

  @override
  String get visibilityFriends => 'Freunde';

  @override
  String get visibilityMatches => 'Freunde & Matches';

  @override
  String get visibilityPublic => 'Alle';

  @override
  String get attendanceVisibilityDefault => 'Für alle meine Events verwenden';

  @override
  String get attendanceVisibilityHint =>
      'Andere sehen deine Pläne nur, wenn du es erlaubst. Du siehst trotzdem, wer seine teilt.';

  @override
  String get attendanceVisibilitySaved => 'Sichtbarkeit aktualisiert';

  @override
  String get concertMatchTitle => 'Concert Match';

  @override
  String concertMatchHeadlineMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du und $count weitere Personen interessiert euch für dieses Konzert.',
      one: 'Du und 1 weitere Person interessiert euch für dieses Konzert.',
      zero:
          'Du bist die erste Person, die du sehen kannst. Unten Menschen, die diesen Künstler lieben.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchHeadlineOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Personen, die du sehen kannst, interessieren sich für dieses Konzert.',
      one:
          '1 Person, die du sehen kannst, interessiert sich für dieses Konzert.',
      zero:
          'Noch hat niemand, den du sehen kannst, Pläne für dieses Konzert geteilt.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchFan(String artist) {
    return 'Liebt auch $artist';
  }

  @override
  String concertMatchCreateGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Event-Gruppe erstellen ($count)',
      zero: 'Event-Gruppe erstellen',
    );
    return '$_temp0';
  }

  @override
  String get concertMatchGroupNote =>
      'Personen treten nur bei, wenn sie deine Einladung annehmen. Niemandes Standort oder Reisepläne werden geteilt.';

  @override
  String get concertMatchShare => 'In einem Circle teilen';

  @override
  String get concertMatchShared => 'Event mit dem Circle geteilt';

  @override
  String concertMatchSharedMessage(String event, String date) {
    return 'Hat ein Event geteilt: $event · $date';
  }

  @override
  String get concertMatchNoCircles => 'Du hast noch keine Circles.';

  @override
  String get concertMatchEmpty => 'Noch keine Matches für dieses Konzert.';

  @override
  String get concertMatchSelectHint =>
      'Wähle Personen für eine Event-Gruppe aus';

  @override
  String get circlePlans => 'Pläne';

  @override
  String get circlePlansEmpty =>
      'Noch keine Pläne. Schlag einen vor: Essen, Drinks vor der Show, ein Treffpunkt.';

  @override
  String get circleAddPlan => 'Plan hinzufügen';

  @override
  String get circlePlanTitle => 'Was';

  @override
  String get circlePlanWhen => 'Wann (optional)';

  @override
  String get circlePlanNote => 'Details (optional)';

  @override
  String get circlePlanIn => 'Ich bin dabei';

  @override
  String get circlePlanJoined => 'Du bist dabei';

  @override
  String circlePlanPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dabei',
      one: '1 dabei',
    );
    return '$_temp0';
  }

  @override
  String get circlePlanPrivacy => 'Nur Circle-Mitglieder sehen Pläne.';

  @override
  String get groupConcert => 'Das Konzert';

  @override
  String get groupYourStatus => 'Dein Status';

  @override
  String get groupStatusHint => 'Nur Mitglieder dieser Gruppe sehen ihn.';

  @override
  String get groupHeld => 'Ausgeblendet, während Admins Meldungen prüfen';

  @override
  String get groupRemoveAdmin => 'Entfernen (Admin)';

  @override
  String get groupBan => 'Aus der Gruppe ausschließen';

  @override
  String groupBanConfirm(String name) {
    return '$name aus dieser Gruppe ausschließen? Die Person kann nicht wieder beitreten.';
  }

  @override
  String get groupErrorBanned =>
      'Diese Person kann nicht in diese Gruppe eingeladen werden.';

  @override
  String get groupYourGroups => 'Deine Gruppen für dieses Event';

  @override
  String get groupStart => 'Konzertgruppe starten';

  @override
  String get groupReportMember => 'Mitglied melden';

  @override
  String get vibeTitle => 'Daily Vibe';

  @override
  String get vibeQuestion => 'Was ist dein Vibe heute?';

  @override
  String get vibeShare => 'Teile deinen Vibe';

  @override
  String get vibeChange => 'Heutigen Vibe ändern';

  @override
  String get vibeSearchHint => 'Song auf Spotify suchen';

  @override
  String get vibeTabSpotify => 'Spotify';

  @override
  String get vibeTabLink => 'Anderer Link';

  @override
  String get vibeLinkHint =>
      'Link zu Apple Music, YouTube, SoundCloud oder Bandcamp';

  @override
  String get vibeTitleHint => 'Songtitel';

  @override
  String get vibeArtistHint => 'Künstler';

  @override
  String get vibeCaptionHint => 'Bildunterschrift hinzufügen (optional)';

  @override
  String get vibeExpires => 'Verschwindet nach 24 Stunden';

  @override
  String get vibeEveryone => 'Für alle sichtbar';

  @override
  String get vibeVisibilityBody =>
      'Aus: Nur deine Verbindungen und musikalischen Matches sehen ihn.';

  @override
  String get vibePost => 'Vibe posten';

  @override
  String get vibePosted => 'Dein Vibe ist online';

  @override
  String get vibeEmptyTitle => 'Heute noch keine Vibes';

  @override
  String get vibeEmptyBody =>
      'Teile deinen und verbinde dich mit Menschen oder folge ihnen, um ihre zu sehen.';

  @override
  String get vibeListen => 'Auf Spotify anhören';

  @override
  String get vibeOpen => 'Link öffnen';

  @override
  String get vibeSave => 'Zu Entdeckungen hinzufügen';

  @override
  String get vibeSaved => 'In deinen Entdeckungen';

  @override
  String vibeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kommentare',
      one: '1 Kommentar',
      zero: 'Kommentieren',
    );
    return '$_temp0';
  }

  @override
  String get vibeCommentHint => 'Kommentar hinzufügen';

  @override
  String get vibeReply => 'Antworten';

  @override
  String vibeReplyingTo(String name) {
    return 'Antwort an $name';
  }

  @override
  String vibeExpiresIn(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Noch $hours Std.',
      one: 'Noch 1 Std.',
      zero: 'Weniger als 1 Std.',
    );
    return '$_temp0';
  }

  @override
  String get vibeDelete => 'Meinen Vibe löschen';

  @override
  String get vibeSearchEmpty => 'Keine Songs gefunden.';

  @override
  String get vibeProviderUnavailable =>
      'Die Spotify-Suche ist gerade nicht verfügbar. Du kannst einen Link einfügen.';

  @override
  String get vibeError =>
      'Dein Vibe konnte nicht gepostet werden. Versuch es erneut.';

  @override
  String get vibeAttribution => 'Songinfos und Cover von Spotify';

  @override
  String get discoveriesTitle => 'Entdeckungen';

  @override
  String get discoveriesEmpty =>
      'Songs, die du aus Daily Vibes, Storys, Beiträgen und Communities hinzufügst, erscheinen hier. Nur du kannst sie sehen.';

  @override
  String get discoveriesSubtitle => 'Auf VIBRA entdeckte Songs';

  @override
  String get vibeLoadError => 'Daily Vibe konnte nicht geladen werden.';

  @override
  String get vibeHomeCta => 'Teile den Song, der heute dein Vibe ist';

  @override
  String get storyAdd => 'Story hinzufügen';

  @override
  String get storyYours => 'Deine Story';

  @override
  String get storyNew => 'Neue Musik-Story';

  @override
  String get storyKindNowPlaying => 'Höre gerade';

  @override
  String get storyKindArtist => 'Lieblingskünstler';

  @override
  String get storyKindAlbum => 'Album-Tipp';

  @override
  String get storyKindPlaylist => 'Playlist';

  @override
  String get storyKindConcertPhoto => 'Konzertfoto';

  @override
  String get storyKindOpinion => 'Musikmeinung';

  @override
  String get storyAttribution => 'Musikinfos und Cover von Spotify';

  @override
  String get storyPreview => 'Story-Vorschau';

  @override
  String get storySearchArtist => 'Künstler auf Spotify suchen';

  @override
  String get storySearchAlbum => 'Album auf Spotify suchen';

  @override
  String get storySearchPlaylist => 'Öffentliche Playlist auf Spotify suchen';

  @override
  String get storySearchEmpty => 'Nichts gefunden.';

  @override
  String get storyArtistNameHint => 'Name des Künstlers';

  @override
  String get storyAlbumTitleHint => 'Albumtitel';

  @override
  String get storyPlaylistTitleHint => 'Name der Playlist';

  @override
  String get storyPlaylistOwnerHint => 'Erstellt von (optional)';

  @override
  String get storyPickPhoto => 'Konzertfoto auswählen';

  @override
  String get storyChangePhoto => 'Foto ändern';

  @override
  String get storyPhotoPrivacy =>
      'Standort- und Kameradaten werden vor dem Teilen aus dem Foto entfernt.';

  @override
  String get storyTagConcert => 'Konzert (optional)';

  @override
  String get storyNoConcert => 'Kein Konzert';

  @override
  String get storyOpinionHint =>
      'Deine Meinung: ein Album, eine Szene, ein Song…';

  @override
  String get storyBackground => 'Hintergrund';

  @override
  String get storyAudience => 'Wer sie sehen kann';

  @override
  String get storyDefaultAudience => 'Wer deine Storys standardmäßig sieht';

  @override
  String get storyAudienceConnections => 'Verbindungen';

  @override
  String get storyAudienceEveryone => 'Alle';

  @override
  String get storyAudienceConnectionsBody =>
      'Deine Verbindungen und musikalischen Matches.';

  @override
  String get storyAudienceEveryoneBody =>
      'Auch Personen, die dir folgen. Blockierte und ausgeblendete Personen sehen sie nie.';

  @override
  String get storyAllowReplies => 'Antworten erlauben';

  @override
  String get storyAllowRepliesBody =>
      'Antworten sind privat: Nur du und die antwortende Person seht sie.';

  @override
  String get storyExpires => 'Verschwindet nach 24 Stunden.';

  @override
  String get storyShare => 'Story teilen';

  @override
  String get storyPosted => 'Deine Story ist 24 Stunden online';

  @override
  String get storyError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get storyRateLimited =>
      'Du teilst gerade viel. Warte kurz und versuch es erneut.';

  @override
  String get storySpam =>
      'Das sieht nach Spam aus. Entferne Links und versuch es erneut.';

  @override
  String get storyPhotoError =>
      'Dieses Foto kann nicht verwendet werden. Wähle ein JPG oder PNG bis 10 MB.';

  @override
  String get storySettingsTitle => 'Story-Privatsphäre';

  @override
  String get storyHideFrom => 'Storys ausblenden für';

  @override
  String get storyHideFromBody =>
      'Sie sehen deine Storys nicht und werden nicht benachrichtigt.';

  @override
  String get storyHidden => 'Von deinen Storys ausgeblendet';

  @override
  String get storyNoConnections =>
      'Sobald du Verbindungen hast, kannst du hier wählen, wer deine Storys nicht sieht.';

  @override
  String get storyJustNow => 'jetzt';

  @override
  String storyMinutesAgo(int minutes) {
    return '$minutes Min.';
  }

  @override
  String storyHoursAgo(int hours) {
    return '$hours Std.';
  }

  @override
  String get storyPrevious => 'Vorherige Story';

  @override
  String get storyNext => 'Nächste Story';

  @override
  String get storyMore => 'Weitere Optionen';

  @override
  String get storyLoadError => 'Diese Storys konnten nicht geladen werden.';

  @override
  String get storyGone =>
      'Diese Storys sind abgelaufen oder nicht mehr verfügbar.';

  @override
  String get storyHeld =>
      'Nach Meldungen zur Prüfung ausgeblendet. Nur du kannst sie sehen.';

  @override
  String storyReplyHint(String name) {
    return '$name antworten…';
  }

  @override
  String get storySendReply => 'Senden';

  @override
  String get storyReplySent => 'Antwort privat gesendet';

  @override
  String get storyRepliesOff => 'Antworten sind für diese Story deaktiviert';

  @override
  String get storyRepliesOffMine =>
      'Antworten sind für diese Story deaktiviert.';

  @override
  String storyViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufrufe',
      one: '1 Aufruf',
      zero: 'Keine Aufrufe',
    );
    return '$_temp0';
  }

  @override
  String storyReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Antworten',
      one: '1 Antwort',
      zero: 'Antworten',
    );
    return '$_temp0';
  }

  @override
  String storyReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Reaktionen',
      one: '1 Reaktion',
    );
    return '$_temp0';
  }

  @override
  String get storyInsightsPrivate =>
      'Nur du siehst, wer angesehen und geantwortet hat.';

  @override
  String get storyNoViewers => 'Noch keine Aufrufe.';

  @override
  String get storyNoReplies => 'Noch keine Antworten.';

  @override
  String storyAnswerHint(String name) {
    return '$name privat antworten…';
  }

  @override
  String get storyMakeEveryone => 'Allen zeigen';

  @override
  String get storyMakeConnectionsOnly => 'Nur Verbindungen zeigen';

  @override
  String get storyNowEveryone => 'Jetzt können alle diese Story sehen';

  @override
  String get storyNowConnections =>
      'Jetzt sehen nur deine Verbindungen diese Story';

  @override
  String get storyTurnRepliesOff => 'Antworten deaktivieren';

  @override
  String get storyTurnRepliesOn => 'Antworten aktivieren';

  @override
  String get storyDelete => 'Story löschen';

  @override
  String get storyDeleted => 'Story gelöscht';

  @override
  String storyMute(String name) {
    return 'Storys von $name stummschalten';
  }

  @override
  String storyMuted(String name) {
    return 'Du siehst die Storys von $name nicht mehr. Die Person wird nicht benachrichtigt.';
  }

  @override
  String get feedTitle => 'VIBRA Feed';

  @override
  String get feedHomeCta =>
      'Empfehlungen, Rezensionen und Entdeckungen aus deiner Musikwelt';

  @override
  String get feedForYou => 'Für dich';

  @override
  String get feedFollowing => 'Gefolgt';

  @override
  String get feedLatest => 'Neueste';

  @override
  String get feedForYouBody =>
      'Sortiert nach Personen, denen du folgst, deinen Verbindungen, Communities und der Musik, die du liebst. Jeder Beitrag sagt, warum er hier ist.';

  @override
  String get feedFollowingBody =>
      'Neueste zuerst, von Personen, denen du folgst, und deinen Verbindungen.';

  @override
  String get feedLatestBody =>
      'Neueste zuerst, alle Beiträge, die du sehen kannst.';

  @override
  String get feedCompose => 'Posten';

  @override
  String get feedNewPost => 'Neuer Beitrag';

  @override
  String get feedPublish => 'Veröffentlichen';

  @override
  String get feedPosted => 'Dein Beitrag ist online';

  @override
  String get feedKindSong => 'Song';

  @override
  String get feedKindAlbum => 'Album';

  @override
  String get feedKindPlaylist => 'Playlist';

  @override
  String get feedKindRecommendation => 'Empfehlung';

  @override
  String get feedKindDiscovery => 'Entdeckung';

  @override
  String get feedKindReview => 'Rezension';

  @override
  String get feedKindOpinion => 'Meinung';

  @override
  String get feedKindConcertPhoto => 'Konzertfoto';

  @override
  String get feedKindShare => 'Geteilt';

  @override
  String get feedItemTrack => 'Song';

  @override
  String get feedItemAlbum => 'Album';

  @override
  String get feedItemArtist => 'Künstler';

  @override
  String get feedItemPlaylist => 'Playlist';

  @override
  String get feedWhatAbout => 'Worum geht es?';

  @override
  String get feedYourRating => 'Deine Bewertung';

  @override
  String feedRatingLabel(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating Sterne',
      one: '1 Stern',
    );
    return '$_temp0';
  }

  @override
  String get feedReviewHint => 'Was hältst du davon? Sei konkret.';

  @override
  String get feedDiscoveryHint => 'Wie hast du es entdeckt?';

  @override
  String get feedRecommendationHint => 'Warum sollte man es hören?';

  @override
  String get feedBodyHint => 'Schreib etwas dazu (optional)';

  @override
  String get feedAudienceEveryoneBody =>
      'Alle auf VIBRA können ihn sehen, außer blockierte Personen.';

  @override
  String get feedAllowComments => 'Kommentare erlauben';

  @override
  String get feedDuplicatePost => 'Das hast du heute schon gepostet.';

  @override
  String get feedError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get feedLoadError => 'Der Feed konnte nicht geladen werden.';

  @override
  String get feedEmptyTitle => 'Noch nichts hier';

  @override
  String get feedEmptyBody =>
      'Teile eine Empfehlung oder tritt Communities bei und folge Personen, um deinen Feed zu füllen.';

  @override
  String get feedEmptyFollowing =>
      'Hier erscheinen Beiträge von Personen, denen du folgst, und deinen Verbindungen.';

  @override
  String get feedEnd => 'Du bist auf dem neuesten Stand';

  @override
  String get feedReasonFollowing => 'Du folgst der Person';

  @override
  String get feedReasonConnection => 'Deine Verbindung';

  @override
  String get feedReasonArtists => 'Ein Künstler, den du hörst';

  @override
  String get feedReasonGenres => 'Genres, die du liebst';

  @override
  String get feedReasonCommunity => 'Aus deinen Communities';

  @override
  String get feedReasonMatch => 'Musikalische Affinität';

  @override
  String get feedReasonInteraction => 'Du interagierst oft mit der Person';

  @override
  String get feedReasonNew => 'Neu auf VIBRA';

  @override
  String feedDaysAgo(int days) {
    return '$days T.';
  }

  @override
  String get feedHeld =>
      'Nach Meldungen zur Prüfung ausgeblendet. Nur du kannst ihn sehen.';

  @override
  String get feedLike => 'Gefällt mir';

  @override
  String get feedUnlike => 'Gefällt mir entfernen';

  @override
  String get feedReact => 'Reagieren';

  @override
  String get feedComments => 'Kommentare';

  @override
  String get feedShare => 'Teilen';

  @override
  String get feedSave => 'Speichern';

  @override
  String get feedUnsave => 'Aus Gespeichertem entfernen';

  @override
  String get feedSaved => 'Gespeichert';

  @override
  String get feedUnsaved => 'Aus Gespeichertem entfernt';

  @override
  String get feedShareToFeed => 'In deinem Feed teilen';

  @override
  String get feedShareCommentHint => 'Kommentar hinzufügen (optional)';

  @override
  String get feedShareOnlyPublic =>
      'Nur öffentliche Beiträge anderer Personen können in deinem Feed geteilt werden.';

  @override
  String get feedShared => 'In deinem Feed geteilt';

  @override
  String get feedAlreadyShared => 'Du hast diesen Beitrag schon geteilt.';

  @override
  String get feedCopyLink => 'Musiklink kopieren';

  @override
  String get feedLinkCopied => 'Link kopiert';

  @override
  String get feedTurnCommentsOff => 'Kommentare deaktivieren';

  @override
  String get feedTurnCommentsOn => 'Kommentare aktivieren';

  @override
  String get feedDelete => 'Beitrag löschen';

  @override
  String get feedDeleted => 'Beitrag gelöscht';

  @override
  String get feedNotInterested => 'Kein Interesse';

  @override
  String get feedNotInterestedDone => 'Du siehst weniger Beiträge wie diesen';

  @override
  String get feedPostTitle => 'Beitrag';

  @override
  String get feedPostGone => 'Beitrag nicht verfügbar';

  @override
  String get feedPostGoneBody =>
      'Er wurde gelöscht oder du kannst ihn nicht mehr sehen.';

  @override
  String get feedCommentHint => 'Kommentar hinzufügen';

  @override
  String get feedCommentsOff =>
      'Kommentare sind für diesen Beitrag deaktiviert.';

  @override
  String get feedDuplicateComment =>
      'Diesen Kommentar hast du schon geschrieben.';

  @override
  String get feedNoComments => 'Noch keine Kommentare. Fang das Gespräch an.';

  @override
  String get feedDeleteComment => 'Kommentar löschen';

  @override
  String get feedSavedTitle => 'Gespeicherte Beiträge';

  @override
  String get feedSavedSubtitle => 'Beiträge, die du im Feed gespeichert hast';

  @override
  String get feedSavedEmpty => 'Keine gespeicherten Beiträge';

  @override
  String get feedSavedEmptyBody =>
      'Tippe auf das Lesezeichen eines Beitrags, um ihn hier zu behalten. Nur du siehst deine gespeicherten Beiträge.';

  @override
  String get feedPostsTitle => 'Beiträge';

  @override
  String feedPostsOf(String name) {
    return 'Beiträge von $name';
  }

  @override
  String get feedSeeAllPosts => 'Alle ansehen';

  @override
  String get feedNoPosts => 'Noch keine Beiträge';

  @override
  String get feedNoPostsBody =>
      'Beiträge, die du sehen kannst, erscheinen hier.';

  @override
  String get feedYourPosts => 'Deine Beiträge';

  @override
  String get feedYourPostsSubtitle =>
      'Alles, was du im Feed veröffentlicht hast';

  @override
  String get reactionFire => 'Feuer';

  @override
  String get reactionObsessed => 'Besessen';

  @override
  String get reactionUnderrated => 'Unterschätzt';

  @override
  String get reactionClassic => 'Klassiker';

  @override
  String get reactionNewDiscovery => 'Neue Entdeckung';

  @override
  String get reactionOnRepeat => 'In Dauerschleife';

  @override
  String get reactionHeart => 'Liebe';

  @override
  String get reactionHeadphones => 'Höre ich';

  @override
  String get reactionClap => 'Applaus';

  @override
  String get reactionMindBlown => 'Umwerfend';

  @override
  String get reactionTrackTitle => 'Auf diesen Song reagieren';

  @override
  String get discoveryAdded => 'Zu deinen Entdeckungen hinzugefügt';

  @override
  String get discoveryAddFailed =>
      'Der Song konnte nicht hinzugefügt werden. Versuch es erneut.';

  @override
  String get discoveryOffer =>
      'Eine neue Entdeckung? Behalte sie in deinen Entdeckungen.';

  @override
  String discoveryFoundVia(String name) {
    return 'über $name';
  }

  @override
  String get aiTitle => 'VIBRA AI';

  @override
  String get aiHomeCta =>
      'Frag nach Künstlern, Alben, Konzerten und Genres zum Entdecken';

  @override
  String get aiPrivacyTile =>
      'Optionaler Musikassistent. Aus, bis du ihn einschaltest.';

  @override
  String get aiUnavailableTitle => 'VIBRA AI ist nicht verfügbar';

  @override
  String get aiUnavailableBody =>
      'Der Assistent ist gerade nicht verfügbar. Alles andere in VIBRA funktioniert wie gewohnt.';

  @override
  String get aiConsentTitle => 'Dein Musikassistent';

  @override
  String get aiConsentIntro =>
      'Frag nach ähnlichen Künstlern, Alben für deinen Geschmack, passenden Konzerten, Communities und neuen Genres. Optional und aus, bis du ihn einschaltest.';

  @override
  String get aiConsentUses => 'Zum Antworten nutzt er';

  @override
  String get aiConsentUsesProfile =>
      'Deine Musical DNA, deine Top-Künstler und die Genres, die du gewählt hast';

  @override
  String get aiConsentUsesChat =>
      'Deine Frage und die letzten Nachrichten dieses Chats';

  @override
  String get aiConsentUsesCatalogue =>
      'Spotifys öffentlichen Katalog sowie Konzerte und Communities von VIBRA';

  @override
  String get aiConsentNever => 'Er nutzt nie';

  @override
  String get aiConsentNeverBody =>
      'Deine Nachrichten, deinen Standort, Kontakte, Profile anderer oder deinen Spotify-Login. VIBRA speichert die Chats nicht.';

  @override
  String get aiConsentProvider =>
      'Antworten werden von einem externen KI-Anbieter (Anthropic) erzeugt, der für jede Frage die oben genannten Informationen erhält. Du kannst VIBRA AI jederzeit ausschalten.';

  @override
  String get aiConsentAccept => 'VIBRA AI einschalten';

  @override
  String get aiConsentDecline => 'Jetzt nicht';

  @override
  String get aiTurnOff => 'VIBRA AI ausschalten';

  @override
  String get aiTurnedOff => 'VIBRA AI ist aus';

  @override
  String get aiNewChat => 'Neues Gespräch';

  @override
  String get aiIntro => 'Was möchtest du entdecken?';

  @override
  String get aiExampleSimilar =>
      'Empfiehl mir Künstler ähnlich wie Travis Scott';

  @override
  String get aiExampleUnderground => 'Finde Underground-Hip-Hop-Künstler';

  @override
  String get aiExampleAlbums => 'Empfiehl mir Alben nach meinem Musikprofil';

  @override
  String get aiExampleExplain => 'Erklär, warum zwei Künstler ähnlich klingen';

  @override
  String get aiExampleConcerts =>
      'Finde Konzerte, die zu meinen Interessen passen';

  @override
  String get aiExampleCommunities =>
      'Schlag mir Communities vor, die mir gefallen könnten';

  @override
  String get aiExampleGenres => 'Hilf mir, neue Genres zu entdecken';

  @override
  String get aiInputHint => 'Frag VIBRA AI zu Musik';

  @override
  String get aiThinking => 'Ich schaue nach…';

  @override
  String get aiGeneratedLabel => 'KI-generiert · kann Fehler enthalten';

  @override
  String get aiVerifiedTitle => 'Verifizierte Ergebnisse';

  @override
  String get aiIdeasTitle => 'Ideen zum Entdecken';

  @override
  String get aiIdeasBody => 'Generierte Vorschläge, nicht verifiziert.';

  @override
  String get aiSourceSpotify => 'Auf Spotify verifiziert';

  @override
  String get aiSourceEvents => 'Aus VIBRAs Konzertliste';

  @override
  String get aiSourceCommunities => 'VIBRA-Community';

  @override
  String get aiSourceDna => 'Aus deiner Musical DNA';

  @override
  String get aiSourceGenres => 'VIBRA-Genrekatalog';

  @override
  String aiMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get aiRateLimited =>
      'Du hast viel gefragt. Versuch es gleich noch einmal.';

  @override
  String get aiError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get aiRefused =>
      'Dabei kann VIBRA AI nicht helfen. Versuch eine Musikfrage.';

  @override
  String get aiIncomplete =>
      'Die Antwort konnte nicht fertiggestellt werden. Frag einfacher.';

  @override
  String get discoverTitle => 'Entdecke deinen nächsten Künstler';

  @override
  String get discoverHomeCta =>
      'Ähnliche, aufstrebende und Underground-Künstler für dich';

  @override
  String get discoverIntro =>
      'Basierend auf deinen Lieblingskünstlern, deiner Musical DNA, entdeckten Songs und deinem Feedback. Deine Antworten prägen die nächsten Vorschläge.';

  @override
  String get discoverAll => 'Alle';

  @override
  String get discoverSimilar => 'Ähnlich';

  @override
  String get discoverCollaborations => 'Kollaborationen';

  @override
  String get discoverEmerging => 'Aufstrebend';

  @override
  String get discoverUnderground => 'Underground';

  @override
  String get discoverExploration => 'Neue Genres';

  @override
  String discoverReasonCollab(String artist) {
    return 'Hat mit $artist zusammengearbeitet';
  }

  @override
  String discoverReasonExplore(String genre) {
    return 'Ein Schritt in Richtung $genre';
  }

  @override
  String discoverReasonGenres(String genres) {
    return 'Passt zu: $genres';
  }

  @override
  String get discoverLike => 'Gefällt mir';

  @override
  String get discoverSave => 'Für später speichern';

  @override
  String get discoverKnown => 'Kenne ich schon';

  @override
  String get discoverNotInterested => 'Kein Interesse';

  @override
  String get discoverLiked => 'Verstanden: mehr davon';

  @override
  String get discoverUndone => 'Entfernt';

  @override
  String get discoverSaved => 'Für später gespeichert';

  @override
  String get discoverUnsaved => 'Aus Gespeichertem entfernt';

  @override
  String get discoverKnownDone =>
      'Notiert. Dieser Künstler wird nicht mehr vorgeschlagen.';

  @override
  String get discoverNotInterestedDone =>
      'Du siehst diesen Künstler nicht mehr und weniger ähnliche.';

  @override
  String get discoverRefresh => 'Neue Vorschläge';

  @override
  String get discoverRefreshLimited =>
      'Aktualisieren gerade nicht möglich. Versuch es in ein paar Minuten.';

  @override
  String get discoverError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get discoverEmptyTitle => 'Noch keine neuen Künstler';

  @override
  String get discoverEmptyBody =>
      'Schau später wieder vorbei oder tippe auf Neue Vorschläge.';

  @override
  String get discoverNoProfile =>
      'Verbinde Spotify oder wähle ein paar Genres, damit VIBRA weiß, was dir gefällt.';

  @override
  String get discoverPickGenres => 'Genres wählen';

  @override
  String get discoverSavedTitle => 'Gespeicherte Künstler';

  @override
  String get discoverSavedSubtitle =>
      'Künstler, die du für später gespeichert hast';

  @override
  String get discoverSavedEmpty => 'Keine gespeicherten Künstler';

  @override
  String get discoverSavedEmptyBody =>
      'Tippe bei einem Vorschlag auf Für später speichern, um ihn hier zu behalten.';

  @override
  String get tasteTitle => 'Geschmacksentwicklung';

  @override
  String get tasteOpen => 'Sieh, wie sich dein Geschmack entwickelt hat';

  @override
  String get tastePeriodMonth => '1 Monat';

  @override
  String get tastePeriodThreeMonths => '3 Monate';

  @override
  String get tastePeriodSixMonths => '6 Monate';

  @override
  String get tastePeriodYear => '1 Jahr';

  @override
  String tasteEvolved(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Dein Musikgeschmack hat sich im letzten Monat verändert',
      'year': 'Dein Musikgeschmack hat sich im letzten Jahr verändert',
      'three':
          'Dein Musikgeschmack hat sich in den letzten 3 Monaten verändert',
      'six': 'Dein Musikgeschmack hat sich in den letzten 6 Monaten verändert',
      'other':
          'Dein Musikgeschmack hat sich in den letzten 3 Monaten verändert',
    });
    return '$_temp0';
  }

  @override
  String tasteSteady(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Dein Musikgeschmack ist im letzten Monat stabil geblieben',
      'year': 'Dein Musikgeschmack ist im letzten Jahr stabil geblieben',
      'three':
          'Dein Musikgeschmack ist in den letzten 3 Monaten stabil geblieben',
      'six':
          'Dein Musikgeschmack ist in den letzten 6 Monaten stabil geblieben',
      'other':
          'Dein Musikgeschmack ist in den letzten 3 Monaten stabil geblieben',
    });
    return '$_temp0';
  }

  @override
  String tasteComparing(String from, String to) {
    return 'Vergleich deiner Musical DNA vom $from mit der vom $to.';
  }

  @override
  String tasteShortHistory(String from, String to) {
    return 'Dein Verlauf beginnt am $from, daher wird $from mit $to verglichen.';
  }

  @override
  String tasteChangePoints(int points) {
    return '$points Prozentpunkte deines Genre-Mix haben sich verschoben.';
  }

  @override
  String get tasteThenNow => 'Damals und heute';

  @override
  String get tasteThen => 'Damals';

  @override
  String get tasteNow => 'Heute';

  @override
  String get tasteTimeline => 'Im Lauf der Zeit';

  @override
  String tasteTimelineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Momentaufnahmen',
      one: '1 Momentaufnahme',
    );
    return '$_temp0 deiner Musical DNA aus diesem Zeitraum.';
  }

  @override
  String get tasteNewGenres => 'Neu entdeckte Genres';

  @override
  String get tasteNoNewGenres => 'Keine neuen Genres in diesem Zeitraum.';

  @override
  String get tasteEmergingArtists => 'Aufsteigende Favoriten';

  @override
  String get tasteNoEmergingArtists =>
      'Deine Lieblingskünstler sind dieselben wie zuvor.';

  @override
  String get tasteNoArtistData =>
      'Verbinde Spotify, um zu sehen, wie sich deine Lieblingskünstler ändern.';

  @override
  String get tasteArtistNew => 'Neu';

  @override
  String tasteArtistRose(int from, int to) {
    return '#$from → #$to';
  }

  @override
  String get tastePrevious => 'Was du früher mehr gehört hast';

  @override
  String get tasteNoPrevious => 'Nichts, was du geliebt hast, ist verblasst.';

  @override
  String get tasteFormerTopArtist => 'War einer deiner Top-Künstler';

  @override
  String get tasteCommunities => 'Communities, denen du beigetreten bist';

  @override
  String get tasteNoCommunities =>
      'Du bist in diesem Zeitraum keiner Community beigetreten.';

  @override
  String tasteJoinedOn(String date) {
    return 'Beigetreten am $date';
  }

  @override
  String get tasteNoDnaTitle => 'Noch keine Musical DNA';

  @override
  String get tasteNoDnaBody =>
      'Deine Geschmacksentwicklung beginnt, sobald VIBRA deine Musical DNA hat.';

  @override
  String get tasteTooEarlyTitle => 'Noch nicht genug Verlauf';

  @override
  String tasteTooEarlyBody(String date) {
    return 'Dein Verlauf beginnt am $date. Schau in ein paar Wochen wieder vorbei.';
  }

  @override
  String get tasteOffTitle => 'Geschmacksverlauf ist aus';

  @override
  String get tasteOffBody =>
      'VIBRA speichert nur deine aktuelle Musical DNA. Schalte den Verlauf unten ein, um ab heute deinen Geschmack zu verfolgen.';

  @override
  String get tasteKeepHistory => 'Geschmacksverlauf speichern';

  @override
  String get tasteKeepHistoryBody =>
      'Eine Musical-DNA-Momentaufnahme pro Tag, bis zu 400 Tage gespeichert und nur für dich sichtbar.';

  @override
  String get tasteTurnOffTitle => 'Geschmacksverlauf ausschalten?';

  @override
  String get tasteTurnOffBody =>
      'Deine früheren Momentaufnahmen werden gelöscht und nur deine aktuelle Musical DNA bleibt. Funktionen, die deinen Geschmack über die Zeit vergleichen, funktionieren erst wieder, wenn du ihn einschaltest.';

  @override
  String get tasteTurnOffConfirm => 'Ausschalten und löschen';

  @override
  String get tasteError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get profileSectionGenres => 'Lieblingsgenres';

  @override
  String get profileSectionArtists => 'Lieblingskünstler';

  @override
  String get profileSectionStats => 'Musikstatistiken';

  @override
  String get profileSectionSavedSongs => 'Gespeicherte Songs';

  @override
  String get profileSectionPlaylists => 'Geteilte Playlists';

  @override
  String get profileSectionEvents => 'Kommende Events';

  @override
  String get profileSectionCommunities => 'Communities';

  @override
  String get profileSectionCircles => 'Circles';

  @override
  String get profileSectionActivity => 'Musikaktivität';

  @override
  String get profileLevelPublic => 'Alle';

  @override
  String get profileLevelConnections => 'Verbindungen';

  @override
  String get profileLevelPrivate => 'Nur ich';

  @override
  String get profileRelationConnection => 'Deine Verbindung';

  @override
  String get profileRelationMatch => 'Musikalisches Match';

  @override
  String profileMemberSince(String date) {
    return 'Bei VIBRA seit $date';
  }

  @override
  String profileSignatureSemantics(String name, String genres) {
    return '$name, Klangsignatur: $genres';
  }

  @override
  String get profileNoGenres => 'Noch keine Lieblingsgenres.';

  @override
  String get profileNoArtists => 'Noch keine Lieblingskünstler.';

  @override
  String get profileNoPlaylists => 'Noch keine Playlists geteilt.';

  @override
  String get profileNoEvents => 'Keine kommenden Events zum Anzeigen.';

  @override
  String get profileNoCommunities => 'Noch in keiner Community.';

  @override
  String get profileNoCircles => 'Du bist noch in keinem Circle.';

  @override
  String get profileNoSharedCircles => 'Ihr seid in keinem gemeinsamen Circle.';

  @override
  String get profileSharedCirclesNote => 'Circles, in denen ihr beide seid.';

  @override
  String get profileNoActivity => 'Keine aktuelle Aktivität.';

  @override
  String profileActivityPosted(String title) {
    return 'Gepostet: $title';
  }

  @override
  String profileActivityVibe(String title) {
    return 'Daily Vibe: $title';
  }

  @override
  String profileActivityJoined(String name) {
    return 'Ist $name beigetreten';
  }

  @override
  String get profileEventGoing => 'Geht hin';

  @override
  String get profileEventMaybe => 'Vielleicht';

  @override
  String get profileEventInterested => 'Interessiert';

  @override
  String get profileStatGenres => 'Genres';

  @override
  String get profileStatDiversity => 'Vielfalt';

  @override
  String get profileStatDiscoveries => 'Entdeckungen';

  @override
  String get profileStatPosts => 'Beiträge';

  @override
  String get profileStatConcerts => 'Besuchte Konzerte';

  @override
  String get profileSomePrivate =>
      'Einige Bereiche dieses Profils sind privat.';

  @override
  String get profilePrivacyTitle => 'Profil-Privatsphäre';

  @override
  String get profilePrivacyTile =>
      'Wähle, wer welchen Teil deines Musikprofils sieht';

  @override
  String get profilePrivacyIntro =>
      'Wähle, wer welchen Teil deines Profils sehen kann. Foto, Name, Benutzername und Bio sind für Personen sichtbar, mit denen du interagieren kannst.';

  @override
  String get profilePrivacyEventsNote =>
      'Jedes Event behält zusätzlich die Sichtbarkeit aus „Wer geht hin“.';

  @override
  String get profilePrivacyCirclesNote =>
      'Andere sehen nur Circles, in denen sie selbst auch sind.';

  @override
  String get profilePrivacyPostsNote =>
      'Jeder Beitrag behält zusätzlich sein eigenes Publikum.';

  @override
  String get profilePrivacyDnaNote =>
      'Die Musical DNA hat eine eigene Sichtbarkeitseinstellung.';

  @override
  String get profilePrivacyError =>
      'Speichern fehlgeschlagen. Versuch es erneut.';

  @override
  String get safetyTitle => 'Sicherheit & Privatsphäre';

  @override
  String get safetySettingsSubtitle =>
      'Blockierungen, Meldungen, Sichtbarkeit und Standort an einem Ort';

  @override
  String get safetyIntro =>
      'Alles, was bestimmt, wer dich erreichen kann und was andere sehen. VIBRAs Server setzen diese Regeln überall in der App durch.';

  @override
  String get safetyPeople => 'Personen';

  @override
  String get safetyBlockedTitle => 'Blockierte Personen';

  @override
  String safetyBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
      zero: 'Niemand blockiert',
    );
    return '$_temp0';
  }

  @override
  String get safetyBlockExplain =>
      'Blockieren gilt überall: Nachrichten, Kommentare, Beiträge, Storys, Communities, Circles, Events und Radar. Es entfernt auch Follows und Verbindungen zwischen euch. Die andere Person wird nicht benachrichtigt.';

  @override
  String get safetyNoBlocked => 'Du hast niemanden blockiert';

  @override
  String safetyBlockedOn(String date) {
    return 'Blockiert am $date';
  }

  @override
  String get safetyUnblock => 'Entsperren';

  @override
  String safetyUnblockTitle(String name) {
    return '$name entsperren?';
  }

  @override
  String get safetyUnblockBody =>
      'Die Person kann dich wieder finden und kontaktieren. Durch das Blockieren entfernte Follows und Verbindungen kommen nicht zurück.';

  @override
  String safetyUnblocked(String name) {
    return '$name ist entsperrt';
  }

  @override
  String safetyBlockTitle(String name) {
    return '$name blockieren?';
  }

  @override
  String get safetyBlockBody =>
      'Ihr seht euch nirgends mehr auf VIBRA, und Follows und Verbindungen zwischen euch werden entfernt. Niemand wird benachrichtigt.';

  @override
  String get safetyReportUser => 'Diese Person melden';

  @override
  String get safetyReported => 'Danke. Unser Team prüft die Meldung.';

  @override
  String get safetyDuplicateReport => 'Das hast du kürzlich schon gemeldet.';

  @override
  String get safetyRateLimited =>
      'Zu viele Versuche. Versuch es später erneut.';

  @override
  String get safetyUserUnavailable => 'Diese Person ist nicht verfügbar.';

  @override
  String get safetyVisibility => 'Was andere sehen';

  @override
  String safetyHiddenFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Personen verborgen',
      one: 'vor 1 Person verborgen',
    );
    return '$_temp0';
  }

  @override
  String get safetyAttendance => 'Event-Teilnahme';

  @override
  String get safetyAttendanceBody => 'pro Event unter „Wer geht hin“ wählbar';

  @override
  String get safetyLocation => 'Standort';

  @override
  String get safetyLocationExplain =>
      'Dein genauer Standort wird niemandem gezeigt. Der Radar nutzt ungefähre Bereiche, und nur, wenn du ihn einschaltest.';

  @override
  String get safetyRadarVisible => 'An, sichtbar';

  @override
  String get safetyRadarHidden => 'An, verborgen';

  @override
  String get safetyOn => 'An';

  @override
  String get safetyOff => 'Aus';

  @override
  String get safetyData => 'Deine Daten';

  @override
  String get safetyAllPrivacy => 'Alle Privatsphäre-Einstellungen';

  @override
  String get safetyAllPrivacyBody =>
      'Einwilligungen, Benachrichtigungen und Datenexport';

  @override
  String get safetyReporting => 'Meldungen';

  @override
  String get safetyReportingBody =>
      'Du kannst eine Person über ihr Profil melden und jede Nachricht, jeden Beitrag, Kommentar, jede Story, Antwort, Vibe oder Community-Inhalt über sein Menü. Meldungen sind privat. Von mehreren gemeldete Inhalte werden während der Prüfung ausgeblendet, und Community-Moderatoren können Inhalte entfernen und Mitglieder sperren.';

  @override
  String get safetyContact => 'Support kontaktieren';

  @override
  String get notifTitle => 'Benachrichtigungen';

  @override
  String get notifCenterSubtitle => 'Alles, was passiert ist, an einem Ort';

  @override
  String get notifSettingsTitle => 'Benachrichtigungseinstellungen';

  @override
  String get notifSettingsSubtitle => 'Kategorien, Ruhezeiten und Tageslimit';

  @override
  String get notifToday => 'Heute';

  @override
  String get notifThisWeek => 'Diese Woche';

  @override
  String get notifEarlier => 'Früher';

  @override
  String get notifMarkAllRead => 'Alle als gelesen markieren';

  @override
  String get notifUnread => 'Ungelesen';

  @override
  String notifUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Benachrichtigungen',
      one: '1 ungelesene Benachrichtigung',
    );
    return '$_temp0';
  }

  @override
  String notifGrouped(int count) {
    return '$count Updates';
  }

  @override
  String get notifEmptyTitle => 'Noch keine Benachrichtigungen';

  @override
  String get notifEmptyBody =>
      'Anfragen, Nachrichten, Konzerte und alles andere erscheinen hier.';

  @override
  String get notifError => 'Etwas ist schiefgelaufen. Versuch es erneut.';

  @override
  String get notifPushAll => 'Push-Benachrichtigungen';

  @override
  String get notifPushAllBody =>
      'Aus: Alles erscheint weiterhin in der Übersicht, aber nichts wird gepusht.';

  @override
  String get notifNoDevice =>
      'Push ist auf diesem Gerät noch nicht eingerichtet. Du siehst trotzdem jede Benachrichtigung hier.';

  @override
  String get notifCategoriesTitle => 'Was Push senden darf';

  @override
  String get notifCategoriesBody =>
      'Eine Kategorie auszuschalten stoppt ihre Pushs. Sie erscheint weiterhin in der Übersicht.';

  @override
  String get notifOncePerDay => 'Höchstens ein Push pro Tag.';

  @override
  String get notifCatRequests => 'Vibra-Anfragen';

  @override
  String get notifCatRequestsBody => 'Neue und angenommene Anfragen.';

  @override
  String get notifCatMessages => 'Nachrichten';

  @override
  String get notifCatMessagesBody =>
      'Direktnachrichten, Nachrichtenanfragen und Live-Chats bei Events.';

  @override
  String get notifCatCommunities => 'Community-Aktivität';

  @override
  String get notifCatCommunitiesBody =>
      'Kommentare zu deinen Community-Beiträgen.';

  @override
  String get notifCatCircles => 'Circles';

  @override
  String get notifCatCirclesBody => 'Einladungen, Nachrichten und Pläne.';

  @override
  String get notifCatConcerts => 'Konzertankündigungen';

  @override
  String get notifCatConcertsBody =>
      'Neue Konzerte von Künstlern, die du hörst, und Event-Updates.';

  @override
  String get notifCatReminders => 'Event-Erinnerungen';

  @override
  String get notifCatRemindersBody =>
      'Eine Woche vorher, am Vortag und am Tag deiner Events.';

  @override
  String get notifCatRecommendations => 'Empfehlungen';

  @override
  String get notifCatRecommendationsBody =>
      'Von Personen, denen du folgst, empfohlene Musik und neue musikalische Matches.';

  @override
  String get notifCatSocial => 'Daily Vibe, Storys und Beiträge';

  @override
  String get notifCatSocialBody =>
      'Kommentare und Antworten auf das, was du teilst.';

  @override
  String get notifCatDiscoveries => 'Musikalische Entdeckungen';

  @override
  String get notifCatDiscoveriesBody =>
      'Wenn jemand einen Song speichert, den du geteilt hast.';

  @override
  String get notifCatUpdates => 'VIBRA-Neuigkeiten';

  @override
  String get notifCatUpdatesBody =>
      'Deine Musikwoche und gelegentliche Vorschläge.';

  @override
  String get notifQuietTitle => 'Ruhezeiten';

  @override
  String get notifQuietBody =>
      'In diesen Stunden keine Pushs außer Direktnachrichten. Alles wartet in der Übersicht.';

  @override
  String get notifQuietFrom => 'Von';

  @override
  String get notifQuietTo => 'Bis';

  @override
  String notifDailyCap(int count) {
    return 'Höchstens $count Pushs pro Tag';
  }

  @override
  String get notifCalmExplain =>
      'Damit Benachrichtigungen nützlich bleiben, fasst VIBRA wiederholte Aktivität zu einer zusammen („3 neue Kommentare“), pusht dieselbe Gruppe nicht innerhalb von 30 Minuten erneut, hält Pushs in Ruhezeiten zurück, begrenzt weniger wichtige Kategorien auf einen Push pro Tag und benachrichtigt dich nie über blockierte Personen.';

  @override
  String get circlesMuted => 'Benachrichtigungen stumm';

  @override
  String get profileStories => 'Storys';

  @override
  String storyCardSemantics(String name, String kind, int hours) {
    return 'Musik-Story von $name: $kind, vor $hours Std.';
  }

  @override
  String musicRadarMapSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Affinitätskarte mit $count Personen',
      one: 'Affinitätskarte mit 1 Person',
      zero: 'Affinitätskarte, noch niemand',
    );
    return '$_temp0';
  }

  @override
  String musicRadarMapPerson(String name, int percent) {
    return '$name, $percent % Affinität';
  }

  @override
  String get musicRadarMapNote =>
      'Näher an der Mitte heißt mehr gemeinsame Musik. Die Positionen zeigen Affinität, nie, wo jemand ist.';

  @override
  String get safetyOverviewError =>
      'Deine aktuellen Einstellungen konnten nicht geladen werden. Du kannst trotzdem jeden Bereich öffnen.';

  @override
  String get homeSignatureEyebrow => 'DEINE MUSIK, DEINE LEUTE';

  @override
  String get homeSignatureTitle => 'Finde deine Leute durch Musik';

  @override
  String homeDnaTop(String family) {
    return '$family prägt deinen Sound';
  }

  @override
  String get homeDnaEmpty => 'Erstelle sie aus deinen Lieblingsgenres';

  @override
  String homeFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen auf deiner Frequenz',
      one: '1 Person auf deiner Frequenz',
      zero: 'Entdecke Leute mit deinem Geschmack',
    );
    return '$_temp0';
  }

  @override
  String homeConcertMatchNext(String name) {
    return 'Triff Leute, die zu $name gehen';
  }

  @override
  String get homeConcertMatchNone =>
      'Wähle ein Konzert und triff Leute, die hingehen';

  @override
  String homeCirclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Circles',
      one: '1 Circle',
      zero: 'Gründe eine kleine Musikgruppe',
    );
    return '$_temp0';
  }

  @override
  String homeCirclesInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einladungen warten',
      one: '1 Einladung wartet',
    );
    return '$_temp0';
  }
}
