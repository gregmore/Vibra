import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/data/datasources/supabase_musical_dna_datasource.dart';
import 'package:vibra/domain/entities/musical_dna.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/profile/musical_dna_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Dna extends Mock implements SupabaseMusicalDnaDatasource {}

MusicalDna _dna(Map<String, int> families, DateTime day) =>
    MusicalDna.fromJson({
      'families': [
        for (final e in families.entries)
          {
            'key': e.key,
            'share': e.value / 100,
            'percent': e.value,
            'artists': e.key == 'hip-hop' ? ['Travis Scott', 'Kanye West'] : [],
          },
      ],
      'subgenres': [
        {'key': 'trap', 'family': 'hip-hop', 'share': 0.25, 'percent': 25},
        {'key': 'hip-hop', 'family': 'hip-hop', 'share': 0.15, 'percent': 15},
      ],
      'diversity': {'score': 58, 'tier': 'balanced'},
      'sources': {
        'spotify': true,
        'manual': true,
        'artists': 50,
        'artists_classified': 46,
        'tracks': 50,
        'manual_genres': 4,
      },
    }, capturedOn: day)!;

void main() {
  if (!AppConstants.spotifyEnabled) return;
  late _Dna source;

  setUpAll(() => registerFallbackValue(DnaVisibility.private));

  setUp(() {
    source = _Dna();
    when(
      () => source.myVisibility(),
    ).thenAnswer((_) async => DnaVisibility.matches);
    when(() => source.setMyVisibility(any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseMusicalDnaDatasourceProvider.overrideWithValue(source),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'own DNA: distribution, diversity, evolution, sources, visibility',
    (tester) async {
      when(() => source.myHistory()).thenAnswer(
        (_) async => [
          _dna({
            'hip-hop': 40,
            'rnb': 15,
            'electronic': 45,
          }, DateTime(2026, 11, 6)),
          _dna({
            'hip-hop': 60,
            'rnb': 30,
            'electronic': 10,
          }, DateTime(2026, 9, 1)),
        ],
      );
      await mount(tester, const MusicalDnaScreen());

      expect(find.text('Genre distribution'), findsOneWidget);
      expect(find.text('Trap 25%'), findsOneWidget);
      // The generic family entry is not repeated as its own tag.
      expect(find.text('Hip-Hop 15%'), findsNothing);
      expect(find.text('Through Travis Scott, Kanye West'), findsOneWidget);
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.text('58'), findsOneWidget);
      expect(find.text('10% → 45%'), findsOneWidget);
      expect(find.text('60% → 40%'), findsOneWidget);
      expect(
        find.text('46 of your top 50 Spotify artists (last 6 months)'),
        findsOneWidget,
      );
      expect(find.text('4 genres you picked'), findsOneWidget);

      await tester.tap(find.text('Only me'));
      await tester.pumpAndSettle();
      verify(() => source.setMyVisibility(DnaVisibility.private)).called(1);
      expect(
        find.text('Only you can see it. It still shapes your suggestions.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('no data: asks the server once, then invites to add genres', (
    tester,
  ) async {
    when(() => source.myHistory()).thenAnswer((_) async => []);
    when(() => source.refresh()).thenAnswer((_) async {});
    await mount(tester, const MusicalDnaScreen());
    verify(() => source.refresh()).called(1);
    expect(find.text('No Musical DNA yet'), findsOneWidget);
    expect(find.text('Pick genres'), findsOneWidget);
  });

  testWidgets('someone else: hidden DNA shows a private state, no controls', (
    tester,
  ) async {
    when(() => source.dnaOf('u2')).thenAnswer((_) async => null);
    await mount(
      tester,
      const MusicalDnaScreen(userId: 'u2', displayName: 'Alex'),
    );
    expect(find.text("Alex's Musical DNA"), findsOneWidget);
    expect(find.text('No Musical DNA yet'), findsOneWidget);
    expect(find.text('Who can see it'), findsNothing);
  });

  testWidgets('someone else: visible DNA without evolution or visibility', (
    tester,
  ) async {
    when(() => source.dnaOf('u2')).thenAnswer(
      (_) async => _dna({'hip-hop': 70, 'rnb': 30}, DateTime(2026, 11, 6)),
    );
    await mount(
      tester,
      const MusicalDnaScreen(userId: 'u2', displayName: 'Alex'),
    );
    expect(find.text('Genre distribution'), findsOneWidget);
    expect(find.text('Evolution'), findsNothing);
    expect(find.text('Who can see it'), findsNothing);
    verifyNever(() => source.myVisibility());
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.myHistory(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester, const MusicalDnaScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
