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
  String get homeSearchHint => 'Artistes, salles, villes';

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
      'Êtes-vous sûr de vouloir déconnecter votre compte Spotify ? Les recommandations de concerts ne seront plus personnalisées.';

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
      'Vos vibrations musicales sont uniques ! Il n y a personne avec des goûts similaires à proximité pour le moment...';

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
  String get musicStatsHeatmap => 'Carte thermique d écoute';

  @override
  String get musicStatsHeatmapSub => 'Répartition hebdomadaire de vos écoutes';

  @override
  String get liveScreenTitle => 'Live Vibra';

  @override
  String get liveScreenSendFailed =>
      'Échec de l envoi. Vérifiez votre session.';

  @override
  String get liveScreenActivateMode => 'Activer le mode Live';

  @override
  String get liveScreenPresentNowTitle => 'Présents maintenant';

  @override
  String get liveScreenPresentNowSub =>
      'Participants avec une haute compatibilité musicale';

  @override
  String get liveScreenChatTitle => 'Chat de l événement';

  @override
  String get liveScreenChatSub => 'Le chat se ferme automatiquement dans 24h';

  @override
  String get eventDetailNotAvailableTitle => 'Événement indisponible';

  @override
  String get eventDetailNotAvailableMsg =>
      'Cet événement n est plus disponible.';

  @override
  String get eventDetailMapTitle => 'Carte du lieu';

  @override
  String get eventDetailMapSub => 'Lieu de l événement';

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
  String get spotifyAuthStep2Title => '2. Échange d informations';

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
    return 'Une erreur s est produite : $error';
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
  String get legalTermsTitle => 'Conditions d utilisation';

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
  String get legalSupportSec1 => 'E-mail d assistance';

  @override
  String get legalSupportSec2 => 'Problèmes couverts';

  @override
  String get legalSupportSec3 => 'À vérifier d abord';

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
  String get spotifyAuthCancelledTitle => 'Échec de l authentification';

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
      'En utilisant Vibra, vous acceptez d utiliser l application légalement.';

  @override
  String get legalTermsBody2 =>
      'Spotify, Supabase, Firebase et les fournisseurs d événements peuvent être utilisés pour fournir les fonctionnalités principales.';

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
      'Un résumé des informations de confidentialité disponibles dans l application, incluant les catégories de données traitées et les finalités d utilisation.';

  @override
  String get legalTermsSubtitle =>
      'Un résumé des règles, responsabilités et conditions de service applicables à l utilisation de Vibra.';

  @override
  String get legalSupportSubtitle =>
      'Informations de support pour l accès au compte, les notifications, la connexion Spotify et les fonctionnalités en direct.';

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
  String get authUsername => 'Nom d utilisateur';

  @override
  String get authUsernameHint => 'Entrez un nom d utilisateur';

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
  String get authRegister => 'S inscrire';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authAlreadyHaveAccount =>
      'Vous avez déjà un compte ? Se connecter';

  @override
  String get authDontHaveAccount => 'Vous n avez pas de compte ? S inscrire';

  @override
  String get authGenericError => 'Une erreur s est produite';

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
  String get spotifyConnectOnboarding => 'Flux d intégration';

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
  String get spotifyConnectSkip => 'Passer pour l instant';

  @override
  String get homeSpotifySyncTitle =>
      'Débloquer les Recommandations Personnalisées';

  @override
  String get homeSpotifySyncSub => 'Synchronisez vos écoutes musicales';

  @override
  String get homeSpotifySyncDesc =>
      'Connectez Spotify pour recevoir des recommandations d événements et trouver des personnes ayant les mêmes goûts que vous.';

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
      'En connectant Spotify, vous autorisez Vibra à lire votre profil et vos artistes, titres et genres principaux. Ils servent aux suggestions d’événements et aux affinités musicales ; vous pouvez déconnecter Spotify et supprimer ces données dans les réglages.';

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
}
