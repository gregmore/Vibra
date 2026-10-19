import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/env_config.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/spotify_token_storage.dart';
import '../../domain/repositories/events_repository.dart';
import '../../domain/repositories/live_repository.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/social_repository.dart';
import '../../core/router/app_router.dart';
import '../../data/datasources/bandsintown_datasource.dart';
import '../../data/datasources/events_aggregator_datasource.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../data/datasources/supabase_events_datasource.dart';
import '../../data/datasources/supabase_live_datasource.dart';
import '../../data/datasources/supabase_notifications_datasource.dart';
import '../../data/datasources/supabase_profile_datasource.dart';
import '../../data/datasources/supabase_social_datasource.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../data/repositories/live_repository_impl.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../data/datasources/spotify_auth_datasource.dart';
import '../../data/repositories/spotify_auth_repository_impl.dart';
import '../../domain/repositories/spotify_auth_repository.dart';
import '../../core/utils/logger.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.createRouter(ref);
  ref.onDispose(router.dispose);
  return router;
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      contentType: 'application/json',
      followRedirects: false,
    ),
  );

  dio.interceptors.add(_SupportDiagnosticsInterceptor());

  return dio;
});

class _SupportDiagnosticsInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response?.statusCode;
    VibraLogger.api(
      err.requestOptions.method,
      err.requestOptions.uri.path,
      statusCode: response ?? 500,
    );
    super.onError(err, handler);
  }
}

final supabaseDatasourceProvider = Provider<SupabaseDatasource>(
  (ref) => SupabaseDatasource(),
);

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final spotifyTokenStorageProvider = Provider<SpotifyTokenStorage>((ref) {
  final auth = ref.watch(supabaseDatasourceProvider).client.auth;
  final userId = auth.currentUser?.id;
  final subscription = auth.onAuthStateChange.listen((event) {
    if (event.session?.user.id != userId) ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);
  return SpotifyTokenStorage(
    ref.watch(secureStorageProvider),
    namespace:
        '${Uri.parse(EnvConfig.supabaseUrl).host}_${userId ?? 'signed-out'}',
  );
});

final bandsintownDatasourceProvider = Provider<BandsintownDatasource?>((ref) {
  final appId = EnvConfig.bandsintownAppId;
  if (appId == null || appId.isEmpty) return null;
  return BandsintownDatasource(dio: ref.watch(dioProvider), appId: appId);
});

final eventsAggregatorDatasourceProvider = Provider<EventsAggregatorDatasource>(
  (ref) {
    return EventsAggregatorDatasource(
      bandsintown: ref.watch(bandsintownDatasourceProvider),
      nearbySearch: ref
          .watch(supabaseEventsDatasourceProvider)
          .searchNearbyEvents,
    );
  },
);

final supabaseProfileDatasourceProvider = Provider<SupabaseProfileDatasource>((
  ref,
) {
  return SupabaseProfileDatasource(ref.watch(supabaseDatasourceProvider));
});

final supabaseEventsDatasourceProvider = Provider<SupabaseEventsDatasource>((
  ref,
) {
  return SupabaseEventsDatasource(ref.watch(supabaseDatasourceProvider));
});

final supabaseSocialDatasourceProvider = Provider<SupabaseSocialDatasource>((
  ref,
) {
  return SupabaseSocialDatasource(ref.watch(supabaseDatasourceProvider));
});

final supabaseLiveDatasourceProvider = Provider<SupabaseLiveDatasource>((ref) {
  return SupabaseLiveDatasource(ref.watch(supabaseDatasourceProvider));
});

final supabaseNotificationsDatasourceProvider =
    Provider<SupabaseNotificationsDatasource>((ref) {
      return SupabaseNotificationsDatasource(
        ref.watch(supabaseDatasourceProvider),
      );
    });

// ─────────────────────────────────────────────────────────────
// Repositories (data layer)
// ─────────────────────────────────────────────────────────────

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(supabaseProfileDatasourceProvider));
});

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(
    externalDatasource: ref.watch(eventsAggregatorDatasourceProvider),
    supabaseDatasource: ref.watch(supabaseEventsDatasourceProvider),
  );
});

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(ref.watch(supabaseSocialDatasourceProvider));
});

final liveRepositoryProvider = Provider<LiveRepository>((ref) {
  return LiveRepositoryImpl(ref.watch(supabaseLiveDatasourceProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepositoryImpl(
    ref.watch(supabaseNotificationsDatasourceProvider),
  );
});

final spotifyAuthDatasourceProvider = Provider<SpotifyAuthDatasource>((ref) {
  return SpotifyAuthDatasource(
    supabaseClient: ref.watch(supabaseDatasourceProvider).client,
  );
});

final spotifyAuthRepositoryProvider = Provider<SpotifyAuthRepository>((ref) {
  return SpotifyAuthRepositoryImpl(
    datasource: ref.watch(spotifyAuthDatasourceProvider),
    tokenStorage: ref.watch(spotifyTokenStorageProvider),
  );
});
