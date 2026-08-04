// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Vibra';

  @override
  String get appSlogan => 'Don\'t just listen to music. Live it.';

  @override
  String get welcomeTitle => 'Welcome to Vibra';

  @override
  String get onboardingConnectTitle => 'Connect Your Tastes';

  @override
  String get onboardingConnectBody =>
      'Connect Spotify, analyze your favorite artists, tracks, and genres, and turn your listening habits into smarter recommendations.';

  @override
  String get onboardingDiscoverTitle => 'Discover the Right Live Shows';

  @override
  String get onboardingDiscoverBody =>
      'Vibra combines location, events, and musical compatibility to suggest concerts that are truly relevant to you.';

  @override
  String get onboardingCommunityTitle => 'Live the Community';

  @override
  String get onboardingCommunityBody =>
      'Find people with your same sound, enter Live Mode during concerts, and join the conversation in real-time.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGoToLogin => 'Go to Login';

  @override
  String get loginTitle => 'Log in to Vibra';

  @override
  String get loginSubtitle =>
      'Log in with your account or connect using one of the supported providers to unlock real recommendations.';

  @override
  String get loginConsent =>
      'By authenticating, you accept data consent, JWT session management, and GDPR privacy preferences.';

  @override
  String get loginWithSpotify => 'Continue with Spotify';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginWithApple => 'Continue with Apple';

  @override
  String get loginWithEmail => 'Email';

  @override
  String get authFailed => 'Authentication failed';

  @override
  String get authErrorOccurred => 'An error occurred';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeaderNotificationsPrivacy => 'Notifications and Privacy';

  @override
  String get settingsSubtitleNotificationsPrivacy =>
      'Preferences, account, and data management';

  @override
  String get settingsOptionCompatibleEvents => 'Compatible event notifications';

  @override
  String get settingsOptionHighMatchAlerts => 'High compatibility user alerts';

  @override
  String get settingsOptionLiveChat => 'Live Chat during concerts';

  @override
  String get settingsOptionDiscoverVisible => 'Profile visible in Discover';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSub =>
      'Check device permissions and push delivery status';

  @override
  String get settingsNotificationsSnackbar =>
      'Notifications depend on device permissions, Firebase configuration, and an authenticated account.';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySub =>
      'Data usage, consents, and user rights';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTermsOfServiceSub =>
      'Rules of use, liabilities, and terms of service';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsSupportSub => 'Help, contacts, and support options';

  @override
  String get settingsAbout => 'About Vibra';

  @override
  String get settingsAboutSub =>
      'App version, identifiers, and product overview';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsLogoutConfirmTitle => 'Log Out';

  @override
  String get settingsLogoutConfirmBody => 'Are you sure you want to log out?';

  @override
  String get settingsLogoutAll => 'Log Out from all devices';

  @override
  String get settingsLogoutAllConfirmTitle => 'Log Out from all devices';

  @override
  String get settingsLogoutAllConfirmBody =>
      'Are you sure you want to log out from all devices? You will be signed out everywhere.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Delete Account';

  @override
  String get settingsDeleteAccountConfirmBody =>
      'Are you sure you want to permanently delete your account? This action is irreversible.';

  @override
  String get settingsDelete => 'Delete';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSub =>
      'Select your preferred application language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String homeGreeting(String username) {
    return 'Hello $username, let\'s listen loud tonight.';
  }

  @override
  String get homeSearchHint => 'Artists, venues, cities';

  @override
  String get homeForYouTitle => 'For You';

  @override
  String get homeForYouSubtitle => 'Events with compatibility score over 70';

  @override
  String get homeNearYouTitle => 'Near You';

  @override
  String get homeNearYouSubtitle => 'Selected with a 50 km GPS radius';

  @override
  String get homeNearYouAction => 'Open map';

  @override
  String get homeTrendingTitle => 'Trending';

  @override
  String get homeTrendingSubtitle => 'Most followed events of the week';

  @override
  String get homeTrendingAction => 'View all';

  @override
  String get settingsSpotifyAccount => 'Spotify Account';

  @override
  String get settingsSpotifyDisconnected =>
      'Disconnected — Connect for recommendations';

  @override
  String get settingsSpotifyDisconnect => 'Disconnect';

  @override
  String get settingsSpotifyDisconnectConfirmTitle => 'Disconnect Spotify';

  @override
  String get settingsSpotifyDisconnectConfirmBody =>
      'Are you sure you want to disconnect your Spotify account? Concert recommendations will no longer be personalized.';

  @override
  String get settingsSpotifyDisconnectedSuccess =>
      'Spotify successfully disconnected';

  @override
  String get settingsGenerateCompatibleUsers => 'Generate Compatible Users';

  @override
  String get settingsGenerateCompatibleUsersSub =>
      'Create bots with similar music tastes';

  @override
  String get settingsGenerateCompatibleUsersLoading =>
      'Generating... Please wait.';

  @override
  String get settingsGenerateCompatibleUsersSuccess =>
      'Generated successfully!';

  @override
  String settingsError(String error) {
    return 'Error: $error';
  }

  @override
  String settingsLogoutError(String error) {
    return 'Error during logout: $error';
  }

  @override
  String settingsSpotifyConnected(String username) {
    return 'Connected as @$username';
  }

  @override
  String get settingsDeleteAccountError =>
      'Unable to delete account. Ensure the RPC has been loaded in the database.';

  @override
  String get eventDetailChat => 'Chat';

  @override
  String get eventDetailTicketsUnavailable => 'Ticket link unavailable.';

  @override
  String get eventDetailTicketsError => 'Unable to open ticket link.';

  @override
  String get eventDetailBuyTickets => 'Buy Tickets';

  @override
  String get eventDetailAttendanceConfirmed => 'Attendance confirmed!';

  @override
  String get eventDetailAttend => 'Going';

  @override
  String get eventDetailAttendanceMaybe => 'Attendance set to Maybe';

  @override
  String get eventDetailMaybe => 'Maybe';

  @override
  String get eventDetailAttendanceNotGoing => 'You marked you are not going';

  @override
  String get eventDetailNotGoing => 'Not going';

  @override
  String get eventDetailCopied => 'Event details copied!';

  @override
  String get exploreSearchEvents => 'Search events';

  @override
  String get exploreSearchInArea => 'Search in this area';

  @override
  String get exploreSearchingEvents => 'Searching for events...';

  @override
  String exploreRadius(String radius) {
    return '$radius km';
  }

  @override
  String get friendsTitle => 'Friends';

  @override
  String get chatSendFailed => 'Failed to send';

  @override
  String get socialTitle => 'Social';

  @override
  String socialRequestFrom(String userId) {
    return 'Request from $userId';
  }

  @override
  String get socialOpen => 'Open';

  @override
  String get userProfileTitle => 'User Profile';

  @override
  String userProfileCompatibility(String percentage) {
    return '$percentage% compatibility';
  }

  @override
  String get userProfileTopArtists => 'Top artists';

  @override
  String get userProfileFriendRequestSent => 'Friend request sent!';

  @override
  String get userProfileSendRequest => 'Send request';

  @override
  String get userProfileOpenChat => 'Open chat';

  @override
  String socialMatchVibraSent(String name) {
    return 'Vibra sent to $name! 🎉';
  }

  @override
  String get socialMatchViewProfile => 'View full profile';

  @override
  String get socialMatchIgnore => 'Ignore';

  @override
  String get userProfileNotAvailableTitle => 'Profile not available';

  @override
  String get userProfileNotAvailableMessage =>
      'No user selected or no match available at the moment.';

  @override
  String get userProfileEvents => 'Past/upcoming concerts';

  @override
  String get socialDiscoverUsers => 'Discover users';

  @override
  String get socialHighCompatibility => 'Users with high musical compatibility';

  @override
  String socialRequestsCount(int count) {
    return 'Requests ($count)';
  }

  @override
  String get socialPendingFriendships => 'Pending friendships';

  @override
  String get socialRequestsToManage => 'Requests to manage';

  @override
  String get navHome => 'Home';

  @override
  String get navEvents => 'Events';

  @override
  String get navVibra => 'Vibra';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get friendsYourFriends => 'Your friends';

  @override
  String get friendsYourConnections => 'Your Vibra connections';

  @override
  String get friendsNoFriendsYet => 'No friends yet';

  @override
  String get friendsGoToExplore =>
      'Go to the Explore section or use Social Match to find people with the same taste.';

  @override
  String get friendsSentRequests => 'Sent requests';

  @override
  String get friendsWaitingForReply => 'Waiting for reply';

  @override
  String get friendsPendingApproval => 'Pending approval';

  @override
  String get socialMatchNewAffinity => 'NEW AFFINITY';

  @override
  String get socialMatchScore => 'MATCH SCORE';

  @override
  String get socialMatchWhyMatched => 'WHY YOU MATCHED';

  @override
  String socialMatchCommonEvents(String count) {
    return 'Live nearby • $count common events';
  }

  @override
  String get socialMatchSendVibra => 'Send Vibra';

  @override
  String get exploreSearchHint => 'Search by name or city (e.g. Milan)';

  @override
  String get exploreInteractiveMap => 'Interactive map';

  @override
  String get exploreLiveAroundYou =>
      'Explore live events around you in real time';

  @override
  String get exploreSearchRadius => 'Search radius';

  @override
  String get exploreFindEventsNearYou => 'Find events near you';

  @override
  String get exploreMusicGenre => 'Music genre';

  @override
  String get exploreFilterByGenre => 'Filter by your favorite genres';

  @override
  String get exploreGenreAll => 'All';

  @override
  String get friendsReceivedRequests => 'Received requests';

  @override
  String get friendsAcceptOrReject => 'Accept or reject new connections';

  @override
  String get friendsWantsToConnect => 'Wants to connect with you';

  @override
  String socialMatchListenBoth(String artists) {
    return 'You both listen to $artists';
  }

  @override
  String socialMatchCityEvents(String city, String count) {
    return '$city • $count common events';
  }

  @override
  String get myProfileConnectSpotify => 'Connect Spotify';

  @override
  String get myProfileOverview => 'Overview';

  @override
  String get myProfileOverviewSubtitle => 'Quick access to profile areas';

  @override
  String get myProfileSettings => 'Settings';

  @override
  String get myProfileMusicStats => 'Music stats';

  @override
  String get myProfileMusicStatsSubtitle =>
      'Top artists, genres and listening heatmap';

  @override
  String get myProfileMyEvents => 'My events';

  @override
  String myProfileMyEventsSubtitle(String count) {
    return '$count saved, upcoming and past events';
  }

  @override
  String get myProfileSettingsSubtitle =>
      'Privacy, notifications, account and logout';

  @override
  String get myEventsTitle => 'My Events';

  @override
  String get myEventsGoing => 'Going';

  @override
  String get myEventsGoingSubtitle => 'Confirmed or upcoming events';

  @override
  String get myEventsGoingEmpty =>
      'You haven\'t confirmed your attendance to any event yet.\\nExplore and find your next concerts!';

  @override
  String get myEventsSaved => 'Saved';

  @override
  String get myEventsSavedSubtitle => 'Keep an eye on';

  @override
  String get myEventsSavedEmpty =>
      'No saved events.\\nSave the events you are interested in so you don\'t miss them.';

  @override
  String get chatEmptyTitle => 'No messages';

  @override
  String get chatEmptyMessage => 'Start the conversation!';

  @override
  String get chatInputHint => 'Write a message...';

  @override
  String get socialMatchScanningTitle => 'VIBE ANALYSIS';

  @override
  String get socialMatchScanningSubtitle =>
      'Searching for people with similar music taste nearby...';

  @override
  String get socialMatchEmptyTitle => 'No matches nearby';

  @override
  String get socialMatchEmptyMessage =>
      'Your music vibes are unique! There are no people with similar tastes nearby right now...';

  @override
  String get socialMatchEmptyAction => 'Discover nearby events';

  @override
  String get socialMatchEmptySecondary => 'Search again';

  @override
  String get musicStatsTitle => 'Music Stats';

  @override
  String musicStatsSyncError(String error) {
    return 'Sync error: $error';
  }

  @override
  String get musicStatsTopArtists => 'Top artists';

  @override
  String get musicStatsTopArtistsSub => 'Score based on Spotify preferences';

  @override
  String get musicStatsHeatmap => 'Listening heatmap';

  @override
  String get musicStatsHeatmapSub => 'Weekly distribution of your listening';

  @override
  String get liveScreenTitle => 'Live Vibra';

  @override
  String get liveScreenSendFailed =>
      'Send failed. Check session and attendance.';

  @override
  String get liveScreenActivateMode => 'Activate Live Mode';

  @override
  String get liveScreenPresentNowTitle => 'Present now';

  @override
  String get liveScreenPresentNowSub =>
      'Attendees with high musical compatibility';

  @override
  String get liveScreenChatTitle => 'Event Chat';

  @override
  String get liveScreenChatSub => 'Realtime chat auto-closes in 24h';

  @override
  String get eventDetailNotAvailableTitle => 'Event unavailable';

  @override
  String get eventDetailNotAvailableMsg =>
      'This event is no longer available or hasnt loaded.';

  @override
  String get eventDetailMapTitle => 'Venue Map';

  @override
  String get eventDetailMapSub => 'Event location';

  @override
  String get eventDetailAttendeesTitle => 'Attendees';

  @override
  String get eventDetailAttendeesSub =>
      'Users with musical match and confirmed attendance';

  @override
  String get spotifyAuthStep1Title => '1. OAuth Authorization';

  @override
  String get spotifyAuthStep1Sub => 'Securely login on official Spotify site';

  @override
  String get spotifyAuthStep2Title => '2. Credential Exchange';

  @override
  String get spotifyAuthStep2Sub =>
      'Generation of secure keys and token encryption';

  @override
  String get spotifyAuthStep3Title => '3. Taste Syncing';

  @override
  String get spotifyAuthStep3Sub =>
      'Analysis of top artists, tracks, and playlists';

  @override
  String get spotifyAuthCancelled =>
      'Connection cancelled. You must authorize Vibra for personalized recommendations.';

  @override
  String spotifyAuthError(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get legalPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get legalPrivacySec1 => 'What data Vibra collects';

  @override
  String get legalPrivacySec2 => 'Why Vibra uses it';

  @override
  String get legalPrivacySec3 => 'Your controls';

  @override
  String get legalPrivacySec4 => 'Privacy contact';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalTermsSec1 => 'Using Vibra';

  @override
  String get legalTermsSec2 => 'Third-party services';

  @override
  String get legalTermsSec3 => 'Content and behavior';

  @override
  String get legalTermsSec4 => 'Legal contact';

  @override
  String get legalSupportTitle => 'Support';

  @override
  String get legalSupportSec1 => 'Support email';

  @override
  String get legalSupportSec2 => 'Covered issues';

  @override
  String get legalSupportSec3 => 'What to check first';

  @override
  String get legalAboutTitle => 'About Vibra';

  @override
  String get legalAboutSec1 => 'Version';

  @override
  String get legalAboutSec2 => 'Platform identifiers';

  @override
  String get legalAboutSec3 => 'What Vibra does';

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
  String get spotifyAuthCancelledTitle => 'Authentication Failed';

  @override
  String get errorTitle => 'System Error';

  @override
  String get legalPrivacyBody1 =>
      'Account data, music profile, event attendance, messages, live chat activity, location when authorized, and push tokens.';

  @override
  String get legalPrivacyBody2 =>
      'To authenticate users, generate music recommendations, enable social features, send notifications, and improve service reliability.';

  @override
  String get legalPrivacyBody3 =>
      'You can revoke permissions, disconnect services, request deletion, and manage visibility and privacy preferences from account settings.';

  @override
  String legalPrivacyBody4(String email) {
    return 'Privacy and personal data requests: $email';
  }

  @override
  String get legalTermsBody1 =>
      'By using Vibra, users agree to use the app lawfully, maintain accurate data, and avoid abusive or harmful behavior.';

  @override
  String get legalTermsBody2 =>
      'Spotify, Supabase, Firebase, and event providers may be used to deliver core features. Their terms and privacy policies also apply.';

  @override
  String get legalTermsBody3 =>
      'Users are responsible for published content and sent messages. Vibra may suspend or remove accounts that violate platform rules.';

  @override
  String legalTermsBody4(String email) {
    return 'Legal requests and formal communications: $email';
  }

  @override
  String legalSupportBody1(String email) {
    return '$email';
  }

  @override
  String get legalSupportBody2 =>
      'Login issues, Spotify connection, event discovery, notifications, chat, privacy requests, and account deletion.';

  @override
  String get legalSupportBody3 =>
      'Permissions, Spotify connection status, Firebase configuration, and the presence of an authenticated user.';

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
      'Vibra helps connect Spotify, discover relevant live events, view event details, meet compatible people, and join live chats during concerts.';

  @override
  String legalAboutBody4(String email) {
    return '$email';
  }

  @override
  String get homeGreetingMorning => 'Good morning 👋';

  @override
  String get homeGreetingAfternoon => 'Good afternoon 👋';

  @override
  String get homeGreetingEvening => 'Good evening 🌙';

  @override
  String get eventCardTBA => 'TBA';

  @override
  String get eventCardCity => 'City';

  @override
  String get legalPrivacySubtitle =>
      'A summary of the privacy information available in the app, including categories of processed data and purposes of use.';

  @override
  String get legalTermsSubtitle =>
      'A summary of the rules, responsibilities, and terms of service applicable to using Vibra.';

  @override
  String get legalSupportSubtitle =>
      'Support information for account access, notifications, Spotify connection, and live features.';

  @override
  String get legalAboutSubtitle =>
      'Vibra combines music taste, event discovery, and social interaction around live experiences.';

  @override
  String get exploreShowAllEvents => 'Show all events';

  @override
  String get musicStatsSyncSpotify => 'Sync Spotify';

  @override
  String get liveModeDisabled => 'Live mode is disabled';

  @override
  String get authCreateAccount => 'Create an Account';

  @override
  String get authLoginWithEmail => 'Login with Email';

  @override
  String get authUsername => 'Username';

  @override
  String get authUsernameHint => 'Enter a username';

  @override
  String get authEmail => 'Email Address';

  @override
  String get authEmailHint => 'Enter your email';

  @override
  String get authEmailInvalid => 'Enter a valid email';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authPasswordShort => 'Password must be at least 6 characters';

  @override
  String get authRegister => 'Register';

  @override
  String get authLogin => 'Login';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? Login';

  @override
  String get authDontHaveAccount => 'Don t have an account? Register';

  @override
  String get authGenericError => 'An error occurred';

  @override
  String get eventCardLocation => 'Location';

  @override
  String get matchScore => 'MATCH SCORE';

  @override
  String get userGeneric => 'User';

  @override
  String get spotifyConnectTitle => 'Connect Spotify';

  @override
  String get spotifyConnectSubtitle =>
      'Connect your account to sync your favorite artists and unlock personalized recommendations for concerts.';

  @override
  String get spotifyConnectOnboarding => 'Onboarding Flow';

  @override
  String get spotifyConnectPrivacyDesc =>
      'We will read your top artists and genres to personalize recommendations and calculate your affinity (Match Score) with other users. Aggregated historical data will only be used for this purpose.';

  @override
  String get spotifyConnectContinue => 'Continue and Explore';

  @override
  String get spotifyConnectRetry => 'Retry Connection';

  @override
  String get spotifyConnectAction => 'Connect my Spotify';

  @override
  String get spotifyConnectSkip => 'Skip for now';

  @override
  String get homeSpotifySyncTitle => 'Unlock Personalized Recommendations';

  @override
  String get homeSpotifySyncSub => 'Sync your music listening';

  @override
  String get homeSpotifySyncDesc =>
      'Connect Spotify to get event recommendations and find people with your same tastes.';

  @override
  String get homeSpotifySyncAction => 'CONNECT SPOTIFY';
}
