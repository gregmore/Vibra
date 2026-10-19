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
  /// **'Discover concerts and people to enjoy them with.'**
  String get loginSubtitle;

  /// No description provided for @loginConsent.
  ///
  /// In en, this message translates to:
  /// **'Read the terms and privacy information before continuing. Manage optional preferences in settings.'**
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
  /// **'To receive notifications, sign in and enable Vibra notifications in your device settings.'**
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
  /// **'Could not delete your account. Try again or contact support.'**
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
  /// **'Explore the community to find people and send friend requests.'**
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
  /// **'SEARCH RADIUS: {radius} KM'**
  String exploreSearchRadius(int radius);

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

  /// No description provided for @myEventsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get myEventsUpcoming;

  /// No description provided for @myEventsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get myEventsPast;

  /// No description provided for @myEventsPastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your concert history'**
  String get myEventsPastSubtitle;

  /// No description provided for @myEventsPastEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past events yet.'**
  String get myEventsPastEmpty;

  /// No description provided for @myEventsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events, artists or places'**
  String get myEventsSearchHint;

  /// No description provided for @myEventsSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events match your search.'**
  String get myEventsSearchEmpty;

  /// No description provided for @myEventsClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get myEventsClearSearch;

  /// No description provided for @myEventsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore events'**
  String get myEventsExplore;

  /// No description provided for @inboxUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get inboxUnread;

  /// No description provided for @inboxNoResults.
  ///
  /// In en, this message translates to:
  /// **'No conversations found.'**
  String get inboxNoResults;

  /// No description provided for @inboxNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name or clear the filters to see all messages.'**
  String get inboxNoResultsBody;

  /// No description provided for @inboxClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get inboxClearFilters;

  /// No description provided for @homeFeedError.
  ///
  /// In en, this message translates to:
  /// **'Events could not be loaded.'**
  String get homeFeedError;

  /// No description provided for @homeFeedErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Try again shortly. You can still explore the map.'**
  String get homeFeedErrorBody;

  /// No description provided for @homeFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'There’s room for a new night out.'**
  String get homeFeedEmpty;

  /// No description provided for @homeFeedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Explore the map to find your next live show.'**
  String get homeFeedEmptyBody;

  /// No description provided for @socialSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search people or artists'**
  String get socialSearchHint;

  /// No description provided for @socialSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No people found.'**
  String get socialSearchEmpty;

  /// No description provided for @socialSearchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name or artist.'**
  String get socialSearchEmptyBody;

  /// No description provided for @socialDiscoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'New connections start here.'**
  String get socialDiscoverEmpty;

  /// No description provided for @socialDiscoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile and connect Spotify to find people with similar tastes.'**
  String get socialDiscoverEmptyBody;

  /// No description provided for @chatSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendMessage;

  /// No description provided for @chatLoadError.
  ///
  /// In en, this message translates to:
  /// **'The conversation could not be loaded.'**
  String get chatLoadError;

  /// No description provided for @chatDraftRecovered.
  ///
  /// In en, this message translates to:
  /// **'The message was not sent. Its text has been restored in the composer.'**
  String get chatDraftRecovered;

  /// No description provided for @eventLocationUnknown.
  ///
  /// In en, this message translates to:
  /// **'The exact location is not available yet.'**
  String get eventLocationUnknown;

  /// No description provided for @eventDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get eventDirections;

  /// No description provided for @eventDirectionsError.
  ///
  /// In en, this message translates to:
  /// **'Directions could not be opened.'**
  String get eventDirectionsError;

  /// No description provided for @inboxDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get inboxDeleteTitle;

  /// No description provided for @inboxDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The conversation will be removed from your inbox. The other person’s messages will not be deleted.'**
  String get inboxDeleteBody;

  /// No description provided for @inboxDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get inboxDeleteAction;

  /// No description provided for @inboxDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted.'**
  String get inboxDeleteSuccess;

  /// No description provided for @inboxDeleteError.
  ///
  /// In en, this message translates to:
  /// **'The conversation was not deleted. Please try again.'**
  String get inboxDeleteError;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @eventCopyDetails.
  ///
  /// In en, this message translates to:
  /// **'Copy event details'**
  String get eventCopyDetails;

  /// No description provided for @eventCopyError.
  ///
  /// In en, this message translates to:
  /// **'Event details could not be copied.'**
  String get eventCopyError;

  /// No description provided for @eventCancelled.
  ///
  /// In en, this message translates to:
  /// **'Event cancelled'**
  String get eventCancelled;

  /// No description provided for @eventTicketsOffsale.
  ///
  /// In en, this message translates to:
  /// **'Tickets not on sale'**
  String get eventTicketsOffsale;

  /// No description provided for @socialMatchSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Vibra was not sent. Try again: the profile is still available.'**
  String get socialMatchSendFailed;

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
  /// **'You haven\'t confirmed your attendance to any event yet.\nExplore and find your next concerts!'**
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
  /// **'No saved events.\nSave the events you are interested in so you don\'t miss them.'**
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
  /// **'This event is no longer available or hasn’t loaded yet.'**
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
  /// **'Check your connection, device permissions and sign-in status. If the issue persists, report a problem from settings.'**
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
  /// **'Vibra helps you discover live events, explore the map, save concerts, meet people and join chats. Spotify features are available only when the service is enabled.'**
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
  /// **'Live events, a map and a community to share new nights out.'**
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
  /// **'Don’t have an account? Register'**
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

  /// No description provided for @loginBackToWelcome.
  ///
  /// In en, this message translates to:
  /// **'Back to the welcome screen'**
  String get loginBackToWelcome;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authEmailLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to log in and explore concerts.'**
  String get authEmailLoginSubtitle;

  /// No description provided for @authEmailRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to register and start enjoying live shows.'**
  String get authEmailRegisterSubtitle;

  /// No description provided for @authAgeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am at least 18 years old.'**
  String get authAgeConfirmation;

  /// No description provided for @authAgeExplanation.
  ///
  /// In en, this message translates to:
  /// **'Vibra helps people meet and is not intended for minors.'**
  String get authAgeExplanation;

  /// No description provided for @authAgeRequired.
  ///
  /// In en, this message translates to:
  /// **'You must confirm that you are at least 18 years old to create an account.'**
  String get authAgeRequired;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @spotifyUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Spotify is paused'**
  String get spotifyUnavailableTitle;

  /// No description provided for @spotifyUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Spotify and music affinity are temporarily disabled. Events, friends and chat remain available.'**
  String get spotifyUnavailableBody;

  /// No description provided for @launchExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next concert'**
  String get launchExploreTitle;

  /// No description provided for @launchExploreBody.
  ///
  /// In en, this message translates to:
  /// **'Search artists, explore the map and save nearby events.'**
  String get launchExploreBody;

  /// No description provided for @launchCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the community'**
  String get launchCommunityTitle;

  /// No description provided for @launchCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'Find people, add friends and plan concerts in your chats.'**
  String get launchCommunityBody;

  /// No description provided for @launchSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your live calendar'**
  String get launchSavedTitle;

  /// No description provided for @launchSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Save concerts and find the ones you want to attend.'**
  String get launchSavedBody;

  /// No description provided for @launchCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search people by name or username'**
  String get launchCommunitySubtitle;

  /// No description provided for @launchCommunityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No people found'**
  String get launchCommunityEmptyTitle;

  /// No description provided for @launchCommunityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name or check back later.'**
  String get launchCommunityEmptyBody;

  /// No description provided for @launchCommunityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load people. Try again.'**
  String get launchCommunityLoadError;

  /// No description provided for @commonOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOK;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get commonConnect;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonTryLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later.'**
  String get commonTryLater;

  /// No description provided for @commonConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get commonConnectionError;

  /// No description provided for @commonLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, loading'**
  String commonLoadingLabel(String label);

  /// No description provided for @commonSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, selected'**
  String commonSelectedLabel(String label);

  /// No description provided for @commonNotSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, not selected'**
  String commonNotSelectedLabel(String label);

  /// No description provided for @commonOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get commonOnline;

  /// No description provided for @commonAvatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get commonAvatar;

  /// No description provided for @commonPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percentage} percent {label}'**
  String commonPercentLabel(int percentage, String label);

  /// No description provided for @commonAvatarAffinity.
  ///
  /// In en, this message translates to:
  /// **'{name}, {percentage} percent affinity'**
  String commonAvatarAffinity(String name, int percentage);

  /// No description provided for @commonRegistrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Registration complete'**
  String get commonRegistrationComplete;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileBack.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get profileBack;

  /// No description provided for @profilePersonalSpace.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL SPACE'**
  String get profilePersonalSpace;

  /// No description provided for @profileSpotifyConnected.
  ///
  /// In en, this message translates to:
  /// **'Spotify connected'**
  String get profileSpotifyConnected;

  /// No description provided for @profileFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowing;

  /// No description provided for @profileOpenMusicStats.
  ///
  /// In en, this message translates to:
  /// **'Open music statistics'**
  String get profileOpenMusicStats;

  /// No description provided for @profileYourVibra.
  ///
  /// In en, this message translates to:
  /// **'YOUR VIBRA'**
  String get profileYourVibra;

  /// No description provided for @profileInRotation.
  ///
  /// In en, this message translates to:
  /// **'In rotation'**
  String get profileInRotation;

  /// No description provided for @profileSyncMusicBody.
  ///
  /// In en, this message translates to:
  /// **'Sync Spotify to see your music profile.'**
  String get profileSyncMusicBody;

  /// No description provided for @profileShapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Shape your Vibra'**
  String get profileShapeTitle;

  /// No description provided for @profileShapeBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify to show your musical identity.'**
  String get profileShapeBody;

  /// No description provided for @profileUsernameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get profileUsernameEmpty;

  /// No description provided for @profileUsernameShort.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get profileUsernameShort;

  /// No description provided for @profileUsernameCharacters.
  ///
  /// In en, this message translates to:
  /// **'Use only letters, numbers, _ or .'**
  String get profileUsernameCharacters;

  /// No description provided for @profileUsernameCharactersOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Use only letters, numbers and underscores'**
  String get profileUsernameCharactersOnboarding;

  /// No description provided for @profileUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get profileUsernameTaken;

  /// No description provided for @profileUsernameTakenRetry.
  ///
  /// In en, this message translates to:
  /// **'This username is taken. Choose another one.'**
  String get profileUsernameTakenRetry;

  /// No description provided for @profilePhotoPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow access to photos in your device settings and try again.'**
  String get profilePhotoPermission;

  /// No description provided for @profilePhotoPickError.
  ///
  /// In en, this message translates to:
  /// **'Could not select the photo. Try again.'**
  String get profilePhotoPickError;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoTitle;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoGalleryBody.
  ///
  /// In en, this message translates to:
  /// **'Select a photo from your device'**
  String get profilePhotoGalleryBody;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Use the camera to take a new photo'**
  String get profilePhotoCameraBody;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profilePhotoRemove;

  /// No description provided for @profilePhotoRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore the default avatar'**
  String get profilePhotoRestore;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Try again shortly.'**
  String get profileSaveError;

  /// No description provided for @profilePhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profilePhotoChange;

  /// No description provided for @profileUsernameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. music_fan'**
  String get profileUsernameExample;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name or nickname'**
  String get profileNameHint;

  /// No description provided for @profileNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get profileNameEmpty;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileDescription;

  /// No description provided for @profileDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself…'**
  String get profileDescriptionHint;

  /// No description provided for @profileMusicStreaming.
  ///
  /// In en, this message translates to:
  /// **'Music and streaming'**
  String get profileMusicStreaming;

  /// No description provided for @profileAccountConnected.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get profileAccountConnected;

  /// No description provided for @profileConnectSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Connect your account for better suggestions'**
  String get profileConnectSuggestions;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSaveChanges;

  /// No description provided for @homeYourSoundToday.
  ///
  /// In en, this message translates to:
  /// **'YOUR SOUND, TODAY'**
  String get homeYourSoundToday;

  /// No description provided for @homeSpotifySynced.
  ///
  /// In en, this message translates to:
  /// **'Spotify synced · suggestions learn from you'**
  String get homeSpotifySynced;

  /// No description provided for @homeSpotifyPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify to personalize your suggestions'**
  String get homeSpotifyPersonalize;

  /// No description provided for @homeCompleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get homeCompleteProfile;

  /// No description provided for @homeShapeVibra.
  ///
  /// In en, this message translates to:
  /// **'Make your Vibra your own'**
  String get homeShapeVibra;

  /// No description provided for @homeNextEvent.
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get homeNextEvent;

  /// No description provided for @homeNearbyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'NEARBY'**
  String get homeNearbyEyebrow;

  /// No description provided for @homeTrendingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'HAPPENING NOW'**
  String get homeTrendingEyebrow;

  /// No description provided for @settingsPrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'Private messages and requests'**
  String get settingsPrivateMessages;

  /// No description provided for @settingsPersonalizedUpdates.
  ///
  /// In en, this message translates to:
  /// **'Personalized updates and reminders'**
  String get settingsPersonalizedUpdates;

  /// No description provided for @settingsMusicWeek.
  ///
  /// In en, this message translates to:
  /// **'Your music week'**
  String get settingsMusicWeek;

  /// No description provided for @settingsMusicWeekBody.
  ///
  /// In en, this message translates to:
  /// **'Events and affinities selected for you'**
  String get settingsMusicWeekBody;

  /// No description provided for @settingsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get settingsWeekly;

  /// No description provided for @settingsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get settingsMonthly;

  /// No description provided for @settingsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsNever;

  /// No description provided for @settingsPrivacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy and personal data'**
  String get settingsPrivacyData;

  /// No description provided for @settingsPrivacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Consent, data export and deletion'**
  String get settingsPrivacyDataBody;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsHelpCenterBody.
  ///
  /// In en, this message translates to:
  /// **'Help with accounts, events, chat and Spotify'**
  String get settingsHelpCenterBody;

  /// No description provided for @settingsReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settingsReportProblem;

  /// No description provided for @settingsReportProblemBody.
  ///
  /// In en, this message translates to:
  /// **'Send sanitized diagnostics and an optional screenshot'**
  String get settingsReportProblemBody;

  /// No description provided for @privacySaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your preference. Try again.'**
  String get privacySaveError;

  /// No description provided for @privacyExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data export'**
  String get privacyExportTitle;

  /// No description provided for @privacySaveJSON.
  ///
  /// In en, this message translates to:
  /// **'Save JSON'**
  String get privacySaveJSON;

  /// No description provided for @privacyCopyJSON.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get privacyCopyJSON;

  /// No description provided for @privacyCopiedJSON.
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard.'**
  String get privacyCopiedJSON;

  /// No description provided for @privacyExportError.
  ///
  /// In en, this message translates to:
  /// **'Data export unavailable. Try again later.'**
  String get privacyExportError;

  /// No description provided for @privacyExportSaved.
  ///
  /// In en, this message translates to:
  /// **'Export saved to {path}'**
  String privacyExportSaved(String path);

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose each optional use of your data separately. You can change your mind at any time.'**
  String get privacyIntro;

  /// No description provided for @privacyPreciseLocation.
  ///
  /// In en, this message translates to:
  /// **'Precise location'**
  String get privacyPreciseLocation;

  /// No description provided for @privacyPreciseLocationBody.
  ///
  /// In en, this message translates to:
  /// **'For nearby events and Live features. Stored for up to 30 days.'**
  String get privacyPreciseLocationBody;

  /// No description provided for @privacySpotifyMatching.
  ///
  /// In en, this message translates to:
  /// **'Spotify for music affinity'**
  String get privacySpotifyMatching;

  /// No description provided for @privacySpotifyMatchingBody.
  ///
  /// In en, this message translates to:
  /// **'Use synced artists, genres and listening for suggestions and affinity.'**
  String get privacySpotifyMatchingBody;

  /// No description provided for @privacyServiceNotifications.
  ///
  /// In en, this message translates to:
  /// **'Service notifications'**
  String get privacyServiceNotifications;

  /// No description provided for @privacyServiceNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Matches, messages and saved events.'**
  String get privacyServiceNotificationsBody;

  /// No description provided for @privacyMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing messages'**
  String get privacyMarketing;

  /// No description provided for @privacyMarketingBody.
  ///
  /// In en, this message translates to:
  /// **'Always optional; you can use the app without them.'**
  String get privacyMarketingBody;

  /// No description provided for @privacyExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get privacyExportAction;

  /// No description provided for @privacyExportBody.
  ///
  /// In en, this message translates to:
  /// **'Generate a readable JSON copy of your profile, chats, events and interactions, including previous Spotify data if present.'**
  String get privacyExportBody;

  /// No description provided for @privacyDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account removes its data. Sent messages become anonymous and their content and media are removed. Backups follow the retention period stated in the privacy policy.'**
  String get privacyDeletionBody;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the app theme or follow your device.'**
  String get appearanceBody;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @appearanceDarkBody.
  ///
  /// In en, this message translates to:
  /// **'Reduces brightness in low light'**
  String get appearanceDarkBody;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceLightBody.
  ///
  /// In en, this message translates to:
  /// **'Bright surfaces and soft shadows'**
  String get appearanceLightBody;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'Automatic (system)'**
  String get appearanceSystem;

  /// No description provided for @appearanceSystemBody.
  ///
  /// In en, this message translates to:
  /// **'Updates when your device setting changes'**
  String get appearanceSystemBody;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back to the previous step'**
  String get onboardingBack;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Let’s start'**
  String get onboardingStart;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileBody.
  ///
  /// In en, this message translates to:
  /// **'How other people will see you'**
  String get onboardingProfileBody;

  /// No description provided for @onboardingSkipToHome.
  ///
  /// In en, this message translates to:
  /// **'Skip the rest and go to Home'**
  String get onboardingSkipToHome;

  /// No description provided for @onboardingPhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading profile photo'**
  String get onboardingPhotoUploading;

  /// No description provided for @onboardingPhotoSelect.
  ///
  /// In en, this message translates to:
  /// **'Choose or change your profile photo'**
  String get onboardingPhotoSelect;

  /// No description provided for @onboardingUsernameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. vibra_user'**
  String get onboardingUsernameExample;

  /// No description provided for @onboardingRequired.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get onboardingRequired;

  /// No description provided for @onboardingSpotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Find events based on your listening and discover musical affinity with other people.'**
  String get onboardingSpotifyBody;

  /// No description provided for @onboardingSpotifyCancelled.
  ///
  /// In en, this message translates to:
  /// **'Connection cancelled. Try again or skip for now.'**
  String get onboardingSpotifyCancelled;

  /// No description provided for @onboardingSpotifyError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Try again later.'**
  String get onboardingSpotifyError;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Events near you'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Enable location to discover concerts and venues in your area.'**
  String get onboardingLocationBody;

  /// No description provided for @onboardingLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. You can enable it later in your device settings.'**
  String get onboardingLocationDenied;

  /// No description provided for @onboardingAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get onboardingAllowLocation;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay up to date'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Get notifications for saved events, friend requests and messages.'**
  String get onboardingNotificationsBody;

  /// No description provided for @onboardingNotificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications denied. You can enable them in your device settings.'**
  String get onboardingNotificationsDenied;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get onboardingAllowNotifications;

  /// No description provided for @liveAttendanceError.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm attendance. Try again.'**
  String get liveAttendanceError;

  /// No description provided for @liveEventsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load Live events.'**
  String get liveEventsLoadError;

  /// No description provided for @liveLocationHelp.
  ///
  /// In en, this message translates to:
  /// **'Live chat is available within 500 m of an event, during the 24 hours before and after the concert. Enable location in privacy settings.'**
  String get liveLocationHelp;

  /// No description provided for @liveUnavailableHere.
  ///
  /// In en, this message translates to:
  /// **'This event’s chat is unavailable at your location or at this time.'**
  String get liveUnavailableHere;

  /// No description provided for @liveRefreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh location'**
  String get liveRefreshLocation;

  /// No description provided for @liveEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Live event'**
  String get liveEventTitle;

  /// No description provided for @liveConnectionInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Live chat connection interrupted.'**
  String get liveConnectionInterrupted;

  /// No description provided for @liveEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages. Start the conversation!'**
  String get liveEmpty;

  /// No description provided for @liveRetryAttendance.
  ///
  /// In en, this message translates to:
  /// **'Check attendance again'**
  String get liveRetryAttendance;

  /// No description provided for @liveConfirmingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Confirming attendance…'**
  String get liveConfirmingAttendance;

  /// No description provided for @liveJoinToChat.
  ///
  /// In en, this message translates to:
  /// **'Join the event to write in chat'**
  String get liveJoinToChat;

  /// No description provided for @liveInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write in Live chat…'**
  String get liveInputHint;

  /// No description provided for @liveSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Live message'**
  String get liveSendMessage;

  /// No description provided for @musicReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get musicReconnect;

  /// No description provided for @musicReconnectBody.
  ///
  /// In en, this message translates to:
  /// **'Reconnect Spotify to update music statistics.'**
  String get musicReconnectBody;

  /// No description provided for @musicStatsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Music statistics updated.'**
  String get musicStatsUpdated;

  /// No description provided for @musicStatsRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Updating music statistics'**
  String get musicStatsRefreshing;

  /// No description provided for @musicStatsNoArtists.
  ///
  /// In en, this message translates to:
  /// **'No artists available after the last sync.'**
  String get musicStatsNoArtists;

  /// No description provided for @musicStatsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Give your profile a sound.'**
  String get musicStatsEmptyTitle;

  /// No description provided for @musicStatsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify to see the artists and rhythms that define you.'**
  String get musicStatsEmptyBody;

  /// No description provided for @musicStatsYourSound.
  ///
  /// In en, this message translates to:
  /// **'YOUR SOUND'**
  String get musicStatsYourSound;

  /// No description provided for @musicStatsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Listening that makes a mark.'**
  String get musicStatsHeroTitle;

  /// No description provided for @musicStatsArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get musicStatsArtists;

  /// No description provided for @musicStatsRhythm.
  ///
  /// In en, this message translates to:
  /// **'Rhythm'**
  String get musicStatsRhythm;

  /// No description provided for @spotifyBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get spotifyBackToLogin;

  /// No description provided for @spotifyConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Connecting Spotify allows Vibra to read your profile and top artists, tracks and genres. We use them for event suggestions and musical affinity; you can disconnect Spotify and delete this data in settings.'**
  String get spotifyConsentBody;

  /// No description provided for @eventBackToEvents.
  ///
  /// In en, this message translates to:
  /// **'Back to events'**
  String get eventBackToEvents;

  /// No description provided for @eventPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get eventPrice;

  /// No description provided for @eventVenueTBA.
  ///
  /// In en, this message translates to:
  /// **'Venue to be announced'**
  String get eventVenueTBA;

  /// No description provided for @eventOpenSemantics.
  ///
  /// In en, this message translates to:
  /// **'Open event {name}, {date}, {place}'**
  String eventOpenSemantics(String name, String date, String place);

  /// No description provided for @eventAffinitySemantics.
  ///
  /// In en, this message translates to:
  /// **'{percentage} percent affinity'**
  String eventAffinitySemantics(int percentage);

  /// No description provided for @eventForYouScore.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% FOR YOU'**
  String eventForYouScore(int percentage);

  /// No description provided for @eventCommonSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} shared or saved event} other{{count} shared or saved events}}'**
  String eventCommonSavedCount(int count);

  /// No description provided for @supportReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get supportReportTitle;

  /// No description provided for @supportReportIntro.
  ///
  /// In en, this message translates to:
  /// **'Describe what is not working. We’ll include the app version, operating system and a few diagnostics with sensitive information removed.'**
  String get supportReportIntro;

  /// No description provided for @supportDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem description'**
  String get supportDescriptionLabel;

  /// No description provided for @supportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Include the screen, steps and what you expected.'**
  String get supportDescriptionHint;

  /// No description provided for @supportAddScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Add screenshot'**
  String get supportAddScreenshot;

  /// No description provided for @supportScreenshotAttached.
  ///
  /// In en, this message translates to:
  /// **'Screenshot attached'**
  String get supportScreenshotAttached;

  /// No description provided for @supportRemoveScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Remove screenshot'**
  String get supportRemoveScreenshot;

  /// No description provided for @supportScreenshotPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Make sure the screenshot does not show passwords, private messages or other sensitive data.'**
  String get supportScreenshotPrivacy;

  /// No description provided for @supportSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get supportSending;

  /// No description provided for @supportSendReport.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get supportSendReport;

  /// No description provided for @supportDescriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem in at least 8 characters.'**
  String get supportDescriptionTooShort;

  /// No description provided for @supportDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'The description can contain up to 4000 characters.'**
  String get supportDescriptionTooLong;

  /// No description provided for @supportReportSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report sent'**
  String get supportReportSentTitle;

  /// No description provided for @supportReportSentBody.
  ///
  /// In en, this message translates to:
  /// **'We’ve received your report. Support replies within 48 business hours.'**
  String get supportReportSentBody;

  /// No description provided for @supportReportSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the report. Try again or contact {email}.'**
  String supportReportSendFailed(String email);

  /// No description provided for @supportReportAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to send the report.'**
  String get supportReportAuthRequired;

  /// No description provided for @supportReportRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You’ve sent too many reports. Wait a minute and try again.'**
  String get supportReportRateLimited;

  /// No description provided for @supportScreenshotTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The screenshot must be smaller than 5 MB.'**
  String get supportScreenshotTooLarge;

  /// No description provided for @supportScreenshotUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPG or PNG screenshot.'**
  String get supportScreenshotUnsupported;

  /// No description provided for @supportScreenshotPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select the screenshot. Try again.'**
  String get supportScreenshotPickFailed;

  /// No description provided for @supportScreenshotPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access in device settings to attach a screenshot.'**
  String get supportScreenshotPermissionDenied;

  /// No description provided for @supportAlternativeContact.
  ///
  /// In en, this message translates to:
  /// **'You can also contact {email}. We reply within 48 business hours.'**
  String supportAlternativeContact(String email);

  /// No description provided for @supportFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'How is Vibra going?'**
  String get supportFeedbackTitle;

  /// No description provided for @supportFeedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve.'**
  String get supportFeedbackBody;

  /// No description provided for @supportFeedbackNegative.
  ///
  /// In en, this message translates to:
  /// **'Not well'**
  String get supportFeedbackNegative;

  /// No description provided for @supportFeedbackNeutral.
  ///
  /// In en, this message translates to:
  /// **'So-so'**
  String get supportFeedbackNeutral;

  /// No description provided for @supportFeedbackPositive.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get supportFeedbackPositive;

  /// No description provided for @supportFeedbackDescriptionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Feedback:'**
  String get supportFeedbackDescriptionPrefix;

  /// No description provided for @chatSendFriendshipRequired.
  ///
  /// In en, this message translates to:
  /// **'To message this person, send a friend request and wait for it to be accepted.'**
  String get chatSendFriendshipRequired;

  /// No description provided for @chatSendFirstContactLimit.
  ///
  /// In en, this message translates to:
  /// **'You’ve already sent 3 messages. Wait for a reply before sending more.'**
  String get chatSendFirstContactLimit;

  /// No description provided for @chatSendUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This conversation is unavailable.'**
  String get chatSendUnavailable;

  /// No description provided for @chatSendRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You’re sending too many messages. Wait a minute and try again.'**
  String get chatSendRateLimited;

  /// No description provided for @chatSendSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to send your message.'**
  String get chatSendSignInRequired;

  /// No description provided for @chatRequestFriendship.
  ///
  /// In en, this message translates to:
  /// **'Send friend request'**
  String get chatRequestFriendship;

  /// No description provided for @chatFriendshipRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get chatFriendshipRequestSent;

  /// No description provided for @chatFriendshipRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the friend request. Try again.'**
  String get chatFriendshipRequestFailed;

  /// No description provided for @chatMessageTooLong.
  ///
  /// In en, this message translates to:
  /// **'The message can contain up to 2000 characters.'**
  String get chatMessageTooLong;

  /// No description provided for @chatPermissionChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking conversation…'**
  String get chatPermissionChecking;

  /// No description provided for @chatFriendshipRequestPending.
  ///
  /// In en, this message translates to:
  /// **'Friend request awaiting acceptance'**
  String get chatFriendshipRequestPending;

  /// No description provided for @chatAcceptFriendship.
  ///
  /// In en, this message translates to:
  /// **'Accept friend request'**
  String get chatAcceptFriendship;

  /// No description provided for @chatFriendshipAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted. You can now send messages.'**
  String get chatFriendshipAccepted;

  /// No description provided for @socialReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get socialReportUser;

  /// No description provided for @socialReportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get socialReportSpam;

  /// No description provided for @socialReportHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get socialReportHarassment;

  /// No description provided for @socialReportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get socialReportInappropriate;

  /// No description provided for @socialReportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get socialReportDetailsHint;

  /// No description provided for @socialReportSent.
  ///
  /// In en, this message translates to:
  /// **'User reported'**
  String get socialReportSent;

  /// No description provided for @socialReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit the report. Try again.'**
  String get socialReportFailed;

  /// No description provided for @socialReportAction.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get socialReportAction;

  /// No description provided for @socialBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get socialBlockUser;

  /// No description provided for @socialBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block this person? You will no longer be able to exchange messages.'**
  String get socialBlockConfirm;

  /// No description provided for @socialBlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get socialBlockSuccess;

  /// No description provided for @socialBlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not block this person. Try again.'**
  String get socialBlockFailed;

  /// No description provided for @socialBlockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get socialBlockAction;

  /// No description provided for @chatRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Message request'**
  String get chatRequestTitle;

  /// No description provided for @chatRequestBody.
  ///
  /// In en, this message translates to:
  /// **'{name} would like to message you. Reply to accept the conversation.'**
  String chatRequestBody(String name);

  /// No description provided for @chatRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request declined and deleted'**
  String get chatRequestRejected;

  /// No description provided for @chatRequestRejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the request. Try again.'**
  String get chatRequestRejectFailed;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get commonReject;

  /// No description provided for @commonReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commonReply;

  /// No description provided for @userProfileView.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get userProfileView;

  /// No description provided for @chatConnectionInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Chat connection interrupted.'**
  String get chatConnectionInterrupted;

  /// No description provided for @chatMeetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Meetup proposal'**
  String get chatMeetupTitle;

  /// No description provided for @chatMeetupAccept.
  ///
  /// In en, this message translates to:
  /// **'I’m in'**
  String get chatMeetupAccept;

  /// No description provided for @chatMeetupDecline.
  ///
  /// In en, this message translates to:
  /// **'I can’t'**
  String get chatMeetupDecline;

  /// No description provided for @chatMeetupAcceptMessage.
  ///
  /// In en, this message translates to:
  /// **'I’m in! {message}'**
  String chatMeetupAcceptMessage(String message);

  /// No description provided for @chatMeetupDeclineMessage.
  ///
  /// In en, this message translates to:
  /// **'I can’t attend. {message}'**
  String chatMeetupDeclineMessage(String message);

  /// No description provided for @helpIntro.
  ///
  /// In en, this message translates to:
  /// **'Quick answers and support. We reply within 48 business hours.'**
  String get helpIntro;

  /// No description provided for @helpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search frequently asked questions'**
  String get helpSearchHint;

  /// No description provided for @helpSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No answers found. Try another search.'**
  String get helpSearchEmpty;

  /// No description provided for @helpNeedMore.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get helpNeedMore;

  /// No description provided for @helpCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get helpCategoryAll;

  /// No description provided for @helpCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get helpCategoryAccount;

  /// No description provided for @helpCategoryChatMatch.
  ///
  /// In en, this message translates to:
  /// **'Chat and affinity'**
  String get helpCategoryChatMatch;

  /// No description provided for @helpCategoryPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get helpCategoryPrivacy;

  /// No description provided for @helpLoginQuestion.
  ///
  /// In en, this message translates to:
  /// **'I can’t sign in'**
  String get helpLoginQuestion;

  /// No description provided for @helpLoginAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check your email and password, then close and reopen Vibra. If it still fails, use “Report a problem” and include your sign-in method.'**
  String get helpLoginAnswer;

  /// No description provided for @helpLogoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I sign out?'**
  String get helpLogoutQuestion;

  /// No description provided for @helpLogoutAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings > Log out. To end all sessions, choose “Log out from all devices”.'**
  String get helpLogoutAnswer;

  /// No description provided for @helpDeleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get helpDeleteQuestion;

  /// No description provided for @helpDeleteAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings > Delete account. Confirming removes your account data as described in the privacy policy.'**
  String get helpDeleteAnswer;

  /// No description provided for @helpEventsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why are there no events near me?'**
  String get helpEventsQuestion;

  /// No description provided for @helpEventsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check location access and widen the search radius. Availability depends on event sources in the area; you can also search a city.'**
  String get helpEventsAnswer;

  /// No description provided for @helpTicketsQuestion.
  ///
  /// In en, this message translates to:
  /// **'An event or ticket link won’t open'**
  String get helpTicketsQuestion;

  /// No description provided for @helpTicketsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Events and tickets come from external partners. Try again later; if the issue persists, report it and include the event.'**
  String get helpTicketsAnswer;

  /// No description provided for @helpAffinityQuestion.
  ///
  /// In en, this message translates to:
  /// **'How is affinity calculated?'**
  String get helpAffinityQuestion;

  /// No description provided for @helpAffinityAnswer.
  ///
  /// In en, this message translates to:
  /// **'The score compares shared artists and genres, with a small bonus for less common tastes. It indicates affinity and is not a guarantee.'**
  String get helpAffinityAnswer;

  /// No description provided for @helpBlockQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I block or report someone?'**
  String get helpBlockQuestion;

  /// No description provided for @helpBlockAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open the conversation and use its menu to block or report the person. Blocking prevents future interactions; reports are sent to the team.'**
  String get helpBlockAnswer;

  /// No description provided for @helpSpotifyConnectQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I connect Spotify?'**
  String get helpSpotifyConnectQuestion;

  /// No description provided for @helpSpotifyConnectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings > Spotify account and complete authorization in Spotify. You’ll return to Vibra automatically.'**
  String get helpSpotifyConnectAnswer;

  /// No description provided for @helpSpotifyDisconnectQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I disconnect Spotify?'**
  String get helpSpotifyDisconnectQuestion;

  /// No description provided for @helpSpotifyDisconnectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings > Spotify account and choose “Disconnect”.'**
  String get helpSpotifyDisconnectAnswer;

  /// No description provided for @helpSpotifyErrorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Spotify connection fails'**
  String get helpSpotifyErrorQuestion;

  /// No description provided for @helpSpotifyErrorAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and complete authorization. Never share passwords or tokens with support: reports include only sanitized diagnostics.'**
  String get helpSpotifyErrorAnswer;

  /// No description provided for @helpReportDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'What data does a problem report send?'**
  String get helpReportDataQuestion;

  /// No description provided for @helpReportDataAnswer.
  ///
  /// In en, this message translates to:
  /// **'App version, operating system, the last failing endpoint and a few technical logs with sensitive data removed. A screenshot is optional: check that it contains no private information.'**
  String get helpReportDataAnswer;

  /// No description provided for @helpPrivacyQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I exercise my data rights?'**
  String get helpPrivacyQuestion;

  /// No description provided for @helpPrivacyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings > Privacy and personal data to manage consent and export your data. For other requests, contact {email}.'**
  String helpPrivacyAnswer(String email);

  /// No description provided for @exploreEyebrow.
  ///
  /// In en, this message translates to:
  /// **'EVENTS AROUND YOU'**
  String get exploreEyebrow;

  /// No description provided for @exploreClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get exploreClearSearch;

  /// No description provided for @exploreEventsVisible.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} EVENT IN VIEW} other{{count} EVENTS IN VIEW}}'**
  String exploreEventsVisible(int count);

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @exploreLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Events could not be loaded.'**
  String get exploreLoadErrorTitle;

  /// No description provided for @exploreLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and search this area again.'**
  String get exploreLoadErrorBody;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No events found in this area.'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Widen the radius or change the filters.'**
  String get exploreEmptyBody;

  /// No description provided for @exploreZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get exploreZoomIn;

  /// No description provided for @exploreZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get exploreZoomOut;

  /// No description provided for @exploreOpenEvents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Open list of {count} event} other{Open list of {count} events}}'**
  String exploreOpenEvents(int count);

  /// No description provided for @exploreMoveMapHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to search for events'**
  String get exploreMoveMapHint;

  /// No description provided for @exploreEventsInArea.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} event in this area} other{{count} events in this area}}'**
  String exploreEventsInArea(int count);

  /// No description provided for @exploreCloseEvents.
  ///
  /// In en, this message translates to:
  /// **'Close event list'**
  String get exploreCloseEvents;

  /// No description provided for @exploreGenreElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get exploreGenreElectronic;

  /// No description provided for @exploreGenreAlternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get exploreGenreAlternative;

  /// No description provided for @commonLinkOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get commonLinkOpenError;

  /// No description provided for @authConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'We’ve sent you a confirmation email. Check your inbox before signing in.'**
  String get authConfirmEmail;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address first. Check your inbox.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. Check them and try again.'**
  String get authInvalidCredentials;

  /// No description provided for @authProviderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is unavailable. Use email or try again later.'**
  String get authProviderUnavailable;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try signing in.'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password and try again.'**
  String get authWeakPassword;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection unavailable. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorSessionChanged.
  ///
  /// In en, this message translates to:
  /// **'Your session has changed. Sign in again and retry.'**
  String get errorSessionChanged;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a minute and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorActionFailed.
  ///
  /// In en, this message translates to:
  /// **'The action failed. Try again shortly.'**
  String get errorActionFailed;

  /// No description provided for @socialAffinity.
  ///
  /// In en, this message translates to:
  /// **'Affinity'**
  String get socialAffinity;

  /// No description provided for @socialFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get socialFollow;

  /// No description provided for @socialFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get socialFollowing;

  /// No description provided for @socialFollowUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update following. Try again.'**
  String get socialFollowUpdateError;

  /// No description provided for @socialMessageAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get socialMessageAction;

  /// No description provided for @socialFriendRequestSentShort.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get socialFriendRequestSentShort;

  /// No description provided for @socialFriendRequestError.
  ///
  /// In en, this message translates to:
  /// **'Could not send the request. Try again.'**
  String get socialFriendRequestError;

  /// No description provided for @socialAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get socialAddFriend;

  /// No description provided for @socialCommonArtists.
  ///
  /// In en, this message translates to:
  /// **'Shared artists'**
  String get socialCommonArtists;

  /// No description provided for @socialUsersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load people.'**
  String get socialUsersLoadError;

  /// No description provided for @socialFollowersCount.
  ///
  /// In en, this message translates to:
  /// **'Followers ({count})'**
  String socialFollowersCount(int count);

  /// No description provided for @socialFollowingCount.
  ///
  /// In en, this message translates to:
  /// **'Following ({count})'**
  String socialFollowingCount(int count);

  /// No description provided for @socialNoFollowers.
  ///
  /// In en, this message translates to:
  /// **'No followers'**
  String get socialNoFollowers;

  /// No description provided for @socialNoFollowersBody.
  ///
  /// In en, this message translates to:
  /// **'People who follow this profile will appear here.'**
  String get socialNoFollowersBody;

  /// No description provided for @socialNoFollowing.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone'**
  String get socialNoFollowing;

  /// No description provided for @socialNoFollowingBody.
  ///
  /// In en, this message translates to:
  /// **'Followed profiles will appear here.'**
  String get socialNoFollowingBody;

  /// No description provided for @friendsRequestUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update the request. Try again.'**
  String get friendsRequestUpdateError;

  /// No description provided for @friendsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get friendsRemoveTitle;

  /// No description provided for @friendsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your friends?'**
  String friendsRemoveBody(String name);

  /// No description provided for @friendsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from friends'**
  String friendsRemoved(String name);

  /// No description provided for @friendsRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove this friend. Try again.'**
  String get friendsRemoveError;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @friendsConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends and connections'**
  String get friendsConnectionsTitle;

  /// No description provided for @friendsCount.
  ///
  /// In en, this message translates to:
  /// **'Friends ({count})'**
  String friendsCount(int count);

  /// No description provided for @friendsReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get friendsReceived;

  /// No description provided for @friendsSentCount.
  ///
  /// In en, this message translates to:
  /// **'Sent ({count})'**
  String friendsSentCount(int count);

  /// No description provided for @friendsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your friends…'**
  String get friendsSearchHint;

  /// No description provided for @friendsNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get friendsNoneFound;

  /// No description provided for @friendsFindBody.
  ///
  /// In en, this message translates to:
  /// **'Explore profiles, send friend requests and share events.'**
  String get friendsFindBody;

  /// No description provided for @friendsFindPeople.
  ///
  /// In en, this message translates to:
  /// **'Find people'**
  String get friendsFindPeople;

  /// No description provided for @friendsNoReceived.
  ///
  /// In en, this message translates to:
  /// **'No requests received'**
  String get friendsNoReceived;

  /// No description provided for @friendsNoReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'Friend requests from other people will appear here.'**
  String get friendsNoReceivedBody;

  /// No description provided for @friendsVibraUser.
  ///
  /// In en, this message translates to:
  /// **'Vibra user'**
  String get friendsVibraUser;

  /// No description provided for @friendsNoSent.
  ///
  /// In en, this message translates to:
  /// **'No sent requests'**
  String get friendsNoSent;

  /// No description provided for @friendsNoSentBody.
  ///
  /// In en, this message translates to:
  /// **'Sent friend requests awaiting a reply will appear here.'**
  String get friendsNoSentBody;

  /// No description provided for @inboxOpenConversation.
  ///
  /// In en, this message translates to:
  /// **'Open conversation with {name}'**
  String inboxOpenConversation(String name);

  /// No description provided for @inboxUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} unread message} other{{count} unread messages}}'**
  String inboxUnreadCount(int count);

  /// No description provided for @inboxEyebrow.
  ///
  /// In en, this message translates to:
  /// **'IN TOUCH'**
  String get inboxEyebrow;

  /// No description provided for @inboxMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get inboxMessages;

  /// No description provided for @inboxDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get inboxDirect;

  /// No description provided for @inboxRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get inboxRequests;

  /// No description provided for @inboxSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get inboxSearchHint;

  /// No description provided for @inboxClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation search'**
  String get inboxClearSearch;

  /// No description provided for @inboxRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh conversations.'**
  String get inboxRefreshError;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Find someone to share a concert with and start talking.'**
  String get inboxEmptyBody;

  /// No description provided for @inboxNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests.'**
  String get inboxNoRequests;

  /// No description provided for @inboxNoRequestsBody.
  ///
  /// In en, this message translates to:
  /// **'New message requests will appear here.'**
  String get inboxNoRequestsBody;

  /// No description provided for @socialMatchSend.
  ///
  /// In en, this message translates to:
  /// **'SEND'**
  String get socialMatchSend;

  /// No description provided for @socialMatchPass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get socialMatchPass;

  /// No description provided for @socialMatchSharedListening.
  ///
  /// In en, this message translates to:
  /// **'Your listening has found common ground.'**
  String get socialMatchSharedListening;

  /// No description provided for @socialYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get socialYou;

  /// No description provided for @socialMatchFrequencyNow.
  ///
  /// In en, this message translates to:
  /// **'same frequency, right now'**
  String get socialMatchFrequencyNow;

  /// No description provided for @socialMatchSharedSound.
  ///
  /// In en, this message translates to:
  /// **'SHARED LISTENING'**
  String get socialMatchSharedSound;

  /// No description provided for @socialMatchSameArea.
  ///
  /// In en, this message translates to:
  /// **'SAME AREA'**
  String get socialMatchSameArea;

  /// No description provided for @friendsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load friends. Try again.'**
  String get friendsLoadError;
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
