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
      'Connectez-vous avec votre compte ou utilisez l\'un des fournisseurs compatibles pour débloquer des recommandations personnalisées.';

  @override
  String get loginConsent =>
      'En vous authentifiant, vous acceptez le consentement des données, la gestion des sessions JWT et les préférences de confidentialité RGPD.';

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
      'Les notifications dépendent des autorisations de l\'appareil, de la configuration Firebase et d\'un compte connecté.';

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
      'Impossible de supprimer le compte. Assurez-vous que le RPC a été chargé dans la base de données.';

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
      'Allez dans la section Explorer ou utilisez Social Match pour trouver des personnes ayant les mêmes goûts.';

  @override
  String get friendsSentRequests => 'Demandes envoyées';

  @override
  String get friendsWaitingForReply => 'En attente de réponse';

  @override
  String get friendsPendingApproval => 'En attente d\'approbation';

  @override
  String get socialMatchNewAffinity => 'NOUVELLE AFFINITÉ';

  @override
  String get socialMatchScore => 'SCORE DE MATCH';

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
  String get exploreSearchRadius => 'Rayon de recherche';

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
  String get myEventsTitle => 'Mes événements';

  @override
  String get myEventsGoing => 'J\'y vais';

  @override
  String get myEventsGoingSubtitle => 'Événements confirmés ou à venir';

  @override
  String get myEventsGoingEmpty =>
      'Vous n\'avez pas encore confirmé votre présence à un événement.\\nExplorez et trouvez vos prochains concerts !';

  @override
  String get myEventsSaved => 'Enregistrés';

  @override
  String get myEventsSavedSubtitle => 'À garder à l\'œil';

  @override
  String get myEventsSavedEmpty =>
      'Aucun événement enregistré.\\nEnregistrez les événements qui vous intéressent pour ne pas les manquer.';

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
      'Permissions, statut de la connexion Spotify, configuration Firebase.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Package Android: $android\nBundle iOS: $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra vous aide à connecter Spotify, découvrir des événements et rencontrer des personnes.';

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
      'Vibra combine les goûts musicaux, la découverte d événements et l interaction sociale autour d expériences en direct.';

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
  String get matchScore => 'SCORE DE MATCH';

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
}
