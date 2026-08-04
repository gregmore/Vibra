import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/db_tables.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/direct_message.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/friendship.dart';
import '../../domain/entities/live_message.dart';
import '../../domain/entities/music_profile.dart';
import '../../domain/entities/matched_user_preview.dart';
import '../../domain/entities/music_stat_point.dart';
import '../../domain/entities/settings_option.dart';
import '../../domain/usecases/events_usecases.dart';
import '../../domain/usecases/usecase.dart';
import '../../data/mappers/domain_mappers.dart';
import '../../data/models/event_model.dart';
import 'core_providers.dart';
import 'usecase_providers.dart';
import 'auth_provider.dart';

export '../../domain/entities/matched_user_preview.dart';
export '../../domain/entities/music_stat_point.dart';
export '../../domain/entities/settings_option.dart';

class EventsFeedController extends StateNotifier<List<Event>> {
  EventsFeedController(this.ref) : super(const []) {
    Future.microtask(_load);
    _startPolling();
  }

  final Ref ref;
  Timer? _timer;

  void _startPolling() {
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      _load();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      var loaded = await ref.read(getStoredEventsUseCaseProvider).call(50);

      if (loaded.length < 15) {
        final externalEvents = await ref
            .read(searchNearbyEventsUseCaseProvider)
            .call(
              const SearchNearbyEventsParams(
                latitude: 45.4642,
                longitude: 9.19,
                radiusKm: 50,
              ),
            );
        loaded = _mergeEvents(loaded, externalEvents);
      }

      final user = ref.read(supabaseDatasourceProvider).currentUser;
      if (user != null) {
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

      if (loaded.isNotEmpty) {
        state = _filterPastEvents(loaded);
      }
    } catch (e) {
      VibraLogger.error('Failed to load events', error: e);
      // state remains empty — screens show empty/error state
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

  Future<void> _load() async {
    try {
      final supabase = ref.read(supabaseDatasourceProvider);
      final authUser = supabase.currentUser;
      if (authUser == null) return;

      try {
        state = await ref
            .read(getMyProfileUseCaseProvider)
            .call(const NoParams());
      } catch (e) {
        VibraLogger.error(
          'Failed to load profile, checking if user was deleted',
          error: e,
        );

        try {
          // Verify if the user still exists in auth.users by calling the server
          await supabase.client.auth.getUser();
        } catch (authError) {
          VibraLogger.error(
            'User no longer exists on server, logging out',
            error: authError,
          );
          await ref.read(generalAuthProvider.notifier).signOut();
          return;
        }

        VibraLogger.info('User exists, trying to upsert bootstrap profile');

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
          bio: null,
          spotifyId: null,
          onboardingCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          state = await ref
              .read(upsertMyProfileUseCaseProvider)
              .call(bootstrap);
        } catch (err) {
          VibraLogger.error('Failed to upsert bootstrap profile', error: err);
          state = bootstrap;
        }
      }
    } catch (e) {
      VibraLogger.error('Supabase not initialized or check failed', error: e);
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
    final supabase = ref.read(supabaseDatasourceProvider);
    final user = supabase.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (onboardingStep != null) updates['onboarding_step'] = onboardingStep;
    if (onboardingCompleted != null)
      updates['onboarding_completed'] = onboardingCompleted;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await supabase.client
          .from(DbTables.users)
          .update(updates)
          .eq('id', user.id);
      await _load();
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

  Future<void> _load() async {
    try {
      final music = await ref
          .read(getMyMusicProfileUseCaseProvider)
          .call(const NoParams());
      if (music != null) {
        state = music;
      }
    } catch (e) {
      VibraLogger.error('Failed to load music profile', error: e);
      // state remains empty/initial
    }
  }
}

class MatchedUsersController extends StateNotifier<List<MatchedUserPreview>> {
  MatchedUsersController(this.ref) : super(const []) {
    Future.microtask(_load);
    _subscribe();
  }

  final Ref ref;
  RealtimeChannel? _channel;

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
      final acceptedIds = accepted.map((f) {
        final me = currentUserId;
        return f.requesterId == me ? f.receiverId : f.requesterId;
      }).toSet();

      final userById = <String, Map<String, dynamic>>{
        for (final user in publicUsers) user['id'].toString(): user,
      };

      state = rows
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

            return MatchedUserPreview(
              user: appUser,
              compatibility: (row['compatibility'] as num?)?.round() ?? 0,
              topArtists: const [],
              city: 'Live nearby',
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

  void passMatch(String userId) {
    state = state.where((m) => m.user.id != userId).toList(growable: false);
  }

  Future<void> sendVibra(String userId) async {
    // In un'app reale questo chiamerebbe il backend per creare la richiesta.
    // Per ora, aggiorniamo solo lo stato rimuovendolo dalla lista visibile.
    state = state.where((m) => m.user.id != userId).toList(growable: false);
  }
}

class PendingFriendshipsController extends StateNotifier<List<Friendship>> {
  PendingFriendshipsController(this.ref) : super(const []) {
    Future.microtask(_load);
    _subscribe();
  }

  final Ref ref;
  RealtimeChannel? _channel;

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
    try {
      state = await ref.read(listFriendshipsUseCaseProvider).call('pending');
    } catch (e) {
      VibraLogger.error('Failed to load pending friendships', error: e);
      // state remains empty
    }
  }
}

class DirectMessagesController extends StateNotifier<List<DirectMessage>> {
  DirectMessagesController(this.ref) : super(const []);

  final Ref ref;
  StreamSubscription? _subscription;

  void loadConversation(String otherUserId) {
    _subscription?.cancel();
    final ds = ref.read(supabaseSocialDatasourceProvider);
    _subscription = ds
        .streamMessagesWith(otherUserId: otherUserId)
        .listen(
          (models) {
            final messages = models
                .map(
                  (m) => DirectMessage(
                    id: m.id,
                    senderId: m.senderId,
                    receiverId: m.receiverId,
                    content: m.content,
                    createdAt: m.createdAt,
                    readAt: m.readAt,
                  ),
                )
                .toList(growable: false);
            state = messages;
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

class LiveMessagesController extends StateNotifier<List<LiveMessage>> {
  LiveMessagesController(this.ref, this.eventId) : super(const []) {
    if (eventId != null) {
      _subscribe();
    }

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  final Ref ref;
  final String? eventId;
  StreamSubscription<List<LiveMessage>>? _subscription;

  void _subscribe() {
    if (eventId == null) return;
    try {
      _subscription = ref
          .read(streamLiveMessagesUseCaseProvider)
          .call(eventId!)
          .listen((messages) {
            state = messages.reversed.toList(growable: false);
          });
    } catch (e) {
      VibraLogger.error(
        'Failed to stream live messages for event $eventId',
        error: e,
      );
      // state remains empty
    }
  }
}

class UserEventsController
    extends StateNotifier<({List<Event> going, List<Event> saved})> {
  UserEventsController(this.ref) : super((going: const [], saved: const [])) {
    Future.microtask(_load);
  }

  final Ref ref;

  Future<void> refresh() => _load();

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

final liveMessagesProvider =
    StateNotifierProvider.autoDispose<
      LiveMessagesController,
      List<LiveMessage>
    >((ref) {
      final events = ref.watch(allEventsProvider);
      final eventId = events.isNotEmpty ? events.first.id : null;
      return LiveMessagesController(ref, eventId);
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
  return [
    MusicStatPoint(label: 'Lun', value: 0.4),
    MusicStatPoint(label: 'Mar', value: 0.6),
    MusicStatPoint(label: 'Mer', value: 0.3),
    MusicStatPoint(label: 'Gio', value: 0.8),
    MusicStatPoint(label: 'Ven', value: 1.0),
    MusicStatPoint(label: 'Sab', value: 0.9),
    MusicStatPoint(label: 'Dom', value: 0.5),
  ];
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
  final _settingsKeys = ['event_alert', 'match', 'live_chat', 'chat'];

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

class PushEnabledController extends StateNotifier<bool> {
  PushEnabledController(this.ref) : super(true) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('push_enabled') ?? true;
    } catch (e) {
      VibraLogger.error('Failed to load push_enabled preference', error: e);
    }
  }

  Future<void> toggle(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_enabled', value);

      final supabase = ref.read(supabaseDatasourceProvider);
      final user = supabase.currentUser;
      if (user != null) {
        if (value) {
          // get FCM token and send to Supabase
          final messaging = FirebaseMessaging.instance;
          final token = await messaging.getToken();
          if (token != null && token.isNotEmpty) {
            await supabase.client.from('users').upsert({
              'id': user.id,
              'email': user.email ?? '',
              'fcm_token': token,
            }, onConflict: 'id');
            VibraLogger.info(
              'Push notifications re-enabled, token sent to Supabase',
              tag: 'Push',
            );
          }
        } else {
          // remove FCM token from Supabase
          await supabase.client.from('users').upsert({
            'id': user.id,
            'email': user.email ?? '',
            'fcm_token': null,
          }, onConflict: 'id');
          VibraLogger.info(
            'Push notifications disabled, token removed from Supabase',
            tag: 'Push',
          );
        }
      }
    } catch (e) {
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
