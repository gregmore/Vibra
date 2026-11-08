import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/services/cache_service.dart';
import 'app_state_providers.dart';
import 'app_synchronization_provider.dart';
import 'core_providers.dart';
import '../../core/errors/exceptions.dart';

enum SpotifyAuthStatus {
  idle,

  /// Spotify consent screen is open.
  authorizing,

  /// Consent granted; the server is exchanging the PKCE code.
  exchangingToken,

  /// Connected; the first (or a manual) data sync is running.
  syncingProfile,

  /// Connected and data synced: statistics are populated.
  success,

  /// Connected, but the data sync failed. Retry syncs, not reconnects.
  syncFailed,

  /// Spotify access was revoked or the connection is gone: show "Connect".
  disconnected,
  error,
  userCancelled,
}

/// Backend error codes surfaced to the UI.
abstract final class SpotifyErrorCodes {
  static const notConnected = 'spotify_not_connected';
  static const rateLimited = 'spotify_rate_limited';
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
  const SpotifyAuthStatusState.syncFailed(String message)
    : status = SpotifyAuthStatus.syncFailed,
      errorMessage = message;
  const SpotifyAuthStatusState.disconnected()
    : status = SpotifyAuthStatus.disconnected,
      errorMessage = SpotifyErrorCodes.notConnected;

  bool get isBusy =>
      status == SpotifyAuthStatus.authorizing ||
      status == SpotifyAuthStatus.exchangingToken ||
      status == SpotifyAuthStatus.syncingProfile;
}

class SpotifyAuthNotifier extends StateNotifier<SpotifyAuthStatusState> {
  final Ref _ref;

  SpotifyAuthNotifier(this._ref) : super(const SpotifyAuthStatusState.idle());

  Future<void> connectSpotify() async {
    if (!AppConstants.spotifyEnabled) {
      state = const SpotifyAuthStatusState.error(
        'spotify_temporarily_unavailable',
      );
      return;
    }
    if (state.isBusy) return;
    var connected = false;
    try {
      state = const SpotifyAuthStatusState.authorizing();
      final repository = _ref.read(spotifyAuthRepositoryProvider);
      await repository.connectAccount(
        onAuthorized: () {
          if (mounted) state = const SpotifyAuthStatusState.exchangingToken();
        },
      );
      connected = true;
      // "Connected" is only shown once the first sync has populated the
      // statistics, so the profile never looks connected-but-empty.
      await _refreshProfileState();
      await _runSync();
    } catch (e) {
      final errorMessage = _messageOf(e);
      VibraLogger.error('Errore durante la connessione Spotify', error: e);
      if (connected) {
        state = _isNotConnected(errorMessage)
            ? const SpotifyAuthStatusState.disconnected()
            : SpotifyAuthStatusState.syncFailed(errorMessage);
        return;
      }
      final lower = errorMessage.toLowerCase();
      final isCancellation =
          lower.contains('cancel') ||
          lower.contains('annull') ||
          lower.contains('dismiss');
      if (isCancellation) {
        state = const SpotifyAuthStatusState.userCancelled();
      } else {
        state = SpotifyAuthStatusState.error(errorMessage);
        await _logErrorToDatabase(errorMessage);
      }
    }
  }

  /// Manual or retry sync. Server-side, an hourly job keeps data fresh too.
  Future<void> syncSpotify() async {
    if (!AppConstants.spotifyEnabled) {
      state = const SpotifyAuthStatusState.error(
        'spotify_temporarily_unavailable',
      );
      return;
    }
    if (state.isBusy) return;
    try {
      await _runSync();
    } catch (e) {
      final errorMessage = _messageOf(e);
      VibraLogger.error('Errore durante la sincronizzazione Spotify', error: e);
      if (_isNotConnected(errorMessage)) {
        state = const SpotifyAuthStatusState.disconnected();
        return;
      }
      // Una sincronizzazione remota fallita non deve nascondere l'ultimo
      // profilo valido già persistito nel database.
      try {
        await _ref.read(myMusicProfileProvider.notifier).refresh();
      } catch (_) {
        // Lo stato d'errore originale resta quello rilevante per l'utente.
      }
      state = SpotifyAuthStatusState.error(errorMessage);
    }
  }

  Future<void> _runSync() async {
    state = const SpotifyAuthStatusState.syncingProfile();
    final user = _ref.read(supabaseDatasourceProvider).currentUser;
    try {
      await _ref.read(spotifyAuthDatasourceProvider).syncMusicProfile();
    } catch (e) {
      if (_isNotConnected(_messageOf(e))) {
        // Revoked from Spotify (or disconnected elsewhere): the server has
        // already removed the connection and its data. Reflect it locally.
        await _clearLocalMusicData(user?.id);
        await _refreshProfileState();
      }
      rethrow;
    }
    // Clear cache to prevent falling back to stale data if parsing fails
    if (user != null) {
      await CacheService.remove(CacheService.musicProfileKey(user.id));
    }
    await _ref.read(myMusicProfileProvider.notifier).refresh();
    state = const SpotifyAuthStatusState.success();
  }

  Future<void> _refreshProfileState() async {
    try {
      await _ref.read(appSynchronizationProvider).refreshProfile();
    } catch (e) {
      VibraLogger.warning('Profilo non aggiornato: $e', tag: 'SpotifyAuth');
    }
  }

  Future<void> _clearLocalMusicData(String? userId) async {
    await _ref.read(spotifyTokenStorageProvider).clear();
    if (userId != null) {
      await CacheService.remove(CacheService.musicProfileKey(userId));
    }
    try {
      await _ref.read(myMusicProfileProvider.notifier).refresh();
    } catch (_) {
      // A missing profile after disconnect is the expected state.
    }
  }

  static String _messageOf(Object e) {
    if (e is ServerException) return e.message;
    if (e is AuthException) return e.message;
    return e.toString();
  }

  static bool _isNotConnected(String message) =>
      message.contains(SpotifyErrorCodes.notConnected);

  Future<void> _logErrorToDatabase(String message) async {
    try {
      final supabase = _ref.read(supabaseDatasourceProvider);
      if (!supabase.isAuthenticated) return;
      final redacted = VibraLogger.redact(message);
      await supabase.client.from('auth_errors_log').insert({
        'user_id': supabase.currentUser?.id,
        'error_code': 'SPOTIFY_AUTH_FAILURE',
        'error_message': redacted.substring(
          0,
          redacted.length > 2000 ? 2000 : redacted.length,
        ),
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

  /// Disconnects Spotify. The server deletes the encrypted tokens, music
  /// profile, listening history and matches in one transaction; the app then
  /// clears its local caches so no residual data stays on the device.
  Future<void> disconnectSpotify() async {
    final supabase = _ref.read(supabaseDatasourceProvider);
    final currentUser = supabase.currentUser;
    if (currentUser == null) return;
    try {
      state = const SpotifyAuthStatusState.syncingProfile();
      await _ref.read(spotifyAuthDatasourceProvider).disconnect();
      await _clearLocalMusicData(currentUser.id);
      await _refreshProfileState();
      state = const SpotifyAuthStatusState.idle();
      VibraLogger.info('Spotify scollegato con successo');
    } catch (e) {
      VibraLogger.error('Errore durante lo scollegamento di Spotify', error: e);
      state = SpotifyAuthStatusState.error(_messageOf(e));
      rethrow;
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
