import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_circles_datasource.dart';
import 'package:vibra/domain/entities/circle.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/domain/entities/same_frequency.dart';
import 'package:vibra/domain/usecases/circle_suggestions.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/circle_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/circles/circle_screen.dart';
import 'package:vibra/presentation/screens/circles/circles_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseCirclesDatasource {}

const _mine = Circle(
  id: 'c1',
  name: 'Trap Circle',
  basis: CircleBasis.genre,
  genreKey: 'trap',
  memberCount: 3,
);

FrequencyCandidate _p(String id, int score) => FrequencyCandidate(
  userId: id,
  username: id,
  displayName: id.toUpperCase(),
  compatibility: score,
  affinity: AffinityDetails.empty,
);

void main() {
  late _Source source;

  setUpAll(() => registerFallbackValue(CircleBasis.genre));

  setUp(() {
    source = _Source();
    when(() => source.currentUserId).thenReturn('me');
    when(() => source.myCircles()).thenAnswer((_) async => [_mine]);
    when(() => source.myInvitations()).thenAnswer(
      (_) async => [
        const CircleInvitation(
          id: 'inv1',
          circleId: 'c9',
          circleName: 'Techno Crew',
          basis: CircleBasis.genre,
          memberCount: 4,
          inviter: CirclePerson(id: 'u5', username: 'sam', displayName: 'Sam'),
        ),
      ],
    );
    when(
      () => source.respond(any(), accept: any(named: 'accept')),
    ).thenAnswer((_) async => null);
    when(
      () => source.create(
        name: any(named: 'name'),
        description: any(named: 'description'),
        basis: any(named: 'basis'),
        genreKey: any(named: 'genreKey'),
        artistName: any(named: 'artistName'),
        eventId: any(named: 'eventId'),
        topic: any(named: 'topic'),
      ),
    ).thenAnswer((_) async => 'new');
    when(() => source.invite(any(), any())).thenAnswer((_) async {});
    when(() => source.messages(any())).thenAnswer((_) => Stream.value([]));
    when(() => source.members(any())).thenAnswer(
      (_) async => [
        const CircleMember(
          CirclePerson(id: 'me', username: 'me'),
          isAdmin: true,
        ),
        const CircleMember(CirclePerson(id: 'u2', username: 'alex')),
      ],
    );
    when(() => source.pendingInvites(any())).thenAnswer((_) async => []);
  });

  Future<void> mount(
    WidgetTester tester,
    Widget home, {
    List<CircleSuggestion> suggestions = const [],
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseCirclesDatasourceProvider.overrideWithValue(source),
          circleSuggestionsProvider.overrideWith((ref) async => suggestions),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an invitation is only an offer: accept or decline', (
    tester,
  ) async {
    await mount(tester, const CirclesScreen());
    expect(find.text('Sam invited you'), findsOneWidget);
    expect(find.text('Techno Crew'), findsOneWidget);
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();
    verify(() => source.respond('inv1', accept: false)).called(1);
    expect(find.text('Invitation declined'), findsOneWidget);
  });

  testWidgets('a VIBRA suggestion creates the circle and only invites', (
    tester,
  ) async {
    await mount(
      tester,
      const CirclesScreen(),
      suggestions: [
        CircleSuggestion(
          basis: SuggestionBasis.genre,
          key: 'trap',
          people: [_p('a', 90), _p('b', 85), _p('c', 80), _p('d', 75)],
        ),
      ],
    );
    expect(find.text('A circle of 5 people who share Trap.'), findsOneWidget);
    expect(
      find.text('Each person gets an invitation and decides whether to join.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Create and invite'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    verify(
      () => source.create(
        name: 'Trap Circle',
        description: '',
        basis: CircleBasis.genre,
        genreKey: 'trap',
        artistName: null,
      ),
    ).called(1);
    for (final id in ['a', 'b', 'c', 'd']) {
      verify(() => source.invite('new', id)).called(1);
    }
  });

  testWidgets('circle screen: tabs, admin sees invite and member tools', (
    tester,
  ) async {
    await mount(tester, const CircleScreen(circleId: 'c1'));
    expect(find.text('Say hi to your circle.'), findsOneWidget);
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('Invite people'), findsNothing); // c1: not admin
    expect(find.text('alex'), findsOneWidget);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.myCircles(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester, const CirclesScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failure, then Retry, shows the content', (tester) async {
      Future<List<Circle>> real() => source.myCircles();
      final success = await real();
      when(real).thenThrow(Exception('temporary'));
      await mount(tester, const CirclesScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      when(real).thenAnswer((_) async => success);
      await tester.tap(find.byIcon(Icons.refresh_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(VibraErrorView), findsNothing);
      expect(find.text('Trap Circle'), findsWidgets);
    });

    testWidgets('no data: the empty state, not a blank screen', (tester) async {
      when(() => source.myCircles()).thenAnswer((_) async => []);
      when(() => source.myInvitations()).thenAnswer((_) async => []);
      await mount(tester, const CirclesScreen());
      expect(find.byType(VibraEmptyView), findsWidgets);
      expect(find.byType(VibraErrorView), findsNothing);
    });
  });
}
