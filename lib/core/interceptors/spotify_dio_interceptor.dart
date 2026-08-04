import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/core_providers.dart';
import '../utils/logger.dart';

class SpotifyDioInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;

  SpotifyDioInterceptor({required this.ref, required this.dio});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokenStorage = ref.read(spotifyTokenStorageProvider);
    final token = await tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      VibraLogger.warning('Access token Spotify scaduto. Tento il refresh...');
      try {
        final authRepository = ref.read(spotifyAuthRepositoryProvider);
        final newSession = await authRepository.refreshSession();
        
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${newSession.accessToken}';
        
        // Riprova la richiesta originaria
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        VibraLogger.error('Refresh token fallito', error: e);
        return super.onError(err, handler);
      }
    } else if (err.response?.statusCode == 429) {
      final retryAfter = err.response?.headers.value('retry-after');
      if (retryAfter != null) {
        final waitSeconds = int.tryParse(retryAfter) ?? 1;
        VibraLogger.warning('Rate limit superato. Attendo $waitSeconds secondi...');
        await Future.delayed(Duration(seconds: waitSeconds));
        
        final options = err.requestOptions;
        try {
          final response = await dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }
    
    return super.onError(err, handler);
  }
}
