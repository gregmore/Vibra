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
      'Descubre conciertos y personas con quienes disfrutarlos.';

  @override
  String get loginConsent =>
      'Puedes leer los términos y la información de privacidad antes de continuar. Gestiona tus preferencias opcionales en los ajustes.';

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
      'Para recibir avisos, inicia sesión y activa las notificaciones de Vibra en los ajustes del dispositivo.';

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
      'No se pudo eliminar tu cuenta. Inténtalo de nuevo o contacta con soporte.';

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
      'Explora la comunidad para encontrar personas y enviar solicitudes de amistad.';

  @override
  String get friendsSentRequests => 'Solicitudes enviadas';

  @override
  String get friendsWaitingForReply => 'Esperando respuesta';

  @override
  String get friendsPendingApproval => 'Pendiente de aprobación';

  @override
  String get socialMatchNewAffinity => 'NUEVA AFINIDAD';

  @override
  String get socialMatchScore => 'AFINIDAD MUSICAL';

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
  String exploreSearchRadius(int radius) {
    return 'RADIO DE BÚSQUEDA: $radius KM';
  }

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
  String get myEventsUpcoming => 'Próximos';

  @override
  String get myEventsPast => 'Pasados';

  @override
  String get myEventsPastSubtitle => 'Tu historial de conciertos';

  @override
  String get myEventsPastEmpty => 'Aún no tienes eventos pasados.';

  @override
  String get myEventsSearchHint => 'Busca eventos, artistas o lugares';

  @override
  String get myEventsSearchEmpty => 'Ningún evento coincide con tu búsqueda.';

  @override
  String get myEventsClearSearch => 'Borrar búsqueda';

  @override
  String get myEventsExplore => 'Explorar eventos';

  @override
  String get inboxUnread => 'Sin leer';

  @override
  String get inboxNoResults => 'No se encontraron conversaciones.';

  @override
  String get inboxNoResultsBody =>
      'Prueba otro nombre o elimina los filtros para ver todos los mensajes.';

  @override
  String get inboxClearFilters => 'Quitar filtros';

  @override
  String get homeFeedError => 'No se pudieron cargar los eventos.';

  @override
  String get homeFeedErrorBody =>
      'Inténtalo de nuevo en un momento. Puedes seguir explorando el mapa.';

  @override
  String get homeFeedEmpty => 'Hay espacio para una nueva noche.';

  @override
  String get homeFeedEmptyBody =>
      'Explora el mapa para encontrar tu próximo concierto.';

  @override
  String get socialSearchHint => 'Busca personas o artistas';

  @override
  String get socialSearchEmpty => 'No se encontraron personas.';

  @override
  String get socialSearchEmptyBody => 'Prueba otro nombre o artista.';

  @override
  String get socialDiscoverEmpty => 'Las nuevas conexiones empiezan aquí.';

  @override
  String get socialDiscoverEmptyBody =>
      'Completa tu perfil y conecta Spotify para encontrar personas con gustos similares.';

  @override
  String get chatSendMessage => 'Enviar mensaje';

  @override
  String get chatLoadError => 'No se pudo cargar la conversación.';

  @override
  String get chatDraftRecovered =>
      'El mensaje no se envió. El texto se ha recuperado en el campo de escritura.';

  @override
  String get eventLocationUnknown =>
      'La ubicación exacta aún no está disponible.';

  @override
  String get eventDirections => 'Cómo llegar';

  @override
  String get eventDirectionsError => 'No se pudieron abrir las indicaciones.';

  @override
  String get inboxDeleteTitle => '¿Eliminar la conversación?';

  @override
  String get inboxDeleteBody =>
      'La conversación se quitará de tu bandeja. Los mensajes de la otra persona no se eliminarán.';

  @override
  String get inboxDeleteAction => 'Eliminar conversación';

  @override
  String get inboxDeleteSuccess => 'Conversación eliminada.';

  @override
  String get inboxDeleteError =>
      'No se eliminó la conversación. Inténtalo de nuevo.';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get eventCopyDetails => 'Copiar los detalles del evento';

  @override
  String get eventCopyError => 'No se pudieron copiar los detalles.';

  @override
  String get eventCancelled => 'Evento cancelado';

  @override
  String get eventTicketsOffsale => 'Entradas no disponibles para la venta';

  @override
  String get socialMatchSendFailed =>
      'No se envió la Vibra. Inténtalo de nuevo: el perfil sigue disponible.';

  @override
  String get myEventsTitle => 'Mis eventos';

  @override
  String get myEventsGoing => 'Asistiré';

  @override
  String get myEventsGoingSubtitle => 'Eventos confirmados o próximos';

  @override
  String get myEventsGoingEmpty =>
      'Aún no has confirmado tu asistencia a ningún evento.\n¡Explora y encuentra tus próximos conciertos!';

  @override
  String get myEventsSaved => 'Guardados';

  @override
  String get myEventsSavedSubtitle => 'Para tener en cuenta';

  @override
  String get myEventsSavedEmpty =>
      'Ningún evento guardado.\nGuarda los eventos que te interesan para no perderlos.';

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
      'Comprueba la conexión, los permisos del dispositivo y el inicio de sesión. Si persiste, informa del problema desde los ajustes.';

  @override
  String legalAboutBody1(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String legalAboutBody2(String android, String ios) {
    return 'Paquete Android: $android\nIdentificador iOS: $ios';
  }

  @override
  String get legalAboutBody3 =>
      'Vibra te ayuda a descubrir eventos en vivo, explorar el mapa, guardar conciertos, conocer personas y unirte a chats. Las funciones de Spotify solo están disponibles cuando el servicio está habilitado.';

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
      'Eventos en vivo, mapa y comunidad para compartir nuevas experiencias.';

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
  String get matchScore => 'AFINIDAD MUSICAL';

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

  @override
  String get loginBackToWelcome => 'Volver a la pantalla de bienvenida';

  @override
  String get authOr => 'o';

  @override
  String get authEmailLoginSubtitle =>
      'Introduce tus credenciales para iniciar sesión y explorar conciertos.';

  @override
  String get authEmailRegisterSubtitle =>
      'Introduce tus credenciales para registrarte y empezar a disfrutar de los conciertos en directo.';

  @override
  String get authAgeConfirmation => 'Confirmo que tengo al menos 18 años.';

  @override
  String get authAgeExplanation =>
      'Vibra facilita encuentros entre personas y no está destinada a menores.';

  @override
  String get authAgeRequired =>
      'Debes confirmar que tienes al menos 18 años para crear una cuenta.';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get spotifyUnavailableTitle => 'Spotify en pausa';

  @override
  String get spotifyUnavailableBody =>
      'Spotify y la afinidad musical están temporalmente desactivados. Los eventos, amigos y chats siguen disponibles.';

  @override
  String get launchExploreTitle => 'Encuentra tu próximo concierto';

  @override
  String get launchExploreBody =>
      'Busca artistas, explora el mapa y guarda eventos cercanos.';

  @override
  String get launchCommunityTitle => 'Vive la comunidad';

  @override
  String get launchCommunityBody =>
      'Encuentra personas, añade amigos y organiza conciertos en tus chats.';

  @override
  String get launchSavedTitle => 'Tu agenda de conciertos';

  @override
  String get launchSavedBody =>
      'Guarda conciertos y encuentra los que quieres visitar.';

  @override
  String get launchCommunitySubtitle => 'Busca personas por nombre o usuario';

  @override
  String get launchCommunityEmptyTitle => 'No se encontraron personas';

  @override
  String get launchCommunityEmptyBody =>
      'Prueba otro nombre o vuelve más tarde.';

  @override
  String get launchCommunityLoadError =>
      'No se pudieron cargar las personas. Inténtalo de nuevo.';

  @override
  String get commonOK => 'Aceptar';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonAll => 'Todos';

  @override
  String get commonConnect => 'Conectar';

  @override
  String get commonActive => 'Activo';

  @override
  String get commonNotNow => 'Ahora no';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get commonTryLater => 'Inténtalo más tarde.';

  @override
  String get commonConnectionError => 'Error de conexión';

  @override
  String commonLoadingLabel(String label) {
    return '$label, cargando';
  }

  @override
  String commonSelectedLabel(String label) {
    return '$label, seleccionado';
  }

  @override
  String commonNotSelectedLabel(String label) {
    return '$label, no seleccionado';
  }

  @override
  String get commonOnline => 'En línea';

  @override
  String get commonAvatar => 'Avatar';

  @override
  String commonPercentLabel(int percentage, String label) {
    return '$percentage por ciento $label';
  }

  @override
  String commonAvatarAffinity(String name, int percentage) {
    return '$name, afinidad del $percentage por ciento';
  }

  @override
  String get commonRegistrationComplete => 'Registro completado';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileBack => 'Volver al perfil';

  @override
  String get profilePersonalSpace => 'ESPACIO PERSONAL';

  @override
  String get profileSpotifyConnected => 'Spotify conectado';

  @override
  String get profileFollowers => 'Seguidores';

  @override
  String get profileFollowing => 'Siguiendo';

  @override
  String get profileOpenMusicStats => 'Abrir estadísticas musicales';

  @override
  String get profileYourVibra => 'TU VIBRA';

  @override
  String get profileInRotation => 'En rotación';

  @override
  String get profileSyncMusicBody =>
      'Sincroniza Spotify para ver tu perfil musical.';

  @override
  String get profileShapeTitle => 'Dale forma a tu Vibra';

  @override
  String get profileShapeBody =>
      'Conecta Spotify para mostrar tu identidad musical.';

  @override
  String get profileUsernameEmpty =>
      'El nombre de usuario no puede estar vacío';

  @override
  String get profileUsernameShort => 'Al menos 3 caracteres';

  @override
  String get profileUsernameCharacters => 'Usa solo letras, números, _ o .';

  @override
  String get profileUsernameCharactersOnboarding =>
      'Usa solo letras, números y guiones bajos';

  @override
  String get profileUsernameTaken => 'Nombre de usuario ya utilizado';

  @override
  String get profileUsernameTakenRetry =>
      'Este nombre de usuario ya está ocupado. Elige otro.';

  @override
  String get profilePhotoPermission =>
      'Permite el acceso a las fotos en los ajustes del dispositivo e inténtalo de nuevo.';

  @override
  String get profilePhotoPickError =>
      'No se pudo seleccionar la foto. Inténtalo de nuevo.';

  @override
  String get profilePhotoTitle => 'Foto de perfil';

  @override
  String get profilePhotoGallery => 'Elegir de la galería';

  @override
  String get profilePhotoGalleryBody => 'Selecciona una foto del dispositivo';

  @override
  String get profilePhotoCamera => 'Hacer una foto';

  @override
  String get profilePhotoCameraBody =>
      'Usa la cámara para hacer una nueva foto';

  @override
  String get profilePhotoRemove => 'Eliminar foto';

  @override
  String get profilePhotoRestore => 'Restaurar el avatar predeterminado';

  @override
  String get profileSaved => '¡Perfil actualizado!';

  @override
  String get profileSaveError =>
      'No se pudo guardar el perfil. Inténtalo de nuevo en unos momentos.';

  @override
  String get profilePhotoChange => 'Cambiar foto de perfil';

  @override
  String get profileUsernameExample => 'p. ej. musica_fan';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileNameHint => 'Tu nombre o apodo';

  @override
  String get profileNameEmpty => 'El nombre no puede estar vacío';

  @override
  String get profileDescription => 'Descripción';

  @override
  String get profileDescriptionHint => 'Cuéntanos algo sobre ti…';

  @override
  String get profileMusicStreaming => 'Música y streaming';

  @override
  String get profileAccountConnected => 'Cuenta conectada';

  @override
  String get profileConnectSuggestions =>
      'Conecta tu cuenta para mejorar las sugerencias';

  @override
  String get profileSaveChanges => 'Guardar cambios';

  @override
  String get homeYourSoundToday => 'TU SONIDO, HOY';

  @override
  String get homeSpotifySynced =>
      'Spotify sincronizado · las sugerencias aprenden de ti';

  @override
  String get homeSpotifyPersonalize =>
      'Conecta Spotify para personalizar las sugerencias';

  @override
  String get homeCompleteProfile => 'Completa tu perfil';

  @override
  String get homeShapeVibra => 'Dale tu toque a Vibra';

  @override
  String get homeNextEvent => 'EL PRÓXIMO';

  @override
  String get homeNearbyEyebrow => 'CERCA DE TI';

  @override
  String get homeTrendingEyebrow => 'LO QUE SE MUEVE';

  @override
  String get settingsPrivateMessages => 'Mensajes y solicitudes privados';

  @override
  String get settingsPersonalizedUpdates =>
      'Actualizaciones y recordatorios personalizados';

  @override
  String get settingsMusicWeek => 'Tu semana musical';

  @override
  String get settingsMusicWeekBody =>
      'Eventos y afinidades seleccionados para ti';

  @override
  String get settingsWeekly => 'Semanal';

  @override
  String get settingsMonthly => 'Mensual';

  @override
  String get settingsNever => 'Nunca';

  @override
  String get settingsPrivacyData => 'Privacidad y datos personales';

  @override
  String get settingsPrivacyDataBody =>
      'Consentimiento, exportación y eliminación de datos';

  @override
  String get settingsHelpCenter => 'Centro de ayuda';

  @override
  String get settingsHelpCenterBody =>
      'Ayuda con cuentas, eventos, chat y Spotify';

  @override
  String get settingsReportProblem => 'Informar de un problema';

  @override
  String get settingsReportProblemBody =>
      'Envía datos técnicos anonimizados y una captura opcional';

  @override
  String get privacySaveError =>
      'No se pudo guardar la preferencia. Inténtalo de nuevo.';

  @override
  String get privacyExportTitle => 'Exportación de tus datos';

  @override
  String get privacySaveJSON => 'Guardar JSON';

  @override
  String get privacyCopyJSON => 'Copiar JSON';

  @override
  String get privacyCopiedJSON => 'JSON copiado al portapapeles.';

  @override
  String get privacyExportError =>
      'La exportación no está disponible. Inténtalo más tarde.';

  @override
  String privacyExportSaved(String path) {
    return 'Exportación guardada en $path';
  }

  @override
  String get privacyIntro =>
      'Elige por separado cada uso opcional de tus datos. Puedes cambiar de opinión en cualquier momento.';

  @override
  String get privacyPreciseLocation => 'Ubicación precisa';

  @override
  String get privacyPreciseLocationBody =>
      'Para eventos cercanos y funciones Live. Se conserva un máximo de 30 días.';

  @override
  String get privacySpotifyMatching => 'Spotify para afinidad musical';

  @override
  String get privacySpotifyMatchingBody =>
      'Usa artistas, géneros y escuchas sincronizados para sugerencias y afinidades.';

  @override
  String get privacyServiceNotifications => 'Notificaciones del servicio';

  @override
  String get privacyServiceNotificationsBody =>
      'Afinidades, mensajes y eventos guardados.';

  @override
  String get privacyMarketing => 'Comunicaciones de marketing';

  @override
  String get privacyMarketingBody =>
      'Siempre opcionales; puedes usar la app sin ellas.';

  @override
  String get privacyExportAction => 'Exportar mis datos';

  @override
  String get privacyExportBody =>
      'Genera una copia JSON legible de tu perfil, chats, eventos e interacciones, incluidos los datos previos de Spotify si existen.';

  @override
  String get privacyDeletionBody =>
      'Al eliminar tu cuenta se borran sus datos. Los mensajes enviados se vuelven anónimos y se elimina su contenido y archivos. Las copias de seguridad siguen el plazo indicado en la política de privacidad.';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get appearanceBody =>
      'Elige el tema de la app o sigue el del dispositivo.';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String get appearanceDarkBody => 'Reduce el brillo con poca luz';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceLightBody => 'Superficies luminosas y sombras suaves';

  @override
  String get appearanceSystem => 'Automático (sistema)';

  @override
  String get appearanceSystemBody =>
      'Se actualiza cuando cambian los ajustes del dispositivo';

  @override
  String get onboardingBack => 'Volver al paso anterior';

  @override
  String get onboardingStart => 'Empecemos';

  @override
  String get onboardingProfileTitle => 'Tu perfil';

  @override
  String get onboardingProfileBody => 'Cómo te verán los demás';

  @override
  String get onboardingSkipToHome => 'Omitir el resto e ir al inicio';

  @override
  String get onboardingPhotoUploading => 'Subiendo la foto de perfil';

  @override
  String get onboardingPhotoSelect => 'Elegir o cambiar la foto de perfil';

  @override
  String get onboardingUsernameExample => 'p. ej. vibra_user';

  @override
  String get onboardingRequired => 'OBLIGATORIO';

  @override
  String get onboardingSpotifyBody =>
      'Encuentra eventos según tus escuchas y descubre tu afinidad musical con otras personas.';

  @override
  String get onboardingSpotifyCancelled =>
      'Conexión cancelada. Inténtalo de nuevo o sáltalo por ahora.';

  @override
  String get onboardingSpotifyError =>
      'No se pudo conectar. Inténtalo más tarde.';

  @override
  String get onboardingLocationTitle => 'Eventos cerca de ti';

  @override
  String get onboardingLocationBody =>
      'Activa la ubicación para descubrir conciertos y locales en tu zona.';

  @override
  String get onboardingLocationDenied =>
      'Permiso denegado permanentemente. Puedes activarlo después en los ajustes del dispositivo.';

  @override
  String get onboardingAllowLocation => 'Permitir ubicación';

  @override
  String get onboardingNotificationsTitle => 'Mantente al día';

  @override
  String get onboardingNotificationsBody =>
      'Recibe avisos de eventos guardados, solicitudes de amistad y mensajes.';

  @override
  String get onboardingNotificationsDenied =>
      'Notificaciones denegadas. Puedes activarlas en los ajustes del dispositivo.';

  @override
  String get onboardingAllowNotifications => 'Activar notificaciones';

  @override
  String get liveAttendanceError =>
      'No se pudo confirmar la asistencia. Inténtalo de nuevo.';

  @override
  String get liveEventsLoadError => 'No se pudieron cargar los eventos Live.';

  @override
  String get liveLocationHelp =>
      'El chat Live está disponible a menos de 500 m del evento, durante las 24 horas antes y después del concierto. Activa la ubicación en los ajustes de privacidad.';

  @override
  String get liveUnavailableHere =>
      'El chat de este evento no está disponible en tu ubicación o en este momento.';

  @override
  String get liveRefreshLocation => 'Actualizar ubicación';

  @override
  String get liveEventTitle => 'Evento Live';

  @override
  String get liveConnectionInterrupted => 'Conexión al chat Live interrumpida.';

  @override
  String get liveEmpty => 'No hay mensajes. ¡Inicia la conversación!';

  @override
  String get liveRetryAttendance => 'Volver a comprobar la asistencia';

  @override
  String get liveConfirmingAttendance => 'Confirmando asistencia…';

  @override
  String get liveJoinToChat => 'Únete al evento para escribir en el chat';

  @override
  String get liveInputHint => 'Escribe en el chat Live…';

  @override
  String get liveSendMessage => 'Enviar mensaje Live';

  @override
  String get musicReconnect => 'Volver a conectar';

  @override
  String get musicReconnectBody =>
      'Vuelve a conectar Spotify para actualizar las estadísticas musicales.';

  @override
  String get musicStatsUpdated => 'Estadísticas musicales actualizadas.';

  @override
  String get musicStatsRefreshing => 'Actualizando estadísticas musicales';

  @override
  String get musicStatsNoArtists =>
      'No hay artistas disponibles tras la última sincronización.';

  @override
  String get musicStatsEmptyTitle => 'Dale sonido a tu perfil.';

  @override
  String get musicStatsEmptyBody =>
      'Conecta Spotify para ver los artistas y ritmos que te definen.';

  @override
  String get musicStatsYourSound => 'TU SONIDO';

  @override
  String get musicStatsHeroTitle => 'Escuchas que dejan huella.';

  @override
  String get musicStatsArtists => 'Artistas';

  @override
  String get musicStatsRhythm => 'Ritmo';

  @override
  String get spotifyBackToLogin => 'Volver al inicio de sesión';

  @override
  String get spotifyConsentBody =>
      'Al conectar Spotify autorizas a Vibra a leer tu perfil y tus artistas, canciones y géneros principales. Los usamos para sugerir eventos y afinidades musicales; puedes desconectar Spotify y borrar estos datos en los ajustes.';

  @override
  String get eventBackToEvents => 'Volver a los eventos';

  @override
  String get eventPrice => 'Precio';

  @override
  String get eventVenueTBA => 'Lugar por confirmar';

  @override
  String eventOpenSemantics(String name, String date, String place) {
    return 'Abrir evento $name, $date, $place';
  }

  @override
  String eventAffinitySemantics(int percentage) {
    return 'Afinidad del $percentage por ciento';
  }

  @override
  String eventForYouScore(int percentage) {
    return '$percentage% PARA TI';
  }

  @override
  String eventCommonSavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos compartidos o guardados',
      one: '$count evento compartido o guardado',
    );
    return '$_temp0';
  }

  @override
  String get supportReportTitle => 'Informar de un problema';

  @override
  String get supportReportIntro =>
      'Describe lo que no funciona. Incluiremos la versión de la app, el sistema operativo y algunos datos técnicos sin información sensible.';

  @override
  String get supportDescriptionLabel => 'Descripción del problema';

  @override
  String get supportDescriptionHint =>
      'Indica la pantalla, los pasos y lo que esperabas.';

  @override
  String get supportAddScreenshot => 'Añadir captura';

  @override
  String get supportScreenshotAttached => 'Captura adjunta';

  @override
  String get supportRemoveScreenshot => 'Eliminar captura';

  @override
  String get supportScreenshotPrivacy =>
      'Comprueba que la captura no muestre contraseñas, mensajes privados u otros datos sensibles.';

  @override
  String get supportSending => 'Enviando…';

  @override
  String get supportSendReport => 'Enviar informe';

  @override
  String get supportDescriptionTooShort =>
      'Describe el problema con al menos 8 caracteres.';

  @override
  String get supportDescriptionTooLong =>
      'La descripción puede contener un máximo de 4000 caracteres.';

  @override
  String get supportReportSentTitle => 'Informe enviado';

  @override
  String get supportReportSentBody =>
      'Hemos recibido tu informe. El soporte responde en 48 horas laborables.';

  @override
  String supportReportSendFailed(String email) {
    return 'No se pudo enviar el informe. Inténtalo de nuevo o escribe a $email.';
  }

  @override
  String get supportReportAuthRequired =>
      'Vuelve a iniciar sesión para enviar el informe.';

  @override
  String get supportReportRateLimited =>
      'Has enviado demasiados informes. Espera un minuto e inténtalo de nuevo.';

  @override
  String get supportScreenshotTooLarge =>
      'La captura debe ocupar menos de 5 MB.';

  @override
  String get supportScreenshotUnsupported =>
      'Elige una captura en formato JPG o PNG.';

  @override
  String get supportScreenshotPickFailed =>
      'No se pudo seleccionar la captura. Inténtalo de nuevo.';

  @override
  String get supportScreenshotPermissionDenied =>
      'Permite el acceso a las fotos en los ajustes del dispositivo para adjuntar una captura.';

  @override
  String supportAlternativeContact(String email) {
    return 'También puedes escribir a $email. Respondemos en 48 horas laborables.';
  }

  @override
  String get supportFeedbackTitle => '¿Qué tal va Vibra?';

  @override
  String get supportFeedbackBody => 'Tu opinión nos ayuda a mejorar.';

  @override
  String get supportFeedbackNegative => 'Mal';

  @override
  String get supportFeedbackNeutral => 'Regular';

  @override
  String get supportFeedbackPositive => '¡Bien!';

  @override
  String get supportFeedbackDescriptionPrefix => 'Comentario:';

  @override
  String get chatSendFriendshipRequired =>
      'Para escribir a esta persona, envía una solicitud de amistad y espera a que la acepte.';

  @override
  String get chatSendFirstContactLimit =>
      'Ya has enviado 3 mensajes. Espera una respuesta antes de enviar más.';

  @override
  String get chatSendUnavailable => 'Esta conversación no está disponible.';

  @override
  String get chatSendRateLimited =>
      'Estás enviando demasiados mensajes. Espera un minuto e inténtalo de nuevo.';

  @override
  String get chatSendSignInRequired =>
      'Vuelve a iniciar sesión para enviar el mensaje.';

  @override
  String get chatRequestFriendship => 'Enviar solicitud de amistad';

  @override
  String get chatFriendshipRequestSent => 'Solicitud de amistad enviada';

  @override
  String get chatFriendshipRequestFailed =>
      'No se pudo enviar la solicitud de amistad. Inténtalo de nuevo.';

  @override
  String get chatMessageTooLong =>
      'El mensaje puede contener un máximo de 2000 caracteres.';

  @override
  String get chatPermissionChecking => 'Comprobando conversación…';

  @override
  String get chatFriendshipRequestPending =>
      'Solicitud de amistad pendiente de aceptación';

  @override
  String get chatAcceptFriendship => 'Aceptar amistad';

  @override
  String get chatFriendshipAccepted =>
      'Amistad aceptada. Ya puedes enviar mensajes.';

  @override
  String get socialReportUser => 'Denunciar usuario';

  @override
  String get socialReportSpam => 'Spam';

  @override
  String get socialReportHarassment => 'Acoso';

  @override
  String get socialReportInappropriate => 'Contenido inapropiado';

  @override
  String get socialReportDetailsHint => 'Detalles adicionales (opcional)';

  @override
  String get socialReportSent => 'Usuario denunciado';

  @override
  String get socialReportFailed =>
      'No se pudo enviar la denuncia. Inténtalo de nuevo.';

  @override
  String get socialReportAction => 'Denunciar';

  @override
  String get socialBlockUser => 'Bloquear usuario';

  @override
  String get socialBlockConfirm =>
      '¿Quieres bloquear a esta persona? Ya no podréis intercambiar mensajes.';

  @override
  String get socialBlockSuccess => 'Usuario bloqueado';

  @override
  String get socialBlockFailed =>
      'No se pudo bloquear a esta persona. Inténtalo de nuevo.';

  @override
  String get socialBlockAction => 'Bloquear';

  @override
  String get chatRequestTitle => 'Solicitud de mensaje';

  @override
  String chatRequestBody(String name) {
    return '$name quiere escribirte. Responde para aceptar la conversación.';
  }

  @override
  String get chatRequestRejected => 'Solicitud rechazada y eliminada';

  @override
  String get chatRequestRejectFailed =>
      'No se pudo eliminar la solicitud. Inténtalo de nuevo.';

  @override
  String get commonReject => 'Rechazar';

  @override
  String get commonReply => 'Responder';

  @override
  String get userProfileView => 'Ver perfil';

  @override
  String get chatConnectionInterrupted => 'Conexión al chat interrumpida.';

  @override
  String get chatMeetupTitle => 'Propuesta de encuentro';

  @override
  String get chatMeetupAccept => 'Me apunto';

  @override
  String get chatMeetupDecline => 'No puedo';

  @override
  String chatMeetupAcceptMessage(String message) {
    return '¡Me apunto! $message';
  }

  @override
  String chatMeetupDeclineMessage(String message) {
    return 'No puedo asistir. $message';
  }

  @override
  String get helpIntro =>
      'Respuestas rápidas y ayuda. Respondemos en 48 horas laborables.';

  @override
  String get helpSearchHint => 'Buscar en preguntas frecuentes';

  @override
  String get helpSearchEmpty =>
      'No se encontraron respuestas. Prueba otra búsqueda.';

  @override
  String get helpNeedMore => '¿Necesitas más ayuda?';

  @override
  String get helpCategoryAll => 'Todas';

  @override
  String get helpCategoryAccount => 'Cuenta';

  @override
  String get helpCategoryChatMatch => 'Chat y afinidad';

  @override
  String get helpCategoryPrivacy => 'Privacidad';

  @override
  String get helpLoginQuestion => 'No puedo iniciar sesión';

  @override
  String get helpLoginAnswer =>
      'Comprueba el correo y la contraseña, y cierra y vuelve a abrir Vibra. Si el problema persiste, usa “Informar de un problema” e indica el método de acceso.';

  @override
  String get helpLogoutQuestion => '¿Cómo cierro sesión?';

  @override
  String get helpLogoutAnswer =>
      'Ve a Perfil > Ajustes > Cerrar sesión. Para terminar todas las sesiones, elige “Cerrar sesión en todos los dispositivos”.';

  @override
  String get helpDeleteQuestion => '¿Cómo elimino mi cuenta?';

  @override
  String get helpDeleteAnswer =>
      'Ve a Perfil > Ajustes > Eliminar cuenta. Al confirmar se eliminan los datos según la política de privacidad.';

  @override
  String get helpEventsQuestion => '¿Por qué no veo eventos cerca de mí?';

  @override
  String get helpEventsAnswer =>
      'Comprueba el acceso a la ubicación y amplía el radio. La disponibilidad depende de las fuentes de eventos de la zona; también puedes buscar una ciudad.';

  @override
  String get helpTicketsQuestion => 'Un evento o enlace de entradas no se abre';

  @override
  String get helpTicketsAnswer =>
      'Los eventos y las entradas proceden de socios externos. Inténtalo más tarde; si persiste, envía un informe indicando el evento.';

  @override
  String get helpAffinityQuestion => '¿Cómo se calcula la afinidad?';

  @override
  String get helpAffinityAnswer =>
      'La puntuación compara artistas y géneros compartidos, con un pequeño extra para gustos menos comunes. Indica afinidad, sin garantizarla.';

  @override
  String get helpBlockQuestion => '¿Cómo bloqueo o denuncio a alguien?';

  @override
  String get helpBlockAnswer =>
      'Abre la conversación y usa el menú para bloquear o denunciar a la persona. El bloqueo impide futuras interacciones; las denuncias se envían al equipo.';

  @override
  String get helpSpotifyConnectQuestion => '¿Cómo conecto Spotify?';

  @override
  String get helpSpotifyConnectAnswer =>
      'Ve a Perfil > Ajustes > Cuenta de Spotify y completa la autorización en Spotify. Volverás automáticamente a Vibra.';

  @override
  String get helpSpotifyDisconnectQuestion => '¿Cómo desconecto Spotify?';

  @override
  String get helpSpotifyDisconnectAnswer =>
      'Ve a Perfil > Ajustes > Cuenta de Spotify y elige “Desconectar”.';

  @override
  String get helpSpotifyErrorQuestion => 'La conexión con Spotify falla';

  @override
  String get helpSpotifyErrorAnswer =>
      'Comprueba la conexión y completa la autorización. No compartas contraseñas ni tokens con soporte: los informes solo incluyen datos técnicos depurados.';

  @override
  String get helpReportDataQuestion => '¿Qué datos envía un informe?';

  @override
  String get helpReportDataAnswer =>
      'Versión de la app, sistema operativo, último endpoint con error y algunos registros técnicos sin datos sensibles. La captura es opcional: comprueba que no contenga información privada.';

  @override
  String get helpPrivacyQuestion =>
      '¿Cómo ejerzo mis derechos sobre los datos?';

  @override
  String helpPrivacyAnswer(String email) {
    return 'Ve a Perfil > Ajustes > Privacidad y datos personales para gestionar consentimientos y exportar datos. Para otras solicitudes escribe a $email.';
  }

  @override
  String get exploreEyebrow => 'EVENTOS A TU ALREDEDOR';

  @override
  String get exploreClearSearch => 'Borrar búsqueda';

  @override
  String exploreEventsVisible(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count EVENTOS A LA VISTA',
      one: '$count EVENTO A LA VISTA',
    );
    return '$_temp0';
  }

  @override
  String get commonReset => 'Restablecer';

  @override
  String get exploreLoadErrorTitle => 'No se pudieron cargar los eventos.';

  @override
  String get exploreLoadErrorBody =>
      'Comprueba la conexión y vuelve a buscar en esta zona.';

  @override
  String get exploreEmptyTitle => 'No se encontraron eventos en esta zona.';

  @override
  String get exploreEmptyBody => 'Amplía el radio o cambia los filtros.';

  @override
  String get exploreZoomIn => 'Acercar mapa';

  @override
  String get exploreZoomOut => 'Alejar mapa';

  @override
  String exploreOpenEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Abrir lista de $count eventos',
      one: 'Abrir lista de $count evento',
    );
    return '$_temp0';
  }

  @override
  String get exploreMoveMapHint => 'Mueve el mapa para buscar eventos';

  @override
  String exploreEventsInArea(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos en esta zona',
      one: '$count evento en esta zona',
    );
    return '$_temp0';
  }

  @override
  String get exploreCloseEvents => 'Cerrar lista de eventos';

  @override
  String get exploreGenreElectronic => 'Electrónica';

  @override
  String get exploreGenreAlternative => 'Alternativa';

  @override
  String get commonLinkOpenError => 'No se pudo abrir el enlace.';

  @override
  String get authConfirmEmail =>
      'Te hemos enviado un correo de confirmación. Revisa tu bandeja antes de iniciar sesión.';

  @override
  String get authEmailNotConfirmed =>
      'Confirma primero tu dirección de correo. Revisa tu bandeja de entrada.';

  @override
  String get authInvalidCredentials =>
      'El correo o la contraseña no son correctos. Compruébalos e inténtalo de nuevo.';

  @override
  String get authProviderUnavailable =>
      'Este método de acceso no está disponible. Usa el correo o inténtalo más tarde.';

  @override
  String get authEmailAlreadyRegistered =>
      'Este correo ya está registrado. Intenta iniciar sesión.';

  @override
  String get authWeakPassword =>
      'Elige una contraseña más segura e inténtalo de nuevo.';

  @override
  String get errorNetwork =>
      'Conexión no disponible. Comprueba la red e inténtalo de nuevo.';

  @override
  String get errorSessionChanged =>
      'La sesión ha cambiado. Vuelve a iniciar sesión e inténtalo de nuevo.';

  @override
  String get errorRateLimited =>
      'Demasiadas solicitudes. Espera un minuto e inténtalo de nuevo.';

  @override
  String get errorActionFailed =>
      'La operación ha fallado. Inténtalo de nuevo en unos momentos.';

  @override
  String get socialAffinity => 'Afinidad';

  @override
  String get socialFollow => 'Seguir';

  @override
  String get socialFollowing => 'Siguiendo';

  @override
  String get socialFollowUpdateError =>
      'No se pudo actualizar el seguimiento. Inténtalo de nuevo.';

  @override
  String get socialMessageAction => 'Enviar mensaje';

  @override
  String get socialFriendRequestSentShort => 'Enviada';

  @override
  String get socialFriendRequestError =>
      'No se pudo enviar la solicitud. Inténtalo de nuevo.';

  @override
  String get socialAddFriend => 'Añadir';

  @override
  String get socialCommonArtists => 'Artistas en común';

  @override
  String get socialUsersLoadError => 'No se pudieron cargar las personas.';

  @override
  String socialFollowersCount(int count) {
    return 'Seguidores ($count)';
  }

  @override
  String socialFollowingCount(int count) {
    return 'Siguiendo ($count)';
  }

  @override
  String get socialNoFollowers => 'Sin seguidores';

  @override
  String get socialNoFollowersBody =>
      'Aquí aparecerán las personas que sigan este perfil.';

  @override
  String get socialNoFollowing => 'No sigues a nadie';

  @override
  String get socialNoFollowingBody =>
      'Aquí aparecerán los perfiles que sigues.';

  @override
  String get friendsRequestUpdateError =>
      'No se pudo actualizar la solicitud. Inténtalo de nuevo.';

  @override
  String get friendsRemoveTitle => 'Eliminar de amigos';

  @override
  String friendsRemoveBody(String name) {
    return '¿Quieres eliminar a $name de tus amigos?';
  }

  @override
  String friendsRemoved(String name) {
    return '$name eliminado de amigos';
  }

  @override
  String get friendsRemoveError =>
      'No se pudo eliminar a este amigo. Inténtalo de nuevo.';

  @override
  String get commonRemove => 'Eliminar';

  @override
  String get friendsConnectionsTitle => 'Amigos y conexiones';

  @override
  String friendsCount(int count) {
    return 'Amigos ($count)';
  }

  @override
  String get friendsReceived => 'Recibidas';

  @override
  String friendsSentCount(int count) {
    return 'Enviadas ($count)';
  }

  @override
  String get friendsSearchHint => 'Buscar entre tus amigos…';

  @override
  String get friendsNoneFound => 'No se encontraron amigos';

  @override
  String get friendsFindBody =>
      'Explora perfiles, envía solicitudes de amistad y comparte eventos.';

  @override
  String get friendsFindPeople => 'Encontrar personas';

  @override
  String get friendsNoReceived => 'No hay solicitudes recibidas';

  @override
  String get friendsNoReceivedBody =>
      'Aquí aparecerán las solicitudes de amistad que recibas.';

  @override
  String get friendsVibraUser => 'Usuario de Vibra';

  @override
  String get friendsNoSent => 'No hay solicitudes enviadas';

  @override
  String get friendsNoSentBody =>
      'Aquí aparecerán las solicitudes enviadas pendientes de respuesta.';

  @override
  String inboxOpenConversation(String name) {
    return 'Abrir conversación con $name';
  }

  @override
  String inboxUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes sin leer',
      one: '$count mensaje sin leer',
    );
    return '$_temp0';
  }

  @override
  String get inboxEyebrow => 'EN CONTACTO';

  @override
  String get inboxMessages => 'Mensajes';

  @override
  String get inboxDirect => 'Directos';

  @override
  String get inboxRequests => 'Solicitudes';

  @override
  String get inboxSearchHint => 'Buscar una conversación';

  @override
  String get inboxClearSearch => 'Borrar búsqueda de conversaciones';

  @override
  String get inboxRefreshError =>
      'No se pudieron actualizar las conversaciones.';

  @override
  String get inboxEmptyTitle => 'Todavía no hay conversaciones.';

  @override
  String get inboxEmptyBody =>
      'Encuentra a alguien con quien compartir un concierto y empieza a hablar.';

  @override
  String get inboxNoRequests => 'No hay solicitudes pendientes.';

  @override
  String get inboxNoRequestsBody =>
      'Aquí aparecerán las nuevas solicitudes de mensaje.';

  @override
  String get socialMatchSend => 'ENVIAR';

  @override
  String get socialMatchPass => 'PASAR';

  @override
  String get socialMatchSharedListening =>
      'Tus escuchas han encontrado algo en común.';

  @override
  String get socialYou => 'Tú';

  @override
  String get socialMatchFrequencyNow => 'misma frecuencia, ahora';

  @override
  String get socialMatchSharedSound => 'ESCUCHAS COMPARTIDAS';

  @override
  String get socialMatchSameArea => 'MISMA ZONA';

  @override
  String get friendsLoadError =>
      'No se pudieron cargar los amigos. Inténtalo de nuevo.';
}
