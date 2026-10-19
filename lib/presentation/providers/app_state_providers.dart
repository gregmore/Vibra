import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/push_notifications_bootstrap.dart';
import '../../core/config/push_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/db_tables.dart';
import '../../core/errors/exceptions.dart' as app_errors;
import '../../core/services/cache_service.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/conversation_summary.dart';
import '../../domain/entities/direct_message.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/follow_stats.dart';
import '../../domain/entities/friendship.dart';
import '../../domain/entities/live_message.dart';
import '../../domain/entities/music_profile.dart';
import '../../domain/entities/matched_user_preview.dart';
import '../../domain/entities/music_stat_point.dart';
import '../../domain/entities/settings_option.dart';
import '../../domain/usecases/calculate_user_compatibility_usecase.dart';
import '../../domain/usecases/events_usecases.dart';
import '../../domain/usecases/social_usecases.dart';
import '../../domain/usecases/usecase.dart';
import '../../data/mappers/domain_mappers.dart';
import '../../data/models/event_model.dart';
import '../../data/models/user_model.dart';
import 'core_providers.dart';
import 'usecase_providers.dart';
import 'auth_provider.dart';
import 'public_friends_provider.dart';

export '../../domain/entities/conversation_summary.dart';
export '../../domain/entities/follow_stats.dart';
export '../../domain/entities/matched_user_preview.dart';
export '../../domain/entities/music_stat_point.dart';
export '../../domain/entities/settings_option.dart';

final eventsFeedStatusProvider = StateProvider<AsyncValue<void>>(
  (ref) => const AsyncData(null),
);

final conversationsStatusProvider = StateProvider<AsyncValue<void>>(
  (ref) => const AsyncData(null),
);

class EventsFeedController extends StateNotifier<List<Event>> {
  EventsFeedController(this.ref) : super(const []) {
    try {
      final cached = CacheService.getList(CacheService.keyEvents);
      if (cached != null) {
        state = _filterPastEvents(
          cached.map((row) => EventModel.fromJson(row).toEntity()).toList(),
        );
      }
    } catch (_) {
      // A stale cache must not prevent a fresh fetch.
    }
    Future.microtask(refresh);
    _startPolling();
  }

  final Ref ref;
  Timer? _timer;
  Future<void>? _inFlight;

  Future<void> refresh() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  void _startPolling() {
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      refresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    ref.read(eventsFeedStatusProvider.notifier).state = const AsyncLoading();
    try {
      var loaded = await ref.read(getStoredEventsUseCaseProvider).call(50);
      if (!mounted) return;
      state = _filterPastEvents(loaded);

      if (loaded.length < 15) {
        final externalEvents = await ref
            .read(searchNearbyEventsUseCaseProvider)
            .call(
              const SearchNearbyEventsParams(
                latitude: 45.4642,
                longitude: 9.19,
                radiusKm: 50,
              ),
            )
            .catchError((Object error) {
              VibraLogger.warning('Eventi esterni non disponibili: $error');
              return <Event>[];
            });
        if (!mounted) return;
        loaded = _mergeEvents(loaded, externalEvents);
        state = _filterPastEvents(loaded);
      }

      final user = ref.read(supabaseDatasourceProvider).currentUser;
      if (user != null && AppConstants.spotifyEnabled) {
        try {
          final response = await ref
              .read(supabaseDatasourceProvider)
              .invokeFunction(
                'recommend-events',
                body: {
                  'user_id': user.id,
                  'limit': 20,
                  'latitude': 45.4642,
                  'longitude': 9.19,
                },
              );

          final items = List<Map<String, dynamic>>.from(
            response['data'] as List? ?? const [],
          );

          final recommended = items
              .map(
                (item) => EventModel.fromJson(
                  Map<String, dynamic>.from(item['event'] as Map),
                ).toEntity(),
              )
              .toList(growable: false);

          if (!mounted) return;
          if (recommended.isNotEmpty) {
            state = _filterPastEvents(_mergeEvents(recommended, loaded));
            return;
          }
        } catch (e) {
          if (e.toString().contains('music_profile_not_found')) {
            VibraLogger.info(
              'Profilo Spotify non sincronizzato. Mostro solo eventi generici.',
            );
          } else {
            VibraLogger.error('Failed to load recommended events', error: e);
          }
          // fallback to DB/external events
        }
      }

      if (mounted && loaded.isNotEmpty) {
        state = _filterPastEvents(loaded);
      }
    } catch (e, stack) {
      VibraLogger.error('Failed to load events', error: e);
      if (mounted) {
        ref.read(eventsFeedStatusProvider.notifier).state = AsyncError(
          e,
          stack,
        );
      }
    } finally {
      if (mounted && ref.read(eventsFeedStatusProvider).isLoading) {
        ref.read(eventsFeedStatusProvider.notifier).state = const AsyncData(
          null,
        );
      }
    }
  }

  List<Event> _filterPastEvents(List<Event> events) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return events
        .where((e) => !e.eventDate.isBefore(startOfDay))
        .toList(growable: false);
  }
}

class ProfileController extends StateNotifier<AppUser> {
  ProfileController(this.ref)
    : super(
        AppUser(
          id: '',
          email: '',
          username: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ) {
    Future.microtask(_load);
  }

  final Ref ref;
  int _loadVersion = 0;

  Future<void> refresh() => _load();

  Future<void> _load() async {
    if (!mounted) return;
    final version = ++_loadVersion;
    try {
      final supabase = ref.read(supabaseDatasourceProvider);
      final authUser = supabase.currentUser;
      if (authUser == null) return;
      bool active() =>
          mounted &&
          version == _loadVersion &&
          supabase.currentUser?.id == authUser.id;
      try {
        final loaded = await ref
            .read(getMyProfileUseCaseProvider)
            .call(const NoParams());
        if (active() && loaded.id == authUser.id) {
          state = loaded;
          await CacheService.saveObject(
            'CACHE_USER_PROFILE_${authUser.id}',
            loaded.toModel().toJson(),
          );
        }
      } catch (error) {
        if (!active()) return;
        // A temporary network error must not overwrite profile data or sign out
        // someone whose existing session remains valid.
        if (error is! app_errors.ServerException ||
            error.message != 'Profilo utente non trovato') {
          VibraLogger.error('Impossibile aggiornare il profilo', error: error);
          return;
        }
        try {
          await supabase.client.auth.getUser();
        } catch (authError) {
          if (!active()) return;
          if (authError is AuthException &&
              authError is! AuthRetryableFetchException &&
              (authError.statusCode == '401' ||
                  authError.statusCode == '403')) {
            await ref.read(generalAuthProvider.notifier).signOut();
          }
          return;
        }
        if (!active()) return;
        final bootstrap = AppUser(
          id: authUser.id,
          email: authUser.email ?? '',
          username:
              (authUser.userMetadata?['username'] as String?) ??
              (authUser.email?.split('@').first ?? 'vibra_user'),
          displayName:
              (authUser.userMetadata?['display_name'] as String?) ??
              authUser.email?.split('@').first,
          avatarUrl: authUser.userMetadata?['avatar_url'] as String?,
          onboardingCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        try {
          final created = await ref
              .read(upsertMyProfileUseCaseProvider)
              .call(bootstrap);
          if (active()) {
            state = created;
            await CacheService.saveObject(
              'CACHE_USER_PROFILE_${authUser.id}',
              created.toModel().toJson(),
            );
          }
        } catch (error) {
          VibraLogger.error('Impossibile creare il profilo', error: error);
        }
      }
    } catch (error) {
      VibraLogger.error('Impossibile caricare il profilo', error: error);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    String? onboardingStep,
    bool? onboardingCompleted,
    String? avatarUrl,
  }) async {
    if (!mounted) throw StateError('Profilo non più disponibile.');
    final supabase = ref.read(supabaseDatasourceProvider);
    final user = supabase.currentUser;
    if (user == null) {
      throw StateError(
        'Sessione scaduta. Accedi di nuovo per salvare il profilo.',
      );
    }

    void requireSameAccount() {
      if (!mounted || supabase.currentUser?.id != user.id) {
        throw StateError(
          'La sessione è cambiata. Accedi di nuovo per salvare il profilo.',
        );
      }
    }

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (onboardingStep != null) updates['onboarding_step'] = onboardingStep;
    if (onboardingCompleted != null) {
      updates['onboarding_completed'] = onboardingCompleted;
    }

    if (avatarUrl != null) {
      if (avatarUrl.isEmpty) {
        updates['avatar_url'] = null;
      } else if (!avatarUrl.startsWith('http://') &&
          !avatarUrl.startsWith('https://')) {
        try {
          final fileBytes = await io.File(avatarUrl).readAsBytes();
          requireSameAccount();
          final ext = avatarUrl.split('.').last.toLowerCase();
          final mimeType = ext == 'png'
              ? 'image/png'
              : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
          final path = '${user.id}/$fileName';
          final url = await supabase.uploadFile(
            'avatars',
            path,
            fileBytes,
            contentType: mimeType,
            // Each avatar has a new path: INSERT needs no overwrite permissions.
            upsert: false,
          );
          requireSameAccount();
          updates['avatar_url'] = url;
        } catch (e) {
          VibraLogger.error('Failed to upload avatar', error: e);
          rethrow;
        }
      } else {
        updates['avatar_url'] = avatarUrl;
      }
    }

    if (updates.isNotEmpty) {
      requireSameAccount();
      updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
      final row = await supabase.client
          .from(DbTables.users)
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();
      requireSameAccount();
      _loadVersion++;
      final updated = UserModel.fromJson(row);
      state = updated.toEntity();
      await CacheService.saveObject(
        'CACHE_USER_PROFILE_${user.id}',
        updated.toJson(),
      );
    }
  }
}

class MusicProfileController extends StateNotifier<MusicProfile> {
  MusicProfileController(this.ref)
    : super(
        const MusicProfile(
          id: '',
          userId: '',
          topArtists: [],
          topTracks: [],
          topGenres: [],
        ),
      ) {
    Future.microtask(_load);
  }

  final Ref ref;

  Future<void> refresh() => _load();

  Future<void> _load() async {
    if (!AppConstants.spotifyEnabled) return;
    try {
      final music = await ref
          .read(getMyMusicProfileUseCaseProvider)
          .call(const NoParams());
      if (music != null) {
        state = music;
      } else {
        state = const MusicProfile(
          id: '',
          userId: '',
          topArtists: [],
          topTracks: [],
          topGenres: [],
        );
      }
    } catch (e) {
      VibraLogger.error('Failed to load music profile', error: e);
      // state remains empty/initial
    }
  }
}

class MatchedUsersController extends StateNotifier<List<MatchedUserPreview>> {
  MatchedUsersController(this.ref) : super(const []) {
    if (AppConstants.spotifyEnabled) {
      Future.microtask(_load);
      _subscribe();
    }
  }

  final Ref ref;
  RealtimeChannel? _channel;
  int _loadGeneration = 0;
  final Map<String, Future<void>> _sendingVibra = {};

  Future<void> refresh() => _load();

  void _subscribe() {
    final ds = ref.read(supabaseDatasourceProvider);
    _channel = ds.client
        .channel('public:user_matches')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_matches',
          callback: (payload) {
            _load();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> _load() async {
    if (!AppConstants.spotifyEnabled) return;
    final generation = ++_loadGeneration;
    try {
      final datasource = ref.read(supabaseSocialDatasourceProvider);
      final rows = await datasource.listMyMatches(limit: 20);

      final currentUserId = ref
          .read(supabaseDatasourceProvider)
          .currentUser
          ?.id;
      final ids = rows
          .map((row) {
            final a = row['user_id_a']?.toString();
            final b = row['user_id_b']?.toString();
            return a == currentUserId ? b : a;
          })
          .whereType<String>()
          .toSet()
          .toList(growable: false);

      final publicUsers = await datasource.getPublicUsersByIds(ids);
      final accepted = await datasource.listMyFriendships(status: 'accepted');
      final pending = await datasource.listMyFriendships(status: 'pending');
      final outgoingPendingIds = pending
          .where((request) => request.requesterId == currentUserId)
          .map((request) => request.receiverId)
          .toSet();
      final acceptedIds = accepted.map((f) {
        final me = currentUserId;
        return f.requesterId == me ? f.receiverId : f.requesterId;
      }).toSet();

      final userById = <String, Map<String, dynamic>>{
        for (final user in publicUsers) user['id'].toString(): user,
      };

      // ── Recupera profili musicali per arricchire le card ──────────
      final allIdsToFetch = [...ids];
      if (currentUserId != null && !allIdsToFetch.contains(currentUserId)) {
        allIdsToFetch.add(currentUserId);
      }
      final musicProfiles = await datasource.getMusicProfilesByUserIds(
        allIdsToFetch,
      );
      final musicProfileByUserId = <String, Map<String, dynamic>>{
        for (final mp in musicProfiles) mp['user_id'].toString(): mp,
      };

      // Il mio profilo musicale (per calcolo compatibilità con dettagli)
      final myMusicRaw = currentUserId != null
          ? musicProfileByUserId[currentUserId]
          : null;
      final myMusicProfile = myMusicRaw != null
          ? _parseMusicProfile(currentUserId!, myMusicRaw)
          : null;

      final useCase = const CalculateUserCompatibilityUseCase();

      if (!mounted || generation != _loadGeneration) return;
      state = rows
          .where((row) {
            final otherId = row['user_id_a'] == currentUserId
                ? row['user_id_b'].toString()
                : row['user_id_a'].toString();
            return !outgoingPendingIds.contains(otherId);
          })
          .map((row) {
            final otherId = row['user_id_a'] == currentUserId
                ? row['user_id_b'].toString()
                : row['user_id_a'].toString();
            final user = userById[otherId];

            final appUser = AppUser(
              id: otherId,
              email: '',
              username: user?['username']?.toString() ?? 'user',
              displayName: user?['display_name']?.toString(),
              avatarUrl: user?['avatar_url']?.toString(),
              bio: user?['bio']?.toString(),
              spotifyId: user?['spotify_id']?.toString(),
              createdAt: user?['created_at'] != null
                  ? DateTime.tryParse(user!['created_at'].toString())
                  : null,
              updatedAt: user?['updated_at'] != null
                  ? DateTime.tryParse(user!['updated_at'].toString())
                  : null,
            );

            // ── Calcola artisti/generi condivisi tramite il nuovo algoritmo ──
            List<String> sharedArtistNames = const [];
            final otherMusicRaw = musicProfileByUserId[otherId];
            if (myMusicProfile != null && otherMusicRaw != null) {
              final otherProfile = _parseMusicProfile(otherId, otherMusicRaw);
              final result = useCase.call(
                left: myMusicProfile,
                right: otherProfile,
              );
              sharedArtistNames = result.sharedArtistNames.take(5).toList();
            }

            return MatchedUserPreview(
              user: appUser,
              compatibility: (row['compatibility'] as num?)?.round() ?? 0,
              topArtists: sharedArtistNames,
              city: user?['city']?.toString() ?? 'Live nearby',
              attendingEvents: 0,
              isFriend: acceptedIds.contains(otherId),
            );
          })
          .toList(growable: false);
    } catch (e) {
      VibraLogger.error('Failed to load matched users', error: e);
      // state remains empty
    }
  }

  /// Converte i dati raw JSONB di un music_profile nella entity domain.
  MusicProfile _parseMusicProfile(String userId, Map<String, dynamic> raw) {
    final topArtistsRaw = raw['top_artists'] as List<dynamic>? ?? [];
    final topGenresRaw = raw['top_genres'] as List<dynamic>? ?? [];

    return MusicProfile(
      id: '',
      userId: userId,
      topArtists: topArtistsRaw
          .map(
            (a) => MusicArtistPreference(
              id: a['id']?.toString() ?? '',
              name: a['name']?.toString() ?? '',
              score: (a['score'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(growable: false),
      topTracks: const [],
      topGenres: topGenresRaw
          .map(
            (g) => GenrePreference(
              genre: g['genre']?.toString() ?? '',
              weight: (g['weight'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }

  void passMatch(String userId) {
    state = state.where((m) => m.user.id != userId).toList(growable: false);
  }

  Future<void> sendVibra(String userId) {
    return _sendingVibra[userId] ??= _sendVibraRequest(userId).whenComplete(() {
      _sendingVibra.remove(userId);
    });
  }

  Future<void> _sendVibraRequest(String userId) async {
    await ref.read(requestFriendshipUseCaseProvider).call(userId);
    if (!mounted) return;
    // A feed request started before this mutation must not restore the old card.
    _loadGeneration++;
    state = state
        .where((match) => match.user.id != userId)
        .toList(growable: false);
  }
}

class PendingFriendshipsController extends StateNotifier<List<Friendship>> {
  PendingFriendshipsController(this.ref) : super(const []) {
    Future.microtask(_load);
    _subscribe();
  }

  final Ref ref;
  RealtimeChannel? _channel;
  int _loadGeneration = 0;

  Future<void> refresh() => _load();

  void _subscribe() {
    final ds = ref.read(supabaseDatasourceProvider);
    _channel = ds.client
        .channel('public:friendships')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friendships',
          callback: (payload) {
            _load();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    try {
      final loaded = await ref
          .read(listFriendshipsUseCaseProvider)
          .call('pending');
      if (mounted && generation == _loadGeneration) state = loaded;
    } catch (e) {
      VibraLogger.error('Failed to load pending friendships', error: e);
      // state remains empty
    }
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await ref
          .read(respondFriendshipUseCaseProvider)
          .call(
            RespondFriendshipParams(
              friendshipId: friendshipId,
              status: 'accepted',
            ),
          );
      await _load();
      if (!mounted) return;
      ref.invalidate(matchedUsersProvider);
      ref.invalidate(conversationsProvider);
    } catch (e) {
      VibraLogger.error('Failed to accept friend request', error: e);
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    try {
      await ref
          .read(respondFriendshipUseCaseProvider)
          .call(
            RespondFriendshipParams(
              friendshipId: friendshipId,
              status: 'rejected',
            ),
          );
      await _load();
      if (!mounted) return;
      ref.invalidate(matchedUsersProvider);
    } catch (e) {
      VibraLogger.error('Failed to reject friend request', error: e);
      rethrow;
    }
  }

  Future<void> cancelFriendRequest(String friendshipId) async {
    try {
      await ref.read(cancelFriendRequestUseCaseProvider).call(friendshipId);
      await _load();
      if (!mounted) return;
      ref.invalidate(matchedUsersProvider);
    } catch (e) {
      VibraLogger.error('Failed to cancel friend request', error: e);
      rethrow;
    }
  }

  Future<void> deleteFriendship(String friendshipId) async {
    try {
      await ref.read(deleteFriendshipUseCaseProvider).call(friendshipId);
      await _load();
      if (!mounted) return;
      ref.invalidate(matchedUsersProvider);
      ref.invalidate(conversationsProvider);
    } catch (e) {
      VibraLogger.error('Failed to delete friendship', error: e);
      rethrow;
    }
  }
}

class ConversationsController extends StateNotifier<List<ConversationSummary>> {
  ConversationsController(this.ref) : super(const []) {
    Future.microtask(refresh);
    _subscribe();
  }

  final Ref ref;
  RealtimeChannel? _channel;

  Future<void>? _inFlight;
  bool _reloadRequested = false;
  int _loadGeneration = 0;

  void _subscribe() {
    final ds = ref.read(supabaseDatasourceProvider);
    _channel = ds.client
        .channel('public:conversations_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            refresh();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> refresh() {
    _reloadRequested = true;
    return _inFlight ??= _drainReloads().whenComplete(() => _inFlight = null);
  }

  Future<void> _drainReloads() async {
    while (mounted && _reloadRequested) {
      _reloadRequested = false;
      await _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    if (mounted && state.isEmpty) {
      ref.read(conversationsStatusProvider.notifier).state =
          const AsyncLoading();
    }
    try {
      final list = await ref
          .read(listConversationsUseCaseProvider)
          .call(const NoParams());
      if (!mounted || generation != _loadGeneration) return;
      state = list;
      ref.read(conversationsStatusProvider.notifier).state = const AsyncData(
        null,
      );
    } catch (e, stackTrace) {
      if (mounted && generation == _loadGeneration) {
        ref.read(conversationsStatusProvider.notifier).state = AsyncError(
          e,
          stackTrace,
        );
      }
      VibraLogger.error('Failed to load conversations', error: e);
    }
  }
}

class UserFollowStatsController extends StateNotifier<FollowStats> {
  UserFollowStatsController(this.ref, this.userId)
    : super(const FollowStats.empty()) {
    if (userId.isNotEmpty) {
      Future.microtask(() => refresh().catchError((Object _) {}));
    }
  }

  final Ref ref;
  final String userId;
  Future<void>? _toggleInFlight;
  Future<void>? _loadInFlight;
  bool _statsLoaded = false;
  int _loadGeneration = 0;

  Future<void> refresh() =>
      _toggleInFlight ??
      (_loadInFlight ??= _load().whenComplete(() => _loadInFlight = null));

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    try {
      final stats = await ref.read(getFollowStatsUseCaseProvider).call(userId);
      if (mounted && generation == _loadGeneration) {
        state = stats;
        _statsLoaded = true;
      }
    } catch (e) {
      VibraLogger.error('Failed to load follow stats for $userId', error: e);
      rethrow;
    }
  }

  Future<void> toggleFollow() => _toggleInFlight ??= _toggleFollow()
      .whenComplete(() => _toggleInFlight = null);

  Future<void> _toggleFollow() async {
    // A failed or pending initial fetch cannot safely tell us whether to follow
    // or unfollow. Resolve it before changing the count.
    if (!_statsLoaded) await refresh();
    if (!mounted) return;
    final previous = state;
    final wasFollowing = previous.isFollowing;
    // A stale stats response must not overwrite the optimistic transition.
    _loadGeneration++;
    final newFollowing = !wasFollowing;
    final newCount = newFollowing
        ? state.followersCount + 1
        : (state.followersCount > 0 ? state.followersCount - 1 : 0);

    // Optimistic update
    state = state.copyWith(isFollowing: newFollowing, followersCount: newCount);

    try {
      if (newFollowing) {
        await ref.read(followUserUseCaseProvider).call(userId);
      } else {
        await ref.read(unfollowUserUseCaseProvider).call(userId);
      }
      if (!mounted) return;
      final me = ref.read(supabaseDatasourceProvider).currentUser;
      if (me != null) {
        ref.invalidate(userFollowStatsProvider(me.id));
      }
      // Repeated follows and concurrent activity may change the real count.
      // A stats refresh failing after a successful mutation is not a rollback.
      try {
        await _load();
      } catch (_) {}
    } catch (e) {
      VibraLogger.error('Failed to toggle follow for $userId', error: e);
      // Revert
      if (mounted) state = previous;
      rethrow;
    }
  }
}

class DirectMessagesController extends StateNotifier<List<DirectMessage>> {
  DirectMessagesController(this.ref) : super(const []);

  final Ref ref;
  StreamSubscription? _subscription;
  int _generation = 0;

  void loadConversation(String otherUserId) {
    final generation = ++_generation;
    _subscription?.cancel();
    state = const [];
    final ds = ref.read(supabaseSocialDatasourceProvider);
    _subscription = ds
        .streamMessagesWith(otherUserId: otherUserId)
        .listen(
          (models) {
            if (!mounted || generation != _generation) return;
            state = models.map((message) => message.toEntity()).toList();
          },
          onError: (e) {
            VibraLogger.error('Failed to stream direct messages', error: e);
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class UserEventsController
    extends StateNotifier<({List<Event> going, List<Event> saved})> {
  UserEventsController(this.ref) : super((going: const [], saved: const [])) {
    Future.microtask(_load);
  }

  final Ref ref;

  Future<void> refresh() => _load();

  /// Aggiorna subito la cache condivisa dopo una mutazione riuscita. Il
  /// successivo refresh dal server sostituirà l'evento esterno con la copia DB.
  void applyAttendance(Event event, String status) {
    bool sameEvent(Event candidate) =>
        candidate.id == event.id ||
        (candidate.source == event.source &&
            candidate.externalId == event.externalId);

    final going = state.going.where((item) => !sameEvent(item)).toList();
    final saved = state.saved.where((item) => !sameEvent(item)).toList();
    if (status == 'going') going.add(event);
    if (status == 'maybe') saved.add(event);
    going.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    saved.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    state = (going: going, saved: saved);
  }

  Future<void> _load() async {
    try {
      final currentUser = ref.read(supabaseDatasourceProvider).currentUser;
      if (currentUser == null) return;

      final attendeeRows = await ref
          .read(supabaseDatasourceProvider)
          .client
          .from(DbTables.eventAttendees)
          .select('event_id,status')
          .eq('user_id', currentUser.id)
          .neq('status', 'not_going');

      final goingIds = <String>[];
      final savedIds = <String>[];

      for (final row in attendeeRows) {
        final id = row['event_id']?.toString();
        final status = row['status']?.toString();
        if (id != null) {
          if (status == 'going') {
            goingIds.add(id);
          } else if (status == 'maybe') {
            savedIds.add(id);
          }
        }
      }

      final allIds = [...goingIds, ...savedIds];

      if (allIds.isEmpty) {
        state = (going: const [], saved: const []);
        return;
      }

      final eventRows = await ref
          .read(supabaseDatasourceProvider)
          .client
          .from(DbTables.events)
          .select()
          .inFilter('id', allIds)
          .order('event_date', ascending: true);

      final eventsList = List<Map<String, dynamic>>.from(eventRows)
          .map(EventModel.fromJson)
          .map((e) => e.toEntity())
          .toList(growable: false);

      final goingEvents = eventsList
          .where((e) => goingIds.contains(e.id))
          .toList(growable: false);
      final savedEvents = eventsList
          .where((e) => savedIds.contains(e.id))
          .toList(growable: false);

      state = (going: goingEvents, saved: savedEvents);
    } catch (e) {
      VibraLogger.error('Failed to load user events', error: e);
      state = (going: const [], saved: const []);
    }
  }
}

final allEventsProvider =
    StateNotifierProvider<EventsFeedController, List<Event>>((ref) {
      return EventsFeedController(ref);
    });

final featuredEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(allEventsProvider);
  return events.take(2).toList(growable: false);
});

final nearbyEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(allEventsProvider);
  if (events.length <= 2) return const [];
  return events.skip(2).take(3).toList(growable: false);
});

final trendingEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(allEventsProvider);
  if (events.length <= 5) return const [];
  return events.skip(5).take(10).toList(growable: false);
});

final matchedUsersProvider =
    StateNotifierProvider<MatchedUsersController, List<MatchedUserPreview>>((
      ref,
    ) {
      return MatchedUsersController(ref);
    });

final friendsProvider = Provider<List<MatchedUserPreview>>((ref) {
  if (!AppConstants.spotifyEnabled) {
    final friends = ref.watch(publicFriendsProvider);
    return friends.isLoading || friends.hasError
        ? const []
        : friends.valueOrNull ?? const [];
  }
  return ref
      .watch(matchedUsersProvider)
      .where((u) => u.isFriend)
      .toList(growable: false);
});

final pendingFriendshipsProvider =
    StateNotifierProvider<PendingFriendshipsController, List<Friendship>>((
      ref,
    ) {
      return PendingFriendshipsController(ref);
    });

final directMessagesProvider =
    StateNotifierProvider<DirectMessagesController, List<DirectMessage>>((ref) {
      return DirectMessagesController(ref);
    });

final conversationsProvider =
    StateNotifierProvider<ConversationsController, List<ConversationSummary>>((
      ref,
    ) {
      return ConversationsController(ref);
    });

final directConversationsProvider = Provider<List<ConversationSummary>>((ref) {
  return ref
      .watch(conversationsProvider)
      .where((c) => !c.isMessageRequest)
      .toList(growable: false);
});

final messageRequestsProvider = Provider<List<ConversationSummary>>((ref) {
  return ref
      .watch(conversationsProvider)
      .where((c) => c.isMessageRequest)
      .toList(growable: false);
});

final totalUnreadMessagesCountProvider = Provider<int>((ref) {
  final conversations = ref.watch(conversationsProvider);
  return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
});

class NotificationsController extends StateNotifier<List<AppNotification>> {
  NotificationsController(this.ref) : super(const []) {
    Future.microtask(_load);
  }

  final Ref ref;

  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      state = await ref.read(listNotificationsUseCaseProvider).call(100);
    } catch (e) {
      VibraLogger.error('Failed to load notifications', error: e);
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsController, List<AppNotification>>((
      ref,
    ) {
      return NotificationsController(ref);
    });

class GlobalBadgeCounts {
  const GlobalBadgeCounts({
    required this.pendingFriendships,
    required this.unreadMessages,
    required this.unreadNotifications,
  });

  final int pendingFriendships;
  final int unreadMessages;
  final int unreadNotifications;
}

/// Unica fonte per tutti i contatori mostrati nella navigazione e nelle pagine.
final globalBadgeCountsProvider = Provider<GlobalBadgeCounts>((ref) {
  final pending = ref.watch(pendingFriendshipsProvider).length;
  final unreadMessages = ref.watch(totalUnreadMessagesCountProvider);
  final unreadNotifications = ref
      .watch(notificationsProvider)
      .where((notification) => !notification.read)
      .length;
  return GlobalBadgeCounts(
    pendingFriendships: pending,
    unreadMessages: unreadMessages,
    unreadNotifications: unreadNotifications,
  );
});

final userFollowStatsProvider =
    StateNotifierProvider.family<
      UserFollowStatsController,
      FollowStats,
      String
    >((ref, userId) {
      return UserFollowStatsController(ref, userId);
    });

final userProfileDetailProvider =
    FutureProvider.family<MatchedUserPreview?, String>((ref, userId) async {
      if (userId.isEmpty) return null;

      // 1. Controlla prima la cache dei match
      final matches = ref.watch(matchedUsersProvider);
      final cachedMatch = matches.where((m) => m.user.id == userId).firstOrNull;
      if (cachedMatch != null) return cachedMatch;

      // 2. Se non presente in cache, carica il profilo da users_public
      try {
        final ds = ref.read(supabaseSocialDatasourceProvider);
        final coreDs = ref.read(supabaseDatasourceProvider);
        final userRow = await coreDs.client
            .from('users_public')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (userRow == null) return null;

        final appUser = AppUser(
          id: userRow['id']?.toString() ?? userId,
          email: '',
          username: userRow['username']?.toString() ?? 'user',
          displayName: userRow['display_name']?.toString(),
          avatarUrl: userRow['avatar_url']?.toString(),
          bio: userRow['bio']?.toString(),
          spotifyId: userRow['spotify_id']?.toString(),
        );

        // Carica artisti condivisi
        final musicProfiles = AppConstants.spotifyEnabled
            ? await ds.getMusicProfilesByUserIds([userId])
            : <Map<String, dynamic>>[];
        List<String> topArtists = const [];
        if (musicProfiles.isNotEmpty) {
          final topArtistsRaw =
              musicProfiles.first['top_artists'] as List<dynamic>? ?? [];
          topArtists = topArtistsRaw
              .map((a) => a['name']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }

        // Controlla stato amicizia
        final friendships = await ref
            .read(listFriendshipsUseCaseProvider)
            .call('accepted');
        final currentUserId = coreDs.currentUser?.id;
        final isFriend = friendships.any(
          (f) =>
              (f.requesterId == currentUserId && f.receiverId == userId) ||
              (f.receiverId == currentUserId && f.requesterId == userId),
        );

        return MatchedUserPreview(
          user: appUser,
          compatibility: 0,
          topArtists: topArtists,
          city: '',
          attendingEvents: 0,
          isFriend: isFriend,
        );
      } catch (e) {
        VibraLogger.error('Failed to load user profile for $userId', error: e);
        return null;
      }
    });

final liveMessagesProvider = StreamProvider.autoDispose
    .family<List<LiveMessage>, String>((ref, eventId) {
      return ref.watch(streamLiveMessagesUseCaseProvider).call(eventId);
    });

final myProfileProvider = StateNotifierProvider<ProfileController, AppUser>((
  ref,
) {
  return ProfileController(ref);
});

final myMusicProfileProvider =
    StateNotifierProvider<MusicProfileController, MusicProfile>((ref) {
      return MusicProfileController(ref);
    });

final topArtistsStatsProvider = Provider<List<MusicArtistPreference>>((ref) {
  final artists = ref.watch(myMusicProfileProvider).topArtists;
  return artists.take(5).toList();
});

final topGenresStatsProvider = Provider<List<GenrePreference>>((ref) {
  final genres = ref.watch(myMusicProfileProvider).topGenres;
  return genres.take(5).toList();
});

final listeningHeatmapProvider = Provider<List<MusicStatPoint>>((ref) {
  final profile = ref.watch(myMusicProfileProvider);
  // Se abbiamo dati reali da Spotify, li usiamo.
  if (profile.listeningHeatmap.isNotEmpty) {
    return profile.listeningHeatmap;
  }
  // Fallback: barre uniformi a zero (nessun dato disponibile).
  // Non usiamo valori casuali/fittizi per non ingannare l'utente.
  const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
  return days.map((d) => MusicStatPoint(label: d, value: 0.0)).toList();
});

final myEventsProvider =
    StateNotifierProvider<
      UserEventsController,
      ({List<Event> going, List<Event> saved})
    >((ref) {
      return UserEventsController(ref);
    });

final savedEventsProvider = Provider<List<Event>>((ref) {
  return ref.watch(myEventsProvider).saved;
});

final settingsStateProvider =
    StateNotifierProvider<SettingsController, List<SettingsOptionState>>((ref) {
      return SettingsController(ref);
    });

class SettingsController extends StateNotifier<List<SettingsOptionState>> {
  SettingsController(this.ref)
    : super(const [
        SettingsOptionState(
          label: 'Notifiche eventi compatibili',
          enabled: true,
        ),
        SettingsOptionState(
          label: 'Alert utenti con match alto',
          enabled: true,
        ),
        SettingsOptionState(
          label: 'Chat Live durante i concerti',
          enabled: true,
        ),
        SettingsOptionState(
          label: 'Richieste e messaggi privati',
          enabled: true,
        ),
      ]) {
    _load();
  }

  final Ref ref;

  // Mapping of UI index to JSON keys in Supabase push_settings
  final _settingsKeys = [
    'event_alert',
    'match',
    'live_chat',
    'chat',
    'retention',
  ];

  Future<void> _load() async {
    try {
      final supabase = ref.read(supabaseDatasourceProvider);
      final user = supabase.currentUser;
      if (user == null) return;

      final res = await supabase.client
          .from(DbTables.users)
          .select('push_settings')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null && res['push_settings'] != null) {
        final pushSettings = res['push_settings'] as Map<String, dynamic>;
        final updated = <SettingsOptionState>[];

        for (int i = 0; i < state.length; i++) {
          final key = _settingsKeys[i];
          final val = pushSettings[key] as bool? ?? state[i].enabled;
          updated.add(SettingsOptionState(label: state[i].label, enabled: val));
        }
        state = updated;
      }
    } catch (e) {
      VibraLogger.error('Failed to load settings from Supabase', error: e);
    }
  }

  void toggle(int index, bool value) {
    final updated = [...state];
    updated[index] = SettingsOptionState(
      label: state[index].label,
      enabled: value,
    );
    state = updated;
    _save(index, value);
  }

  Future<void> _save(int index, bool value) async {
    try {
      final supabase = ref.read(supabaseDatasourceProvider);
      final user = supabase.currentUser;
      if (user == null) return;

      final key = _settingsKeys[index];

      // Fetch current settings first to merge them
      final res = await supabase.client
          .from(DbTables.users)
          .select('push_settings')
          .eq('id', user.id)
          .maybeSingle();

      final currentSettings =
          (res?['push_settings'] as Map<String, dynamic>?) ?? {};
      currentSettings[key] = value;

      await supabase.client
          .from(DbTables.users)
          .update({'push_settings': currentSettings})
          .eq('id', user.id);
    } catch (e) {
      VibraLogger.error('Failed to save settings to Supabase', error: e);
    }
  }
}

final digestFrequencyProvider =
    StateNotifierProvider<DigestFrequencyController, String>((ref) {
      return DigestFrequencyController(ref);
    });

class DigestFrequencyController extends StateNotifier<String> {
  DigestFrequencyController(this.ref) : super('weekly') {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    try {
      final ds = ref.read(supabaseDatasourceProvider);
      final user = ds.currentUser;
      if (user == null) return;
      final row = await ds.client
          .from('notification_preferences')
          .select('digest_frequency')
          .eq('user_id', user.id)
          .maybeSingle();
      final value = row?['digest_frequency'] as String?;
      if (value == 'weekly' || value == 'monthly' || value == 'never') {
        state = value!;
      }
    } catch (e) {
      VibraLogger.error('Failed to load digest preference', error: e);
    }
  }

  Future<void> setFrequency(String value) async {
    if (!const {'weekly', 'monthly', 'never'}.contains(value)) {
      return;
    }
    final previous = state;
    state = value;
    try {
      final ds = ref.read(supabaseDatasourceProvider);
      final user = ds.currentUser;
      if (user == null) return;
      await ds.client.from('notification_preferences').upsert({
        'user_id': user.id,
        'digest_frequency': value,
      }, onConflict: 'user_id');
    } catch (e) {
      state = previous;
      VibraLogger.error('Failed to save digest preference', error: e);
    }
  }
}

List<Event> _mergeEvents(List<Event> recommended, List<Event> fallback) {
  final byTitle = <String, Event>{};

  for (final event in recommended) {
    byTitle[event.name.toLowerCase().trim()] = event;
  }

  for (final event in fallback) {
    byTitle.putIfAbsent(event.name.toLowerCase().trim(), () => event);
  }

  final merged = byTitle.values.toList();
  merged.sort((a, b) => a.eventDate.compareTo(b.eventDate));
  return merged;
}

class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _loadLocale();
  }

  static const _spKey = 'user_selected_locale';

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_spKey);
      if (code != null && code.isNotEmpty) {
        state = Locale(code);
      }
    } catch (e) {
      VibraLogger.error('Failed to load locale preference', error: e);
    }
  }

  Future<void> setLocale(String? languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (languageCode == null || languageCode.isEmpty) {
        await prefs.remove(_spKey);
        state = null; // system default
      } else {
        await prefs.setString(_spKey, languageCode);
        state = Locale(languageCode);
      }
    } catch (e) {
      VibraLogger.error('Failed to save locale preference', error: e);
    }
  }
}

final localeStateProvider = StateNotifierProvider<LocaleController, Locale?>((
  ref,
) {
  return LocaleController();
});

/// Explicit appearance preference. The system choice maps to ThemeMode.system,
/// so Flutter follows changes to the device setting while the app is open.
enum VibraThemePreference { dark, light, system }

class ThemePreferenceController extends StateNotifier<VibraThemePreference> {
  ThemePreferenceController(this.ref) : super(VibraThemePreference.system) {
    _load();
  }

  static const _storageKey = 'vibra_theme_preference';
  final Ref ref;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = _fromStorage(prefs.getString(_storageKey));

      // Remote sync is optional; local storage remains usable offline and
      // before the database migration is deployed.
      final datasource = ref.read(supabaseDatasourceProvider);
      final user = datasource.currentUser;
      if (user == null) return;
      final row = await datasource.client
          .from(DbTables.users)
          .select('theme_preference')
          .eq('id', user.id)
          .maybeSingle();
      final remoteValue = row?['theme_preference'] as String?;
      if (remoteValue != null) {
        state = _fromStorage(remoteValue);
        await prefs.setString(_storageKey, state.name);
      }
    } catch (e) {
      VibraLogger.info('Theme preference loaded locally only: $e');
    }
  }

  Future<void> setPreference(VibraThemePreference value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, value.name);
    } catch (e) {
      VibraLogger.error('Failed to persist theme preference', error: e);
    }
    try {
      final datasource = ref.read(supabaseDatasourceProvider);
      final user = datasource.currentUser;
      if (user != null) {
        await datasource.client
            .from(DbTables.users)
            .update({'theme_preference': value.name})
            .eq('id', user.id);
      }
    } catch (e) {
      VibraLogger.info('Theme preference will remain local: $e');
    }
  }

  VibraThemePreference _fromStorage(String? raw) => switch (raw) {
    'dark' => VibraThemePreference.dark,
    'light' => VibraThemePreference.light,
    _ => VibraThemePreference.system,
  };
}

final themePreferenceProvider =
    StateNotifierProvider<ThemePreferenceController, VibraThemePreference>(
      (ref) => ThemePreferenceController(ref),
    );

ThemeMode themeModeForPreference(VibraThemePreference preference) =>
    switch (preference) {
      VibraThemePreference.dark => ThemeMode.dark,
      VibraThemePreference.light => ThemeMode.light,
      VibraThemePreference.system => ThemeMode.system,
    };

class PushEnabledController extends StateNotifier<bool> {
  PushEnabledController(this.ref) : super(true) {
    _load();
  }

  final Ref ref;
  int _revision = 0;

  Future<void> _load() async {
    final revision = _revision;
    try {
      final supabase = ref.read(supabaseDatasourceProvider);
      final user = supabase.currentUser;
      if (user == null) return;
      final prefs = await SharedPreferences.getInstance();
      if (!mounted || revision != _revision) return;
      await PushPreferences.migrateLegacyOptOut(prefs, user.id, () async {
        await supabase.client
            .from(DbTables.users)
            .update({'push_enabled': false, 'fcm_token': null})
            .eq('id', user.id);
      });
      if (!mounted || revision != _revision) return;
      state = prefs.getBool(PushPreferences.key(user.id)) ?? true;
      final profile = await supabase.client
          .from(DbTables.users)
          .select('push_enabled')
          .eq('id', user.id)
          .maybeSingle();
      if (!mounted ||
          revision != _revision ||
          supabase.currentUser?.id != user.id ||
          profile == null) {
        return;
      }
      state = profile['push_enabled'] != false;
      await prefs.setBool(PushPreferences.key(user.id), state);
    } catch (e) {
      VibraLogger.error('Failed to load push_enabled preference', error: e);
    }
  }

  Future<void> toggle(bool value) async {
    _revision++;
    final previous = state;
    state = value;
    try {
      final supabase = ref.read(supabaseDatasourceProvider);
      final user = supabase.currentUser;
      if (user == null) return;
      await supabase.client
          .from(DbTables.users)
          .update({'push_enabled': value, if (!value) 'fcm_token': null})
          .eq('id', user.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PushPreferences.key(user.id), value);
      if (value) await PushNotificationsBootstrap.synchronizeToken();
    } catch (e) {
      if (mounted) state = previous;
      VibraLogger.error('Failed to toggle push_enabled', error: e);
    }
  }
}

final pushEnabledProvider = StateNotifierProvider<PushEnabledController, bool>((
  ref,
) {
  return PushEnabledController(ref);
});

class PresenceController extends StateNotifier<Map<String, String>>
    with WidgetsBindingObserver {
  PresenceController(this.ref) : super(const {}) {
    WidgetsBinding.instance.addObserver(this);
    _initPresence();
  }

  final Ref ref;
  RealtimeChannel? _presenceChannel;

  Future<void> _initPresence() async {
    final ds = ref.read(supabaseDatasourceProvider);
    final user = ds.currentUser;
    if (user == null) return;

    _presenceChannel = ds.client.channel('global_presence');

    _presenceChannel
        ?.onPresenceSync((_) {
          final newState = <String, String>{};
          final presenceState = _presenceChannel!.presenceState();
          for (final singleState in presenceState) {
            if (singleState.presences.isNotEmpty) {
              final payload = singleState.presences.first.payload;
              final userId = payload['user_id'] as String?;
              if (userId != null) {
                newState[userId] = payload['status'] as String? ?? 'online';
              }
            }
          }
          state = newState;
        })
        .subscribe((status, [error]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _presenceChannel?.track({
              'status': 'online',
              'user_id': user.id,
            });
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _presenceChannel?.track({'status': 'online'});
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _presenceChannel?.untrack();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceChannel?.unsubscribe();
    super.dispose();
  }
}

final presenceProvider =
    StateNotifierProvider<PresenceController, Map<String, String>>((ref) {
      return PresenceController(ref);
    });
