import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/db_tables.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import 'app_state_providers.dart';
import 'core_providers.dart';
import 'map_events_provider.dart';
import 'public_users_provider.dart';
import 'public_friends_provider.dart';
import 'direct_message_permission_provider.dart';

/// Ponte unico tra la cache Riverpod e i cambiamenti esterni all'albero widget.
/// Le schermate leggono i provider di dominio; Realtime, reconnect e foreground
/// aggiornano esattamente gli stessi provider.
class AppSynchronizationController {
  AppSynchronizationController(this.ref) {
    _authSubscription = ref
        .read(supabaseDatasourceProvider)
        .client
        .auth
        .onAuthStateChange
        .listen((_) {
          _restartRealtime();
          unawaited(refreshAll());
        });
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final online = results.any((result) => result != ConnectivityResult.none);
      if (online && !_wasOnline) unawaited(refreshAll());
      _wasOnline = online;
    });
    _restartRealtime();
    ref.onDispose(dispose);
  }

  final Ref ref;
  final List<RealtimeChannel> _channels = [];
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _eventsDebounce;
  Timer? _socialDebounce;
  Timer? _profileDebounce;
  bool _wasOnline = true;

  void _restartRealtime() {
    for (final channel in _channels) {
      unawaited(channel.unsubscribe());
    }
    _channels.clear();

    final client = ref.read(supabaseDatasourceProvider).client;
    _channels.add(
      client
          .channel('vibra-cache-events')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.events,
            callback: (_) => _debounceEvents(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.eventAttendees,
            callback: (_) => _debounceEvents(),
          )
          .subscribe(),
    );
    _channels.add(
      client
          .channel('vibra-cache-social')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.friendships,
            callback: (_) => _debounceSocial(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.userMatches,
            callback: (_) => _debounceSocial(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.messages,
            callback: (_) => _debounceSocial(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.notifications,
            callback: (_) => _debounceSocial(),
          )
          .subscribe(),
    );
    _channels.add(
      client
          .channel('vibra-cache-profile')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.users,
            callback: (_) => _debounceProfile(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DbTables.musicProfiles,
            callback: (_) => _debounceProfile(),
          )
          .subscribe(),
    );
  }

  void _debounceEvents() {
    _eventsDebounce?.cancel();
    _eventsDebounce = Timer(
      const Duration(milliseconds: 120),
      () => unawaited(refreshEvents()),
    );
  }

  void _debounceSocial() {
    _socialDebounce?.cancel();
    _socialDebounce = Timer(
      const Duration(milliseconds: 120),
      () => unawaited(refreshSocial()),
    );
  }

  void _debounceProfile() {
    _profileDebounce?.cancel();
    _profileDebounce = Timer(
      const Duration(milliseconds: 120),
      () => unawaited(refreshProfile()),
    );
  }

  Future<void> refreshEvents() async {
    await Future.wait([
      ref.read(allEventsProvider.notifier).refresh(),
      ref.read(myEventsProvider.notifier).refresh(),
      ref.read(mapEventsProvider.notifier).refresh(),
    ]);
  }

  Future<void> refreshSocial() async {
    ref.invalidate(publicUsersProvider);
    ref.invalidate(publicConnectionProfilesProvider);
    ref.invalidate(publicFriendsProvider);
    ref.invalidate(directMessagePermissionProvider);
    await Future.wait([
      ref.read(matchedUsersProvider.notifier).refresh(),
      ref.read(pendingFriendshipsProvider.notifier).refresh(),
      ref.read(conversationsProvider.notifier).refresh(),
      ref.read(notificationsProvider.notifier).refresh(),
    ]);
    ref.invalidate(userProfileDetailProvider);
  }

  Future<void> refreshProfile() async {
    await Future.wait([
      ref.read(myProfileProvider.notifier).refresh(),
      ref.read(myMusicProfileProvider.notifier).refresh(),
    ]);
    ref.invalidate(userProfileDetailProvider);
  }

  Future<void> refreshAll() async {
    try {
      await Future.wait([refreshEvents(), refreshSocial(), refreshProfile()]);
    } catch (error, stackTrace) {
      VibraLogger.error(
        'Shared cache refresh failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Applica la mutazione alla cache condivisa, poi riconcilia in background.
  void eventAttendanceChanged(Event event, String status) {
    ref.read(myEventsProvider.notifier).applyAttendance(event, status);
    unawaited(refreshEvents());
  }

  void onAppResumed() => unawaited(refreshAll());

  void dispose() {
    _eventsDebounce?.cancel();
    _socialDebounce?.cancel();
    _profileDebounce?.cancel();
    unawaited(_authSubscription?.cancel());
    unawaited(_connectivitySubscription?.cancel());
    for (final channel in _channels) {
      unawaited(channel.unsubscribe());
    }
    _channels.clear();
  }
}

final appSynchronizationProvider = Provider<AppSynchronizationController>((
  ref,
) {
  return AppSynchronizationController(ref);
});
