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
      'Discover concerts and people to enjoy them with.';

  @override
  String get loginConsent =>
      'Read the terms and privacy information before continuing. Manage optional preferences in settings.';

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
      'To receive notifications, sign in and enable Vibra notifications in your device settings.';

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
      'Vibra will delete your Spotify connection, synced artists and genres, listening history and musical matches. Event suggestions will no longer be personalized.';

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
      'Could not delete your account. Try again or contact support.';

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
  String get socialPeopleSection => 'People';

  @override
  String get socialAffinityTitle => 'Find your music matches';

  @override
  String socialRequestsPreview(String name, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$name and $others others want to connect',
      one: '$name and 1 other person want to connect',
      zero: '$name wants to connect with you',
    );
    return '$_temp0';
  }

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
      'Explore the community to find people and send friend requests.';

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
  String exploreSearchRadius(int radius) {
    return 'SEARCH RADIUS: $radius KM';
  }

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
  String get myEventsUpcoming => 'Upcoming';

  @override
  String get myEventsPast => 'Past';

  @override
  String get myEventsPastSubtitle => 'Your concert history';

  @override
  String get myEventsPastEmpty => 'No past events yet.';

  @override
  String get myEventsSearchHint => 'Search events, artists or places';

  @override
  String get myEventsSearchEmpty => 'No events match your search.';

  @override
  String get myEventsClearSearch => 'Clear search';

  @override
  String get myEventsExplore => 'Explore events';

  @override
  String get inboxUnread => 'Unread';

  @override
  String get inboxNoResults => 'No conversations found.';

  @override
  String get inboxNoResultsBody =>
      'Try another name or clear the filters to see all messages.';

  @override
  String get inboxClearFilters => 'Clear filters';

  @override
  String get homeFeedError => 'Events could not be loaded.';

  @override
  String get homeFeedErrorBody =>
      'Try again shortly. You can still explore the map.';

  @override
  String get homeFeedEmpty => 'There’s room for a new night out.';

  @override
  String get homeFeedEmptyBody =>
      'Explore the map to find your next live show.';

  @override
  String get socialSearchHint => 'Search people or artists';

  @override
  String get socialSearchEmpty => 'No people found.';

  @override
  String get socialSearchEmptyBody => 'Try another name or artist.';

  @override
  String get socialDiscoverEmpty => 'New connections start here.';

  @override
  String get socialDiscoverEmptyBody =>
      'Complete your profile and connect Spotify to find people with similar tastes.';

  @override
  String get chatSendMessage => 'Send message';

  @override
  String get chatLoadError => 'The conversation could not be loaded.';

  @override
  String get chatDraftRecovered =>
      'The message was not sent. Its text has been restored in the composer.';

  @override
  String get eventLocationUnknown => 'The exact location is not available yet.';

  @override
  String get eventDirections => 'Get directions';

  @override
  String get eventDirectionsError => 'Directions could not be opened.';

  @override
  String get inboxDeleteTitle => 'Delete this conversation?';

  @override
  String get inboxDeleteBody =>
      'The conversation will be removed from your inbox. The other person’s messages will not be deleted.';

  @override
  String get inboxDeleteAction => 'Delete conversation';

  @override
  String get inboxDeleteSuccess => 'Conversation deleted.';

  @override
  String get inboxDeleteError =>
      'The conversation was not deleted. Please try again.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get eventCopyDetails => 'Copy event details';

  @override
  String get eventCopyError => 'Event details could not be copied.';

  @override
  String get eventCancelled => 'Event cancelled';

  @override
  String get eventTicketsOffsale => 'Tickets not on sale';

  @override
  String get socialMatchSendFailed =>
      'Vibra was not sent. Try again: the profile is still available.';

  @override
  String get myEventsTitle => 'My Events';

  @override
  String get myEventsGoing => 'Going';

  @override
  String get myEventsGoingSubtitle => 'Confirmed or upcoming events';

  @override
  String get myEventsGoingEmpty =>
      'You haven\'t confirmed your attendance to any event yet.\nExplore and find your next concerts!';

  @override
  String get myEventsSaved => 'Saved';

  @override
  String get myEventsSavedSubtitle => 'Keep an eye on';

  @override
  String get myEventsSavedEmpty =>
      'No saved events.\nSave the events you are interested in so you don\'t miss them.';

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
      'This event is no longer available or hasn’t loaded yet.';

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
      'Check your connection, device permissions and sign-in status. If the issue persists, report a problem from settings.';

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
      'Vibra helps you discover live events, explore the map, save concerts, meet people and join chats. Spotify features are available only when the service is enabled.';

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
      'Live events, a map and a community to share new nights out.';

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
  String get authDontHaveAccount => 'Don’t have an account? Register';

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

  @override
  String get loginBackToWelcome => 'Back to the welcome screen';

  @override
  String get authOr => 'or';

  @override
  String get authEmailLoginSubtitle =>
      'Enter your credentials to log in and explore concerts.';

  @override
  String get authEmailRegisterSubtitle =>
      'Enter your credentials to register and start enjoying live shows.';

  @override
  String get authAgeConfirmation =>
      'I confirm that I am at least 18 years old.';

  @override
  String get authAgeExplanation =>
      'Vibra helps people meet and is not intended for minors.';

  @override
  String get authAgeRequired =>
      'You must confirm that you are at least 18 years old to create an account.';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get spotifyUnavailableTitle => 'Spotify is paused';

  @override
  String get spotifyUnavailableBody =>
      'Spotify and music affinity are temporarily disabled. Events, friends and chat remain available.';

  @override
  String get launchExploreTitle => 'Find your next concert';

  @override
  String get launchExploreBody =>
      'Search artists, explore the map and save nearby events.';

  @override
  String get launchCommunityTitle => 'Join the community';

  @override
  String get launchCommunityBody =>
      'Find people, add friends and plan concerts in your chats.';

  @override
  String get launchSavedTitle => 'Your live calendar';

  @override
  String get launchSavedBody =>
      'Save concerts and find the ones you want to attend.';

  @override
  String get launchCommunitySubtitle => 'Search people by name or username';

  @override
  String get launchCommunityEmptyTitle => 'No people found';

  @override
  String get launchCommunityEmptyBody =>
      'Try another name or check back later.';

  @override
  String get launchCommunityLoadError => 'Could not load people. Try again.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonAll => 'All';

  @override
  String get commonConnect => 'Connect';

  @override
  String get commonActive => 'Active';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonTryLater => 'Try again later.';

  @override
  String get commonConnectionError => 'Connection error';

  @override
  String commonLoadingLabel(String label) {
    return '$label, loading';
  }

  @override
  String commonSelectedLabel(String label) {
    return '$label, selected';
  }

  @override
  String commonNotSelectedLabel(String label) {
    return '$label, not selected';
  }

  @override
  String get commonOnline => 'Online';

  @override
  String get commonAvatar => 'Avatar';

  @override
  String commonPercentLabel(int percentage, String label) {
    return '$percentage percent $label';
  }

  @override
  String commonAvatarAffinity(String name, int percentage) {
    return '$name, $percentage percent affinity';
  }

  @override
  String get commonRegistrationComplete => 'Registration complete';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileBack => 'Back to profile';

  @override
  String get profilePersonalSpace => 'PERSONAL SPACE';

  @override
  String get profileSpotifyConnected => 'Spotify connected';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileOpenMusicStats => 'Open music statistics';

  @override
  String get profileYourVibra => 'YOUR VIBRA';

  @override
  String get profileInRotation => 'In rotation';

  @override
  String get profileSyncMusicBody => 'Sync Spotify to see your music profile.';

  @override
  String get profileShapeTitle => 'Shape your Vibra';

  @override
  String get profileShapeBody =>
      'Connect Spotify to show your musical identity.';

  @override
  String get profileUsernameEmpty => 'Username cannot be empty';

  @override
  String get profileUsernameShort => 'At least 3 characters';

  @override
  String get profileUsernameCharacters => 'Use only letters, numbers, _ or .';

  @override
  String get profileUsernameCharactersOnboarding =>
      'Use only letters, numbers and underscores';

  @override
  String get profileUsernameTaken => 'Username already taken';

  @override
  String get profileUsernameTakenRetry =>
      'This username is taken. Choose another one.';

  @override
  String get profilePhotoPermission =>
      'Allow access to photos in your device settings and try again.';

  @override
  String get profilePhotoPickError => 'Could not select the photo. Try again.';

  @override
  String get profilePhotoTitle => 'Profile photo';

  @override
  String get profilePhotoGallery => 'Choose from gallery';

  @override
  String get profilePhotoGalleryBody => 'Select a photo from your device';

  @override
  String get profilePhotoCamera => 'Take a photo';

  @override
  String get profilePhotoCameraBody => 'Use the camera to take a new photo';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get profilePhotoRestore => 'Restore the default avatar';

  @override
  String get profileSaved => 'Profile updated!';

  @override
  String get profileSaveError =>
      'Could not save your profile. Try again shortly.';

  @override
  String get profilePhotoChange => 'Change profile photo';

  @override
  String get profileUsernameExample => 'e.g. music_fan';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameHint => 'Your name or nickname';

  @override
  String get profileNameEmpty => 'Name cannot be empty';

  @override
  String get profileDescription => 'Bio';

  @override
  String get profileDescriptionHint => 'Tell us about yourself…';

  @override
  String get profileMusicStreaming => 'Music and streaming';

  @override
  String get profileAccountConnected => 'Account connected';

  @override
  String get profileConnectSuggestions =>
      'Connect your account for better suggestions';

  @override
  String get profileSaveChanges => 'Save changes';

  @override
  String get homeYourSoundToday => 'YOUR SOUND, TODAY';

  @override
  String get homeSpotifySynced => 'Spotify synced · suggestions learn from you';

  @override
  String get homeSpotifyPersonalize =>
      'Connect Spotify to personalize your suggestions';

  @override
  String get homeCompleteProfile => 'Complete your profile';

  @override
  String get homeShapeVibra => 'Make your Vibra your own';

  @override
  String get homeNextEvent => 'UP NEXT';

  @override
  String get homeNearbyEyebrow => 'NEARBY';

  @override
  String get homeTrendingEyebrow => 'HAPPENING NOW';

  @override
  String get settingsPrivateMessages => 'Private messages and requests';

  @override
  String get settingsPersonalizedUpdates =>
      'Personalized updates and reminders';

  @override
  String get settingsMusicWeek => 'Your music week';

  @override
  String get settingsMusicWeekBody => 'Events and affinities selected for you';

  @override
  String get settingsWeekly => 'Weekly';

  @override
  String get settingsMonthly => 'Monthly';

  @override
  String get settingsNever => 'Never';

  @override
  String get settingsPrivacyData => 'Privacy and personal data';

  @override
  String get settingsPrivacyDataBody => 'Consent, data export and deletion';

  @override
  String get settingsHelpCenter => 'Help center';

  @override
  String get settingsHelpCenterBody =>
      'Help with accounts, events, chat and Spotify';

  @override
  String get settingsReportProblem => 'Report a problem';

  @override
  String get settingsReportProblemBody =>
      'Send sanitized diagnostics and an optional screenshot';

  @override
  String get privacySaveError => 'Could not save your preference. Try again.';

  @override
  String get privacyExportTitle => 'Your data export';

  @override
  String get privacySaveJSON => 'Save JSON';

  @override
  String get privacyCopyJSON => 'Copy JSON';

  @override
  String get privacyCopiedJSON => 'JSON copied to clipboard.';

  @override
  String get privacyExportError => 'Data export unavailable. Try again later.';

  @override
  String privacyExportSaved(String path) {
    return 'Export saved to $path';
  }

  @override
  String get privacyIntro =>
      'Choose each optional use of your data separately. You can change your mind at any time.';

  @override
  String get privacyPreciseLocation => 'Precise location';

  @override
  String get privacyPreciseLocationBody =>
      'For nearby events and Live features. Stored for up to 30 days.';

  @override
  String get privacySpotifyMatching => 'Spotify for music affinity';

  @override
  String get privacySpotifyMatchingBody =>
      'Use synced artists, genres and listening for suggestions and affinity.';

  @override
  String get privacyServiceNotifications => 'Service notifications';

  @override
  String get privacyServiceNotificationsBody =>
      'Matches, messages and saved events.';

  @override
  String get privacyMarketing => 'Marketing messages';

  @override
  String get privacyMarketingBody =>
      'Always optional; you can use the app without them.';

  @override
  String get privacyExportAction => 'Export my data';

  @override
  String get privacyExportBody =>
      'Generate a readable JSON copy of your profile, chats, events and interactions, including previous Spotify data if present.';

  @override
  String get privacyDeletionBody =>
      'Deleting your account removes its data. Sent messages become anonymous and their content and media are removed. Backups follow the retention period stated in the privacy policy.';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceBody => 'Choose the app theme or follow your device.';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceDarkBody => 'Reduces brightness in low light';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceLightBody => 'Bright surfaces and soft shadows';

  @override
  String get appearanceSystem => 'Automatic (system)';

  @override
  String get appearanceSystemBody => 'Updates when your device setting changes';

  @override
  String get onboardingBack => 'Back to the previous step';

  @override
  String get onboardingStart => 'Let’s start';

  @override
  String get onboardingProfileTitle => 'Your profile';

  @override
  String get onboardingProfileBody => 'How other people will see you';

  @override
  String get onboardingSkipToHome => 'Skip the rest and go to Home';

  @override
  String get onboardingPhotoUploading => 'Uploading profile photo';

  @override
  String get onboardingPhotoSelect => 'Choose or change your profile photo';

  @override
  String get onboardingUsernameExample => 'e.g. vibra_user';

  @override
  String get onboardingRequired => 'REQUIRED';

  @override
  String get onboardingSpotifyBody =>
      'Find events based on your listening and discover musical affinity with other people.';

  @override
  String get onboardingSpotifyCancelled =>
      'Connection cancelled. Try again or skip for now.';

  @override
  String get onboardingSpotifyError => 'Could not connect. Try again later.';

  @override
  String get onboardingLocationTitle => 'Events near you';

  @override
  String get onboardingLocationBody =>
      'Enable location to discover concerts and venues in your area.';

  @override
  String get onboardingLocationDenied =>
      'Permission permanently denied. You can enable it later in your device settings.';

  @override
  String get onboardingAllowLocation => 'Allow location';

  @override
  String get onboardingNotificationsTitle => 'Stay up to date';

  @override
  String get onboardingNotificationsBody =>
      'Get notifications for saved events, friend requests and messages.';

  @override
  String get onboardingNotificationsDenied =>
      'Notifications denied. You can enable them in your device settings.';

  @override
  String get onboardingAllowNotifications => 'Enable notifications';

  @override
  String get liveAttendanceError => 'Could not confirm attendance. Try again.';

  @override
  String get liveEventsLoadError => 'Could not load Live events.';

  @override
  String get liveLocationHelp =>
      'Live chat is available within 500 m of an event, during the 24 hours before and after the concert. Enable location in privacy settings.';

  @override
  String get liveUnavailableHere =>
      'This event’s chat is unavailable at your location or at this time.';

  @override
  String get liveRefreshLocation => 'Refresh location';

  @override
  String get liveEventTitle => 'Live event';

  @override
  String get liveConnectionInterrupted => 'Live chat connection interrupted.';

  @override
  String get liveEmpty => 'No messages. Start the conversation!';

  @override
  String get liveRetryAttendance => 'Check attendance again';

  @override
  String get liveConfirmingAttendance => 'Confirming attendance…';

  @override
  String get liveJoinToChat => 'Join the event to write in chat';

  @override
  String get liveInputHint => 'Write in Live chat…';

  @override
  String get liveSendMessage => 'Send Live message';

  @override
  String get musicReconnect => 'Reconnect';

  @override
  String get musicReconnectBody =>
      'Reconnect Spotify to update music statistics.';

  @override
  String get musicStatsUpdated => 'Music statistics updated.';

  @override
  String get musicStatsRefreshing => 'Updating music statistics';

  @override
  String get musicStatsNoArtists => 'No artists available after the last sync.';

  @override
  String get musicStatsEmptyTitle => 'Give your profile a sound.';

  @override
  String get musicStatsEmptyBody =>
      'Connect Spotify to see the artists and rhythms that define you.';

  @override
  String get musicStatsYourSound => 'YOUR SOUND';

  @override
  String get musicStatsHeroTitle => 'Listening that makes a mark.';

  @override
  String get musicStatsArtists => 'Artists';

  @override
  String get musicStatsRhythm => 'Rhythm';

  @override
  String get spotifyBackToLogin => 'Back to login';

  @override
  String get spotifyConsentBody =>
      'Vibra reads your Spotify profile, your top artists, tracks and genres from the last ~6 months, and the times of your recent plays. We use them for music statistics, event suggestions and musical affinity. Your Spotify credentials stay encrypted on our servers, never on this device. You can disconnect Spotify and delete this data at any time in Settings.';

  @override
  String get eventBackToEvents => 'Back to events';

  @override
  String get eventPrice => 'Price';

  @override
  String get eventVenueTBA => 'Venue to be announced';

  @override
  String eventOpenSemantics(String name, String date, String place) {
    return 'Open event $name, $date, $place';
  }

  @override
  String eventAffinitySemantics(int percentage) {
    return '$percentage percent affinity';
  }

  @override
  String eventForYouScore(int percentage) {
    return '$percentage% FOR YOU';
  }

  @override
  String eventCommonSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shared or saved events',
      one: '$count shared or saved event',
    );
    return '$_temp0';
  }

  @override
  String get supportReportTitle => 'Report a problem';

  @override
  String get supportReportIntro =>
      'Describe what is not working. We’ll include the app version, operating system and a few diagnostics with sensitive information removed.';

  @override
  String get supportDescriptionLabel => 'Problem description';

  @override
  String get supportDescriptionHint =>
      'Include the screen, steps and what you expected.';

  @override
  String get supportAddScreenshot => 'Add screenshot';

  @override
  String get supportScreenshotAttached => 'Screenshot attached';

  @override
  String get supportRemoveScreenshot => 'Remove screenshot';

  @override
  String get supportScreenshotPrivacy =>
      'Make sure the screenshot does not show passwords, private messages or other sensitive data.';

  @override
  String get supportSending => 'Sending…';

  @override
  String get supportSendReport => 'Send report';

  @override
  String get supportDescriptionTooShort =>
      'Describe the problem in at least 8 characters.';

  @override
  String get supportDescriptionTooLong =>
      'The description can contain up to 4000 characters.';

  @override
  String get supportReportSentTitle => 'Report sent';

  @override
  String get supportReportSentBody =>
      'We’ve received your report. Support replies within 48 business hours.';

  @override
  String supportReportSendFailed(String email) {
    return 'Could not send the report. Try again or contact $email.';
  }

  @override
  String get supportReportAuthRequired => 'Sign in again to send the report.';

  @override
  String get supportReportRateLimited =>
      'You’ve sent too many reports. Wait a minute and try again.';

  @override
  String get supportScreenshotTooLarge =>
      'The screenshot must be smaller than 5 MB.';

  @override
  String get supportScreenshotUnsupported => 'Choose a JPG or PNG screenshot.';

  @override
  String get supportScreenshotPickFailed =>
      'Could not select the screenshot. Try again.';

  @override
  String get supportScreenshotPermissionDenied =>
      'Allow photo access in device settings to attach a screenshot.';

  @override
  String supportAlternativeContact(String email) {
    return 'You can also contact $email. We reply within 48 business hours.';
  }

  @override
  String get supportFeedbackTitle => 'How is Vibra going?';

  @override
  String get supportFeedbackBody => 'Your feedback helps us improve.';

  @override
  String get supportFeedbackNegative => 'Not well';

  @override
  String get supportFeedbackNeutral => 'So-so';

  @override
  String get supportFeedbackPositive => 'Great!';

  @override
  String get supportFeedbackDescriptionPrefix => 'Feedback:';

  @override
  String get chatSendFriendshipRequired =>
      'To message this person, send a friend request and wait for it to be accepted.';

  @override
  String get chatSendFirstContactLimit =>
      'You’ve already sent 3 messages. Wait for a reply before sending more.';

  @override
  String get chatSendUnavailable => 'This conversation is unavailable.';

  @override
  String get chatSendRateLimited =>
      'You’re sending too many messages. Wait a minute and try again.';

  @override
  String get chatSendSignInRequired => 'Sign in again to send your message.';

  @override
  String get chatRequestFriendship => 'Send friend request';

  @override
  String get chatFriendshipRequestSent => 'Friend request sent';

  @override
  String get chatFriendshipRequestFailed =>
      'Could not send the friend request. Try again.';

  @override
  String get chatMessageTooLong =>
      'The message can contain up to 2000 characters.';

  @override
  String get chatPermissionChecking => 'Checking conversation…';

  @override
  String get chatFriendshipRequestPending =>
      'Friend request awaiting acceptance';

  @override
  String get chatAcceptFriendship => 'Accept friend request';

  @override
  String get chatFriendshipAccepted =>
      'Friend request accepted. You can now send messages.';

  @override
  String get socialReportUser => 'Report user';

  @override
  String get socialReportSpam => 'Spam';

  @override
  String get socialReportHarassment => 'Harassment';

  @override
  String get socialReportInappropriate => 'Inappropriate content';

  @override
  String get socialReportDetailsHint => 'Additional details (optional)';

  @override
  String get socialReportSent => 'User reported';

  @override
  String get socialReportFailed => 'Could not submit the report. Try again.';

  @override
  String get socialReportAction => 'Report';

  @override
  String get socialBlockUser => 'Block user';

  @override
  String get socialBlockConfirm =>
      'Block this person? You will no longer be able to exchange messages.';

  @override
  String get socialBlockSuccess => 'User blocked';

  @override
  String get socialBlockFailed => 'Could not block this person. Try again.';

  @override
  String get socialBlockAction => 'Block';

  @override
  String get chatRequestTitle => 'Message request';

  @override
  String chatRequestBody(String name) {
    return '$name would like to message you. Reply to accept the conversation.';
  }

  @override
  String get chatRequestRejected => 'Request declined and deleted';

  @override
  String get chatRequestRejectFailed =>
      'Could not delete the request. Try again.';

  @override
  String get commonReject => 'Decline';

  @override
  String get commonReply => 'Reply';

  @override
  String get userProfileView => 'View profile';

  @override
  String get chatConnectionInterrupted => 'Chat connection interrupted.';

  @override
  String get chatMeetupTitle => 'Meetup proposal';

  @override
  String get chatMeetupAccept => 'I’m in';

  @override
  String get chatMeetupDecline => 'I can’t';

  @override
  String chatMeetupAcceptMessage(String message) {
    return 'I’m in! $message';
  }

  @override
  String chatMeetupDeclineMessage(String message) {
    return 'I can’t attend. $message';
  }

  @override
  String get helpIntro =>
      'Quick answers and support. We reply within 48 business hours.';

  @override
  String get helpSearchHint => 'Search frequently asked questions';

  @override
  String get helpSearchEmpty => 'No answers found. Try another search.';

  @override
  String get helpNeedMore => 'Still need help?';

  @override
  String get helpCategoryAll => 'All';

  @override
  String get helpCategoryAccount => 'Account';

  @override
  String get helpCategoryChatMatch => 'Chat and affinity';

  @override
  String get helpCategoryPrivacy => 'Privacy';

  @override
  String get helpLoginQuestion => 'I can’t sign in';

  @override
  String get helpLoginAnswer =>
      'Check your email and password, then close and reopen Vibra. If it still fails, use “Report a problem” and include your sign-in method.';

  @override
  String get helpLogoutQuestion => 'How do I sign out?';

  @override
  String get helpLogoutAnswer =>
      'Go to Profile > Settings > Log out. To end all sessions, choose “Log out from all devices”.';

  @override
  String get helpDeleteQuestion => 'How do I delete my account?';

  @override
  String get helpDeleteAnswer =>
      'Go to Profile > Settings > Delete account. Confirming removes your account data as described in the privacy policy.';

  @override
  String get helpEventsQuestion => 'Why are there no events near me?';

  @override
  String get helpEventsAnswer =>
      'Check location access and widen the search radius. Availability depends on event sources in the area; you can also search a city.';

  @override
  String get helpTicketsQuestion => 'An event or ticket link won’t open';

  @override
  String get helpTicketsAnswer =>
      'Events and tickets come from external partners. Try again later; if the issue persists, report it and include the event.';

  @override
  String get helpAffinityQuestion => 'How is affinity calculated?';

  @override
  String get helpAffinityAnswer =>
      'The score compares shared artists and genres, with a small bonus for less common tastes. It indicates affinity and is not a guarantee.';

  @override
  String get helpBlockQuestion => 'How do I block or report someone?';

  @override
  String get helpBlockAnswer =>
      'Open the conversation and use its menu to block or report the person. Blocking prevents future interactions; reports are sent to the team.';

  @override
  String get helpSpotifyConnectQuestion => 'How do I connect Spotify?';

  @override
  String get helpSpotifyConnectAnswer =>
      'Go to Profile > Settings > Spotify account and complete authorization in Spotify. You’ll return to Vibra automatically.';

  @override
  String get helpSpotifyDisconnectQuestion => 'How do I disconnect Spotify?';

  @override
  String get helpSpotifyDisconnectAnswer =>
      'Go to Profile > Settings > Spotify account and choose “Disconnect”.';

  @override
  String get helpSpotifyErrorQuestion => 'Spotify connection fails';

  @override
  String get helpSpotifyErrorAnswer =>
      'Check your connection and complete authorization. Never share passwords or tokens with support: reports include only sanitized diagnostics.';

  @override
  String get helpReportDataQuestion => 'What data does a problem report send?';

  @override
  String get helpReportDataAnswer =>
      'App version, operating system, the last failing endpoint and a few technical logs with sensitive data removed. A screenshot is optional: check that it contains no private information.';

  @override
  String get helpPrivacyQuestion => 'How do I exercise my data rights?';

  @override
  String helpPrivacyAnswer(String email) {
    return 'Go to Profile > Settings > Privacy and personal data to manage consent and export your data. For other requests, contact $email.';
  }

  @override
  String get exploreEyebrow => 'EVENTS AROUND YOU';

  @override
  String get exploreClearSearch => 'Clear search';

  @override
  String exploreEventsVisible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count EVENTS IN VIEW',
      one: '$count EVENT IN VIEW',
    );
    return '$_temp0';
  }

  @override
  String get commonReset => 'Reset';

  @override
  String get exploreLoadErrorTitle => 'Events could not be loaded.';

  @override
  String get exploreLoadErrorBody =>
      'Check your connection and search this area again.';

  @override
  String get exploreEmptyTitle => 'No events found in this area.';

  @override
  String get exploreEmptyBody => 'Widen the radius or change the filters.';

  @override
  String get exploreZoomIn => 'Zoom in';

  @override
  String get exploreZoomOut => 'Zoom out';

  @override
  String exploreOpenEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Open list of $count events',
      one: 'Open list of $count event',
    );
    return '$_temp0';
  }

  @override
  String get exploreMoveMapHint => 'Move the map to search for events';

  @override
  String exploreEventsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events in this area',
      one: '$count event in this area',
    );
    return '$_temp0';
  }

  @override
  String get exploreCloseEvents => 'Close event list';

  @override
  String get exploreGenreElectronic => 'Electronic';

  @override
  String get exploreGenreAlternative => 'Alternative';

  @override
  String get commonLinkOpenError => 'Could not open the link.';

  @override
  String get authConfirmEmail =>
      'We’ve sent you a confirmation email. Check your inbox before signing in.';

  @override
  String get authEmailNotConfirmed =>
      'Confirm your email address first. Check your inbox.';

  @override
  String get authInvalidCredentials =>
      'Email or password is incorrect. Check them and try again.';

  @override
  String get authProviderUnavailable =>
      'This sign-in method is unavailable. Use email or try again later.';

  @override
  String get authEmailAlreadyRegistered =>
      'This email is already registered. Try signing in.';

  @override
  String get authWeakPassword => 'Choose a stronger password and try again.';

  @override
  String get errorNetwork =>
      'Connection unavailable. Check your network and try again.';

  @override
  String get errorSessionChanged =>
      'Your session has changed. Sign in again and retry.';

  @override
  String get errorRateLimited =>
      'Too many requests. Wait a minute and try again.';

  @override
  String get errorActionFailed => 'The action failed. Try again shortly.';

  @override
  String get socialAffinity => 'Affinity';

  @override
  String get socialFollow => 'Follow';

  @override
  String get socialFollowing => 'Following';

  @override
  String get socialFollowUpdateError =>
      'Could not update following. Try again.';

  @override
  String get socialMessageAction => 'Message';

  @override
  String get socialFriendRequestSentShort => 'Sent';

  @override
  String get socialFriendRequestError =>
      'Could not send the request. Try again.';

  @override
  String get socialAddFriend => 'Add friend';

  @override
  String get socialCommonArtists => 'Shared artists';

  @override
  String get socialUsersLoadError => 'Could not load people.';

  @override
  String socialFollowersCount(int count) {
    return 'Followers ($count)';
  }

  @override
  String socialFollowingCount(int count) {
    return 'Following ($count)';
  }

  @override
  String get socialNoFollowers => 'No followers';

  @override
  String get socialNoFollowersBody =>
      'People who follow this profile will appear here.';

  @override
  String get socialNoFollowing => 'Not following anyone';

  @override
  String get socialNoFollowingBody => 'Followed profiles will appear here.';

  @override
  String get friendsRequestUpdateError =>
      'Could not update the request. Try again.';

  @override
  String get friendsRemoveTitle => 'Remove friend';

  @override
  String friendsRemoveBody(String name) {
    return 'Remove $name from your friends?';
  }

  @override
  String friendsRemoved(String name) {
    return '$name removed from friends';
  }

  @override
  String get friendsRemoveError => 'Could not remove this friend. Try again.';

  @override
  String get commonRemove => 'Remove';

  @override
  String get friendsConnectionsTitle => 'Friends and connections';

  @override
  String friendsCount(int count) {
    return 'Friends ($count)';
  }

  @override
  String get friendsReceived => 'Received';

  @override
  String friendsSentCount(int count) {
    return 'Sent ($count)';
  }

  @override
  String get friendsSearchHint => 'Search your friends…';

  @override
  String get friendsNoneFound => 'No friends found';

  @override
  String get friendsFindBody =>
      'Explore profiles, send friend requests and share events.';

  @override
  String get friendsFindPeople => 'Find people';

  @override
  String get friendsNoReceived => 'No requests received';

  @override
  String get friendsNoReceivedBody =>
      'Friend requests from other people will appear here.';

  @override
  String get friendsVibraUser => 'Vibra user';

  @override
  String get friendsNoSent => 'No sent requests';

  @override
  String get friendsNoSentBody =>
      'Sent friend requests awaiting a reply will appear here.';

  @override
  String inboxOpenConversation(String name) {
    return 'Open conversation with $name';
  }

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '$count unread message',
    );
    return '$_temp0';
  }

  @override
  String get inboxEyebrow => 'IN TOUCH';

  @override
  String get inboxMessages => 'Messages';

  @override
  String get inboxDirect => 'Direct';

  @override
  String get inboxRequests => 'Requests';

  @override
  String get inboxSearchHint => 'Search conversations';

  @override
  String get inboxClearSearch => 'Clear conversation search';

  @override
  String get inboxRefreshError => 'Could not refresh conversations.';

  @override
  String get inboxEmptyTitle => 'No conversations yet.';

  @override
  String get inboxEmptyBody =>
      'Find someone to share a concert with and start talking.';

  @override
  String get inboxNoRequests => 'No pending requests.';

  @override
  String get inboxNoRequestsBody => 'New message requests will appear here.';

  @override
  String get socialMatchSend => 'SEND';

  @override
  String get socialMatchPass => 'PASS';

  @override
  String get socialMatchSharedListening =>
      'Your listening has found common ground.';

  @override
  String get socialYou => 'You';

  @override
  String get socialMatchFrequencyNow => 'same frequency, right now';

  @override
  String get socialMatchSharedSound => 'SHARED LISTENING';

  @override
  String get socialMatchSameArea => 'SAME AREA';

  @override
  String get friendsLoadError => 'Could not load friends. Try again.';

  @override
  String get matchTierHigh => 'High match';

  @override
  String get matchTierMedium => 'Good match';

  @override
  String get matchTierLow => 'Low match';

  @override
  String get eventStatusUpcoming => 'Upcoming';

  @override
  String get eventStatusToday => 'Today';

  @override
  String get eventStatusSoldOut => 'Sold out';

  @override
  String get eventStatusCancelled => 'Cancelled';

  @override
  String get eventStatusPostponed => 'Postponed';

  @override
  String get eventStatusPast => 'Ended';

  @override
  String eventPriceFrom(String price) {
    return 'From $price';
  }

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get homeSpotifyBannerTitle => 'Connect your sound';

  @override
  String get homeUpNext => 'UP NEXT';

  @override
  String get homeSpotifyConnectedTitle => 'Spotify connected';

  @override
  String get spotifyConsentSharing =>
      'People with musical affinity turned on see only your affinity score and the artists and genres you have in common, never your listening history.';

  @override
  String get spotifySyncFailedTitle =>
      'Spotify is connected, but your music hasn\'t loaded yet.';

  @override
  String get spotifySyncRetry => 'Retry sync';

  @override
  String get spotifyRevokedBody =>
      'Vibra\'s access was removed from your Spotify account, so we disconnected it and deleted the synced data. Connect again to restore your statistics and matches.';

  @override
  String get spotifyRateLimited =>
      'Spotify is busy right now. Try again in a minute.';

  @override
  String get settingsSpotifyDisconnectError =>
      'Spotify could not be disconnected. Try again.';

  @override
  String get socialConnectSpotifyBody =>
      'Connect Spotify to meet people who listen to what you love.';

  @override
  String socialAffinityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people share your taste',
      one: '1 person shares your taste',
      zero: 'No new affinities yet',
    );
    return '$_temp0';
  }

  @override
  String get spotifyAccessNotGranted =>
      'Spotify hasn\'t enabled Vibra for your account yet. Everything else in Vibra works as usual; try connecting again later.';

  @override
  String get spotifyConnectFailed =>
      'Spotify couldn\'t complete the connection. Try again in a moment.';

  @override
  String get settingsSectionMusic => 'Music';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionHelp => 'Help';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsDeleteAccountSub =>
      'Permanently delete your account and data';

  @override
  String get settingsEditProfileSub => 'Name, photo, bio and username';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get profileStatEvents => 'Events';

  @override
  String get profileSpotifyBenefits => 'Stats · Affinity · For you';

  @override
  String get appearanceAuto => 'Automatic';

  @override
  String get affinityCategoryExceptional => 'Exceptional musical affinity';

  @override
  String get affinityCategoryVeryHigh => 'Very high affinity';

  @override
  String get affinityCategoryHigh => 'High affinity';

  @override
  String get affinityCategoryModerate => 'Moderate affinity';

  @override
  String get affinityCategoryLow => 'Different sounds';

  @override
  String get affinityCategoryVeryLow => 'New musical worlds';

  @override
  String affinityHeadline(int percent) {
    return '$percent% musical affinity';
  }

  @override
  String get affinitySharedGenres => 'Your shared genres';

  @override
  String get affinityTheirGenres => 'Their main genres';

  @override
  String get affinityArtistsInCommon => 'Artists in common';

  @override
  String get affinityWhy => 'Why you match';

  @override
  String get affinityQuoteExceptional => 'You seem to hear music the same way.';

  @override
  String get affinityQuoteVeryHigh =>
      'Your musical tastes have a lot in common.';

  @override
  String get affinityQuoteHigh => 'Your musical tastes have plenty in common.';

  @override
  String get affinityQuoteModerate =>
      'You share some sounds, and can discover others.';

  @override
  String get affinityQuoteDiscovery =>
      'Different worlds: a chance to discover new music.';

  @override
  String affinityReasonSharedFamilies(String genres) {
    return 'You both mostly listen to $genres.';
  }

  @override
  String affinityReasonSharedSubgenres(String genres) {
    return 'You share a love for $genres.';
  }

  @override
  String affinityReasonDifferentSubgenres(String genre) {
    return 'You both love $genre, with different subgenres.';
  }

  @override
  String affinityReasonRelatedFamilies(String first, String second) {
    return '$first and $second are neighbouring sounds.';
  }

  @override
  String affinityReasonSharedArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You share $count favourite artists.',
      one: 'You share 1 favourite artist.',
    );
    return '$_temp0';
  }

  @override
  String get affinityReasonDiscovery =>
      'Different tastes: a good way to discover new music.';

  @override
  String get affinityListSeparator => ' and ';

  @override
  String get genreFamilyHipHop => 'Hip-Hop';

  @override
  String get genreFamilyRnb => 'R&B';

  @override
  String get genreFamilyElectronic => 'Electronic';

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
  String get genreFamilyClassical => 'Classical';

  @override
  String get genreFamilySoundtrack => 'Soundtracks';

  @override
  String get genreFamilyGospel => 'Gospel & Christian';

  @override
  String get genreFamilyWorld => 'World';

  @override
  String get musicGenresTitle => 'Your genres';

  @override
  String get musicGenresSubtitle =>
      'Pick the genres you love. They help us find people with related taste, with or without Spotify.';

  @override
  String get musicGenresSpotifyNote =>
      'Spotify is connected: these genres are added to the ones from your listening.';

  @override
  String get musicGenresSearchHint => 'Search a genre';

  @override
  String get musicGenresNoResults => 'No genre found';

  @override
  String musicGenresSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genres selected',
      one: '1 genre selected',
      zero: 'No genre selected',
    );
    return '$_temp0';
  }

  @override
  String get musicGenresYourPicks => 'Your picks';

  @override
  String get musicGenresLevelLike => 'I like it';

  @override
  String get musicGenresLevelMuch => 'A lot';

  @override
  String get musicGenresLevelLove => 'I love it';

  @override
  String get musicGenresIntensityHint =>
      'Tap a picked genre to change how much you like it.';

  @override
  String musicGenresRemove(String genre) {
    return 'Remove $genre';
  }

  @override
  String get musicGenresLimit => 'You can pick up to 30 genres.';

  @override
  String get musicGenresMatching => 'Show me to people with related taste';

  @override
  String get musicGenresMatchingBody =>
      'They only see your affinity score and the genres and artists you share.';

  @override
  String get musicGenresSave => 'Save';

  @override
  String get musicGenresSaved =>
      'Genres saved. Your affinities are being updated.';

  @override
  String get musicGenresSaveError => 'Couldn’t save your genres. Try again.';

  @override
  String get musicGenresLoadError => 'Couldn’t load your genres.';

  @override
  String get musicGenresEntry => 'Favourite genres';

  @override
  String get musicGenresEntrySub =>
      'Pick the genres you love, even without Spotify';

  @override
  String get socialAffinityPickGenres => 'Or pick your genres';

  @override
  String get socialAffinityPickGenresBody =>
      'Pick the genres you love to meet people with related taste.';

  @override
  String get privacyMusicAffinity => 'Music affinity';

  @override
  String get privacyMusicAffinityBody =>
      'Use your Spotify data and the genres you pick for suggestions and affinity.';

  @override
  String get musicalDnaTitle => 'Musical DNA';

  @override
  String get musicalDnaEyebrow => 'Your musical identity';

  @override
  String musicalDnaUserTitle(String name) {
    return '$name\'s Musical DNA';
  }

  @override
  String get musicalDnaUserEyebrow => 'Musical identity';

  @override
  String get musicalDnaDistribution => 'Genre distribution';

  @override
  String get musicalDnaDistributionSub =>
      'How your taste divides across genre families';

  @override
  String musicalDnaArtistsVia(String artists) {
    return 'Through $artists';
  }

  @override
  String get musicalDnaDiversity => 'Diversity';

  @override
  String get musicalDnaDiversityFocused => 'Focused';

  @override
  String get musicalDnaDiversityBalanced => 'Balanced';

  @override
  String get musicalDnaDiversityEclectic => 'Eclectic';

  @override
  String get musicalDnaDiversityFocusedBody =>
      'Your identity lives in a few close sounds.';

  @override
  String get musicalDnaDiversityBalancedBody =>
      'A clear core, with room for other worlds.';

  @override
  String get musicalDnaDiversityEclecticBody =>
      'Your taste moves freely across very different worlds.';

  @override
  String musicalDnaDiversityCounts(String families, String subgenres) {
    return '$families families · $subgenres subgenres';
  }

  @override
  String get musicalDnaEvolution => 'Evolution';

  @override
  String get musicalDnaEvolutionSub =>
      'How your DNA changes as your listening does';

  @override
  String musicalDnaEvolutionEmpty(String date) {
    return 'Tracking since $date. Changes show up here as your listening evolves.';
  }

  @override
  String musicalDnaShiftSince(String date) {
    return 'Since $date';
  }

  @override
  String get musicalDnaNoShift =>
      'Stable: no family moved by more than 3 points.';

  @override
  String musicalDnaShiftSemantics(String family, String from, String to) {
    return '$family, from $from to $to percent';
  }

  @override
  String get musicalDnaSources => 'Based on';

  @override
  String musicalDnaSourceArtists(String classified, String total) {
    return '$classified of your top $total Spotify artists (last 6 months)';
  }

  @override
  String get musicalDnaSourceSpotifyGenres =>
      'The genres of your top Spotify artists (last 6 months)';

  @override
  String musicalDnaSourceTracks(String count) {
    return 'Your top $count Spotify tracks';
  }

  @override
  String musicalDnaSourceGenres(String count) {
    return '$count genres you picked';
  }

  @override
  String get musicalDnaEditGenres => 'Edit your genres';

  @override
  String get musicalDnaVisibility => 'Who can see it';

  @override
  String get musicalDnaVisibilityPublic => 'Everyone';

  @override
  String get musicalDnaVisibilityMatches => 'Matches';

  @override
  String get musicalDnaVisibilityPrivate => 'Only me';

  @override
  String get musicalDnaVisibilityPublicBody =>
      'Anyone on Vibra can see your Musical DNA on your profile.';

  @override
  String get musicalDnaVisibilityMatchesBody =>
      'Only people you have a musical affinity with or are connected to.';

  @override
  String get musicalDnaVisibilityPrivateBody =>
      'Only you can see it. It still shapes your suggestions.';

  @override
  String get musicalDnaVisibilityError =>
      'Couldn\'t save your choice. Try again.';

  @override
  String get musicalDnaEmptyTitle => 'No Musical DNA yet';

  @override
  String get musicalDnaEmptyBody =>
      'Connect Spotify or pick a few genres you love, and your DNA builds itself from them.';

  @override
  String get musicalDnaPickGenres => 'Pick genres';

  @override
  String get musicalDnaLoadError => 'Your Musical DNA couldn\'t be loaded.';

  @override
  String musicalDnaUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String musicalDnaFamilySemantics(String family, String percent) {
    return '$family, $percent percent';
  }

  @override
  String get musicalDnaProfileTile => 'Musical DNA';

  @override
  String get musicalDnaProfileTileSubtitle =>
      'Your genres, diversity and how they evolve';

  @override
  String get musicalDnaSeeFull => 'See full DNA';

  @override
  String affinityReasonCommonGround(String genres) {
    return 'You both listen to $genres, in different amounts.';
  }

  @override
  String get affinityReasonBothEclectic =>
      'You\'re both eclectic listeners, moving across very different genres.';

  @override
  String get affinityReasonBothFocused =>
      'You both stay close to your core sound.';

  @override
  String get affinityReasonDiversityContrast =>
      'One of you explores widely, the other stays focused: plenty to share.';

  @override
  String affinityHeadlineSentence(int percent) {
    return 'You have $percent% musical affinity.';
  }

  @override
  String get sameFrequencyTitle => 'Same Frequency';

  @override
  String get sameFrequencyHeadline => 'You\'re on the same frequency.';

  @override
  String sameFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You\'ve discovered $count people with a strong musical connection.',
      one: 'You\'ve discovered 1 person with a strong musical connection.',
      zero: 'No strong musical connections yet.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyTabForYou => 'For you';

  @override
  String get sameFrequencyTabSaved => 'Saved';

  @override
  String get sameFrequencyEmptyTitle => 'No one on your frequency yet';

  @override
  String get sameFrequencyEmptyBody =>
      'People appear here as Vibra finds others who share your sound. Pick more genres or sync Spotify to widen your signal.';

  @override
  String get sameFrequencySavedEmptyTitle => 'No saved profiles';

  @override
  String get sameFrequencySavedEmptyBody =>
      'Save people you want to come back to. They stay here until you remove them.';

  @override
  String get sameFrequencySave => 'Save';

  @override
  String get sameFrequencySaved => 'Saved';

  @override
  String get sameFrequencySaveError =>
      'Couldn\'t update your saved profiles. Try again.';

  @override
  String get sameFrequencyWhy => 'Why you\'re on the same frequency';

  @override
  String sameFrequencyReasonDiscoveries(String artists) {
    return 'You both recently discovered $artists.';
  }

  @override
  String sameFrequencyReasonDirection(String genres) {
    return 'You\'re both moving toward $genres.';
  }

  @override
  String sameFrequencyReasonEvent(String event, String date) {
    return 'You\'re both going to $event · $date.';
  }

  @override
  String sameFrequencyReasonEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You saved $count of the same upcoming events.',
      one: 'You saved 1 of the same upcoming events.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyDiscoverArtists => 'Discover shared artists';

  @override
  String sameFrequencySharedArtistsTitle(String name) {
    return 'Artists you and $name share';
  }

  @override
  String get sameFrequencyFindEvents => 'Find events';

  @override
  String get sameFrequencyEventsOptIn => 'Compare saved events';

  @override
  String get sameFrequencyEventsOptInBody =>
      'Find people going to the same concerts. It only works with people who turned this on too; otherwise your saved events stay private.';

  @override
  String get sameFrequencyEntryBody =>
      'People who share a real musical connection with you';

  @override
  String get sameFrequencyLoadError => 'Same Frequency couldn\'t be loaded.';

  @override
  String sameFrequencyPersonSemantics(String name, String percent) {
    return '$name, $percent percent musical affinity';
  }

  @override
  String get musicRadarTitle => 'Music Radar';

  @override
  String get musicRadarHeadline =>
      'People near you who share your musical taste.';

  @override
  String musicRadarCount(int count, int distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compatible people within $distance km.',
      one: '1 compatible person within $distance km.',
      zero: 'No compatible people within $distance km yet.',
    );
    return '$_temp0';
  }

  @override
  String get musicRadarAreaSound => 'The sound of your area';

  @override
  String get musicRadarAreaSoundSub => 'What people nearby listen to most';

  @override
  String get musicRadarAreaTooFew =>
      'Shown once enough people nearby use the radar.';

  @override
  String get musicRadarPeople => 'Compatible profiles';

  @override
  String get musicRadarEvents => 'Upcoming events for your sound';

  @override
  String get musicRadarEventYourArtist => 'One of your artists';

  @override
  String get musicRadarEventSharedArtist =>
      'An artist you share with people nearby';

  @override
  String get musicRadarEventYourGenre => 'Your genres';

  @override
  String get musicRadarEventAreaGenre => 'Popular in your area';

  @override
  String get musicRadarIntroTitle => 'Discover people nearby through music';

  @override
  String get musicRadarIntroBody =>
      'Music Radar shows people around you with a similar taste. It stays off until you turn it on.';

  @override
  String get musicRadarPrivacy1 =>
      'Nobody sees your location or your distance: only that you\'re within their radius.';

  @override
  String get musicRadarPrivacy2 =>
      'Your position is rounded to an area of about 5 km (or 20 km) and moves at most every 6 hours.';

  @override
  String get musicRadarPrivacy3 =>
      'Hide your profile, change the distance or turn the radar off at any time.';

  @override
  String get musicRadarTurnOn => 'Turn on Music Radar';

  @override
  String get musicRadarLocationTitle => 'Location needed';

  @override
  String get musicRadarLocationBody =>
      'Music Radar uses your approximate location. Turn on location in Privacy controls, then come back.';

  @override
  String get musicRadarOpenPrivacy => 'Open privacy controls';

  @override
  String get musicRadarMatchingNote =>
      'Turn on Music affinity in Privacy controls to see compatible people.';

  @override
  String get musicRadarSettings => 'Radar settings';

  @override
  String get musicRadarEnabled => 'Music Radar';

  @override
  String get musicRadarVisible => 'Show me on the radar';

  @override
  String get musicRadarVisibleBody =>
      'When off, you can still look around, but nobody sees you.';

  @override
  String get musicRadarDistance => 'Discovery distance';

  @override
  String musicRadarDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get musicRadarPrecision => 'Location precision';

  @override
  String get musicRadarPrecisionArea => 'Area (~5 km)';

  @override
  String get musicRadarPrecisionRegion => 'Region (~20 km)';

  @override
  String get musicRadarPrecisionBody =>
      'How roughly others are placed relative to you. Your exact location is never shared.';

  @override
  String get musicRadarSaveError => 'Couldn\'t save the setting. Try again.';

  @override
  String get musicRadarLoadError => 'Music Radar couldn\'t be loaded.';

  @override
  String get musicRadarEntryBody => 'People near you who share your taste';

  @override
  String get musicRadarEmptyPeople =>
      'No one compatible nearby right now. Try a larger distance or check back later.';

  @override
  String get communitiesTitle => 'Communities';

  @override
  String get communitiesEntryBody => 'Genres, artists and scenes you love';

  @override
  String get communitiesSearchHint => 'Search communities or artists';

  @override
  String get communitiesForYou => 'For you';

  @override
  String get communitiesForYouSub => 'Based on your musical profile';

  @override
  String get communitiesMine => 'Your communities';

  @override
  String get communitiesExplore => 'Explore';

  @override
  String get communitiesEmptySearch => 'No communities match your search.';

  @override
  String communitiesRecommendation(String name) {
    return 'Based on your musical profile, you might enjoy $name.';
  }

  @override
  String communitiesReasonArtist(String artist) {
    return '$artist is one of your top artists.';
  }

  @override
  String communitiesReasonGenre(String genre, int percent) {
    return '$genre is $percent% of your Musical DNA.';
  }

  @override
  String communitiesStartArtist(String artist) {
    return 'Start the $artist community';
  }

  @override
  String get communitiesStartArtistBody =>
      'One of your top artists has no community yet.';

  @override
  String communitiesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get communitiesOfficial => 'Official';

  @override
  String get communitiesKindGenre => 'Genre';

  @override
  String get communitiesKindArtist => 'Artist';

  @override
  String get communitiesKindInterest => 'Interest';

  @override
  String get communitiesJoin => 'Join';

  @override
  String get communitiesJoined => 'Joined';

  @override
  String get communitiesLeave => 'Leave';

  @override
  String communitiesLeaveConfirm(String name) {
    return 'Leave $name?';
  }

  @override
  String get communitiesCreate => 'Create a community';

  @override
  String get communitiesCreateName => 'Name';

  @override
  String get communitiesCreateDescription => 'Description (optional)';

  @override
  String get communitiesCreateArtist => 'Artist';

  @override
  String get communitiesCreateGenre => 'Genre';

  @override
  String get communitiesCreateAction => 'Create';

  @override
  String get communitiesTabPosts => 'Posts';

  @override
  String get communitiesTabDiscussions => 'Discussions';

  @override
  String get communitiesTabEvents => 'Events';

  @override
  String get communitiesTabMembers => 'Members';

  @override
  String get communitiesNewPost => 'New post';

  @override
  String get communitiesComposerPost => 'Post';

  @override
  String get communitiesComposerDiscussion => 'Discussion';

  @override
  String get communitiesComposerMusic => 'Share music';

  @override
  String get communitiesComposerBodyHint => 'What\'s on your mind?';

  @override
  String get communitiesComposerTitleHint => 'Discussion topic';

  @override
  String get communitiesComposerLinkHint =>
      'Spotify, Apple Music, YouTube, SoundCloud or Bandcamp link';

  @override
  String get communitiesComposerTrackHint => 'Track or album (optional)';

  @override
  String get communitiesComposerArtistHint => 'Artist (optional)';

  @override
  String get communitiesPublish => 'Publish';

  @override
  String get communitiesJoinToPost => 'Join to post, comment and react.';

  @override
  String get communitiesEmptyFeed => 'No posts yet. Start the conversation.';

  @override
  String get communitiesEmptyDiscussions => 'No discussions yet.';

  @override
  String get communitiesEmptyEvents => 'No upcoming events for this community.';

  @override
  String communitiesComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'Comment',
    );
    return '$_temp0';
  }

  @override
  String get communitiesCommentHint => 'Add a comment';

  @override
  String get communitiesEmptyComments => 'No comments yet.';

  @override
  String get communitiesOpenMusic => 'Listen';

  @override
  String get communitiesHeld => 'Hidden while moderators review reports';

  @override
  String get communitiesDelete => 'Delete';

  @override
  String get communitiesRemove => 'Remove (moderator)';

  @override
  String get communitiesRestore => 'Restore';

  @override
  String get communitiesBan => 'Ban from community';

  @override
  String communitiesBanConfirm(String name) {
    return 'Ban $name from this community?';
  }

  @override
  String get communitiesMakeModerator => 'Make moderator';

  @override
  String get communitiesRemoveModerator => 'Remove moderator';

  @override
  String get communitiesRoleOwner => 'Owner';

  @override
  String get communitiesRoleModerator => 'Moderator';

  @override
  String get communitiesModeration => 'Moderation';

  @override
  String get communitiesModerationEmpty => 'Nothing to review.';

  @override
  String communitiesReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get communitiesReported => 'Thanks, moderators will review it.';

  @override
  String get communitiesError => 'Something went wrong. Try again.';

  @override
  String get communitiesErrorRate => 'You\'re going too fast. Wait a moment.';

  @override
  String get communitiesErrorSpam =>
      'This looks like spam: too many links, a suspicious link or a repeat.';

  @override
  String get communitiesErrorBanned => 'You\'re banned from this community.';

  @override
  String get communitiesErrorLink =>
      'Use a Spotify, Apple Music, YouTube, SoundCloud or Bandcamp link.';

  @override
  String get communitiesErrorExists =>
      'A community for this artist already exists.';

  @override
  String get communitiesErrorLimit => 'You\'ve reached today\'s limit.';

  @override
  String get communitiesLoadError => 'Communities couldn\'t be loaded.';

  @override
  String sameFrequencyReasonCommunities(String communities) {
    return 'You\'re both in $communities.';
  }

  @override
  String get musicRadarCommunities => 'Communities for your area\'s sound';

  @override
  String get circlesTitle => 'Circles';

  @override
  String get circlesSubtitle => 'Small groups for the music you love';

  @override
  String get circlesInvitations => 'Invitations';

  @override
  String circlesInvitedBy(String name) {
    return '$name invited you';
  }

  @override
  String get circlesAccept => 'Accept';

  @override
  String get circlesDecline => 'Decline';

  @override
  String get circlesInviteDeclined => 'Invitation declined';

  @override
  String get circlesSuggested => 'VIBRA suggests';

  @override
  String circlesSuggestionGenre(int count, String genre) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A circle of $count people who share $genre.',
    );
    return '$_temp0';
  }

  @override
  String circlesSuggestionArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A circle of $count people who all listen to $artist.',
    );
    return '$_temp0';
  }

  @override
  String get circlesSuggestionConsent =>
      'Each person gets an invitation and decides whether to join.';

  @override
  String get circlesCreateAndInvite => 'Create and invite';

  @override
  String circlesSuggestionName(String topic) {
    return '$topic Circle';
  }

  @override
  String circlesInvitesSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Circle created. $count invitations sent.',
      one: 'Circle created. 1 invitation sent.',
      zero: 'Circle created. No invitations could be sent.',
    );
    return '$_temp0';
  }

  @override
  String get circlesMine => 'Your circles';

  @override
  String get circlesEmptyTitle => 'No circles yet';

  @override
  String get circlesEmptyBody =>
      'Create a small group around a genre, an artist or a concert, and invite people you know.';

  @override
  String get circlesCreate => 'New circle';

  @override
  String get circlesBasisGenre => 'Genre';

  @override
  String get circlesBasisArtist => 'Artist';

  @override
  String get circlesBasisConcert => 'Concert';

  @override
  String get circlesBasisInterest => 'Interest';

  @override
  String get circlesBasisActivity => 'Activity';

  @override
  String get circlesName => 'Name';

  @override
  String get circlesDescription => 'Description (optional)';

  @override
  String get circlesTopic => 'Topic';

  @override
  String get circlesNoSavedEvents =>
      'Save an event first to start a circle around it.';

  @override
  String get circlesCreateAction => 'Create';

  @override
  String circlesMembers(int count, int max) {
    return '$count/$max members';
  }

  @override
  String get circlesTabChat => 'Chat';

  @override
  String get circlesTabPlaylist => 'Playlist';

  @override
  String get circlesTabEvents => 'Events';

  @override
  String get circlesTabMembers => 'Members';

  @override
  String get circlesMessageHint => 'Message the circle';

  @override
  String get circlesChatEmpty => 'Say hi to your circle.';

  @override
  String get circlesPlaylistEmpty => 'No tracks yet. Add the first one.';

  @override
  String get circlesAddTrack => 'Add a track';

  @override
  String get circlesEventsEmpty => 'No shared events yet.';

  @override
  String get circlesShareEvent => 'Share an event';

  @override
  String get circlesInvite => 'Invite people';

  @override
  String get circlesInviteHint =>
      'You can invite your connections and people you have a musical match with. They decide whether to join.';

  @override
  String get circlesInviteNone => 'No one else to invite right now.';

  @override
  String get circlesInviteSend => 'Send invitations';

  @override
  String get circlesPending => 'Invited';

  @override
  String get circlesRevoke => 'Cancel invitation';

  @override
  String get circlesAdmin => 'Admin';

  @override
  String get circlesMakeAdmin => 'Make admin';

  @override
  String get circlesRemoveMember => 'Remove from circle';

  @override
  String get circlesMute => 'Mute notifications';

  @override
  String get circlesUnmute => 'Unmute notifications';

  @override
  String get circlesEdit => 'Edit circle';

  @override
  String get circlesLeave => 'Leave circle';

  @override
  String circlesLeaveConfirm(String name) {
    return 'Leave $name?';
  }

  @override
  String get circlesSave => 'Save';

  @override
  String get circlesError => 'Something went wrong. Try again.';

  @override
  String get circlesErrorFull => 'This circle is full.';

  @override
  String get circlesErrorNotAllowed =>
      'You can only invite your connections or people you have a musical match with.';

  @override
  String get circlesErrorDeclined =>
      'This person declined recently. Try again later.';

  @override
  String get circlesLoadError => 'Circles couldn\'t be loaded.';

  @override
  String get circlesRemove => 'Remove';

  @override
  String get concertTitle => 'Concert Finder';

  @override
  String get concertHeadline => 'You might enjoy these upcoming events.';

  @override
  String get concertWhy => 'Why it\'s recommended';

  @override
  String concertReasonTopArtist(String artist, int rank) {
    return '$artist is #$rank in your top artists.';
  }

  @override
  String concertReasonTrackArtist(String artist) {
    return '$artist is on your most-played tracks.';
  }

  @override
  String concertReasonSavedArtist(String artist) {
    return 'You saved another $artist event.';
  }

  @override
  String concertReasonGenre(String genre, int percent) {
    return '$genre is $percent% of your Musical DNA.';
  }

  @override
  String concertReasonSimilarToSaved(String genre) {
    return 'Like other $genre events you saved.';
  }

  @override
  String concertReasonDistance(int km) {
    return '$km km from you.';
  }

  @override
  String concertReasonSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $days days.',
      one: 'Tomorrow.',
      zero: 'Today.',
    );
    return '$_temp0';
  }

  @override
  String get concertFilterGenre => 'Genre';

  @override
  String get concertFilterAll => 'All';

  @override
  String get concertArtistHint => 'Search an artist';

  @override
  String get concertFilterDate => 'When';

  @override
  String get concertDateAny => 'Any time';

  @override
  String get concertDateWeek => 'Next 7 days';

  @override
  String get concertDateMonth => 'Next 30 days';

  @override
  String get concertDate3Months => 'Next 3 months';

  @override
  String get concertFilterDistance => 'Distance';

  @override
  String get concertDistanceAny => 'Any distance';

  @override
  String concertDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get concertFilterPrice => 'Price';

  @override
  String get concertPriceAny => 'Any price';

  @override
  String concertPriceUpTo(String price) {
    return 'Up to $price';
  }

  @override
  String get concertPriceNote => 'Only events with a published price in euros.';

  @override
  String get concertEmpty => 'No recommended events match these filters.';

  @override
  String get concertEmptyBody =>
      'Try a wider distance, another date or fewer filters.';

  @override
  String get concertNoProfileTitle => 'Tell us what you listen to';

  @override
  String get concertNoProfileBody =>
      'Connect Spotify or pick a few genres to get concert recommendations.';

  @override
  String get concertLocationNote =>
      'Turn on location to see distances and nearby events.';

  @override
  String get concertLoadError => 'Recommendations couldn\'t be loaded.';

  @override
  String get concertSaved => 'Saved';

  @override
  String get eventDetailInterested => 'Interested';

  @override
  String get eventDetailAttendanceInterested => 'Saved as interested';

  @override
  String get eventDetailAttendanceRemoved => 'Removed from your events';

  @override
  String get whosGoingTitle => 'Who\'s going?';

  @override
  String get whosGoingSubtitle =>
      'People who chose to share their plans with you';

  @override
  String whosGoingGoing(int count) {
    return '$count going';
  }

  @override
  String whosGoingMaybe(int count) {
    return '$count maybe';
  }

  @override
  String whosGoingInterested(int count) {
    return '$count interested';
  }

  @override
  String get whosGoingFriends => 'Friends';

  @override
  String get whosGoingCompatible => 'Compatible people';

  @override
  String get whosGoingOthers => 'Others';

  @override
  String get whosGoingEmpty =>
      'No one you can see has shared plans for this event yet.';

  @override
  String get whosGoingPrivacyNote =>
      'You only see people who chose to share their plans with you. Yours follow your choice below.';

  @override
  String get whosGoingCommunities => 'Communities for this event';

  @override
  String whosGoingAffinity(int percent) {
    return '$percent% affinity';
  }

  @override
  String get whosGoingRequested => 'Requested';

  @override
  String get attendanceVisibility => 'Who can see your plans';

  @override
  String get visibilityPrivate => 'Only me';

  @override
  String get visibilityFriends => 'Friends';

  @override
  String get visibilityMatches => 'Friends & matches';

  @override
  String get visibilityPublic => 'Everyone';

  @override
  String get attendanceVisibilityDefault => 'Use for all my events';

  @override
  String get attendanceVisibilityHint =>
      'Others see your plans only if you allow it. You still see people who share theirs.';

  @override
  String get attendanceVisibilitySaved => 'Visibility updated';

  @override
  String get concertMatchTitle => 'Concert Match';

  @override
  String concertMatchHeadlineMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You and $count other people are interested in this concert.',
      one: 'You and 1 other person are interested in this concert.',
      zero:
          'You\'re the first one here you can see. People who love this artist are below.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchHeadlineOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people you can see are interested in this concert.',
      one: '1 person you can see is interested in this concert.',
      zero: 'No one you can see has shared plans for this concert yet.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchFan(String artist) {
    return 'Also loves $artist';
  }

  @override
  String concertMatchCreateGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create event group ($count)',
      zero: 'Create event group',
    );
    return '$_temp0';
  }

  @override
  String get concertMatchGroupNote =>
      'People join only if they accept your invitation. Nobody\'s location or travel plans are shared.';

  @override
  String get concertMatchShare => 'Share to a circle';

  @override
  String get concertMatchShared => 'Event shared with the circle';

  @override
  String concertMatchSharedMessage(String event, String date) {
    return 'Shared an event: $event · $date';
  }

  @override
  String get concertMatchNoCircles => 'You have no circles yet.';

  @override
  String get concertMatchEmpty => 'No matches for this concert yet.';

  @override
  String get concertMatchSelectHint =>
      'Select people to invite to an event group';

  @override
  String get circlePlans => 'Plans';

  @override
  String get circlePlansEmpty =>
      'No plans yet. Suggest one: dinner, pre-show drinks, a meeting point.';

  @override
  String get circleAddPlan => 'Add a plan';

  @override
  String get circlePlanTitle => 'What';

  @override
  String get circlePlanWhen => 'When (optional)';

  @override
  String get circlePlanNote => 'Details (optional)';

  @override
  String get circlePlanIn => 'I\'m in';

  @override
  String get circlePlanJoined => 'You\'re in';

  @override
  String circlePlanPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in',
      one: '1 in',
    );
    return '$_temp0';
  }

  @override
  String get circlePlanPrivacy => 'Only circle members see plans.';

  @override
  String get groupConcert => 'The concert';

  @override
  String get groupYourStatus => 'Your status';

  @override
  String get groupStatusHint => 'Only members of this group see it.';

  @override
  String get groupHeld => 'Hidden while admins review reports';

  @override
  String get groupRemoveAdmin => 'Remove (admin)';

  @override
  String get groupBan => 'Ban from group';

  @override
  String groupBanConfirm(String name) {
    return 'Ban $name from this group? They won\'t be able to rejoin.';
  }

  @override
  String get groupErrorBanned => 'This person can\'t be invited to this group.';

  @override
  String get groupYourGroups => 'Your groups for this event';

  @override
  String get groupStart => 'Start a concert group';

  @override
  String get groupReportMember => 'Report member';

  @override
  String get vibeTitle => 'Daily Vibe';

  @override
  String get vibeQuestion => 'What\'s your vibe today?';

  @override
  String get vibeShare => 'Share your vibe';

  @override
  String get vibeChange => 'Change today\'s vibe';

  @override
  String get vibeSearchHint => 'Search a song on Spotify';

  @override
  String get vibeTabSpotify => 'Spotify';

  @override
  String get vibeTabLink => 'Other link';

  @override
  String get vibeLinkHint =>
      'Apple Music, YouTube, SoundCloud or Bandcamp link';

  @override
  String get vibeTitleHint => 'Song title';

  @override
  String get vibeArtistHint => 'Artist';

  @override
  String get vibeCaptionHint => 'Add a caption (optional)';

  @override
  String get vibeExpires => 'Disappears after 24 hours';

  @override
  String get vibeEveryone => 'Visible to everyone';

  @override
  String get vibeVisibilityBody =>
      'Off: only your connections and musical matches see it.';

  @override
  String get vibePost => 'Post vibe';

  @override
  String get vibePosted => 'Your vibe is live';

  @override
  String get vibeEmptyTitle => 'No vibes yet today';

  @override
  String get vibeEmptyBody =>
      'Share yours, and connect with or follow people to see theirs.';

  @override
  String get vibeListen => 'Listen on Spotify';

  @override
  String get vibeOpen => 'Open link';

  @override
  String get vibeSave => 'Add to discoveries';

  @override
  String get vibeSaved => 'In your discoveries';

  @override
  String vibeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'Comment',
    );
    return '$_temp0';
  }

  @override
  String get vibeCommentHint => 'Add a comment';

  @override
  String get vibeReply => 'Reply';

  @override
  String vibeReplyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String vibeExpiresIn(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '${hours}h left',
      one: '1h left',
      zero: 'Less than 1h left',
    );
    return '$_temp0';
  }

  @override
  String get vibeDelete => 'Delete my vibe';

  @override
  String get vibeSearchEmpty => 'No songs found.';

  @override
  String get vibeProviderUnavailable =>
      'Spotify search isn\'t available right now. You can paste a link instead.';

  @override
  String get vibeError => 'Couldn\'t post your vibe. Try again.';

  @override
  String get vibeAttribution => 'Song info and artwork from Spotify';

  @override
  String get discoveriesTitle => 'Discoveries';

  @override
  String get discoveriesEmpty =>
      'Songs you add from Daily Vibes, stories, posts and communities appear here. Only you can see them.';

  @override
  String get discoveriesSubtitle => 'Songs you found on VIBRA';

  @override
  String get vibeLoadError => 'Daily Vibe couldn\'t be loaded.';

  @override
  String get vibeHomeCta => 'Share the song that\'s your vibe today';

  @override
  String get storyAdd => 'Add story';

  @override
  String get storyYours => 'Your story';

  @override
  String get storyNew => 'New music story';

  @override
  String get storyKindNowPlaying => 'Now listening';

  @override
  String get storyKindArtist => 'Favorite artist';

  @override
  String get storyKindAlbum => 'Album pick';

  @override
  String get storyKindPlaylist => 'Playlist';

  @override
  String get storyKindConcertPhoto => 'Concert photo';

  @override
  String get storyKindOpinion => 'Music opinion';

  @override
  String get storyAttribution => 'Music info and artwork from Spotify';

  @override
  String get storyPreview => 'Story preview';

  @override
  String get storySearchArtist => 'Search an artist on Spotify';

  @override
  String get storySearchAlbum => 'Search an album on Spotify';

  @override
  String get storySearchPlaylist => 'Search a public playlist on Spotify';

  @override
  String get storySearchEmpty => 'Nothing found.';

  @override
  String get storyArtistNameHint => 'Artist name';

  @override
  String get storyAlbumTitleHint => 'Album title';

  @override
  String get storyPlaylistTitleHint => 'Playlist name';

  @override
  String get storyPlaylistOwnerHint => 'Made by (optional)';

  @override
  String get storyPickPhoto => 'Choose a concert photo';

  @override
  String get storyChangePhoto => 'Change photo';

  @override
  String get storyPhotoPrivacy =>
      'Location and camera data are removed from the photo before it\'s shared.';

  @override
  String get storyTagConcert => 'Concert (optional)';

  @override
  String get storyNoConcert => 'No concert';

  @override
  String get storyOpinionHint => 'Your hot take: an album, a scene, a song…';

  @override
  String get storyBackground => 'Background';

  @override
  String get storyAudience => 'Who can see it';

  @override
  String get storyDefaultAudience => 'Who sees your stories by default';

  @override
  String get storyAudienceConnections => 'Connections';

  @override
  String get storyAudienceEveryone => 'Everyone';

  @override
  String get storyAudienceConnectionsBody =>
      'Your connections and musical matches.';

  @override
  String get storyAudienceEveryoneBody =>
      'Also people who follow you. Blocked people and anyone you hide stories from never see it.';

  @override
  String get storyAllowReplies => 'Allow replies';

  @override
  String get storyAllowRepliesBody =>
      'Replies are private: only you and the person replying see them.';

  @override
  String get storyExpires => 'Disappears after 24 hours.';

  @override
  String get storyShare => 'Share story';

  @override
  String get storyPosted => 'Your story is live for 24 hours';

  @override
  String get storyError => 'Something went wrong. Try again.';

  @override
  String get storyRateLimited =>
      'You\'re sharing a lot. Wait a moment and try again.';

  @override
  String get storySpam => 'This looks like spam. Remove links and try again.';

  @override
  String get storyPhotoError =>
      'This photo can\'t be used. Choose a JPG or PNG up to 10 MB.';

  @override
  String get storySettingsTitle => 'Story privacy';

  @override
  String get storyHideFrom => 'Hide your stories from';

  @override
  String get storyHideFromBody =>
      'They won\'t see your stories and won\'t be told.';

  @override
  String get storyHidden => 'Hidden from your stories';

  @override
  String get storyNoConnections =>
      'When you have connections, you can choose here who doesn\'t see your stories.';

  @override
  String get storyJustNow => 'now';

  @override
  String storyMinutesAgo(int minutes) {
    return '${minutes}m';
  }

  @override
  String storyHoursAgo(int hours) {
    return '${hours}h';
  }

  @override
  String get storyPrevious => 'Previous story';

  @override
  String get storyNext => 'Next story';

  @override
  String get storyMore => 'More options';

  @override
  String get storyLoadError => 'These stories couldn\'t be loaded.';

  @override
  String get storyGone =>
      'These stories have expired or are no longer available.';

  @override
  String get storyHeld =>
      'Hidden while it\'s reviewed after reports. Only you can see it.';

  @override
  String storyReplyHint(String name) {
    return 'Reply to $name…';
  }

  @override
  String get storySendReply => 'Send';

  @override
  String get storyReplySent => 'Reply sent privately';

  @override
  String get storyRepliesOff => 'Replies are off for this story';

  @override
  String get storyRepliesOffMine => 'Replies are off for this story.';

  @override
  String storyViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '1 view',
      zero: 'No views',
    );
    return '$_temp0';
  }

  @override
  String storyReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
      zero: 'Replies',
    );
    return '$_temp0';
  }

  @override
  String storyReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: '1 reaction',
    );
    return '$_temp0';
  }

  @override
  String get storyInsightsPrivate => 'Only you can see who viewed and replied.';

  @override
  String get storyNoViewers => 'No views yet.';

  @override
  String get storyNoReplies => 'No replies yet.';

  @override
  String storyAnswerHint(String name) {
    return 'Answer $name privately…';
  }

  @override
  String get storyMakeEveryone => 'Show to everyone';

  @override
  String get storyMakeConnectionsOnly => 'Show to connections only';

  @override
  String get storyNowEveryone => 'Everyone can now see this story';

  @override
  String get storyNowConnections =>
      'Only your connections can now see this story';

  @override
  String get storyTurnRepliesOff => 'Turn off replies';

  @override
  String get storyTurnRepliesOn => 'Turn on replies';

  @override
  String get storyDelete => 'Delete story';

  @override
  String get storyDeleted => 'Story deleted';

  @override
  String storyMute(String name) {
    return 'Mute $name\'s stories';
  }

  @override
  String storyMuted(String name) {
    return 'You won\'t see $name\'s stories. They won\'t be told.';
  }

  @override
  String get feedTitle => 'VIBRA Feed';

  @override
  String get feedHomeCta =>
      'Recommendations, reviews and discoveries from your music world';

  @override
  String get feedForYou => 'For you';

  @override
  String get feedFollowing => 'Following';

  @override
  String get feedLatest => 'Latest';

  @override
  String get feedForYouBody =>
      'Ranked by people you follow, your connections, communities and the music you love. Each post says why it\'s here.';

  @override
  String get feedFollowingBody =>
      'Newest first, from people you follow and your connections.';

  @override
  String get feedLatestBody => 'Newest first, every post you can see.';

  @override
  String get feedCompose => 'Post';

  @override
  String get feedNewPost => 'New post';

  @override
  String get feedPublish => 'Publish';

  @override
  String get feedPosted => 'Your post is live';

  @override
  String get feedKindSong => 'Song';

  @override
  String get feedKindAlbum => 'Album';

  @override
  String get feedKindPlaylist => 'Playlist';

  @override
  String get feedKindRecommendation => 'Recommendation';

  @override
  String get feedKindDiscovery => 'Discovery';

  @override
  String get feedKindReview => 'Review';

  @override
  String get feedKindOpinion => 'Opinion';

  @override
  String get feedKindConcertPhoto => 'Concert photo';

  @override
  String get feedKindShare => 'Shared';

  @override
  String get feedItemTrack => 'Song';

  @override
  String get feedItemAlbum => 'Album';

  @override
  String get feedItemArtist => 'Artist';

  @override
  String get feedItemPlaylist => 'Playlist';

  @override
  String get feedWhatAbout => 'What is it about?';

  @override
  String get feedYourRating => 'Your rating';

  @override
  String feedRatingLabel(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get feedReviewHint => 'What did you think? Be specific.';

  @override
  String get feedDiscoveryHint => 'How did you find it?';

  @override
  String get feedRecommendationHint => 'Why should people listen to it?';

  @override
  String get feedBodyHint => 'Say something about it (optional)';

  @override
  String get feedAudienceEveryoneBody =>
      'Anyone on VIBRA can see it, except people you blocked.';

  @override
  String get feedAllowComments => 'Allow comments';

  @override
  String get feedDuplicatePost => 'You already posted this today.';

  @override
  String get feedError => 'Something went wrong. Try again.';

  @override
  String get feedLoadError => 'The feed couldn\'t be loaded.';

  @override
  String get feedEmptyTitle => 'Nothing here yet';

  @override
  String get feedEmptyBody =>
      'Share a recommendation, or join communities and follow people to fill your feed.';

  @override
  String get feedEmptyFollowing =>
      'Posts from people you follow and your connections appear here.';

  @override
  String get feedEnd => 'You\'re all caught up';

  @override
  String get feedReasonFollowing => 'You follow them';

  @override
  String get feedReasonConnection => 'Your connection';

  @override
  String get feedReasonArtists => 'An artist you listen to';

  @override
  String get feedReasonGenres => 'Genres you love';

  @override
  String get feedReasonCommunity => 'From your communities';

  @override
  String get feedReasonMatch => 'Musical affinity';

  @override
  String get feedReasonInteraction => 'You often engage with them';

  @override
  String get feedReasonNew => 'New on VIBRA';

  @override
  String feedDaysAgo(int days) {
    return '${days}d';
  }

  @override
  String get feedHeld =>
      'Hidden while it\'s reviewed after reports. Only you can see it.';

  @override
  String get feedLike => 'Like';

  @override
  String get feedUnlike => 'Remove like';

  @override
  String get feedReact => 'React';

  @override
  String get feedComments => 'Comments';

  @override
  String get feedShare => 'Share';

  @override
  String get feedSave => 'Save';

  @override
  String get feedUnsave => 'Remove from saved';

  @override
  String get feedSaved => 'Saved';

  @override
  String get feedUnsaved => 'Removed from saved';

  @override
  String get feedShareToFeed => 'Share to your feed';

  @override
  String get feedShareCommentHint => 'Add a comment (optional)';

  @override
  String get feedShareOnlyPublic =>
      'Only public posts by other people can be shared to your feed.';

  @override
  String get feedShared => 'Shared to your feed';

  @override
  String get feedAlreadyShared => 'You already shared this post.';

  @override
  String get feedCopyLink => 'Copy music link';

  @override
  String get feedLinkCopied => 'Link copied';

  @override
  String get feedTurnCommentsOff => 'Turn off comments';

  @override
  String get feedTurnCommentsOn => 'Turn on comments';

  @override
  String get feedDelete => 'Delete post';

  @override
  String get feedDeleted => 'Post deleted';

  @override
  String get feedNotInterested => 'Not interested';

  @override
  String get feedNotInterestedDone => 'You\'ll see fewer posts like this';

  @override
  String get feedPostTitle => 'Post';

  @override
  String get feedPostGone => 'Post not available';

  @override
  String get feedPostGoneBody => 'It was deleted or you can no longer see it.';

  @override
  String get feedCommentHint => 'Add a comment';

  @override
  String get feedCommentsOff => 'Comments are off for this post.';

  @override
  String get feedDuplicateComment => 'You already wrote this comment.';

  @override
  String get feedNoComments => 'No comments yet. Start the conversation.';

  @override
  String get feedDeleteComment => 'Delete comment';

  @override
  String get feedSavedTitle => 'Saved posts';

  @override
  String get feedSavedSubtitle => 'Posts you bookmarked in the feed';

  @override
  String get feedSavedEmpty => 'No saved posts';

  @override
  String get feedSavedEmptyBody =>
      'Tap the bookmark on a post to keep it here. Only you can see your saved posts.';

  @override
  String get feedPostsTitle => 'Posts';

  @override
  String feedPostsOf(String name) {
    return '$name\'s posts';
  }

  @override
  String get feedSeeAllPosts => 'See all';

  @override
  String get feedNoPosts => 'No posts yet';

  @override
  String get feedNoPostsBody => 'Posts you can see will appear here.';

  @override
  String get feedYourPosts => 'Your posts';

  @override
  String get feedYourPostsSubtitle => 'Everything you published in the feed';

  @override
  String get reactionFire => 'Fire';

  @override
  String get reactionObsessed => 'Obsessed';

  @override
  String get reactionUnderrated => 'Underrated';

  @override
  String get reactionClassic => 'Classic';

  @override
  String get reactionNewDiscovery => 'New discovery';

  @override
  String get reactionOnRepeat => 'On repeat';

  @override
  String get reactionHeart => 'Love';

  @override
  String get reactionHeadphones => 'Listening';

  @override
  String get reactionClap => 'Applause';

  @override
  String get reactionMindBlown => 'Mind-blowing';

  @override
  String get reactionTrackTitle => 'React to this song';

  @override
  String get discoveryAdded => 'Added to your Discoveries';

  @override
  String get discoveryAddFailed => 'Couldn\'t add the song. Try again.';

  @override
  String get discoveryOffer => 'A new discovery? Keep it in your Discoveries.';

  @override
  String discoveryFoundVia(String name) {
    return 'via $name';
  }

  @override
  String get aiTitle => 'VIBRA AI';

  @override
  String get aiHomeCta =>
      'Ask for artists, albums, concerts and genres to discover';

  @override
  String get aiPrivacyTile =>
      'Optional music assistant. Off unless you turn it on.';

  @override
  String get aiUnavailableTitle => 'VIBRA AI isn\'t available';

  @override
  String get aiUnavailableBody =>
      'The assistant isn\'t available right now. Everything else in VIBRA works as usual.';

  @override
  String get aiConsentTitle => 'Meet your music assistant';

  @override
  String get aiConsentIntro =>
      'Ask for similar artists, albums for your taste, concerts that match your interests, communities and new genres. It\'s optional and off until you turn it on.';

  @override
  String get aiConsentUses => 'To answer, it uses';

  @override
  String get aiConsentUsesProfile =>
      'Your Musical DNA, top artists and the genres you picked';

  @override
  String get aiConsentUsesChat =>
      'Your question and the last few messages of this chat';

  @override
  String get aiConsentUsesCatalogue =>
      'Spotify\'s public catalogue and VIBRA\'s concerts and communities';

  @override
  String get aiConsentNever => 'It never uses';

  @override
  String get aiConsentNeverBody =>
      'Your messages, location, contacts, other people\'s profiles or your Spotify login. Chats aren\'t saved by VIBRA.';

  @override
  String get aiConsentProvider =>
      'Answers are generated by an external AI provider (Anthropic), which receives the information above for each question. You can turn VIBRA AI off at any time.';

  @override
  String get aiConsentAccept => 'Turn on VIBRA AI';

  @override
  String get aiConsentDecline => 'Not now';

  @override
  String get aiTurnOff => 'Turn off VIBRA AI';

  @override
  String get aiTurnedOff => 'VIBRA AI is off';

  @override
  String get aiNewChat => 'New conversation';

  @override
  String get aiIntro => 'What do you want to discover?';

  @override
  String get aiExampleSimilar => 'Recommend artists similar to Travis Scott';

  @override
  String get aiExampleUnderground => 'Find underground Hip-Hop artists';

  @override
  String get aiExampleAlbums => 'Recommend albums based on my musical profile';

  @override
  String get aiExampleExplain => 'Explain why two artists have similar sounds';

  @override
  String get aiExampleConcerts => 'Find concerts matching my interests';

  @override
  String get aiExampleCommunities => 'Suggest communities I might enjoy';

  @override
  String get aiExampleGenres => 'Help me discover new genres';

  @override
  String get aiInputHint => 'Ask VIBRA AI about music';

  @override
  String get aiThinking => 'Looking into it…';

  @override
  String get aiGeneratedLabel => 'AI-generated · may contain mistakes';

  @override
  String get aiVerifiedTitle => 'Verified results';

  @override
  String get aiIdeasTitle => 'Ideas to explore';

  @override
  String get aiIdeasBody => 'Generated suggestions, not verified.';

  @override
  String get aiSourceSpotify => 'Verified on Spotify';

  @override
  String get aiSourceEvents => 'From VIBRA\'s concert listings';

  @override
  String get aiSourceCommunities => 'VIBRA community';

  @override
  String get aiSourceDna => 'From your Musical DNA';

  @override
  String get aiSourceGenres => 'VIBRA genre catalogue';

  @override
  String aiMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get aiRateLimited =>
      'You\'ve asked a lot. Try again in a little while.';

  @override
  String get aiError => 'Something went wrong. Try again.';

  @override
  String get aiRefused =>
      'VIBRA AI can\'t help with that. Try a music question.';

  @override
  String get aiIncomplete =>
      'The answer couldn\'t be completed. Try asking in a simpler way.';

  @override
  String get discoverTitle => 'Discover my next artist';

  @override
  String get discoverHomeCta =>
      'Similar, emerging and underground artists picked for you';

  @override
  String get discoverIntro =>
      'Based on your favourite artists, your Musical DNA, songs you discovered and your feedback. Your answers shape the next picks.';

  @override
  String get discoverAll => 'All';

  @override
  String get discoverSimilar => 'Similar';

  @override
  String get discoverCollaborations => 'Collaborations';

  @override
  String get discoverEmerging => 'Emerging';

  @override
  String get discoverUnderground => 'Underground';

  @override
  String get discoverExploration => 'New genres';

  @override
  String discoverReasonCollab(String artist) {
    return 'Collaborated with $artist';
  }

  @override
  String discoverReasonExplore(String genre) {
    return 'A step into $genre';
  }

  @override
  String discoverReasonGenres(String genres) {
    return 'Shares your $genres';
  }

  @override
  String get discoverLike => 'Like';

  @override
  String get discoverSave => 'Save for later';

  @override
  String get discoverKnown => 'Already know';

  @override
  String get discoverNotInterested => 'Not interested';

  @override
  String get discoverLiked => 'Got it: more like this';

  @override
  String get discoverUndone => 'Removed';

  @override
  String get discoverSaved => 'Saved for later';

  @override
  String get discoverUnsaved => 'Removed from saved';

  @override
  String get discoverKnownDone => 'Noted. We won\'t suggest this artist again.';

  @override
  String get discoverNotInterestedDone =>
      'You won\'t see this artist again, and fewer like them.';

  @override
  String get discoverRefresh => 'New picks';

  @override
  String get discoverRefreshLimited =>
      'Couldn\'t refresh right now. Try again in a few minutes.';

  @override
  String get discoverError => 'Something went wrong. Try again.';

  @override
  String get discoverEmptyTitle => 'No new artists yet';

  @override
  String get discoverEmptyBody => 'Check back later or tap New picks.';

  @override
  String get discoverNoProfile =>
      'Connect Spotify or pick a few genres so VIBRA knows what you like.';

  @override
  String get discoverPickGenres => 'Pick genres';

  @override
  String get discoverSavedTitle => 'Saved artists';

  @override
  String get discoverSavedSubtitle => 'Artists you saved to listen to later';

  @override
  String get discoverSavedEmpty => 'No saved artists';

  @override
  String get discoverSavedEmptyBody =>
      'Tap Save for later on a recommendation to keep it here.';

  @override
  String get tasteTitle => 'Taste evolution';

  @override
  String get tasteOpen => 'See how your taste evolved';

  @override
  String get tastePeriodMonth => '1 month';

  @override
  String get tastePeriodThreeMonths => '3 months';

  @override
  String get tastePeriodSixMonths => '6 months';

  @override
  String get tastePeriodYear => '1 year';

  @override
  String tasteEvolved(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Your musical taste has evolved over the last month',
      'year': 'Your musical taste has evolved over the last year',
      'three': 'Your musical taste has evolved over the last 3 months',
      'six': 'Your musical taste has evolved over the last 6 months',
      'other': 'Your musical taste has evolved over the last 3 months',
    });
    return '$_temp0';
  }

  @override
  String tasteSteady(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Your musical taste stayed steady over the last month',
      'year': 'Your musical taste stayed steady over the last year',
      'three': 'Your musical taste stayed steady over the last 3 months',
      'six': 'Your musical taste stayed steady over the last 6 months',
      'other': 'Your musical taste stayed steady over the last 3 months',
    });
    return '$_temp0';
  }

  @override
  String tasteComparing(String from, String to) {
    return 'Comparing your Musical DNA on $from with $to.';
  }

  @override
  String tasteShortHistory(String from, String to) {
    return 'Your history starts on $from, so this compares $from with $to.';
  }

  @override
  String tasteChangePoints(int points) {
    return '$points percentage points of your genre mix moved.';
  }

  @override
  String get tasteThenNow => 'Then and now';

  @override
  String get tasteThen => 'Then';

  @override
  String get tasteNow => 'Now';

  @override
  String get tasteTimeline => 'Along the way';

  @override
  String tasteTimelineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count snapshots',
      one: '1 snapshot',
    );
    return '$_temp0 of your Musical DNA from this period.';
  }

  @override
  String get tasteNewGenres => 'New genres discovered';

  @override
  String get tasteNoNewGenres => 'No new genres in this period.';

  @override
  String get tasteEmergingArtists => 'Rising favourites';

  @override
  String get tasteNoEmergingArtists =>
      'Your favourite artists are the same as before.';

  @override
  String get tasteNoArtistData =>
      'Connect Spotify to see how your favourite artists change.';

  @override
  String get tasteArtistNew => 'New';

  @override
  String tasteArtistRose(int from, int to) {
    return '#$from → #$to';
  }

  @override
  String get tastePrevious => 'What you listened to more before';

  @override
  String get tasteNoPrevious => 'Nothing you used to love has faded.';

  @override
  String get tasteFormerTopArtist => 'Was one of your top artists';

  @override
  String get tasteCommunities => 'Communities you joined';

  @override
  String get tasteNoCommunities =>
      'You didn\'t join any communities in this period.';

  @override
  String tasteJoinedOn(String date) {
    return 'Joined on $date';
  }

  @override
  String get tasteNoDnaTitle => 'No Musical DNA yet';

  @override
  String get tasteNoDnaBody =>
      'Your taste evolution starts once VIBRA has your Musical DNA.';

  @override
  String get tasteTooEarlyTitle => 'Not enough history yet';

  @override
  String tasteTooEarlyBody(String date) {
    return 'Your history starts on $date. Come back in a few weeks to see how your taste changes.';
  }

  @override
  String get tasteOffTitle => 'Taste history is off';

  @override
  String get tasteOffBody =>
      'VIBRA keeps only your current Musical DNA. Turn history on below to start following your taste from today.';

  @override
  String get tasteKeepHistory => 'Keep my taste history';

  @override
  String get tasteKeepHistoryBody =>
      'One Musical DNA snapshot a day, kept up to 400 days and visible only to you.';

  @override
  String get tasteTurnOffTitle => 'Turn off taste history?';

  @override
  String get tasteTurnOffBody =>
      'Your past snapshots will be deleted and only your current Musical DNA will be kept. Features that compare your taste over time will stop working until you turn it back on.';

  @override
  String get tasteTurnOffConfirm => 'Turn off and delete';

  @override
  String get tasteError => 'Something went wrong. Try again.';

  @override
  String get profileSectionGenres => 'Favourite genres';

  @override
  String get profileSectionArtists => 'Favourite artists';

  @override
  String get profileSectionStats => 'Musical statistics';

  @override
  String get profileSectionSavedSongs => 'Saved songs';

  @override
  String get profileSectionPlaylists => 'Shared playlists';

  @override
  String get profileSectionEvents => 'Upcoming events';

  @override
  String get profileSectionCommunities => 'Communities';

  @override
  String get profileSectionCircles => 'Circles';

  @override
  String get profileSectionActivity => 'Musical activity';

  @override
  String get profileLevelPublic => 'Everyone';

  @override
  String get profileLevelConnections => 'Connections';

  @override
  String get profileLevelPrivate => 'Only me';

  @override
  String get profileRelationConnection => 'Your connection';

  @override
  String get profileRelationMatch => 'Musical match';

  @override
  String profileMemberSince(String date) {
    return 'On VIBRA since $date';
  }

  @override
  String profileSignatureSemantics(String name, String genres) {
    return '$name, sound signature: $genres';
  }

  @override
  String get profileNoGenres => 'No favourite genres yet.';

  @override
  String get profileNoArtists => 'No favourite artists yet.';

  @override
  String get profileNoPlaylists => 'No playlists shared yet.';

  @override
  String get profileNoEvents => 'No upcoming events to show.';

  @override
  String get profileNoCommunities => 'Not in any communities yet.';

  @override
  String get profileNoCircles => 'You\'re not in any circles yet.';

  @override
  String get profileNoSharedCircles => 'You\'re not in any circles together.';

  @override
  String get profileSharedCirclesNote => 'Circles you\'re both in.';

  @override
  String get profileNoActivity => 'No recent activity.';

  @override
  String profileActivityPosted(String title) {
    return 'Posted: $title';
  }

  @override
  String profileActivityVibe(String title) {
    return 'Daily Vibe: $title';
  }

  @override
  String profileActivityJoined(String name) {
    return 'Joined $name';
  }

  @override
  String get profileEventGoing => 'Going';

  @override
  String get profileEventMaybe => 'Maybe';

  @override
  String get profileEventInterested => 'Interested';

  @override
  String get profileStatGenres => 'Genres';

  @override
  String get profileStatDiversity => 'Diversity';

  @override
  String get profileStatDiscoveries => 'Discoveries';

  @override
  String get profileStatPosts => 'Posts';

  @override
  String get profileStatConcerts => 'Concerts attended';

  @override
  String get profileSomePrivate => 'Some sections of this profile are private.';

  @override
  String get profilePrivacyTitle => 'Profile privacy';

  @override
  String get profilePrivacyTile =>
      'Choose who sees each part of your musical profile';

  @override
  String get profilePrivacyIntro =>
      'Choose who can see each part of your profile. Your photo, name, username and bio are always visible to people you can interact with.';

  @override
  String get profilePrivacyEventsNote =>
      'Each event also keeps the visibility you chose in Who\'s Going.';

  @override
  String get profilePrivacyCirclesNote =>
      'Others only ever see circles they\'re also in.';

  @override
  String get profilePrivacyPostsNote =>
      'Each post also keeps its own audience.';

  @override
  String get profilePrivacyDnaNote =>
      'Musical DNA has its own visibility setting.';

  @override
  String get profilePrivacyError => 'Couldn\'t save. Try again.';

  @override
  String get safetyTitle => 'Safety & privacy';

  @override
  String get safetySettingsSubtitle =>
      'Blocks, reports, visibility and location in one place';

  @override
  String get safetyIntro =>
      'Everything that decides who can reach you and what they see. These rules are enforced by VIBRA\'s servers, everywhere in the app.';

  @override
  String get safetyPeople => 'People';

  @override
  String get safetyBlockedTitle => 'Blocked people';

  @override
  String safetyBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'Nobody blocked',
    );
    return '$_temp0';
  }

  @override
  String get safetyBlockExplain =>
      'Blocking works everywhere: messages, comments, posts, stories, communities, circles, events and the radar. It also removes follows and connections between you. The other person isn\'t told.';

  @override
  String get safetyNoBlocked => 'You haven\'t blocked anyone';

  @override
  String safetyBlockedOn(String date) {
    return 'Blocked on $date';
  }

  @override
  String get safetyUnblock => 'Unblock';

  @override
  String safetyUnblockTitle(String name) {
    return 'Unblock $name?';
  }

  @override
  String get safetyUnblockBody =>
      'They\'ll be able to find you and contact you again. Follows and connections removed by the block don\'t come back.';

  @override
  String safetyUnblocked(String name) {
    return '$name is unblocked';
  }

  @override
  String safetyBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get safetyBlockBody =>
      'You won\'t see each other anywhere on VIBRA, and follows and connections between you are removed. They won\'t be told.';

  @override
  String get safetyReportUser => 'Report this person';

  @override
  String get safetyReported => 'Thanks. Our team will review this report.';

  @override
  String get safetyDuplicateReport => 'You already reported this recently.';

  @override
  String get safetyRateLimited => 'Too many attempts. Try again later.';

  @override
  String get safetyUserUnavailable => 'This person isn\'t available.';

  @override
  String get safetyVisibility => 'What others see';

  @override
  String safetyHiddenFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hidden from $count people',
      one: 'hidden from 1 person',
    );
    return '$_temp0';
  }

  @override
  String get safetyAttendance => 'Event attendance';

  @override
  String get safetyAttendanceBody => 'chosen per event in Who\'s Going';

  @override
  String get safetyLocation => 'Location';

  @override
  String get safetyLocationExplain =>
      'Your exact position is never shown to anyone. The radar uses approximate areas, and only when you turn it on.';

  @override
  String get safetyRadarVisible => 'On, visible';

  @override
  String get safetyRadarHidden => 'On, hidden';

  @override
  String get safetyOn => 'On';

  @override
  String get safetyOff => 'Off';

  @override
  String get safetyData => 'Your data';

  @override
  String get safetyAllPrivacy => 'All privacy controls';

  @override
  String get safetyAllPrivacyBody =>
      'Consents, notifications and your data export';

  @override
  String get safetyReporting => 'Reporting';

  @override
  String get safetyReportingBody =>
      'You can report a person from their profile, and any message, post, comment, story, reply, vibe or community content from its menu. Reports are private. Content reported by several people is hidden while it\'s reviewed, and community moderators can remove content and ban members.';

  @override
  String get safetyContact => 'Contact support';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifCenterSubtitle => 'Everything that happened, in one place';

  @override
  String get notifSettingsTitle => 'Notification preferences';

  @override
  String get notifSettingsSubtitle => 'Categories, quiet hours and daily limit';

  @override
  String get notifToday => 'Today';

  @override
  String get notifThisWeek => 'This week';

  @override
  String get notifEarlier => 'Earlier';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifUnread => 'Unread';

  @override
  String notifUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread notifications',
      one: '1 unread notification',
    );
    return '$_temp0';
  }

  @override
  String notifGrouped(int count) {
    return '$count updates';
  }

  @override
  String get notifEmptyTitle => 'No notifications yet';

  @override
  String get notifEmptyBody =>
      'Requests, messages, concerts and everything else will appear here.';

  @override
  String get notifError => 'Something went wrong. Try again.';

  @override
  String get notifPushAll => 'Push notifications';

  @override
  String get notifPushAllBody =>
      'Off: everything still appears in the notification center, nothing is pushed.';

  @override
  String get notifNoDevice =>
      'Push isn\'t set up on this device yet. You\'ll still see every notification here.';

  @override
  String get notifCategoriesTitle => 'What can push';

  @override
  String get notifCategoriesBody =>
      'Turning a category off stops its pushes. It still shows up in the notification center.';

  @override
  String get notifOncePerDay => 'At most one push a day.';

  @override
  String get notifCatRequests => 'Vibra requests';

  @override
  String get notifCatRequestsBody => 'New requests and requests accepted.';

  @override
  String get notifCatMessages => 'Messages';

  @override
  String get notifCatMessagesBody =>
      'Direct messages, message requests and event live chats.';

  @override
  String get notifCatCommunities => 'Community activity';

  @override
  String get notifCatCommunitiesBody => 'Comments on your community posts.';

  @override
  String get notifCatCircles => 'Circles';

  @override
  String get notifCatCirclesBody => 'Invitations, messages and plans.';

  @override
  String get notifCatConcerts => 'Concert announcements';

  @override
  String get notifCatConcertsBody =>
      'New concerts by artists you listen to, and event updates.';

  @override
  String get notifCatReminders => 'Event reminders';

  @override
  String get notifCatRemindersBody =>
      'A week before, the day before and the day of events you\'re going to.';

  @override
  String get notifCatRecommendations => 'Recommendations';

  @override
  String get notifCatRecommendationsBody =>
      'Music recommended by people you follow, and new musical matches.';

  @override
  String get notifCatSocial => 'Daily Vibe, stories and posts';

  @override
  String get notifCatSocialBody => 'Comments and replies on what you share.';

  @override
  String get notifCatDiscoveries => 'Musical discoveries';

  @override
  String get notifCatDiscoveriesBody => 'When someone saves a song you shared.';

  @override
  String get notifCatUpdates => 'VIBRA updates';

  @override
  String get notifCatUpdatesBody =>
      'Your music week and occasional suggestions.';

  @override
  String get notifQuietTitle => 'Quiet hours';

  @override
  String get notifQuietBody =>
      'No pushes during these hours, except direct messages. Everything waits in the notification center.';

  @override
  String get notifQuietFrom => 'From';

  @override
  String get notifQuietTo => 'To';

  @override
  String notifDailyCap(int count) {
    return 'At most $count pushes a day';
  }

  @override
  String get notifCalmExplain =>
      'To keep notifications useful, VIBRA groups repeated activity into one notification (\"3 new comments\"), doesn\'t push the same group again within 30 minutes, holds pushes during quiet hours, limits low-priority categories to one push a day, and never notifies you about people you\'ve blocked.';

  @override
  String get circlesMuted => 'Notifications muted';

  @override
  String get profileStories => 'Stories';

  @override
  String storyCardSemantics(String name, String kind, int hours) {
    return 'Music story by $name: $kind, $hours h ago';
  }

  @override
  String musicRadarMapSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Affinity map with $count people',
      one: 'Affinity map with 1 person',
      zero: 'Affinity map, nobody yet',
    );
    return '$_temp0';
  }

  @override
  String musicRadarMapPerson(String name, int percent) {
    return '$name, $percent% affinity';
  }

  @override
  String get musicRadarMapNote =>
      'Closer to the centre means more music in common. Positions show affinity, never where anyone is.';

  @override
  String get safetyOverviewError =>
      'Your current settings couldn\'t be loaded. You can still open each section.';

  @override
  String get homeSignatureEyebrow => 'YOUR MUSIC, YOUR PEOPLE';

  @override
  String get homeSignatureTitle => 'Find your people through music';

  @override
  String homeDnaTop(String family) {
    return '$family leads your sound';
  }

  @override
  String get homeDnaEmpty => 'Build it from the genres you love';

  @override
  String homeFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people on your frequency',
      one: '1 person on your frequency',
      zero: 'Discover people who share your taste',
    );
    return '$_temp0';
  }

  @override
  String homeConcertMatchNext(String name) {
    return 'Meet people going to $name';
  }

  @override
  String get homeConcertMatchNone => 'Choose a concert to meet people going';

  @override
  String homeCirclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count circles',
      one: '1 circle',
      zero: 'Start a small music group',
    );
    return '$_temp0';
  }

  @override
  String homeCirclesInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations waiting',
      one: '1 invitation waiting',
    );
    return '$_temp0';
  }
}
