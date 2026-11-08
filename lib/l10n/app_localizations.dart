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
  /// **'Vibra will delete your Spotify connection, synced artists and genres, listening history and musical matches. Event suggestions will no longer be personalized.'**
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

  /// No description provided for @socialPeopleSection.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get socialPeopleSection;

  /// No description provided for @socialAffinityTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your music matches'**
  String get socialAffinityTitle;

  /// No description provided for @socialRequestsPreview.
  ///
  /// In en, this message translates to:
  /// **'{others, plural, =0{{name} wants to connect with you} =1{{name} and 1 other person want to connect} other{{name} and {others} others want to connect}}'**
  String socialRequestsPreview(String name, int others);

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
  /// **'Vibra reads your Spotify profile, your top artists, tracks and genres from the last ~6 months, and the times of your recent plays. We use them for music statistics, event suggestions and musical affinity. Your Spotify credentials stay encrypted on our servers, never on this device. You can disconnect Spotify and delete this data at any time in Settings.'**
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

  /// No description provided for @matchTierHigh.
  ///
  /// In en, this message translates to:
  /// **'High match'**
  String get matchTierHigh;

  /// No description provided for @matchTierMedium.
  ///
  /// In en, this message translates to:
  /// **'Good match'**
  String get matchTierMedium;

  /// No description provided for @matchTierLow.
  ///
  /// In en, this message translates to:
  /// **'Low match'**
  String get matchTierLow;

  /// No description provided for @eventStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get eventStatusUpcoming;

  /// No description provided for @eventStatusToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get eventStatusToday;

  /// No description provided for @eventStatusSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get eventStatusSoldOut;

  /// No description provided for @eventStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get eventStatusCancelled;

  /// No description provided for @eventStatusPostponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get eventStatusPostponed;

  /// No description provided for @eventStatusPast.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get eventStatusPast;

  /// No description provided for @eventPriceFrom.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String eventPriceFrom(String price);

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// No description provided for @homeSpotifyBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your sound'**
  String get homeSpotifyBannerTitle;

  /// No description provided for @homeUpNext.
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get homeUpNext;

  /// No description provided for @homeSpotifyConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Spotify connected'**
  String get homeSpotifyConnectedTitle;

  /// No description provided for @spotifyConsentSharing.
  ///
  /// In en, this message translates to:
  /// **'People with musical affinity turned on see only your affinity score and the artists and genres you have in common, never your listening history.'**
  String get spotifyConsentSharing;

  /// No description provided for @spotifySyncFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Spotify is connected, but your music hasn\'t loaded yet.'**
  String get spotifySyncFailedTitle;

  /// No description provided for @spotifySyncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry sync'**
  String get spotifySyncRetry;

  /// No description provided for @spotifyRevokedBody.
  ///
  /// In en, this message translates to:
  /// **'Vibra\'s access was removed from your Spotify account, so we disconnected it and deleted the synced data. Connect again to restore your statistics and matches.'**
  String get spotifyRevokedBody;

  /// No description provided for @spotifyRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Spotify is busy right now. Try again in a minute.'**
  String get spotifyRateLimited;

  /// No description provided for @settingsSpotifyDisconnectError.
  ///
  /// In en, this message translates to:
  /// **'Spotify could not be disconnected. Try again.'**
  String get settingsSpotifyDisconnectError;

  /// No description provided for @socialConnectSpotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify to meet people who listen to what you love.'**
  String get socialConnectSpotifyBody;

  /// No description provided for @socialAffinityCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new affinities yet} =1{1 person shares your taste} other{{count} people share your taste}}'**
  String socialAffinityCount(int count);

  /// No description provided for @spotifyAccessNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Spotify hasn\'t enabled Vibra for your account yet. Everything else in Vibra works as usual; try connecting again later.'**
  String get spotifyAccessNotGranted;

  /// No description provided for @spotifyConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Spotify couldn\'t complete the connection. Try again in a moment.'**
  String get spotifyConnectFailed;

  /// No description provided for @settingsSectionMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsSectionMusic;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsSectionHelp;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsDeleteAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get settingsDeleteAccountSub;

  /// No description provided for @settingsEditProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Name, photo, bio and username'**
  String get settingsEditProfileSub;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String settingsVersion(String version, String build);

  /// No description provided for @profileStatEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get profileStatEvents;

  /// No description provided for @profileSpotifyBenefits.
  ///
  /// In en, this message translates to:
  /// **'Stats · Affinity · For you'**
  String get profileSpotifyBenefits;

  /// No description provided for @appearanceAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get appearanceAuto;

  /// No description provided for @affinityCategoryExceptional.
  ///
  /// In en, this message translates to:
  /// **'Exceptional musical affinity'**
  String get affinityCategoryExceptional;

  /// No description provided for @affinityCategoryVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high affinity'**
  String get affinityCategoryVeryHigh;

  /// No description provided for @affinityCategoryHigh.
  ///
  /// In en, this message translates to:
  /// **'High affinity'**
  String get affinityCategoryHigh;

  /// No description provided for @affinityCategoryModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate affinity'**
  String get affinityCategoryModerate;

  /// No description provided for @affinityCategoryLow.
  ///
  /// In en, this message translates to:
  /// **'Different sounds'**
  String get affinityCategoryLow;

  /// No description provided for @affinityCategoryVeryLow.
  ///
  /// In en, this message translates to:
  /// **'New musical worlds'**
  String get affinityCategoryVeryLow;

  /// No description provided for @affinityHeadline.
  ///
  /// In en, this message translates to:
  /// **'{percent}% musical affinity'**
  String affinityHeadline(int percent);

  /// No description provided for @affinitySharedGenres.
  ///
  /// In en, this message translates to:
  /// **'Your shared genres'**
  String get affinitySharedGenres;

  /// No description provided for @affinityTheirGenres.
  ///
  /// In en, this message translates to:
  /// **'Their main genres'**
  String get affinityTheirGenres;

  /// No description provided for @affinityArtistsInCommon.
  ///
  /// In en, this message translates to:
  /// **'Artists in common'**
  String get affinityArtistsInCommon;

  /// No description provided for @affinityWhy.
  ///
  /// In en, this message translates to:
  /// **'Why you match'**
  String get affinityWhy;

  /// No description provided for @affinityQuoteExceptional.
  ///
  /// In en, this message translates to:
  /// **'You seem to hear music the same way.'**
  String get affinityQuoteExceptional;

  /// No description provided for @affinityQuoteVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Your musical tastes have a lot in common.'**
  String get affinityQuoteVeryHigh;

  /// No description provided for @affinityQuoteHigh.
  ///
  /// In en, this message translates to:
  /// **'Your musical tastes have plenty in common.'**
  String get affinityQuoteHigh;

  /// No description provided for @affinityQuoteModerate.
  ///
  /// In en, this message translates to:
  /// **'You share some sounds, and can discover others.'**
  String get affinityQuoteModerate;

  /// No description provided for @affinityQuoteDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Different worlds: a chance to discover new music.'**
  String get affinityQuoteDiscovery;

  /// No description provided for @affinityReasonSharedFamilies.
  ///
  /// In en, this message translates to:
  /// **'You both mostly listen to {genres}.'**
  String affinityReasonSharedFamilies(String genres);

  /// No description provided for @affinityReasonSharedSubgenres.
  ///
  /// In en, this message translates to:
  /// **'You share a love for {genres}.'**
  String affinityReasonSharedSubgenres(String genres);

  /// No description provided for @affinityReasonDifferentSubgenres.
  ///
  /// In en, this message translates to:
  /// **'You both love {genre}, with different subgenres.'**
  String affinityReasonDifferentSubgenres(String genre);

  /// No description provided for @affinityReasonRelatedFamilies.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second} are neighbouring sounds.'**
  String affinityReasonRelatedFamilies(String first, String second);

  /// No description provided for @affinityReasonSharedArtists.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You share 1 favourite artist.} other{You share {count} favourite artists.}}'**
  String affinityReasonSharedArtists(int count);

  /// No description provided for @affinityReasonDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Different tastes: a good way to discover new music.'**
  String get affinityReasonDiscovery;

  /// No description provided for @affinityListSeparator.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get affinityListSeparator;

  /// No description provided for @genreFamilyHipHop.
  ///
  /// In en, this message translates to:
  /// **'Hip-Hop'**
  String get genreFamilyHipHop;

  /// No description provided for @genreFamilyRnb.
  ///
  /// In en, this message translates to:
  /// **'R&B'**
  String get genreFamilyRnb;

  /// No description provided for @genreFamilyElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get genreFamilyElectronic;

  /// No description provided for @genreFamilyRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get genreFamilyRock;

  /// No description provided for @genreFamilyMetal.
  ///
  /// In en, this message translates to:
  /// **'Metal'**
  String get genreFamilyMetal;

  /// No description provided for @genreFamilyPunk.
  ///
  /// In en, this message translates to:
  /// **'Punk'**
  String get genreFamilyPunk;

  /// No description provided for @genreFamilyPop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get genreFamilyPop;

  /// No description provided for @genreFamilyJazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get genreFamilyJazz;

  /// No description provided for @genreFamilyBlues.
  ///
  /// In en, this message translates to:
  /// **'Blues'**
  String get genreFamilyBlues;

  /// No description provided for @genreFamilyReggae.
  ///
  /// In en, this message translates to:
  /// **'Reggae'**
  String get genreFamilyReggae;

  /// No description provided for @genreFamilyLatin.
  ///
  /// In en, this message translates to:
  /// **'Latin'**
  String get genreFamilyLatin;

  /// No description provided for @genreFamilyAfro.
  ///
  /// In en, this message translates to:
  /// **'Afro'**
  String get genreFamilyAfro;

  /// No description provided for @genreFamilyCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get genreFamilyCountry;

  /// No description provided for @genreFamilyFolk.
  ///
  /// In en, this message translates to:
  /// **'Folk'**
  String get genreFamilyFolk;

  /// No description provided for @genreFamilyClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get genreFamilyClassical;

  /// No description provided for @genreFamilySoundtrack.
  ///
  /// In en, this message translates to:
  /// **'Soundtracks'**
  String get genreFamilySoundtrack;

  /// No description provided for @genreFamilyGospel.
  ///
  /// In en, this message translates to:
  /// **'Gospel & Christian'**
  String get genreFamilyGospel;

  /// No description provided for @genreFamilyWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get genreFamilyWorld;

  /// No description provided for @musicGenresTitle.
  ///
  /// In en, this message translates to:
  /// **'Your genres'**
  String get musicGenresTitle;

  /// No description provided for @musicGenresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the genres you love. They help us find people with related taste, with or without Spotify.'**
  String get musicGenresSubtitle;

  /// No description provided for @musicGenresSpotifyNote.
  ///
  /// In en, this message translates to:
  /// **'Spotify is connected: these genres are added to the ones from your listening.'**
  String get musicGenresSpotifyNote;

  /// No description provided for @musicGenresSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a genre'**
  String get musicGenresSearchHint;

  /// No description provided for @musicGenresNoResults.
  ///
  /// In en, this message translates to:
  /// **'No genre found'**
  String get musicGenresNoResults;

  /// No description provided for @musicGenresSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No genre selected} =1{1 genre selected} other{{count} genres selected}}'**
  String musicGenresSelected(int count);

  /// No description provided for @musicGenresYourPicks.
  ///
  /// In en, this message translates to:
  /// **'Your picks'**
  String get musicGenresYourPicks;

  /// No description provided for @musicGenresLevelLike.
  ///
  /// In en, this message translates to:
  /// **'I like it'**
  String get musicGenresLevelLike;

  /// No description provided for @musicGenresLevelMuch.
  ///
  /// In en, this message translates to:
  /// **'A lot'**
  String get musicGenresLevelMuch;

  /// No description provided for @musicGenresLevelLove.
  ///
  /// In en, this message translates to:
  /// **'I love it'**
  String get musicGenresLevelLove;

  /// No description provided for @musicGenresIntensityHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a picked genre to change how much you like it.'**
  String get musicGenresIntensityHint;

  /// No description provided for @musicGenresRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {genre}'**
  String musicGenresRemove(String genre);

  /// No description provided for @musicGenresLimit.
  ///
  /// In en, this message translates to:
  /// **'You can pick up to 30 genres.'**
  String get musicGenresLimit;

  /// No description provided for @musicGenresMatching.
  ///
  /// In en, this message translates to:
  /// **'Show me to people with related taste'**
  String get musicGenresMatching;

  /// No description provided for @musicGenresMatchingBody.
  ///
  /// In en, this message translates to:
  /// **'They only see your affinity score and the genres and artists you share.'**
  String get musicGenresMatchingBody;

  /// No description provided for @musicGenresSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get musicGenresSave;

  /// No description provided for @musicGenresSaved.
  ///
  /// In en, this message translates to:
  /// **'Genres saved. Your affinities are being updated.'**
  String get musicGenresSaved;

  /// No description provided for @musicGenresSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your genres. Try again.'**
  String get musicGenresSaveError;

  /// No description provided for @musicGenresLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your genres.'**
  String get musicGenresLoadError;

  /// No description provided for @musicGenresEntry.
  ///
  /// In en, this message translates to:
  /// **'Favourite genres'**
  String get musicGenresEntry;

  /// No description provided for @musicGenresEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Pick the genres you love, even without Spotify'**
  String get musicGenresEntrySub;

  /// No description provided for @socialAffinityPickGenres.
  ///
  /// In en, this message translates to:
  /// **'Or pick your genres'**
  String get socialAffinityPickGenres;

  /// No description provided for @socialAffinityPickGenresBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the genres you love to meet people with related taste.'**
  String get socialAffinityPickGenresBody;

  /// No description provided for @privacyMusicAffinity.
  ///
  /// In en, this message translates to:
  /// **'Music affinity'**
  String get privacyMusicAffinity;

  /// No description provided for @privacyMusicAffinityBody.
  ///
  /// In en, this message translates to:
  /// **'Use your Spotify data and the genres you pick for suggestions and affinity.'**
  String get privacyMusicAffinityBody;

  /// No description provided for @musicalDnaTitle.
  ///
  /// In en, this message translates to:
  /// **'Musical DNA'**
  String get musicalDnaTitle;

  /// No description provided for @musicalDnaEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your musical identity'**
  String get musicalDnaEyebrow;

  /// No description provided for @musicalDnaUserTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Musical DNA'**
  String musicalDnaUserTitle(String name);

  /// No description provided for @musicalDnaUserEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Musical identity'**
  String get musicalDnaUserEyebrow;

  /// No description provided for @musicalDnaDistribution.
  ///
  /// In en, this message translates to:
  /// **'Genre distribution'**
  String get musicalDnaDistribution;

  /// No description provided for @musicalDnaDistributionSub.
  ///
  /// In en, this message translates to:
  /// **'How your taste divides across genre families'**
  String get musicalDnaDistributionSub;

  /// No description provided for @musicalDnaArtistsVia.
  ///
  /// In en, this message translates to:
  /// **'Through {artists}'**
  String musicalDnaArtistsVia(String artists);

  /// No description provided for @musicalDnaDiversity.
  ///
  /// In en, this message translates to:
  /// **'Diversity'**
  String get musicalDnaDiversity;

  /// No description provided for @musicalDnaDiversityFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get musicalDnaDiversityFocused;

  /// No description provided for @musicalDnaDiversityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get musicalDnaDiversityBalanced;

  /// No description provided for @musicalDnaDiversityEclectic.
  ///
  /// In en, this message translates to:
  /// **'Eclectic'**
  String get musicalDnaDiversityEclectic;

  /// No description provided for @musicalDnaDiversityFocusedBody.
  ///
  /// In en, this message translates to:
  /// **'Your identity lives in a few close sounds.'**
  String get musicalDnaDiversityFocusedBody;

  /// No description provided for @musicalDnaDiversityBalancedBody.
  ///
  /// In en, this message translates to:
  /// **'A clear core, with room for other worlds.'**
  String get musicalDnaDiversityBalancedBody;

  /// No description provided for @musicalDnaDiversityEclecticBody.
  ///
  /// In en, this message translates to:
  /// **'Your taste moves freely across very different worlds.'**
  String get musicalDnaDiversityEclecticBody;

  /// No description provided for @musicalDnaDiversityCounts.
  ///
  /// In en, this message translates to:
  /// **'{families} families · {subgenres} subgenres'**
  String musicalDnaDiversityCounts(String families, String subgenres);

  /// No description provided for @musicalDnaEvolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get musicalDnaEvolution;

  /// No description provided for @musicalDnaEvolutionSub.
  ///
  /// In en, this message translates to:
  /// **'How your DNA changes as your listening does'**
  String get musicalDnaEvolutionSub;

  /// No description provided for @musicalDnaEvolutionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tracking since {date}. Changes show up here as your listening evolves.'**
  String musicalDnaEvolutionEmpty(String date);

  /// No description provided for @musicalDnaShiftSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String musicalDnaShiftSince(String date);

  /// No description provided for @musicalDnaNoShift.
  ///
  /// In en, this message translates to:
  /// **'Stable: no family moved by more than 3 points.'**
  String get musicalDnaNoShift;

  /// No description provided for @musicalDnaShiftSemantics.
  ///
  /// In en, this message translates to:
  /// **'{family}, from {from} to {to} percent'**
  String musicalDnaShiftSemantics(String family, String from, String to);

  /// No description provided for @musicalDnaSources.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get musicalDnaSources;

  /// No description provided for @musicalDnaSourceArtists.
  ///
  /// In en, this message translates to:
  /// **'{classified} of your top {total} Spotify artists (last 6 months)'**
  String musicalDnaSourceArtists(String classified, String total);

  /// No description provided for @musicalDnaSourceSpotifyGenres.
  ///
  /// In en, this message translates to:
  /// **'The genres of your top Spotify artists (last 6 months)'**
  String get musicalDnaSourceSpotifyGenres;

  /// No description provided for @musicalDnaSourceTracks.
  ///
  /// In en, this message translates to:
  /// **'Your top {count} Spotify tracks'**
  String musicalDnaSourceTracks(String count);

  /// No description provided for @musicalDnaSourceGenres.
  ///
  /// In en, this message translates to:
  /// **'{count} genres you picked'**
  String musicalDnaSourceGenres(String count);

  /// No description provided for @musicalDnaEditGenres.
  ///
  /// In en, this message translates to:
  /// **'Edit your genres'**
  String get musicalDnaEditGenres;

  /// No description provided for @musicalDnaVisibility.
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get musicalDnaVisibility;

  /// No description provided for @musicalDnaVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get musicalDnaVisibilityPublic;

  /// No description provided for @musicalDnaVisibilityMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get musicalDnaVisibilityMatches;

  /// No description provided for @musicalDnaVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get musicalDnaVisibilityPrivate;

  /// No description provided for @musicalDnaVisibilityPublicBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone on Vibra can see your Musical DNA on your profile.'**
  String get musicalDnaVisibilityPublicBody;

  /// No description provided for @musicalDnaVisibilityMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Only people you have a musical affinity with or are connected to.'**
  String get musicalDnaVisibilityMatchesBody;

  /// No description provided for @musicalDnaVisibilityPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Only you can see it. It still shapes your suggestions.'**
  String get musicalDnaVisibilityPrivateBody;

  /// No description provided for @musicalDnaVisibilityError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your choice. Try again.'**
  String get musicalDnaVisibilityError;

  /// No description provided for @musicalDnaEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Musical DNA yet'**
  String get musicalDnaEmptyTitle;

  /// No description provided for @musicalDnaEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify or pick a few genres you love, and your DNA builds itself from them.'**
  String get musicalDnaEmptyBody;

  /// No description provided for @musicalDnaPickGenres.
  ///
  /// In en, this message translates to:
  /// **'Pick genres'**
  String get musicalDnaPickGenres;

  /// No description provided for @musicalDnaLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your Musical DNA couldn\'t be loaded.'**
  String get musicalDnaLoadError;

  /// No description provided for @musicalDnaUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String musicalDnaUpdated(String date);

  /// No description provided for @musicalDnaFamilySemantics.
  ///
  /// In en, this message translates to:
  /// **'{family}, {percent} percent'**
  String musicalDnaFamilySemantics(String family, String percent);

  /// No description provided for @musicalDnaProfileTile.
  ///
  /// In en, this message translates to:
  /// **'Musical DNA'**
  String get musicalDnaProfileTile;

  /// No description provided for @musicalDnaProfileTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your genres, diversity and how they evolve'**
  String get musicalDnaProfileTileSubtitle;

  /// No description provided for @musicalDnaSeeFull.
  ///
  /// In en, this message translates to:
  /// **'See full DNA'**
  String get musicalDnaSeeFull;

  /// No description provided for @affinityReasonCommonGround.
  ///
  /// In en, this message translates to:
  /// **'You both listen to {genres}, in different amounts.'**
  String affinityReasonCommonGround(String genres);

  /// No description provided for @affinityReasonBothEclectic.
  ///
  /// In en, this message translates to:
  /// **'You\'re both eclectic listeners, moving across very different genres.'**
  String get affinityReasonBothEclectic;

  /// No description provided for @affinityReasonBothFocused.
  ///
  /// In en, this message translates to:
  /// **'You both stay close to your core sound.'**
  String get affinityReasonBothFocused;

  /// No description provided for @affinityReasonDiversityContrast.
  ///
  /// In en, this message translates to:
  /// **'One of you explores widely, the other stays focused: plenty to share.'**
  String get affinityReasonDiversityContrast;

  /// No description provided for @affinityHeadlineSentence.
  ///
  /// In en, this message translates to:
  /// **'You have {percent}% musical affinity.'**
  String affinityHeadlineSentence(int percent);

  /// No description provided for @sameFrequencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Same Frequency'**
  String get sameFrequencyTitle;

  /// No description provided for @sameFrequencyHeadline.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the same frequency.'**
  String get sameFrequencyHeadline;

  /// No description provided for @sameFrequencyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No strong musical connections yet.} =1{You\'ve discovered 1 person with a strong musical connection.} other{You\'ve discovered {count} people with a strong musical connection.}}'**
  String sameFrequencyCount(int count);

  /// No description provided for @sameFrequencyTabForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get sameFrequencyTabForYou;

  /// No description provided for @sameFrequencyTabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get sameFrequencyTabSaved;

  /// No description provided for @sameFrequencyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No one on your frequency yet'**
  String get sameFrequencyEmptyTitle;

  /// No description provided for @sameFrequencyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'People appear here as Vibra finds others who share your sound. Pick more genres or sync Spotify to widen your signal.'**
  String get sameFrequencyEmptyBody;

  /// No description provided for @sameFrequencySavedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved profiles'**
  String get sameFrequencySavedEmptyTitle;

  /// No description provided for @sameFrequencySavedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save people you want to come back to. They stay here until you remove them.'**
  String get sameFrequencySavedEmptyBody;

  /// No description provided for @sameFrequencySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get sameFrequencySave;

  /// No description provided for @sameFrequencySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get sameFrequencySaved;

  /// No description provided for @sameFrequencySaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your saved profiles. Try again.'**
  String get sameFrequencySaveError;

  /// No description provided for @sameFrequencyWhy.
  ///
  /// In en, this message translates to:
  /// **'Why you\'re on the same frequency'**
  String get sameFrequencyWhy;

  /// No description provided for @sameFrequencyReasonDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'You both recently discovered {artists}.'**
  String sameFrequencyReasonDiscoveries(String artists);

  /// No description provided for @sameFrequencyReasonDirection.
  ///
  /// In en, this message translates to:
  /// **'You\'re both moving toward {genres}.'**
  String sameFrequencyReasonDirection(String genres);

  /// No description provided for @sameFrequencyReasonEvent.
  ///
  /// In en, this message translates to:
  /// **'You\'re both going to {event} · {date}.'**
  String sameFrequencyReasonEvent(String event, String date);

  /// No description provided for @sameFrequencyReasonEvents.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You saved 1 of the same upcoming events.} other{You saved {count} of the same upcoming events.}}'**
  String sameFrequencyReasonEvents(int count);

  /// No description provided for @sameFrequencyDiscoverArtists.
  ///
  /// In en, this message translates to:
  /// **'Discover shared artists'**
  String get sameFrequencyDiscoverArtists;

  /// No description provided for @sameFrequencySharedArtistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Artists you and {name} share'**
  String sameFrequencySharedArtistsTitle(String name);

  /// No description provided for @sameFrequencyFindEvents.
  ///
  /// In en, this message translates to:
  /// **'Find events'**
  String get sameFrequencyFindEvents;

  /// No description provided for @sameFrequencyEventsOptIn.
  ///
  /// In en, this message translates to:
  /// **'Compare saved events'**
  String get sameFrequencyEventsOptIn;

  /// No description provided for @sameFrequencyEventsOptInBody.
  ///
  /// In en, this message translates to:
  /// **'Find people going to the same concerts. It only works with people who turned this on too; otherwise your saved events stay private.'**
  String get sameFrequencyEventsOptInBody;

  /// No description provided for @sameFrequencyEntryBody.
  ///
  /// In en, this message translates to:
  /// **'People who share a real musical connection with you'**
  String get sameFrequencyEntryBody;

  /// No description provided for @sameFrequencyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Same Frequency couldn\'t be loaded.'**
  String get sameFrequencyLoadError;

  /// No description provided for @sameFrequencyPersonSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {percent} percent musical affinity'**
  String sameFrequencyPersonSemantics(String name, String percent);

  /// No description provided for @musicRadarTitle.
  ///
  /// In en, this message translates to:
  /// **'Music Radar'**
  String get musicRadarTitle;

  /// No description provided for @musicRadarHeadline.
  ///
  /// In en, this message translates to:
  /// **'People near you who share your musical taste.'**
  String get musicRadarHeadline;

  /// No description provided for @musicRadarCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No compatible people within {distance} km yet.} =1{1 compatible person within {distance} km.} other{{count} compatible people within {distance} km.}}'**
  String musicRadarCount(int count, int distance);

  /// No description provided for @musicRadarAreaSound.
  ///
  /// In en, this message translates to:
  /// **'The sound of your area'**
  String get musicRadarAreaSound;

  /// No description provided for @musicRadarAreaSoundSub.
  ///
  /// In en, this message translates to:
  /// **'What people nearby listen to most'**
  String get musicRadarAreaSoundSub;

  /// No description provided for @musicRadarAreaTooFew.
  ///
  /// In en, this message translates to:
  /// **'Shown once enough people nearby use the radar.'**
  String get musicRadarAreaTooFew;

  /// No description provided for @musicRadarPeople.
  ///
  /// In en, this message translates to:
  /// **'Compatible profiles'**
  String get musicRadarPeople;

  /// No description provided for @musicRadarEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events for your sound'**
  String get musicRadarEvents;

  /// No description provided for @musicRadarEventYourArtist.
  ///
  /// In en, this message translates to:
  /// **'One of your artists'**
  String get musicRadarEventYourArtist;

  /// No description provided for @musicRadarEventSharedArtist.
  ///
  /// In en, this message translates to:
  /// **'An artist you share with people nearby'**
  String get musicRadarEventSharedArtist;

  /// No description provided for @musicRadarEventYourGenre.
  ///
  /// In en, this message translates to:
  /// **'Your genres'**
  String get musicRadarEventYourGenre;

  /// No description provided for @musicRadarEventAreaGenre.
  ///
  /// In en, this message translates to:
  /// **'Popular in your area'**
  String get musicRadarEventAreaGenre;

  /// No description provided for @musicRadarIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover people nearby through music'**
  String get musicRadarIntroTitle;

  /// No description provided for @musicRadarIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Music Radar shows people around you with a similar taste. It stays off until you turn it on.'**
  String get musicRadarIntroBody;

  /// No description provided for @musicRadarPrivacy1.
  ///
  /// In en, this message translates to:
  /// **'Nobody sees your location or your distance: only that you\'re within their radius.'**
  String get musicRadarPrivacy1;

  /// No description provided for @musicRadarPrivacy2.
  ///
  /// In en, this message translates to:
  /// **'Your position is rounded to an area of about 5 km (or 20 km) and moves at most every 6 hours.'**
  String get musicRadarPrivacy2;

  /// No description provided for @musicRadarPrivacy3.
  ///
  /// In en, this message translates to:
  /// **'Hide your profile, change the distance or turn the radar off at any time.'**
  String get musicRadarPrivacy3;

  /// No description provided for @musicRadarTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on Music Radar'**
  String get musicRadarTurnOn;

  /// No description provided for @musicRadarLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location needed'**
  String get musicRadarLocationTitle;

  /// No description provided for @musicRadarLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Music Radar uses your approximate location. Turn on location in Privacy controls, then come back.'**
  String get musicRadarLocationBody;

  /// No description provided for @musicRadarOpenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Open privacy controls'**
  String get musicRadarOpenPrivacy;

  /// No description provided for @musicRadarMatchingNote.
  ///
  /// In en, this message translates to:
  /// **'Turn on Music affinity in Privacy controls to see compatible people.'**
  String get musicRadarMatchingNote;

  /// No description provided for @musicRadarSettings.
  ///
  /// In en, this message translates to:
  /// **'Radar settings'**
  String get musicRadarSettings;

  /// No description provided for @musicRadarEnabled.
  ///
  /// In en, this message translates to:
  /// **'Music Radar'**
  String get musicRadarEnabled;

  /// No description provided for @musicRadarVisible.
  ///
  /// In en, this message translates to:
  /// **'Show me on the radar'**
  String get musicRadarVisible;

  /// No description provided for @musicRadarVisibleBody.
  ///
  /// In en, this message translates to:
  /// **'When off, you can still look around, but nobody sees you.'**
  String get musicRadarVisibleBody;

  /// No description provided for @musicRadarDistance.
  ///
  /// In en, this message translates to:
  /// **'Discovery distance'**
  String get musicRadarDistance;

  /// No description provided for @musicRadarDistanceValue.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String musicRadarDistanceValue(int km);

  /// No description provided for @musicRadarPrecision.
  ///
  /// In en, this message translates to:
  /// **'Location precision'**
  String get musicRadarPrecision;

  /// No description provided for @musicRadarPrecisionArea.
  ///
  /// In en, this message translates to:
  /// **'Area (~5 km)'**
  String get musicRadarPrecisionArea;

  /// No description provided for @musicRadarPrecisionRegion.
  ///
  /// In en, this message translates to:
  /// **'Region (~20 km)'**
  String get musicRadarPrecisionRegion;

  /// No description provided for @musicRadarPrecisionBody.
  ///
  /// In en, this message translates to:
  /// **'How roughly others are placed relative to you. Your exact location is never shared.'**
  String get musicRadarPrecisionBody;

  /// No description provided for @musicRadarSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the setting. Try again.'**
  String get musicRadarSaveError;

  /// No description provided for @musicRadarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Music Radar couldn\'t be loaded.'**
  String get musicRadarLoadError;

  /// No description provided for @musicRadarEntryBody.
  ///
  /// In en, this message translates to:
  /// **'People near you who share your taste'**
  String get musicRadarEntryBody;

  /// No description provided for @musicRadarEmptyPeople.
  ///
  /// In en, this message translates to:
  /// **'No one compatible nearby right now. Try a larger distance or check back later.'**
  String get musicRadarEmptyPeople;

  /// No description provided for @communitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get communitiesTitle;

  /// No description provided for @communitiesEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Genres, artists and scenes you love'**
  String get communitiesEntryBody;

  /// No description provided for @communitiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search communities or artists'**
  String get communitiesSearchHint;

  /// No description provided for @communitiesForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get communitiesForYou;

  /// No description provided for @communitiesForYouSub.
  ///
  /// In en, this message translates to:
  /// **'Based on your musical profile'**
  String get communitiesForYouSub;

  /// No description provided for @communitiesMine.
  ///
  /// In en, this message translates to:
  /// **'Your communities'**
  String get communitiesMine;

  /// No description provided for @communitiesExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get communitiesExplore;

  /// No description provided for @communitiesEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'No communities match your search.'**
  String get communitiesEmptySearch;

  /// No description provided for @communitiesRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Based on your musical profile, you might enjoy {name}.'**
  String communitiesRecommendation(String name);

  /// No description provided for @communitiesReasonArtist.
  ///
  /// In en, this message translates to:
  /// **'{artist} is one of your top artists.'**
  String communitiesReasonArtist(String artist);

  /// No description provided for @communitiesReasonGenre.
  ///
  /// In en, this message translates to:
  /// **'{genre} is {percent}% of your Musical DNA.'**
  String communitiesReasonGenre(String genre, int percent);

  /// No description provided for @communitiesStartArtist.
  ///
  /// In en, this message translates to:
  /// **'Start the {artist} community'**
  String communitiesStartArtist(String artist);

  /// No description provided for @communitiesStartArtistBody.
  ///
  /// In en, this message translates to:
  /// **'One of your top artists has no community yet.'**
  String get communitiesStartArtistBody;

  /// No description provided for @communitiesMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String communitiesMembers(int count);

  /// No description provided for @communitiesOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get communitiesOfficial;

  /// No description provided for @communitiesKindGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get communitiesKindGenre;

  /// No description provided for @communitiesKindArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get communitiesKindArtist;

  /// No description provided for @communitiesKindInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get communitiesKindInterest;

  /// No description provided for @communitiesJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get communitiesJoin;

  /// No description provided for @communitiesJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get communitiesJoined;

  /// No description provided for @communitiesLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get communitiesLeave;

  /// No description provided for @communitiesLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String communitiesLeaveConfirm(String name);

  /// No description provided for @communitiesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a community'**
  String get communitiesCreate;

  /// No description provided for @communitiesCreateName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get communitiesCreateName;

  /// No description provided for @communitiesCreateDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get communitiesCreateDescription;

  /// No description provided for @communitiesCreateArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get communitiesCreateArtist;

  /// No description provided for @communitiesCreateGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get communitiesCreateGenre;

  /// No description provided for @communitiesCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get communitiesCreateAction;

  /// No description provided for @communitiesTabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get communitiesTabPosts;

  /// No description provided for @communitiesTabDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get communitiesTabDiscussions;

  /// No description provided for @communitiesTabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get communitiesTabEvents;

  /// No description provided for @communitiesTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get communitiesTabMembers;

  /// No description provided for @communitiesNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get communitiesNewPost;

  /// No description provided for @communitiesComposerPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get communitiesComposerPost;

  /// No description provided for @communitiesComposerDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get communitiesComposerDiscussion;

  /// No description provided for @communitiesComposerMusic.
  ///
  /// In en, this message translates to:
  /// **'Share music'**
  String get communitiesComposerMusic;

  /// No description provided for @communitiesComposerBodyHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get communitiesComposerBodyHint;

  /// No description provided for @communitiesComposerTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Discussion topic'**
  String get communitiesComposerTitleHint;

  /// No description provided for @communitiesComposerLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Spotify, Apple Music, YouTube, SoundCloud or Bandcamp link'**
  String get communitiesComposerLinkHint;

  /// No description provided for @communitiesComposerTrackHint.
  ///
  /// In en, this message translates to:
  /// **'Track or album (optional)'**
  String get communitiesComposerTrackHint;

  /// No description provided for @communitiesComposerArtistHint.
  ///
  /// In en, this message translates to:
  /// **'Artist (optional)'**
  String get communitiesComposerArtistHint;

  /// No description provided for @communitiesPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get communitiesPublish;

  /// No description provided for @communitiesJoinToPost.
  ///
  /// In en, this message translates to:
  /// **'Join to post, comment and react.'**
  String get communitiesJoinToPost;

  /// No description provided for @communitiesEmptyFeed.
  ///
  /// In en, this message translates to:
  /// **'No posts yet. Start the conversation.'**
  String get communitiesEmptyFeed;

  /// No description provided for @communitiesEmptyDiscussions.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet.'**
  String get communitiesEmptyDiscussions;

  /// No description provided for @communitiesEmptyEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events for this community.'**
  String get communitiesEmptyEvents;

  /// No description provided for @communitiesComments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Comment} =1{1 comment} other{{count} comments}}'**
  String communitiesComments(int count);

  /// No description provided for @communitiesCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get communitiesCommentHint;

  /// No description provided for @communitiesEmptyComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get communitiesEmptyComments;

  /// No description provided for @communitiesOpenMusic.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get communitiesOpenMusic;

  /// No description provided for @communitiesHeld.
  ///
  /// In en, this message translates to:
  /// **'Hidden while moderators review reports'**
  String get communitiesHeld;

  /// No description provided for @communitiesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get communitiesDelete;

  /// No description provided for @communitiesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove (moderator)'**
  String get communitiesRemove;

  /// No description provided for @communitiesRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get communitiesRestore;

  /// No description provided for @communitiesBan.
  ///
  /// In en, this message translates to:
  /// **'Ban from community'**
  String get communitiesBan;

  /// No description provided for @communitiesBanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Ban {name} from this community?'**
  String communitiesBanConfirm(String name);

  /// No description provided for @communitiesMakeModerator.
  ///
  /// In en, this message translates to:
  /// **'Make moderator'**
  String get communitiesMakeModerator;

  /// No description provided for @communitiesRemoveModerator.
  ///
  /// In en, this message translates to:
  /// **'Remove moderator'**
  String get communitiesRemoveModerator;

  /// No description provided for @communitiesRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get communitiesRoleOwner;

  /// No description provided for @communitiesRoleModerator.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get communitiesRoleModerator;

  /// No description provided for @communitiesModeration.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get communitiesModeration;

  /// No description provided for @communitiesModerationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review.'**
  String get communitiesModerationEmpty;

  /// No description provided for @communitiesReports.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 report} other{{count} reports}}'**
  String communitiesReports(int count);

  /// No description provided for @communitiesReported.
  ///
  /// In en, this message translates to:
  /// **'Thanks, moderators will review it.'**
  String get communitiesReported;

  /// No description provided for @communitiesError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get communitiesError;

  /// No description provided for @communitiesErrorRate.
  ///
  /// In en, this message translates to:
  /// **'You\'re going too fast. Wait a moment.'**
  String get communitiesErrorRate;

  /// No description provided for @communitiesErrorSpam.
  ///
  /// In en, this message translates to:
  /// **'This looks like spam: too many links, a suspicious link or a repeat.'**
  String get communitiesErrorSpam;

  /// No description provided for @communitiesErrorBanned.
  ///
  /// In en, this message translates to:
  /// **'You\'re banned from this community.'**
  String get communitiesErrorBanned;

  /// No description provided for @communitiesErrorLink.
  ///
  /// In en, this message translates to:
  /// **'Use a Spotify, Apple Music, YouTube, SoundCloud or Bandcamp link.'**
  String get communitiesErrorLink;

  /// No description provided for @communitiesErrorExists.
  ///
  /// In en, this message translates to:
  /// **'A community for this artist already exists.'**
  String get communitiesErrorExists;

  /// No description provided for @communitiesErrorLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit.'**
  String get communitiesErrorLimit;

  /// No description provided for @communitiesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Communities couldn\'t be loaded.'**
  String get communitiesLoadError;

  /// No description provided for @sameFrequencyReasonCommunities.
  ///
  /// In en, this message translates to:
  /// **'You\'re both in {communities}.'**
  String sameFrequencyReasonCommunities(String communities);

  /// No description provided for @musicRadarCommunities.
  ///
  /// In en, this message translates to:
  /// **'Communities for your area\'s sound'**
  String get musicRadarCommunities;

  /// No description provided for @circlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get circlesTitle;

  /// No description provided for @circlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small groups for the music you love'**
  String get circlesSubtitle;

  /// No description provided for @circlesInvitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get circlesInvitations;

  /// No description provided for @circlesInvitedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you'**
  String circlesInvitedBy(String name);

  /// No description provided for @circlesAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get circlesAccept;

  /// No description provided for @circlesDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get circlesDecline;

  /// No description provided for @circlesInviteDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get circlesInviteDeclined;

  /// No description provided for @circlesSuggested.
  ///
  /// In en, this message translates to:
  /// **'VIBRA suggests'**
  String get circlesSuggested;

  /// No description provided for @circlesSuggestionGenre.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{A circle of {count} people who share {genre}.}}'**
  String circlesSuggestionGenre(int count, String genre);

  /// No description provided for @circlesSuggestionArtist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{A circle of {count} people who all listen to {artist}.}}'**
  String circlesSuggestionArtist(int count, String artist);

  /// No description provided for @circlesSuggestionConsent.
  ///
  /// In en, this message translates to:
  /// **'Each person gets an invitation and decides whether to join.'**
  String get circlesSuggestionConsent;

  /// No description provided for @circlesCreateAndInvite.
  ///
  /// In en, this message translates to:
  /// **'Create and invite'**
  String get circlesCreateAndInvite;

  /// No description provided for @circlesSuggestionName.
  ///
  /// In en, this message translates to:
  /// **'{topic} Circle'**
  String circlesSuggestionName(String topic);

  /// No description provided for @circlesInvitesSent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Circle created. No invitations could be sent.} =1{Circle created. 1 invitation sent.} other{Circle created. {count} invitations sent.}}'**
  String circlesInvitesSent(int count);

  /// No description provided for @circlesMine.
  ///
  /// In en, this message translates to:
  /// **'Your circles'**
  String get circlesMine;

  /// No description provided for @circlesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No circles yet'**
  String get circlesEmptyTitle;

  /// No description provided for @circlesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a small group around a genre, an artist or a concert, and invite people you know.'**
  String get circlesEmptyBody;

  /// No description provided for @circlesCreate.
  ///
  /// In en, this message translates to:
  /// **'New circle'**
  String get circlesCreate;

  /// No description provided for @circlesBasisGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get circlesBasisGenre;

  /// No description provided for @circlesBasisArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get circlesBasisArtist;

  /// No description provided for @circlesBasisConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert'**
  String get circlesBasisConcert;

  /// No description provided for @circlesBasisInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get circlesBasisInterest;

  /// No description provided for @circlesBasisActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get circlesBasisActivity;

  /// No description provided for @circlesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get circlesName;

  /// No description provided for @circlesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get circlesDescription;

  /// No description provided for @circlesTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get circlesTopic;

  /// No description provided for @circlesNoSavedEvents.
  ///
  /// In en, this message translates to:
  /// **'Save an event first to start a circle around it.'**
  String get circlesNoSavedEvents;

  /// No description provided for @circlesCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get circlesCreateAction;

  /// No description provided for @circlesMembers.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} members'**
  String circlesMembers(int count, int max);

  /// No description provided for @circlesTabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get circlesTabChat;

  /// No description provided for @circlesTabPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get circlesTabPlaylist;

  /// No description provided for @circlesTabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get circlesTabEvents;

  /// No description provided for @circlesTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get circlesTabMembers;

  /// No description provided for @circlesMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message the circle'**
  String get circlesMessageHint;

  /// No description provided for @circlesChatEmpty.
  ///
  /// In en, this message translates to:
  /// **'Say hi to your circle.'**
  String get circlesChatEmpty;

  /// No description provided for @circlesPlaylistEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tracks yet. Add the first one.'**
  String get circlesPlaylistEmpty;

  /// No description provided for @circlesAddTrack.
  ///
  /// In en, this message translates to:
  /// **'Add a track'**
  String get circlesAddTrack;

  /// No description provided for @circlesEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No shared events yet.'**
  String get circlesEventsEmpty;

  /// No description provided for @circlesShareEvent.
  ///
  /// In en, this message translates to:
  /// **'Share an event'**
  String get circlesShareEvent;

  /// No description provided for @circlesInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite people'**
  String get circlesInvite;

  /// No description provided for @circlesInviteHint.
  ///
  /// In en, this message translates to:
  /// **'You can invite your connections and people you have a musical match with. They decide whether to join.'**
  String get circlesInviteHint;

  /// No description provided for @circlesInviteNone.
  ///
  /// In en, this message translates to:
  /// **'No one else to invite right now.'**
  String get circlesInviteNone;

  /// No description provided for @circlesInviteSend.
  ///
  /// In en, this message translates to:
  /// **'Send invitations'**
  String get circlesInviteSend;

  /// No description provided for @circlesPending.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get circlesPending;

  /// No description provided for @circlesRevoke.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation'**
  String get circlesRevoke;

  /// No description provided for @circlesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get circlesAdmin;

  /// No description provided for @circlesMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get circlesMakeAdmin;

  /// No description provided for @circlesRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from circle'**
  String get circlesRemoveMember;

  /// No description provided for @circlesMute.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get circlesMute;

  /// No description provided for @circlesUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute notifications'**
  String get circlesUnmute;

  /// No description provided for @circlesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit circle'**
  String get circlesEdit;

  /// No description provided for @circlesLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave circle'**
  String get circlesLeave;

  /// No description provided for @circlesLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String circlesLeaveConfirm(String name);

  /// No description provided for @circlesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get circlesSave;

  /// No description provided for @circlesError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get circlesError;

  /// No description provided for @circlesErrorFull.
  ///
  /// In en, this message translates to:
  /// **'This circle is full.'**
  String get circlesErrorFull;

  /// No description provided for @circlesErrorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You can only invite your connections or people you have a musical match with.'**
  String get circlesErrorNotAllowed;

  /// No description provided for @circlesErrorDeclined.
  ///
  /// In en, this message translates to:
  /// **'This person declined recently. Try again later.'**
  String get circlesErrorDeclined;

  /// No description provided for @circlesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Circles couldn\'t be loaded.'**
  String get circlesLoadError;

  /// No description provided for @circlesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get circlesRemove;

  /// No description provided for @concertTitle.
  ///
  /// In en, this message translates to:
  /// **'Concert Finder'**
  String get concertTitle;

  /// No description provided for @concertHeadline.
  ///
  /// In en, this message translates to:
  /// **'You might enjoy these upcoming events.'**
  String get concertHeadline;

  /// No description provided for @concertWhy.
  ///
  /// In en, this message translates to:
  /// **'Why it\'s recommended'**
  String get concertWhy;

  /// No description provided for @concertReasonTopArtist.
  ///
  /// In en, this message translates to:
  /// **'{artist} is #{rank} in your top artists.'**
  String concertReasonTopArtist(String artist, int rank);

  /// No description provided for @concertReasonTrackArtist.
  ///
  /// In en, this message translates to:
  /// **'{artist} is on your most-played tracks.'**
  String concertReasonTrackArtist(String artist);

  /// No description provided for @concertReasonSavedArtist.
  ///
  /// In en, this message translates to:
  /// **'You saved another {artist} event.'**
  String concertReasonSavedArtist(String artist);

  /// No description provided for @concertReasonGenre.
  ///
  /// In en, this message translates to:
  /// **'{genre} is {percent}% of your Musical DNA.'**
  String concertReasonGenre(String genre, int percent);

  /// No description provided for @concertReasonSimilarToSaved.
  ///
  /// In en, this message translates to:
  /// **'Like other {genre} events you saved.'**
  String concertReasonSimilarToSaved(String genre);

  /// No description provided for @concertReasonDistance.
  ///
  /// In en, this message translates to:
  /// **'{km} km from you.'**
  String concertReasonDistance(int km);

  /// No description provided for @concertReasonSoon.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today.} =1{Tomorrow.} other{In {days} days.}}'**
  String concertReasonSoon(int days);

  /// No description provided for @concertFilterGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get concertFilterGenre;

  /// No description provided for @concertFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get concertFilterAll;

  /// No description provided for @concertArtistHint.
  ///
  /// In en, this message translates to:
  /// **'Search an artist'**
  String get concertArtistHint;

  /// No description provided for @concertFilterDate.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get concertFilterDate;

  /// No description provided for @concertDateAny.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get concertDateAny;

  /// No description provided for @concertDateWeek.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get concertDateWeek;

  /// No description provided for @concertDateMonth.
  ///
  /// In en, this message translates to:
  /// **'Next 30 days'**
  String get concertDateMonth;

  /// No description provided for @concertDate3Months.
  ///
  /// In en, this message translates to:
  /// **'Next 3 months'**
  String get concertDate3Months;

  /// No description provided for @concertFilterDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get concertFilterDistance;

  /// No description provided for @concertDistanceAny.
  ///
  /// In en, this message translates to:
  /// **'Any distance'**
  String get concertDistanceAny;

  /// No description provided for @concertDistanceValue.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String concertDistanceValue(int km);

  /// No description provided for @concertFilterPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get concertFilterPrice;

  /// No description provided for @concertPriceAny.
  ///
  /// In en, this message translates to:
  /// **'Any price'**
  String get concertPriceAny;

  /// No description provided for @concertPriceUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {price}'**
  String concertPriceUpTo(String price);

  /// No description provided for @concertPriceNote.
  ///
  /// In en, this message translates to:
  /// **'Only events with a published price in euros.'**
  String get concertPriceNote;

  /// No description provided for @concertEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recommended events match these filters.'**
  String get concertEmpty;

  /// No description provided for @concertEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a wider distance, another date or fewer filters.'**
  String get concertEmptyBody;

  /// No description provided for @concertNoProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you listen to'**
  String get concertNoProfileTitle;

  /// No description provided for @concertNoProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify or pick a few genres to get concert recommendations.'**
  String get concertNoProfileBody;

  /// No description provided for @concertLocationNote.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to see distances and nearby events.'**
  String get concertLocationNote;

  /// No description provided for @concertLoadError.
  ///
  /// In en, this message translates to:
  /// **'Recommendations couldn\'t be loaded.'**
  String get concertLoadError;

  /// No description provided for @concertSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get concertSaved;

  /// No description provided for @eventDetailInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get eventDetailInterested;

  /// No description provided for @eventDetailAttendanceInterested.
  ///
  /// In en, this message translates to:
  /// **'Saved as interested'**
  String get eventDetailAttendanceInterested;

  /// No description provided for @eventDetailAttendanceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from your events'**
  String get eventDetailAttendanceRemoved;

  /// No description provided for @whosGoingTitle.
  ///
  /// In en, this message translates to:
  /// **'Who\'s going?'**
  String get whosGoingTitle;

  /// No description provided for @whosGoingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'People who chose to share their plans with you'**
  String get whosGoingSubtitle;

  /// No description provided for @whosGoingGoing.
  ///
  /// In en, this message translates to:
  /// **'{count} going'**
  String whosGoingGoing(int count);

  /// No description provided for @whosGoingMaybe.
  ///
  /// In en, this message translates to:
  /// **'{count} maybe'**
  String whosGoingMaybe(int count);

  /// No description provided for @whosGoingInterested.
  ///
  /// In en, this message translates to:
  /// **'{count} interested'**
  String whosGoingInterested(int count);

  /// No description provided for @whosGoingFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get whosGoingFriends;

  /// No description provided for @whosGoingCompatible.
  ///
  /// In en, this message translates to:
  /// **'Compatible people'**
  String get whosGoingCompatible;

  /// No description provided for @whosGoingOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get whosGoingOthers;

  /// No description provided for @whosGoingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one you can see has shared plans for this event yet.'**
  String get whosGoingEmpty;

  /// No description provided for @whosGoingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'You only see people who chose to share their plans with you. Yours follow your choice below.'**
  String get whosGoingPrivacyNote;

  /// No description provided for @whosGoingCommunities.
  ///
  /// In en, this message translates to:
  /// **'Communities for this event'**
  String get whosGoingCommunities;

  /// No description provided for @whosGoingAffinity.
  ///
  /// In en, this message translates to:
  /// **'{percent}% affinity'**
  String whosGoingAffinity(int percent);

  /// No description provided for @whosGoingRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get whosGoingRequested;

  /// No description provided for @attendanceVisibility.
  ///
  /// In en, this message translates to:
  /// **'Who can see your plans'**
  String get attendanceVisibility;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get visibilityPrivate;

  /// No description provided for @visibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get visibilityFriends;

  /// No description provided for @visibilityMatches.
  ///
  /// In en, this message translates to:
  /// **'Friends & matches'**
  String get visibilityMatches;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get visibilityPublic;

  /// No description provided for @attendanceVisibilityDefault.
  ///
  /// In en, this message translates to:
  /// **'Use for all my events'**
  String get attendanceVisibilityDefault;

  /// No description provided for @attendanceVisibilityHint.
  ///
  /// In en, this message translates to:
  /// **'Others see your plans only if you allow it. You still see people who share theirs.'**
  String get attendanceVisibilityHint;

  /// No description provided for @attendanceVisibilitySaved.
  ///
  /// In en, this message translates to:
  /// **'Visibility updated'**
  String get attendanceVisibilitySaved;

  /// No description provided for @concertMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Concert Match'**
  String get concertMatchTitle;

  /// No description provided for @concertMatchHeadlineMine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{You\'re the first one here you can see. People who love this artist are below.} =1{You and 1 other person are interested in this concert.} other{You and {count} other people are interested in this concert.}}'**
  String concertMatchHeadlineMine(int count);

  /// No description provided for @concertMatchHeadlineOthers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No one you can see has shared plans for this concert yet.} =1{1 person you can see is interested in this concert.} other{{count} people you can see are interested in this concert.}}'**
  String concertMatchHeadlineOthers(int count);

  /// No description provided for @concertMatchFan.
  ///
  /// In en, this message translates to:
  /// **'Also loves {artist}'**
  String concertMatchFan(String artist);

  /// No description provided for @concertMatchCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Create event group} other{Create event group ({count})}}'**
  String concertMatchCreateGroup(int count);

  /// No description provided for @concertMatchGroupNote.
  ///
  /// In en, this message translates to:
  /// **'People join only if they accept your invitation. Nobody\'s location or travel plans are shared.'**
  String get concertMatchGroupNote;

  /// No description provided for @concertMatchShare.
  ///
  /// In en, this message translates to:
  /// **'Share to a circle'**
  String get concertMatchShare;

  /// No description provided for @concertMatchShared.
  ///
  /// In en, this message translates to:
  /// **'Event shared with the circle'**
  String get concertMatchShared;

  /// No description provided for @concertMatchSharedMessage.
  ///
  /// In en, this message translates to:
  /// **'Shared an event: {event} · {date}'**
  String concertMatchSharedMessage(String event, String date);

  /// No description provided for @concertMatchNoCircles.
  ///
  /// In en, this message translates to:
  /// **'You have no circles yet.'**
  String get concertMatchNoCircles;

  /// No description provided for @concertMatchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matches for this concert yet.'**
  String get concertMatchEmpty;

  /// No description provided for @concertMatchSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select people to invite to an event group'**
  String get concertMatchSelectHint;

  /// No description provided for @circlePlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get circlePlans;

  /// No description provided for @circlePlansEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plans yet. Suggest one: dinner, pre-show drinks, a meeting point.'**
  String get circlePlansEmpty;

  /// No description provided for @circleAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Add a plan'**
  String get circleAddPlan;

  /// No description provided for @circlePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get circlePlanTitle;

  /// No description provided for @circlePlanWhen.
  ///
  /// In en, this message translates to:
  /// **'When (optional)'**
  String get circlePlanWhen;

  /// No description provided for @circlePlanNote.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get circlePlanNote;

  /// No description provided for @circlePlanIn.
  ///
  /// In en, this message translates to:
  /// **'I\'m in'**
  String get circlePlanIn;

  /// No description provided for @circlePlanJoined.
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get circlePlanJoined;

  /// No description provided for @circlePlanPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 in} other{{count} in}}'**
  String circlePlanPeople(int count);

  /// No description provided for @circlePlanPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Only circle members see plans.'**
  String get circlePlanPrivacy;

  /// No description provided for @groupConcert.
  ///
  /// In en, this message translates to:
  /// **'The concert'**
  String get groupConcert;

  /// No description provided for @groupYourStatus.
  ///
  /// In en, this message translates to:
  /// **'Your status'**
  String get groupYourStatus;

  /// No description provided for @groupStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Only members of this group see it.'**
  String get groupStatusHint;

  /// No description provided for @groupHeld.
  ///
  /// In en, this message translates to:
  /// **'Hidden while admins review reports'**
  String get groupHeld;

  /// No description provided for @groupRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove (admin)'**
  String get groupRemoveAdmin;

  /// No description provided for @groupBan.
  ///
  /// In en, this message translates to:
  /// **'Ban from group'**
  String get groupBan;

  /// No description provided for @groupBanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Ban {name} from this group? They won\'t be able to rejoin.'**
  String groupBanConfirm(String name);

  /// No description provided for @groupErrorBanned.
  ///
  /// In en, this message translates to:
  /// **'This person can\'t be invited to this group.'**
  String get groupErrorBanned;

  /// No description provided for @groupYourGroups.
  ///
  /// In en, this message translates to:
  /// **'Your groups for this event'**
  String get groupYourGroups;

  /// No description provided for @groupStart.
  ///
  /// In en, this message translates to:
  /// **'Start a concert group'**
  String get groupStart;

  /// No description provided for @groupReportMember.
  ///
  /// In en, this message translates to:
  /// **'Report member'**
  String get groupReportMember;

  /// No description provided for @vibeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Vibe'**
  String get vibeTitle;

  /// No description provided for @vibeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your vibe today?'**
  String get vibeQuestion;

  /// No description provided for @vibeShare.
  ///
  /// In en, this message translates to:
  /// **'Share your vibe'**
  String get vibeShare;

  /// No description provided for @vibeChange.
  ///
  /// In en, this message translates to:
  /// **'Change today\'s vibe'**
  String get vibeChange;

  /// No description provided for @vibeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a song on Spotify'**
  String get vibeSearchHint;

  /// No description provided for @vibeTabSpotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get vibeTabSpotify;

  /// No description provided for @vibeTabLink.
  ///
  /// In en, this message translates to:
  /// **'Other link'**
  String get vibeTabLink;

  /// No description provided for @vibeLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Apple Music, YouTube, SoundCloud or Bandcamp link'**
  String get vibeLinkHint;

  /// No description provided for @vibeTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Song title'**
  String get vibeTitleHint;

  /// No description provided for @vibeArtistHint.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get vibeArtistHint;

  /// No description provided for @vibeCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption (optional)'**
  String get vibeCaptionHint;

  /// No description provided for @vibeExpires.
  ///
  /// In en, this message translates to:
  /// **'Disappears after 24 hours'**
  String get vibeExpires;

  /// No description provided for @vibeEveryone.
  ///
  /// In en, this message translates to:
  /// **'Visible to everyone'**
  String get vibeEveryone;

  /// No description provided for @vibeVisibilityBody.
  ///
  /// In en, this message translates to:
  /// **'Off: only your connections and musical matches see it.'**
  String get vibeVisibilityBody;

  /// No description provided for @vibePost.
  ///
  /// In en, this message translates to:
  /// **'Post vibe'**
  String get vibePost;

  /// No description provided for @vibePosted.
  ///
  /// In en, this message translates to:
  /// **'Your vibe is live'**
  String get vibePosted;

  /// No description provided for @vibeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No vibes yet today'**
  String get vibeEmptyTitle;

  /// No description provided for @vibeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Share yours, and connect with or follow people to see theirs.'**
  String get vibeEmptyBody;

  /// No description provided for @vibeListen.
  ///
  /// In en, this message translates to:
  /// **'Listen on Spotify'**
  String get vibeListen;

  /// No description provided for @vibeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get vibeOpen;

  /// No description provided for @vibeSave.
  ///
  /// In en, this message translates to:
  /// **'Add to discoveries'**
  String get vibeSave;

  /// No description provided for @vibeSaved.
  ///
  /// In en, this message translates to:
  /// **'In your discoveries'**
  String get vibeSaved;

  /// No description provided for @vibeComments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Comment} =1{1 comment} other{{count} comments}}'**
  String vibeComments(int count);

  /// No description provided for @vibeCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get vibeCommentHint;

  /// No description provided for @vibeReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get vibeReply;

  /// No description provided for @vibeReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String vibeReplyingTo(String name);

  /// No description provided for @vibeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =0{Less than 1h left} =1{1h left} other{{hours}h left}}'**
  String vibeExpiresIn(int hours);

  /// No description provided for @vibeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete my vibe'**
  String get vibeDelete;

  /// No description provided for @vibeSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No songs found.'**
  String get vibeSearchEmpty;

  /// No description provided for @vibeProviderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Spotify search isn\'t available right now. You can paste a link instead.'**
  String get vibeProviderUnavailable;

  /// No description provided for @vibeError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your vibe. Try again.'**
  String get vibeError;

  /// No description provided for @vibeAttribution.
  ///
  /// In en, this message translates to:
  /// **'Song info and artwork from Spotify'**
  String get vibeAttribution;

  /// No description provided for @discoveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discoveries'**
  String get discoveriesTitle;

  /// No description provided for @discoveriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Songs you add from Daily Vibes, stories, posts and communities appear here. Only you can see them.'**
  String get discoveriesEmpty;

  /// No description provided for @discoveriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Songs you found on VIBRA'**
  String get discoveriesSubtitle;

  /// No description provided for @vibeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Daily Vibe couldn\'t be loaded.'**
  String get vibeLoadError;

  /// No description provided for @vibeHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Share the song that\'s your vibe today'**
  String get vibeHomeCta;

  /// No description provided for @storyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add story'**
  String get storyAdd;

  /// No description provided for @storyYours.
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get storyYours;

  /// No description provided for @storyNew.
  ///
  /// In en, this message translates to:
  /// **'New music story'**
  String get storyNew;

  /// No description provided for @storyKindNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now listening'**
  String get storyKindNowPlaying;

  /// No description provided for @storyKindArtist.
  ///
  /// In en, this message translates to:
  /// **'Favorite artist'**
  String get storyKindArtist;

  /// No description provided for @storyKindAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album pick'**
  String get storyKindAlbum;

  /// No description provided for @storyKindPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get storyKindPlaylist;

  /// No description provided for @storyKindConcertPhoto.
  ///
  /// In en, this message translates to:
  /// **'Concert photo'**
  String get storyKindConcertPhoto;

  /// No description provided for @storyKindOpinion.
  ///
  /// In en, this message translates to:
  /// **'Music opinion'**
  String get storyKindOpinion;

  /// No description provided for @storyAttribution.
  ///
  /// In en, this message translates to:
  /// **'Music info and artwork from Spotify'**
  String get storyAttribution;

  /// No description provided for @storyPreview.
  ///
  /// In en, this message translates to:
  /// **'Story preview'**
  String get storyPreview;

  /// No description provided for @storySearchArtist.
  ///
  /// In en, this message translates to:
  /// **'Search an artist on Spotify'**
  String get storySearchArtist;

  /// No description provided for @storySearchAlbum.
  ///
  /// In en, this message translates to:
  /// **'Search an album on Spotify'**
  String get storySearchAlbum;

  /// No description provided for @storySearchPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Search a public playlist on Spotify'**
  String get storySearchPlaylist;

  /// No description provided for @storySearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get storySearchEmpty;

  /// No description provided for @storyArtistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Artist name'**
  String get storyArtistNameHint;

  /// No description provided for @storyAlbumTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Album title'**
  String get storyAlbumTitleHint;

  /// No description provided for @storyPlaylistTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get storyPlaylistTitleHint;

  /// No description provided for @storyPlaylistOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Made by (optional)'**
  String get storyPlaylistOwnerHint;

  /// No description provided for @storyPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a concert photo'**
  String get storyPickPhoto;

  /// No description provided for @storyChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get storyChangePhoto;

  /// No description provided for @storyPhotoPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Location and camera data are removed from the photo before it\'s shared.'**
  String get storyPhotoPrivacy;

  /// No description provided for @storyTagConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert (optional)'**
  String get storyTagConcert;

  /// No description provided for @storyNoConcert.
  ///
  /// In en, this message translates to:
  /// **'No concert'**
  String get storyNoConcert;

  /// No description provided for @storyOpinionHint.
  ///
  /// In en, this message translates to:
  /// **'Your hot take: an album, a scene, a song…'**
  String get storyOpinionHint;

  /// No description provided for @storyBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get storyBackground;

  /// No description provided for @storyAudience.
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get storyAudience;

  /// No description provided for @storyDefaultAudience.
  ///
  /// In en, this message translates to:
  /// **'Who sees your stories by default'**
  String get storyDefaultAudience;

  /// No description provided for @storyAudienceConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get storyAudienceConnections;

  /// No description provided for @storyAudienceEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get storyAudienceEveryone;

  /// No description provided for @storyAudienceConnectionsBody.
  ///
  /// In en, this message translates to:
  /// **'Your connections and musical matches.'**
  String get storyAudienceConnectionsBody;

  /// No description provided for @storyAudienceEveryoneBody.
  ///
  /// In en, this message translates to:
  /// **'Also people who follow you. Blocked people and anyone you hide stories from never see it.'**
  String get storyAudienceEveryoneBody;

  /// No description provided for @storyAllowReplies.
  ///
  /// In en, this message translates to:
  /// **'Allow replies'**
  String get storyAllowReplies;

  /// No description provided for @storyAllowRepliesBody.
  ///
  /// In en, this message translates to:
  /// **'Replies are private: only you and the person replying see them.'**
  String get storyAllowRepliesBody;

  /// No description provided for @storyExpires.
  ///
  /// In en, this message translates to:
  /// **'Disappears after 24 hours.'**
  String get storyExpires;

  /// No description provided for @storyShare.
  ///
  /// In en, this message translates to:
  /// **'Share story'**
  String get storyShare;

  /// No description provided for @storyPosted.
  ///
  /// In en, this message translates to:
  /// **'Your story is live for 24 hours'**
  String get storyPosted;

  /// No description provided for @storyError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get storyError;

  /// No description provided for @storyRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'re sharing a lot. Wait a moment and try again.'**
  String get storyRateLimited;

  /// No description provided for @storySpam.
  ///
  /// In en, this message translates to:
  /// **'This looks like spam. Remove links and try again.'**
  String get storySpam;

  /// No description provided for @storyPhotoError.
  ///
  /// In en, this message translates to:
  /// **'This photo can\'t be used. Choose a JPG or PNG up to 10 MB.'**
  String get storyPhotoError;

  /// No description provided for @storySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Story privacy'**
  String get storySettingsTitle;

  /// No description provided for @storyHideFrom.
  ///
  /// In en, this message translates to:
  /// **'Hide your stories from'**
  String get storyHideFrom;

  /// No description provided for @storyHideFromBody.
  ///
  /// In en, this message translates to:
  /// **'They won\'t see your stories and won\'t be told.'**
  String get storyHideFromBody;

  /// No description provided for @storyHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden from your stories'**
  String get storyHidden;

  /// No description provided for @storyNoConnections.
  ///
  /// In en, this message translates to:
  /// **'When you have connections, you can choose here who doesn\'t see your stories.'**
  String get storyNoConnections;

  /// No description provided for @storyJustNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get storyJustNow;

  /// No description provided for @storyMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String storyMinutesAgo(int minutes);

  /// No description provided for @storyHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String storyHoursAgo(int hours);

  /// No description provided for @storyPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous story'**
  String get storyPrevious;

  /// No description provided for @storyNext.
  ///
  /// In en, this message translates to:
  /// **'Next story'**
  String get storyNext;

  /// No description provided for @storyMore.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get storyMore;

  /// No description provided for @storyLoadError.
  ///
  /// In en, this message translates to:
  /// **'These stories couldn\'t be loaded.'**
  String get storyLoadError;

  /// No description provided for @storyGone.
  ///
  /// In en, this message translates to:
  /// **'These stories have expired or are no longer available.'**
  String get storyGone;

  /// No description provided for @storyHeld.
  ///
  /// In en, this message translates to:
  /// **'Hidden while it\'s reviewed after reports. Only you can see it.'**
  String get storyHeld;

  /// No description provided for @storyReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}…'**
  String storyReplyHint(String name);

  /// No description provided for @storySendReply.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get storySendReply;

  /// No description provided for @storyReplySent.
  ///
  /// In en, this message translates to:
  /// **'Reply sent privately'**
  String get storyReplySent;

  /// No description provided for @storyRepliesOff.
  ///
  /// In en, this message translates to:
  /// **'Replies are off for this story'**
  String get storyRepliesOff;

  /// No description provided for @storyRepliesOffMine.
  ///
  /// In en, this message translates to:
  /// **'Replies are off for this story.'**
  String get storyRepliesOffMine;

  /// No description provided for @storyViews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No views} =1{1 view} other{{count} views}}'**
  String storyViews(int count);

  /// No description provided for @storyReplies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Replies} =1{1 reply} other{{count} replies}}'**
  String storyReplies(int count);

  /// No description provided for @storyReactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reaction} other{{count} reactions}}'**
  String storyReactionCount(int count);

  /// No description provided for @storyInsightsPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only you can see who viewed and replied.'**
  String get storyInsightsPrivate;

  /// No description provided for @storyNoViewers.
  ///
  /// In en, this message translates to:
  /// **'No views yet.'**
  String get storyNoViewers;

  /// No description provided for @storyNoReplies.
  ///
  /// In en, this message translates to:
  /// **'No replies yet.'**
  String get storyNoReplies;

  /// No description provided for @storyAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Answer {name} privately…'**
  String storyAnswerHint(String name);

  /// No description provided for @storyMakeEveryone.
  ///
  /// In en, this message translates to:
  /// **'Show to everyone'**
  String get storyMakeEveryone;

  /// No description provided for @storyMakeConnectionsOnly.
  ///
  /// In en, this message translates to:
  /// **'Show to connections only'**
  String get storyMakeConnectionsOnly;

  /// No description provided for @storyNowEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone can now see this story'**
  String get storyNowEveryone;

  /// No description provided for @storyNowConnections.
  ///
  /// In en, this message translates to:
  /// **'Only your connections can now see this story'**
  String get storyNowConnections;

  /// No description provided for @storyTurnRepliesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off replies'**
  String get storyTurnRepliesOff;

  /// No description provided for @storyTurnRepliesOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on replies'**
  String get storyTurnRepliesOn;

  /// No description provided for @storyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete story'**
  String get storyDelete;

  /// No description provided for @storyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Story deleted'**
  String get storyDeleted;

  /// No description provided for @storyMute.
  ///
  /// In en, this message translates to:
  /// **'Mute {name}\'s stories'**
  String storyMute(String name);

  /// No description provided for @storyMuted.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see {name}\'s stories. They won\'t be told.'**
  String storyMuted(String name);

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'VIBRA Feed'**
  String get feedTitle;

  /// No description provided for @feedHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Recommendations, reviews and discoveries from your music world'**
  String get feedHomeCta;

  /// No description provided for @feedForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get feedForYou;

  /// No description provided for @feedFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get feedFollowing;

  /// No description provided for @feedLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get feedLatest;

  /// No description provided for @feedForYouBody.
  ///
  /// In en, this message translates to:
  /// **'Ranked by people you follow, your connections, communities and the music you love. Each post says why it\'s here.'**
  String get feedForYouBody;

  /// No description provided for @feedFollowingBody.
  ///
  /// In en, this message translates to:
  /// **'Newest first, from people you follow and your connections.'**
  String get feedFollowingBody;

  /// No description provided for @feedLatestBody.
  ///
  /// In en, this message translates to:
  /// **'Newest first, every post you can see.'**
  String get feedLatestBody;

  /// No description provided for @feedCompose.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get feedCompose;

  /// No description provided for @feedNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get feedNewPost;

  /// No description provided for @feedPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get feedPublish;

  /// No description provided for @feedPosted.
  ///
  /// In en, this message translates to:
  /// **'Your post is live'**
  String get feedPosted;

  /// No description provided for @feedKindSong.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get feedKindSong;

  /// No description provided for @feedKindAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get feedKindAlbum;

  /// No description provided for @feedKindPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get feedKindPlaylist;

  /// No description provided for @feedKindRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get feedKindRecommendation;

  /// No description provided for @feedKindDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get feedKindDiscovery;

  /// No description provided for @feedKindReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get feedKindReview;

  /// No description provided for @feedKindOpinion.
  ///
  /// In en, this message translates to:
  /// **'Opinion'**
  String get feedKindOpinion;

  /// No description provided for @feedKindConcertPhoto.
  ///
  /// In en, this message translates to:
  /// **'Concert photo'**
  String get feedKindConcertPhoto;

  /// No description provided for @feedKindShare.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get feedKindShare;

  /// No description provided for @feedItemTrack.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get feedItemTrack;

  /// No description provided for @feedItemAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get feedItemAlbum;

  /// No description provided for @feedItemArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get feedItemArtist;

  /// No description provided for @feedItemPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get feedItemPlaylist;

  /// No description provided for @feedWhatAbout.
  ///
  /// In en, this message translates to:
  /// **'What is it about?'**
  String get feedWhatAbout;

  /// No description provided for @feedYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get feedYourRating;

  /// No description provided for @feedRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'{rating, plural, =1{1 star} other{{rating} stars}}'**
  String feedRatingLabel(int rating);

  /// No description provided for @feedReviewHint.
  ///
  /// In en, this message translates to:
  /// **'What did you think? Be specific.'**
  String get feedReviewHint;

  /// No description provided for @feedDiscoveryHint.
  ///
  /// In en, this message translates to:
  /// **'How did you find it?'**
  String get feedDiscoveryHint;

  /// No description provided for @feedRecommendationHint.
  ///
  /// In en, this message translates to:
  /// **'Why should people listen to it?'**
  String get feedRecommendationHint;

  /// No description provided for @feedBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Say something about it (optional)'**
  String get feedBodyHint;

  /// No description provided for @feedAudienceEveryoneBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone on VIBRA can see it, except people you blocked.'**
  String get feedAudienceEveryoneBody;

  /// No description provided for @feedAllowComments.
  ///
  /// In en, this message translates to:
  /// **'Allow comments'**
  String get feedAllowComments;

  /// No description provided for @feedDuplicatePost.
  ///
  /// In en, this message translates to:
  /// **'You already posted this today.'**
  String get feedDuplicatePost;

  /// No description provided for @feedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get feedError;

  /// No description provided for @feedLoadError.
  ///
  /// In en, this message translates to:
  /// **'The feed couldn\'t be loaded.'**
  String get feedLoadError;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Share a recommendation, or join communities and follow people to fill your feed.'**
  String get feedEmptyBody;

  /// No description provided for @feedEmptyFollowing.
  ///
  /// In en, this message translates to:
  /// **'Posts from people you follow and your connections appear here.'**
  String get feedEmptyFollowing;

  /// No description provided for @feedEnd.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get feedEnd;

  /// No description provided for @feedReasonFollowing.
  ///
  /// In en, this message translates to:
  /// **'You follow them'**
  String get feedReasonFollowing;

  /// No description provided for @feedReasonConnection.
  ///
  /// In en, this message translates to:
  /// **'Your connection'**
  String get feedReasonConnection;

  /// No description provided for @feedReasonArtists.
  ///
  /// In en, this message translates to:
  /// **'An artist you listen to'**
  String get feedReasonArtists;

  /// No description provided for @feedReasonGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres you love'**
  String get feedReasonGenres;

  /// No description provided for @feedReasonCommunity.
  ///
  /// In en, this message translates to:
  /// **'From your communities'**
  String get feedReasonCommunity;

  /// No description provided for @feedReasonMatch.
  ///
  /// In en, this message translates to:
  /// **'Musical affinity'**
  String get feedReasonMatch;

  /// No description provided for @feedReasonInteraction.
  ///
  /// In en, this message translates to:
  /// **'You often engage with them'**
  String get feedReasonInteraction;

  /// No description provided for @feedReasonNew.
  ///
  /// In en, this message translates to:
  /// **'New on VIBRA'**
  String get feedReasonNew;

  /// No description provided for @feedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String feedDaysAgo(int days);

  /// No description provided for @feedHeld.
  ///
  /// In en, this message translates to:
  /// **'Hidden while it\'s reviewed after reports. Only you can see it.'**
  String get feedHeld;

  /// No description provided for @feedLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get feedLike;

  /// No description provided for @feedUnlike.
  ///
  /// In en, this message translates to:
  /// **'Remove like'**
  String get feedUnlike;

  /// No description provided for @feedReact.
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get feedReact;

  /// No description provided for @feedComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get feedComments;

  /// No description provided for @feedShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get feedShare;

  /// No description provided for @feedSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get feedSave;

  /// No description provided for @feedUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get feedUnsave;

  /// No description provided for @feedSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get feedSaved;

  /// No description provided for @feedUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get feedUnsaved;

  /// No description provided for @feedShareToFeed.
  ///
  /// In en, this message translates to:
  /// **'Share to your feed'**
  String get feedShareToFeed;

  /// No description provided for @feedShareCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get feedShareCommentHint;

  /// No description provided for @feedShareOnlyPublic.
  ///
  /// In en, this message translates to:
  /// **'Only public posts by other people can be shared to your feed.'**
  String get feedShareOnlyPublic;

  /// No description provided for @feedShared.
  ///
  /// In en, this message translates to:
  /// **'Shared to your feed'**
  String get feedShared;

  /// No description provided for @feedAlreadyShared.
  ///
  /// In en, this message translates to:
  /// **'You already shared this post.'**
  String get feedAlreadyShared;

  /// No description provided for @feedCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy music link'**
  String get feedCopyLink;

  /// No description provided for @feedLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get feedLinkCopied;

  /// No description provided for @feedTurnCommentsOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off comments'**
  String get feedTurnCommentsOff;

  /// No description provided for @feedTurnCommentsOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on comments'**
  String get feedTurnCommentsOn;

  /// No description provided for @feedDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get feedDelete;

  /// No description provided for @feedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get feedDeleted;

  /// No description provided for @feedNotInterested.
  ///
  /// In en, this message translates to:
  /// **'Not interested'**
  String get feedNotInterested;

  /// No description provided for @feedNotInterestedDone.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see fewer posts like this'**
  String get feedNotInterestedDone;

  /// No description provided for @feedPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get feedPostTitle;

  /// No description provided for @feedPostGone.
  ///
  /// In en, this message translates to:
  /// **'Post not available'**
  String get feedPostGone;

  /// No description provided for @feedPostGoneBody.
  ///
  /// In en, this message translates to:
  /// **'It was deleted or you can no longer see it.'**
  String get feedPostGoneBody;

  /// No description provided for @feedCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get feedCommentHint;

  /// No description provided for @feedCommentsOff.
  ///
  /// In en, this message translates to:
  /// **'Comments are off for this post.'**
  String get feedCommentsOff;

  /// No description provided for @feedDuplicateComment.
  ///
  /// In en, this message translates to:
  /// **'You already wrote this comment.'**
  String get feedDuplicateComment;

  /// No description provided for @feedNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Start the conversation.'**
  String get feedNoComments;

  /// No description provided for @feedDeleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get feedDeleteComment;

  /// No description provided for @feedSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved posts'**
  String get feedSavedTitle;

  /// No description provided for @feedSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Posts you bookmarked in the feed'**
  String get feedSavedSubtitle;

  /// No description provided for @feedSavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved posts'**
  String get feedSavedEmpty;

  /// No description provided for @feedSavedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on a post to keep it here. Only you can see your saved posts.'**
  String get feedSavedEmptyBody;

  /// No description provided for @feedPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get feedPostsTitle;

  /// No description provided for @feedPostsOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s posts'**
  String feedPostsOf(String name);

  /// No description provided for @feedSeeAllPosts.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get feedSeeAllPosts;

  /// No description provided for @feedNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get feedNoPosts;

  /// No description provided for @feedNoPostsBody.
  ///
  /// In en, this message translates to:
  /// **'Posts you can see will appear here.'**
  String get feedNoPostsBody;

  /// No description provided for @feedYourPosts.
  ///
  /// In en, this message translates to:
  /// **'Your posts'**
  String get feedYourPosts;

  /// No description provided for @feedYourPostsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you published in the feed'**
  String get feedYourPostsSubtitle;

  /// No description provided for @reactionFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get reactionFire;

  /// No description provided for @reactionObsessed.
  ///
  /// In en, this message translates to:
  /// **'Obsessed'**
  String get reactionObsessed;

  /// No description provided for @reactionUnderrated.
  ///
  /// In en, this message translates to:
  /// **'Underrated'**
  String get reactionUnderrated;

  /// No description provided for @reactionClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get reactionClassic;

  /// No description provided for @reactionNewDiscovery.
  ///
  /// In en, this message translates to:
  /// **'New discovery'**
  String get reactionNewDiscovery;

  /// No description provided for @reactionOnRepeat.
  ///
  /// In en, this message translates to:
  /// **'On repeat'**
  String get reactionOnRepeat;

  /// No description provided for @reactionHeart.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get reactionHeart;

  /// No description provided for @reactionHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get reactionHeadphones;

  /// No description provided for @reactionClap.
  ///
  /// In en, this message translates to:
  /// **'Applause'**
  String get reactionClap;

  /// No description provided for @reactionMindBlown.
  ///
  /// In en, this message translates to:
  /// **'Mind-blowing'**
  String get reactionMindBlown;

  /// No description provided for @reactionTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'React to this song'**
  String get reactionTrackTitle;

  /// No description provided for @discoveryAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your Discoveries'**
  String get discoveryAdded;

  /// No description provided for @discoveryAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the song. Try again.'**
  String get discoveryAddFailed;

  /// No description provided for @discoveryOffer.
  ///
  /// In en, this message translates to:
  /// **'A new discovery? Keep it in your Discoveries.'**
  String get discoveryOffer;

  /// No description provided for @discoveryFoundVia.
  ///
  /// In en, this message translates to:
  /// **'via {name}'**
  String discoveryFoundVia(String name);

  /// No description provided for @aiTitle.
  ///
  /// In en, this message translates to:
  /// **'VIBRA AI'**
  String get aiTitle;

  /// No description provided for @aiHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Ask for artists, albums, concerts and genres to discover'**
  String get aiHomeCta;

  /// No description provided for @aiPrivacyTile.
  ///
  /// In en, this message translates to:
  /// **'Optional music assistant. Off unless you turn it on.'**
  String get aiPrivacyTile;

  /// No description provided for @aiUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'VIBRA AI isn\'t available'**
  String get aiUnavailableTitle;

  /// No description provided for @aiUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'The assistant isn\'t available right now. Everything else in VIBRA works as usual.'**
  String get aiUnavailableBody;

  /// No description provided for @aiConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet your music assistant'**
  String get aiConsentTitle;

  /// No description provided for @aiConsentIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask for similar artists, albums for your taste, concerts that match your interests, communities and new genres. It\'s optional and off until you turn it on.'**
  String get aiConsentIntro;

  /// No description provided for @aiConsentUses.
  ///
  /// In en, this message translates to:
  /// **'To answer, it uses'**
  String get aiConsentUses;

  /// No description provided for @aiConsentUsesProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Musical DNA, top artists and the genres you picked'**
  String get aiConsentUsesProfile;

  /// No description provided for @aiConsentUsesChat.
  ///
  /// In en, this message translates to:
  /// **'Your question and the last few messages of this chat'**
  String get aiConsentUsesChat;

  /// No description provided for @aiConsentUsesCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Spotify\'s public catalogue and VIBRA\'s concerts and communities'**
  String get aiConsentUsesCatalogue;

  /// No description provided for @aiConsentNever.
  ///
  /// In en, this message translates to:
  /// **'It never uses'**
  String get aiConsentNever;

  /// No description provided for @aiConsentNeverBody.
  ///
  /// In en, this message translates to:
  /// **'Your messages, location, contacts, other people\'s profiles or your Spotify login. Chats aren\'t saved by VIBRA.'**
  String get aiConsentNeverBody;

  /// No description provided for @aiConsentProvider.
  ///
  /// In en, this message translates to:
  /// **'Answers are generated by an external AI provider (Anthropic), which receives the information above for each question. You can turn VIBRA AI off at any time.'**
  String get aiConsentProvider;

  /// No description provided for @aiConsentAccept.
  ///
  /// In en, this message translates to:
  /// **'Turn on VIBRA AI'**
  String get aiConsentAccept;

  /// No description provided for @aiConsentDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get aiConsentDecline;

  /// No description provided for @aiTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off VIBRA AI'**
  String get aiTurnOff;

  /// No description provided for @aiTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'VIBRA AI is off'**
  String get aiTurnedOff;

  /// No description provided for @aiNewChat.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get aiNewChat;

  /// No description provided for @aiIntro.
  ///
  /// In en, this message translates to:
  /// **'What do you want to discover?'**
  String get aiIntro;

  /// No description provided for @aiExampleSimilar.
  ///
  /// In en, this message translates to:
  /// **'Recommend artists similar to Travis Scott'**
  String get aiExampleSimilar;

  /// No description provided for @aiExampleUnderground.
  ///
  /// In en, this message translates to:
  /// **'Find underground Hip-Hop artists'**
  String get aiExampleUnderground;

  /// No description provided for @aiExampleAlbums.
  ///
  /// In en, this message translates to:
  /// **'Recommend albums based on my musical profile'**
  String get aiExampleAlbums;

  /// No description provided for @aiExampleExplain.
  ///
  /// In en, this message translates to:
  /// **'Explain why two artists have similar sounds'**
  String get aiExampleExplain;

  /// No description provided for @aiExampleConcerts.
  ///
  /// In en, this message translates to:
  /// **'Find concerts matching my interests'**
  String get aiExampleConcerts;

  /// No description provided for @aiExampleCommunities.
  ///
  /// In en, this message translates to:
  /// **'Suggest communities I might enjoy'**
  String get aiExampleCommunities;

  /// No description provided for @aiExampleGenres.
  ///
  /// In en, this message translates to:
  /// **'Help me discover new genres'**
  String get aiExampleGenres;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask VIBRA AI about music'**
  String get aiInputHint;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Looking into it…'**
  String get aiThinking;

  /// No description provided for @aiGeneratedLabel.
  ///
  /// In en, this message translates to:
  /// **'AI-generated · may contain mistakes'**
  String get aiGeneratedLabel;

  /// No description provided for @aiVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified results'**
  String get aiVerifiedTitle;

  /// No description provided for @aiIdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas to explore'**
  String get aiIdeasTitle;

  /// No description provided for @aiIdeasBody.
  ///
  /// In en, this message translates to:
  /// **'Generated suggestions, not verified.'**
  String get aiIdeasBody;

  /// No description provided for @aiSourceSpotify.
  ///
  /// In en, this message translates to:
  /// **'Verified on Spotify'**
  String get aiSourceSpotify;

  /// No description provided for @aiSourceEvents.
  ///
  /// In en, this message translates to:
  /// **'From VIBRA\'s concert listings'**
  String get aiSourceEvents;

  /// No description provided for @aiSourceCommunities.
  ///
  /// In en, this message translates to:
  /// **'VIBRA community'**
  String get aiSourceCommunities;

  /// No description provided for @aiSourceDna.
  ///
  /// In en, this message translates to:
  /// **'From your Musical DNA'**
  String get aiSourceDna;

  /// No description provided for @aiSourceGenres.
  ///
  /// In en, this message translates to:
  /// **'VIBRA genre catalogue'**
  String get aiSourceGenres;

  /// No description provided for @aiMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String aiMembersCount(int count);

  /// No description provided for @aiRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'ve asked a lot. Try again in a little while.'**
  String get aiRateLimited;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get aiError;

  /// No description provided for @aiRefused.
  ///
  /// In en, this message translates to:
  /// **'VIBRA AI can\'t help with that. Try a music question.'**
  String get aiRefused;

  /// No description provided for @aiIncomplete.
  ///
  /// In en, this message translates to:
  /// **'The answer couldn\'t be completed. Try asking in a simpler way.'**
  String get aiIncomplete;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover my next artist'**
  String get discoverTitle;

  /// No description provided for @discoverHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Similar, emerging and underground artists picked for you'**
  String get discoverHomeCta;

  /// No description provided for @discoverIntro.
  ///
  /// In en, this message translates to:
  /// **'Based on your favourite artists, your Musical DNA, songs you discovered and your feedback. Your answers shape the next picks.'**
  String get discoverIntro;

  /// No description provided for @discoverAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get discoverAll;

  /// No description provided for @discoverSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get discoverSimilar;

  /// No description provided for @discoverCollaborations.
  ///
  /// In en, this message translates to:
  /// **'Collaborations'**
  String get discoverCollaborations;

  /// No description provided for @discoverEmerging.
  ///
  /// In en, this message translates to:
  /// **'Emerging'**
  String get discoverEmerging;

  /// No description provided for @discoverUnderground.
  ///
  /// In en, this message translates to:
  /// **'Underground'**
  String get discoverUnderground;

  /// No description provided for @discoverExploration.
  ///
  /// In en, this message translates to:
  /// **'New genres'**
  String get discoverExploration;

  /// No description provided for @discoverReasonCollab.
  ///
  /// In en, this message translates to:
  /// **'Collaborated with {artist}'**
  String discoverReasonCollab(String artist);

  /// No description provided for @discoverReasonExplore.
  ///
  /// In en, this message translates to:
  /// **'A step into {genre}'**
  String discoverReasonExplore(String genre);

  /// No description provided for @discoverReasonGenres.
  ///
  /// In en, this message translates to:
  /// **'Shares your {genres}'**
  String discoverReasonGenres(String genres);

  /// No description provided for @discoverLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get discoverLike;

  /// No description provided for @discoverSave.
  ///
  /// In en, this message translates to:
  /// **'Save for later'**
  String get discoverSave;

  /// No description provided for @discoverKnown.
  ///
  /// In en, this message translates to:
  /// **'Already know'**
  String get discoverKnown;

  /// No description provided for @discoverNotInterested.
  ///
  /// In en, this message translates to:
  /// **'Not interested'**
  String get discoverNotInterested;

  /// No description provided for @discoverLiked.
  ///
  /// In en, this message translates to:
  /// **'Got it: more like this'**
  String get discoverLiked;

  /// No description provided for @discoverUndone.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get discoverUndone;

  /// No description provided for @discoverSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved for later'**
  String get discoverSaved;

  /// No description provided for @discoverUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get discoverUnsaved;

  /// No description provided for @discoverKnownDone.
  ///
  /// In en, this message translates to:
  /// **'Noted. We won\'t suggest this artist again.'**
  String get discoverKnownDone;

  /// No description provided for @discoverNotInterestedDone.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see this artist again, and fewer like them.'**
  String get discoverNotInterestedDone;

  /// No description provided for @discoverRefresh.
  ///
  /// In en, this message translates to:
  /// **'New picks'**
  String get discoverRefresh;

  /// No description provided for @discoverRefreshLimited.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh right now. Try again in a few minutes.'**
  String get discoverRefreshLimited;

  /// No description provided for @discoverError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get discoverError;

  /// No description provided for @discoverEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No new artists yet'**
  String get discoverEmptyTitle;

  /// No description provided for @discoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Check back later or tap New picks.'**
  String get discoverEmptyBody;

  /// No description provided for @discoverNoProfile.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify or pick a few genres so VIBRA knows what you like.'**
  String get discoverNoProfile;

  /// No description provided for @discoverPickGenres.
  ///
  /// In en, this message translates to:
  /// **'Pick genres'**
  String get discoverPickGenres;

  /// No description provided for @discoverSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved artists'**
  String get discoverSavedTitle;

  /// No description provided for @discoverSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Artists you saved to listen to later'**
  String get discoverSavedSubtitle;

  /// No description provided for @discoverSavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved artists'**
  String get discoverSavedEmpty;

  /// No description provided for @discoverSavedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Save for later on a recommendation to keep it here.'**
  String get discoverSavedEmptyBody;

  /// No description provided for @tasteTitle.
  ///
  /// In en, this message translates to:
  /// **'Taste evolution'**
  String get tasteTitle;

  /// No description provided for @tasteOpen.
  ///
  /// In en, this message translates to:
  /// **'See how your taste evolved'**
  String get tasteOpen;

  /// No description provided for @tastePeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get tastePeriodMonth;

  /// No description provided for @tastePeriodThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get tastePeriodThreeMonths;

  /// No description provided for @tastePeriodSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get tastePeriodSixMonths;

  /// No description provided for @tastePeriodYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get tastePeriodYear;

  /// No description provided for @tasteEvolved.
  ///
  /// In en, this message translates to:
  /// **'{period, select, month{Your musical taste has evolved over the last month} year{Your musical taste has evolved over the last year} three{Your musical taste has evolved over the last 3 months} six{Your musical taste has evolved over the last 6 months} other{Your musical taste has evolved over the last 3 months}}'**
  String tasteEvolved(String period);

  /// No description provided for @tasteSteady.
  ///
  /// In en, this message translates to:
  /// **'{period, select, month{Your musical taste stayed steady over the last month} year{Your musical taste stayed steady over the last year} three{Your musical taste stayed steady over the last 3 months} six{Your musical taste stayed steady over the last 6 months} other{Your musical taste stayed steady over the last 3 months}}'**
  String tasteSteady(String period);

  /// No description provided for @tasteComparing.
  ///
  /// In en, this message translates to:
  /// **'Comparing your Musical DNA on {from} with {to}.'**
  String tasteComparing(String from, String to);

  /// No description provided for @tasteShortHistory.
  ///
  /// In en, this message translates to:
  /// **'Your history starts on {from}, so this compares {from} with {to}.'**
  String tasteShortHistory(String from, String to);

  /// No description provided for @tasteChangePoints.
  ///
  /// In en, this message translates to:
  /// **'{points} percentage points of your genre mix moved.'**
  String tasteChangePoints(int points);

  /// No description provided for @tasteThenNow.
  ///
  /// In en, this message translates to:
  /// **'Then and now'**
  String get tasteThenNow;

  /// No description provided for @tasteThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get tasteThen;

  /// No description provided for @tasteNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get tasteNow;

  /// No description provided for @tasteTimeline.
  ///
  /// In en, this message translates to:
  /// **'Along the way'**
  String get tasteTimeline;

  /// No description provided for @tasteTimelineBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 snapshot} other{{count} snapshots}} of your Musical DNA from this period.'**
  String tasteTimelineBody(int count);

  /// No description provided for @tasteNewGenres.
  ///
  /// In en, this message translates to:
  /// **'New genres discovered'**
  String get tasteNewGenres;

  /// No description provided for @tasteNoNewGenres.
  ///
  /// In en, this message translates to:
  /// **'No new genres in this period.'**
  String get tasteNoNewGenres;

  /// No description provided for @tasteEmergingArtists.
  ///
  /// In en, this message translates to:
  /// **'Rising favourites'**
  String get tasteEmergingArtists;

  /// No description provided for @tasteNoEmergingArtists.
  ///
  /// In en, this message translates to:
  /// **'Your favourite artists are the same as before.'**
  String get tasteNoEmergingArtists;

  /// No description provided for @tasteNoArtistData.
  ///
  /// In en, this message translates to:
  /// **'Connect Spotify to see how your favourite artists change.'**
  String get tasteNoArtistData;

  /// No description provided for @tasteArtistNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tasteArtistNew;

  /// No description provided for @tasteArtistRose.
  ///
  /// In en, this message translates to:
  /// **'#{from} → #{to}'**
  String tasteArtistRose(int from, int to);

  /// No description provided for @tastePrevious.
  ///
  /// In en, this message translates to:
  /// **'What you listened to more before'**
  String get tastePrevious;

  /// No description provided for @tasteNoPrevious.
  ///
  /// In en, this message translates to:
  /// **'Nothing you used to love has faded.'**
  String get tasteNoPrevious;

  /// No description provided for @tasteFormerTopArtist.
  ///
  /// In en, this message translates to:
  /// **'Was one of your top artists'**
  String get tasteFormerTopArtist;

  /// No description provided for @tasteCommunities.
  ///
  /// In en, this message translates to:
  /// **'Communities you joined'**
  String get tasteCommunities;

  /// No description provided for @tasteNoCommunities.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t join any communities in this period.'**
  String get tasteNoCommunities;

  /// No description provided for @tasteJoinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined on {date}'**
  String tasteJoinedOn(String date);

  /// No description provided for @tasteNoDnaTitle.
  ///
  /// In en, this message translates to:
  /// **'No Musical DNA yet'**
  String get tasteNoDnaTitle;

  /// No description provided for @tasteNoDnaBody.
  ///
  /// In en, this message translates to:
  /// **'Your taste evolution starts once VIBRA has your Musical DNA.'**
  String get tasteNoDnaBody;

  /// No description provided for @tasteTooEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet'**
  String get tasteTooEarlyTitle;

  /// No description provided for @tasteTooEarlyBody.
  ///
  /// In en, this message translates to:
  /// **'Your history starts on {date}. Come back in a few weeks to see how your taste changes.'**
  String tasteTooEarlyBody(String date);

  /// No description provided for @tasteOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Taste history is off'**
  String get tasteOffTitle;

  /// No description provided for @tasteOffBody.
  ///
  /// In en, this message translates to:
  /// **'VIBRA keeps only your current Musical DNA. Turn history on below to start following your taste from today.'**
  String get tasteOffBody;

  /// No description provided for @tasteKeepHistory.
  ///
  /// In en, this message translates to:
  /// **'Keep my taste history'**
  String get tasteKeepHistory;

  /// No description provided for @tasteKeepHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'One Musical DNA snapshot a day, kept up to 400 days and visible only to you.'**
  String get tasteKeepHistoryBody;

  /// No description provided for @tasteTurnOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off taste history?'**
  String get tasteTurnOffTitle;

  /// No description provided for @tasteTurnOffBody.
  ///
  /// In en, this message translates to:
  /// **'Your past snapshots will be deleted and only your current Musical DNA will be kept. Features that compare your taste over time will stop working until you turn it back on.'**
  String get tasteTurnOffBody;

  /// No description provided for @tasteTurnOffConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn off and delete'**
  String get tasteTurnOffConfirm;

  /// No description provided for @tasteError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get tasteError;

  /// No description provided for @profileSectionGenres.
  ///
  /// In en, this message translates to:
  /// **'Favourite genres'**
  String get profileSectionGenres;

  /// No description provided for @profileSectionArtists.
  ///
  /// In en, this message translates to:
  /// **'Favourite artists'**
  String get profileSectionArtists;

  /// No description provided for @profileSectionStats.
  ///
  /// In en, this message translates to:
  /// **'Musical statistics'**
  String get profileSectionStats;

  /// No description provided for @profileSectionSavedSongs.
  ///
  /// In en, this message translates to:
  /// **'Saved songs'**
  String get profileSectionSavedSongs;

  /// No description provided for @profileSectionPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Shared playlists'**
  String get profileSectionPlaylists;

  /// No description provided for @profileSectionEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get profileSectionEvents;

  /// No description provided for @profileSectionCommunities.
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get profileSectionCommunities;

  /// No description provided for @profileSectionCircles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get profileSectionCircles;

  /// No description provided for @profileSectionActivity.
  ///
  /// In en, this message translates to:
  /// **'Musical activity'**
  String get profileSectionActivity;

  /// No description provided for @profileLevelPublic.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get profileLevelPublic;

  /// No description provided for @profileLevelConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get profileLevelConnections;

  /// No description provided for @profileLevelPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get profileLevelPrivate;

  /// No description provided for @profileRelationConnection.
  ///
  /// In en, this message translates to:
  /// **'Your connection'**
  String get profileRelationConnection;

  /// No description provided for @profileRelationMatch.
  ///
  /// In en, this message translates to:
  /// **'Musical match'**
  String get profileRelationMatch;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'On VIBRA since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileSignatureSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, sound signature: {genres}'**
  String profileSignatureSemantics(String name, String genres);

  /// No description provided for @profileNoGenres.
  ///
  /// In en, this message translates to:
  /// **'No favourite genres yet.'**
  String get profileNoGenres;

  /// No description provided for @profileNoArtists.
  ///
  /// In en, this message translates to:
  /// **'No favourite artists yet.'**
  String get profileNoArtists;

  /// No description provided for @profileNoPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists shared yet.'**
  String get profileNoPlaylists;

  /// No description provided for @profileNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events to show.'**
  String get profileNoEvents;

  /// No description provided for @profileNoCommunities.
  ///
  /// In en, this message translates to:
  /// **'Not in any communities yet.'**
  String get profileNoCommunities;

  /// No description provided for @profileNoCircles.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in any circles yet.'**
  String get profileNoCircles;

  /// No description provided for @profileNoSharedCircles.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in any circles together.'**
  String get profileNoSharedCircles;

  /// No description provided for @profileSharedCirclesNote.
  ///
  /// In en, this message translates to:
  /// **'Circles you\'re both in.'**
  String get profileSharedCirclesNote;

  /// No description provided for @profileNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity.'**
  String get profileNoActivity;

  /// No description provided for @profileActivityPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted: {title}'**
  String profileActivityPosted(String title);

  /// No description provided for @profileActivityVibe.
  ///
  /// In en, this message translates to:
  /// **'Daily Vibe: {title}'**
  String profileActivityVibe(String title);

  /// No description provided for @profileActivityJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {name}'**
  String profileActivityJoined(String name);

  /// No description provided for @profileEventGoing.
  ///
  /// In en, this message translates to:
  /// **'Going'**
  String get profileEventGoing;

  /// No description provided for @profileEventMaybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get profileEventMaybe;

  /// No description provided for @profileEventInterested.
  ///
  /// In en, this message translates to:
  /// **'Interested'**
  String get profileEventInterested;

  /// No description provided for @profileStatGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get profileStatGenres;

  /// No description provided for @profileStatDiversity.
  ///
  /// In en, this message translates to:
  /// **'Diversity'**
  String get profileStatDiversity;

  /// No description provided for @profileStatDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Discoveries'**
  String get profileStatDiscoveries;

  /// No description provided for @profileStatPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profileStatPosts;

  /// No description provided for @profileStatConcerts.
  ///
  /// In en, this message translates to:
  /// **'Concerts attended'**
  String get profileStatConcerts;

  /// No description provided for @profileSomePrivate.
  ///
  /// In en, this message translates to:
  /// **'Some sections of this profile are private.'**
  String get profileSomePrivate;

  /// No description provided for @profilePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile privacy'**
  String get profilePrivacyTitle;

  /// No description provided for @profilePrivacyTile.
  ///
  /// In en, this message translates to:
  /// **'Choose who sees each part of your musical profile'**
  String get profilePrivacyTile;

  /// No description provided for @profilePrivacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see each part of your profile. Your photo, name, username and bio are always visible to people you can interact with.'**
  String get profilePrivacyIntro;

  /// No description provided for @profilePrivacyEventsNote.
  ///
  /// In en, this message translates to:
  /// **'Each event also keeps the visibility you chose in Who\'s Going.'**
  String get profilePrivacyEventsNote;

  /// No description provided for @profilePrivacyCirclesNote.
  ///
  /// In en, this message translates to:
  /// **'Others only ever see circles they\'re also in.'**
  String get profilePrivacyCirclesNote;

  /// No description provided for @profilePrivacyPostsNote.
  ///
  /// In en, this message translates to:
  /// **'Each post also keeps its own audience.'**
  String get profilePrivacyPostsNote;

  /// No description provided for @profilePrivacyDnaNote.
  ///
  /// In en, this message translates to:
  /// **'Musical DNA has its own visibility setting.'**
  String get profilePrivacyDnaNote;

  /// No description provided for @profilePrivacyError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get profilePrivacyError;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety & privacy'**
  String get safetyTitle;

  /// No description provided for @safetySettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Blocks, reports, visibility and location in one place'**
  String get safetySettingsSubtitle;

  /// No description provided for @safetyIntro.
  ///
  /// In en, this message translates to:
  /// **'Everything that decides who can reach you and what they see. These rules are enforced by VIBRA\'s servers, everywhere in the app.'**
  String get safetyIntro;

  /// No description provided for @safetyPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get safetyPeople;

  /// No description provided for @safetyBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get safetyBlockedTitle;

  /// No description provided for @safetyBlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nobody blocked} =1{1 person} other{{count} people}}'**
  String safetyBlockedCount(int count);

  /// No description provided for @safetyBlockExplain.
  ///
  /// In en, this message translates to:
  /// **'Blocking works everywhere: messages, comments, posts, stories, communities, circles, events and the radar. It also removes follows and connections between you. The other person isn\'t told.'**
  String get safetyBlockExplain;

  /// No description provided for @safetyNoBlocked.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone'**
  String get safetyNoBlocked;

  /// No description provided for @safetyBlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Blocked on {date}'**
  String safetyBlockedOn(String date);

  /// No description provided for @safetyUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get safetyUnblock;

  /// No description provided for @safetyUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}?'**
  String safetyUnblockTitle(String name);

  /// No description provided for @safetyUnblockBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll be able to find you and contact you again. Follows and connections removed by the block don\'t come back.'**
  String get safetyUnblockBody;

  /// No description provided for @safetyUnblocked.
  ///
  /// In en, this message translates to:
  /// **'{name} is unblocked'**
  String safetyUnblocked(String name);

  /// No description provided for @safetyBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String safetyBlockTitle(String name);

  /// No description provided for @safetyBlockBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see each other anywhere on VIBRA, and follows and connections between you are removed. They won\'t be told.'**
  String get safetyBlockBody;

  /// No description provided for @safetyReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report this person'**
  String get safetyReportUser;

  /// No description provided for @safetyReported.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Our team will review this report.'**
  String get safetyReported;

  /// No description provided for @safetyDuplicateReport.
  ///
  /// In en, this message translates to:
  /// **'You already reported this recently.'**
  String get safetyDuplicateReport;

  /// No description provided for @safetyRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get safetyRateLimited;

  /// No description provided for @safetyUserUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This person isn\'t available.'**
  String get safetyUserUnavailable;

  /// No description provided for @safetyVisibility.
  ///
  /// In en, this message translates to:
  /// **'What others see'**
  String get safetyVisibility;

  /// No description provided for @safetyHiddenFrom.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{hidden from 1 person} other{hidden from {count} people}}'**
  String safetyHiddenFrom(int count);

  /// No description provided for @safetyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Event attendance'**
  String get safetyAttendance;

  /// No description provided for @safetyAttendanceBody.
  ///
  /// In en, this message translates to:
  /// **'chosen per event in Who\'s Going'**
  String get safetyAttendanceBody;

  /// No description provided for @safetyLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get safetyLocation;

  /// No description provided for @safetyLocationExplain.
  ///
  /// In en, this message translates to:
  /// **'Your exact position is never shown to anyone. The radar uses approximate areas, and only when you turn it on.'**
  String get safetyLocationExplain;

  /// No description provided for @safetyRadarVisible.
  ///
  /// In en, this message translates to:
  /// **'On, visible'**
  String get safetyRadarVisible;

  /// No description provided for @safetyRadarHidden.
  ///
  /// In en, this message translates to:
  /// **'On, hidden'**
  String get safetyRadarHidden;

  /// No description provided for @safetyOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get safetyOn;

  /// No description provided for @safetyOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get safetyOff;

  /// No description provided for @safetyData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get safetyData;

  /// No description provided for @safetyAllPrivacy.
  ///
  /// In en, this message translates to:
  /// **'All privacy controls'**
  String get safetyAllPrivacy;

  /// No description provided for @safetyAllPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Consents, notifications and your data export'**
  String get safetyAllPrivacyBody;

  /// No description provided for @safetyReporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get safetyReporting;

  /// No description provided for @safetyReportingBody.
  ///
  /// In en, this message translates to:
  /// **'You can report a person from their profile, and any message, post, comment, story, reply, vibe or community content from its menu. Reports are private. Content reported by several people is hidden while it\'s reviewed, and community moderators can remove content and ban members.'**
  String get safetyReportingBody;

  /// No description provided for @safetyContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get safetyContact;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything that happened, in one place'**
  String get notifCenterSubtitle;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notifSettingsTitle;

  /// No description provided for @notifSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Categories, quiet hours and daily limit'**
  String get notifSettingsSubtitle;

  /// No description provided for @notifToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifToday;

  /// No description provided for @notifThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get notifThisWeek;

  /// No description provided for @notifEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifEarlier;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifMarkAllRead;

  /// No description provided for @notifUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifUnread;

  /// No description provided for @notifUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread notification} other{{count} unread notifications}}'**
  String notifUnreadCount(int count);

  /// No description provided for @notifGrouped.
  ///
  /// In en, this message translates to:
  /// **'{count} updates'**
  String notifGrouped(int count);

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Requests, messages, concerts and everything else will appear here.'**
  String get notifEmptyBody;

  /// No description provided for @notifError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get notifError;

  /// No description provided for @notifPushAll.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notifPushAll;

  /// No description provided for @notifPushAllBody.
  ///
  /// In en, this message translates to:
  /// **'Off: everything still appears in the notification center, nothing is pushed.'**
  String get notifPushAllBody;

  /// No description provided for @notifNoDevice.
  ///
  /// In en, this message translates to:
  /// **'Push isn\'t set up on this device yet. You\'ll still see every notification here.'**
  String get notifNoDevice;

  /// No description provided for @notifCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'What can push'**
  String get notifCategoriesTitle;

  /// No description provided for @notifCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Turning a category off stops its pushes. It still shows up in the notification center.'**
  String get notifCategoriesBody;

  /// No description provided for @notifOncePerDay.
  ///
  /// In en, this message translates to:
  /// **'At most one push a day.'**
  String get notifOncePerDay;

  /// No description provided for @notifCatRequests.
  ///
  /// In en, this message translates to:
  /// **'Vibra requests'**
  String get notifCatRequests;

  /// No description provided for @notifCatRequestsBody.
  ///
  /// In en, this message translates to:
  /// **'New requests and requests accepted.'**
  String get notifCatRequestsBody;

  /// No description provided for @notifCatMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notifCatMessages;

  /// No description provided for @notifCatMessagesBody.
  ///
  /// In en, this message translates to:
  /// **'Direct messages, message requests and event live chats.'**
  String get notifCatMessagesBody;

  /// No description provided for @notifCatCommunities.
  ///
  /// In en, this message translates to:
  /// **'Community activity'**
  String get notifCatCommunities;

  /// No description provided for @notifCatCommunitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Comments on your community posts.'**
  String get notifCatCommunitiesBody;

  /// No description provided for @notifCatCircles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get notifCatCircles;

  /// No description provided for @notifCatCirclesBody.
  ///
  /// In en, this message translates to:
  /// **'Invitations, messages and plans.'**
  String get notifCatCirclesBody;

  /// No description provided for @notifCatConcerts.
  ///
  /// In en, this message translates to:
  /// **'Concert announcements'**
  String get notifCatConcerts;

  /// No description provided for @notifCatConcertsBody.
  ///
  /// In en, this message translates to:
  /// **'New concerts by artists you listen to, and event updates.'**
  String get notifCatConcertsBody;

  /// No description provided for @notifCatReminders.
  ///
  /// In en, this message translates to:
  /// **'Event reminders'**
  String get notifCatReminders;

  /// No description provided for @notifCatRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'A week before, the day before and the day of events you\'re going to.'**
  String get notifCatRemindersBody;

  /// No description provided for @notifCatRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get notifCatRecommendations;

  /// No description provided for @notifCatRecommendationsBody.
  ///
  /// In en, this message translates to:
  /// **'Music recommended by people you follow, and new musical matches.'**
  String get notifCatRecommendationsBody;

  /// No description provided for @notifCatSocial.
  ///
  /// In en, this message translates to:
  /// **'Daily Vibe, stories and posts'**
  String get notifCatSocial;

  /// No description provided for @notifCatSocialBody.
  ///
  /// In en, this message translates to:
  /// **'Comments and replies on what you share.'**
  String get notifCatSocialBody;

  /// No description provided for @notifCatDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Musical discoveries'**
  String get notifCatDiscoveries;

  /// No description provided for @notifCatDiscoveriesBody.
  ///
  /// In en, this message translates to:
  /// **'When someone saves a song you shared.'**
  String get notifCatDiscoveriesBody;

  /// No description provided for @notifCatUpdates.
  ///
  /// In en, this message translates to:
  /// **'VIBRA updates'**
  String get notifCatUpdates;

  /// No description provided for @notifCatUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'Your music week and occasional suggestions.'**
  String get notifCatUpdatesBody;

  /// No description provided for @notifQuietTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notifQuietTitle;

  /// No description provided for @notifQuietBody.
  ///
  /// In en, this message translates to:
  /// **'No pushes during these hours, except direct messages. Everything waits in the notification center.'**
  String get notifQuietBody;

  /// No description provided for @notifQuietFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get notifQuietFrom;

  /// No description provided for @notifQuietTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get notifQuietTo;

  /// No description provided for @notifDailyCap.
  ///
  /// In en, this message translates to:
  /// **'At most {count} pushes a day'**
  String notifDailyCap(int count);

  /// No description provided for @notifCalmExplain.
  ///
  /// In en, this message translates to:
  /// **'To keep notifications useful, VIBRA groups repeated activity into one notification (\"3 new comments\"), doesn\'t push the same group again within 30 minutes, holds pushes during quiet hours, limits low-priority categories to one push a day, and never notifies you about people you\'ve blocked.'**
  String get notifCalmExplain;

  /// No description provided for @circlesMuted.
  ///
  /// In en, this message translates to:
  /// **'Notifications muted'**
  String get circlesMuted;

  /// No description provided for @profileStories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get profileStories;

  /// No description provided for @storyCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'Music story by {name}: {kind}, {hours} h ago'**
  String storyCardSemantics(String name, String kind, int hours);

  /// No description provided for @musicRadarMapSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Affinity map, nobody yet} =1{Affinity map with 1 person} other{Affinity map with {count} people}}'**
  String musicRadarMapSemantics(int count);

  /// No description provided for @musicRadarMapPerson.
  ///
  /// In en, this message translates to:
  /// **'{name}, {percent}% affinity'**
  String musicRadarMapPerson(String name, int percent);

  /// No description provided for @musicRadarMapNote.
  ///
  /// In en, this message translates to:
  /// **'Closer to the centre means more music in common. Positions show affinity, never where anyone is.'**
  String get musicRadarMapNote;

  /// No description provided for @safetyOverviewError.
  ///
  /// In en, this message translates to:
  /// **'Your current settings couldn\'t be loaded. You can still open each section.'**
  String get safetyOverviewError;

  /// No description provided for @homeSignatureEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR MUSIC, YOUR PEOPLE'**
  String get homeSignatureEyebrow;

  /// No description provided for @homeSignatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your people through music'**
  String get homeSignatureTitle;

  /// No description provided for @homeDnaTop.
  ///
  /// In en, this message translates to:
  /// **'{family} leads your sound'**
  String homeDnaTop(String family);

  /// No description provided for @homeDnaEmpty.
  ///
  /// In en, this message translates to:
  /// **'Build it from the genres you love'**
  String get homeDnaEmpty;

  /// No description provided for @homeFrequencyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Discover people who share your taste} =1{1 person on your frequency} other{{count} people on your frequency}}'**
  String homeFrequencyCount(int count);

  /// No description provided for @homeConcertMatchNext.
  ///
  /// In en, this message translates to:
  /// **'Meet people going to {name}'**
  String homeConcertMatchNext(String name);

  /// No description provided for @homeConcertMatchNone.
  ///
  /// In en, this message translates to:
  /// **'Choose a concert to meet people going'**
  String get homeConcertMatchNone;

  /// No description provided for @homeCirclesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Start a small music group} =1{1 circle} other{{count} circles}}'**
  String homeCirclesCount(int count);

  /// No description provided for @homeCirclesInvites.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 invitation waiting} other{{count} invitations waiting}}'**
  String homeCirclesInvites(int count);
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
