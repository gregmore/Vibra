import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../core/config/env_config.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/spotify_token_storage.dart';
import '../../domain/repositories/events_repository.dart';
import '../../domain/repositories/live_repository.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../../core/router/app_router.dart';
import '../../data/datasources/bandsintown_datasource.dart';
import '../../data/datasources/events_aggregator_datasource.dart';
import '../../data/datasources/spotify_datasource.dart';
import '../../data/datasources/supabase_datasource.dart';
import '../../data/datasources/supabase_events_datasource.dart';
import '../../data/datasources/supabase_live_datasource.dart';
import '../../data/datasources/supabase_notifications_datasource.dart';
import '../../data/datasources/supabase_profile_datasource.dart';
import '../../data/datasources/supabase_social_datasource.dart';
import '../../data/datasources/songkick_datasource.dart';
import '../../data/datasources/events_datasource.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../data/repositories/live_repository_impl.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../data/repositories/spotify_repository_impl.dart';
import '../../data/datasources/spotify_auth_datasource.dart';
import '../../data/repositories/spotify_auth_repository_impl.dart';
import '../../domain/repositories/spotify_auth_repository.dart';
import '../../core/utils/logger.dart';

final routerProvider = Provider<GoRouter>((ref) => AppRouter.createRouter(ref));

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseBody: false,
    ),
  );

  dio.interceptors.add(SpotifyAuthInterceptor(ref));

  return dio;
});

final appAuthProvider = Provider<FlutterAppAuth>((ref) => FlutterAppAuth());

final supabaseDatasourceProvider = Provider<SupabaseDatasource>(
  (ref) => SupabaseDatasource(),
);

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final spotifyTokenStorageProvider = Provider<SpotifyTokenStorage>((ref) {
  return SpotifyTokenStorage(ref.watch(secureStorageProvider));
});

final spotifyDatasourceProvider = Provider<SpotifyDatasource>((ref) {
  return SpotifyDatasource(
    dio: ref.watch(dioProvider),
    appAuth: ref.watch(appAuthProvider),
  );
});

final ticketmasterDatasourceProvider = Provider<TicketmasterDatasource?>((ref) {
  final apiKey = EnvConfig.ticketmasterApiKey;
  if (apiKey == null || apiKey.isEmpty) return null;
  return TicketmasterDatasource(dio: ref.watch(dioProvider), apiKey: apiKey);
});

final songkickDatasourceProvider = Provider<SongkickDatasource?>((ref) {
  final apiKey = EnvConfig.songkickApiKey;
  if (apiKey == null || apiKey.isEmpty) return null;
  return SongkickDatasource(dio: ref.watch(dioProvider), apiKey: apiKey);
});

final bandsintownDatasourceProvider = Provider<BandsintownDatasource?>((ref) {
  final appId = EnvConfig.bandsintownAppId;
  if (appId == null || appId.isEmpty) return null;
  return BandsintownDatasource(dio: ref.watch(dioProvider), appId: appId);
});

final eventsAggregatorDatasourceProvider = Provider<EventsAggregatorDatasource>(
  (ref) {
    return EventsAggregatorDatasource(
      ticketmaster: ref.watch(ticketmasterDatasourceProvider),
      songkick: ref.watch(songkickDatasourceProvider),
      bandsintown: ref.watch(bandsintownDatasourceProvider),
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

final spotifyRepositoryProvider = Provider<SpotifyRepository>((ref) {
  return SpotifyRepositoryImpl(
    ref.watch(spotifyDatasourceProvider),
    ref.watch(spotifyTokenStorageProvider),
  );
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

class SpotifyAuthInterceptor extends Interceptor {
  final Ref ref;

  SpotifyAuthInterceptor(this.ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.contains('spotify-token-exchange')) {
        return super.onError(err, handler);
      }

      try {
        final session = await ref
            .read(spotifyAuthRepositoryProvider)
            .refreshSession();

        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] =
            'Bearer ${session.accessToken}';

        final dio = ref.read(dioProvider);
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        VibraLogger.error(
          'Errore durante il refresh automatico nel Dio interceptor',
          error: e,
        );
      }
    }
    super.onError(err, handler);
  }
}
