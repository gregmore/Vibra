import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/spotify_token_model.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';

class SpotifyAuthDatasource {
  final SupabaseClient supabaseClient;

  SpotifyAuthDatasource({
    required this.supabaseClient,
  });

  /// Genera un Code Verifier casuale per PKCE.
  String generateCodeVerifier() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(43, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Genera un Code Challenge derivato dal Code Verifier usando SHA-256.
  String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  /// Genera uno stato casuale per prevenire CSRF.
  String generateState() {
    final rand = Random.secure();
    return List.generate(16, (index) => rand.nextInt(16).toRadixString(16)).join();
  }

  /// Avvia il flusso di autorizzazione Spotify tramite flutter_web_auth_2.
  /// Restituisce il codice di autorizzazione.
  Future<String> authenticate({
    required String codeChallenge,
    required String state,
  }) async {
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
      VibraLogger.info('Avvio FlutterWebAuth2 con URL: $authUrl');
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackScheme,
      );

      final resultUri = Uri.parse(result);
      final code = resultUri.queryParameters['code'];
      final returnedState = resultUri.queryParameters['state'];
      final error = resultUri.queryParameters['error'];

      if (error != null) {
        throw AuthException(message: 'Errore Spotify OAuth: $error');
      }

      if (returnedState != state) {
        throw const AuthException(message: 'Stato non corrispondente. Potenziale attacco CSRF.');
      }

      if (code == null) {
        throw const AuthException(message: 'Codice di autorizzazione non ricevuto da Spotify.');
      }

      return code;
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
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'spotify-token-exchange',
        body: {
          'action': 'exchange',
          'code': code,
          'code_verifier': codeVerifier,
          'redirect_uri': EnvConfig.spotifyRedirectUri,
        },
      );

      if (response.status != 200) {
        String errMsg = 'Scambio token fallito: ${response.data}';
        
        if (response.data is Map && response.data['error'] == 'spotify_account_already_linked') {
          errMsg = response.data['message'] ?? 'Questo account Spotify è già collegato a un altro profilo Vibra.';
        }

        throw ServerException(
          message: errMsg,
          endpoint: 'spotify-token-exchange',
        );
      }

      final data = response.data as Map<String, dynamic>;
      return SpotifyTokenModel.fromJson(data);
    } catch (e) {
      VibraLogger.error('Errore durante lo scambio token Spotify', error: e);
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Scambio token fallito: $e', endpoint: 'spotify-token-exchange');
    }
  }

  /// Rinnova la sessione Spotify tramite Edge Function.
  Future<SpotifyTokenModel> refreshSession({required String refreshToken}) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'spotify-token-exchange',
        body: {
          'action': 'refresh',
          'refresh_token': refreshToken,
        },
      );

      if (response.status != 200) {
        throw ServerException(
          message: 'Refresh token fallito: ${response.data}',
          endpoint: 'spotify-token-exchange',
        );
      }

      final data = response.data as Map<String, dynamic>;
      return SpotifyTokenModel.fromJson(data);
    } catch (e) {
      VibraLogger.error('Errore durante il refresh della sessione Spotify', error: e);
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Refresh sessione fallito: $e', endpoint: 'spotify-token-exchange');
    }
  }

  /// Avvia la sincronizzazione del profilo musicale tramite Edge Function.
  Future<Map<String, dynamic>> syncMusicProfile() async {
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
    } catch (e) {
      VibraLogger.error('Errore durante la sincronizzazione profilo Spotify', error: e);
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Sincronizzazione profilo fallita: $e', endpoint: 'sync-music-profile');
    }
  }
}
