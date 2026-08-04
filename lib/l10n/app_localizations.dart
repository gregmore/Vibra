import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Vibra'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Don\'t just listen to music. Live it.'**
  String get appSlogan;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vibra'**
  String get welcomeTitle;

  /// No description provided for @onboardingConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Your Tastes'**
  String get onboardingConnectTitle;

  /// No description provided for @onboardingConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify, analyze your favorite artists, tracks, and genres, and turn your listening habits into smarter recommendations.'**
  String get onboardingConnectBody;

  /// No description provided for @onboardingDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the Right Live Shows'**
  String get onboardingDiscoverTitle;

  /// No description provided for @onboardingDiscoverBody.
  ///
  /// In en, this message translates to:
  /// **'Vibra combines location, events, and musical compatibility to suggest concerts that are truly relevant to you.'**
  String get onboardingDiscoverBody;

  /// No description provided for @onboardingCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Live the Community'**
  String get onboardingCommunityTitle;

  /// No description provided for @onboardingCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'Find people with your same sound, enter Live Mode during concerts, and join the conversation in real-time.'**
  String get onboardingCommunityBody;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get onboardingGoToLogin;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to Vibra'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in with your account or connect using one of the supported providers to unlock real recommendations.'**
  String get loginSubtitle;

  /// No description provided for @loginConsent.
  ///
  /// In en, this message translates to:
  /// **'By authenticating, you accept data consent, JWT session management, and GDPR privacy preferences.'**
  String get loginConsent;

  /// No description provided for @loginWithSpotify.
  ///
  /// In en, this message translates to:
  /// **'Continue with Spotify'**
  String get loginWithSpotify;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginWithApple;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginWithEmail;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authFailed;

  /// No description provided for @authErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get authErrorOccurred;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHeaderNotificationsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Notifications and Privacy'**
  String get settingsHeaderNotificationsPrivacy;

  /// No description provided for @settingsSubtitleNotificationsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Preferences, account, and data management'**
  String get settingsSubtitleNotificationsPrivacy;

  /// No description provided for @settingsOptionCompatibleEvents.
  ///
  /// In en, this message translates to:
  /// **'Compatible event notifications'**
  String get settingsOptionCompatibleEvents;

  /// No description provided for @settingsOptionHighMatchAlerts.
  ///
  /// In en, this message translates to:
  /// **'High compatibility user alerts'**
  String get settingsOptionHighMatchAlerts;

  /// No description provided for @settingsOptionLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat during concerts'**
  String get settingsOptionLiveChat;

  /// No description provided for @settingsOptionDiscoverVisible.
  ///
  /// In en, this message translates to:
  /// **'Profile visible in Discover'**
  String get settingsOptionDiscoverVisible;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Check device permissions and push delivery status'**
  String get settingsNotificationsSub;

  /// No description provided for @settingsNotificationsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Notifications depend on device permissions, Firebase configuration, and an authenticated account.'**
  String get settingsNotificationsSnackbar;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicySub.
  ///
  /// In en, this message translates to:
  /// **'Data usage, consents, and user rights'**
  String get settingsPrivacyPolicySub;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTermsOfServiceSub.
  ///
  /// In en, this message translates to:
  /// **'Rules of use, liabilities, and terms of service'**
  String get settingsTermsOfServiceSub;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsSupportSub.
  ///
  /// In en, this message translates to:
  /// **'Help, contacts, and support options'**
  String get settingsSupportSub;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Vibra'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSub.
  ///
  /// In en, this message translates to:
  /// **'App version, identifiers, and product overview'**
  String get settingsAboutSub;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsLogoutConfirmBody;

  /// No description provided for @settingsLogoutAll.
  ///
  /// In en, this message translates to:
  /// **'Log Out from all devices'**
  String get settingsLogoutAll;

  /// No description provided for @settingsLogoutAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out from all devices'**
  String get settingsLogoutAllConfirmTitle;

  /// No description provided for @settingsLogoutAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from all devices? You will be signed out everywhere.'**
  String get settingsLogoutAllConfirmBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action is irreversible.'**
  String get settingsDeleteAccountConfirmBody;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDelete;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred application language'**
  String get settingsLanguageSub;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {username}, let\'s listen loud tonight.'**
  String homeGreeting(String username);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Artists, venues, cities'**
  String get homeSearchHint;

  /// No description provided for @homeForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get homeForYouTitle;

  /// No description provided for @homeForYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Events with compatibility score over 70'**
  String get homeForYouSubtitle;

  /// No description provided for @homeNearYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get homeNearYouTitle;

  /// No description provided for @homeNearYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Selected with a 50 km GPS radius'**
  String get homeNearYouSubtitle;

  /// No description provided for @homeNearYouAction.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get homeNearYouAction;

  /// No description provided for @homeTrendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get homeTrendingTitle;

  /// No description provided for @homeTrendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most followed events of the week'**
  String get homeTrendingSubtitle;

  /// No description provided for @homeTrendingAction.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeTrendingAction;

  /// No description provided for @settingsSpotifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Spotify Account'**
  String get settingsSpotifyAccount;

  /// No description provided for @settingsSpotifyDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected — Connect for recommendations'**
  String get settingsSpotifyDisconnected;

  /// No description provided for @settingsSpotifyDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get settingsSpotifyDisconnect;

  /// No description provided for @settingsSpotifyDisconnectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Spotify'**
  String get settingsSpotifyDisconnectConfirmTitle;

  /// No description provided for @settingsSpotifyDisconnectConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disconnect your Spotify account? Concert recommendations will no longer be personalized.'**
  String get settingsSpotifyDisconnectConfirmBody;

  /// No description provided for @settingsSpotifyDisconnectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Spotify successfully disconnected'**
  String get settingsSpotifyDisconnectedSuccess;

  /// No description provided for @settingsGenerateCompatibleUsers.
  ///
  /// In en, this message translates to:
  /// **'Generate Compatible Users'**
  String get settingsGenerateCompatibleUsers;

  /// No description provided for @settingsGenerateCompatibleUsersSub.
  ///
  /// In en, this message translates to:
  /// **'Create bots with similar music tastes'**
  String get settingsGenerateCompatibleUsersSub;

  /// No description provided for @settingsGenerateCompatibleUsersLoading.
  ///
  /// In en, this message translates to:
  /// **'Generating... Please wait.'**
  String get settingsGenerateCompatibleUsersLoading;

  /// No description provided for @settingsGenerateCompatibleUsersSuccess.
  ///
  /// In en, this message translates to:
  /// **'Generated successfully!'**
  String get settingsGenerateCompatibleUsersSuccess;

  /// No description provided for @settingsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String settingsError(String error);

  /// No description provided for @settingsLogoutError.
  ///
  /// In en, this message translates to:
  /// **'Error during logout: {error}'**
  String settingsLogoutError(String error);

  /// No description provided for @settingsSpotifyConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected as @{username}'**
  String settingsSpotifyConnected(String username);

  /// No description provided for @settingsDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete account. Ensure the RPC has been loaded in the database.'**
  String get settingsDeleteAccountError;

  /// No description provided for @eventDetailChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get eventDetailChat;

  /// No description provided for @eventDetailTicketsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ticket link unavailable.'**
  String get eventDetailTicketsUnavailable;

  /// No description provided for @eventDetailTicketsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open ticket link.'**
  String get eventDetailTicketsError;

  /// No description provided for @eventDetailBuyTickets.
  ///
  /// In en, this message translates to:
  /// **'Buy Tickets'**
  String get eventDetailBuyTickets;

  /// No description provided for @eventDetailAttendanceConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Attendance confirmed!'**
  String get eventDetailAttendanceConfirmed;

  /// No description provided for @eventDetailAttend.
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get eventDetailAttend;

  /// No description provided for @eventDetailAttendanceMaybe.
  ///
  /// In en, this message translates to:
  /// **'Attendance set to Maybe'**
  String get eventDetailAttendanceMaybe;

  /// No description provided for @eventDetailMaybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get eventDetailMaybe;

  /// No description provided for @eventDetailAttendanceNotGoing.
  ///
  /// In en, this message translates to:
  /// **'You marked you are not going'**
  String get eventDetailAttendanceNotGoing;

  /// No description provided for @eventDetailNotGoing.
  ///
  /// In en, this message translates to:
  /// **'Not going'**
  String get eventDetailNotGoing;

  /// No description provided for @eventDetailCopied.
  ///
  /// In en, this message translates to:
  /// **'Event details copied!'**
  String get eventDetailCopied;

  /// No description provided for @exploreSearchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search events'**
  String get exploreSearchEvents;

  /// No description provided for @exploreSearchInArea.
  ///
  /// In en, this message translates to:
  /// **'Search in this area'**
  String get exploreSearchInArea;

  /// No description provided for @exploreSearchingEvents.
  ///
  /// In en, this message translates to:
  /// **'Searching for events...'**
  String get exploreSearchingEvents;

  /// No description provided for @exploreRadius.
  ///
  /// In en, this message translates to:
  /// **'{radius} km'**
  String exploreRadius(String radius);

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get chatSendFailed;

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialTitle;

  /// No description provided for @socialRequestFrom.
  ///
  /// In en, this message translates to:
  /// **'Request from {userId}'**
  String socialRequestFrom(String userId);

  /// No description provided for @socialOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get socialOpen;

  /// No description provided for @userProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileTitle;

  /// No description provided for @userProfileCompatibility.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% compatibility'**
  String userProfileCompatibility(String percentage);

  /// No description provided for @userProfileTopArtists.
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get userProfileTopArtists;

  /// No description provided for @userProfileFriendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent!'**
  String get userProfileFriendRequestSent;

  /// No description provided for @userProfileSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get userProfileSendRequest;

  /// No description provided for @userProfileOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get userProfileOpenChat;

  /// No description provided for @socialMatchVibraSent.
  ///
  /// In en, this message translates to:
  /// **'Vibra sent to {name}! 🎉'**
  String socialMatchVibraSent(String name);

  /// No description provided for @socialMatchViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View full profile'**
  String get socialMatchViewProfile;

  /// No description provided for @socialMatchIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get socialMatchIgnore;

  /// No description provided for @userProfileNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get userProfileNotAvailableTitle;

  /// No description provided for @userProfileNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No user selected or no match available at the moment.'**
  String get userProfileNotAvailableMessage;

  /// No description provided for @userProfileEvents.
  ///
  /// In en, this message translates to:
  /// **'Past/upcoming concerts'**
  String get userProfileEvents;

  /// No description provided for @socialDiscoverUsers.
  ///
  /// In en, this message translates to:
  /// **'Discover users'**
  String get socialDiscoverUsers;

  /// No description provided for @socialHighCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Users with high musical compatibility'**
  String get socialHighCompatibility;

  /// No description provided for @socialRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Requests ({count})'**
  String socialRequestsCount(int count);

  /// No description provided for @socialPendingFriendships.
  ///
  /// In en, this message translates to:
  /// **'Pending friendships'**
  String get socialPendingFriendships;

  /// No description provided for @socialRequestsToManage.
  ///
  /// In en, this message translates to:
  /// **'Requests to manage'**
  String get socialRequestsToManage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navVibra.
  ///
  /// In en, this message translates to:
  /// **'Vibra'**
  String get navVibra;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @friendsYourFriends.
  ///
  /// In en, this message translates to:
  /// **'Your friends'**
  String get friendsYourFriends;

  /// No description provided for @friendsYourConnections.
  ///
  /// In en, this message translates to:
  /// **'Your Vibra connections'**
  String get friendsYourConnections;

  /// No description provided for @friendsNoFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get friendsNoFriendsYet;

  /// No description provided for @friendsGoToExplore.
  ///
  /// In en, this message translates to:
  /// **'Go to the Explore section or use Social Match to find people with the same taste.'**
  String get friendsGoToExplore;

  /// No description provided for @friendsSentRequests.
  ///
  /// In en, this message translates to:
  /// **'Sent requests'**
  String get friendsSentRequests;

  /// No description provided for @friendsWaitingForReply.
  ///
  /// In en, this message translates to:
  /// **'Waiting for reply'**
  String get friendsWaitingForReply;

  /// No description provided for @friendsPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get friendsPendingApproval;

  /// No description provided for @socialMatchNewAffinity.
  ///
  /// In en, this message translates to:
  /// **'NEW AFFINITY'**
  String get socialMatchNewAffinity;

  /// No description provided for @socialMatchScore.
  ///
  /// In en, this message translates to:
  /// **'MATCH SCORE'**
  String get socialMatchScore;

  /// No description provided for @socialMatchWhyMatched.
  ///
  /// In en, this message translates to:
  /// **'WHY YOU MATCHED'**
  String get socialMatchWhyMatched;

  /// No description provided for @socialMatchCommonEvents.
  ///
  /// In en, this message translates to:
  /// **'Live nearby • {count} common events'**
  String socialMatchCommonEvents(String count);

  /// No description provided for @socialMatchSendVibra.
  ///
  /// In en, this message translates to:
  /// **'Send Vibra'**
  String get socialMatchSendVibra;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or city (e.g. Milan)'**
  String get exploreSearchHint;

  /// No description provided for @exploreInteractiveMap.
  ///
  /// In en, this message translates to:
  /// **'Interactive map'**
  String get exploreInteractiveMap;

  /// No description provided for @exploreLiveAroundYou.
  ///
  /// In en, this message translates to:
  /// **'Explore live events around you in real time'**
  String get exploreLiveAroundYou;

  /// No description provided for @exploreSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get exploreSearchRadius;

  /// No description provided for @exploreFindEventsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Find events near you'**
  String get exploreFindEventsNearYou;

  /// No description provided for @exploreMusicGenre.
  ///
  /// In en, this message translates to:
  /// **'Music genre'**
  String get exploreMusicGenre;

  /// No description provided for @exploreFilterByGenre.
  ///
  /// In en, this message translates to:
  /// **'Filter by your favorite genres'**
  String get exploreFilterByGenre;

  /// No description provided for @exploreGenreAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exploreGenreAll;

  /// No description provided for @friendsReceivedRequests.
  ///
  /// In en, this message translates to:
  /// **'Received requests'**
  String get friendsReceivedRequests;

  /// No description provided for @friendsAcceptOrReject.
  ///
  /// In en, this message translates to:
  /// **'Accept or reject new connections'**
  String get friendsAcceptOrReject;

  /// No description provided for @friendsWantsToConnect.
  ///
  /// In en, this message translates to:
  /// **'Wants to connect with you'**
  String get friendsWantsToConnect;

  /// No description provided for @socialMatchListenBoth.
  ///
  /// In en, this message translates to:
  /// **'You both listen to {artists}'**
  String socialMatchListenBoth(String artists);

  /// No description provided for @socialMatchCityEvents.
  ///
  /// In en, this message translates to:
  /// **'{city} • {count} common events'**
  String socialMatchCityEvents(String city, String count);

  /// No description provided for @myProfileConnectSpotify.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify'**
  String get myProfileConnectSpotify;

  /// No description provided for @myProfileOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get myProfileOverview;

  /// No description provided for @myProfileOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access to profile areas'**
  String get myProfileOverviewSubtitle;

  /// No description provided for @myProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get myProfileSettings;

  /// No description provided for @myProfileMusicStats.
  ///
  /// In en, this message translates to:
  /// **'Music stats'**
  String get myProfileMusicStats;

  /// No description provided for @myProfileMusicStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top artists, genres and listening heatmap'**
  String get myProfileMusicStatsSubtitle;

  /// No description provided for @myProfileMyEvents.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get myProfileMyEvents;

  /// No description provided for @myProfileMyEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} saved, upcoming and past events'**
  String myProfileMyEventsSubtitle(String count);

  /// No description provided for @myProfileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy, notifications, account and logout'**
  String get myProfileSettingsSubtitle;

  /// No description provided for @myEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEventsTitle;

  /// No description provided for @myEventsGoing.
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get myEventsGoing;

  /// No description provided for @myEventsGoingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmed or upcoming events'**
  String get myEventsGoingSubtitle;

  /// No description provided for @myEventsGoingEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t confirmed your attendance to any event yet.\\nExplore and find your next concerts!'**
  String get myEventsGoingEmpty;

  /// No description provided for @myEventsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get myEventsSaved;

  /// No description provided for @myEventsSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep an eye on'**
  String get myEventsSavedSubtitle;

  /// No description provided for @myEventsSavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved events.\\nSave the events you are interested in so you don\'t miss them.'**
  String get myEventsSavedEmpty;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get chatEmptyMessage;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get chatInputHint;

  /// No description provided for @socialMatchScanningTitle.
  ///
  /// In en, this message translates to:
  /// **'VIBE ANALYSIS'**
  String get socialMatchScanningTitle;

  /// No description provided for @socialMatchScanningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Searching for people with similar music taste nearby...'**
  String get socialMatchScanningSubtitle;

  /// No description provided for @socialMatchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches nearby'**
  String get socialMatchEmptyTitle;

  /// No description provided for @socialMatchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your music vibes are unique! There are no people with similar tastes nearby right now...'**
  String get socialMatchEmptyMessage;

  /// No description provided for @socialMatchEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Discover nearby events'**
  String get socialMatchEmptyAction;

  /// No description provided for @socialMatchEmptySecondary.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get socialMatchEmptySecondary;

  /// No description provided for @musicStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Music Stats'**
  String get musicStatsTitle;

  /// No description provided for @musicStatsSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error: {error}'**
  String musicStatsSyncError(String error);

  /// No description provided for @musicStatsTopArtists.
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get musicStatsTopArtists;

  /// No description provided for @musicStatsTopArtistsSub.
  ///
  /// In en, this message translates to:
  /// **'Score based on Spotify preferences'**
  String get musicStatsTopArtistsSub;

  /// No description provided for @musicStatsHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Listening heatmap'**
  String get musicStatsHeatmap;

  /// No description provided for @musicStatsHeatmapSub.
  ///
  /// In en, this message translates to:
  /// **'Weekly distribution of your listening'**
  String get musicStatsHeatmapSub;

  /// No description provided for @liveScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Vibra'**
  String get liveScreenTitle;

  /// No description provided for @liveScreenSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed. Check session and attendance.'**
  String get liveScreenSendFailed;

  /// No description provided for @liveScreenActivateMode.
  ///
  /// In en, this message translates to:
  /// **'Activate Live Mode'**
  String get liveScreenActivateMode;

  /// No description provided for @liveScreenPresentNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Present now'**
  String get liveScreenPresentNowTitle;

  /// No description provided for @liveScreenPresentNowSub.
  ///
  /// In en, this message translates to:
  /// **'Attendees with high musical compatibility'**
  String get liveScreenPresentNowSub;

  /// No description provided for @liveScreenChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Chat'**
  String get liveScreenChatTitle;

  /// No description provided for @liveScreenChatSub.
  ///
  /// In en, this message translates to:
  /// **'Realtime chat auto-closes in 24h'**
  String get liveScreenChatSub;

  /// No description provided for @eventDetailNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Event unavailable'**
  String get eventDetailNotAvailableTitle;

  /// No description provided for @eventDetailNotAvailableMsg.
  ///
  /// In en, this message translates to:
  /// **'This event is no longer available or hasnt loaded.'**
  String get eventDetailNotAvailableMsg;

  /// No description provided for @eventDetailMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Venue Map'**
  String get eventDetailMapTitle;

  /// No description provided for @eventDetailMapSub.
  ///
  /// In en, this message translates to:
  /// **'Event location'**
  String get eventDetailMapSub;

  /// No description provided for @eventDetailAttendeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get eventDetailAttendeesTitle;

  /// No description provided for @eventDetailAttendeesSub.
  ///
  /// In en, this message translates to:
  /// **'Users with musical match and confirmed attendance'**
  String get eventDetailAttendeesSub;

  /// No description provided for @spotifyAuthStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. OAuth Authorization'**
  String get spotifyAuthStep1Title;

  /// No description provided for @spotifyAuthStep1Sub.
  ///
  /// In en, this message translates to:
  /// **'Securely login on official Spotify site'**
  String get spotifyAuthStep1Sub;

  /// No description provided for @spotifyAuthStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Credential Exchange'**
  String get spotifyAuthStep2Title;

  /// No description provided for @spotifyAuthStep2Sub.
  ///
  /// In en, this message translates to:
  /// **'Generation of secure keys and token encryption'**
  String get spotifyAuthStep2Sub;

  /// No description provided for @spotifyAuthStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Taste Syncing'**
  String get spotifyAuthStep3Title;

  /// No description provided for @spotifyAuthStep3Sub.
  ///
  /// In en, this message translates to:
  /// **'Analysis of top artists, tracks, and playlists'**
  String get spotifyAuthStep3Sub;

  /// No description provided for @spotifyAuthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Connection cancelled. You must authorize Vibra for personalized recommendations.'**
  String get spotifyAuthCancelled;

  /// No description provided for @spotifyAuthError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String spotifyAuthError(String error);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @legalPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicyTitle;

  /// No description provided for @legalPrivacySec1.
  ///
  /// In en, this message translates to:
  /// **'What data Vibra collects'**
  String get legalPrivacySec1;

  /// No description provided for @legalPrivacySec2.
  ///
  /// In en, this message translates to:
  /// **'Why Vibra uses it'**
  String get legalPrivacySec2;

  /// No description provided for @legalPrivacySec3.
  ///
  /// In en, this message translates to:
  /// **'Your controls'**
  String get legalPrivacySec3;

  /// No description provided for @legalPrivacySec4.
  ///
  /// In en, this message translates to:
  /// **'Privacy contact'**
  String get legalPrivacySec4;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalTermsSec1.
  ///
  /// In en, this message translates to:
  /// **'Using Vibra'**
  String get legalTermsSec1;

  /// No description provided for @legalTermsSec2.
  ///
  /// In en, this message translates to:
  /// **'Third-party services'**
  String get legalTermsSec2;

  /// No description provided for @legalTermsSec3.
  ///
  /// In en, this message translates to:
  /// **'Content and behavior'**
  String get legalTermsSec3;

  /// No description provided for @legalTermsSec4.
  ///
  /// In en, this message translates to:
  /// **'Legal contact'**
  String get legalTermsSec4;

  /// No description provided for @legalSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get legalSupportTitle;

  /// No description provided for @legalSupportSec1.
  ///
  /// In en, this message translates to:
  /// **'Support email'**
  String get legalSupportSec1;

  /// No description provided for @legalSupportSec2.
  ///
  /// In en, this message translates to:
  /// **'Covered issues'**
  String get legalSupportSec2;

  /// No description provided for @legalSupportSec3.
  ///
  /// In en, this message translates to:
  /// **'What to check first'**
  String get legalSupportSec3;

  /// No description provided for @legalAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Vibra'**
  String get legalAboutTitle;

  /// No description provided for @legalAboutSec1.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get legalAboutSec1;

  /// No description provided for @legalAboutSec2.
  ///
  /// In en, this message translates to:
  /// **'Platform identifiers'**
  String get legalAboutSec2;

  /// No description provided for @legalAboutSec3.
  ///
  /// In en, this message translates to:
  /// **'What Vibra does'**
  String get legalAboutSec3;

  /// No description provided for @legalAboutSec4.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get legalAboutSec4;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get langItalian;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langGerman;

  /// No description provided for @spotifyAuthCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Authentication Failed'**
  String get spotifyAuthCancelledTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'System Error'**
  String get errorTitle;

  /// No description provided for @legalPrivacyBody1.
  ///
  /// In en, this message translates to:
  /// **'Account data, music profile, event attendance, messages, live chat activity, location when authorized, and push tokens.'**
  String get legalPrivacyBody1;

  /// No description provided for @legalPrivacyBody2.
  ///
  /// In en, this message translates to:
  /// **'To authenticate users, generate music recommendations, enable social features, send notifications, and improve service reliability.'**
  String get legalPrivacyBody2;

  /// No description provided for @legalPrivacyBody3.
  ///
  /// In en, this message translates to:
  /// **'You can revoke permissions, disconnect services, request deletion, and manage visibility and privacy preferences from account settings.'**
  String get legalPrivacyBody3;

  /// No description provided for @legalPrivacyBody4.
  ///
  /// In en, this message translates to:
  /// **'Privacy and personal data requests: {email}'**
  String legalPrivacyBody4(String email);

  /// No description provided for @legalTermsBody1.
  ///
  /// In en, this message translates to:
  /// **'By using Vibra, users agree to use the app lawfully, maintain accurate data, and avoid abusive or harmful behavior.'**
  String get legalTermsBody1;

  /// No description provided for @legalTermsBody2.
  ///
  /// In en, this message translates to:
  /// **'Spotify, Supabase, Firebase, and event providers may be used to deliver core features. Their terms and privacy policies also apply.'**
  String get legalTermsBody2;

  /// No description provided for @legalTermsBody3.
  ///
  /// In en, this message translates to:
  /// **'Users are responsible for published content and sent messages. Vibra may suspend or remove accounts that violate platform rules.'**
  String get legalTermsBody3;

  /// No description provided for @legalTermsBody4.
  ///
  /// In en, this message translates to:
  /// **'Legal requests and formal communications: {email}'**
  String legalTermsBody4(String email);

  /// No description provided for @legalSupportBody1.
  ///
  /// In en, this message translates to:
  /// **'{email}'**
  String legalSupportBody1(String email);

  /// No description provided for @legalSupportBody2.
  ///
  /// In en, this message translates to:
  /// **'Login issues, Spotify connection, event discovery, notifications, chat, privacy requests, and account deletion.'**
  String get legalSupportBody2;

  /// No description provided for @legalSupportBody3.
  ///
  /// In en, this message translates to:
  /// **'Permissions, Spotify connection status, Firebase configuration, and the presence of an authenticated user.'**
  String get legalSupportBody3;

  /// No description provided for @legalAboutBody1.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String legalAboutBody1(String version, String build);

  /// No description provided for @legalAboutBody2.
  ///
  /// In en, this message translates to:
  /// **'Android package: {android}\niOS bundle: {ios}'**
  String legalAboutBody2(String android, String ios);

  /// No description provided for @legalAboutBody3.
  ///
  /// In en, this message translates to:
  /// **'Vibra helps connect Spotify, discover relevant live events, view event details, meet compatible people, and join live chats during concerts.'**
  String get legalAboutBody3;

  /// No description provided for @legalAboutBody4.
  ///
  /// In en, this message translates to:
  /// **'{email}'**
  String legalAboutBody4(String email);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning 👋'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 👋'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening 🌙'**
  String get homeGreetingEvening;

  /// No description provided for @eventCardTBA.
  ///
  /// In en, this message translates to:
  /// **'TBA'**
  String get eventCardTBA;

  /// No description provided for @eventCardCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get eventCardCity;

  /// No description provided for @legalPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A summary of the privacy information available in the app, including categories of processed data and purposes of use.'**
  String get legalPrivacySubtitle;

  /// No description provided for @legalTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A summary of the rules, responsibilities, and terms of service applicable to using Vibra.'**
  String get legalTermsSubtitle;

  /// No description provided for @legalSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support information for account access, notifications, Spotify connection, and live features.'**
  String get legalSupportSubtitle;

  /// No description provided for @legalAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibra combines music taste, event discovery, and social interaction around live experiences.'**
  String get legalAboutSubtitle;

  /// No description provided for @exploreShowAllEvents.
  ///
  /// In en, this message translates to:
  /// **'Show all events'**
  String get exploreShowAllEvents;

  /// No description provided for @musicStatsSyncSpotify.
  ///
  /// In en, this message translates to:
  /// **'Sync Spotify'**
  String get musicStatsSyncSpotify;

  /// No description provided for @liveModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Live mode is disabled'**
  String get liveModeDisabled;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get authCreateAccount;

  /// No description provided for @authLoginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get authLoginWithEmail;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get authUsernameHint;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordShort;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don t have an account? Register'**
  String get authDontHaveAccount;

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get authGenericError;

  /// No description provided for @eventCardLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get eventCardLocation;

  /// No description provided for @matchScore.
  ///
  /// In en, this message translates to:
  /// **'MATCH SCORE'**
  String get matchScore;

  /// No description provided for @userGeneric.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userGeneric;

  /// No description provided for @spotifyConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify'**
  String get spotifyConnectTitle;

  /// No description provided for @spotifyConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your account to sync your favorite artists and unlock personalized recommendations for concerts.'**
  String get spotifyConnectSubtitle;

  /// No description provided for @spotifyConnectOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Flow'**
  String get spotifyConnectOnboarding;

  /// No description provided for @spotifyConnectPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'We will read your top artists and genres to personalize recommendations and calculate your affinity (Match Score) with other users. Aggregated historical data will only be used for this purpose.'**
  String get spotifyConnectPrivacyDesc;

  /// No description provided for @spotifyConnectContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue and Explore'**
  String get spotifyConnectContinue;

  /// No description provided for @spotifyConnectRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get spotifyConnectRetry;

  /// No description provided for @spotifyConnectAction.
  ///
  /// In en, this message translates to:
  /// **'Connect my Spotify'**
  String get spotifyConnectAction;

  /// No description provided for @spotifyConnectSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get spotifyConnectSkip;

  /// No description provided for @homeSpotifySyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Personalized Recommendations'**
  String get homeSpotifySyncTitle;

  /// No description provided for @homeSpotifySyncSub.
  ///
  /// In en, this message translates to:
  /// **'Sync your music listening'**
  String get homeSpotifySyncSub;

  /// No description provided for @homeSpotifySyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify to get event recommendations and find people with your same tastes.'**
  String get homeSpotifySyncDesc;

  /// No description provided for @homeSpotifySyncAction.
  ///
  /// In en, this message translates to:
  /// **'CONNECT SPOTIFY'**
  String get homeSpotifySyncAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
