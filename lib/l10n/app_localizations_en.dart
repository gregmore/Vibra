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
      'Connecting Spotify allows Vibra to read your profile and top artists, tracks and genres. We use them for event suggestions and musical affinity; you can disconnect Spotify and delete this data in settings.';

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
}
