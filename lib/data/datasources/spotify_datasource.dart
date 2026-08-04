import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/spotify_oauth_config.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/spotify/spotify_artist_model.dart';
import '../models/spotify/spotify_paged_response.dart';
import '../models/spotify/spotify_playlist_model.dart';
import '../models/spotify/spotify_track_model.dart';

/// Datasource per l'API Spotify.
/// Gestisce OAuth PKCE e chiamate all'API Web di Spotify.
class SpotifyDatasource {
  final Dio dio;
  final FlutterAppAuth appAuth;

  SpotifyDatasource({required this.dio, required this.appAuth});

  String? _accessToken;
  String? _refreshToken;

  /// Token di accesso corrente.
  String? get accessToken => _accessToken;

  /// Imposta i token (utile quando si caricano dal database).
  void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _configureDio();
  }

  /// Configura Dio con il token di autorizzazione.
  void _configureDio() {
    dio.options.baseUrl = ApiConstants.spotifyApiBase;
    dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    dio.options.headers['Content-Type'] = 'application/json';
  }

  // ── OAuth 2.0 PKCE Flow ─────────────────────────────────

  /// Avvia il flusso di autorizzazione OAuth 2.0 con PKCE.
  /// Apre il browser per il login Spotify e restituisce i token.
  Future<Map<String, String>> authorize() async {
    try {
      final result = await appAuth.authorizeAndExchangeCode(
        SpotifyOAuthConfig.buildAuthorizationRequest(),
      );

      if (result.accessToken == null) {
        throw const AuthException(
          message: 'Autorizzazione Spotify fallita: nessun token ricevuto',
        );
      }

      _accessToken = result.accessToken!;
      _refreshToken = result.refreshToken;
      _configureDio();

      VibraLogger.info('Spotify OAuth completato con successo');

      return {
        'access_token': result.accessToken!,
        if (result.refreshToken != null) 'refresh_token': result.refreshToken!,
      };
    } catch (e) {
      if (e is AuthException) rethrow;
      VibraLogger.error('Errore OAuth Spotify', error: e);
      throw AuthException(
        message: 'Errore durante l\'autenticazione Spotify: $e',
      );
    }
  }

  /// Rinnova il token di accesso usando il refresh token.
  Future<String> refreshAccessToken() async {
    if (_refreshToken == null) {
      throw const AuthException(message: 'Nessun refresh token disponibile');
    }

    try {
      final result = await appAuth.token(
        SpotifyOAuthConfig.buildRefreshTokenRequest(_refreshToken!),
      );

      if (result.accessToken == null) {
        throw const SpotifyException(
          message: 'Refresh token fallito',
          isTokenExpired: true,
        );
      }

      _accessToken = result.accessToken!;
      if (result.refreshToken != null) {
        _refreshToken = result.refreshToken!;
      }
      _configureDio();

      VibraLogger.info('Token Spotify rinnovato con successo');
      return _accessToken!;
    } catch (e) {
      if (e is SpotifyException || e is AuthException) rethrow;
      VibraLogger.error('Errore refresh token Spotify', error: e);
      throw const SpotifyException(
        message: 'Impossibile rinnovare il token Spotify',
        isTokenExpired: true,
      );
    }
  }

  // ── API Calls ───────────────────────────────────────────

  /// Recupera i top artisti dell'utente.
  /// [timeRange]: 'short_term' | 'medium_term' | 'long_term'
  Future<SpotifyPagedResponse> getTopArtists({
    int limit = 50,
    String timeRange = 'medium_term',
  }) async {
    final json = await _get(
      ApiConstants.spotifyTopArtists,
      queryParams: {'limit': limit, 'time_range': timeRange},
    );
    return SpotifyPagedResponse.fromJson(json);
  }

  /// Recupera i top brani dell'utente.
  Future<SpotifyPagedResponse> getTopTracks({
    int limit = 50,
    String timeRange = 'medium_term',
  }) async {
    final json = await _get(
      ApiConstants.spotifyTopTracks,
      queryParams: {'limit': limit, 'time_range': timeRange},
    );
    return SpotifyPagedResponse.fromJson(json);
  }

  /// Recupera le playlist dell'utente.
  Future<SpotifyPagedResponse> getPlaylists({int limit = 50}) async {
    final json = await _get(
      ApiConstants.spotifyPlaylists,
      queryParams: {'limit': limit},
    );
    return SpotifyPagedResponse.fromJson(json);
  }

  /// Recupera il profilo dell'utente Spotify.
  Future<Map<String, dynamic>> getUserProfile() async {
    return _get(ApiConstants.spotifyMe);
  }

  /// Helper: decodifica lista artisti da response paginata.
  List<SpotifyArtistModel> parseArtists(SpotifyPagedResponse response) {
    return response.items
        .whereType<Map<String, dynamic>>()
        .map(SpotifyArtistModel.fromJson)
        .toList(growable: false);
  }

  /// Helper: decodifica lista brani da response paginata.
  List<SpotifyTrackModel> parseTracks(SpotifyPagedResponse response) {
    return response.items
        .whereType<Map<String, dynamic>>()
        .map(SpotifyTrackModel.fromJson)
        .toList(growable: false);
  }

  /// Helper: decodifica playlist.
  List<SpotifyPlaylistModel> parsePlaylists(SpotifyPagedResponse response) {
    return response.items
        .whereType<Map<String, dynamic>>()
        .map(SpotifyPlaylistModel.fromJson)
        .toList(growable: false);
  }

  /// Metodo generico GET con gestione errori e retry token.
  Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      VibraLogger.api(
        'GET',
        '${ApiConstants.spotifyApiBase}$endpoint',
        statusCode: response.statusCode,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Token scaduto — tentativo di refresh automatico
      if (e.response?.statusCode == 401) {
        throw const SpotifyException(
          message: 'Token Spotify scaduto',
          statusCode: 401,
          isTokenExpired: true,
        );
      }
      VibraLogger.error('Errore API Spotify: $endpoint', error: e);
      throw SpotifyException(
        message: e.message ?? 'Errore sconosciuto API Spotify',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
