import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_musical_dna_datasource.dart';
import 'package:vibra/domain/entities/musical_dna.dart';
import 'package:vibra/domain/entities/taste_evolution.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/profile/taste_evolution_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseMusicalDnaDatasource {}

Map<String, dynamic> _snap(
  String day,
  Map<String, int> f,
  List<String> artists,
) => {
  'captured_on': day,
  'dna': {
    'families': [
      for (final e in f.entries)
        {'key': e.key, 'percent': e.value, 'share': e.value / 100},
    ],
    'subgenres': [
      for (final e in f.entries)
        {
          'key': e.key == 'electronic' ? 'techno' : e.key,
          'family': e.key,
          'percent': e.value,
          'share': e.value / 100,
        },
    ],
    'artists': [
      for (final a in artists) {'key': a, 'name': a},
    ],
  },
};

TasteEvolution _evolution({bool tracking = true, bool baseline = true}) =>
    TasteEvolution.fromJson({
      'tracking': tracking,
      'days': 90,
      'snapshot_count': baseline ? 90 : 1,
      'oldest_on': baseline ? '2026-08-01' : '2026-11-08',
      'current': _snap(
        '2026-11-08',
        {'hip-hop': 60, 'electronic': 40},
        ['Fred again..', 'Travis Scott'],
      ),
      'baseline': baseline
          ? {
              ..._snap(
                '2026-08-08',
                {'hip-hop': 70, 'rock': 30},
                ['Travis Scott', 'Arctic Monkeys'],
              ),
              'full_period': true,
            }
          : null,
      'timeline': const [],
      'communities': [
        {
          'id': 'c1',
          'name': 'Techno Underground',
          'joined_at': '2026-10-01T10:00:00Z',
        },
      ],
    });

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(() => source.setTasteHistory(any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseMusicalDnaDatasourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: TasteEvolutionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('compares two real snapshots, with their dates', (tester) async {
    when(() => source.evolution(any())).thenAnswer((_) async => _evolution());
    await mount(tester);
    expect(
      find.text('Your musical taste has evolved over the last 3 months'),
      findsOneWidget,
    );
    expect(
      find.text('Comparing your Musical DNA on Aug 8, 2026 with Nov 8, 2026.'),
      findsOneWidget,
    );
    expect(find.text('Then and now'), findsOneWidget);
    // In the chart and under previous preferences.
    expect(find.text('30% → 0%'), findsNWidgets(2));
    expect(find.textContaining('Techno'), findsWidgets);
    expect(find.text('Fred again..'), findsOneWidget);
    expect(find.text('Arctic Monkeys'), findsOneWidget);
    expect(find.text('Techno Underground'), findsOneWidget);
    // Another period asks the server again.
    await tester.tap(find.text('1 year'));
    await tester.pumpAndSettle();
    verify(() => source.evolution(365)).called(1);
  });

  testWidgets('with one snapshot, says so instead of inventing history', (
    tester,
  ) async {
    when(
      () => source.evolution(any()),
    ).thenAnswer((_) async => _evolution(baseline: false));
    await mount(tester);
    expect(find.text('Not enough history yet'), findsOneWidget);
    expect(find.textContaining('Nov 8, 2026'), findsOneWidget);
    expect(find.text('Then and now'), findsNothing);
  });

  testWidgets('history can be turned off, after confirming deletion', (
    tester,
  ) async {
    when(() => source.evolution(any())).thenAnswer((_) async => _evolution());
    await mount(tester);
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Turn off taste history?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => source.setTasteHistory(any()));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    when(
      () => source.evolution(any()),
    ).thenAnswer((_) async => _evolution(tracking: false));
    await tester.tap(find.text('Turn off and delete'));
    await tester.pumpAndSettle();
    verify(() => source.setTasteHistory(false)).called(1);
    expect(find.text('Taste history is off'), findsOneWidget);
  });

  test('periods map to real day counts', () {
    expect(TastePeriod.values.map((p) => p.days), [30, 90, 180, 365]);
    expect(MusicalDna.fromJson({'families': []}), isNull);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.evolution(any()),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
