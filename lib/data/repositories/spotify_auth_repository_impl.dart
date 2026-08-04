import '../../domain/entities/spotify_session.dart';
import '../../domain/repositories/spotify_auth_repository.dart';
import '../datasources/spotify_auth_datasource.dart';
import '../../core/services/spotify_token_storage.dart';

class SpotifyAuthRepositoryImpl implements SpotifyAuthRepository {
  final SpotifyAuthDatasource datasource;
  final SpotifyTokenStorage tokenStorage;

  SpotifyAuthRepositoryImpl({
    required this.datasource,
    required this.tokenStorage,
  });

  @override
  Future<SpotifySession> connectAccount() async {
    final codeVerifier = datasource.generateCodeVerifier();
    final codeChallenge = datasource.generateCodeChallenge(codeVerifier);
    final state = datasource.generateState();

    final code = await datasource.authenticate(
      codeChallenge: codeChallenge,
      state: state,
    );

    final tokenModel = await datasource.exchangeCode(
      code: code,
      codeVerifier: codeVerifier,
    );

    // Salva i token localmente in modo sicuro
    await tokenStorage.saveAccessToken(tokenModel.accessToken);
    await tokenStorage.saveRefreshToken(tokenModel.refreshToken);

    return tokenModel;
  }

  @override
  Future<SpotifySession> refreshSession() async {
    final oldRefreshToken = await tokenStorage.readRefreshToken();
    if (oldRefreshToken == null) {
      throw Exception('Nessun refresh token disponibile per Spotify');
    }

    final tokenModel = await datasource.refreshSession(refreshToken: oldRefreshToken);

    await tokenStorage.saveAccessToken(tokenModel.accessToken);
    if (tokenModel.refreshToken.isNotEmpty) {
      await tokenStorage.saveRefreshToken(tokenModel.refreshToken);
    }

    return tokenModel;
  }
}
