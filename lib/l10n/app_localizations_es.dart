// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Vibra';

  @override
  String get appSlogan => 'No solo escuches música. Vívela.';

  @override
  String get welcomeTitle => 'Bienvenido a Vibra';

  @override
  String get onboardingConnectTitle => 'Conecta tus gustos';

  @override
  String get onboardingConnectBody =>
      'Conecta Spotify, analiza tus artistas, canciones y géneros favoritos, y convierte tu escucha en recomendaciones más inteligentes.';

  @override
  String get onboardingDiscoverTitle => 'Descubre los directos correctos';

  @override
  String get onboardingDiscoverBody =>
      'Vibra combina ubicación, eventos y compatibilidad musical para sugerirte conciertos realmente relevantes.';

  @override
  String get onboardingCommunityTitle => 'Vive la comunidad';

  @override
  String get onboardingCommunityBody =>
      'Encuentra personas con tu mismo sonido, activa el modo Live durante los conciertos y únete a la conversación en tiempo real.';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingGoToLogin => 'Ir al inicio de sesión';

  @override
  String get loginTitle => 'Inicia sesión en Vibra';

  @override
  String get loginSubtitle =>
      'Inicia sesión con tu cuenta o conéctate usando uno de los proveedores compatibles para desbloquear recomendaciones reales.';

  @override
  String get loginConsent =>
      'Al autenticarte, aceptas el consentimiento de datos, la gestión de sesiones JWT y las preferencias de privacidad de GDPR.';

  @override
  String get loginWithSpotify => 'Continuar con Spotify';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get loginWithApple => 'Continuar con Apple';

  @override
  String get loginWithEmail => 'Correo electrónico';

  @override
  String get authFailed => 'Autenticación fallida';

  @override
  String get authErrorOccurred => 'Ha ocurrido un error';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsHeaderNotificationsPrivacy =>
      'Notificaciones y privacidad';

  @override
  String get settingsSubtitleNotificationsPrivacy =>
      'Preferencias, cuenta y gestión de datos';

  @override
  String get settingsOptionCompatibleEvents =>
      'Notificaciones de eventos compatibles';

  @override
  String get settingsOptionHighMatchAlerts =>
      'Alertas de usuarios con alta compatibilidad';

  @override
  String get settingsOptionLiveChat => 'Chat en vivo durante los conciertos';

  @override
  String get settingsOptionDiscoverVisible => 'Perfil visible en Discover';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsSub =>
      'Comprueba los permisos del dispositivo y el estado de entrega push';

  @override
  String get settingsNotificationsSnackbar =>
      'Las notificaciones dependen de los permisos del dispositivo, la configuración de Firebase y una cuenta autenticada.';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsPrivacyPolicySub =>
      'Uso de datos, consentimientos y derechos del usuario';

  @override
  String get settingsTermsOfService => 'Términos de servicio';

  @override
  String get settingsTermsOfServiceSub =>
      'Reglas de uso, responsabilidades y condiciones del servicio';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsSupportSub => 'Ayuda, contactos y opciones de asistencia';

  @override
  String get settingsAbout => 'Acerca de Vibra';

  @override
  String get settingsAboutSub =>
      'Versión de la app, identificadores e información general';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirmTitle => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirmBody =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settingsLogoutAll => 'Cerrar sesión en todos los dispositivos';

  @override
  String get settingsLogoutAllConfirmTitle =>
      'Cerrar sesión en todos los dispositivos';

  @override
  String get settingsLogoutAllConfirmBody =>
      '¿Estás seguro de que quieres cerrar sesión en todos los dispositivos? Se cerrará tu sesión en todas partes.';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountConfirmBody =>
      '¿Estás seguro de que deseas eliminar permanentemente tu cuenta? Esta acción es irreversible.';

  @override
  String get settingsDelete => 'Eliminar';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSub =>
      'Selecciona el idioma preferido de la aplicación';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String homeGreeting(String username) {
    return 'Hola $username, hoy se escucha fuerte.';
  }

  @override
  String get homeSearchHint => 'Artistas, recintos, ciudades';

  @override
  String get homeForYouTitle => 'Para Ti';

  @override
  String get homeForYouSubtitle => 'Eventos con compatibilidad superior a 70';

  @override
  String get homeNearYouTitle => 'Cerca de Ti';

  @override
  String get homeNearYouSubtitle => 'Seleccionados en un radio GPS de 50 km';

  @override
  String get homeNearYouAction => 'Abrir mapa';

  @override
  String get homeTrendingTitle => 'Tendencias';

  @override
  String get homeTrendingSubtitle => 'Los eventos más seguidos de la semana';

  @override
  String get homeTrendingAction => 'Ver todo';

  @override
  String get settingsSpotifyAccount => 'Cuenta de Spotify';

  @override
  String get settingsSpotifyDisconnected =>
      'Desconectado — Conecta para recomendaciones';

  @override
  String get settingsSpotifyDisconnect => 'Desconectar';

  @override
  String get settingsSpotifyDisconnectConfirmTitle => 'Desconectar Spotify';

  @override
  String get settingsSpotifyDisconnectConfirmBody =>
      '¿Estás seguro de que quieres desconectar tu cuenta de Spotify? Las recomendaciones de conciertos ya no serán personalizadas.';

  @override
  String get settingsSpotifyDisconnectedSuccess =>
      'Spotify desconectado con éxito';

  @override
  String get settingsGenerateCompatibleUsers => 'Generar usuarios compatibles';

  @override
  String get settingsGenerateCompatibleUsersSub =>
      'Crea bots con gustos musicales similares';

  @override
  String get settingsGenerateCompatibleUsersLoading =>
      'Generando... Espera por favor.';

  @override
  String get settingsGenerateCompatibleUsersSuccess => '¡Generados con éxito!';

  @override
  String settingsError(String error) {
    return 'Error: $error';
  }

  @override
  String settingsLogoutError(String error) {
    return 'Error durante el cierre de sesión: $error';
  }

  @override
  String settingsSpotifyConnected(String username) {
    return 'Conectado como @$username';
  }

  @override
  String get settingsDeleteAccountError =>
      'No se puede eliminar la cuenta. Asegúrate de que el RPC se haya cargado en la base de datos.';

  @override
  String get eventDetailChat => 'Chat';

  @override
  String get eventDetailTicketsUnavailable =>
      'Enlace de entradas no disponible.';

  @override
  String get eventDetailTicketsError =>
      'No se puede abrir el enlace de la entrada.';

  @override
  String get eventDetailBuyTickets => 'Comprar entradas';

  @override
  String get eventDetailAttendanceConfirmed => '¡Asistencia confirmada!';

  @override
  String get eventDetailAttend => 'Asistiré';

  @override
  String get eventDetailAttendanceMaybe => 'Asistencia establecida en Tal vez';

  @override
  String get eventDetailMaybe => 'Tal vez';

  @override
  String get eventDetailAttendanceNotGoing => 'Indicaste que no irás';

  @override
  String get eventDetailNotGoing => 'No iré';

  @override
  String get eventDetailCopied => '¡Detalles del evento copiados!';

  @override
  String get exploreSearchEvents => 'Buscar eventos';

  @override
  String get exploreSearchInArea => 'Buscar en esta área';

  @override
  String get exploreSearchingEvents => 'Buscando eventos...';

  @override
  String exploreRadius(String radius) {
    return '$radius km';
  }

  @override
  String get friendsTitle => 'Amigos';

  @override
  String get chatSendFailed => 'Envío fallido';

  @override
  String get socialTitle => 'Social';

  @override
  String socialRequestFrom(String userId) {
    return 'Solicitud de $userId';
  }

  @override
  String get socialOpen => 'Abrir';

  @override
  String get userProfileTitle => 'Perfil de usuario';

  @override
  String userProfileCompatibility(String percentage) {
    return '$percentage% compatibilidad';
  }

  @override
  String get userProfileTopArtists => 'Mejores artistas';

  @override
  String get userProfileFriendRequestSent => '¡Solicitud de amistad enviada!';

  @override
  String get userProfileSendRequest => 'Enviar solicitud';

  @override
  String get userProfileOpenChat => 'Abrir chat';

  @override
  String socialMatchVibraSent(String name) {
    return '¡Vibra enviada a $name! 🎉';
  }

  @override
  String get socialMatchViewProfile => 'Ver perfil completo';

  @override
  String get socialMatchIgnore => 'Ignorar';

  @override
  String get userProfileNotAvailableTitle => 'Perfil no disponible';

  @override
  String get userProfileNotAvailableMessage =>
      'Ningún usuario seleccionado o ninguna coincidencia disponible en este momento.';

  @override
  String get userProfileEvents => 'Conciertos pasados/próximos';

  @override
  String get socialDiscoverUsers => 'Descubrir usuarios';

  @override
  String get socialHighCompatibility =>
      'Usuarios con alta compatibilidad musical';

  @override
  String socialRequestsCount(int count) {
    return 'Solicitudes ($count)';
  }

  @override
  String get socialPendingFriendships => 'Amistades pendientes';

  @override
  String get socialRequestsToManage => 'Solicitudes por gestionar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navEvents => 'Eventos';

  @override
  String get navVibra => 'Vibra';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get friendsYourFriends => 'Tus amigos';

  @override
  String get friendsYourConnections => 'Tus conexiones en Vibra';

  @override
  String get friendsNoFriendsYet => 'Todavía no tienes amigos';

  @override
  String get friendsGoToExplore =>
      'Ve a la sección Explorar o usa Social Match para encontrar personas con tus mismos gustos.';

  @override
  String get friendsSentRequests => 'Solicitudes enviadas';

  @override
  String get friendsWaitingForReply => 'Esperando respuesta';

  @override
  String get friendsPendingApproval => 'Pendiente de aprobación';

  @override
  String get socialMatchNewAffinity => 'NUEVA AFINIDAD';

  @override
  String get socialMatchScore => 'MATCH SCORE';

  @override
  String get socialMatchWhyMatched => 'POR QUÉ HAY MATCH';

  @override
  String socialMatchCommonEvents(String count) {
    return 'Live nearby • $count eventos en común';
  }

  @override
  String get socialMatchSendVibra => 'Enviar Vibra';

  @override
  String get exploreSearchHint => 'Buscar por nombre o ciudad (ej. Milán)';

  @override
  String get exploreInteractiveMap => 'Mapa interactivo';

  @override
  String get exploreLiveAroundYou =>
      'Explora eventos en vivo a tu alrededor en tiempo real';

  @override
  String get exploreSearchRadius => 'Radio de búsqueda';

  @override
  String get exploreFindEventsNearYou => 'Encuentra eventos cerca de ti';

  @override
  String get exploreMusicGenre => 'Género musical';

  @override
  String get exploreFilterByGenre => 'Filtra por tus géneros favoritos';

  @override
  String get exploreGenreAll => 'Todos';

  @override
  String get friendsReceivedRequests => 'Solicitudes recibidas';

  @override
  String get friendsAcceptOrReject => 'Aceptar o rechazar nuevas conexiones';

  @override
  String get friendsWantsToConnect => 'Quiere conectarse contigo';

  @override
  String socialMatchListenBoth(String artists) {
    return 'Ambos escuchan $artists';
  }

  @override
  String socialMatchCityEvents(String city, String count) {
    return '$city • $count eventos en común';
  }

  @override
  String get myProfileConnectSpotify => 'Conectar Spotify';

  @override
  String get myProfileOverview => 'Visión general';

  @override
  String get myProfileOverviewSubtitle =>
      'Acceso rápido a las áreas del perfil';

  @override
  String get myProfileSettings => 'Ajustes';

  @override
  String get myProfileMusicStats => 'Estadísticas musicales';

  @override
  String get myProfileMusicStatsSubtitle =>
      'Artistas principales, géneros y mapa de calor de escucha';

  @override
  String get myProfileMyEvents => 'Mis eventos';

  @override
  String myProfileMyEventsSubtitle(String count) {
    return '$count eventos guardados, próximos y pasados';
  }

  @override
  String get myProfileSettingsSubtitle =>
      'Privacidad, notificaciones, cuenta y cierre de sesión';

  @override
  String get myEventsTitle => 'Mis eventos';

  @override
  String get myEventsGoing => 'Asistiré';

  @override
  String get myEventsGoingSubtitle => 'Eventos confirmados o próximos';

  @override
  String get myEventsGoingEmpty =>
      'Aún no has confirmado tu asistencia a ningún evento.\\n¡Explora y encuentra tus próximos conciertos!';

  @override
  String get myEventsSaved => 'Guardados';

  @override
  String get myEventsSavedSubtitle => 'Para tener en cuenta';

  @override
  String get myEventsSavedEmpty =>
      'Ningún evento guardado.\\nGuarda los eventos que te interesan para no perderlos.';

  @override
  String get chatEmptyTitle => 'Sin mensajes';

  @override
  String get chatEmptyMessage => '¡Comienza la conversación!';

  @override
  String get chatInputHint => 'Escribe un mensaje...';

  @override
  String get socialMatchScanningTitle => 'ANÁLISIS DE VIBRA';

  @override
  String get socialMatchScanningSubtitle =>
      'Buscando personas con gustos musicales similares cerca...';

  @override
  String get socialMatchEmptyTitle => 'Sin afinidades cercanas';

  @override
  String get socialMatchEmptyMessage =>
      '¡Tus vibras musicales son únicas! No hay personas con gustos similares cerca en este momento...';

  @override
  String get socialMatchEmptyAction => 'Descubrir eventos cercanos';

  @override
  String get socialMatchEmptySecondary => 'Buscar de nuevo';

  @override
  String get musicStatsTitle => 'Estadísticas Musicales';

  @override
  String musicStatsSyncError(String error) {
    return 'Error de sincronización: $error';
  }

  @override
  String get musicStatsTopArtists => 'Artistas principales';

  @override
  String get musicStatsTopArtistsSub =>
      'Puntuación basada en preferencias de Spotify';

  @override
  String get musicStatsHeatmap => 'Mapa de calor de escucha';

  @override
  String get musicStatsHeatmapSub =>
      'Distribución semanal de tus reproducciones';

  @override
  String get liveScreenTitle => 'Live Vibra';

  @override
  String get liveScreenSendFailed =>
      'Fallo al enviar. Comprueba la sesión y tu asistencia.';

  @override
  String get liveScreenActivateMode => 'Activar Modo Live';

  @override
  String get liveScreenPresentNowTitle => 'Presentes ahora';

  @override
  String get liveScreenPresentNowSub =>
      'Asistentes con alta compatibilidad musical';

  @override
  String get liveScreenChatTitle => 'Chat del Evento';

  @override
  String get liveScreenChatSub =>
      'El chat en tiempo real se cierra automáticamente en 24h';

  @override
  String get eventDetailNotAvailableTitle => 'Evento no disponible';

  @override
  String get eventDetailNotAvailableMsg =>
      'Este evento ya no está disponible o no cargó.';

  @override
  String get eventDetailMapTitle => 'Mapa del Lugar';

  @override
  String get eventDetailMapSub => 'Ubicación del evento';

  @override
  String get eventDetailAttendeesTitle => 'Asistentes';

  @override
  String get eventDetailAttendeesSub =>
      'Usuarios con compatibilidad musical y asistencia confirmada';

  @override
  String get spotifyAuthStep1Title => '1. Autorización OAuth';

  @override
  String get spotifyAuthStep1Sub =>
      'Inicio de sesión seguro en el sitio oficial de Spotify';

  @override
  String get spotifyAuthStep2Title => '2. Intercambio de Credenciales';

  @override
  String get spotifyAuthStep2Sub =>
      'Generación de claves seguras y encriptación de token';

  @override
  String get spotifyAuthStep3Title => '3. Sincronización de Gustos';

  @override
  String get spotifyAuthStep3Sub =>
      'Análisis de artistas principales, pistas y playlists';

  @override
  String get spotifyAuthCancelled =>
      'Conexión cancelada. Debes autorizar Vibra para recomendaciones personalizadas.';

  @override
  String spotifyAuthError(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get legalPrivacyPolicyTitle => 'Política de Privacidad';

  @override
  String get legalPrivacySec1 => 'Qué datos recopila Vibra';

  @override
  String get legalPrivacySec2 => 'Por qué Vibra lo usa';

  @override
  String get legalPrivacySec3 => 'Tus controles';

  @override
  String get legalPrivacySec4 => 'Contacto de privacidad';

  @override
  String get legalTermsTitle => 'Términos de Servicio';

  @override
  String get legalTermsSec1 => 'Uso de Vibra';

  @override
  String get legalTermsSec2 => 'Servicios de terceros';

  @override
  String get legalTermsSec3 => 'Contenido y comportamiento';

  @override
  String get legalTermsSec4 => 'Contacto legal';

  @override
  String get legalSupportTitle => 'Soporte';

  @override
  String get legalSupportSec1 => 'Email de soporte';

  @override
  String get legalSupportSec2 => 'Problemas cubiertos';

  @override
  String get legalSupportSec3 => 'Qué revisar primero';

  @override
  String get legalAboutTitle => 'Acerca de Vibra';

  @override
  String get legalAboutSec1 => 'Versión';

  @override
  String get legalAboutSec2 => 'Identificadores de plataforma';

  @override
  String get legalAboutSec3 => 'Qué hace Vibra';

  @override
  String get legalAboutSec4 => 'Soporte';

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
  String get spotifyAuthCancelledTitle => 'Autenticación Fallida';

  @override
  String get errorTitle => 'Error del Sistema';

  @override
  String get legalPrivacyBody1 =>
      'Datos de cuenta, perfil musical, asistencia a eventos, mensajes, actividad en chat en vivo, ubicación si está autorizada y tokens push.';

  @override
  String get legalPrivacyBody2 =>
      'Para autenticar usuarios, generar recomendaciones, habilitar funciones sociales, enviar notificaciones y mejorar la fiabilidad.';

  @override
  String get legalPrivacyBody3 =>
      'Puedes revocar permisos, desconectar servicios, solicitar eliminación y gestionar visibilidad y preferencias de privacidad desde los ajustes de cuenta.';

  @override
  String legalPrivacyBody4(String email) {
    return 'Solicitudes de privacidad y datos personales: $email';
  }

  @override
  String get legalTermsBody1 =>
      'Al usar Vibra, los usuarios aceptan usar la app legalmente, mantener datos precisos y evitar comportamiento abusivo.';

  @override
  String get legalTermsBody2 =>
      'Spotify, Supabase, Firebase y proveedores de eventos pueden usarse para ofrecer funciones principales. Sus términos y políticas de privacidad también se aplican.';

  @override
  String get legalTermsBody3 =>
      'Los usuarios son responsables del contenido publicado y mensajes enviados. Vibra puede suspender o eliminar cuentas que violen las reglas.';

  @override
  String legalTermsBody4(String email) {
    return 'Solicitudes legales y comunicaciones formales: $email';
  }

  @override
  String legalSupportBody1(String email) {
    return '$email';
  }

  @override
  String get legalSupportBody2 =>
      'Problemas de inicio, conexión Spotify, descubrimiento de eventos, notificaciones, chat, privacidad y eliminación de cuenta.';

  @override
  String get legalSupportBody3 =>
      'Permisos, estado de conexión a Spotify, configuración de Firebase y presencia de un usuario autenticado.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Paquete Android: $android\nBundle iOS: $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra ayuda a conectar Spotify, descubrir eventos en vivo, ver detalles, conocer gente compatible y unirse a chats en vivo.';

  @override
  String legalAboutBody4(String email) {
    return '$email';
  }

  @override
  String get homeGreetingMorning => 'Buenos días 👋';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes 👋';

  @override
  String get homeGreetingEvening => 'Buenas noches 🌙';

  @override
  String get eventCardTBA => 'Por definir';

  @override
  String get eventCardCity => 'Ciudad';

  @override
  String get legalPrivacySubtitle =>
      'Un resumen de la información de privacidad disponible en la app, incluyendo categorías de datos procesados y propósitos de uso.';

  @override
  String get legalTermsSubtitle =>
      'Un resumen de las reglas, responsabilidades y términos de servicio aplicables al uso de Vibra.';

  @override
  String get legalSupportSubtitle =>
      'Información de soporte para acceso a la cuenta, notificaciones, conexión a Spotify y funciones en vivo.';

  @override
  String get legalAboutSubtitle =>
      'Vibra combina gustos musicales, descubrimiento de eventos e interacción social en torno a experiencias en vivo.';

  @override
  String get exploreShowAllEvents => 'Mostrar todos los eventos';

  @override
  String get musicStatsSyncSpotify => 'Sincronizar Spotify';

  @override
  String get liveModeDisabled => 'El modo Live está desactivado';

  @override
  String get authCreateAccount => 'Crear una Cuenta';

  @override
  String get authLoginWithEmail => 'Iniciar sesión con Email';

  @override
  String get authUsername => 'Nombre de usuario';

  @override
  String get authUsernameHint => 'Introduce un nombre de usuario';

  @override
  String get authEmail => 'Dirección de Email';

  @override
  String get authEmailHint => 'Introduce tu email';

  @override
  String get authEmailInvalid => 'Introduce un email válido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHint => 'Introduce tu contraseña';

  @override
  String get authPasswordShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authAlreadyHaveAccount => '¿Ya tienes una cuenta? Iniciar sesión';

  @override
  String get authDontHaveAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get authGenericError => 'Ha ocurrido un error';

  @override
  String get eventCardLocation => 'Ubicación';

  @override
  String get matchScore => 'PUNTUACIÓN DE MATCH';

  @override
  String get userGeneric => 'Usuario';

  @override
  String get spotifyConnectTitle => 'Conectar Spotify';

  @override
  String get spotifyConnectSubtitle =>
      'Conecta tu cuenta para sincronizar tus artistas favoritos y desbloquear recomendaciones personalizadas para conciertos.';

  @override
  String get spotifyConnectOnboarding => 'Flujo de Onboarding';

  @override
  String get spotifyConnectPrivacyDesc =>
      'Tus datos están protegidos por encriptación AES-GCM en el servidor.';

  @override
  String get spotifyConnectContinue => 'Continuar y Explorar';

  @override
  String get spotifyConnectRetry => 'Reintentar Conexión';

  @override
  String get spotifyConnectAction => 'Conectar mi Spotify';

  @override
  String get spotifyConnectSkip => 'Saltar por ahora';

  @override
  String get homeSpotifySyncTitle =>
      'Desbloquea Recomendaciones Personalizadas';

  @override
  String get homeSpotifySyncSub => 'Sincroniza tus escuchas musicales';

  @override
  String get homeSpotifySyncDesc =>
      'Conecta Spotify para recibir recomendaciones de eventos y encontrar personas con tus mismos gustos.';

  @override
  String get homeSpotifySyncAction => 'CONECTAR SPOTIFY';
}
