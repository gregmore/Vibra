// Offline store captures: production widgets, fictional data, no backend writes.
// Run explicitly: flutter test script/store/capture_screenshots_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/presentation/providers/public_users_provider.dart';
import 'package:vibra/presentation/providers/public_friends_provider.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/domain/entities/music_profile.dart';
import 'package:vibra/domain/usecases/events_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import 'package:vibra/presentation/screens/auth/login_screen.dart';
import 'package:vibra/presentation/screens/profile/edit_profile_screen.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/home/home_screen.dart';
import 'package:vibra/presentation/screens/profile/my_profile_screen.dart';
import 'package:vibra/presentation/screens/profile/my_events_screen.dart';
import 'package:vibra/presentation/screens/social/conversations_screen.dart';
import 'package:vibra/presentation/screens/social/discover_users_screen.dart';
import 'package:vibra/presentation/screens/event_detail/event_detail_screen.dart';
import 'package:vibra/presentation/screens/shell/vibra_shell_screen.dart';

const me = AppUser(
  id: 'fixture-me',
  email: 'giulia@example.invalid',
  username: 'giulia_live',
  displayName: 'Giulia',
  bio: 'Indie, amici e una serata sotto il palco.',
  spotifyId: AppConstants.spotifyEnabled ? 'fixture-spotify' : null,
);
final events = [
  for (final (i, name, artist) in [
    (1, 'Notte Indie', 'Calcutta'),
    (2, 'Onde Sonore', 'Nuova Scena'),
    (3, 'Ritmi in Città', 'Suoni Urbani'),
  ])
    Event(
      id: 'fixture-event-$i',
      externalId: 'fixture-event-$i',
      source: 'fixture',
      name: name,
      artistName: artist,
      city: 'Milano',
      venueName: 'Spazio Live',
      eventDate: DateTime(2027, 5, 14 + i, 21),
      priceMin: 25,
      priceMax: 40,
      description:
          'Una serata dedicata alla musica dal vivo e alle nuove connessioni.',
    ),
];
final matches = [
  for (final (i, name, score) in [
    (1, 'Sofia', 94),
    (2, 'Luca', 89),
    (3, 'Emma', 86),
  ])
    MatchedUserPreview(
      user: AppUser(
        id: 'fixture-friend-$i',
        email: 'friend$i@example.invalid',
        username: '${name.toLowerCase()}_music',
        displayName: name,
      ),
      compatibility: AppConstants.spotifyEnabled ? score : 0,
      topArtists: AppConstants.spotifyEnabled
          ? ['Calcutta', 'Indie']
          : const [],
      city: AppConstants.spotifyEnabled ? 'Milano' : '',
      attendingEvents: AppConstants.spotifyEnabled ? i + 1 : 0,
      isFriend: i == 1,
    ),
];
const music = MusicProfile(
  id: 'fixture-music',
  userId: 'fixture-me',
  topArtists: [
    MusicArtistPreference(id: 'a1', name: 'Calcutta', score: 94),
    MusicArtistPreference(id: 'a2', name: 'Thegiornalisti', score: 89),
    MusicArtistPreference(id: 'a3', name: 'Arctic Monkeys', score: 85),
  ],
  topTracks: [],
  topGenres: [
    GenrePreference(genre: 'Indie', weight: 0.7),
    GenrePreference(genre: 'Alternative', weight: 0.3),
  ],
);

class FixtureAuth extends StateNotifier<GeneralAuthState>
    implements GeneralAuthNotifier {
  FixtureAuth() : super(const GeneralAuthState.idle());
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureProfile extends StateNotifier<AppUser>
    implements ProfileController {
  FixtureProfile() : super(me);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureMusic extends StateNotifier<MusicProfile>
    implements MusicProfileController {
  FixtureMusic() : super(music);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureEvents
    extends StateNotifier<({List<Event> going, List<Event> saved})>
    implements UserEventsController {
  FixtureEvents() : super((going: [events[0], events[1]], saved: [events[2]]));
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureMatches extends StateNotifier<List<MatchedUserPreview>>
    implements MatchedUsersController {
  FixtureMatches() : super(matches);
  @override
  Future<void> refresh() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureFriendships extends StateNotifier<List<Friendship>>
    implements PendingFriendshipsController {
  FixtureFriendships() : super([]);
  @override
  Future<void> refresh() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureStats extends StateNotifier<FollowStats>
    implements UserFollowStatsController {
  FixtureStats()
    : super(
        const FollowStats(
          followersCount: 24,
          followingCount: 18,
          isFollowing: false,
          isFollower: false,
        ),
      );
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureConversations extends StateNotifier<List<ConversationSummary>>
    implements ConversationsController {
  FixtureConversations()
    : super([
        for (final (i, name, message) in [
          (1, 'Sofia', 'Ci vediamo sotto il palco!'),
          (2, 'Luca', 'Hai già salvato Notte Indie?'),
          (3, 'Emma', 'Anche tu ami la musica indie?'),
        ])
          ConversationSummary(
            otherUserId: 'fixture-friend-$i',
            otherUsername: '${name.toLowerCase()}_music',
            otherDisplayName: name,
            otherAvatarUrl: null,
            lastMessageContent: message,
            lastMessageCreatedAt: DateTime.now().subtract(
              Duration(minutes: i * 5),
            ),
            unreadCount: i == 1 ? 2 : 0,
            isFriend: true,
            isMessageRequest: false,
          ),
      ]);
  @override
  Future<void> refresh() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FixtureAttendance implements GetMyEventAttendanceUseCase {
  @override
  Future<String?> call(Event event) async => 'going';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final (family, files) in [
      (
        'Inter',
        [
          'Inter-Regular',
          'Inter-Medium',
          'Inter-SemiBold',
          'Inter-Bold',
          'Inter-ExtraBold',
        ],
      ),
      ('Syne', ['Syne-SemiBold', 'Syne-Bold']),
    ]) {
      final loader = FontLoader(family);
      for (final file in files) {
        loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
      }
      await loader.load();
    }
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  final formats = [
    ('ios-medium', const Size(402, 874), 3.0),
    ('android-phone', const Size(360, 640), 3.0),
    ('ipad-13', const Size(1032, 1376), 2.0),
  ];
  final captures = [
    ('01-home', '/home'),
    ('02-community', '/discover-users'),
    ('03-evento', '/event-detail'),
    ('04-agenda', '/my-events'),
    ('05-messaggi', '/conversations'),
    ('06-profilo', '/profile'),
    ('07-accesso', '/login'),
    ('08-modifica-profilo', '/edit-profile'),
    ('09-foto-profilo', '/edit-profile?photoSheet=1'),
  ];
  for (final (format, size, scale) in formats) {
    for (final (name, location) in captures) {
      testWidgets('$format $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        final router = GoRouter(
          initialLocation: location,
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (c, s, shell) =>
                  VibraShellScreen(navigationShell: shell),
              branches: [
                for (final (path, screen) in <(String, Widget)>[
                  ('/home', const HomeScreen()),
                  // Unvisited branches retain the production shell's destination order.
                  ('/explore', const SizedBox.shrink()),
                  ('/social-match', const SizedBox.shrink()),
                  ('/conversations', const ConversationsScreen()),
                  ('/profile', const MyProfileScreen()),
                ])
                  StatefulShellBranch(
                    routes: [GoRoute(path: path, builder: (c, s) => screen)],
                  ),
              ],
            ),
            GoRoute(
              path: '/discover-users',
              builder: (c, s) => const DiscoverUsersScreen(),
            ),
            GoRoute(
              path: '/event-detail',
              builder: (c, s) => EventDetailScreen(event: events[0]),
            ),
            GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
            GoRoute(
              path: '/edit-profile',
              builder: (c, s) => const EditProfileScreen(),
            ),
            GoRoute(
              path: '/my-events',
              builder: (c, s) => const MyEventsScreen(),
            ),
          ],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              generalAuthProvider.overrideWith((ref) => FixtureAuth()),
              myProfileProvider.overrideWith((ref) => FixtureProfile()),
              publicFriendsProvider.overrideWith(
                (ref) async => [matches.first],
              ),
              publicConnectionProfilesProvider.overrideWith(
                (ref) async => matches,
              ),
              myMusicProfileProvider.overrideWith((ref) => FixtureMusic()),
              myEventsProvider.overrideWith((ref) => FixtureEvents()),
              matchedUsersProvider.overrideWith((ref) => FixtureMatches()),
              publicUsersProvider.overrideWith(
                (ref, query) async => matches
                    .where(
                      (u) =>
                          u.user.username.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ||
                          (u.user.displayName ?? '').toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                    )
                    .toList(),
              ),
              pendingFriendshipsProvider.overrideWith(
                (ref) => FixtureFriendships(),
              ),
              userFollowStatsProvider.overrideWith((ref, id) => FixtureStats()),
              conversationsProvider.overrideWith(
                (ref) => FixtureConversations(),
              ),
              featuredEventsProvider.overrideWithValue(events),
              nearbyEventsProvider.overrideWithValue(events),
              trendingEventsProvider.overrideWithValue(events),
              globalBadgeCountsProvider.overrideWithValue(
                const GlobalBadgeCounts(
                  pendingFriendships: 0,
                  unreadMessages: 2,
                  unreadNotifications: 0,
                ),
              ),
              getMyEventAttendanceUseCaseProvider.overrideWithValue(
                FixtureAttendance(),
              ),
            ],
            child: RepaintBoundary(
              key: key,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                theme: Platform.environment['VIBRA_CAPTURE_THEME'] == 'dark'
                    ? VibraTheme.darkTheme
                    : VibraTheme.lightTheme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('it'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
        // Show the recommendation section after a normal user scroll.
        if (location == '/home') {
          final scrollable = tester.state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(CustomScrollView).first,
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          scrollable.position.jumpTo(220);
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
          await tester.pump();
        }
        if (name == '09-foto-profilo') {
          await tester.tap(find.text('Cambia immagine profilo'));
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
        }
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: scale);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '${Platform.environment['VIBRA_SCREENSHOT_DIR'] ?? 'release/store-materials/screenshots'}/$format/$name.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        router.dispose();
      });
    }
  }
}
