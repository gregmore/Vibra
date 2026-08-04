import 'package:flutter_appauth/flutter_appauth.dart';

import '../constants/api_constants.dart';
import 'env_config.dart';

/// Configurazione OAuth 2.0 Authorization Code Flow con PKCE per Spotify.
/// Le impostazioni native andranno allineate in AndroidManifest e Info.plist.
class SpotifyOAuthConfig {
  SpotifyOAuthConfig._();

  static const AuthorizationServiceConfiguration serviceConfiguration =
      AuthorizationServiceConfiguration(
        authorizationEndpoint: ApiConstants.spotifyAuthUrl,
        tokenEndpoint: ApiConstants.spotifyTokenUrl,
      );

  static String get clientId => EnvConfig.spotifyClientId;

  static String get redirectUri => EnvConfig.spotifyRedirectUri;

  static List<String> get scopes =>
      List.unmodifiable(ApiConstants.spotifyScopes);

  static AuthorizationTokenRequest buildAuthorizationRequest() {
    return AuthorizationTokenRequest(
      clientId,
      redirectUri,
      serviceConfiguration: serviceConfiguration,
      scopes: scopes,
      promptValues: const ['consent'],
    );
  }

  static TokenRequest buildRefreshTokenRequest(String refreshToken) {
    return TokenRequest(
      clientId,
      redirectUri,
      refreshToken: refreshToken,
      serviceConfiguration: serviceConfiguration,
      scopes: scopes,
    );
  }
}
