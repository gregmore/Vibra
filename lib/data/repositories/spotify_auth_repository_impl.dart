import '../../domain/entities/spotify_session.dart';
import '../../domain/repositories/spotify_auth_repository.dart';
import '../datasources/spotify_auth_datasource.dart';
import '../../core/services/spotify_token_storage.dart';

class SpotifyAuthRepositoryImpl implements SpotifyAuthRepository {
  final SpotifyAuthDatasource datasource;

  /// Only used to erase Spotify tokens that older app versions kept on the
  /// device. New connections never store Spotify credentials locally.
  final SpotifyTokenStorage tokenStorage;

  SpotifyAuthRepositoryImpl({
    required this.datasource,
    required this.tokenStorage,
  });

  @override
  Future<SpotifySession> connectAccount({void Function()? onAuthorized}) async {
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
    onAuthorized?.call();

    final session = await datasource.exchangeCode(
      code: code,
      codeVerifier: codeVerifier,
      vibraAccessToken: originalSession.accessToken,
    );
    checkUser();

    // Remove credentials an earlier app version may have kept on the device.
    await tokenStorage.clear();
    return session;
  }
}
