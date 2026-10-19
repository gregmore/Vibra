import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/screens/home/home_screen.dart';
import 'package:vibra/presentation/screens/profile/help_center_screen.dart';
import 'package:vibra/presentation/screens/profile/music_stats_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_avatar.dart';
import 'package:vibra/presentation/widgets/common/vibra_editorial_event.dart';
import 'package:vibra/presentation/widgets/common/vibra_event_card.dart';
import 'package:vibra/presentation/widgets/common/vibra_user_match_card.dart';
import 'package:vibra/presentation/widgets/vibra_neon_avatar.dart';

class _Profile extends StateNotifier<AppUser> implements ProfileController {
  _Profile({bool hasAvatar = true})
    : super(
        AppUser(
          id: 'legacy-user',
          email: '',
          username: 'giulia',
          displayName: 'Giulia',
          spotifyId: 'legacy-spotify-id',
          avatarUrl: hasAvatar ? 'https://avatars.example/photo.png' : null,
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget screen) => MaterialApp(
  locale: const Locale('it'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: screen,
);

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets(
    'Public music stats never read or synchronize Spotify data',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myMusicProfileProvider.overrideWith(
              (ref) => throw StateError('Read legacy music'),
            ),
            spotifyAuthProvider.overrideWith(
              (ref) => throw StateError('Started Spotify'),
            ),
          ],
          child: _app(const MusicStatsScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Spotify in pausa'), findsWidgets);
      expect(find.byIcon(Icons.sync_rounded), findsNothing);
      expect(find.text('Connetti Spotify'), findsNothing);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    },
    skip: AppConstants.spotifyEnabled,
  );

  testWidgets(
    'Community cards hide stale affinity and artist data',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: VibraUserMatchCard(
              user: MatchedUserPreview(
                user: AppUser(
                  id: 'other',
                  email: '',
                  username: 'sara',
                  displayName: 'Sara',
                ),
                compatibility: 99,
                topArtists: ['Legacy private artist'],
                city: 'Roma',
                attendingEvents: 87,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(VibraAvatar), findsOneWidget);
      expect(find.byType(VibraNeonAvatar), findsNothing);
      expect(find.text('99%'), findsNothing);
      expect(find.text('Legacy private artist'), findsNothing);
      expect(find.textContaining('87 eventi'), findsNothing);
      expect(find.text('@sara'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    },
    skip: AppConstants.spotifyEnabled,
  );

  testWidgets(
    'Event cards omit affinity badges and accessibility claims',
    (tester) async {
      final event = Event(
        id: 'concert',
        externalId: 'concert',
        source: 'test',
        name: 'Concerto',
        eventDate: DateTime(2030),
        venueName: 'Arena',
      );
      await tester.pumpWidget(
        ProviderScope(
          child: _app(
            Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    VibraEventFeature(
                      event: event,
                      onTap: () {},
                      matchScore: 99,
                    ),
                    VibraEventRow(event: event, onTap: () {}, matchScore: 98),
                    VibraEventCard(event: event, matchScore: 97),
                    VibraEventCard(event: event, matchScore: 96, compact: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining(RegExp(r'\d+%')), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains('affinità') ?? false),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    },
    skip: AppConstants.spotifyEnabled,
  );

  testWidgets(
    'Public home ignores legacy Spotify and keeps avatar completion',
    (tester) async {
      Future<void> mount(bool hasAvatar) => tester.pumpWidget(
        ProviderScope(
          key: ValueKey(hasAvatar),
          overrides: [
            myProfileProvider.overrideWith(
              (ref) => _Profile(hasAvatar: hasAvatar),
            ),
            featuredEventsProvider.overrideWithValue([]),
            nearbyEventsProvider.overrideWithValue([]),
            trendingEventsProvider.overrideWithValue([]),
          ],
          child: _app(const HomeScreen()),
        ),
      );
      await mount(true);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Spotify'), findsNothing);
      expect(find.text('Per Te'), findsNothing);
      expect(find.text('Dai più forma alla tua vibra'), findsNothing);
      expect(find.text('Eventi'), findsOneWidget);
      await mount(false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Dai più forma alla tua vibra'), findsOneWidget);
      expect(find.textContaining('Spotify'), findsNothing);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    },
    skip: AppConstants.spotifyEnabled,
  );

  testWidgets(
    'Public help does not advertise connection or music matching',
    (tester) async {
      await tester.pumpWidget(_app(const HelpCenterScreen()));
      expect(find.text('Spotify'), findsNothing);
      expect(find.text('Come collego Spotify?'), findsNothing);
      expect(find.text('Come viene calcolato il match score?'), findsNothing);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    },
    skip: AppConstants.spotifyEnabled,
  );
}
