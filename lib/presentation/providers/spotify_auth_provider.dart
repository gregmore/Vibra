import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../core/services/cache_service.dart';
import 'app_state_providers.dart';
import 'core_providers.dart';
import '../../core/errors/exceptions.dart';

enum SpotifyAuthStatus {
  idle,
  authorizing,
  exchangingToken,
  syncingProfile,
  success,
  error,
  userCancelled,
}

class SpotifyAuthStatusState {
  final SpotifyAuthStatus status;
  final String? errorMessage;

  const SpotifyAuthStatusState({required this.status, this.errorMessage});

  const SpotifyAuthStatusState.idle()
    : status = SpotifyAuthStatus.idle,
      errorMessage = null;
  const SpotifyAuthStatusState.authorizing()
    : status = SpotifyAuthStatus.authorizing,
      errorMessage = null;
  const SpotifyAuthStatusState.exchangingToken()
    : status = SpotifyAuthStatus.exchangingToken,
      errorMessage = null;
  const SpotifyAuthStatusState.syncingProfile()
    : status = SpotifyAuthStatus.syncingProfile,
      errorMessage = null;
  const SpotifyAuthStatusState.success()
    : status = SpotifyAuthStatus.success,
      errorMessage = null;
  const SpotifyAuthStatusState.userCancelled()
    : status = SpotifyAuthStatus.userCancelled,
      errorMessage = null;
  const SpotifyAuthStatusState.error(String message)
    : status = SpotifyAuthStatus.error,
      errorMessage = message;
}

class SpotifyAuthNotifier extends StateNotifier<SpotifyAuthStatusState> {
  final Ref _ref;

  SpotifyAuthNotifier(this._ref) : super(const SpotifyAuthStatusState.idle());

  Future<void> connectSpotify() async {
    try {
      state = const SpotifyAuthStatusState.authorizing();
      VibraLogger.info('Stato: authorizing...');

      final repository = _ref.read(spotifyAuthRepositoryProvider);
      final datasource = _ref.read(spotifyAuthDatasourceProvider);

      await repository.connectAccount();

      state = const SpotifyAuthStatusState.exchangingToken();
      VibraLogger.info('Stato: exchangingToken...');

      state = const SpotifyAuthStatusState.syncingProfile();
      VibraLogger.info('Stato: syncingProfile...');

      await datasource.syncMusicProfile();

      _ref.invalidate(myProfileProvider);
      _ref.invalidate(myMusicProfileProvider);

      state = const SpotifyAuthStatusState.success();
      VibraLogger.info('Stato: success!');
    } catch (e) {
      String errorMessage = e.toString();
      if (e is ServerException) {
        errorMessage = e.message;
      } else if (e is AuthException) {
        errorMessage = e.message;
      }

      VibraLogger.error('Errore durante la connessione Spotify', error: e);

      final isCancellation =
          errorMessage.toLowerCase().contains('cancel') ||
          errorMessage.toLowerCase().contains('annull') ||
          errorMessage.toLowerCase().contains('dismiss');

      if (isCancellation) {
        state = const SpotifyAuthStatusState.userCancelled();
      } else {
        state = SpotifyAuthStatusState.error(errorMessage);
        await _logErrorToDatabase(errorMessage);
      }
    }
  }

  Future<void> syncSpotify() async {
    try {
      state = const SpotifyAuthStatusState.syncingProfile();
      VibraLogger.info('Stato: syncingProfile...');

      final datasource = _ref.read(spotifyAuthDatasourceProvider);
      await datasource.syncMusicProfile();

      // Clear cache to prevent falling back to stale data if parsing fails
      await CacheService.remove(CacheService.keyMusicProfile);

      _ref.invalidate(myMusicProfileProvider);

      state = const SpotifyAuthStatusState.success();
      VibraLogger.info('Stato: sync success!');
    } catch (e) {
      final errorMessage = e.toString();
      VibraLogger.error('Errore durante la sincronizzazione Spotify', error: e);
      state = SpotifyAuthStatusState.error(errorMessage);
    }
  }

  Future<void> _logErrorToDatabase(String message) async {
    try {
      final supabase = _ref.read(supabaseDatasourceProvider);
      if (!supabase.isAuthenticated) return;
      await supabase.client.from('auth_errors_log').insert({
        'user_id': supabase.currentUser?.id,
        'error_code': 'SPOTIFY_AUTH_FAILURE',
        'error_message': message,
        'metadata': {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': 'mobile',
        },
      });
      VibraLogger.info('Errore di autenticazione registrato nel database');
    } catch (dbErr) {
      VibraLogger.warning(
        'Log errore auth non persistito: $dbErr',
        tag: 'SpotifyAuth',
      );
    }
  }

  Future<void> disconnectSpotify() async {
    try {
      state = const SpotifyAuthStatusState.authorizing();
      VibraLogger.info('Scollegamento di Spotify in corso...');

      final supabase = _ref.read(supabaseDatasourceProvider);
      final currentUser = supabase.currentUser;
      if (currentUser == null) return;

      await supabase.client
          .from('users')
          .update({
            'spotify_id': null,
            'spotify_access_token': null,
            'spotify_refresh_token': null,
          })
          .eq('id', currentUser.id);

      await supabase.client
          .from('music_profiles')
          .delete()
          .eq('user_id', currentUser.id);

      await _ref.read(spotifyTokenStorageProvider).clear();

      _ref.invalidate(myProfileProvider);
      _ref.invalidate(myMusicProfileProvider);

      state = const SpotifyAuthStatusState.idle();
      VibraLogger.info('Spotify scollegato con successo');
    } catch (e) {
      VibraLogger.error('Errore durante lo scollegamento di Spotify', error: e);
      state = SpotifyAuthStatusState.error(e.toString());
    }
  }

  void reset() {
    state = const SpotifyAuthStatusState.idle();
  }
}

final spotifyAuthProvider =
    StateNotifierProvider<SpotifyAuthNotifier, SpotifyAuthStatusState>((ref) {
      return SpotifyAuthNotifier(ref);
    });
