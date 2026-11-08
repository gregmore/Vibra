// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Vibra';

  @override
  String get appSlogan => 'N\'écoutez pas seulement la musique. Vivez-la.';

  @override
  String get welcomeTitle => 'Bienvenue sur Vibra';

  @override
  String get onboardingConnectTitle => 'Connectez vos goûts';

  @override
  String get onboardingConnectBody =>
      'Associez Spotify, analysez vos artistes, titres et genres favoris, et transformez vos écoutes en recommandations plus intelligentes.';

  @override
  String get onboardingDiscoverTitle => 'Découvrez les bons lives';

  @override
  String get onboardingDiscoverBody =>
      'Vibra combine localisation, événements et compatibilité musicale pour vous suggérer des concerts vraiment pertinents.';

  @override
  String get onboardingCommunityTitle => 'Vivez la communauté';

  @override
  String get onboardingCommunityBody =>
      'Trouvez des personnes qui partagent vos goûts, activez le mode Live pendant les concerts et rejoignez la conversation en temps réel.';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingGoToLogin => 'Aller à la connexion';

  @override
  String get loginTitle => 'Se connecter à Vibra';

  @override
  String get loginSubtitle =>
      'Découvrez des concerts et des personnes avec qui les partager.';

  @override
  String get loginConsent =>
      'Lis les conditions et les informations sur la confidentialité avant de continuer. Gère tes préférences facultatives dans les paramètres.';

  @override
  String get loginWithSpotify => 'Continuer avec Spotify';

  @override
  String get loginWithGoogle => 'Continuer avec Google';

  @override
  String get loginWithApple => 'Continuer avec Apple';

  @override
  String get loginWithEmail => 'E-mail';

  @override
  String get authFailed => 'Échec de l\'authentification';

  @override
  String get authErrorOccurred => 'Une erreur est survenue';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsHeaderNotificationsPrivacy =>
      'Notifications et confidentialité';

  @override
  String get settingsSubtitleNotificationsPrivacy =>
      'Préférences, compte et gestion des données';

  @override
  String get settingsOptionCompatibleEvents =>
      'Notifications d\'événements compatibles';

  @override
  String get settingsOptionHighMatchAlerts =>
      'Alertes d\'utilisateurs hautement compatibles';

  @override
  String get settingsOptionLiveChat => 'Chat en direct pendant les concerts';

  @override
  String get settingsOptionDiscoverVisible => 'Profil visible dans Discover';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSub =>
      'Vérifiez les autorisations de l\'appareil et l\'état des notifications push';

  @override
  String get settingsNotificationsSnackbar =>
      'Pour recevoir des notifications, connectez-vous et activez celles de Vibra dans les réglages de l’appareil.';

  @override
  String get settingsPrivacyPolicy => 'Politique de Confidentialité';

  @override
  String get settingsPrivacyPolicySub =>
      'Utilisation des données, consentements et droits des utilisateurs';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsTermsOfServiceSub =>
      'Règles d\'utilisation, responsabilités et conditions de service';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsSupportSub => 'Aide, contacts et options d\'assistance';

  @override
  String get settingsAbout => 'À propos de Vibra';

  @override
  String get settingsAboutSub =>
      'Version de l\'application, identifiants et aperçu du produit';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutConfirmTitle => 'Se déconnecter';

  @override
  String get settingsLogoutConfirmBody =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get settingsLogoutAll => 'Se déconnecter de tous les appareils';

  @override
  String get settingsLogoutAllConfirmTitle =>
      'Se déconnecter de tous les appareils';

  @override
  String get settingsLogoutAllConfirmBody =>
      'Êtes-vous sûr de vouloir vous déconnecter de tous les appareils ? Vous serez déconnecté partout.';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountConfirmBody =>
      'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.';

  @override
  String get settingsDelete => 'Supprimer';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSub =>
      'Sélectionnez votre langue préférée pour l\'application';

  @override
  String get settingsLanguageSystem => 'Langue du système';

  @override
  String homeGreeting(String username) {
    return 'Bonjour $username, on écoute fort ce soir.';
  }

  @override
  String get homeForYouTitle => 'Pour Vous';

  @override
  String get homeForYouSubtitle =>
      'Événements avec un score de compatibilité supérieur à 70';

  @override
  String get homeNearYouTitle => 'Autour de Vous';

  @override
  String get homeNearYouSubtitle => 'Sélectionnés dans un rayon GPS de 50 km';

  @override
  String get homeNearYouAction => 'Ouvrir la carte';

  @override
  String get homeTrendingTitle => 'Tendances';

  @override
  String get homeTrendingSubtitle =>
      'Les événements les plus suivis de la semaine';

  @override
  String get homeTrendingAction => 'Voir tout';

  @override
  String get settingsSpotifyAccount => 'Compte Spotify';

  @override
  String get settingsSpotifyDisconnected =>
      'Déconnecté — Connectez pour des recommandations';

  @override
  String get settingsSpotifyDisconnect => 'Déconnecter';

  @override
  String get settingsSpotifyDisconnectConfirmTitle => 'Déconnecter Spotify';

  @override
  String get settingsSpotifyDisconnectConfirmBody =>
      'Vibra supprimera votre connexion Spotify, les artistes et genres synchronisés, l’historique d’écoute et les affinités musicales. Les suggestions d’événements ne seront plus personnalisées.';

  @override
  String get settingsSpotifyDisconnectedSuccess =>
      'Spotify déconnecté avec succès';

  @override
  String get settingsGenerateCompatibleUsers =>
      'Générer des utilisateurs compatibles';

  @override
  String get settingsGenerateCompatibleUsersSub =>
      'Créez des bots avec des goûts musicaux similaires';

  @override
  String get settingsGenerateCompatibleUsersLoading =>
      'Génération en cours... Veuillez patienter.';

  @override
  String get settingsGenerateCompatibleUsersSuccess => 'Générés avec succès !';

  @override
  String settingsError(String error) {
    return 'Erreur : $error';
  }

  @override
  String settingsLogoutError(String error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String settingsSpotifyConnected(String username) {
    return 'Connecté en tant que @$username';
  }

  @override
  String get settingsDeleteAccountError =>
      'Impossible de supprimer votre compte. Réessayez ou contactez l’assistance.';

  @override
  String get eventDetailChat => 'Chat';

  @override
  String get eventDetailTicketsUnavailable =>
      'Lien vers les billets indisponible.';

  @override
  String get eventDetailTicketsError =>
      'Impossible d\'ouvrir le lien du billet.';

  @override
  String get eventDetailBuyTickets => 'Acheter des billets';

  @override
  String get eventDetailAttendanceConfirmed => 'Présence confirmée !';

  @override
  String get eventDetailAttend => 'Je participe';

  @override
  String get eventDetailAttendanceMaybe => 'Présence définie sur Peut-être';

  @override
  String get eventDetailMaybe => 'Peut-être';

  @override
  String get eventDetailAttendanceNotGoing =>
      'Vous avez indiqué que vous n\'irez pas';

  @override
  String get eventDetailNotGoing => 'J\'y vais pas';

  @override
  String get eventDetailCopied => 'Détails de l\'événement copiés !';

  @override
  String get exploreSearchEvents => 'Rechercher des événements';

  @override
  String get exploreSearchInArea => 'Rechercher dans cette zone';

  @override
  String get exploreSearchingEvents => 'Recherche d\'événements...';

  @override
  String exploreRadius(String radius) {
    return '$radius km';
  }

  @override
  String get friendsTitle => 'Amis';

  @override
  String get chatSendFailed => 'Échec de l\'envoi';

  @override
  String get socialTitle => 'Social';

  @override
  String socialRequestFrom(String userId) {
    return 'Demande de $userId';
  }

  @override
  String get socialOpen => 'Ouvrir';

  @override
  String get userProfileTitle => 'Profil utilisateur';

  @override
  String userProfileCompatibility(String percentage) {
    return '$percentage% de compatibilité';
  }

  @override
  String get userProfileTopArtists => 'Meilleurs artistes';

  @override
  String get userProfileFriendRequestSent => 'Demande d\'ami envoyée !';

  @override
  String get userProfileSendRequest => 'Envoyer la demande';

  @override
  String get userProfileOpenChat => 'Ouvrir le chat';

  @override
  String socialMatchVibraSent(String name) {
    return 'Vibra envoyée à $name ! 🎉';
  }

  @override
  String get socialMatchViewProfile => 'Voir le profil complet';

  @override
  String get socialMatchIgnore => 'Ignorer';

  @override
  String get userProfileNotAvailableTitle => 'Profil non disponible';

  @override
  String get userProfileNotAvailableMessage =>
      'Aucun utilisateur sélectionné ou aucune correspondance disponible pour le moment.';

  @override
  String get userProfileEvents => 'Concerts passés/à venir';

  @override
  String get socialDiscoverUsers => 'Découvrir des utilisateurs';

  @override
  String get socialHighCompatibility =>
      'Utilisateurs avec une compatibilité musicale élevée';

  @override
  String socialRequestsCount(int count) {
    return 'Demandes ($count)';
  }

  @override
  String get socialPendingFriendships => 'Amitiés en attente';

  @override
  String get socialRequestsToManage => 'Demandes à gérer';

  @override
  String get socialPeopleSection => 'Personnes';

  @override
  String get socialAffinityTitle => 'Trouvez vos affinités musicales';

  @override
  String socialRequestsPreview(String name, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$name et $others autres personnes souhaitent se connecter',
      one: '$name et 1 autre personne souhaitent se connecter',
      zero: '$name souhaite se connecter avec vous',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navEvents => 'Événements';

  @override
  String get navVibra => 'Vibra';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get friendsYourFriends => 'Vos amis';

  @override
  String get friendsYourConnections => 'Vos connexions sur Vibra';

  @override
  String get friendsNoFriendsYet => 'Pas encore d\'amis';

  @override
  String get friendsGoToExplore =>
      'Explorez la communauté pour trouver des personnes et envoyer des demandes d’amis.';

  @override
  String get friendsSentRequests => 'Demandes envoyées';

  @override
  String get friendsWaitingForReply => 'En attente de réponse';

  @override
  String get friendsPendingApproval => 'En attente d\'approbation';

  @override
  String get socialMatchNewAffinity => 'NOUVELLE AFFINITÉ';

  @override
  String get socialMatchScore => 'AFFINITÉ MUSICALE';

  @override
  String get socialMatchWhyMatched => 'POURQUOI VOUS MATCHEZ';

  @override
  String socialMatchCommonEvents(String count) {
    return 'Live nearby • $count événements en commun';
  }

  @override
  String get socialMatchSendVibra => 'Envoyer Vibra';

  @override
  String get exploreSearchHint => 'Rechercher par nom ou ville (ex. Milan)';

  @override
  String get exploreInteractiveMap => 'Carte interactive';

  @override
  String get exploreLiveAroundYou =>
      'Explorez les événements en direct autour de vous en temps réel';

  @override
  String exploreSearchRadius(int radius) {
    return 'RAYON DE RECHERCHE : $radius KM';
  }

  @override
  String get exploreFindEventsNearYou =>
      'Trouvez des événements près de chez vous';

  @override
  String get exploreMusicGenre => 'Genre musical';

  @override
  String get exploreFilterByGenre => 'Filtrez par vos genres préférés';

  @override
  String get exploreGenreAll => 'Tous';

  @override
  String get friendsReceivedRequests => 'Demandes reçues';

  @override
  String get friendsAcceptOrReject =>
      'Acceptez ou refusez de nouvelles connexions';

  @override
  String get friendsWantsToConnect => 'Veut se connecter avec vous';

  @override
  String socialMatchListenBoth(String artists) {
    return 'Vous écoutez tous les deux $artists';
  }

  @override
  String socialMatchCityEvents(String city, String count) {
    return '$city • $count événements en commun';
  }

  @override
  String get myProfileConnectSpotify => 'Connecter Spotify';

  @override
  String get myProfileOverview => 'Aperçu';

  @override
  String get myProfileOverviewSubtitle => 'Accès rapide aux zones du profil';

  @override
  String get myProfileSettings => 'Paramètres';

  @override
  String get myProfileMusicStats => 'Statistiques musicales';

  @override
  String get myProfileMusicStatsSubtitle =>
      'Artistes principaux, genres et carte thermique d\'écoute';

  @override
  String get myProfileMyEvents => 'Mes événements';

  @override
  String myProfileMyEventsSubtitle(String count) {
    return '$count événements enregistrés, à venir et passés';
  }

  @override
  String get myProfileSettingsSubtitle =>
      'Confidentialité, notifications, compte et déconnexion';

  @override
  String get myEventsUpcoming => 'À venir';

  @override
  String get myEventsPast => 'Passés';

  @override
  String get myEventsPastSubtitle => 'Votre historique de concerts';

  @override
  String get myEventsPastEmpty => 'Vous n’avez pas encore d’événements passés.';

  @override
  String get myEventsSearchHint =>
      'Rechercher des événements, artistes ou lieux';

  @override
  String get myEventsSearchEmpty =>
      'Aucun événement ne correspond à votre recherche.';

  @override
  String get myEventsClearSearch => 'Effacer la recherche';

  @override
  String get myEventsExplore => 'Explorer les événements';

  @override
  String get inboxUnread => 'Non lus';

  @override
  String get inboxNoResults => 'Aucune conversation trouvée.';

  @override
  String get inboxNoResultsBody =>
      'Essayez un autre nom ou effacez les filtres pour voir tous les messages.';

  @override
  String get inboxClearFilters => 'Effacer les filtres';

  @override
  String get homeFeedError => 'Les événements n’ont pas pu être chargés.';

  @override
  String get homeFeedErrorBody =>
      'Réessayez dans un instant. Vous pouvez toujours explorer la carte.';

  @override
  String get homeFeedEmpty => 'Il y a de la place pour une nouvelle soirée.';

  @override
  String get homeFeedEmptyBody =>
      'Explorez la carte pour trouver votre prochain concert.';

  @override
  String get socialSearchHint => 'Rechercher des personnes ou artistes';

  @override
  String get socialSearchEmpty => 'Aucune personne trouvée.';

  @override
  String get socialSearchEmptyBody => 'Essayez un autre nom ou artiste.';

  @override
  String get socialDiscoverEmpty => 'Les nouvelles connexions commencent ici.';

  @override
  String get socialDiscoverEmptyBody =>
      'Complétez votre profil et connectez Spotify pour trouver des personnes aux goûts similaires.';

  @override
  String get chatSendMessage => 'Envoyer un message';

  @override
  String get chatLoadError => 'La conversation n’a pas pu être chargée.';

  @override
  String get chatDraftRecovered =>
      'Le message n’a pas été envoyé. Son texte a été restauré dans le champ de saisie.';

  @override
  String get eventLocationUnknown =>
      'La position exacte n’est pas encore disponible.';

  @override
  String get eventDirections => 'Itinéraire';

  @override
  String get eventDirectionsError => 'L’itinéraire n’a pas pu être ouvert.';

  @override
  String get inboxDeleteTitle => 'Supprimer la conversation ?';

  @override
  String get inboxDeleteBody =>
      'La conversation sera retirée de votre boîte de réception. Les messages de l’autre personne ne seront pas supprimés.';

  @override
  String get inboxDeleteAction => 'Supprimer la conversation';

  @override
  String get inboxDeleteSuccess => 'Conversation supprimée.';

  @override
  String get inboxDeleteError =>
      'La conversation n’a pas été supprimée. Réessayez.';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get eventCopyDetails => 'Copier les détails de l’événement';

  @override
  String get eventCopyError => 'Les détails n’ont pas pu être copiés.';

  @override
  String get eventCancelled => 'Événement annulé';

  @override
  String get eventTicketsOffsale => 'Billets non disponibles à la vente';

  @override
  String get socialMatchSendFailed =>
      'La Vibra n’a pas été envoyée. Réessayez : le profil est toujours disponible.';

  @override
  String get myEventsTitle => 'Mes événements';

  @override
  String get myEventsGoing => 'J\'y vais';

  @override
  String get myEventsGoingSubtitle => 'Événements confirmés ou à venir';

  @override
  String get myEventsGoingEmpty =>
      'Vous n\'avez pas encore confirmé votre présence à un événement.\nExplorez et trouvez vos prochains concerts !';

  @override
  String get myEventsSaved => 'Enregistrés';

  @override
  String get myEventsSavedSubtitle => 'À garder à l\'œil';

  @override
  String get myEventsSavedEmpty =>
      'Aucun événement enregistré.\nEnregistrez les événements qui vous intéressent pour ne pas les manquer.';

  @override
  String get chatEmptyTitle => 'Aucun message';

  @override
  String get chatEmptyMessage => 'Commencez la conversation !';

  @override
  String get chatInputHint => 'Écrivez un message...';

  @override
  String get socialMatchScanningTitle => 'ANALYSE DES VIBRATIONS';

  @override
  String get socialMatchScanningSubtitle =>
      'Recherche de personnes ayant des goûts musicaux similaires à proximité...';

  @override
  String get socialMatchEmptyTitle => 'Aucune affinité à proximité';

  @override
  String get socialMatchEmptyMessage =>
      'Vos vibrations musicales sont uniques ! Il n’y a personne avec des goûts similaires à proximité pour le moment...';

  @override
  String get socialMatchEmptyAction => 'Découvrir les événements à proximité';

  @override
  String get socialMatchEmptySecondary => 'Chercher à nouveau';

  @override
  String get musicStatsTitle => 'Statistiques Musicales';

  @override
  String musicStatsSyncError(String error) {
    return 'Erreur de synchronisation : $error';
  }

  @override
  String get musicStatsTopArtists => 'Meilleurs artistes';

  @override
  String get musicStatsTopArtistsSub =>
      'Score basé sur les préférences Spotify';

  @override
  String get musicStatsHeatmap => 'Carte thermique d’écoute';

  @override
  String get musicStatsHeatmapSub => 'Répartition hebdomadaire de vos écoutes';

  @override
  String get liveScreenTitle => 'Live Vibra';

  @override
  String get liveScreenSendFailed =>
      'Échec de l’envoi. Vérifiez votre session.';

  @override
  String get liveScreenActivateMode => 'Activer le mode Live';

  @override
  String get liveScreenPresentNowTitle => 'Présents maintenant';

  @override
  String get liveScreenPresentNowSub =>
      'Participants avec une haute compatibilité musicale';

  @override
  String get liveScreenChatTitle => 'Chat de l’événement';

  @override
  String get liveScreenChatSub => 'Le chat se ferme automatiquement dans 24h';

  @override
  String get eventDetailNotAvailableTitle => 'Événement indisponible';

  @override
  String get eventDetailNotAvailableMsg =>
      'Cet événement n’est plus disponible.';

  @override
  String get eventDetailMapTitle => 'Carte du lieu';

  @override
  String get eventDetailMapSub => 'Lieu de l’événement';

  @override
  String get eventDetailAttendeesTitle => 'Participants';

  @override
  String get eventDetailAttendeesSub =>
      'Utilisateurs avec compatibilité musicale';

  @override
  String get spotifyAuthStep1Title => '1. Autorisation OAuth';

  @override
  String get spotifyAuthStep1Sub =>
      'Connexion sécurisée sur le site officiel de Spotify';

  @override
  String get spotifyAuthStep2Title => '2. Échange d’informations';

  @override
  String get spotifyAuthStep2Sub =>
      'Génération de clés sécurisées et chiffrement de jetons';

  @override
  String get spotifyAuthStep3Title => '3. Synchronisation des goûts';

  @override
  String get spotifyAuthStep3Sub => 'Analyse des artistes et pistes';

  @override
  String get spotifyAuthCancelled =>
      'Connexion annulée. Vous devez autoriser Vibra pour les recommandations.';

  @override
  String spotifyAuthError(String error) {
    return 'Une erreur s’est produite : $error';
  }

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get legalPrivacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get legalPrivacySec1 => 'Données collectées par Vibra';

  @override
  String get legalPrivacySec2 => 'Pourquoi Vibra les utilise';

  @override
  String get legalPrivacySec3 => 'Vos contrôles';

  @override
  String get legalPrivacySec4 => 'Contact confidentialité';

  @override
  String get legalTermsTitle => 'Conditions d’utilisation';

  @override
  String get legalTermsSec1 => 'Utilisation de Vibra';

  @override
  String get legalTermsSec2 => 'Services tiers';

  @override
  String get legalTermsSec3 => 'Contenu et comportement';

  @override
  String get legalTermsSec4 => 'Contact légal';

  @override
  String get legalSupportTitle => 'Support';

  @override
  String get legalSupportSec1 => 'E-mail d’assistance';

  @override
  String get legalSupportSec2 => 'Problèmes couverts';

  @override
  String get legalSupportSec3 => 'À vérifier d’abord';

  @override
  String get legalAboutTitle => 'À propos de Vibra';

  @override
  String get legalAboutSec1 => 'Version';

  @override
  String get legalAboutSec2 => 'Identifiants de plateforme';

  @override
  String get legalAboutSec3 => 'Ce que fait Vibra';

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
  String get spotifyAuthCancelledTitle => 'Échec de l’authentification';

  @override
  String get errorTitle => 'Erreur Système';

  @override
  String get legalPrivacyBody1 =>
      'Données du compte, profil musical, participation aux événements, messages, activité dans le chat en direct, localisation si autorisée et jetons push.';

  @override
  String get legalPrivacyBody2 =>
      'Pour authentifier les utilisateurs, générer des recommandations et envoyer des notifications.';

  @override
  String get legalPrivacyBody3 =>
      'Vous pouvez révoquer les permissions, déconnecter les services, demander la suppression et gérer la visibilité depuis les paramètres du compte.';

  @override
  String legalPrivacyBody4(String email) {
    return 'Demandes de confidentialité : $email';
  }

  @override
  String get legalTermsBody1 =>
      'En utilisant Vibra, vous acceptez d’utiliser l’application légalement.';

  @override
  String get legalTermsBody2 =>
      'Spotify, Supabase, Firebase et les fournisseurs d’événements peuvent être utilisés pour fournir les fonctionnalités principales.';

  @override
  String get legalTermsBody3 =>
      'Les utilisateurs sont responsables du contenu publié. Vibra peut suspendre les comptes enfreignant les règles.';

  @override
  String legalTermsBody4(String email) {
    return 'Demandes légales et communications formelles : $email';
  }

  @override
  String legalSupportBody1(String email) {
    return '$email';
  }

  @override
  String get legalSupportBody2 =>
      'Problèmes de connexion, Spotify, événements.';

  @override
  String get legalSupportBody3 =>
      'Vérifiez la connexion, les autorisations de l’appareil et votre connexion au compte. Si le problème persiste, signalez-le depuis les réglages.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Paquet Android : $android\nIdentifiant iOS : $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra vous aide à découvrir des événements, explorer la carte, enregistrer des concerts, rencontrer des personnes et discuter. Les fonctionnalités Spotify ne sont disponibles que lorsque le service est activé.';

  @override
  String legalAboutBody4(String email) {
    return '$email';
  }

  @override
  String get homeGreetingMorning => 'Bonjour 👋';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi 👋';

  @override
  String get homeGreetingEvening => 'Bonsoir 🌙';

  @override
  String get eventCardTBA => 'À définir';

  @override
  String get eventCardCity => 'Ville';

  @override
  String get legalPrivacySubtitle =>
      'Un résumé des informations de confidentialité disponibles dans l’application, incluant les catégories de données traitées et les finalités d’utilisation.';

  @override
  String get legalTermsSubtitle =>
      'Un résumé des règles, responsabilités et conditions de service applicables à l’utilisation de Vibra.';

  @override
  String get legalSupportSubtitle =>
      'Informations de support pour l’accès au compte, les notifications, la connexion Spotify et les fonctionnalités en direct.';

  @override
  String get legalAboutSubtitle =>
      'Événements, carte et communauté pour partager de nouvelles sorties.';

  @override
  String get exploreShowAllEvents => 'Afficher tous les événements';

  @override
  String get musicStatsSyncSpotify => 'Synchroniser Spotify';

  @override
  String get liveModeDisabled => 'Le mode Live est désactivé';

  @override
  String get authCreateAccount => 'Créer un Compte';

  @override
  String get authLoginWithEmail => 'Se connecter avec Email';

  @override
  String get authUsername => 'Nom d’utilisateur';

  @override
  String get authUsernameHint => 'Entrez un nom d’utilisateur';

  @override
  String get authEmail => 'Adresse Email';

  @override
  String get authEmailHint => 'Entrez votre email';

  @override
  String get authEmailInvalid => 'Entrez un email valide';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPasswordHint => 'Entrez votre mot de passe';

  @override
  String get authPasswordShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get authRegister => 'S’inscrire';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authAlreadyHaveAccount =>
      'Vous avez déjà un compte ? Se connecter';

  @override
  String get authDontHaveAccount => 'Vous n’avez pas de compte ? S’inscrire';

  @override
  String get authGenericError => 'Une erreur s’est produite';

  @override
  String get eventCardLocation => 'Lieu';

  @override
  String get matchScore => 'AFFINITÉ MUSICALE';

  @override
  String get userGeneric => 'Utilisateur';

  @override
  String get spotifyConnectTitle => 'Connecter Spotify';

  @override
  String get spotifyConnectSubtitle =>
      'Connectez votre compte pour synchroniser vos artistes préférés et débloquer des recommandations personnalisées pour les concerts.';

  @override
  String get spotifyConnectOnboarding => 'Flux d’intégration';

  @override
  String get spotifyConnectPrivacyDesc =>
      'Vos données sont protégées par le cryptage AES-GCM sur le serveur.';

  @override
  String get spotifyConnectContinue => 'Continuer et Explorer';

  @override
  String get spotifyConnectRetry => 'Réessayer la connexion';

  @override
  String get spotifyConnectAction => 'Connecter mon Spotify';

  @override
  String get spotifyConnectSkip => 'Passer pour l’instant';

  @override
  String get homeSpotifySyncTitle =>
      'Débloquer les Recommandations Personnalisées';

  @override
  String get homeSpotifySyncSub => 'Synchronisez vos écoutes musicales';

  @override
  String get homeSpotifySyncDesc =>
      'Connectez Spotify pour recevoir des recommandations d’événements et trouver des personnes ayant les mêmes goûts que vous.';

  @override
  String get homeSpotifySyncAction => 'CONNECTER SPOTIFY';

  @override
  String get loginBackToWelcome => 'Revenir à l’écran de bienvenue';

  @override
  String get authOr => 'ou';

  @override
  String get authEmailLoginSubtitle =>
      'Saisis tes identifiants pour te connecter et découvrir des concerts.';

  @override
  String get authEmailRegisterSubtitle =>
      'Saisis tes identifiants pour t’inscrire et commencer à profiter des concerts.';

  @override
  String get authAgeConfirmation => 'Je confirme avoir au moins 18 ans.';

  @override
  String get authAgeExplanation =>
      'Vibra facilite les rencontres et ne s’adresse pas aux mineurs.';

  @override
  String get authAgeRequired =>
      'Tu dois confirmer avoir au moins 18 ans pour créer un compte.';

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get spotifyUnavailableTitle => 'Spotify en pause';

  @override
  String get spotifyUnavailableBody =>
      'Spotify et les affinités musicales sont temporairement désactivés. Les événements, amis et chats restent disponibles.';

  @override
  String get launchExploreTitle => 'Trouve ton prochain concert';

  @override
  String get launchExploreBody =>
      'Recherche des artistes, explore la carte et enregistre les événements proches.';

  @override
  String get launchCommunityTitle => 'Rejoins la communauté';

  @override
  String get launchCommunityBody =>
      'Trouve des personnes, ajoute des amis et organise des concerts dans tes chats.';

  @override
  String get launchSavedTitle => 'Ton agenda de concerts';

  @override
  String get launchSavedBody =>
      'Enregistre des concerts et retrouve ceux auxquels tu veux participer.';

  @override
  String get launchCommunitySubtitle =>
      'Recherche des personnes par nom ou pseudo';

  @override
  String get launchCommunityEmptyTitle => 'Aucune personne trouvée';

  @override
  String get launchCommunityEmptyBody =>
      'Essaie un autre nom ou reviens plus tard.';

  @override
  String get launchCommunityLoadError =>
      'Impossible de charger les personnes. Réessaie.';

  @override
  String get commonOK => 'OK';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonAll => 'Tous';

  @override
  String get commonConnect => 'Connecter';

  @override
  String get commonActive => 'Actif';

  @override
  String get commonNotNow => 'Pas maintenant';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonTryLater => 'Réessayez plus tard.';

  @override
  String get commonConnectionError => 'Erreur de connexion';

  @override
  String commonLoadingLabel(String label) {
    return '$label, chargement en cours';
  }

  @override
  String commonSelectedLabel(String label) {
    return '$label, sélectionné';
  }

  @override
  String commonNotSelectedLabel(String label) {
    return '$label, non sélectionné';
  }

  @override
  String get commonOnline => 'En ligne';

  @override
  String get commonAvatar => 'Avatar';

  @override
  String commonPercentLabel(int percentage, String label) {
    return '$percentage pour cent $label';
  }

  @override
  String commonAvatarAffinity(String name, int percentage) {
    return '$name, affinité de $percentage pour cent';
  }

  @override
  String get commonRegistrationComplete => 'Inscription terminée';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileBack => 'Retour au profil';

  @override
  String get profilePersonalSpace => 'ESPACE PERSONNEL';

  @override
  String get profileSpotifyConnected => 'Spotify connecté';

  @override
  String get profileFollowers => 'Abonnés';

  @override
  String get profileFollowing => 'Abonnements';

  @override
  String get profileOpenMusicStats => 'Ouvrir les statistiques musicales';

  @override
  String get profileYourVibra => 'VOTRE VIBRA';

  @override
  String get profileInRotation => 'En rotation';

  @override
  String get profileSyncMusicBody =>
      'Synchronisez Spotify pour voir votre profil musical.';

  @override
  String get profileShapeTitle => 'Donnez forme à votre Vibra';

  @override
  String get profileShapeBody =>
      'Connectez Spotify pour montrer votre identité musicale.';

  @override
  String get profileUsernameEmpty =>
      'Le nom d’utilisateur ne peut pas être vide';

  @override
  String get profileUsernameShort => 'Au moins 3 caractères';

  @override
  String get profileUsernameCharacters =>
      'Utilisez uniquement des lettres, chiffres, _ ou .';

  @override
  String get profileUsernameCharactersOnboarding =>
      'Utilisez uniquement des lettres, chiffres et tirets bas';

  @override
  String get profileUsernameTaken => 'Nom d’utilisateur déjà utilisé';

  @override
  String get profileUsernameTakenRetry =>
      'Ce nom d’utilisateur est déjà utilisé. Choisissez-en un autre.';

  @override
  String get profilePhotoPermission =>
      'Autorisez l’accès aux photos dans les réglages de l’appareil et réessayez.';

  @override
  String get profilePhotoPickError =>
      'Impossible de sélectionner la photo. Réessayez.';

  @override
  String get profilePhotoTitle => 'Photo de profil';

  @override
  String get profilePhotoGallery => 'Choisir dans la galerie';

  @override
  String get profilePhotoGalleryBody =>
      'Sélectionnez une photo sur votre appareil';

  @override
  String get profilePhotoCamera => 'Prendre une photo';

  @override
  String get profilePhotoCameraBody =>
      'Utilisez l’appareil photo pour prendre une nouvelle photo';

  @override
  String get profilePhotoRemove => 'Supprimer la photo';

  @override
  String get profilePhotoRestore => 'Rétablir l’avatar par défaut';

  @override
  String get profileSaved => 'Profil mis à jour !';

  @override
  String get profileSaveError =>
      'Impossible d’enregistrer votre profil. Réessayez dans un instant.';

  @override
  String get profilePhotoChange => 'Modifier la photo de profil';

  @override
  String get profileUsernameExample => 'ex. musique_fan';

  @override
  String get profileName => 'Nom';

  @override
  String get profileNameHint => 'Votre nom ou pseudo';

  @override
  String get profileNameEmpty => 'Le nom ne peut pas être vide';

  @override
  String get profileDescription => 'Description';

  @override
  String get profileDescriptionHint => 'Parlez-nous de vous…';

  @override
  String get profileMusicStreaming => 'Musique et streaming';

  @override
  String get profileAccountConnected => 'Compte connecté';

  @override
  String get profileConnectSuggestions =>
      'Connectez votre compte pour de meilleures suggestions';

  @override
  String get profileSaveChanges => 'Enregistrer les modifications';

  @override
  String get homeYourSoundToday => 'VOTRE SON, AUJOURD’HUI';

  @override
  String get homeSpotifySynced =>
      'Spotify synchronisé · les suggestions apprennent de vous';

  @override
  String get homeSpotifyPersonalize =>
      'Connectez Spotify pour personnaliser vos suggestions';

  @override
  String get homeCompleteProfile => 'Complétez votre profil';

  @override
  String get homeShapeVibra => 'Personnalisez votre Vibra';

  @override
  String get homeNextEvent => 'LE PROCHAIN';

  @override
  String get homeNearbyEyebrow => 'À PROXIMITÉ';

  @override
  String get homeTrendingEyebrow => 'EN CE MOMENT';

  @override
  String get settingsPrivateMessages => 'Messages et demandes privés';

  @override
  String get settingsPersonalizedUpdates =>
      'Actualités et rappels personnalisés';

  @override
  String get settingsMusicWeek => 'Votre semaine musicale';

  @override
  String get settingsMusicWeekBody =>
      'Événements et affinités sélectionnés pour vous';

  @override
  String get settingsWeekly => 'Hebdomadaire';

  @override
  String get settingsMonthly => 'Mensuel';

  @override
  String get settingsNever => 'Jamais';

  @override
  String get settingsPrivacyData => 'Confidentialité et données personnelles';

  @override
  String get settingsPrivacyDataBody =>
      'Consentements, exportation et suppression des données';

  @override
  String get settingsHelpCenter => 'Centre d’aide';

  @override
  String get settingsHelpCenterBody =>
      'Aide pour les comptes, événements, discussions et Spotify';

  @override
  String get settingsReportProblem => 'Signaler un problème';

  @override
  String get settingsReportProblemBody =>
      'Envoyez des diagnostics anonymisés et une capture facultative';

  @override
  String get privacySaveError =>
      'Impossible d’enregistrer la préférence. Réessayez.';

  @override
  String get privacyExportTitle => 'Exportation de vos données';

  @override
  String get privacySaveJSON => 'Enregistrer JSON';

  @override
  String get privacyCopyJSON => 'Copier JSON';

  @override
  String get privacyCopiedJSON => 'JSON copié dans le presse-papiers.';

  @override
  String get privacyExportError =>
      'Exportation indisponible. Réessayez plus tard.';

  @override
  String privacyExportSaved(String path) {
    return 'Exportation enregistrée dans $path';
  }

  @override
  String get privacyIntro =>
      'Choisissez séparément chaque usage facultatif de vos données. Vous pouvez changer d’avis à tout moment.';

  @override
  String get privacyPreciseLocation => 'Position précise';

  @override
  String get privacyPreciseLocationBody =>
      'Pour les événements proches et les fonctionnalités Live. Conservée au maximum 30 jours.';

  @override
  String get privacySpotifyMatching => 'Spotify pour l’affinité musicale';

  @override
  String get privacySpotifyMatchingBody =>
      'Utilisez les artistes, genres et écoutes synchronisés pour les suggestions et affinités.';

  @override
  String get privacyServiceNotifications => 'Notifications du service';

  @override
  String get privacyServiceNotificationsBody =>
      'Affinités, messages et événements enregistrés.';

  @override
  String get privacyMarketing => 'Communications marketing';

  @override
  String get privacyMarketingBody =>
      'Toujours facultatives ; vous pouvez utiliser l’app sans elles.';

  @override
  String get privacyExportAction => 'Exporter mes données';

  @override
  String get privacyExportBody =>
      'Générez une copie JSON lisible de votre profil, discussions, événements et interactions, avec les anciennes données Spotify si elles existent.';

  @override
  String get privacyDeletionBody =>
      'La suppression du compte efface ses données. Les messages envoyés deviennent anonymes et leur contenu et médias sont supprimés. Les sauvegardes suivent la durée de conservation indiquée dans la politique de confidentialité.';

  @override
  String get appearanceTitle => 'Apparence';

  @override
  String get appearanceBody =>
      'Choisissez le thème de l’app ou suivez celui de l’appareil.';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get appearanceDarkBody =>
      'Réduit la luminosité dans les lieux peu éclairés';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceLightBody => 'Surfaces lumineuses et ombres douces';

  @override
  String get appearanceSystem => 'Automatique (système)';

  @override
  String get appearanceSystemBody =>
      'S’adapte aux changements des réglages de l’appareil';

  @override
  String get onboardingBack => 'Retour à l’étape précédente';

  @override
  String get onboardingStart => 'Commençons';

  @override
  String get onboardingProfileTitle => 'Votre profil';

  @override
  String get onboardingProfileBody => 'Comment les autres vous verront';

  @override
  String get onboardingSkipToHome => 'Passer le reste et aller à l’accueil';

  @override
  String get onboardingPhotoUploading => 'Importation de la photo de profil';

  @override
  String get onboardingPhotoSelect => 'Choisir ou modifier la photo de profil';

  @override
  String get onboardingUsernameExample => 'ex. vibra_user';

  @override
  String get onboardingRequired => 'OBLIGATOIRE';

  @override
  String get onboardingSpotifyBody =>
      'Trouvez des événements selon vos écoutes et découvrez votre affinité musicale avec les autres.';

  @override
  String get onboardingSpotifyCancelled =>
      'Connexion annulée. Réessayez ou passez pour le moment.';

  @override
  String get onboardingSpotifyError =>
      'Impossible de connecter le compte. Réessayez plus tard.';

  @override
  String get onboardingLocationTitle => 'Événements près de vous';

  @override
  String get onboardingLocationBody =>
      'Activez la position pour découvrir les concerts et lieux de votre région.';

  @override
  String get onboardingLocationDenied =>
      'Autorisation refusée définitivement. Vous pouvez l’activer plus tard dans les réglages de l’appareil.';

  @override
  String get onboardingAllowLocation => 'Autoriser la position';

  @override
  String get onboardingNotificationsTitle => 'Restez au courant';

  @override
  String get onboardingNotificationsBody =>
      'Recevez des notifications pour les événements enregistrés, demandes d’amis et messages.';

  @override
  String get onboardingNotificationsDenied =>
      'Notifications refusées. Vous pouvez les activer dans les réglages de l’appareil.';

  @override
  String get onboardingAllowNotifications => 'Activer les notifications';

  @override
  String get liveAttendanceError =>
      'Impossible de confirmer la présence. Réessayez.';

  @override
  String get liveEventsLoadError =>
      'Impossible de charger les événements Live.';

  @override
  String get liveLocationHelp =>
      'La discussion Live est disponible à moins de 500 m d’un événement, dans les 24 heures avant et après le concert. Activez la position dans les réglages de confidentialité.';

  @override
  String get liveUnavailableHere =>
      'La discussion de cet événement est indisponible à votre position ou à cet instant.';

  @override
  String get liveRefreshLocation => 'Actualiser la position';

  @override
  String get liveEventTitle => 'Événement Live';

  @override
  String get liveConnectionInterrupted =>
      'Connexion à la discussion Live interrompue.';

  @override
  String get liveEmpty => 'Aucun message. Lancez la conversation !';

  @override
  String get liveRetryAttendance => 'Vérifier à nouveau la présence';

  @override
  String get liveConfirmingAttendance => 'Confirmation en cours…';

  @override
  String get liveJoinToChat =>
      'Rejoignez l’événement pour écrire dans la discussion';

  @override
  String get liveInputHint => 'Écrivez dans la discussion Live…';

  @override
  String get liveSendMessage => 'Envoyer un message Live';

  @override
  String get musicReconnect => 'Reconnecter';

  @override
  String get musicReconnectBody =>
      'Reconnectez Spotify pour actualiser les statistiques musicales.';

  @override
  String get musicStatsUpdated => 'Statistiques musicales mises à jour.';

  @override
  String get musicStatsRefreshing => 'Actualisation des statistiques musicales';

  @override
  String get musicStatsNoArtists =>
      'Aucun artiste disponible après la dernière synchronisation.';

  @override
  String get musicStatsEmptyTitle => 'Donnez un son à votre profil.';

  @override
  String get musicStatsEmptyBody =>
      'Connectez Spotify pour voir les artistes et rythmes qui vous définissent.';

  @override
  String get musicStatsYourSound => 'VOTRE SON';

  @override
  String get musicStatsHeroTitle => 'Des écoutes qui vous définissent.';

  @override
  String get musicStatsArtists => 'Artistes';

  @override
  String get musicStatsRhythm => 'Rythme';

  @override
  String get spotifyBackToLogin => 'Retour à la connexion';

  @override
  String get spotifyConsentBody =>
      'Vibra lit votre profil Spotify, vos artistes, titres et genres les plus écoutés des ~6 derniers mois et les horaires de vos écoutes récentes. Nous les utilisons pour les statistiques musicales, les suggestions d’événements et l’affinité musicale. Vos identifiants Spotify restent chiffrés sur nos serveurs, jamais sur cet appareil. Vous pouvez déconnecter Spotify et supprimer ces données à tout moment dans les Réglages.';

  @override
  String get eventBackToEvents => 'Retour aux événements';

  @override
  String get eventPrice => 'Prix';

  @override
  String get eventVenueTBA => 'Lieu à confirmer';

  @override
  String eventOpenSemantics(String name, String date, String place) {
    return 'Ouvrir l’événement $name, $date, $place';
  }

  @override
  String eventAffinitySemantics(int percentage) {
    return 'Affinité de $percentage pour cent';
  }

  @override
  String eventForYouScore(int percentage) {
    return '$percentage% POUR VOUS';
  }

  @override
  String eventCommonSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements communs ou enregistrés',
      one: '$count événement commun ou enregistré',
    );
    return '$_temp0';
  }

  @override
  String get supportReportTitle => 'Signaler un problème';

  @override
  String get supportReportIntro =>
      'Décrivez ce qui ne fonctionne pas. Nous inclurons la version de l’app, le système d’exploitation et quelques diagnostics sans informations sensibles.';

  @override
  String get supportDescriptionLabel => 'Description du problème';

  @override
  String get supportDescriptionHint =>
      'Indiquez l’écran, les étapes et le résultat attendu.';

  @override
  String get supportAddScreenshot => 'Ajouter une capture';

  @override
  String get supportScreenshotAttached => 'Capture jointe';

  @override
  String get supportRemoveScreenshot => 'Retirer la capture';

  @override
  String get supportScreenshotPrivacy =>
      'Vérifiez que la capture ne montre pas de mots de passe, messages privés ou autres données sensibles.';

  @override
  String get supportSending => 'Envoi en cours…';

  @override
  String get supportSendReport => 'Envoyer le signalement';

  @override
  String get supportDescriptionTooShort =>
      'Décrivez le problème avec au moins 8 caractères.';

  @override
  String get supportDescriptionTooLong =>
      'La description peut contenir au maximum 4000 caractères.';

  @override
  String get supportReportSentTitle => 'Signalement envoyé';

  @override
  String get supportReportSentBody =>
      'Nous avons reçu votre signalement. L’assistance répond sous 48 heures ouvrées.';

  @override
  String supportReportSendFailed(String email) {
    return 'Impossible d’envoyer le signalement. Réessayez ou écrivez à $email.';
  }

  @override
  String get supportReportAuthRequired =>
      'Reconnectez-vous pour envoyer le signalement.';

  @override
  String get supportReportRateLimited =>
      'Vous avez envoyé trop de signalements. Attendez une minute et réessayez.';

  @override
  String get supportScreenshotTooLarge =>
      'La capture doit faire moins de 5 Mo.';

  @override
  String get supportScreenshotUnsupported =>
      'Choisissez une capture au format JPG ou PNG.';

  @override
  String get supportScreenshotPickFailed =>
      'Impossible de sélectionner la capture. Réessayez.';

  @override
  String get supportScreenshotPermissionDenied =>
      'Autorisez l’accès aux photos dans les réglages de l’appareil pour joindre une capture.';

  @override
  String supportAlternativeContact(String email) {
    return 'Vous pouvez aussi écrire à $email. Nous répondons sous 48 heures ouvrées.';
  }

  @override
  String get supportFeedbackTitle =>
      'Comment se passe votre expérience Vibra ?';

  @override
  String get supportFeedbackBody => 'Votre avis nous aide à nous améliorer.';

  @override
  String get supportFeedbackNegative => 'Pas bien';

  @override
  String get supportFeedbackNeutral => 'Moyennement';

  @override
  String get supportFeedbackPositive => 'Bien !';

  @override
  String get supportFeedbackDescriptionPrefix => 'Avis :';

  @override
  String get chatSendFriendshipRequired =>
      'Pour écrire à cette personne, envoyez une demande d’ami et attendez qu’elle soit acceptée.';

  @override
  String get chatSendFirstContactLimit =>
      'Vous avez déjà envoyé 3 messages. Attendez une réponse avant d’en envoyer d’autres.';

  @override
  String get chatSendUnavailable => 'Cette conversation est indisponible.';

  @override
  String get chatSendRateLimited =>
      'Vous envoyez trop de messages. Attendez une minute et réessayez.';

  @override
  String get chatSendSignInRequired =>
      'Reconnectez-vous pour envoyer le message.';

  @override
  String get chatRequestFriendship => 'Envoyer une demande d’ami';

  @override
  String get chatFriendshipRequestSent => 'Demande d’ami envoyée';

  @override
  String get chatFriendshipRequestFailed =>
      'Impossible d’envoyer la demande d’ami. Réessayez.';

  @override
  String get chatMessageTooLong =>
      'Le message peut contenir au maximum 2000 caractères.';

  @override
  String get chatPermissionChecking => 'Vérification de la conversation…';

  @override
  String get chatFriendshipRequestPending =>
      'Demande d’ami en attente d’acceptation';

  @override
  String get chatAcceptFriendship => 'Accepter la demande d’ami';

  @override
  String get chatFriendshipAccepted =>
      'Demande d’ami acceptée. Vous pouvez maintenant envoyer des messages.';

  @override
  String get socialReportUser => 'Signaler l’utilisateur';

  @override
  String get socialReportSpam => 'Spam';

  @override
  String get socialReportHarassment => 'Harcèlement';

  @override
  String get socialReportInappropriate => 'Contenu inapproprié';

  @override
  String get socialReportDetailsHint => 'Détails supplémentaires (facultatifs)';

  @override
  String get socialReportSent => 'Utilisateur signalé';

  @override
  String get socialReportFailed =>
      'Impossible d’envoyer le signalement. Réessayez.';

  @override
  String get socialReportAction => 'Signaler';

  @override
  String get socialBlockUser => 'Bloquer l’utilisateur';

  @override
  String get socialBlockConfirm =>
      'Bloquer cette personne ? Vous ne pourrez plus échanger de messages.';

  @override
  String get socialBlockSuccess => 'Utilisateur bloqué';

  @override
  String get socialBlockFailed =>
      'Impossible de bloquer cette personne. Réessayez.';

  @override
  String get socialBlockAction => 'Bloquer';

  @override
  String get chatRequestTitle => 'Demande de message';

  @override
  String chatRequestBody(String name) {
    return '$name souhaite vous écrire. Répondez pour accepter la conversation.';
  }

  @override
  String get chatRequestRejected => 'Demande refusée et supprimée';

  @override
  String get chatRequestRejectFailed =>
      'Impossible de supprimer la demande. Réessayez.';

  @override
  String get commonReject => 'Refuser';

  @override
  String get commonReply => 'Répondre';

  @override
  String get userProfileView => 'Voir le profil';

  @override
  String get chatConnectionInterrupted =>
      'Connexion à la discussion interrompue.';

  @override
  String get chatMeetupTitle => 'Proposition de rencontre';

  @override
  String get chatMeetupAccept => 'Je participe';

  @override
  String get chatMeetupDecline => 'Je ne peux pas';

  @override
  String chatMeetupAcceptMessage(String message) {
    return 'Je participe ! $message';
  }

  @override
  String chatMeetupDeclineMessage(String message) {
    return 'Je ne peux pas participer. $message';
  }

  @override
  String get helpIntro =>
      'Réponses rapides et assistance. Nous répondons sous 48 heures ouvrées.';

  @override
  String get helpSearchHint => 'Rechercher dans les questions fréquentes';

  @override
  String get helpSearchEmpty =>
      'Aucune réponse trouvée. Essayez une autre recherche.';

  @override
  String get helpNeedMore => 'Besoin d’aide supplémentaire ?';

  @override
  String get helpCategoryAll => 'Toutes';

  @override
  String get helpCategoryAccount => 'Compte';

  @override
  String get helpCategoryChatMatch => 'Discussion et affinité';

  @override
  String get helpCategoryPrivacy => 'Confidentialité';

  @override
  String get helpLoginQuestion => 'Je ne peux pas me connecter';

  @override
  String get helpLoginAnswer =>
      'Vérifiez l’email et le mot de passe, puis fermez et rouvrez Vibra. Si le problème persiste, utilisez « Signaler un problème » et précisez la méthode de connexion.';

  @override
  String get helpLogoutQuestion => 'Comment me déconnecter ?';

  @override
  String get helpLogoutAnswer =>
      'Allez dans Profil > Réglages > Déconnexion. Pour fermer toutes les sessions, choisissez « Déconnexion de tous les appareils ».';

  @override
  String get helpDeleteQuestion => 'Comment supprimer mon compte ?';

  @override
  String get helpDeleteAnswer =>
      'Allez dans Profil > Réglages > Supprimer le compte. La confirmation supprime les données selon la politique de confidentialité.';

  @override
  String get helpEventsQuestion =>
      'Pourquoi aucun événement n’apparaît près de moi ?';

  @override
  String get helpEventsAnswer =>
      'Vérifiez l’accès à la position et élargissez le rayon. La disponibilité dépend des sources d’événements locales ; vous pouvez aussi rechercher une ville.';

  @override
  String get helpTicketsQuestion =>
      'Un événement ou lien de billetterie ne s’ouvre pas';

  @override
  String get helpTicketsAnswer =>
      'Les événements et billets proviennent de partenaires externes. Réessayez plus tard ; si le problème persiste, signalez-le en indiquant l’événement.';

  @override
  String get helpAffinityQuestion => 'Comment l’affinité est-elle calculée ?';

  @override
  String get helpAffinityAnswer =>
      'Le score compare les artistes et genres communs, avec un petit bonus pour les goûts moins répandus. Il indique une affinité sans la garantir.';

  @override
  String get helpBlockQuestion => 'Comment bloquer ou signaler quelqu’un ?';

  @override
  String get helpBlockAnswer =>
      'Ouvrez la conversation et utilisez le menu pour bloquer ou signaler la personne. Le blocage empêche les interactions futures ; les signalements sont envoyés à l’équipe.';

  @override
  String get helpSpotifyConnectQuestion => 'Comment connecter Spotify ?';

  @override
  String get helpSpotifyConnectAnswer =>
      'Allez dans Profil > Réglages > Compte Spotify et autorisez l’accès dans Spotify. Vous reviendrez automatiquement dans Vibra.';

  @override
  String get helpSpotifyDisconnectQuestion => 'Comment déconnecter Spotify ?';

  @override
  String get helpSpotifyDisconnectAnswer =>
      'Allez dans Profil > Réglages > Compte Spotify et choisissez « Déconnecter ».';

  @override
  String get helpSpotifyErrorQuestion => 'La connexion Spotify échoue';

  @override
  String get helpSpotifyErrorAnswer =>
      'Vérifiez la connexion et terminez l’autorisation. Ne partagez ni mots de passe ni jetons avec l’assistance : les signalements contiennent des diagnostics nettoyés.';

  @override
  String get helpReportDataQuestion =>
      'Quelles données un signalement envoie-t-il ?';

  @override
  String get helpReportDataAnswer =>
      'Version de l’app, système d’exploitation, dernier endpoint en erreur et quelques journaux techniques sans données sensibles. La capture est facultative : vérifiez qu’elle ne contient pas d’informations privées.';

  @override
  String get helpPrivacyQuestion =>
      'Comment exercer mes droits sur les données ?';

  @override
  String helpPrivacyAnswer(String email) {
    return 'Allez dans Profil > Réglages > Confidentialité et données personnelles pour gérer les consentements et exporter les données. Pour d’autres demandes, écrivez à $email.';
  }

  @override
  String get exploreEyebrow => 'ÉVÉNEMENTS AUTOUR DE VOUS';

  @override
  String get exploreClearSearch => 'Effacer la recherche';

  @override
  String exploreEventsVisible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ÉVÉNEMENTS VISIBLES',
      one: '$count ÉVÉNEMENT VISIBLE',
    );
    return '$_temp0';
  }

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get exploreLoadErrorTitle =>
      'Les événements n’ont pas pu être chargés.';

  @override
  String get exploreLoadErrorBody =>
      'Vérifiez la connexion et relancez la recherche dans cette zone.';

  @override
  String get exploreEmptyTitle => 'Aucun événement trouvé dans cette zone.';

  @override
  String get exploreEmptyBody => 'Élargissez le rayon ou modifiez les filtres.';

  @override
  String get exploreZoomIn => 'Agrandir la carte';

  @override
  String get exploreZoomOut => 'Réduire la carte';

  @override
  String exploreOpenEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ouvrir la liste de $count événements',
      one: 'Ouvrir la liste de $count événement',
    );
    return '$_temp0';
  }

  @override
  String get exploreMoveMapHint =>
      'Déplacez la carte pour rechercher des événements';

  @override
  String exploreEventsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements dans cette zone',
      one: '$count événement dans cette zone',
    );
    return '$_temp0';
  }

  @override
  String get exploreCloseEvents => 'Fermer la liste d’événements';

  @override
  String get exploreGenreElectronic => 'Électronique';

  @override
  String get exploreGenreAlternative => 'Alternatif';

  @override
  String get commonLinkOpenError => 'Impossible d’ouvrir le lien.';

  @override
  String get authConfirmEmail =>
      'Nous vous avons envoyé un email de confirmation. Consultez votre boîte avant de vous connecter.';

  @override
  String get authEmailNotConfirmed =>
      'Confirmez d’abord votre adresse email. Consultez votre boîte de réception.';

  @override
  String get authInvalidCredentials =>
      'L’email ou le mot de passe est incorrect. Vérifiez-les et réessayez.';

  @override
  String get authProviderUnavailable =>
      'Cette méthode de connexion est indisponible. Utilisez l’email ou réessayez plus tard.';

  @override
  String get authEmailAlreadyRegistered =>
      'Cette adresse email est déjà inscrite. Essayez de vous connecter.';

  @override
  String get authWeakPassword =>
      'Choisissez un mot de passe plus sûr et réessayez.';

  @override
  String get errorNetwork =>
      'Connexion indisponible. Vérifiez le réseau et réessayez.';

  @override
  String get errorSessionChanged =>
      'Votre session a changé. Reconnectez-vous et réessayez.';

  @override
  String get errorRateLimited =>
      'Trop de demandes. Attendez une minute et réessayez.';

  @override
  String get errorActionFailed =>
      'L’opération a échoué. Réessayez dans un instant.';

  @override
  String get socialAffinity => 'Affinité';

  @override
  String get socialFollow => 'Suivre';

  @override
  String get socialFollowing => 'Abonné';

  @override
  String get socialFollowUpdateError =>
      'Impossible de modifier l’abonnement. Réessayez.';

  @override
  String get socialMessageAction => 'Écrire';

  @override
  String get socialFriendRequestSentShort => 'Envoyée';

  @override
  String get socialFriendRequestError =>
      'Impossible d’envoyer la demande. Réessayez.';

  @override
  String get socialAddFriend => 'Ajouter';

  @override
  String get socialCommonArtists => 'Artistes en commun';

  @override
  String get socialUsersLoadError => 'Impossible de charger les utilisateurs.';

  @override
  String socialFollowersCount(int count) {
    return 'Abonnés ($count)';
  }

  @override
  String socialFollowingCount(int count) {
    return 'Abonnements ($count)';
  }

  @override
  String get socialNoFollowers => 'Aucun abonné';

  @override
  String get socialNoFollowersBody =>
      'Les personnes qui suivent ce profil apparaîtront ici.';

  @override
  String get socialNoFollowing => 'Aucun abonnement';

  @override
  String get socialNoFollowingBody => 'Les profils suivis apparaîtront ici.';

  @override
  String get friendsRequestUpdateError =>
      'Impossible de modifier la demande. Réessayez.';

  @override
  String get friendsRemoveTitle => 'Retirer des amis';

  @override
  String friendsRemoveBody(String name) {
    return 'Retirer $name de vos amis ?';
  }

  @override
  String friendsRemoved(String name) {
    return '$name retiré des amis';
  }

  @override
  String get friendsRemoveError => 'Impossible de retirer cet ami. Réessayez.';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get friendsConnectionsTitle => 'Amis et connexions';

  @override
  String friendsCount(int count) {
    return 'Amis ($count)';
  }

  @override
  String get friendsReceived => 'Reçues';

  @override
  String friendsSentCount(int count) {
    return 'Envoyées ($count)';
  }

  @override
  String get friendsSearchHint => 'Rechercher parmi vos amis…';

  @override
  String get friendsNoneFound => 'Aucun ami trouvé';

  @override
  String get friendsFindBody =>
      'Explorez les profils, envoyez des demandes d’amis et partagez des événements.';

  @override
  String get friendsFindPeople => 'Trouver des personnes';

  @override
  String get friendsNoReceived => 'Aucune demande reçue';

  @override
  String get friendsNoReceivedBody =>
      'Les demandes d’amis reçues apparaîtront ici.';

  @override
  String get friendsVibraUser => 'Utilisateur Vibra';

  @override
  String get friendsNoSent => 'Aucune demande envoyée';

  @override
  String get friendsNoSentBody =>
      'Les demandes envoyées en attente de réponse apparaîtront ici.';

  @override
  String inboxOpenConversation(String name) {
    return 'Ouvrir la conversation avec $name';
  }

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus',
      one: '$count message non lu',
    );
    return '$_temp0';
  }

  @override
  String get inboxEyebrow => 'EN CONTACT';

  @override
  String get inboxMessages => 'Messages';

  @override
  String get inboxDirect => 'Directs';

  @override
  String get inboxRequests => 'Demandes';

  @override
  String get inboxSearchHint => 'Rechercher une conversation';

  @override
  String get inboxClearSearch => 'Effacer la recherche de conversations';

  @override
  String get inboxRefreshError => 'Impossible d’actualiser les conversations.';

  @override
  String get inboxEmptyTitle => 'Aucune conversation pour le moment.';

  @override
  String get inboxEmptyBody =>
      'Trouvez quelqu’un avec qui partager un concert et commencez à discuter.';

  @override
  String get inboxNoRequests => 'Aucune demande en attente.';

  @override
  String get inboxNoRequestsBody =>
      'Les nouvelles demandes de message apparaîtront ici.';

  @override
  String get socialMatchSend => 'ENVOYER';

  @override
  String get socialMatchPass => 'PASSER';

  @override
  String get socialMatchSharedListening =>
      'Vos écoutes ont trouvé un point commun.';

  @override
  String get socialYou => 'Vous';

  @override
  String get socialMatchFrequencyNow => 'même fréquence, maintenant';

  @override
  String get socialMatchSharedSound => 'ÉCOUTES COMMUNES';

  @override
  String get socialMatchSameArea => 'MÊME ZONE';

  @override
  String get friendsLoadError => 'Impossible de charger les amis. Réessayez.';

  @override
  String get matchTierHigh => 'Forte affinité';

  @override
  String get matchTierMedium => 'Bonne affinité';

  @override
  String get matchTierLow => 'Faible affinité';

  @override
  String get eventStatusUpcoming => 'À venir';

  @override
  String get eventStatusToday => 'Aujourd\'hui';

  @override
  String get eventStatusSoldOut => 'Complet';

  @override
  String get eventStatusCancelled => 'Annulé';

  @override
  String get eventStatusPostponed => 'Reporté';

  @override
  String get eventStatusPast => 'Terminé';

  @override
  String eventPriceFrom(String price) {
    return 'Dès $price';
  }

  @override
  String get offlineTitle => 'Vous êtes hors ligne';

  @override
  String get homeSpotifyBannerTitle => 'Connectez votre son';

  @override
  String get homeUpNext => 'À SUIVRE';

  @override
  String get homeSpotifyConnectedTitle => 'Spotify connecté';

  @override
  String get spotifyConsentSharing =>
      'Les personnes ayant activé l’affinité musicale voient seulement votre score d’affinité et les artistes et genres que vous avez en commun, jamais votre historique d’écoute.';

  @override
  String get spotifySyncFailedTitle =>
      'Spotify est connecté, mais votre musique n’est pas encore chargée.';

  @override
  String get spotifySyncRetry => 'Relancer la synchronisation';

  @override
  String get spotifyRevokedBody =>
      'L’accès de Vibra a été retiré de votre compte Spotify : nous l’avons déconnecté et avons supprimé les données synchronisées. Reconnectez-le pour retrouver vos statistiques et affinités.';

  @override
  String get spotifyRateLimited =>
      'Spotify est occupé pour le moment. Réessayez dans une minute.';

  @override
  String get settingsSpotifyDisconnectError =>
      'Impossible de déconnecter Spotify. Réessayez.';

  @override
  String get socialConnectSpotifyBody =>
      'Connectez Spotify pour rencontrer des personnes qui écoutent ce que vous aimez.';

  @override
  String socialAffinityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes partagent vos goûts',
      one: '1 personne partage vos goûts',
      zero: 'Aucune nouvelle affinité pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String get spotifyAccessNotGranted =>
      'Spotify n’a pas encore activé Vibra pour votre compte. Le reste de Vibra fonctionne normalement ; réessayez plus tard.';

  @override
  String get spotifyConnectFailed =>
      'Spotify n’a pas pu finaliser la connexion. Réessayez dans un instant.';

  @override
  String get settingsSectionMusic => 'Musique';

  @override
  String get settingsSectionGeneral => 'Général';

  @override
  String get settingsSectionHelp => 'Aide';

  @override
  String get settingsSectionLegal => 'Informations légales';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsDeleteAccountSub =>
      'Supprimer définitivement votre compte et vos données';

  @override
  String get settingsEditProfileSub => 'Nom, photo, bio et nom d’utilisateur';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get profileStatEvents => 'Événements';

  @override
  String get profileSpotifyBenefits => 'Statistiques · Affinité · Pour vous';

  @override
  String get appearanceAuto => 'Automatique';

  @override
  String get affinityCategoryExceptional => 'Affinité musicale exceptionnelle';

  @override
  String get affinityCategoryVeryHigh => 'Affinité très élevée';

  @override
  String get affinityCategoryHigh => 'Affinité élevée';

  @override
  String get affinityCategoryModerate => 'Affinité modérée';

  @override
  String get affinityCategoryLow => 'Des sons différents';

  @override
  String get affinityCategoryVeryLow => 'De nouveaux univers musicaux';

  @override
  String affinityHeadline(int percent) {
    return '$percent % d’affinité musicale';
  }

  @override
  String get affinitySharedGenres => 'Vos genres en commun';

  @override
  String get affinityTheirGenres => 'Ses genres principaux';

  @override
  String get affinityArtistsInCommon => 'Artistes en commun';

  @override
  String get affinityWhy => 'Pourquoi vous vous ressemblez';

  @override
  String get affinityQuoteExceptional =>
      'Vous semblez entendre la musique de la même façon.';

  @override
  String get affinityQuoteVeryHigh =>
      'Vos goûts musicaux ont énormément en commun.';

  @override
  String get affinityQuoteHigh => 'Vos goûts musicaux ont beaucoup en commun.';

  @override
  String get affinityQuoteModerate =>
      'Vous partagez certains sons et pouvez en découvrir d’autres.';

  @override
  String get affinityQuoteDiscovery =>
      'Des univers différents : l’occasion de découvrir de la musique.';

  @override
  String affinityReasonSharedFamilies(String genres) {
    return 'Vous écoutez tous les deux surtout $genres.';
  }

  @override
  String affinityReasonSharedSubgenres(String genres) {
    return 'Vous partagez une passion pour $genres.';
  }

  @override
  String affinityReasonDifferentSubgenres(String genre) {
    return 'Vous aimez tous les deux $genre, avec des sous-genres différents.';
  }

  @override
  String affinityReasonRelatedFamilies(String first, String second) {
    return '$first et $second sont des univers proches.';
  }

  @override
  String affinityReasonSharedArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous partagez $count artistes préférés.',
      one: 'Vous partagez 1 artiste préféré.',
    );
    return '$_temp0';
  }

  @override
  String get affinityReasonDiscovery =>
      'Des goûts différents : idéal pour découvrir de la musique.';

  @override
  String get affinityListSeparator => ' et ';

  @override
  String get genreFamilyHipHop => 'Hip-Hop';

  @override
  String get genreFamilyRnb => 'R&B';

  @override
  String get genreFamilyElectronic => 'Électro';

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
  String get genreFamilyLatin => 'Latino';

  @override
  String get genreFamilyAfro => 'Afro';

  @override
  String get genreFamilyCountry => 'Country';

  @override
  String get genreFamilyFolk => 'Folk';

  @override
  String get genreFamilyClassical => 'Classique';

  @override
  String get genreFamilySoundtrack => 'Bandes originales';

  @override
  String get genreFamilyGospel => 'Gospel et chrétienne';

  @override
  String get genreFamilyWorld => 'Musiques du monde';

  @override
  String get musicGenresTitle => 'Vos genres';

  @override
  String get musicGenresSubtitle =>
      'Choisissez les genres que vous aimez : ils nous aident à trouver des personnes aux goûts proches, avec ou sans Spotify.';

  @override
  String get musicGenresSpotifyNote =>
      'Spotify est connecté : ces genres s’ajoutent à ceux de vos écoutes.';

  @override
  String get musicGenresSearchHint => 'Rechercher un genre';

  @override
  String get musicGenresNoResults => 'Aucun genre trouvé';

  @override
  String musicGenresSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genres choisis',
      one: '1 genre choisi',
      zero: 'Aucun genre choisi',
    );
    return '$_temp0';
  }

  @override
  String get musicGenresYourPicks => 'Votre sélection';

  @override
  String get musicGenresLevelLike => 'J’aime';

  @override
  String get musicGenresLevelMuch => 'Beaucoup';

  @override
  String get musicGenresLevelLove => 'J’adore';

  @override
  String get musicGenresIntensityHint =>
      'Touchez un genre choisi pour dire à quel point vous l’aimez.';

  @override
  String musicGenresRemove(String genre) {
    return 'Retirer $genre';
  }

  @override
  String get musicGenresLimit => 'Vous pouvez choisir jusqu’à 30 genres.';

  @override
  String get musicGenresMatching =>
      'Me montrer aux personnes aux goûts proches';

  @override
  String get musicGenresMatchingBody =>
      'Ils ne voient que le score d’affinité et les genres et artistes en commun.';

  @override
  String get musicGenresSave => 'Enregistrer';

  @override
  String get musicGenresSaved =>
      'Genres enregistrés. Vos affinités sont en cours de mise à jour.';

  @override
  String get musicGenresSaveError =>
      'Impossible d’enregistrer vos genres. Réessayez.';

  @override
  String get musicGenresLoadError => 'Impossible de charger vos genres.';

  @override
  String get musicGenresEntry => 'Genres préférés';

  @override
  String get musicGenresEntrySub => 'Choisissez vos genres, même sans Spotify';

  @override
  String get socialAffinityPickGenres => 'Ou choisissez vos genres';

  @override
  String get socialAffinityPickGenresBody =>
      'Choisissez vos genres préférés pour rencontrer des personnes aux goûts proches.';

  @override
  String get privacyMusicAffinity => 'Affinité musicale';

  @override
  String get privacyMusicAffinityBody =>
      'Utilise vos données Spotify et les genres choisis pour les suggestions et l’affinité.';

  @override
  String get musicalDnaTitle => 'ADN musical';

  @override
  String get musicalDnaEyebrow => 'Ton identité musicale';

  @override
  String musicalDnaUserTitle(String name) {
    return 'ADN musical de $name';
  }

  @override
  String get musicalDnaUserEyebrow => 'Identité musicale';

  @override
  String get musicalDnaDistribution => 'Répartition des genres';

  @override
  String get musicalDnaDistributionSub =>
      'Comment ton goût se répartit entre les familles de genres';

  @override
  String musicalDnaArtistsVia(String artists) {
    return 'À travers $artists';
  }

  @override
  String get musicalDnaDiversity => 'Diversité';

  @override
  String get musicalDnaDiversityFocused => 'Concentré';

  @override
  String get musicalDnaDiversityBalanced => 'Équilibré';

  @override
  String get musicalDnaDiversityEclectic => 'Éclectique';

  @override
  String get musicalDnaDiversityFocusedBody =>
      'Ton identité vit dans quelques sons proches.';

  @override
  String get musicalDnaDiversityBalancedBody =>
      'Un noyau clair, avec de la place pour d\'autres univers.';

  @override
  String get musicalDnaDiversityEclecticBody =>
      'Ton goût circule librement entre des univers très différents.';

  @override
  String musicalDnaDiversityCounts(String families, String subgenres) {
    return '$families familles · $subgenres sous-genres';
  }

  @override
  String get musicalDnaEvolution => 'Évolution';

  @override
  String get musicalDnaEvolutionSub =>
      'Comment ton ADN change au fil de tes écoutes';

  @override
  String musicalDnaEvolutionEmpty(String date) {
    return 'Suivi depuis le $date. Les changements apparaîtront ici à mesure que tes écoutes évoluent.';
  }

  @override
  String musicalDnaShiftSince(String date) {
    return 'Depuis le $date';
  }

  @override
  String get musicalDnaNoShift =>
      'Stable : aucune famille n\'a bougé de plus de 3 points.';

  @override
  String musicalDnaShiftSemantics(String family, String from, String to) {
    return '$family, de $from à $to pour cent';
  }

  @override
  String get musicalDnaSources => 'Basé sur';

  @override
  String musicalDnaSourceArtists(String classified, String total) {
    return '$classified de tes $total artistes Spotify les plus écoutés (6 derniers mois)';
  }

  @override
  String get musicalDnaSourceSpotifyGenres =>
      'Les genres de tes artistes Spotify les plus écoutés (6 derniers mois)';

  @override
  String musicalDnaSourceTracks(String count) {
    return 'Tes $count titres Spotify les plus écoutés';
  }

  @override
  String musicalDnaSourceGenres(String count) {
    return '$count genres choisis par toi';
  }

  @override
  String get musicalDnaEditGenres => 'Modifier tes genres';

  @override
  String get musicalDnaVisibility => 'Qui peut le voir';

  @override
  String get musicalDnaVisibilityPublic => 'Tout le monde';

  @override
  String get musicalDnaVisibilityMatches => 'Affinités';

  @override
  String get musicalDnaVisibilityPrivate => 'Moi seul';

  @override
  String get musicalDnaVisibilityPublicBody =>
      'Tout le monde sur Vibra peut voir ton ADN musical sur ton profil.';

  @override
  String get musicalDnaVisibilityMatchesBody =>
      'Seulement les personnes avec qui tu as une affinité musicale ou une connexion.';

  @override
  String get musicalDnaVisibilityPrivateBody =>
      'Toi seul peux le voir. Il continue de guider tes suggestions.';

  @override
  String get musicalDnaVisibilityError =>
      'Impossible d\'enregistrer ton choix. Réessaie.';

  @override
  String get musicalDnaEmptyTitle => 'Pas encore d\'ADN musical';

  @override
  String get musicalDnaEmptyBody =>
      'Connecte Spotify ou choisis quelques genres que tu aimes : ton ADN se construit à partir de là.';

  @override
  String get musicalDnaPickGenres => 'Choisir des genres';

  @override
  String get musicalDnaLoadError => 'Impossible de charger ton ADN musical.';

  @override
  String musicalDnaUpdated(String date) {
    return 'Mis à jour le $date';
  }

  @override
  String musicalDnaFamilySemantics(String family, String percent) {
    return '$family, $percent pour cent';
  }

  @override
  String get musicalDnaProfileTile => 'ADN musical';

  @override
  String get musicalDnaProfileTileSubtitle =>
      'Tes genres, ta diversité et leur évolution';

  @override
  String get musicalDnaSeeFull => 'Voir l\'ADN complet';

  @override
  String affinityReasonCommonGround(String genres) {
    return 'Vous écoutez tous les deux $genres, dans des proportions différentes.';
  }

  @override
  String get affinityReasonBothEclectic =>
      'Vous êtes tous les deux éclectiques, entre des genres très différents.';

  @override
  String get affinityReasonBothFocused =>
      'Vous restez tous les deux proches de votre son de prédilection.';

  @override
  String get affinityReasonDiversityContrast =>
      'L\'un explore beaucoup, l\'autre reste concentré : de quoi partager.';

  @override
  String affinityHeadlineSentence(int percent) {
    return 'Vous avez $percent % d\'affinité musicale.';
  }

  @override
  String get sameFrequencyTitle => 'Same Frequency';

  @override
  String get sameFrequencyHeadline => 'Vous êtes sur la même fréquence.';

  @override
  String sameFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tu as découvert $count personnes avec une forte connexion musicale.',
      one: 'Tu as découvert 1 personne avec une forte connexion musicale.',
      zero: 'Pas encore de connexion musicale forte.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyTabForYou => 'Pour toi';

  @override
  String get sameFrequencyTabSaved => 'Enregistrés';

  @override
  String get sameFrequencyEmptyTitle =>
      'Personne sur ta fréquence pour l\'instant';

  @override
  String get sameFrequencyEmptyBody =>
      'Les personnes qui partagent ton son apparaîtront ici. Choisis plus de genres ou synchronise Spotify pour élargir ton signal.';

  @override
  String get sameFrequencySavedEmptyTitle => 'Aucun profil enregistré';

  @override
  String get sameFrequencySavedEmptyBody =>
      'Enregistre les personnes que tu veux retrouver. Elles restent ici jusqu\'à ce que tu les retires.';

  @override
  String get sameFrequencySave => 'Enregistrer';

  @override
  String get sameFrequencySaved => 'Enregistré';

  @override
  String get sameFrequencySaveError =>
      'Impossible de mettre à jour tes profils enregistrés. Réessaie.';

  @override
  String get sameFrequencyWhy => 'Pourquoi vous êtes sur la même fréquence';

  @override
  String sameFrequencyReasonDiscoveries(String artists) {
    return 'Vous avez tous les deux découvert récemment $artists.';
  }

  @override
  String sameFrequencyReasonDirection(String genres) {
    return 'Vous vous tournez tous les deux vers $genres.';
  }

  @override
  String sameFrequencyReasonEvent(String event, String date) {
    return 'Vous allez tous les deux à $event · $date.';
  }

  @override
  String sameFrequencyReasonEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous avez enregistré $count événements en commun.',
      one: 'Vous avez enregistré 1 événement en commun.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyDiscoverArtists => 'Découvrir les artistes en commun';

  @override
  String sameFrequencySharedArtistsTitle(String name) {
    return 'Artistes que tu partages avec $name';
  }

  @override
  String get sameFrequencyFindEvents => 'Trouver des événements';

  @override
  String get sameFrequencyEventsOptIn => 'Comparer les événements enregistrés';

  @override
  String get sameFrequencyEventsOptInBody =>
      'Trouve des personnes qui vont aux mêmes concerts. Fonctionne uniquement avec celles qui l\'ont aussi activé ; sinon tes événements enregistrés restent privés.';

  @override
  String get sameFrequencyEntryBody =>
      'Des personnes avec qui tu partages une vraie connexion musicale';

  @override
  String get sameFrequencyLoadError => 'Impossible de charger Same Frequency.';

  @override
  String sameFrequencyPersonSemantics(String name, String percent) {
    return '$name, $percent pour cent d\'affinité musicale';
  }

  @override
  String get musicRadarTitle => 'Music Radar';

  @override
  String get musicRadarHeadline =>
      'Des personnes près de toi qui partagent tes goûts musicaux.';

  @override
  String musicRadarCount(int count, int distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes compatibles à moins de $distance km.',
      one: '1 personne compatible à moins de $distance km.',
      zero: 'Pas encore de personne compatible à moins de $distance km.',
    );
    return '$_temp0';
  }

  @override
  String get musicRadarAreaSound => 'Le son de ta zone';

  @override
  String get musicRadarAreaSoundSub =>
      'Ce que les gens autour de toi écoutent le plus';

  @override
  String get musicRadarAreaTooFew =>
      'Affiché quand assez de personnes proches utilisent le radar.';

  @override
  String get musicRadarPeople => 'Profils compatibles';

  @override
  String get musicRadarEvents => 'Prochains événements pour ton son';

  @override
  String get musicRadarEventYourArtist => 'Un de tes artistes';

  @override
  String get musicRadarEventSharedArtist =>
      'Un artiste que tu partages avec des gens proches';

  @override
  String get musicRadarEventYourGenre => 'Tes genres';

  @override
  String get musicRadarEventAreaGenre => 'Populaire dans ta zone';

  @override
  String get musicRadarIntroTitle =>
      'Découvre des gens près de toi grâce à la musique';

  @override
  String get musicRadarIntroBody =>
      'Music Radar montre les personnes autour de toi aux goûts proches. Il reste désactivé tant que tu ne l\'actives pas.';

  @override
  String get musicRadarPrivacy1 =>
      'Personne ne voit ta position ni ta distance : seulement que tu es dans son rayon.';

  @override
  String get musicRadarPrivacy2 =>
      'Ta position est arrondie à une zone d\'environ 5 km (ou 20 km) et bouge au plus toutes les 6 heures.';

  @override
  String get musicRadarPrivacy3 =>
      'Masque ton profil, change la distance ou coupe le radar quand tu veux.';

  @override
  String get musicRadarTurnOn => 'Activer Music Radar';

  @override
  String get musicRadarLocationTitle => 'Position nécessaire';

  @override
  String get musicRadarLocationBody =>
      'Music Radar utilise ta position approximative. Active la localisation dans les Contrôles de confidentialité, puis reviens.';

  @override
  String get musicRadarOpenPrivacy => 'Ouvrir les contrôles de confidentialité';

  @override
  String get musicRadarMatchingNote =>
      'Active Affinité musicale dans les Contrôles de confidentialité pour voir les personnes compatibles.';

  @override
  String get musicRadarSettings => 'Réglages du radar';

  @override
  String get musicRadarEnabled => 'Music Radar';

  @override
  String get musicRadarVisible => 'M\'afficher sur le radar';

  @override
  String get musicRadarVisibleBody =>
      'Désactivé, tu peux regarder autour de toi, mais personne ne te voit.';

  @override
  String get musicRadarDistance => 'Distance de découverte';

  @override
  String musicRadarDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get musicRadarPrecision => 'Précision de la position';

  @override
  String get musicRadarPrecisionArea => 'Zone (~5 km)';

  @override
  String get musicRadarPrecisionRegion => 'Région (~20 km)';

  @override
  String get musicRadarPrecisionBody =>
      'Avec quelle approximation tu es placé par rapport aux autres. Ta position exacte n\'est jamais partagée.';

  @override
  String get musicRadarSaveError =>
      'Impossible d\'enregistrer le réglage. Réessaie.';

  @override
  String get musicRadarLoadError => 'Impossible de charger Music Radar.';

  @override
  String get musicRadarEntryBody => 'Des personnes proches avec tes goûts';

  @override
  String get musicRadarEmptyPeople =>
      'Personne de compatible à proximité pour l\'instant. Essaie une distance plus grande ou reviens plus tard.';

  @override
  String get communitiesTitle => 'Communautés';

  @override
  String get communitiesEntryBody => 'Genres, artistes et scènes que tu aimes';

  @override
  String get communitiesSearchHint =>
      'Rechercher des communautés ou des artistes';

  @override
  String get communitiesForYou => 'Pour toi';

  @override
  String get communitiesForYouSub => 'D\'après ton profil musical';

  @override
  String get communitiesMine => 'Tes communautés';

  @override
  String get communitiesExplore => 'Explorer';

  @override
  String get communitiesEmptySearch =>
      'Aucune communauté ne correspond à ta recherche.';

  @override
  String communitiesRecommendation(String name) {
    return 'D\'après ton profil musical, tu pourrais aimer $name.';
  }

  @override
  String communitiesReasonArtist(String artist) {
    return '$artist fait partie de tes artistes les plus écoutés.';
  }

  @override
  String communitiesReasonGenre(String genre, int percent) {
    return '$genre représente $percent % de ton ADN musical.';
  }

  @override
  String communitiesStartArtist(String artist) {
    return 'Lance la communauté $artist';
  }

  @override
  String get communitiesStartArtistBody =>
      'Un de tes artistes préférés n\'a pas encore de communauté.';

  @override
  String communitiesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get communitiesOfficial => 'Officielle';

  @override
  String get communitiesKindGenre => 'Genre';

  @override
  String get communitiesKindArtist => 'Artiste';

  @override
  String get communitiesKindInterest => 'Centre d\'intérêt';

  @override
  String get communitiesJoin => 'Rejoindre';

  @override
  String get communitiesJoined => 'Membre';

  @override
  String get communitiesLeave => 'Quitter';

  @override
  String communitiesLeaveConfirm(String name) {
    return 'Quitter $name ?';
  }

  @override
  String get communitiesCreate => 'Créer une communauté';

  @override
  String get communitiesCreateName => 'Nom';

  @override
  String get communitiesCreateDescription => 'Description (facultative)';

  @override
  String get communitiesCreateArtist => 'Artiste';

  @override
  String get communitiesCreateGenre => 'Genre';

  @override
  String get communitiesCreateAction => 'Créer';

  @override
  String get communitiesTabPosts => 'Publications';

  @override
  String get communitiesTabDiscussions => 'Discussions';

  @override
  String get communitiesTabEvents => 'Événements';

  @override
  String get communitiesTabMembers => 'Membres';

  @override
  String get communitiesNewPost => 'Nouvelle publication';

  @override
  String get communitiesComposerPost => 'Publication';

  @override
  String get communitiesComposerDiscussion => 'Discussion';

  @override
  String get communitiesComposerMusic => 'Partager de la musique';

  @override
  String get communitiesComposerBodyHint => 'Qu\'as-tu en tête ?';

  @override
  String get communitiesComposerTitleHint => 'Sujet de la discussion';

  @override
  String get communitiesComposerLinkHint =>
      'Lien Spotify, Apple Music, YouTube, SoundCloud ou Bandcamp';

  @override
  String get communitiesComposerTrackHint => 'Titre ou album (facultatif)';

  @override
  String get communitiesComposerArtistHint => 'Artiste (facultatif)';

  @override
  String get communitiesPublish => 'Publier';

  @override
  String get communitiesJoinToPost =>
      'Rejoins la communauté pour publier, commenter et réagir.';

  @override
  String get communitiesEmptyFeed =>
      'Pas encore de publication. Lance la conversation.';

  @override
  String get communitiesEmptyDiscussions => 'Pas encore de discussion.';

  @override
  String get communitiesEmptyEvents =>
      'Aucun événement à venir pour cette communauté.';

  @override
  String communitiesComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
      zero: 'Commenter',
    );
    return '$_temp0';
  }

  @override
  String get communitiesCommentHint => 'Ajouter un commentaire';

  @override
  String get communitiesEmptyComments => 'Pas encore de commentaire.';

  @override
  String get communitiesOpenMusic => 'Écouter';

  @override
  String get communitiesHeld =>
      'Masqué pendant que les modérateurs examinent les signalements';

  @override
  String get communitiesDelete => 'Supprimer';

  @override
  String get communitiesRemove => 'Retirer (modérateur)';

  @override
  String get communitiesRestore => 'Rétablir';

  @override
  String get communitiesBan => 'Bannir de la communauté';

  @override
  String communitiesBanConfirm(String name) {
    return 'Bannir $name de cette communauté ?';
  }

  @override
  String get communitiesMakeModerator => 'Nommer modérateur';

  @override
  String get communitiesRemoveModerator => 'Retirer le rôle de modérateur';

  @override
  String get communitiesRoleOwner => 'Propriétaire';

  @override
  String get communitiesRoleModerator => 'Modérateur';

  @override
  String get communitiesModeration => 'Modération';

  @override
  String get communitiesModerationEmpty => 'Rien à examiner.';

  @override
  String communitiesReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements',
      one: '1 signalement',
    );
    return '$_temp0';
  }

  @override
  String get communitiesReported => 'Merci, les modérateurs vont l\'examiner.';

  @override
  String get communitiesError => 'Une erreur s\'est produite. Réessaie.';

  @override
  String get communitiesErrorRate => 'Tu vas trop vite. Attends un instant.';

  @override
  String get communitiesErrorSpam =>
      'Ça ressemble à du spam : trop de liens, un lien suspect ou une répétition.';

  @override
  String get communitiesErrorBanned => 'Tu as été banni de cette communauté.';

  @override
  String get communitiesErrorLink =>
      'Utilise un lien Spotify, Apple Music, YouTube, SoundCloud ou Bandcamp.';

  @override
  String get communitiesErrorExists =>
      'Une communauté existe déjà pour cet artiste.';

  @override
  String get communitiesErrorLimit => 'Tu as atteint la limite du jour.';

  @override
  String get communitiesLoadError => 'Impossible de charger les communautés.';

  @override
  String sameFrequencyReasonCommunities(String communities) {
    return 'Vous êtes tous les deux dans $communities.';
  }

  @override
  String get musicRadarCommunities => 'Communautés pour le son de ta zone';

  @override
  String get circlesTitle => 'Cercles';

  @override
  String get circlesSubtitle =>
      'Des petits groupes pour la musique que tu aimes';

  @override
  String get circlesInvitations => 'Invitations';

  @override
  String circlesInvitedBy(String name) {
    return '$name t\'a invité';
  }

  @override
  String get circlesAccept => 'Accepter';

  @override
  String get circlesDecline => 'Refuser';

  @override
  String get circlesInviteDeclined => 'Invitation refusée';

  @override
  String get circlesSuggested => 'VIBRA suggère';

  @override
  String circlesSuggestionGenre(int count, String genre) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un cercle de $count personnes qui partagent $genre.',
    );
    return '$_temp0';
  }

  @override
  String circlesSuggestionArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un cercle de $count personnes qui écoutent toutes $artist.',
    );
    return '$_temp0';
  }

  @override
  String get circlesSuggestionConsent =>
      'Chaque personne reçoit une invitation et décide de rejoindre ou non.';

  @override
  String get circlesCreateAndInvite => 'Créer et inviter';

  @override
  String circlesSuggestionName(String topic) {
    return 'Cercle $topic';
  }

  @override
  String circlesInvitesSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cercle créé. $count invitations envoyées.',
      one: 'Cercle créé. 1 invitation envoyée.',
      zero: 'Cercle créé. Aucune invitation n\'a pu être envoyée.',
    );
    return '$_temp0';
  }

  @override
  String get circlesMine => 'Tes cercles';

  @override
  String get circlesEmptyTitle => 'Pas encore de cercle';

  @override
  String get circlesEmptyBody =>
      'Crée un petit groupe autour d\'un genre, d\'un artiste ou d\'un concert, et invite des personnes que tu connais.';

  @override
  String get circlesCreate => 'Nouveau cercle';

  @override
  String get circlesBasisGenre => 'Genre';

  @override
  String get circlesBasisArtist => 'Artiste';

  @override
  String get circlesBasisConcert => 'Concert';

  @override
  String get circlesBasisInterest => 'Centre d\'intérêt';

  @override
  String get circlesBasisActivity => 'Activité';

  @override
  String get circlesName => 'Nom';

  @override
  String get circlesDescription => 'Description (facultative)';

  @override
  String get circlesTopic => 'Thème';

  @override
  String get circlesNoSavedEvents =>
      'Enregistre d\'abord un événement pour créer un cercle autour.';

  @override
  String get circlesCreateAction => 'Créer';

  @override
  String circlesMembers(int count, int max) {
    return '$count/$max membres';
  }

  @override
  String get circlesTabChat => 'Chat';

  @override
  String get circlesTabPlaylist => 'Playlist';

  @override
  String get circlesTabEvents => 'Événements';

  @override
  String get circlesTabMembers => 'Membres';

  @override
  String get circlesMessageHint => 'Écrire au cercle';

  @override
  String get circlesChatEmpty => 'Dis bonjour à ton cercle.';

  @override
  String get circlesPlaylistEmpty => 'Pas encore de titre. Ajoute le premier.';

  @override
  String get circlesAddTrack => 'Ajouter un titre';

  @override
  String get circlesEventsEmpty => 'Pas encore d\'événement partagé.';

  @override
  String get circlesShareEvent => 'Partager un événement';

  @override
  String get circlesInvite => 'Inviter des personnes';

  @override
  String get circlesInviteHint =>
      'Tu peux inviter tes connexions et les personnes avec qui tu as une affinité musicale. Elles décident de rejoindre ou non.';

  @override
  String get circlesInviteNone =>
      'Personne d\'autre à inviter pour l\'instant.';

  @override
  String get circlesInviteSend => 'Envoyer les invitations';

  @override
  String get circlesPending => 'Invité';

  @override
  String get circlesRevoke => 'Annuler l\'invitation';

  @override
  String get circlesAdmin => 'Admin';

  @override
  String get circlesMakeAdmin => 'Nommer admin';

  @override
  String get circlesRemoveMember => 'Retirer du cercle';

  @override
  String get circlesMute => 'Couper les notifications';

  @override
  String get circlesUnmute => 'Réactiver les notifications';

  @override
  String get circlesEdit => 'Modifier le cercle';

  @override
  String get circlesLeave => 'Quitter le cercle';

  @override
  String circlesLeaveConfirm(String name) {
    return 'Quitter $name ?';
  }

  @override
  String get circlesSave => 'Enregistrer';

  @override
  String get circlesError => 'Une erreur s\'est produite. Réessaie.';

  @override
  String get circlesErrorFull => 'Ce cercle est complet.';

  @override
  String get circlesErrorNotAllowed =>
      'Tu ne peux inviter que tes connexions ou les personnes avec qui tu as une affinité musicale.';

  @override
  String get circlesErrorDeclined =>
      'Cette personne a refusé récemment. Réessaie plus tard.';

  @override
  String get circlesLoadError => 'Impossible de charger les cercles.';

  @override
  String get circlesRemove => 'Retirer';

  @override
  String get concertTitle => 'Concert Finder';

  @override
  String get concertHeadline =>
      'Ces prochains événements pourraient te plaire.';

  @override
  String get concertWhy => 'Pourquoi on te le recommande';

  @override
  String concertReasonTopArtist(String artist, int rank) {
    return '$artist est n° $rank de tes artistes les plus écoutés.';
  }

  @override
  String concertReasonTrackArtist(String artist) {
    return '$artist figure dans tes titres les plus écoutés.';
  }

  @override
  String concertReasonSavedArtist(String artist) {
    return 'Tu as enregistré un autre événement de $artist.';
  }

  @override
  String concertReasonGenre(String genre, int percent) {
    return '$genre représente $percent % de ton ADN musical.';
  }

  @override
  String concertReasonSimilarToSaved(String genre) {
    return 'Comme d\'autres événements $genre que tu as enregistrés.';
  }

  @override
  String concertReasonDistance(int km) {
    return 'À $km km de toi.';
  }

  @override
  String concertReasonSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dans $days jours.',
      one: 'Demain.',
      zero: 'Aujourd\'hui.',
    );
    return '$_temp0';
  }

  @override
  String get concertFilterGenre => 'Genre';

  @override
  String get concertFilterAll => 'Tous';

  @override
  String get concertArtistHint => 'Rechercher un artiste';

  @override
  String get concertFilterDate => 'Quand';

  @override
  String get concertDateAny => 'N\'importe quand';

  @override
  String get concertDateWeek => '7 prochains jours';

  @override
  String get concertDateMonth => '30 prochains jours';

  @override
  String get concertDate3Months => '3 prochains mois';

  @override
  String get concertFilterDistance => 'Distance';

  @override
  String get concertDistanceAny => 'N\'importe quelle distance';

  @override
  String concertDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get concertFilterPrice => 'Prix';

  @override
  String get concertPriceAny => 'N\'importe quel prix';

  @override
  String concertPriceUpTo(String price) {
    return 'Jusqu\'à $price';
  }

  @override
  String get concertPriceNote =>
      'Uniquement les événements avec un prix publié en euros.';

  @override
  String get concertEmpty =>
      'Aucun événement recommandé ne correspond à ces filtres.';

  @override
  String get concertEmptyBody =>
      'Essaie une distance plus grande, une autre date ou moins de filtres.';

  @override
  String get concertNoProfileTitle => 'Dis-nous ce que tu écoutes';

  @override
  String get concertNoProfileBody =>
      'Connecte Spotify ou choisis quelques genres pour recevoir des recommandations de concerts.';

  @override
  String get concertLocationNote =>
      'Active la localisation pour voir les distances et les événements proches.';

  @override
  String get concertLoadError => 'Impossible de charger les recommandations.';

  @override
  String get concertSaved => 'Enregistré';

  @override
  String get eventDetailInterested => 'Intéressé';

  @override
  String get eventDetailAttendanceInterested => 'Enregistré comme intérêt';

  @override
  String get eventDetailAttendanceRemoved => 'Retiré de tes événements';

  @override
  String get whosGoingTitle => 'Qui y va ?';

  @override
  String get whosGoingSubtitle =>
      'Des personnes qui ont choisi de partager leurs projets avec toi';

  @override
  String whosGoingGoing(int count) {
    return '$count y vont';
  }

  @override
  String whosGoingMaybe(int count) {
    return '$count peut-être';
  }

  @override
  String whosGoingInterested(int count) {
    return '$count intéressés';
  }

  @override
  String get whosGoingFriends => 'Amis';

  @override
  String get whosGoingCompatible => 'Personnes compatibles';

  @override
  String get whosGoingOthers => 'Autres';

  @override
  String get whosGoingEmpty =>
      'Personne que tu peux voir n\'a partagé ses projets pour cet événement.';

  @override
  String get whosGoingPrivacyNote =>
      'Tu ne vois que les personnes qui ont choisi de partager leurs projets avec toi. Les tiens suivent ton choix ci-dessous.';

  @override
  String get whosGoingCommunities => 'Communautés pour cet événement';

  @override
  String whosGoingAffinity(int percent) {
    return '$percent % d\'affinité';
  }

  @override
  String get whosGoingRequested => 'Demande envoyée';

  @override
  String get attendanceVisibility => 'Qui peut voir tes projets';

  @override
  String get visibilityPrivate => 'Moi seul';

  @override
  String get visibilityFriends => 'Amis';

  @override
  String get visibilityMatches => 'Amis et affinités';

  @override
  String get visibilityPublic => 'Tout le monde';

  @override
  String get attendanceVisibilityDefault => 'Utiliser pour tous mes événements';

  @override
  String get attendanceVisibilityHint =>
      'Les autres ne voient tes projets que si tu le permets. Tu vois toujours ceux qui partagent les leurs.';

  @override
  String get attendanceVisibilitySaved => 'Visibilité mise à jour';

  @override
  String get concertMatchTitle => 'Concert Match';

  @override
  String concertMatchHeadlineMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toi et $count autres personnes êtes intéressés par ce concert.',
      one: 'Toi et 1 autre personne êtes intéressés par ce concert.',
      zero:
          'Tu es le premier que tu peux voir. Plus bas, des personnes qui adorent cet artiste.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchHeadlineOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personnes que tu peux voir sont intéressées par ce concert.',
      one: '1 personne que tu peux voir est intéressée par ce concert.',
      zero:
          'Personne que tu peux voir n\'a encore partagé ses projets pour ce concert.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchFan(String artist) {
    return 'Adore aussi $artist';
  }

  @override
  String concertMatchCreateGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Créer un groupe pour l\'événement ($count)',
      zero: 'Créer un groupe pour l\'événement',
    );
    return '$_temp0';
  }

  @override
  String get concertMatchGroupNote =>
      'Les personnes rejoignent seulement si elles acceptent ton invitation. La position et les trajets de personne ne sont partagés.';

  @override
  String get concertMatchShare => 'Partager dans un cercle';

  @override
  String get concertMatchShared => 'Événement partagé avec le cercle';

  @override
  String concertMatchSharedMessage(String event, String date) {
    return 'A partagé un événement : $event · $date';
  }

  @override
  String get concertMatchNoCircles => 'Tu n\'as pas encore de cercle.';

  @override
  String get concertMatchEmpty => 'Pas encore de match pour ce concert.';

  @override
  String get concertMatchSelectHint =>
      'Sélectionne des personnes à inviter dans un groupe d\'événement';

  @override
  String get circlePlans => 'Projets';

  @override
  String get circlePlansEmpty =>
      'Pas encore de projet. Propose-en un : dîner, verre avant le concert, point de rendez-vous.';

  @override
  String get circleAddPlan => 'Ajouter un projet';

  @override
  String get circlePlanTitle => 'Quoi';

  @override
  String get circlePlanWhen => 'Quand (facultatif)';

  @override
  String get circlePlanNote => 'Détails (facultatifs)';

  @override
  String get circlePlanIn => 'J\'en suis';

  @override
  String get circlePlanJoined => 'Tu en es';

  @override
  String circlePlanPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '1 participant',
    );
    return '$_temp0';
  }

  @override
  String get circlePlanPrivacy =>
      'Seuls les membres du cercle voient les projets.';

  @override
  String get groupConcert => 'Le concert';

  @override
  String get groupYourStatus => 'Ton statut';

  @override
  String get groupStatusHint => 'Seuls les membres de ce groupe le voient.';

  @override
  String get groupHeld =>
      'Masqué pendant que les admins examinent les signalements';

  @override
  String get groupRemoveAdmin => 'Retirer (admin)';

  @override
  String get groupBan => 'Bannir du groupe';

  @override
  String groupBanConfirm(String name) {
    return 'Bannir $name de ce groupe ? Cette personne ne pourra plus revenir.';
  }

  @override
  String get groupErrorBanned =>
      'Cette personne ne peut pas être invitée dans ce groupe.';

  @override
  String get groupYourGroups => 'Tes groupes pour cet événement';

  @override
  String get groupStart => 'Créer un groupe pour le concert';

  @override
  String get groupReportMember => 'Signaler le membre';

  @override
  String get vibeTitle => 'Daily Vibe';

  @override
  String get vibeQuestion => 'Quel est ton vibe aujourd\'hui ?';

  @override
  String get vibeShare => 'Partager ton vibe';

  @override
  String get vibeChange => 'Changer le vibe du jour';

  @override
  String get vibeSearchHint => 'Rechercher un titre sur Spotify';

  @override
  String get vibeTabSpotify => 'Spotify';

  @override
  String get vibeTabLink => 'Autre lien';

  @override
  String get vibeLinkHint =>
      'Lien Apple Music, YouTube, SoundCloud ou Bandcamp';

  @override
  String get vibeTitleHint => 'Titre';

  @override
  String get vibeArtistHint => 'Artiste';

  @override
  String get vibeCaptionHint => 'Ajouter une légende (facultatif)';

  @override
  String get vibeExpires => 'Disparaît après 24 heures';

  @override
  String get vibeEveryone => 'Visible par tout le monde';

  @override
  String get vibeVisibilityBody =>
      'Désactivé : seuls tes connexions et tes affinités musicales le voient.';

  @override
  String get vibePost => 'Publier le vibe';

  @override
  String get vibePosted => 'Ton vibe est en ligne';

  @override
  String get vibeEmptyTitle => 'Pas encore de vibe aujourd\'hui';

  @override
  String get vibeEmptyBody =>
      'Partage le tien, et connecte-toi ou abonne-toi à des personnes pour voir les leurs.';

  @override
  String get vibeListen => 'Écouter sur Spotify';

  @override
  String get vibeOpen => 'Ouvrir le lien';

  @override
  String get vibeSave => 'Ajouter aux découvertes';

  @override
  String get vibeSaved => 'Dans tes découvertes';

  @override
  String vibeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
      zero: 'Commenter',
    );
    return '$_temp0';
  }

  @override
  String get vibeCommentHint => 'Ajouter un commentaire';

  @override
  String get vibeReply => 'Répondre';

  @override
  String vibeReplyingTo(String name) {
    return 'En réponse à $name';
  }

  @override
  String vibeExpiresIn(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours h restantes',
      one: '1 h restante',
      zero: 'Moins d\'1 h',
    );
    return '$_temp0';
  }

  @override
  String get vibeDelete => 'Supprimer mon vibe';

  @override
  String get vibeSearchEmpty => 'Aucun titre trouvé.';

  @override
  String get vibeProviderUnavailable =>
      'La recherche Spotify n\'est pas disponible pour l\'instant. Tu peux coller un lien.';

  @override
  String get vibeError => 'Impossible de publier ton vibe. Réessaie.';

  @override
  String get vibeAttribution => 'Infos et pochette fournies par Spotify';

  @override
  String get discoveriesTitle => 'Découvertes';

  @override
  String get discoveriesEmpty =>
      'Les titres que tu ajoutes depuis Daily Vibe, les stories, les posts et les communautés apparaissent ici. Toi seul peux les voir.';

  @override
  String get discoveriesSubtitle => 'Titres découverts sur VIBRA';

  @override
  String get vibeLoadError => 'Impossible de charger Daily Vibe.';

  @override
  String get vibeHomeCta => 'Partage le titre qui est ton vibe du jour';

  @override
  String get storyAdd => 'Ajouter une story';

  @override
  String get storyYours => 'Ta story';

  @override
  String get storyNew => 'Nouvelle story musicale';

  @override
  String get storyKindNowPlaying => 'En écoute';

  @override
  String get storyKindArtist => 'Artiste préféré';

  @override
  String get storyKindAlbum => 'Album recommandé';

  @override
  String get storyKindPlaylist => 'Playlist';

  @override
  String get storyKindConcertPhoto => 'Photo de concert';

  @override
  String get storyKindOpinion => 'Avis musical';

  @override
  String get storyAttribution => 'Infos et pochettes fournies par Spotify';

  @override
  String get storyPreview => 'Aperçu de la story';

  @override
  String get storySearchArtist => 'Rechercher un artiste sur Spotify';

  @override
  String get storySearchAlbum => 'Rechercher un album sur Spotify';

  @override
  String get storySearchPlaylist =>
      'Rechercher une playlist publique sur Spotify';

  @override
  String get storySearchEmpty => 'Aucun résultat.';

  @override
  String get storyArtistNameHint => 'Nom de l\'artiste';

  @override
  String get storyAlbumTitleHint => 'Titre de l\'album';

  @override
  String get storyPlaylistTitleHint => 'Nom de la playlist';

  @override
  String get storyPlaylistOwnerHint => 'Créée par (facultatif)';

  @override
  String get storyPickPhoto => 'Choisir une photo de concert';

  @override
  String get storyChangePhoto => 'Changer de photo';

  @override
  String get storyPhotoPrivacy =>
      'La localisation et les données de l\'appareil sont retirées de la photo avant le partage.';

  @override
  String get storyTagConcert => 'Concert (facultatif)';

  @override
  String get storyNoConcert => 'Aucun concert';

  @override
  String get storyOpinionHint => 'Ton avis : un album, une scène, un titre…';

  @override
  String get storyBackground => 'Fond';

  @override
  String get storyAudience => 'Qui peut la voir';

  @override
  String get storyDefaultAudience => 'Qui voit tes stories par défaut';

  @override
  String get storyAudienceConnections => 'Connexions';

  @override
  String get storyAudienceEveryone => 'Tout le monde';

  @override
  String get storyAudienceConnectionsBody =>
      'Tes connexions et tes affinités musicales.';

  @override
  String get storyAudienceEveryoneBody =>
      'Aussi les personnes qui te suivent. Les personnes bloquées et celles à qui tu masques tes stories ne la voient jamais.';

  @override
  String get storyAllowReplies => 'Autoriser les réponses';

  @override
  String get storyAllowRepliesBody =>
      'Les réponses sont privées : seuls toi et la personne qui répond les voyez.';

  @override
  String get storyExpires => 'Disparaît après 24 heures.';

  @override
  String get storyShare => 'Partager la story';

  @override
  String get storyPosted => 'Ta story est en ligne pour 24 heures';

  @override
  String get storyError => 'Un problème est survenu. Réessaie.';

  @override
  String get storyRateLimited =>
      'Tu partages beaucoup. Patiente un instant et réessaie.';

  @override
  String get storySpam =>
      'Cela ressemble à du spam. Retire les liens et réessaie.';

  @override
  String get storyPhotoError =>
      'Cette photo ne peut pas être utilisée. Choisis un JPG ou PNG de 10 Mo maximum.';

  @override
  String get storySettingsTitle => 'Confidentialité des stories';

  @override
  String get storyHideFrom => 'Masquer tes stories à';

  @override
  String get storyHideFromBody =>
      'Ces personnes ne verront pas tes stories et n\'en seront pas informées.';

  @override
  String get storyHidden => 'Masqué de tes stories';

  @override
  String get storyNoConnections =>
      'Quand tu auras des connexions, tu pourras choisir ici qui ne voit pas tes stories.';

  @override
  String get storyJustNow => 'maintenant';

  @override
  String storyMinutesAgo(int minutes) {
    return '$minutes min';
  }

  @override
  String storyHoursAgo(int hours) {
    return '$hours h';
  }

  @override
  String get storyPrevious => 'Story précédente';

  @override
  String get storyNext => 'Story suivante';

  @override
  String get storyMore => 'Plus d\'options';

  @override
  String get storyLoadError => 'Impossible de charger ces stories.';

  @override
  String get storyGone => 'Ces stories ont expiré ou ne sont plus disponibles.';

  @override
  String get storyHeld =>
      'Masquée pendant son examen après des signalements. Toi seul peux la voir.';

  @override
  String storyReplyHint(String name) {
    return 'Répondre à $name…';
  }

  @override
  String get storySendReply => 'Envoyer';

  @override
  String get storyReplySent => 'Réponse envoyée en privé';

  @override
  String get storyRepliesOff =>
      'Les réponses sont désactivées pour cette story';

  @override
  String get storyRepliesOffMine =>
      'Les réponses sont désactivées pour cette story.';

  @override
  String storyViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vues',
      one: '1 vue',
      zero: 'Aucune vue',
    );
    return '$_temp0';
  }

  @override
  String storyReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
      zero: 'Réponses',
    );
    return '$_temp0';
  }

  @override
  String storyReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réactions',
      one: '1 réaction',
    );
    return '$_temp0';
  }

  @override
  String get storyInsightsPrivate => 'Toi seul vois qui a vu et répondu.';

  @override
  String get storyNoViewers => 'Pas encore de vues.';

  @override
  String get storyNoReplies => 'Pas encore de réponses.';

  @override
  String storyAnswerHint(String name) {
    return 'Répondre à $name en privé…';
  }

  @override
  String get storyMakeEveryone => 'Montrer à tout le monde';

  @override
  String get storyMakeConnectionsOnly => 'Montrer aux connexions uniquement';

  @override
  String get storyNowEveryone =>
      'Tout le monde peut maintenant voir cette story';

  @override
  String get storyNowConnections =>
      'Seules tes connexions voient maintenant cette story';

  @override
  String get storyTurnRepliesOff => 'Désactiver les réponses';

  @override
  String get storyTurnRepliesOn => 'Activer les réponses';

  @override
  String get storyDelete => 'Supprimer la story';

  @override
  String get storyDeleted => 'Story supprimée';

  @override
  String storyMute(String name) {
    return 'Masquer les stories de $name';
  }

  @override
  String storyMuted(String name) {
    return 'Tu ne verras plus les stories de $name. Cette personne n\'en sera pas informée.';
  }

  @override
  String get feedTitle => 'VIBRA Feed';

  @override
  String get feedHomeCta =>
      'Recommandations, critiques et découvertes de ton univers musical';

  @override
  String get feedForYou => 'Pour toi';

  @override
  String get feedFollowing => 'Abonnements';

  @override
  String get feedLatest => 'Récents';

  @override
  String get feedForYouBody =>
      'Classé selon les personnes que tu suis, tes connexions, tes communautés et la musique que tu aimes. Chaque post dit pourquoi il est là.';

  @override
  String get feedFollowingBody =>
      'Du plus récent au plus ancien, des personnes que tu suis et de tes connexions.';

  @override
  String get feedLatestBody =>
      'Du plus récent au plus ancien, tous les posts que tu peux voir.';

  @override
  String get feedCompose => 'Publier';

  @override
  String get feedNewPost => 'Nouveau post';

  @override
  String get feedPublish => 'Publier';

  @override
  String get feedPosted => 'Ton post est en ligne';

  @override
  String get feedKindSong => 'Titre';

  @override
  String get feedKindAlbum => 'Album';

  @override
  String get feedKindPlaylist => 'Playlist';

  @override
  String get feedKindRecommendation => 'Recommandation';

  @override
  String get feedKindDiscovery => 'Découverte';

  @override
  String get feedKindReview => 'Critique';

  @override
  String get feedKindOpinion => 'Avis';

  @override
  String get feedKindConcertPhoto => 'Photo de concert';

  @override
  String get feedKindShare => 'Partagé';

  @override
  String get feedItemTrack => 'Titre';

  @override
  String get feedItemAlbum => 'Album';

  @override
  String get feedItemArtist => 'Artiste';

  @override
  String get feedItemPlaylist => 'Playlist';

  @override
  String get feedWhatAbout => 'De quoi s\'agit-il ?';

  @override
  String get feedYourRating => 'Ta note';

  @override
  String feedRatingLabel(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get feedReviewHint => 'Qu\'en as-tu pensé ? Sois précis.';

  @override
  String get feedDiscoveryHint => 'Comment l\'as-tu découvert ?';

  @override
  String get feedRecommendationHint => 'Pourquoi faudrait-il l\'écouter ?';

  @override
  String get feedBodyHint => 'Dis-en quelque chose (facultatif)';

  @override
  String get feedAudienceEveryoneBody =>
      'Tout le monde sur VIBRA peut le voir, sauf les personnes bloquées.';

  @override
  String get feedAllowComments => 'Autoriser les commentaires';

  @override
  String get feedDuplicatePost => 'Tu as déjà publié ça aujourd\'hui.';

  @override
  String get feedError => 'Un problème est survenu. Réessaie.';

  @override
  String get feedLoadError => 'Impossible de charger le fil.';

  @override
  String get feedEmptyTitle => 'Rien pour l\'instant';

  @override
  String get feedEmptyBody =>
      'Partage une recommandation, ou rejoins des communautés et suis des personnes pour remplir ton fil.';

  @override
  String get feedEmptyFollowing =>
      'Les posts des personnes que tu suis et de tes connexions apparaissent ici.';

  @override
  String get feedEnd => 'Tu es à jour';

  @override
  String get feedReasonFollowing => 'Tu suis cette personne';

  @override
  String get feedReasonConnection => 'Ta connexion';

  @override
  String get feedReasonArtists => 'Un artiste que tu écoutes';

  @override
  String get feedReasonGenres => 'Des genres que tu aimes';

  @override
  String get feedReasonCommunity => 'De tes communautés';

  @override
  String get feedReasonMatch => 'Affinité musicale';

  @override
  String get feedReasonInteraction =>
      'Tu interagis souvent avec cette personne';

  @override
  String get feedReasonNew => 'Nouveau sur VIBRA';

  @override
  String feedDaysAgo(int days) {
    return '$days j';
  }

  @override
  String get feedHeld =>
      'Masqué pendant son examen après des signalements. Toi seul peux le voir.';

  @override
  String get feedLike => 'J\'aime';

  @override
  String get feedUnlike => 'Retirer j\'aime';

  @override
  String get feedReact => 'Réagir';

  @override
  String get feedComments => 'Commentaires';

  @override
  String get feedShare => 'Partager';

  @override
  String get feedSave => 'Enregistrer';

  @override
  String get feedUnsave => 'Retirer des enregistrements';

  @override
  String get feedSaved => 'Enregistré';

  @override
  String get feedUnsaved => 'Retiré des enregistrements';

  @override
  String get feedShareToFeed => 'Partager sur ton fil';

  @override
  String get feedShareCommentHint => 'Ajouter un commentaire (facultatif)';

  @override
  String get feedShareOnlyPublic =>
      'Seuls les posts publics d\'autres personnes peuvent être partagés sur ton fil.';

  @override
  String get feedShared => 'Partagé sur ton fil';

  @override
  String get feedAlreadyShared => 'Tu as déjà partagé ce post.';

  @override
  String get feedCopyLink => 'Copier le lien de la musique';

  @override
  String get feedLinkCopied => 'Lien copié';

  @override
  String get feedTurnCommentsOff => 'Désactiver les commentaires';

  @override
  String get feedTurnCommentsOn => 'Activer les commentaires';

  @override
  String get feedDelete => 'Supprimer le post';

  @override
  String get feedDeleted => 'Post supprimé';

  @override
  String get feedNotInterested => 'Pas intéressé';

  @override
  String get feedNotInterestedDone => 'Tu verras moins de posts comme celui-ci';

  @override
  String get feedPostTitle => 'Post';

  @override
  String get feedPostGone => 'Post indisponible';

  @override
  String get feedPostGoneBody =>
      'Il a été supprimé ou tu ne peux plus le voir.';

  @override
  String get feedCommentHint => 'Ajouter un commentaire';

  @override
  String get feedCommentsOff =>
      'Les commentaires sont désactivés pour ce post.';

  @override
  String get feedDuplicateComment => 'Tu as déjà écrit ce commentaire.';

  @override
  String get feedNoComments =>
      'Pas encore de commentaires. Lance la conversation.';

  @override
  String get feedDeleteComment => 'Supprimer le commentaire';

  @override
  String get feedSavedTitle => 'Posts enregistrés';

  @override
  String get feedSavedSubtitle => 'Les posts que tu as enregistrés dans le fil';

  @override
  String get feedSavedEmpty => 'Aucun post enregistré';

  @override
  String get feedSavedEmptyBody =>
      'Touche le signet d\'un post pour le garder ici. Toi seul vois tes enregistrements.';

  @override
  String get feedPostsTitle => 'Posts';

  @override
  String feedPostsOf(String name) {
    return 'Posts de $name';
  }

  @override
  String get feedSeeAllPosts => 'Tout voir';

  @override
  String get feedNoPosts => 'Pas encore de posts';

  @override
  String get feedNoPostsBody => 'Les posts que tu peux voir apparaîtront ici.';

  @override
  String get feedYourPosts => 'Tes posts';

  @override
  String get feedYourPostsSubtitle => 'Tout ce que tu as publié dans le fil';

  @override
  String get reactionFire => 'Feu';

  @override
  String get reactionObsessed => 'Obsession';

  @override
  String get reactionUnderrated => 'Sous-coté';

  @override
  String get reactionClassic => 'Classique';

  @override
  String get reactionNewDiscovery => 'Nouvelle découverte';

  @override
  String get reactionOnRepeat => 'En boucle';

  @override
  String get reactionHeart => 'J\'adore';

  @override
  String get reactionHeadphones => 'En écoute';

  @override
  String get reactionClap => 'Bravo';

  @override
  String get reactionMindBlown => 'Bluffant';

  @override
  String get reactionTrackTitle => 'Réagis à ce titre';

  @override
  String get discoveryAdded => 'Ajouté à tes découvertes';

  @override
  String get discoveryAddFailed => 'Impossible d\'ajouter le titre. Réessaie.';

  @override
  String get discoveryOffer =>
      'Une nouvelle découverte ? Garde-la dans tes découvertes.';

  @override
  String discoveryFoundVia(String name) {
    return 'via $name';
  }

  @override
  String get aiTitle => 'VIBRA AI';

  @override
  String get aiHomeCta =>
      'Demande des artistes, albums, concerts et genres à découvrir';

  @override
  String get aiPrivacyTile =>
      'Assistant musical facultatif. Désactivé tant que tu ne l\'actives pas.';

  @override
  String get aiUnavailableTitle => 'VIBRA AI n\'est pas disponible';

  @override
  String get aiUnavailableBody =>
      'L\'assistant n\'est pas disponible pour le moment. Tout le reste de VIBRA fonctionne normalement.';

  @override
  String get aiConsentTitle => 'Voici ton assistant musical';

  @override
  String get aiConsentIntro =>
      'Demande des artistes similaires, des albums pour tes goûts, des concerts selon tes centres d\'intérêt, des communautés et de nouveaux genres. C\'est facultatif et désactivé tant que tu ne l\'actives pas.';

  @override
  String get aiConsentUses => 'Pour répondre, il utilise';

  @override
  String get aiConsentUsesProfile =>
      'Ton Musical DNA, tes artistes favoris et les genres que tu as choisis';

  @override
  String get aiConsentUsesChat =>
      'Ta question et les derniers messages de cette discussion';

  @override
  String get aiConsentUsesCatalogue =>
      'Le catalogue public de Spotify et les concerts et communautés de VIBRA';

  @override
  String get aiConsentNever => 'Il n\'utilise jamais';

  @override
  String get aiConsentNeverBody =>
      'Tes messages, ta localisation, tes contacts, les profils d\'autres personnes ni ta connexion Spotify. VIBRA n\'enregistre pas les discussions.';

  @override
  String get aiConsentProvider =>
      'Les réponses sont générées par un fournisseur d\'IA externe (Anthropic), qui reçoit les informations ci-dessus pour chaque question. Tu peux désactiver VIBRA AI à tout moment.';

  @override
  String get aiConsentAccept => 'Activer VIBRA AI';

  @override
  String get aiConsentDecline => 'Pas maintenant';

  @override
  String get aiTurnOff => 'Désactiver VIBRA AI';

  @override
  String get aiTurnedOff => 'VIBRA AI est désactivé';

  @override
  String get aiNewChat => 'Nouvelle conversation';

  @override
  String get aiIntro => 'Que veux-tu découvrir ?';

  @override
  String get aiExampleSimilar =>
      'Recommande-moi des artistes proches de Travis Scott';

  @override
  String get aiExampleUnderground => 'Trouve des artistes Hip-Hop underground';

  @override
  String get aiExampleAlbums =>
      'Recommande-moi des albums selon mon profil musical';

  @override
  String get aiExampleExplain =>
      'Explique pourquoi deux artistes ont un son proche';

  @override
  String get aiExampleConcerts =>
      'Trouve des concerts selon mes centres d\'intérêt';

  @override
  String get aiExampleCommunities =>
      'Suggère-moi des communautés qui pourraient me plaire';

  @override
  String get aiExampleGenres => 'Aide-moi à découvrir de nouveaux genres';

  @override
  String get aiInputHint => 'Pose une question musicale à VIBRA AI';

  @override
  String get aiThinking => 'Je cherche…';

  @override
  String get aiGeneratedLabel => 'Généré par IA · peut contenir des erreurs';

  @override
  String get aiVerifiedTitle => 'Résultats vérifiés';

  @override
  String get aiIdeasTitle => 'Idées à explorer';

  @override
  String get aiIdeasBody => 'Suggestions générées, non vérifiées.';

  @override
  String get aiSourceSpotify => 'Vérifié sur Spotify';

  @override
  String get aiSourceEvents => 'Issu des concerts VIBRA';

  @override
  String get aiSourceCommunities => 'Communauté VIBRA';

  @override
  String get aiSourceDna => 'Issu de ton Musical DNA';

  @override
  String get aiSourceGenres => 'Catalogue des genres VIBRA';

  @override
  String aiMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get aiRateLimited =>
      'Tu as posé beaucoup de questions. Réessaie dans un moment.';

  @override
  String get aiError => 'Un problème est survenu. Réessaie.';

  @override
  String get aiRefused =>
      'VIBRA AI ne peut pas t\'aider avec ça. Essaie une question sur la musique.';

  @override
  String get aiIncomplete =>
      'La réponse n\'a pas pu être complétée. Essaie de poser la question plus simplement.';

  @override
  String get discoverTitle => 'Découvre ton prochain artiste';

  @override
  String get discoverHomeCta =>
      'Artistes proches, émergents et underground choisis pour toi';

  @override
  String get discoverIntro =>
      'D\'après tes artistes préférés, ton Musical DNA, les titres découverts et tes retours. Tes réponses orientent les prochaines suggestions.';

  @override
  String get discoverAll => 'Tous';

  @override
  String get discoverSimilar => 'Proches';

  @override
  String get discoverCollaborations => 'Collaborations';

  @override
  String get discoverEmerging => 'Émergents';

  @override
  String get discoverUnderground => 'Underground';

  @override
  String get discoverExploration => 'Nouveaux genres';

  @override
  String discoverReasonCollab(String artist) {
    return 'A collaboré avec $artist';
  }

  @override
  String discoverReasonExplore(String genre) {
    return 'Un pas vers : $genre';
  }

  @override
  String discoverReasonGenres(String genres) {
    return 'En phase avec : $genres';
  }

  @override
  String get discoverLike => 'J\'aime';

  @override
  String get discoverSave => 'Garder pour plus tard';

  @override
  String get discoverKnown => 'Je connais déjà';

  @override
  String get discoverNotInterested => 'Ça ne m\'intéresse pas';

  @override
  String get discoverLiked => 'Compris : plus de ce style';

  @override
  String get discoverUndone => 'Retiré';

  @override
  String get discoverSaved => 'Gardé pour plus tard';

  @override
  String get discoverUnsaved => 'Retiré des enregistrements';

  @override
  String get discoverKnownDone =>
      'C\'est noté. Cet artiste ne te sera plus suggéré.';

  @override
  String get discoverNotInterestedDone =>
      'Tu ne verras plus cet artiste, et moins d\'artistes similaires.';

  @override
  String get discoverRefresh => 'Nouvelles suggestions';

  @override
  String get discoverRefreshLimited =>
      'Impossible d\'actualiser pour l\'instant. Réessaie dans quelques minutes.';

  @override
  String get discoverError => 'Un problème est survenu. Réessaie.';

  @override
  String get discoverEmptyTitle => 'Pas encore de nouveaux artistes';

  @override
  String get discoverEmptyBody =>
      'Reviens plus tard ou touche Nouvelles suggestions.';

  @override
  String get discoverNoProfile =>
      'Connecte Spotify ou choisis quelques genres pour que VIBRA sache ce que tu aimes.';

  @override
  String get discoverPickGenres => 'Choisir des genres';

  @override
  String get discoverSavedTitle => 'Artistes enregistrés';

  @override
  String get discoverSavedSubtitle => 'Artistes gardés pour plus tard';

  @override
  String get discoverSavedEmpty => 'Aucun artiste enregistré';

  @override
  String get discoverSavedEmptyBody =>
      'Touche Garder pour plus tard sur une suggestion pour la retrouver ici.';

  @override
  String get tasteTitle => 'Évolution de tes goûts';

  @override
  String get tasteOpen => 'Vois comment tes goûts ont évolué';

  @override
  String get tastePeriodMonth => '1 mois';

  @override
  String get tastePeriodThreeMonths => '3 mois';

  @override
  String get tastePeriodSixMonths => '6 mois';

  @override
  String get tastePeriodYear => '1 an';

  @override
  String tasteEvolved(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Tes goûts musicaux ont évolué ce dernier mois',
      'year': 'Tes goûts musicaux ont évolué cette dernière année',
      'three': 'Tes goûts musicaux ont évolué ces 3 derniers mois',
      'six': 'Tes goûts musicaux ont évolué ces 6 derniers mois',
      'other': 'Tes goûts musicaux ont évolué ces 3 derniers mois',
    });
    return '$_temp0';
  }

  @override
  String tasteSteady(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Tes goûts musicaux sont restés stables ce dernier mois',
      'year': 'Tes goûts musicaux sont restés stables cette dernière année',
      'three': 'Tes goûts musicaux sont restés stables ces 3 derniers mois',
      'six': 'Tes goûts musicaux sont restés stables ces 6 derniers mois',
      'other': 'Tes goûts musicaux sont restés stables ces 3 derniers mois',
    });
    return '$_temp0';
  }

  @override
  String tasteComparing(String from, String to) {
    return 'Comparaison de ton Musical DNA du $from avec celui du $to.';
  }

  @override
  String tasteShortHistory(String from, String to) {
    return 'Ton historique commence le $from : la comparaison porte donc sur le $from et le $to.';
  }

  @override
  String tasteChangePoints(int points) {
    return '$points points de pourcentage de ton mélange de genres ont bougé.';
  }

  @override
  String get tasteThenNow => 'Avant et maintenant';

  @override
  String get tasteThen => 'Avant';

  @override
  String get tasteNow => 'Maintenant';

  @override
  String get tasteTimeline => 'Au fil du temps';

  @override
  String tasteTimelineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relevés',
      one: '1 relevé',
    );
    return '$_temp0 de ton Musical DNA sur cette période.';
  }

  @override
  String get tasteNewGenres => 'Nouveaux genres découverts';

  @override
  String get tasteNoNewGenres => 'Aucun nouveau genre sur cette période.';

  @override
  String get tasteEmergingArtists => 'Favoris en hausse';

  @override
  String get tasteNoEmergingArtists =>
      'Tes artistes préférés sont les mêmes qu\'avant.';

  @override
  String get tasteNoArtistData =>
      'Connecte Spotify pour voir comment évoluent tes artistes préférés.';

  @override
  String get tasteArtistNew => 'Nouveau';

  @override
  String tasteArtistRose(int from, int to) {
    return '#$from → #$to';
  }

  @override
  String get tastePrevious => 'Ce que tu écoutais davantage avant';

  @override
  String get tasteNoPrevious => 'Rien de ce que tu aimais ne s\'est estompé.';

  @override
  String get tasteFormerTopArtist => 'Faisait partie de tes artistes favoris';

  @override
  String get tasteCommunities => 'Communautés rejointes';

  @override
  String get tasteNoCommunities =>
      'Tu n\'as rejoint aucune communauté sur cette période.';

  @override
  String tasteJoinedOn(String date) {
    return 'Rejointe le $date';
  }

  @override
  String get tasteNoDnaTitle => 'Pas encore de Musical DNA';

  @override
  String get tasteNoDnaBody =>
      'L\'évolution de tes goûts commence quand VIBRA a ton Musical DNA.';

  @override
  String get tasteTooEarlyTitle => 'Pas encore assez d\'historique';

  @override
  String tasteTooEarlyBody(String date) {
    return 'Ton historique commence le $date. Reviens dans quelques semaines pour voir l\'évolution de tes goûts.';
  }

  @override
  String get tasteOffTitle => 'Historique des goûts désactivé';

  @override
  String get tasteOffBody =>
      'VIBRA ne garde que ton Musical DNA actuel. Active l\'historique ci-dessous pour suivre tes goûts à partir d\'aujourd\'hui.';

  @override
  String get tasteKeepHistory => 'Conserver l\'historique de mes goûts';

  @override
  String get tasteKeepHistoryBody =>
      'Un relevé de ton Musical DNA par jour, conservé jusqu\'à 400 jours et visible uniquement par toi.';

  @override
  String get tasteTurnOffTitle => 'Désactiver l\'historique des goûts ?';

  @override
  String get tasteTurnOffBody =>
      'Tes relevés passés seront supprimés et seul ton Musical DNA actuel sera conservé. Les fonctions qui comparent tes goûts dans le temps ne fonctionneront plus jusqu\'à sa réactivation.';

  @override
  String get tasteTurnOffConfirm => 'Désactiver et supprimer';

  @override
  String get tasteError => 'Un problème est survenu. Réessaie.';

  @override
  String get profileSectionGenres => 'Genres préférés';

  @override
  String get profileSectionArtists => 'Artistes préférés';

  @override
  String get profileSectionStats => 'Statistiques musicales';

  @override
  String get profileSectionSavedSongs => 'Titres enregistrés';

  @override
  String get profileSectionPlaylists => 'Playlists partagées';

  @override
  String get profileSectionEvents => 'Événements à venir';

  @override
  String get profileSectionCommunities => 'Communautés';

  @override
  String get profileSectionCircles => 'Cercles';

  @override
  String get profileSectionActivity => 'Activité musicale';

  @override
  String get profileLevelPublic => 'Tout le monde';

  @override
  String get profileLevelConnections => 'Connexions';

  @override
  String get profileLevelPrivate => 'Moi uniquement';

  @override
  String get profileRelationConnection => 'Ta connexion';

  @override
  String get profileRelationMatch => 'Affinité musicale';

  @override
  String profileMemberSince(String date) {
    return 'Sur VIBRA depuis $date';
  }

  @override
  String profileSignatureSemantics(String name, String genres) {
    return '$name, signature sonore : $genres';
  }

  @override
  String get profileNoGenres => 'Pas encore de genres préférés.';

  @override
  String get profileNoArtists => 'Pas encore d\'artistes préférés.';

  @override
  String get profileNoPlaylists => 'Pas encore de playlist partagée.';

  @override
  String get profileNoEvents => 'Aucun événement à venir à afficher.';

  @override
  String get profileNoCommunities => 'Dans aucune communauté pour l\'instant.';

  @override
  String get profileNoCircles => 'Tu n\'es dans aucun cercle pour l\'instant.';

  @override
  String get profileNoSharedCircles =>
      'Vous n\'êtes dans aucun cercle ensemble.';

  @override
  String get profileSharedCirclesNote =>
      'Cercles dont vous faites tous les deux partie.';

  @override
  String get profileNoActivity => 'Aucune activité récente.';

  @override
  String profileActivityPosted(String title) {
    return 'A publié : $title';
  }

  @override
  String profileActivityVibe(String title) {
    return 'Daily Vibe : $title';
  }

  @override
  String profileActivityJoined(String name) {
    return 'A rejoint $name';
  }

  @override
  String get profileEventGoing => 'Y va';

  @override
  String get profileEventMaybe => 'Peut-être';

  @override
  String get profileEventInterested => 'Intérêt';

  @override
  String get profileStatGenres => 'Genres';

  @override
  String get profileStatDiversity => 'Diversité';

  @override
  String get profileStatDiscoveries => 'Découvertes';

  @override
  String get profileStatPosts => 'Posts';

  @override
  String get profileStatConcerts => 'Concerts vus';

  @override
  String get profileSomePrivate =>
      'Certaines sections de ce profil sont privées.';

  @override
  String get profilePrivacyTitle => 'Confidentialité du profil';

  @override
  String get profilePrivacyTile =>
      'Choisis qui voit chaque partie de ton profil musical';

  @override
  String get profilePrivacyIntro =>
      'Choisis qui peut voir chaque partie de ton profil. Ta photo, ton nom, ton pseudo et ta bio restent visibles par les personnes avec qui tu peux interagir.';

  @override
  String get profilePrivacyEventsNote =>
      'Chaque événement garde aussi la visibilité choisie dans Qui y va.';

  @override
  String get profilePrivacyCirclesNote =>
      'Les autres ne voient que les cercles dont ils font aussi partie.';

  @override
  String get profilePrivacyPostsNote =>
      'Chaque post garde aussi son propre public.';

  @override
  String get profilePrivacyDnaNote =>
      'Le Musical DNA a son propre réglage de visibilité.';

  @override
  String get profilePrivacyError => 'Impossible d\'enregistrer. Réessaie.';

  @override
  String get safetyTitle => 'Sécurité et confidentialité';

  @override
  String get safetySettingsSubtitle =>
      'Blocages, signalements, visibilité et localisation au même endroit';

  @override
  String get safetyIntro =>
      'Tout ce qui décide qui peut te joindre et ce que les autres voient. Ces règles sont appliquées par les serveurs de VIBRA, partout dans l\'app.';

  @override
  String get safetyPeople => 'Personnes';

  @override
  String get safetyBlockedTitle => 'Personnes bloquées';

  @override
  String safetyBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: 'Personne de bloqué',
    );
    return '$_temp0';
  }

  @override
  String get safetyBlockExplain =>
      'Le blocage s\'applique partout : messages, commentaires, posts, stories, communautés, cercles, événements et radar. Il supprime aussi les abonnements et connexions entre vous. L\'autre personne n\'est pas prévenue.';

  @override
  String get safetyNoBlocked => 'Tu n\'as bloqué personne';

  @override
  String safetyBlockedOn(String date) {
    return 'Depuis le $date';
  }

  @override
  String get safetyUnblock => 'Débloquer';

  @override
  String safetyUnblockTitle(String name) {
    return 'Débloquer $name ?';
  }

  @override
  String get safetyUnblockBody =>
      'Cette personne pourra de nouveau te trouver et te contacter. Les abonnements et connexions supprimés par le blocage ne reviennent pas.';

  @override
  String safetyUnblocked(String name) {
    return 'Déblocage effectué : $name';
  }

  @override
  String safetyBlockTitle(String name) {
    return 'Bloquer $name ?';
  }

  @override
  String get safetyBlockBody =>
      'Vous ne vous verrez plus nulle part sur VIBRA, et les abonnements et connexions entre vous seront supprimés. Personne ne sera prévenu.';

  @override
  String get safetyReportUser => 'Signaler cette personne';

  @override
  String get safetyReported => 'Merci. Notre équipe examinera ce signalement.';

  @override
  String get safetyDuplicateReport => 'Tu l\'as déjà signalé récemment.';

  @override
  String get safetyRateLimited => 'Trop de tentatives. Réessaie plus tard.';

  @override
  String get safetyUserUnavailable => 'Cette personne n\'est pas disponible.';

  @override
  String get safetyVisibility => 'Ce que voient les autres';

  @override
  String safetyHiddenFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'masquées à $count personnes',
      one: 'masquées à 1 personne',
    );
    return '$_temp0';
  }

  @override
  String get safetyAttendance => 'Participation aux événements';

  @override
  String get safetyAttendanceBody =>
      'choisie pour chaque événement dans Qui y va';

  @override
  String get safetyLocation => 'Localisation';

  @override
  String get safetyLocationExplain =>
      'Ta position exacte n\'est jamais montrée à personne. Le radar utilise des zones approximatives, et seulement si tu l\'actives.';

  @override
  String get safetyRadarVisible => 'Activé, visible';

  @override
  String get safetyRadarHidden => 'Activé, masqué';

  @override
  String get safetyOn => 'Activé';

  @override
  String get safetyOff => 'Désactivé';

  @override
  String get safetyData => 'Tes données';

  @override
  String get safetyAllPrivacy => 'Tous les réglages de confidentialité';

  @override
  String get safetyAllPrivacyBody =>
      'Consentements, notifications et export de tes données';

  @override
  String get safetyReporting => 'Signalements';

  @override
  String get safetyReportingBody =>
      'Tu peux signaler une personne depuis son profil, et tout message, post, commentaire, story, réponse, vibe ou contenu de communauté depuis son menu. Les signalements sont privés. Un contenu signalé par plusieurs personnes est masqué pendant son examen, et les modérateurs de communauté peuvent supprimer du contenu et exclure des membres.';

  @override
  String get safetyContact => 'Contacter l\'assistance';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifCenterSubtitle => 'Tout ce qui s\'est passé, au même endroit';

  @override
  String get notifSettingsTitle => 'Préférences de notification';

  @override
  String get notifSettingsSubtitle =>
      'Catégories, heures calmes et limite quotidienne';

  @override
  String get notifToday => 'Aujourd\'hui';

  @override
  String get notifThisWeek => 'Cette semaine';

  @override
  String get notifEarlier => 'Plus tôt';

  @override
  String get notifMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notifUnread => 'Non lue';

  @override
  String notifUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notifications non lues',
      one: '1 notification non lue',
    );
    return '$_temp0';
  }

  @override
  String notifGrouped(int count) {
    return '$count nouveautés';
  }

  @override
  String get notifEmptyTitle => 'Pas encore de notifications';

  @override
  String get notifEmptyBody =>
      'Demandes, messages, concerts et tout le reste apparaîtront ici.';

  @override
  String get notifError => 'Un problème est survenu. Réessaie.';

  @override
  String get notifPushAll => 'Notifications push';

  @override
  String get notifPushAllBody =>
      'Désactivées : tout apparaît quand même dans le centre de notifications, rien n\'est envoyé.';

  @override
  String get notifNoDevice =>
      'Les notifications push ne sont pas encore actives sur cet appareil. Tu verras quand même chaque notification ici.';

  @override
  String get notifCategoriesTitle => 'Ce qui peut t\'envoyer une notification';

  @override
  String get notifCategoriesBody =>
      'Désactiver une catégorie arrête ses notifications push. Elle reste visible dans le centre de notifications.';

  @override
  String get notifOncePerDay => 'Au plus une notification push par jour.';

  @override
  String get notifCatRequests => 'Demandes Vibra';

  @override
  String get notifCatRequestsBody =>
      'Nouvelles demandes et demandes acceptées.';

  @override
  String get notifCatMessages => 'Messages';

  @override
  String get notifCatMessagesBody =>
      'Messages privés, demandes de message et chats en direct des événements.';

  @override
  String get notifCatCommunities => 'Activité des communautés';

  @override
  String get notifCatCommunitiesBody =>
      'Commentaires sur tes posts de communauté.';

  @override
  String get notifCatCircles => 'Cercles';

  @override
  String get notifCatCirclesBody => 'Invitations, messages et projets.';

  @override
  String get notifCatConcerts => 'Annonces de concerts';

  @override
  String get notifCatConcertsBody =>
      'Nouveaux concerts d\'artistes que tu écoutes et mises à jour d\'événements.';

  @override
  String get notifCatReminders => 'Rappels d\'événements';

  @override
  String get notifCatRemindersBody =>
      'Une semaine avant, la veille et le jour des événements où tu vas.';

  @override
  String get notifCatRecommendations => 'Recommandations';

  @override
  String get notifCatRecommendationsBody =>
      'Musique recommandée par les personnes que tu suis et nouvelles affinités musicales.';

  @override
  String get notifCatSocial => 'Daily Vibe, stories et posts';

  @override
  String get notifCatSocialBody =>
      'Commentaires et réponses à ce que tu partages.';

  @override
  String get notifCatDiscoveries => 'Découvertes musicales';

  @override
  String get notifCatDiscoveriesBody =>
      'Quand quelqu\'un enregistre un titre que tu as partagé.';

  @override
  String get notifCatUpdates => 'Actualités VIBRA';

  @override
  String get notifCatUpdatesBody =>
      'Ta semaine musicale et quelques suggestions.';

  @override
  String get notifQuietTitle => 'Heures calmes';

  @override
  String get notifQuietBody =>
      'Aucune notification push pendant ces heures, sauf les messages privés. Tout t\'attend dans le centre de notifications.';

  @override
  String get notifQuietFrom => 'De';

  @override
  String get notifQuietTo => 'À';

  @override
  String notifDailyCap(int count) {
    return 'Au plus $count notifications push par jour';
  }

  @override
  String get notifCalmExplain =>
      'Pour que les notifications restent utiles, VIBRA regroupe l\'activité répétée en une seule notification (« 3 nouveaux commentaires »), ne renvoie pas le même groupe avant 30 minutes, retient les notifications push pendant les heures calmes, limite les catégories moins importantes à une notification push par jour et ne te notifie jamais à propos de personnes bloquées.';

  @override
  String get circlesMuted => 'Notifications désactivées';

  @override
  String get profileStories => 'Stories';

  @override
  String storyCardSemantics(String name, String kind, int hours) {
    return 'Story musicale de $name : $kind, il y a $hours h';
  }

  @override
  String musicRadarMapSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Carte des affinités avec $count personnes',
      one: 'Carte des affinités avec 1 personne',
      zero: 'Carte des affinités, personne pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String musicRadarMapPerson(String name, int percent) {
    return '$name, $percent % d’affinité';
  }

  @override
  String get musicRadarMapNote =>
      'Plus près du centre signifie plus de musique en commun. Les positions montrent l’affinité, jamais où se trouve quelqu’un.';

  @override
  String get safetyOverviewError =>
      'Impossible de charger vos réglages actuels. Vous pouvez quand même ouvrir chaque section.';

  @override
  String get homeSignatureEyebrow => 'TA MUSIQUE, TES GENS';

  @override
  String get homeSignatureTitle => 'Trouve tes gens grâce à la musique';

  @override
  String homeDnaTop(String family) {
    return '$family mène ton son';
  }

  @override
  String get homeDnaEmpty => 'Crée-le à partir des genres que tu aimes';

  @override
  String homeFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes sur ta fréquence',
      one: '1 personne sur ta fréquence',
      zero: 'Découvre qui partage tes goûts',
    );
    return '$_temp0';
  }

  @override
  String homeConcertMatchNext(String name) {
    return 'Rencontre ceux qui vont à $name';
  }

  @override
  String get homeConcertMatchNone =>
      'Choisis un concert pour rencontrer ceux qui y vont';

  @override
  String homeCirclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cercles',
      one: '1 cercle',
      zero: 'Crée un petit groupe musical',
    );
    return '$_temp0';
  }

  @override
  String homeCirclesInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations en attente',
      one: '1 invitation en attente',
    );
    return '$_temp0';
  }
}
