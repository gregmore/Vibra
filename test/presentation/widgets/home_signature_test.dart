import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/domain/entities/circle.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/domain/entities/musical_dna.dart';
import 'package:vibra/domain/entities/same_frequency.dart';
import 'package:vibra/domain/usecases/same_frequency.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/circle_providers.dart';
import 'package:vibra/presentation/providers/musical_dna_providers.dart';
import 'package:vibra/presentation/providers/same_frequency_providers.dart';
import 'package:vibra/presentation/widgets/home_signature.dart';

/// The signature features on Home: Musical DNA, Same Frequency, Concert
/// Match and Vibra Circles, each with a live fact from real data.
void main() {
  const dna = MusicalDna(
    families: [DnaFamily(key: 'hip-hop', share: .6, percent: 60)],
    subgenres: [],
    diversityScore: 40,
    diversityTier: DnaDiversityTier.balanced,
    sources: DnaSources(manual: true, manualGenres: 2),
  );
  FrequencyCandidate person(String id) => FrequencyCandidate(
    userId: id,
    username: id,
    compatibility: 80,
    affinity: AffinityDetails.empty,
  );
  final concert = Event(
    id: 'e1',
    externalId: 'x1',
    source: 'ticketmaster',
    name: 'Night Tour',
    artistName: 'Nova',
    eventDate: DateTime.now().add(const Duration(days: 5)),
  );

  Future<(GoRouter, ProviderContainer)> mount(
    WidgetTester tester, {
    List<MusicalDna> history = const [dna],
    List<FrequencyCandidate> people = const [],
    List<Circle> circles = const [],
    List<CircleInvitation> invitations = const [],
    bool going = true,
  }) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: SingleChildScrollView(child: HomeSignatureSection()),
          ),
        ),
        for (final path in [
          '/musical-dna',
          '/music-genres',
          '/same-frequency',
          '/concert-match',
          '/concerts',
          '/circles',
        ])
          GoRoute(
            path: path,
            builder: (_, state) => Text(
              'opened $path${state.extra is Event ? ' ${(state.extra as Event).id}' : ''}',
            ),
          ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        myMusicalDnaHistoryProvider.overrideWith((ref) async => history),
        sameFrequencyPreviewProvider.overrideWith(
          (ref) async => FrequencyResult(people: people, strongCount: 0),
        ),
        myCirclesProvider.overrideWith((ref) async => circles),
        circleInvitationsProvider.overrideWith((ref) async => invitations),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // After the controller's own first load, mark the concert as going
    // through its public API (as the attendance flow does).
    if (going) {
      container
          .read(myEventsProvider.notifier)
          .applyAttendance(concert, 'going');
      await tester.pumpAndSettle();
    }
    return (router, container);
  }

  testWidgets('each tile states a real fact and opens its feature', (
    tester,
  ) async {
    await mount(
      tester,
      people: [person('a'), person('b'), person('c'), person('d')],
      circles: const [
        Circle(id: 'c1', name: 'Trap', basis: CircleBasis.genre),
        Circle(id: 'c2', name: 'Jazz', basis: CircleBasis.genre),
      ],
    );
    expect(find.text('Find your people through music'), findsOneWidget);
    expect(find.text('Hip-Hop leads your sound'), findsOneWidget);
    expect(find.text('4 people on your frequency'), findsOneWidget);
    expect(find.text('Meet people going to Nova'), findsOneWidget);
    expect(find.text('2 circles'), findsOneWidget);

    await tester.tap(find.text('Meet people going to Nova'));
    await tester.pumpAndSettle();
    expect(find.text('opened /concert-match e1'), findsOneWidget);
  });

  testWidgets('without data each tile invites the first step', (tester) async {
    await mount(tester, history: const [], going: false);
    expect(find.text('Build it from the genres you love'), findsOneWidget);
    expect(find.text('Discover people who share your taste'), findsOneWidget);
    expect(find.text('Choose a concert to meet people going'), findsOneWidget);
    expect(find.text('Start a small music group'), findsOneWidget);
    await tester.tap(find.text('Build it from the genres you love'));
    await tester.pumpAndSettle();
    expect(find.text('opened /music-genres'), findsOneWidget);
  });

  testWidgets('a waiting invitation takes priority on the Circles tile', (
    tester,
  ) async {
    await mount(
      tester,
      invitations: const [
        CircleInvitation(
          id: 'i1',
          circleId: 'c9',
          circleName: 'Techno',
          basis: CircleBasis.genre,
          memberCount: 3,
          inviter: CirclePerson(id: 'u1', username: 'sam'),
        ),
      ],
    );
    expect(find.text('1 invitation waiting'), findsOneWidget);
  });

  testWidgets(
    'a failing section falls back to its invitation, never an error',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          myMusicalDnaHistoryProvider.overrideWith(
            (ref) async => throw Exception('offline'),
          ),
          sameFrequencyPreviewProvider.overrideWith(
            (ref) async => throw Exception('offline'),
          ),
          myCirclesProvider.overrideWith((ref) async => throw Exception('x')),
          circleInvitationsProvider.overrideWith(
            (ref) async => throw Exception('x'),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(
              body: SingleChildScrollView(child: HomeSignatureSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Build it from the genres you love'), findsOneWidget);
      expect(find.text('Start a small music group'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
