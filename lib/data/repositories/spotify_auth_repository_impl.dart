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
    final originalSession = datasource.supabaseClient.auth.currentSession;
    if (originalSession == null) {
      throw StateError('Accedi prima di collegare Spotify.');
    }
    void checkUser() {
      if (datasource.supabaseClient.auth.currentUser?.id !=
          originalSession.user.id) {
        throw StateError('Account cambiato durante il collegamento. Riprova.');
      }
    }

    final codeVerifier = datasource.generateCodeVerifier();
    final codeChallenge = datasource.generateCodeChallenge(codeVerifier);
    final state = datasource.generateState();

    final code = await datasource.authenticate(
      codeChallenge: codeChallenge,
      state: state,
    );

    checkUser();
    final tokenModel = await datasource.exchangeCode(
      code: code,
      codeVerifier: codeVerifier,
      vibraAccessToken: originalSession.accessToken,
    );

    checkUser();

    // Salva i token localmente in modo sicuro
    await tokenStorage.saveAccessToken(tokenModel.accessToken);
    await tokenStorage.saveRefreshToken(tokenModel.refreshToken);
    if (datasource.supabaseClient.auth.currentUser?.id !=
        originalSession.user.id) {
      await tokenStorage.clear();
      throw StateError('Account cambiato durante il collegamento. Riprova.');
    }

    return tokenModel;
  }

  @override
  Future<SpotifySession> refreshSession() async {
    final originalSession = datasource.supabaseClient.auth.currentSession;
    if (originalSession == null) {
      throw StateError('Accedi prima di rinnovare Spotify.');
    }
    void checkUser() {
      if (datasource.supabaseClient.auth.currentUser?.id !=
          originalSession.user.id) {
        throw StateError('Account cambiato durante il rinnovo Spotify.');
      }
    }

    final oldRefreshToken = await tokenStorage.readRefreshToken();
    checkUser();
    if (oldRefreshToken == null) {
      throw Exception('Nessun refresh token disponibile per Spotify');
    }

    final tokenModel = await datasource.refreshSession(
      refreshToken: oldRefreshToken,
      vibraAccessToken: originalSession.accessToken,
    );
    checkUser();

    await tokenStorage.saveAccessToken(tokenModel.accessToken);
    if (tokenModel.refreshToken.isNotEmpty) {
      await tokenStorage.saveRefreshToken(tokenModel.refreshToken);
    }

    if (datasource.supabaseClient.auth.currentUser?.id !=
        originalSession.user.id) {
      await tokenStorage.clear();
      throw StateError('Account cambiato durante il rinnovo Spotify.');
    }
    return tokenModel;
  }
}
