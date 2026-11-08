import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/spotify_token_model.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

class SpotifyAuthDatasource {
  final SupabaseClient supabaseClient;

  SpotifyAuthDatasource({required this.supabaseClient});

  void _requireSpotifyEnabled() {
    if (!AppConstants.spotifyEnabled) {
      throw const ServerException(message: 'spotify_temporarily_unavailable');
    }
  }

  static String validateCallback(
    String callback,
    String redirect,
    String state,
  ) {
    final result = Uri.parse(callback);
    final expected = Uri.parse(redirect);
    // Which check failed, never the code or state values themselves.
    final reason = state.isEmpty
        ? 'empty_state'
        : result.scheme != expected.scheme
        ? 'scheme ${result.scheme} != ${expected.scheme}'
        : result.host != expected.host
        ? 'host ${result.host} != ${expected.host}'
        : result.port != expected.port
        ? 'port'
        // `scheme://host` and `scheme://host/` are the same redirect: iOS
        // returns Spotify's callback with a trailing slash.
        : _normalizedPath(result.path) != _normalizedPath(expected.path)
        ? 'path ${result.path} != ${expected.path}'
        : result.userInfo.isNotEmpty
        ? 'user_info'
        : result.hasFragment
        ? 'fragment'
        : result.queryParametersAll['state']?.length != 1
        ? 'state_count'
        : result.queryParameters['state'] != state
        ? 'state_mismatch'
        : null;
    if (reason != null) {
      VibraLogger.warning('Spotify callback rejected: $reason', tag: 'Spotify');
      throw const AuthException(
        message: 'Callback OAuth non valido. Riprova il collegamento.',
      );
    }
    if (result.queryParameters.containsKey('error')) {
      throw const AuthException(
        message: 'Autorizzazione Spotify annullata o rifiutata.',
      );
    }
    final codes = result.queryParametersAll['code'];
    if (codes == null || codes.length != 1 || codes.single.isEmpty) {
      throw const AuthException(
        message: 'Codice di autorizzazione Spotify mancante.',
      );
    }
    return codes.single;
  }

  static String _normalizedPath(String path) =>
      path.length > 1 && path.endsWith('/')
      ? path.substring(0, path.length - 1)
      : path == '/'
      ? ''
      : path;

  /// Genera un Code Verifier casuale per PKCE.
  String generateCodeVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(
      43,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  /// Genera un Code Challenge derivato dal Code Verifier usando SHA-256.
  String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url
        .encode(digest.bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  /// Genera uno stato casuale per prevenire CSRF.
  String generateState() {
    final rand = Random.secure();
    return List.generate(
      32,
      (index) => rand.nextInt(16).toRadixString(16),
    ).join();
  }

  /// Avvia il flusso di autorizzazione Spotify tramite flutter_web_auth_2.
  /// Restituisce il codice di autorizzazione.
  Future<String> authenticate({
    required String codeChallenge,
    required String state,
  }) async {
    _requireSpotifyEnabled();
    final clientId = EnvConfig.spotifyClientId;
    final redirectUri = EnvConfig.spotifyRedirectUri;
    final callbackScheme = Uri.parse(redirectUri).scheme;
    final scopes = ApiConstants.spotifyScopes.join(' ');

    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': codeChallenge,
      'state': state,
      'scope': scopes,
      'show_dialog': 'true',
    }).toString();

    try {
      VibraLogger.info('Avvio autorizzazione Spotify');
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackScheme,
      );

      return validateCallback(result, redirectUri, state);
    } catch (e) {
      VibraLogger.error('Errore durante il login Spotify', error: e);
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Login Spotify annullato o fallito: $e');
    }
  }

  /// Esegue lo scambio del codice di autorizzazione con i token di Spotify tramite Edge Function.
  Future<SpotifyTokenModel> exchangeCode({
    required String code,
    required String codeVerifier,
    String? vibraAccessToken,
  }) async {
    _requireSpotifyEnabled();
    try {
      final response = await supabaseClient.functions.invoke(
        'spotify-token-exchange',
        headers: vibraAccessToken == null
            ? null
            : {'Authorization': 'Bearer $vibraAccessToken'},
        body: {
          'action': 'exchange',
          'code': code,
          'code_verifier': codeVerifier,
          'redirect_uri': EnvConfig.spotifyRedirectUri,
        },
      );

      if (response.status != 200) {
        String errMsg = 'Scambio token fallito: ${response.data}';

        if (response.data is Map &&
            response.data['error'] == 'spotify_account_already_linked') {
          errMsg =
              response.data['message'] ??
              'Questo account Spotify è già collegato a un altro profilo Vibra.';
        }

        throw ServerException(
          message: errMsg,
          endpoint: 'spotify-token-exchange',
        );
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['connected'] != true) {
        throw const ServerException(
          message: 'spotify_token_exchange_failed',
          endpoint: 'spotify-token-exchange',
        );
      }
      return SpotifyTokenModel.fromJson(data);
    } on FunctionException catch (e) {
      VibraLogger.error('Errore durante lo scambio token Spotify', error: e);
      final details = e.details;
      final code = details is Map ? details['error'] : null;
      throw ServerException(
        message: code == 'spotify_account_already_linked'
            ? (details['message'] as String? ??
                  'Questo account Spotify è già collegato a un altro profilo Vibra.')
            : 'Scambio token fallito: ${code ?? e.status}',
        endpoint: 'spotify-token-exchange',
      );
    } catch (e) {
      VibraLogger.error('Errore durante lo scambio token Spotify', error: e);
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Scambio token fallito: $e',
        endpoint: 'spotify-token-exchange',
      );
    }
  }

  /// Scollega Spotify: il server elimina token cifrati, profilo musicale,
  /// cronologia ascolti e affinità (`disconnect_spotify_account`).
  Future<void> disconnect() async {
    try {
      final response = await supabaseClient.functions.invoke(
        'spotify-disconnect',
      );
      if (response.status != 200) {
        throw ServerException(
          message: 'spotify_disconnect_failed',
          endpoint: 'spotify-disconnect',
        );
      }
    } on FunctionException catch (e) {
      throw ServerException(
        message: 'spotify_disconnect_failed: ${e.status}',
        endpoint: 'spotify-disconnect',
      );
    }
  }

  /// Avvia la sincronizzazione del profilo musicale tramite Edge Function.
  Future<Map<String, dynamic>> syncMusicProfile() async {
    _requireSpotifyEnabled();
    try {
      final response = await supabaseClient.functions.invoke(
        'sync-music-profile',
      );

      if (response.status != 200) {
        throw ServerException(
          message: 'Sincronizzazione profilo fallita: ${response.data}',
          endpoint: 'sync-music-profile',
        );
      }

      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      // Keep the backend error code (e.g. spotify_not_connected after a
      // revocation, spotify_rate_limited) so the UI can react to it.
      final details = e.details;
      final code = details is Map ? details['error'] : null;
      VibraLogger.error('Sync Spotify fallita: ${code ?? e.status}', error: e);
      throw ServerException(
        message: 'Sincronizzazione profilo fallita: ${code ?? e.status}',
        endpoint: 'sync-music-profile',
      );
    } catch (e) {
      VibraLogger.error(
        'Errore durante la sincronizzazione profilo Spotify',
        error: e,
      );
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Sincronizzazione profilo fallita: $e',
        endpoint: 'sync-music-profile',
      );
    }
  }
}
