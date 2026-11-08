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
      'Vibra borrará tu conexión con Spotify, los artistas y géneros sincronizados, el historial de escucha y las afinidades musicales. Las sugerencias de eventos dejarán de estar personalizadas.';

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
  String get socialPeopleSection => 'Personas';

  @override
  String get socialAffinityTitle => 'Encuentra tu afinidad musical';

  @override
  String socialRequestsPreview(String name, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$name y $others personas más quieren conectar',
      one: '$name y 1 persona más quieren conectar',
      zero: '$name quiere conectar contigo',
    );
    return '$_temp0';
  }

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
      'Vibra lee tu perfil de Spotify, tus artistas, canciones y géneros más escuchados de los últimos ~6 meses y las horas de tus reproducciones recientes. Los usamos para estadísticas musicales, sugerencias de eventos y afinidad musical. Tus credenciales de Spotify quedan cifradas en nuestros servidores, nunca en este dispositivo. Puedes desconectar Spotify y borrar estos datos en cualquier momento desde Ajustes.';

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

  @override
  String get matchTierHigh => 'Afinidad alta';

  @override
  String get matchTierMedium => 'Buena afinidad';

  @override
  String get matchTierLow => 'Afinidad baja';

  @override
  String get eventStatusUpcoming => 'Próximo';

  @override
  String get eventStatusToday => 'Hoy';

  @override
  String get eventStatusSoldOut => 'Agotado';

  @override
  String get eventStatusCancelled => 'Cancelado';

  @override
  String get eventStatusPostponed => 'Aplazado';

  @override
  String get eventStatusPast => 'Finalizado';

  @override
  String eventPriceFrom(String price) {
    return 'Desde $price';
  }

  @override
  String get offlineTitle => 'Sin conexión';

  @override
  String get homeSpotifyBannerTitle => 'Conecta tu sonido';

  @override
  String get homeUpNext => 'A CONTINUACIÓN';

  @override
  String get homeSpotifyConnectedTitle => 'Spotify conectado';

  @override
  String get spotifyConsentSharing =>
      'Las personas con la afinidad musical activada solo ven tu puntuación de afinidad y los artistas y géneros que tenéis en común, nunca tu historial de escucha.';

  @override
  String get spotifySyncFailedTitle =>
      'Spotify está conectado, pero tu música aún no se ha cargado.';

  @override
  String get spotifySyncRetry => 'Reintentar sincronización';

  @override
  String get spotifyRevokedBody =>
      'Se retiró el acceso de Vibra desde tu cuenta de Spotify, así que lo desconectamos y borramos los datos sincronizados. Vuelve a conectarlo para recuperar tus estadísticas y afinidades.';

  @override
  String get spotifyRateLimited =>
      'Spotify está ocupado ahora mismo. Inténtalo de nuevo en un minuto.';

  @override
  String get settingsSpotifyDisconnectError =>
      'No se pudo desconectar Spotify. Inténtalo de nuevo.';

  @override
  String get socialConnectSpotifyBody =>
      'Conecta Spotify para conocer gente que escucha lo que te encanta.';

  @override
  String socialAffinityCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas comparten tus gustos',
      one: '1 persona comparte tus gustos',
      zero: 'Aún no hay nuevas afinidades',
    );
    return '$_temp0';
  }

  @override
  String get spotifyAccessNotGranted =>
      'Spotify aún no ha habilitado Vibra para tu cuenta. El resto de Vibra funciona con normalidad; vuelve a intentarlo más tarde.';

  @override
  String get spotifyConnectFailed =>
      'Spotify no pudo completar la conexión. Vuelve a intentarlo en un momento.';

  @override
  String get settingsSectionMusic => 'Música';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionHelp => 'Ayuda';

  @override
  String get settingsSectionLegal => 'Información legal';

  @override
  String get settingsSectionAccount => 'Cuenta';

  @override
  String get settingsDeleteAccountSub =>
      'Elimina definitivamente tu cuenta y tus datos';

  @override
  String get settingsEditProfileSub => 'Nombre, foto, biografía y usuario';

  @override
  String settingsVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get profileStatEvents => 'Eventos';

  @override
  String get profileSpotifyBenefits => 'Estadísticas · Afinidad · Para ti';

  @override
  String get appearanceAuto => 'Automático';

  @override
  String get affinityCategoryExceptional => 'Afinidad musical excepcional';

  @override
  String get affinityCategoryVeryHigh => 'Afinidad muy alta';

  @override
  String get affinityCategoryHigh => 'Afinidad alta';

  @override
  String get affinityCategoryModerate => 'Afinidad moderada';

  @override
  String get affinityCategoryLow => 'Sonidos distintos';

  @override
  String get affinityCategoryVeryLow => 'Nuevos mundos musicales';

  @override
  String affinityHeadline(int percent) {
    return '$percent % de afinidad musical';
  }

  @override
  String get affinitySharedGenres => 'Vuestros géneros en común';

  @override
  String get affinityTheirGenres => 'Sus géneros principales';

  @override
  String get affinityArtistsInCommon => 'Artistas en común';

  @override
  String get affinityWhy => 'Por qué encajáis';

  @override
  String get affinityQuoteExceptional =>
      'Parece que escucháis la música igual.';

  @override
  String get affinityQuoteVeryHigh =>
      'Vuestros gustos musicales tienen muchísimo en común.';

  @override
  String get affinityQuoteHigh =>
      'Vuestros gustos musicales tienen mucho en común.';

  @override
  String get affinityQuoteModerate =>
      'Compartís algunos sonidos y podéis descubrir otros.';

  @override
  String get affinityQuoteDiscovery =>
      'Mundos distintos: una ocasión para descubrir música nueva.';

  @override
  String affinityReasonSharedFamilies(String genres) {
    return 'Los dos escucháis sobre todo $genres.';
  }

  @override
  String affinityReasonSharedSubgenres(String genres) {
    return 'Compartís la pasión por $genres.';
  }

  @override
  String affinityReasonDifferentSubgenres(String genre) {
    return 'Os gusta a los dos $genre, con subgéneros distintos.';
  }

  @override
  String affinityReasonRelatedFamilies(String first, String second) {
    return '$first y $second son sonidos cercanos.';
  }

  @override
  String affinityReasonSharedArtists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compartís $count artistas favoritos.',
      one: 'Compartís 1 artista favorito.',
    );
    return '$_temp0';
  }

  @override
  String get affinityReasonDiscovery =>
      'Gustos distintos: una buena forma de descubrir música.';

  @override
  String get affinityListSeparator => ' y ';

  @override
  String get genreFamilyHipHop => 'Hip-Hop';

  @override
  String get genreFamilyRnb => 'R&B';

  @override
  String get genreFamilyElectronic => 'Electrónica';

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
  String get genreFamilyLatin => 'Latina';

  @override
  String get genreFamilyAfro => 'Afro';

  @override
  String get genreFamilyCountry => 'Country';

  @override
  String get genreFamilyFolk => 'Folk';

  @override
  String get genreFamilyClassical => 'Clásica';

  @override
  String get genreFamilySoundtrack => 'Bandas sonoras';

  @override
  String get genreFamilyGospel => 'Góspel y cristiana';

  @override
  String get genreFamilyWorld => 'Músicas del mundo';

  @override
  String get musicGenresTitle => 'Tus géneros';

  @override
  String get musicGenresSubtitle =>
      'Elige los géneros que te gustan: nos ayudan a encontrar gente con gustos afines, con o sin Spotify.';

  @override
  String get musicGenresSpotifyNote =>
      'Spotify está conectado: estos géneros se suman a los de tus escuchas.';

  @override
  String get musicGenresSearchHint => 'Busca un género';

  @override
  String get musicGenresNoResults => 'Ningún género encontrado';

  @override
  String musicGenresSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count géneros elegidos',
      one: '1 género elegido',
      zero: 'Ningún género elegido',
    );
    return '$_temp0';
  }

  @override
  String get musicGenresYourPicks => 'Tu selección';

  @override
  String get musicGenresLevelLike => 'Me gusta';

  @override
  String get musicGenresLevelMuch => 'Mucho';

  @override
  String get musicGenresLevelLove => 'Me encanta';

  @override
  String get musicGenresIntensityHint =>
      'Toca un género elegido para indicar cuánto te gusta.';

  @override
  String musicGenresRemove(String genre) {
    return 'Quitar $genre';
  }

  @override
  String get musicGenresLimit => 'Puedes elegir hasta 30 géneros.';

  @override
  String get musicGenresMatching => 'Mostrarme a personas con gustos afines';

  @override
  String get musicGenresMatchingBody =>
      'Solo verán la puntuación de afinidad y los géneros y artistas en común.';

  @override
  String get musicGenresSave => 'Guardar';

  @override
  String get musicGenresSaved =>
      'Géneros guardados. Estamos actualizando tus afinidades.';

  @override
  String get musicGenresSaveError =>
      'No se pudieron guardar los géneros. Inténtalo de nuevo.';

  @override
  String get musicGenresLoadError => 'No se pudieron cargar tus géneros.';

  @override
  String get musicGenresEntry => 'Géneros favoritos';

  @override
  String get musicGenresEntrySub => 'Elige tus géneros, incluso sin Spotify';

  @override
  String get socialAffinityPickGenres => 'O elige tus géneros';

  @override
  String get socialAffinityPickGenresBody =>
      'Elige tus géneros favoritos para conocer gente con gustos afines.';

  @override
  String get privacyMusicAffinity => 'Afinidad musical';

  @override
  String get privacyMusicAffinityBody =>
      'Usa tus datos de Spotify y los géneros que eliges para sugerencias y afinidad.';

  @override
  String get musicalDnaTitle => 'ADN musical';

  @override
  String get musicalDnaEyebrow => 'Tu identidad musical';

  @override
  String musicalDnaUserTitle(String name) {
    return 'ADN musical de $name';
  }

  @override
  String get musicalDnaUserEyebrow => 'Identidad musical';

  @override
  String get musicalDnaDistribution => 'Distribución de géneros';

  @override
  String get musicalDnaDistributionSub =>
      'Cómo se reparte tu gusto entre familias de géneros';

  @override
  String musicalDnaArtistsVia(String artists) {
    return 'A través de $artists';
  }

  @override
  String get musicalDnaDiversity => 'Diversidad';

  @override
  String get musicalDnaDiversityFocused => 'Concentrado';

  @override
  String get musicalDnaDiversityBalanced => 'Equilibrado';

  @override
  String get musicalDnaDiversityEclectic => 'Ecléctico';

  @override
  String get musicalDnaDiversityFocusedBody =>
      'Tu identidad vive en pocos sonidos cercanos.';

  @override
  String get musicalDnaDiversityBalancedBody =>
      'Un núcleo claro, con espacio para otros mundos.';

  @override
  String get musicalDnaDiversityEclecticBody =>
      'Tu gusto se mueve libre entre mundos muy distintos.';

  @override
  String musicalDnaDiversityCounts(String families, String subgenres) {
    return '$families familias · $subgenres subgéneros';
  }

  @override
  String get musicalDnaEvolution => 'Evolución';

  @override
  String get musicalDnaEvolutionSub =>
      'Cómo cambia tu ADN a medida que cambia lo que escuchas';

  @override
  String musicalDnaEvolutionEmpty(String date) {
    return 'Seguimiento desde el $date. Aquí verás los cambios a medida que evoluciona lo que escuchas.';
  }

  @override
  String musicalDnaShiftSince(String date) {
    return 'Desde el $date';
  }

  @override
  String get musicalDnaNoShift =>
      'Estable: ninguna familia se movió más de 3 puntos.';

  @override
  String musicalDnaShiftSemantics(String family, String from, String to) {
    return '$family, del $from al $to por ciento';
  }

  @override
  String get musicalDnaSources => 'Basado en';

  @override
  String musicalDnaSourceArtists(String classified, String total) {
    return '$classified de tus $total artistas más escuchados en Spotify (últimos 6 meses)';
  }

  @override
  String get musicalDnaSourceSpotifyGenres =>
      'Los géneros de tus artistas más escuchados en Spotify (últimos 6 meses)';

  @override
  String musicalDnaSourceTracks(String count) {
    return 'Tus $count canciones más escuchadas en Spotify';
  }

  @override
  String musicalDnaSourceGenres(String count) {
    return '$count géneros elegidos por ti';
  }

  @override
  String get musicalDnaEditGenres => 'Editar tus géneros';

  @override
  String get musicalDnaVisibility => 'Quién puede verlo';

  @override
  String get musicalDnaVisibilityPublic => 'Todos';

  @override
  String get musicalDnaVisibilityMatches => 'Afinidades';

  @override
  String get musicalDnaVisibilityPrivate => 'Solo yo';

  @override
  String get musicalDnaVisibilityPublicBody =>
      'Cualquiera en Vibra puede ver tu ADN musical en tu perfil.';

  @override
  String get musicalDnaVisibilityMatchesBody =>
      'Solo las personas con quienes tienes afinidad musical o una conexión.';

  @override
  String get musicalDnaVisibilityPrivateBody =>
      'Solo tú puedes verlo. Sigue guiando tus sugerencias.';

  @override
  String get musicalDnaVisibilityError =>
      'No se pudo guardar tu elección. Inténtalo de nuevo.';

  @override
  String get musicalDnaEmptyTitle => 'Aún no tienes ADN musical';

  @override
  String get musicalDnaEmptyBody =>
      'Conecta Spotify o elige algunos géneros que te encanten y tu ADN se construirá a partir de ellos.';

  @override
  String get musicalDnaPickGenres => 'Elegir géneros';

  @override
  String get musicalDnaLoadError => 'No se pudo cargar tu ADN musical.';

  @override
  String musicalDnaUpdated(String date) {
    return 'Actualizado el $date';
  }

  @override
  String musicalDnaFamilySemantics(String family, String percent) {
    return '$family, $percent por ciento';
  }

  @override
  String get musicalDnaProfileTile => 'ADN musical';

  @override
  String get musicalDnaProfileTileSubtitle =>
      'Tus géneros, tu diversidad y cómo evolucionan';

  @override
  String get musicalDnaSeeFull => 'Ver ADN completo';

  @override
  String affinityReasonCommonGround(String genres) {
    return 'Los dos escucháis $genres, en distinta medida.';
  }

  @override
  String get affinityReasonBothEclectic =>
      'Los dos sois oyentes eclécticos, entre géneros muy distintos.';

  @override
  String get affinityReasonBothFocused =>
      'Los dos os mantenéis cerca de vuestro sonido de referencia.';

  @override
  String get affinityReasonDiversityContrast =>
      'Uno explora mucho y el otro se mantiene centrado: hay mucho que compartir.';

  @override
  String affinityHeadlineSentence(int percent) {
    return 'Tenéis un $percent% de afinidad musical.';
  }

  @override
  String get sameFrequencyTitle => 'Same Frequency';

  @override
  String get sameFrequencyHeadline => 'Estáis en la misma frecuencia.';

  @override
  String sameFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Has descubierto $count personas con una fuerte conexión musical.',
      one: 'Has descubierto 1 persona con una fuerte conexión musical.',
      zero: 'Aún no hay conexiones musicales fuertes.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyTabForYou => 'Para ti';

  @override
  String get sameFrequencyTabSaved => 'Guardados';

  @override
  String get sameFrequencyEmptyTitle => 'Aún nadie en tu frecuencia';

  @override
  String get sameFrequencyEmptyBody =>
      'Aquí aparecerán las personas que compartan tu sonido. Elige más géneros o sincroniza Spotify para ampliar tu señal.';

  @override
  String get sameFrequencySavedEmptyTitle => 'No hay perfiles guardados';

  @override
  String get sameFrequencySavedEmptyBody =>
      'Guarda a las personas a las que quieras volver. Se quedan aquí hasta que las quites.';

  @override
  String get sameFrequencySave => 'Guardar';

  @override
  String get sameFrequencySaved => 'Guardado';

  @override
  String get sameFrequencySaveError =>
      'No se pudieron actualizar tus perfiles guardados. Inténtalo de nuevo.';

  @override
  String get sameFrequencyWhy => 'Por qué estáis en la misma frecuencia';

  @override
  String sameFrequencyReasonDiscoveries(String artists) {
    return 'Los dos habéis descubierto hace poco a $artists.';
  }

  @override
  String sameFrequencyReasonDirection(String genres) {
    return 'Los dos os estáis acercando a $genres.';
  }

  @override
  String sameFrequencyReasonEvent(String event, String date) {
    return 'Los dos vais a $event · $date.';
  }

  @override
  String sameFrequencyReasonEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habéis guardado $count eventos en común.',
      one: 'Habéis guardado 1 evento en común.',
    );
    return '$_temp0';
  }

  @override
  String get sameFrequencyDiscoverArtists => 'Descubrir artistas en común';

  @override
  String sameFrequencySharedArtistsTitle(String name) {
    return 'Artistas que compartes con $name';
  }

  @override
  String get sameFrequencyFindEvents => 'Buscar eventos';

  @override
  String get sameFrequencyEventsOptIn => 'Comparar eventos guardados';

  @override
  String get sameFrequencyEventsOptInBody =>
      'Encuentra gente que va a los mismos conciertos. Solo funciona con quienes también lo activaron; si no, tus eventos guardados siguen siendo privados.';

  @override
  String get sameFrequencyEntryBody =>
      'Personas con las que tienes una conexión musical real';

  @override
  String get sameFrequencyLoadError => 'No se pudo cargar Same Frequency.';

  @override
  String sameFrequencyPersonSemantics(String name, String percent) {
    return '$name, $percent por ciento de afinidad musical';
  }

  @override
  String get musicRadarTitle => 'Music Radar';

  @override
  String get musicRadarHeadline =>
      'Personas cerca de ti que comparten tu gusto musical.';

  @override
  String musicRadarCount(int count, int distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas compatibles a menos de $distance km.',
      one: '1 persona compatible a menos de $distance km.',
      zero: 'Aún no hay personas compatibles a menos de $distance km.',
    );
    return '$_temp0';
  }

  @override
  String get musicRadarAreaSound => 'El sonido de tu zona';

  @override
  String get musicRadarAreaSoundSub => 'Lo que más se escucha cerca de ti';

  @override
  String get musicRadarAreaTooFew =>
      'Se muestra cuando suficientes personas cercanas usan el radar.';

  @override
  String get musicRadarPeople => 'Perfiles compatibles';

  @override
  String get musicRadarEvents => 'Próximos eventos para tu sonido';

  @override
  String get musicRadarEventYourArtist => 'Uno de tus artistas';

  @override
  String get musicRadarEventSharedArtist =>
      'Un artista que compartes con gente cercana';

  @override
  String get musicRadarEventYourGenre => 'Tus géneros';

  @override
  String get musicRadarEventAreaGenre => 'Popular en tu zona';

  @override
  String get musicRadarIntroTitle =>
      'Descubre gente cercana a través de la música';

  @override
  String get musicRadarIntroBody =>
      'Music Radar muestra personas a tu alrededor con gustos parecidos. Está desactivado hasta que lo actives.';

  @override
  String get musicRadarPrivacy1 =>
      'Nadie ve tu ubicación ni tu distancia: solo que estás dentro de su radio.';

  @override
  String get musicRadarPrivacy2 =>
      'Tu posición se redondea a una zona de unos 5 km (o 20 km) y se mueve como máximo cada 6 horas.';

  @override
  String get musicRadarPrivacy3 =>
      'Oculta tu perfil, cambia la distancia o apaga el radar cuando quieras.';

  @override
  String get musicRadarTurnOn => 'Activar Music Radar';

  @override
  String get musicRadarLocationTitle => 'Se necesita la ubicación';

  @override
  String get musicRadarLocationBody =>
      'Music Radar usa tu ubicación aproximada. Activa la ubicación en Controles de privacidad y vuelve.';

  @override
  String get musicRadarOpenPrivacy => 'Abrir controles de privacidad';

  @override
  String get musicRadarMatchingNote =>
      'Activa Afinidad musical en Controles de privacidad para ver personas compatibles.';

  @override
  String get musicRadarSettings => 'Ajustes del radar';

  @override
  String get musicRadarEnabled => 'Music Radar';

  @override
  String get musicRadarVisible => 'Mostrarme en el radar';

  @override
  String get musicRadarVisibleBody =>
      'Si está desactivado, puedes mirar alrededor, pero nadie te ve.';

  @override
  String get musicRadarDistance => 'Distancia de descubrimiento';

  @override
  String musicRadarDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get musicRadarPrecision => 'Precisión de la ubicación';

  @override
  String get musicRadarPrecisionArea => 'Zona (~5 km)';

  @override
  String get musicRadarPrecisionRegion => 'Región (~20 km)';

  @override
  String get musicRadarPrecisionBody =>
      'Con qué aproximación se te sitúa respecto a los demás. Tu ubicación exacta nunca se comparte.';

  @override
  String get musicRadarSaveError =>
      'No se pudo guardar el ajuste. Inténtalo de nuevo.';

  @override
  String get musicRadarLoadError => 'No se pudo cargar Music Radar.';

  @override
  String get musicRadarEntryBody => 'Personas cercanas con tus gustos';

  @override
  String get musicRadarEmptyPeople =>
      'No hay nadie compatible cerca ahora. Prueba una distancia mayor o vuelve más tarde.';

  @override
  String get communitiesTitle => 'Comunidades';

  @override
  String get communitiesEntryBody =>
      'Géneros, artistas y escenas que te encantan';

  @override
  String get communitiesSearchHint => 'Buscar comunidades o artistas';

  @override
  String get communitiesForYou => 'Para ti';

  @override
  String get communitiesForYouSub => 'Según tu perfil musical';

  @override
  String get communitiesMine => 'Tus comunidades';

  @override
  String get communitiesExplore => 'Explorar';

  @override
  String get communitiesEmptySearch =>
      'Ninguna comunidad coincide con tu búsqueda.';

  @override
  String communitiesRecommendation(String name) {
    return 'Según tu perfil musical, quizá te guste $name.';
  }

  @override
  String communitiesReasonArtist(String artist) {
    return '$artist es uno de tus artistas más escuchados.';
  }

  @override
  String communitiesReasonGenre(String genre, int percent) {
    return '$genre es el $percent% de tu ADN musical.';
  }

  @override
  String communitiesStartArtist(String artist) {
    return 'Crea la comunidad de $artist';
  }

  @override
  String get communitiesStartArtistBody =>
      'Uno de tus artistas favoritos aún no tiene comunidad.';

  @override
  String communitiesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get communitiesOfficial => 'Oficial';

  @override
  String get communitiesKindGenre => 'Género';

  @override
  String get communitiesKindArtist => 'Artista';

  @override
  String get communitiesKindInterest => 'Interés';

  @override
  String get communitiesJoin => 'Unirme';

  @override
  String get communitiesJoined => 'Unido';

  @override
  String get communitiesLeave => 'Salir';

  @override
  String communitiesLeaveConfirm(String name) {
    return '¿Salir de $name?';
  }

  @override
  String get communitiesCreate => 'Crear una comunidad';

  @override
  String get communitiesCreateName => 'Nombre';

  @override
  String get communitiesCreateDescription => 'Descripción (opcional)';

  @override
  String get communitiesCreateArtist => 'Artista';

  @override
  String get communitiesCreateGenre => 'Género';

  @override
  String get communitiesCreateAction => 'Crear';

  @override
  String get communitiesTabPosts => 'Publicaciones';

  @override
  String get communitiesTabDiscussions => 'Debates';

  @override
  String get communitiesTabEvents => 'Eventos';

  @override
  String get communitiesTabMembers => 'Miembros';

  @override
  String get communitiesNewPost => 'Nueva publicación';

  @override
  String get communitiesComposerPost => 'Publicación';

  @override
  String get communitiesComposerDiscussion => 'Debate';

  @override
  String get communitiesComposerMusic => 'Compartir música';

  @override
  String get communitiesComposerBodyHint => '¿Qué estás pensando?';

  @override
  String get communitiesComposerTitleHint => 'Tema del debate';

  @override
  String get communitiesComposerLinkHint =>
      'Enlace de Spotify, Apple Music, YouTube, SoundCloud o Bandcamp';

  @override
  String get communitiesComposerTrackHint => 'Canción o álbum (opcional)';

  @override
  String get communitiesComposerArtistHint => 'Artista (opcional)';

  @override
  String get communitiesPublish => 'Publicar';

  @override
  String get communitiesJoinToPost =>
      'Únete para publicar, comentar y reaccionar.';

  @override
  String get communitiesEmptyFeed =>
      'Aún no hay publicaciones. Empieza la conversación.';

  @override
  String get communitiesEmptyDiscussions => 'Aún no hay debates.';

  @override
  String get communitiesEmptyEvents =>
      'No hay próximos eventos para esta comunidad.';

  @override
  String communitiesComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
      zero: 'Comentar',
    );
    return '$_temp0';
  }

  @override
  String get communitiesCommentHint => 'Añade un comentario';

  @override
  String get communitiesEmptyComments => 'Aún no hay comentarios.';

  @override
  String get communitiesOpenMusic => 'Escuchar';

  @override
  String get communitiesHeld =>
      'Oculto mientras los moderadores revisan las denuncias';

  @override
  String get communitiesDelete => 'Eliminar';

  @override
  String get communitiesRemove => 'Quitar (moderador)';

  @override
  String get communitiesRestore => 'Restaurar';

  @override
  String get communitiesBan => 'Expulsar de la comunidad';

  @override
  String communitiesBanConfirm(String name) {
    return '¿Expulsar a $name de esta comunidad?';
  }

  @override
  String get communitiesMakeModerator => 'Hacer moderador';

  @override
  String get communitiesRemoveModerator => 'Quitar moderador';

  @override
  String get communitiesRoleOwner => 'Propietario';

  @override
  String get communitiesRoleModerator => 'Moderador';

  @override
  String get communitiesModeration => 'Moderación';

  @override
  String get communitiesModerationEmpty => 'Nada que revisar.';

  @override
  String communitiesReports(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denuncias',
      one: '1 denuncia',
    );
    return '$_temp0';
  }

  @override
  String get communitiesReported => 'Gracias, los moderadores lo revisarán.';

  @override
  String get communitiesError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get communitiesErrorRate => 'Vas demasiado rápido. Espera un momento.';

  @override
  String get communitiesErrorSpam =>
      'Parece spam: demasiados enlaces, un enlace sospechoso o un contenido repetido.';

  @override
  String get communitiesErrorBanned => 'Te han expulsado de esta comunidad.';

  @override
  String get communitiesErrorLink =>
      'Usa un enlace de Spotify, Apple Music, YouTube, SoundCloud o Bandcamp.';

  @override
  String get communitiesErrorExists =>
      'Ya existe una comunidad para este artista.';

  @override
  String get communitiesErrorLimit => 'Has alcanzado el límite de hoy.';

  @override
  String get communitiesLoadError => 'No se pudieron cargar las comunidades.';

  @override
  String sameFrequencyReasonCommunities(String communities) {
    return 'Los dos estáis en $communities.';
  }

  @override
  String get musicRadarCommunities => 'Comunidades para el sonido de tu zona';

  @override
  String get circlesTitle => 'Círculos';

  @override
  String get circlesSubtitle => 'Grupos pequeños para la música que te encanta';

  @override
  String get circlesInvitations => 'Invitaciones';

  @override
  String circlesInvitedBy(String name) {
    return '$name te ha invitado';
  }

  @override
  String get circlesAccept => 'Aceptar';

  @override
  String get circlesDecline => 'Rechazar';

  @override
  String get circlesInviteDeclined => 'Invitación rechazada';

  @override
  String get circlesSuggested => 'VIBRA sugiere';

  @override
  String circlesSuggestionGenre(int count, String genre) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un círculo de $count personas que comparten $genre.',
    );
    return '$_temp0';
  }

  @override
  String circlesSuggestionArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un círculo de $count personas que escuchan a $artist.',
    );
    return '$_temp0';
  }

  @override
  String get circlesSuggestionConsent =>
      'Cada persona recibe una invitación y decide si se une.';

  @override
  String get circlesCreateAndInvite => 'Crear e invitar';

  @override
  String circlesSuggestionName(String topic) {
    return 'Círculo $topic';
  }

  @override
  String circlesInvitesSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Círculo creado. $count invitaciones enviadas.',
      one: 'Círculo creado. 1 invitación enviada.',
      zero: 'Círculo creado. No se pudo enviar ninguna invitación.',
    );
    return '$_temp0';
  }

  @override
  String get circlesMine => 'Tus círculos';

  @override
  String get circlesEmptyTitle => 'Aún no tienes círculos';

  @override
  String get circlesEmptyBody =>
      'Crea un grupo pequeño en torno a un género, un artista o un concierto e invita a gente que conoces.';

  @override
  String get circlesCreate => 'Nuevo círculo';

  @override
  String get circlesBasisGenre => 'Género';

  @override
  String get circlesBasisArtist => 'Artista';

  @override
  String get circlesBasisConcert => 'Concierto';

  @override
  String get circlesBasisInterest => 'Interés';

  @override
  String get circlesBasisActivity => 'Actividad';

  @override
  String get circlesName => 'Nombre';

  @override
  String get circlesDescription => 'Descripción (opcional)';

  @override
  String get circlesTopic => 'Tema';

  @override
  String get circlesNoSavedEvents =>
      'Guarda primero un evento para crear un círculo en torno a él.';

  @override
  String get circlesCreateAction => 'Crear';

  @override
  String circlesMembers(int count, int max) {
    return '$count/$max miembros';
  }

  @override
  String get circlesTabChat => 'Chat';

  @override
  String get circlesTabPlaylist => 'Playlist';

  @override
  String get circlesTabEvents => 'Eventos';

  @override
  String get circlesTabMembers => 'Miembros';

  @override
  String get circlesMessageHint => 'Escribe al círculo';

  @override
  String get circlesChatEmpty => 'Saluda a tu círculo.';

  @override
  String get circlesPlaylistEmpty => 'Aún no hay canciones. Añade la primera.';

  @override
  String get circlesAddTrack => 'Añadir una canción';

  @override
  String get circlesEventsEmpty => 'Aún no hay eventos compartidos.';

  @override
  String get circlesShareEvent => 'Compartir un evento';

  @override
  String get circlesInvite => 'Invitar personas';

  @override
  String get circlesInviteHint =>
      'Puedes invitar a tus conexiones y a personas con las que tienes afinidad musical. Ellas deciden si se unen.';

  @override
  String get circlesInviteNone => 'No hay nadie más a quien invitar ahora.';

  @override
  String get circlesInviteSend => 'Enviar invitaciones';

  @override
  String get circlesPending => 'Invitado';

  @override
  String get circlesRevoke => 'Cancelar invitación';

  @override
  String get circlesAdmin => 'Admin';

  @override
  String get circlesMakeAdmin => 'Hacer admin';

  @override
  String get circlesRemoveMember => 'Quitar del círculo';

  @override
  String get circlesMute => 'Silenciar notificaciones';

  @override
  String get circlesUnmute => 'Activar notificaciones';

  @override
  String get circlesEdit => 'Editar círculo';

  @override
  String get circlesLeave => 'Salir del círculo';

  @override
  String circlesLeaveConfirm(String name) {
    return '¿Salir de $name?';
  }

  @override
  String get circlesSave => 'Guardar';

  @override
  String get circlesError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get circlesErrorFull => 'Este círculo está completo.';

  @override
  String get circlesErrorNotAllowed =>
      'Solo puedes invitar a tus conexiones o a personas con las que tienes afinidad musical.';

  @override
  String get circlesErrorDeclined =>
      'Esta persona rechazó hace poco. Inténtalo más tarde.';

  @override
  String get circlesLoadError => 'No se pudieron cargar los círculos.';

  @override
  String get circlesRemove => 'Quitar';

  @override
  String get concertTitle => 'Concert Finder';

  @override
  String get concertHeadline => 'Quizá te gusten estos próximos eventos.';

  @override
  String get concertWhy => 'Por qué te lo recomendamos';

  @override
  String concertReasonTopArtist(String artist, int rank) {
    return '$artist es el n.º $rank de tus artistas más escuchados.';
  }

  @override
  String concertReasonTrackArtist(String artist) {
    return '$artist está en tus canciones más escuchadas.';
  }

  @override
  String concertReasonSavedArtist(String artist) {
    return 'Guardaste otro evento de $artist.';
  }

  @override
  String concertReasonGenre(String genre, int percent) {
    return '$genre es el $percent% de tu ADN musical.';
  }

  @override
  String concertReasonSimilarToSaved(String genre) {
    return 'Como otros eventos de $genre que guardaste.';
  }

  @override
  String concertReasonDistance(int km) {
    return 'A $km km de ti.';
  }

  @override
  String concertReasonSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'En $days días.',
      one: 'Mañana.',
      zero: 'Hoy.',
    );
    return '$_temp0';
  }

  @override
  String get concertFilterGenre => 'Género';

  @override
  String get concertFilterAll => 'Todos';

  @override
  String get concertArtistHint => 'Busca un artista';

  @override
  String get concertFilterDate => 'Cuándo';

  @override
  String get concertDateAny => 'Cualquier fecha';

  @override
  String get concertDateWeek => 'Próximos 7 días';

  @override
  String get concertDateMonth => 'Próximos 30 días';

  @override
  String get concertDate3Months => 'Próximos 3 meses';

  @override
  String get concertFilterDistance => 'Distancia';

  @override
  String get concertDistanceAny => 'Cualquier distancia';

  @override
  String concertDistanceValue(int km) {
    return '$km km';
  }

  @override
  String get concertFilterPrice => 'Precio';

  @override
  String get concertPriceAny => 'Cualquier precio';

  @override
  String concertPriceUpTo(String price) {
    return 'Hasta $price';
  }

  @override
  String get concertPriceNote =>
      'Solo eventos con un precio publicado en euros.';

  @override
  String get concertEmpty =>
      'Ningún evento recomendado coincide con estos filtros.';

  @override
  String get concertEmptyBody =>
      'Prueba una distancia mayor, otra fecha o menos filtros.';

  @override
  String get concertNoProfileTitle => 'Cuéntanos qué escuchas';

  @override
  String get concertNoProfileBody =>
      'Conecta Spotify o elige algunos géneros para recibir recomendaciones de conciertos.';

  @override
  String get concertLocationNote =>
      'Activa la ubicación para ver distancias y eventos cercanos.';

  @override
  String get concertLoadError => 'No se pudieron cargar las recomendaciones.';

  @override
  String get concertSaved => 'Guardado';

  @override
  String get eventDetailInterested => 'Me interesa';

  @override
  String get eventDetailAttendanceInterested => 'Guardado como interés';

  @override
  String get eventDetailAttendanceRemoved => 'Quitado de tus eventos';

  @override
  String get whosGoingTitle => '¿Quién va?';

  @override
  String get whosGoingSubtitle =>
      'Personas que eligieron compartir sus planes contigo';

  @override
  String whosGoingGoing(int count) {
    return '$count van';
  }

  @override
  String whosGoingMaybe(int count) {
    return '$count quizá';
  }

  @override
  String whosGoingInterested(int count) {
    return '$count interesados';
  }

  @override
  String get whosGoingFriends => 'Amigos';

  @override
  String get whosGoingCompatible => 'Personas compatibles';

  @override
  String get whosGoingOthers => 'Otros';

  @override
  String get whosGoingEmpty =>
      'Nadie que puedas ver ha compartido planes para este evento.';

  @override
  String get whosGoingPrivacyNote =>
      'Solo ves a quien eligió compartir sus planes contigo. Los tuyos siguen tu elección de abajo.';

  @override
  String get whosGoingCommunities => 'Comunidades para este evento';

  @override
  String whosGoingAffinity(int percent) {
    return '$percent% de afinidad';
  }

  @override
  String get whosGoingRequested => 'Solicitud enviada';

  @override
  String get attendanceVisibility => 'Quién puede ver tus planes';

  @override
  String get visibilityPrivate => 'Solo yo';

  @override
  String get visibilityFriends => 'Amigos';

  @override
  String get visibilityMatches => 'Amigos y afinidades';

  @override
  String get visibilityPublic => 'Todos';

  @override
  String get attendanceVisibilityDefault => 'Usar para todos mis eventos';

  @override
  String get attendanceVisibilityHint =>
      'Los demás solo ven tus planes si lo permites. Tú sigues viendo a quien comparte los suyos.';

  @override
  String get attendanceVisibilitySaved => 'Visibilidad actualizada';

  @override
  String get concertMatchTitle => 'Concert Match';

  @override
  String concertMatchHeadlineMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tú y otras $count personas estáis interesados en este concierto.',
      one: 'Tú y otra persona estáis interesados en este concierto.',
      zero:
          'Eres el primero que puedes ver. Abajo, gente a la que le encanta este artista.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchHeadlineOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personas que puedes ver están interesadas en este concierto.',
      one: '1 persona que puedes ver está interesada en este concierto.',
      zero:
          'Nadie que puedas ver ha compartido planes para este concierto todavía.',
    );
    return '$_temp0';
  }

  @override
  String concertMatchFan(String artist) {
    return 'También le encanta $artist';
  }

  @override
  String concertMatchCreateGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crear grupo del evento ($count)',
      zero: 'Crear grupo del evento',
    );
    return '$_temp0';
  }

  @override
  String get concertMatchGroupNote =>
      'Las personas solo se unen si aceptan tu invitación. No se comparte la ubicación ni los planes de viaje de nadie.';

  @override
  String get concertMatchShare => 'Compartir en un círculo';

  @override
  String get concertMatchShared => 'Evento compartido con el círculo';

  @override
  String concertMatchSharedMessage(String event, String date) {
    return 'Compartió un evento: $event · $date';
  }

  @override
  String get concertMatchNoCircles => 'Aún no tienes círculos.';

  @override
  String get concertMatchEmpty =>
      'Aún no hay coincidencias para este concierto.';

  @override
  String get concertMatchSelectHint =>
      'Selecciona personas para invitar a un grupo del evento';

  @override
  String get circlePlans => 'Planes';

  @override
  String get circlePlansEmpty =>
      'Aún no hay planes. Propón uno: cena, algo antes del concierto, un punto de encuentro.';

  @override
  String get circleAddPlan => 'Añadir un plan';

  @override
  String get circlePlanTitle => 'Qué';

  @override
  String get circlePlanWhen => 'Cuándo (opcional)';

  @override
  String get circlePlanNote => 'Detalles (opcional)';

  @override
  String get circlePlanIn => 'Me apunto';

  @override
  String get circlePlanJoined => 'Te apuntaste';

  @override
  String circlePlanPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count se apuntan',
      one: '1 se apunta',
    );
    return '$_temp0';
  }

  @override
  String get circlePlanPrivacy =>
      'Solo los miembros del círculo ven los planes.';

  @override
  String get groupConcert => 'El concierto';

  @override
  String get groupYourStatus => 'Tu estado';

  @override
  String get groupStatusHint => 'Solo lo ven los miembros de este grupo.';

  @override
  String get groupHeld => 'Oculto mientras los admins revisan las denuncias';

  @override
  String get groupRemoveAdmin => 'Quitar (admin)';

  @override
  String get groupBan => 'Expulsar del grupo';

  @override
  String groupBanConfirm(String name) {
    return '¿Expulsar a $name de este grupo? No podrá volver a entrar.';
  }

  @override
  String get groupErrorBanned =>
      'No se puede invitar a esta persona a este grupo.';

  @override
  String get groupYourGroups => 'Tus grupos para este evento';

  @override
  String get groupStart => 'Crear un grupo del concierto';

  @override
  String get groupReportMember => 'Denunciar miembro';

  @override
  String get vibeTitle => 'Daily Vibe';

  @override
  String get vibeQuestion => '¿Cuál es tu vibe hoy?';

  @override
  String get vibeShare => 'Comparte tu vibe';

  @override
  String get vibeChange => 'Cambiar el vibe de hoy';

  @override
  String get vibeSearchHint => 'Busca una canción en Spotify';

  @override
  String get vibeTabSpotify => 'Spotify';

  @override
  String get vibeTabLink => 'Otro enlace';

  @override
  String get vibeLinkHint =>
      'Enlace de Apple Music, YouTube, SoundCloud o Bandcamp';

  @override
  String get vibeTitleHint => 'Título de la canción';

  @override
  String get vibeArtistHint => 'Artista';

  @override
  String get vibeCaptionHint => 'Añade un texto (opcional)';

  @override
  String get vibeExpires => 'Desaparece a las 24 horas';

  @override
  String get vibeEveryone => 'Visible para todos';

  @override
  String get vibeVisibilityBody =>
      'Desactivado: solo lo ven tus conexiones y afinidades musicales.';

  @override
  String get vibePost => 'Publicar vibe';

  @override
  String get vibePosted => 'Tu vibe está publicado';

  @override
  String get vibeEmptyTitle => 'Aún no hay vibes hoy';

  @override
  String get vibeEmptyBody =>
      'Comparte el tuyo y conecta con gente o síguela para ver los suyos.';

  @override
  String get vibeListen => 'Escuchar en Spotify';

  @override
  String get vibeOpen => 'Abrir enlace';

  @override
  String get vibeSave => 'Añadir a descubrimientos';

  @override
  String get vibeSaved => 'En tus descubrimientos';

  @override
  String vibeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
      zero: 'Comentar',
    );
    return '$_temp0';
  }

  @override
  String get vibeCommentHint => 'Añade un comentario';

  @override
  String get vibeReply => 'Responder';

  @override
  String vibeReplyingTo(String name) {
    return 'Respondiendo a $name';
  }

  @override
  String vibeExpiresIn(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Quedan $hours h',
      one: 'Queda 1 h',
      zero: 'Menos de 1 h',
    );
    return '$_temp0';
  }

  @override
  String get vibeDelete => 'Eliminar mi vibe';

  @override
  String get vibeSearchEmpty => 'No se encontraron canciones.';

  @override
  String get vibeProviderUnavailable =>
      'La búsqueda de Spotify no está disponible ahora. Puedes pegar un enlace.';

  @override
  String get vibeError => 'No se pudo publicar tu vibe. Inténtalo de nuevo.';

  @override
  String get vibeAttribution => 'Información y portada de Spotify';

  @override
  String get discoveriesTitle => 'Descubrimientos';

  @override
  String get discoveriesEmpty =>
      'Aquí aparecen las canciones que añades desde Daily Vibe, historias, posts y comunidades. Solo tú puedes verlas.';

  @override
  String get discoveriesSubtitle => 'Canciones que descubriste en VIBRA';

  @override
  String get vibeLoadError => 'No se pudo cargar Daily Vibe.';

  @override
  String get vibeHomeCta => 'Comparte la canción que es tu vibe de hoy';

  @override
  String get storyAdd => 'Añadir historia';

  @override
  String get storyYours => 'Tu historia';

  @override
  String get storyNew => 'Nueva historia musical';

  @override
  String get storyKindNowPlaying => 'Escuchando ahora';

  @override
  String get storyKindArtist => 'Artista favorito';

  @override
  String get storyKindAlbum => 'Álbum recomendado';

  @override
  String get storyKindPlaylist => 'Playlist';

  @override
  String get storyKindConcertPhoto => 'Foto del concierto';

  @override
  String get storyKindOpinion => 'Opinión musical';

  @override
  String get storyAttribution => 'Información y portadas de Spotify';

  @override
  String get storyPreview => 'Vista previa de la historia';

  @override
  String get storySearchArtist => 'Busca un artista en Spotify';

  @override
  String get storySearchAlbum => 'Busca un álbum en Spotify';

  @override
  String get storySearchPlaylist => 'Busca una playlist pública en Spotify';

  @override
  String get storySearchEmpty => 'No se encontró nada.';

  @override
  String get storyArtistNameHint => 'Nombre del artista';

  @override
  String get storyAlbumTitleHint => 'Título del álbum';

  @override
  String get storyPlaylistTitleHint => 'Nombre de la playlist';

  @override
  String get storyPlaylistOwnerHint => 'Creada por (opcional)';

  @override
  String get storyPickPhoto => 'Elige una foto del concierto';

  @override
  String get storyChangePhoto => 'Cambiar foto';

  @override
  String get storyPhotoPrivacy =>
      'La ubicación y los datos de la cámara se eliminan de la foto antes de compartirla.';

  @override
  String get storyTagConcert => 'Concierto (opcional)';

  @override
  String get storyNoConcert => 'Sin concierto';

  @override
  String get storyOpinionHint =>
      'Tu opinión: un álbum, una escena, una canción…';

  @override
  String get storyBackground => 'Fondo';

  @override
  String get storyAudience => 'Quién puede verla';

  @override
  String get storyDefaultAudience => 'Quién ve tus historias por defecto';

  @override
  String get storyAudienceConnections => 'Conexiones';

  @override
  String get storyAudienceEveryone => 'Todos';

  @override
  String get storyAudienceConnectionsBody =>
      'Tus conexiones y afinidades musicales.';

  @override
  String get storyAudienceEveryoneBody =>
      'También quien te sigue. Las personas bloqueadas y a quienes ocultas tus historias nunca la ven.';

  @override
  String get storyAllowReplies => 'Permitir respuestas';

  @override
  String get storyAllowRepliesBody =>
      'Las respuestas son privadas: solo las ves tú y quien responde.';

  @override
  String get storyExpires => 'Desaparece a las 24 horas.';

  @override
  String get storyShare => 'Compartir historia';

  @override
  String get storyPosted => 'Tu historia está publicada durante 24 horas';

  @override
  String get storyError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get storyRateLimited =>
      'Estás compartiendo mucho. Espera un momento y vuelve a intentarlo.';

  @override
  String get storySpam =>
      'Parece spam. Quita los enlaces y vuelve a intentarlo.';

  @override
  String get storyPhotoError =>
      'No se puede usar esta foto. Elige un JPG o PNG de hasta 10 MB.';

  @override
  String get storySettingsTitle => 'Privacidad de las historias';

  @override
  String get storyHideFrom => 'Ocultar tus historias a';

  @override
  String get storyHideFromBody => 'No verán tus historias y no se les avisará.';

  @override
  String get storyHidden => 'Oculto de tus historias';

  @override
  String get storyNoConnections =>
      'Cuando tengas conexiones, aquí podrás elegir quién no ve tus historias.';

  @override
  String get storyJustNow => 'ahora';

  @override
  String storyMinutesAgo(int minutes) {
    return '$minutes min';
  }

  @override
  String storyHoursAgo(int hours) {
    return '$hours h';
  }

  @override
  String get storyPrevious => 'Historia anterior';

  @override
  String get storyNext => 'Siguiente historia';

  @override
  String get storyMore => 'Más opciones';

  @override
  String get storyLoadError => 'No se pudieron cargar estas historias.';

  @override
  String get storyGone =>
      'Estas historias caducaron o ya no están disponibles.';

  @override
  String get storyHeld =>
      'Oculta mientras se revisa tras varios reportes. Solo tú puedes verla.';

  @override
  String storyReplyHint(String name) {
    return 'Responder a $name…';
  }

  @override
  String get storySendReply => 'Enviar';

  @override
  String get storyReplySent => 'Respuesta enviada en privado';

  @override
  String get storyRepliesOff =>
      'Las respuestas están desactivadas en esta historia';

  @override
  String get storyRepliesOffMine =>
      'Las respuestas están desactivadas en esta historia.';

  @override
  String storyViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vistas',
      one: '1 vista',
      zero: 'Sin vistas',
    );
    return '$_temp0';
  }

  @override
  String storyReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '1 respuesta',
      zero: 'Respuestas',
    );
    return '$_temp0';
  }

  @override
  String storyReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reacciones',
      one: '1 reacción',
    );
    return '$_temp0';
  }

  @override
  String get storyInsightsPrivate => 'Solo tú ves quién vio y respondió.';

  @override
  String get storyNoViewers => 'Aún no hay vistas.';

  @override
  String get storyNoReplies => 'Aún no hay respuestas.';

  @override
  String storyAnswerHint(String name) {
    return 'Responde a $name en privado…';
  }

  @override
  String get storyMakeEveryone => 'Mostrar a todos';

  @override
  String get storyMakeConnectionsOnly => 'Mostrar solo a conexiones';

  @override
  String get storyNowEveryone => 'Ahora todos pueden ver esta historia';

  @override
  String get storyNowConnections =>
      'Ahora solo tus conexiones ven esta historia';

  @override
  String get storyTurnRepliesOff => 'Desactivar respuestas';

  @override
  String get storyTurnRepliesOn => 'Activar respuestas';

  @override
  String get storyDelete => 'Eliminar historia';

  @override
  String get storyDeleted => 'Historia eliminada';

  @override
  String storyMute(String name) {
    return 'Silenciar historias de $name';
  }

  @override
  String storyMuted(String name) {
    return 'No verás las historias de $name. No se le avisará.';
  }

  @override
  String get feedTitle => 'VIBRA Feed';

  @override
  String get feedHomeCta =>
      'Recomendaciones, reseñas y descubrimientos de tu mundo musical';

  @override
  String get feedForYou => 'Para ti';

  @override
  String get feedFollowing => 'Siguiendo';

  @override
  String get feedLatest => 'Recientes';

  @override
  String get feedForYouBody =>
      'Ordenado según a quién sigues, tus conexiones, comunidades y la música que te gusta. Cada post dice por qué aparece.';

  @override
  String get feedFollowingBody =>
      'Primero lo más reciente, de quien sigues y tus conexiones.';

  @override
  String get feedLatestBody =>
      'Primero lo más reciente, todos los posts que puedes ver.';

  @override
  String get feedCompose => 'Publicar';

  @override
  String get feedNewPost => 'Nuevo post';

  @override
  String get feedPublish => 'Publicar';

  @override
  String get feedPosted => 'Tu post está publicado';

  @override
  String get feedKindSong => 'Canción';

  @override
  String get feedKindAlbum => 'Álbum';

  @override
  String get feedKindPlaylist => 'Playlist';

  @override
  String get feedKindRecommendation => 'Recomendación';

  @override
  String get feedKindDiscovery => 'Descubrimiento';

  @override
  String get feedKindReview => 'Reseña';

  @override
  String get feedKindOpinion => 'Opinión';

  @override
  String get feedKindConcertPhoto => 'Foto del concierto';

  @override
  String get feedKindShare => 'Compartido';

  @override
  String get feedItemTrack => 'Canción';

  @override
  String get feedItemAlbum => 'Álbum';

  @override
  String get feedItemArtist => 'Artista';

  @override
  String get feedItemPlaylist => 'Playlist';

  @override
  String get feedWhatAbout => '¿De qué trata?';

  @override
  String get feedYourRating => 'Tu valoración';

  @override
  String feedRatingLabel(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String get feedReviewHint => '¿Qué te pareció? Sé concreto.';

  @override
  String get feedDiscoveryHint => '¿Cómo lo descubriste?';

  @override
  String get feedRecommendationHint => '¿Por qué deberían escucharlo?';

  @override
  String get feedBodyHint => 'Di algo al respecto (opcional)';

  @override
  String get feedAudienceEveryoneBody =>
      'Cualquiera en VIBRA puede verlo, excepto las personas bloqueadas.';

  @override
  String get feedAllowComments => 'Permitir comentarios';

  @override
  String get feedDuplicatePost => 'Ya publicaste esto hoy.';

  @override
  String get feedError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get feedLoadError => 'No se pudo cargar el feed.';

  @override
  String get feedEmptyTitle => 'Aún no hay nada';

  @override
  String get feedEmptyBody =>
      'Comparte una recomendación, o únete a comunidades y sigue a gente para llenar tu feed.';

  @override
  String get feedEmptyFollowing =>
      'Aquí aparecen los posts de quien sigues y de tus conexiones.';

  @override
  String get feedEnd => 'Estás al día';

  @override
  String get feedReasonFollowing => 'Sigues a esta persona';

  @override
  String get feedReasonConnection => 'Tu conexión';

  @override
  String get feedReasonArtists => 'Un artista que escuchas';

  @override
  String get feedReasonGenres => 'Géneros que te gustan';

  @override
  String get feedReasonCommunity => 'De tus comunidades';

  @override
  String get feedReasonMatch => 'Afinidad musical';

  @override
  String get feedReasonInteraction => 'Interactúas a menudo con esta persona';

  @override
  String get feedReasonNew => 'Nuevo en VIBRA';

  @override
  String feedDaysAgo(int days) {
    return '$days d';
  }

  @override
  String get feedHeld =>
      'Oculto mientras se revisa tras varios reportes. Solo tú puedes verlo.';

  @override
  String get feedLike => 'Me gusta';

  @override
  String get feedUnlike => 'Quitar me gusta';

  @override
  String get feedReact => 'Reaccionar';

  @override
  String get feedComments => 'Comentarios';

  @override
  String get feedShare => 'Compartir';

  @override
  String get feedSave => 'Guardar';

  @override
  String get feedUnsave => 'Quitar de guardados';

  @override
  String get feedSaved => 'Guardado';

  @override
  String get feedUnsaved => 'Quitado de guardados';

  @override
  String get feedShareToFeed => 'Compartir en tu feed';

  @override
  String get feedShareCommentHint => 'Añade un comentario (opcional)';

  @override
  String get feedShareOnlyPublic =>
      'Solo los posts públicos de otras personas se pueden compartir en tu feed.';

  @override
  String get feedShared => 'Compartido en tu feed';

  @override
  String get feedAlreadyShared => 'Ya compartiste este post.';

  @override
  String get feedCopyLink => 'Copiar enlace de la música';

  @override
  String get feedLinkCopied => 'Enlace copiado';

  @override
  String get feedTurnCommentsOff => 'Desactivar comentarios';

  @override
  String get feedTurnCommentsOn => 'Activar comentarios';

  @override
  String get feedDelete => 'Eliminar post';

  @override
  String get feedDeleted => 'Post eliminado';

  @override
  String get feedNotInterested => 'No me interesa';

  @override
  String get feedNotInterestedDone => 'Verás menos posts como este';

  @override
  String get feedPostTitle => 'Post';

  @override
  String get feedPostGone => 'Post no disponible';

  @override
  String get feedPostGoneBody => 'Se eliminó o ya no puedes verlo.';

  @override
  String get feedCommentHint => 'Añade un comentario';

  @override
  String get feedCommentsOff =>
      'Los comentarios están desactivados en este post.';

  @override
  String get feedDuplicateComment => 'Ya escribiste este comentario.';

  @override
  String get feedNoComments =>
      'Aún no hay comentarios. Empieza la conversación.';

  @override
  String get feedDeleteComment => 'Eliminar comentario';

  @override
  String get feedSavedTitle => 'Posts guardados';

  @override
  String get feedSavedSubtitle => 'Los posts que guardaste en el feed';

  @override
  String get feedSavedEmpty => 'No hay posts guardados';

  @override
  String get feedSavedEmptyBody =>
      'Toca el marcador de un post para guardarlo aquí. Solo tú ves tus guardados.';

  @override
  String get feedPostsTitle => 'Posts';

  @override
  String feedPostsOf(String name) {
    return 'Posts de $name';
  }

  @override
  String get feedSeeAllPosts => 'Ver todos';

  @override
  String get feedNoPosts => 'Aún no hay posts';

  @override
  String get feedNoPostsBody => 'Aquí aparecerán los posts que puedes ver.';

  @override
  String get feedYourPosts => 'Tus posts';

  @override
  String get feedYourPostsSubtitle => 'Todo lo que publicaste en el feed';

  @override
  String get reactionFire => 'Fuego';

  @override
  String get reactionObsessed => 'Obsesión';

  @override
  String get reactionUnderrated => 'Infravalorado';

  @override
  String get reactionClassic => 'Clásico';

  @override
  String get reactionNewDiscovery => 'Nuevo descubrimiento';

  @override
  String get reactionOnRepeat => 'En bucle';

  @override
  String get reactionHeart => 'Me encanta';

  @override
  String get reactionHeadphones => 'Escuchando';

  @override
  String get reactionClap => 'Aplausos';

  @override
  String get reactionMindBlown => 'Alucinante';

  @override
  String get reactionTrackTitle => 'Reacciona a esta canción';

  @override
  String get discoveryAdded => 'Añadido a tus descubrimientos';

  @override
  String get discoveryAddFailed =>
      'No se pudo añadir la canción. Inténtalo de nuevo.';

  @override
  String get discoveryOffer =>
      '¿Un nuevo descubrimiento? Guárdalo en tus descubrimientos.';

  @override
  String discoveryFoundVia(String name) {
    return 'vía $name';
  }

  @override
  String get aiTitle => 'VIBRA AI';

  @override
  String get aiHomeCta =>
      'Pide artistas, álbumes, conciertos y géneros por descubrir';

  @override
  String get aiPrivacyTile =>
      'Asistente musical opcional. Desactivado hasta que lo actives.';

  @override
  String get aiUnavailableTitle => 'VIBRA AI no está disponible';

  @override
  String get aiUnavailableBody =>
      'El asistente no está disponible ahora. Todo lo demás en VIBRA funciona como siempre.';

  @override
  String get aiConsentTitle => 'Conoce a tu asistente musical';

  @override
  String get aiConsentIntro =>
      'Pide artistas similares, álbumes para tu gusto, conciertos según tus intereses, comunidades y nuevos géneros. Es opcional y está desactivado hasta que lo actives.';

  @override
  String get aiConsentUses => 'Para responder usa';

  @override
  String get aiConsentUsesProfile =>
      'Tu Musical DNA, tus artistas principales y los géneros que elegiste';

  @override
  String get aiConsentUsesChat =>
      'Tu pregunta y los últimos mensajes de este chat';

  @override
  String get aiConsentUsesCatalogue =>
      'El catálogo público de Spotify y los conciertos y comunidades de VIBRA';

  @override
  String get aiConsentNever => 'Nunca usa';

  @override
  String get aiConsentNeverBody =>
      'Tus mensajes, ubicación, contactos, perfiles de otras personas ni tu acceso a Spotify. VIBRA no guarda los chats.';

  @override
  String get aiConsentProvider =>
      'Las respuestas las genera un proveedor de IA externo (Anthropic), que recibe la información anterior en cada pregunta. Puedes desactivar VIBRA AI en cualquier momento.';

  @override
  String get aiConsentAccept => 'Activar VIBRA AI';

  @override
  String get aiConsentDecline => 'Ahora no';

  @override
  String get aiTurnOff => 'Desactivar VIBRA AI';

  @override
  String get aiTurnedOff => 'VIBRA AI está desactivado';

  @override
  String get aiNewChat => 'Nueva conversación';

  @override
  String get aiIntro => '¿Qué quieres descubrir?';

  @override
  String get aiExampleSimilar =>
      'Recomiéndame artistas similares a Travis Scott';

  @override
  String get aiExampleUnderground =>
      'Encuentra artistas de Hip-Hop underground';

  @override
  String get aiExampleAlbums => 'Recomiéndame álbumes según mi perfil musical';

  @override
  String get aiExampleExplain => 'Explica por qué dos artistas suenan parecido';

  @override
  String get aiExampleConcerts => 'Encuentra conciertos según mis intereses';

  @override
  String get aiExampleCommunities =>
      'Sugiéreme comunidades que podrían gustarme';

  @override
  String get aiExampleGenres => 'Ayúdame a descubrir nuevos géneros';

  @override
  String get aiInputHint => 'Pregúntale a VIBRA AI sobre música';

  @override
  String get aiThinking => 'Buscando…';

  @override
  String get aiGeneratedLabel => 'Generado por IA · puede contener errores';

  @override
  String get aiVerifiedTitle => 'Resultados verificados';

  @override
  String get aiIdeasTitle => 'Ideas para explorar';

  @override
  String get aiIdeasBody => 'Sugerencias generadas, no verificadas.';

  @override
  String get aiSourceSpotify => 'Verificado en Spotify';

  @override
  String get aiSourceEvents => 'De los conciertos de VIBRA';

  @override
  String get aiSourceCommunities => 'Comunidad de VIBRA';

  @override
  String get aiSourceDna => 'De tu Musical DNA';

  @override
  String get aiSourceGenres => 'Catálogo de géneros de VIBRA';

  @override
  String aiMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get aiRateLimited =>
      'Has preguntado mucho. Vuelve a intentarlo en un rato.';

  @override
  String get aiError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get aiRefused =>
      'VIBRA AI no puede ayudarte con eso. Prueba con una pregunta sobre música.';

  @override
  String get aiIncomplete =>
      'No se pudo completar la respuesta. Prueba a preguntar de forma más sencilla.';

  @override
  String get discoverTitle => 'Descubre tu próximo artista';

  @override
  String get discoverHomeCta =>
      'Artistas similares, emergentes y underground elegidos para ti';

  @override
  String get discoverIntro =>
      'Según tus artistas favoritos, tu Musical DNA, las canciones que descubriste y tus valoraciones. Tus respuestas guían las próximas recomendaciones.';

  @override
  String get discoverAll => 'Todos';

  @override
  String get discoverSimilar => 'Similares';

  @override
  String get discoverCollaborations => 'Colaboraciones';

  @override
  String get discoverEmerging => 'Emergentes';

  @override
  String get discoverUnderground => 'Underground';

  @override
  String get discoverExploration => 'Nuevos géneros';

  @override
  String discoverReasonCollab(String artist) {
    return 'Colaboró con $artist';
  }

  @override
  String discoverReasonExplore(String genre) {
    return 'Un paso hacia: $genre';
  }

  @override
  String discoverReasonGenres(String genres) {
    return 'Comparte tu estilo: $genres';
  }

  @override
  String get discoverLike => 'Me gusta';

  @override
  String get discoverSave => 'Guardar para después';

  @override
  String get discoverKnown => 'Ya lo conocía';

  @override
  String get discoverNotInterested => 'No me interesa';

  @override
  String get discoverLiked => 'Entendido: más como este';

  @override
  String get discoverUndone => 'Eliminado';

  @override
  String get discoverSaved => 'Guardado para después';

  @override
  String get discoverUnsaved => 'Quitado de guardados';

  @override
  String get discoverKnownDone =>
      'Anotado. No volveremos a sugerirte este artista.';

  @override
  String get discoverNotInterestedDone =>
      'No volverás a ver este artista, y menos parecidos.';

  @override
  String get discoverRefresh => 'Nuevas propuestas';

  @override
  String get discoverRefreshLimited =>
      'No se pudo actualizar ahora. Inténtalo en unos minutos.';

  @override
  String get discoverError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get discoverEmptyTitle => 'Aún no hay artistas nuevos';

  @override
  String get discoverEmptyBody => 'Vuelve más tarde o toca Nuevas propuestas.';

  @override
  String get discoverNoProfile =>
      'Conecta Spotify o elige algunos géneros para que VIBRA sepa qué te gusta.';

  @override
  String get discoverPickGenres => 'Elegir géneros';

  @override
  String get discoverSavedTitle => 'Artistas guardados';

  @override
  String get discoverSavedSubtitle =>
      'Artistas que guardaste para escuchar después';

  @override
  String get discoverSavedEmpty => 'No hay artistas guardados';

  @override
  String get discoverSavedEmptyBody =>
      'Toca Guardar para después en una recomendación para tenerla aquí.';

  @override
  String get tasteTitle => 'Evolución del gusto';

  @override
  String get tasteOpen => 'Mira cómo ha cambiado tu gusto';

  @override
  String get tastePeriodMonth => '1 mes';

  @override
  String get tastePeriodThreeMonths => '3 meses';

  @override
  String get tastePeriodSixMonths => '6 meses';

  @override
  String get tastePeriodYear => '1 año';

  @override
  String tasteEvolved(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Tu gusto musical ha cambiado en el último mes',
      'year': 'Tu gusto musical ha cambiado en el último año',
      'three': 'Tu gusto musical ha cambiado en los últimos 3 meses',
      'six': 'Tu gusto musical ha cambiado en los últimos 6 meses',
      'other': 'Tu gusto musical ha cambiado en los últimos 3 meses',
    });
    return '$_temp0';
  }

  @override
  String tasteSteady(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'month': 'Tu gusto musical se mantuvo estable en el último mes',
      'year': 'Tu gusto musical se mantuvo estable en el último año',
      'three': 'Tu gusto musical se mantuvo estable en los últimos 3 meses',
      'six': 'Tu gusto musical se mantuvo estable en los últimos 6 meses',
      'other': 'Tu gusto musical se mantuvo estable en los últimos 3 meses',
    });
    return '$_temp0';
  }

  @override
  String tasteComparing(String from, String to) {
    return 'Comparando tu Musical DNA del $from con el del $to.';
  }

  @override
  String tasteShortHistory(String from, String to) {
    return 'Tu historial empieza el $from, así que se compara el $from con el $to.';
  }

  @override
  String tasteChangePoints(int points) {
    return 'Se movieron $points puntos porcentuales de tu mezcla de géneros.';
  }

  @override
  String get tasteThenNow => 'Antes y ahora';

  @override
  String get tasteThen => 'Antes';

  @override
  String get tasteNow => 'Ahora';

  @override
  String get tasteTimeline => 'Con el tiempo';

  @override
  String tasteTimelineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capturas',
      one: '1 captura',
    );
    return '$_temp0 de tu Musical DNA en este periodo.';
  }

  @override
  String get tasteNewGenres => 'Nuevos géneros descubiertos';

  @override
  String get tasteNoNewGenres => 'Ningún género nuevo en este periodo.';

  @override
  String get tasteEmergingArtists => 'Favoritos en ascenso';

  @override
  String get tasteNoEmergingArtists =>
      'Tus artistas favoritos son los mismos que antes.';

  @override
  String get tasteNoArtistData =>
      'Conecta Spotify para ver cómo cambian tus artistas favoritos.';

  @override
  String get tasteArtistNew => 'Nuevo';

  @override
  String tasteArtistRose(int from, int to) {
    return '#$from → #$to';
  }

  @override
  String get tastePrevious => 'Lo que escuchabas más antes';

  @override
  String get tasteNoPrevious => 'Nada de lo que te gustaba se ha apagado.';

  @override
  String get tasteFormerTopArtist => 'Era uno de tus artistas principales';

  @override
  String get tasteCommunities => 'Comunidades a las que te uniste';

  @override
  String get tasteNoCommunities =>
      'No te uniste a ninguna comunidad en este periodo.';

  @override
  String tasteJoinedOn(String date) {
    return 'Te uniste el $date';
  }

  @override
  String get tasteNoDnaTitle => 'Aún no hay Musical DNA';

  @override
  String get tasteNoDnaBody =>
      'La evolución de tu gusto empieza cuando VIBRA tenga tu Musical DNA.';

  @override
  String get tasteTooEarlyTitle => 'Aún no hay suficiente historial';

  @override
  String tasteTooEarlyBody(String date) {
    return 'Tu historial empieza el $date. Vuelve en unas semanas para ver cómo cambia tu gusto.';
  }

  @override
  String get tasteOffTitle => 'Historial de gustos desactivado';

  @override
  String get tasteOffBody =>
      'VIBRA solo guarda tu Musical DNA actual. Activa el historial abajo para seguir tu gusto desde hoy.';

  @override
  String get tasteKeepHistory => 'Guardar mi historial de gustos';

  @override
  String get tasteKeepHistoryBody =>
      'Una captura de tu Musical DNA al día, guardada hasta 400 días y visible solo para ti.';

  @override
  String get tasteTurnOffTitle => '¿Desactivar el historial de gustos?';

  @override
  String get tasteTurnOffBody =>
      'Se eliminarán tus capturas anteriores y solo se guardará tu Musical DNA actual. Las funciones que comparan tu gusto en el tiempo dejarán de funcionar hasta que lo reactives.';

  @override
  String get tasteTurnOffConfirm => 'Desactivar y eliminar';

  @override
  String get tasteError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get profileSectionGenres => 'Géneros favoritos';

  @override
  String get profileSectionArtists => 'Artistas favoritos';

  @override
  String get profileSectionStats => 'Estadísticas musicales';

  @override
  String get profileSectionSavedSongs => 'Canciones guardadas';

  @override
  String get profileSectionPlaylists => 'Playlists compartidas';

  @override
  String get profileSectionEvents => 'Próximos eventos';

  @override
  String get profileSectionCommunities => 'Comunidades';

  @override
  String get profileSectionCircles => 'Círculos';

  @override
  String get profileSectionActivity => 'Actividad musical';

  @override
  String get profileLevelPublic => 'Todos';

  @override
  String get profileLevelConnections => 'Conexiones';

  @override
  String get profileLevelPrivate => 'Solo yo';

  @override
  String get profileRelationConnection => 'Tu conexión';

  @override
  String get profileRelationMatch => 'Afinidad musical';

  @override
  String profileMemberSince(String date) {
    return 'En VIBRA desde $date';
  }

  @override
  String profileSignatureSemantics(String name, String genres) {
    return '$name, firma sonora: $genres';
  }

  @override
  String get profileNoGenres => 'Aún no hay géneros favoritos.';

  @override
  String get profileNoArtists => 'Aún no hay artistas favoritos.';

  @override
  String get profileNoPlaylists => 'Aún no hay playlists compartidas.';

  @override
  String get profileNoEvents => 'No hay próximos eventos para mostrar.';

  @override
  String get profileNoCommunities => 'Aún no está en ninguna comunidad.';

  @override
  String get profileNoCircles => 'Aún no estás en ningún círculo.';

  @override
  String get profileNoSharedCircles => 'No estáis en ningún círculo juntos.';

  @override
  String get profileSharedCirclesNote => 'Círculos en los que estáis los dos.';

  @override
  String get profileNoActivity => 'No hay actividad reciente.';

  @override
  String profileActivityPosted(String title) {
    return 'Publicó: $title';
  }

  @override
  String profileActivityVibe(String title) {
    return 'Daily Vibe: $title';
  }

  @override
  String profileActivityJoined(String name) {
    return 'Se unió a $name';
  }

  @override
  String get profileEventGoing => 'Va';

  @override
  String get profileEventMaybe => 'Quizás';

  @override
  String get profileEventInterested => 'Le interesa';

  @override
  String get profileStatGenres => 'Géneros';

  @override
  String get profileStatDiversity => 'Diversidad';

  @override
  String get profileStatDiscoveries => 'Descubrimientos';

  @override
  String get profileStatPosts => 'Posts';

  @override
  String get profileStatConcerts => 'Conciertos asistidos';

  @override
  String get profileSomePrivate =>
      'Algunas secciones de este perfil son privadas.';

  @override
  String get profilePrivacyTitle => 'Privacidad del perfil';

  @override
  String get profilePrivacyTile =>
      'Elige quién ve cada parte de tu perfil musical';

  @override
  String get profilePrivacyIntro =>
      'Elige quién puede ver cada parte de tu perfil. Tu foto, nombre, usuario y biografía siempre son visibles para las personas con las que puedes interactuar.';

  @override
  String get profilePrivacyEventsNote =>
      'Cada evento mantiene además la visibilidad elegida en Quién va.';

  @override
  String get profilePrivacyCirclesNote =>
      'Los demás solo ven los círculos de los que también forman parte.';

  @override
  String get profilePrivacyPostsNote =>
      'Cada post mantiene además su propio público.';

  @override
  String get profilePrivacyDnaNote =>
      'El Musical DNA tiene su propio ajuste de visibilidad.';

  @override
  String get profilePrivacyError => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get safetyTitle => 'Seguridad y privacidad';

  @override
  String get safetySettingsSubtitle =>
      'Bloqueos, reportes, visibilidad y ubicación en un solo lugar';

  @override
  String get safetyIntro =>
      'Todo lo que decide quién puede contactarte y qué ve. Los servidores de VIBRA aplican estas reglas en toda la app.';

  @override
  String get safetyPeople => 'Personas';

  @override
  String get safetyBlockedTitle => 'Personas bloqueadas';

  @override
  String safetyBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
      zero: 'Nadie bloqueado',
    );
    return '$_temp0';
  }

  @override
  String get safetyBlockExplain =>
      'El bloqueo se aplica en todas partes: mensajes, comentarios, posts, historias, comunidades, círculos, eventos y radar. También elimina seguimientos y conexiones entre vosotros. La otra persona no recibe aviso.';

  @override
  String get safetyNoBlocked => 'No has bloqueado a nadie';

  @override
  String safetyBlockedOn(String date) {
    return 'Desde el $date';
  }

  @override
  String get safetyUnblock => 'Desbloquear';

  @override
  String safetyUnblockTitle(String name) {
    return '¿Desbloquear a $name?';
  }

  @override
  String get safetyUnblockBody =>
      'Podrá volver a encontrarte y contactarte. Los seguimientos y conexiones eliminados por el bloqueo no vuelven.';

  @override
  String safetyUnblocked(String name) {
    return 'Se desbloqueó a $name';
  }

  @override
  String safetyBlockTitle(String name) {
    return '¿Bloquear a $name?';
  }

  @override
  String get safetyBlockBody =>
      'No os veréis en ninguna parte de VIBRA y se eliminarán los seguimientos y conexiones entre vosotros. No se avisará a nadie.';

  @override
  String get safetyReportUser => 'Reportar a esta persona';

  @override
  String get safetyReported => 'Gracias. Nuestro equipo revisará el reporte.';

  @override
  String get safetyDuplicateReport => 'Ya lo reportaste hace poco.';

  @override
  String get safetyRateLimited => 'Demasiados intentos. Inténtalo más tarde.';

  @override
  String get safetyUserUnavailable => 'Esta persona no está disponible.';

  @override
  String get safetyVisibility => 'Lo que ven los demás';

  @override
  String safetyHiddenFrom(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ocultas a $count personas',
      one: 'ocultas a 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get safetyAttendance => 'Asistencia a eventos';

  @override
  String get safetyAttendanceBody => 'se elige en cada evento en Quién va';

  @override
  String get safetyLocation => 'Ubicación';

  @override
  String get safetyLocationExplain =>
      'Tu posición exacta nunca se muestra a nadie. El radar usa zonas aproximadas, y solo si lo activas.';

  @override
  String get safetyRadarVisible => 'Activado, visible';

  @override
  String get safetyRadarHidden => 'Activado, oculto';

  @override
  String get safetyOn => 'Activado';

  @override
  String get safetyOff => 'Desactivado';

  @override
  String get safetyData => 'Tus datos';

  @override
  String get safetyAllPrivacy => 'Todos los controles de privacidad';

  @override
  String get safetyAllPrivacyBody =>
      'Consentimientos, notificaciones y exportación de datos';

  @override
  String get safetyReporting => 'Reportes';

  @override
  String get safetyReportingBody =>
      'Puedes reportar a una persona desde su perfil y cualquier mensaje, post, comentario, historia, respuesta, vibe o contenido de comunidad desde su menú. Los reportes son privados. El contenido reportado por varias personas se oculta mientras se revisa, y los moderadores de comunidades pueden eliminar contenido y expulsar miembros.';

  @override
  String get safetyContact => 'Contactar con soporte';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifCenterSubtitle => 'Todo lo que ha pasado, en un solo lugar';

  @override
  String get notifSettingsTitle => 'Preferencias de notificaciones';

  @override
  String get notifSettingsSubtitle =>
      'Categorías, horas de silencio y límite diario';

  @override
  String get notifToday => 'Hoy';

  @override
  String get notifThisWeek => 'Esta semana';

  @override
  String get notifEarlier => 'Antes';

  @override
  String get notifMarkAllRead => 'Marcar todo como leído';

  @override
  String get notifUnread => 'No leída';

  @override
  String notifUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notificaciones sin leer',
      one: '1 notificación sin leer',
    );
    return '$_temp0';
  }

  @override
  String notifGrouped(int count) {
    return '$count novedades';
  }

  @override
  String get notifEmptyTitle => 'Aún no hay notificaciones';

  @override
  String get notifEmptyBody =>
      'Solicitudes, mensajes, conciertos y todo lo demás aparecerán aquí.';

  @override
  String get notifError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get notifPushAll => 'Notificaciones push';

  @override
  String get notifPushAllBody =>
      'Desactivadas: todo sigue apareciendo en el centro de notificaciones, pero no se envía nada.';

  @override
  String get notifNoDevice =>
      'Las notificaciones push aún no están activas en este dispositivo. Igualmente verás cada notificación aquí.';

  @override
  String get notifCategoriesTitle => 'Qué puede enviar notificaciones';

  @override
  String get notifCategoriesBody =>
      'Desactivar una categoría detiene sus notificaciones push. Sigue apareciendo en el centro de notificaciones.';

  @override
  String get notifOncePerDay => 'Como máximo una notificación push al día.';

  @override
  String get notifCatRequests => 'Solicitudes Vibra';

  @override
  String get notifCatRequestsBody => 'Solicitudes nuevas y aceptadas.';

  @override
  String get notifCatMessages => 'Mensajes';

  @override
  String get notifCatMessagesBody =>
      'Mensajes directos, solicitudes de mensaje y chats en vivo de eventos.';

  @override
  String get notifCatCommunities => 'Actividad en comunidades';

  @override
  String get notifCatCommunitiesBody =>
      'Comentarios en tus posts de comunidades.';

  @override
  String get notifCatCircles => 'Círculos';

  @override
  String get notifCatCirclesBody => 'Invitaciones, mensajes y planes.';

  @override
  String get notifCatConcerts => 'Anuncios de conciertos';

  @override
  String get notifCatConcertsBody =>
      'Nuevos conciertos de artistas que escuchas y novedades de eventos.';

  @override
  String get notifCatReminders => 'Recordatorios de eventos';

  @override
  String get notifCatRemindersBody =>
      'Una semana antes, el día anterior y el día de los eventos a los que vas.';

  @override
  String get notifCatRecommendations => 'Recomendaciones';

  @override
  String get notifCatRecommendationsBody =>
      'Música recomendada por quien sigues y nuevas afinidades musicales.';

  @override
  String get notifCatSocial => 'Daily Vibe, historias y posts';

  @override
  String get notifCatSocialBody =>
      'Comentarios y respuestas a lo que compartes.';

  @override
  String get notifCatDiscoveries => 'Descubrimientos musicales';

  @override
  String get notifCatDiscoveriesBody =>
      'Cuando alguien guarda una canción que compartiste.';

  @override
  String get notifCatUpdates => 'Novedades de VIBRA';

  @override
  String get notifCatUpdatesBody =>
      'Tu semana musical y sugerencias ocasionales.';

  @override
  String get notifQuietTitle => 'Horas de silencio';

  @override
  String get notifQuietBody =>
      'Sin notificaciones push en estas horas, salvo los mensajes directos. Todo te espera en el centro de notificaciones.';

  @override
  String get notifQuietFrom => 'Desde';

  @override
  String get notifQuietTo => 'Hasta';

  @override
  String notifDailyCap(int count) {
    return 'Como máximo $count notificaciones push al día';
  }

  @override
  String get notifCalmExplain =>
      'Para que las notificaciones sean útiles, VIBRA agrupa la actividad repetida en una sola notificación («3 comentarios nuevos»), no vuelve a enviar el mismo grupo en 30 minutos, retiene las notificaciones push en las horas de silencio, limita las categorías menos importantes a una notificación push al día y nunca te avisa de personas que bloqueaste.';

  @override
  String get circlesMuted => 'Notificaciones silenciadas';

  @override
  String get profileStories => 'Historias';

  @override
  String storyCardSemantics(String name, String kind, int hours) {
    return 'Historia musical de $name: $kind, hace $hours h';
  }

  @override
  String musicRadarMapSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mapa de afinidad con $count personas',
      one: 'Mapa de afinidad con 1 persona',
      zero: 'Mapa de afinidad, aún sin nadie',
    );
    return '$_temp0';
  }

  @override
  String musicRadarMapPerson(String name, int percent) {
    return '$name, $percent% de afinidad';
  }

  @override
  String get musicRadarMapNote =>
      'Más cerca del centro significa más música en común. Las posiciones muestran afinidad, nunca dónde está alguien.';

  @override
  String get safetyOverviewError =>
      'No se pudo cargar tu configuración actual. Puedes abrir cada sección igualmente.';

  @override
  String get homeSignatureEyebrow => 'TU MÚSICA, TU GENTE';

  @override
  String get homeSignatureTitle => 'Encuentra a tu gente a través de la música';

  @override
  String homeDnaTop(String family) {
    return '$family lidera tu sonido';
  }

  @override
  String get homeDnaEmpty => 'Créalo con los géneros que te gustan';

  @override
  String homeFrequencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas en tu frecuencia',
      one: '1 persona en tu frecuencia',
      zero: 'Descubre a quien comparte tus gustos',
    );
    return '$_temp0';
  }

  @override
  String homeConcertMatchNext(String name) {
    return 'Conoce a quien va a $name';
  }

  @override
  String get homeConcertMatchNone =>
      'Elige un concierto para conocer a quien va';

  @override
  String homeCirclesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count círculos',
      one: '1 círculo',
      zero: 'Crea un pequeño grupo musical',
    );
    return '$_temp0';
  }

  @override
  String homeCirclesInvites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitaciones pendientes',
      one: '1 invitación pendiente',
    );
    return '$_temp0';
  }
}
