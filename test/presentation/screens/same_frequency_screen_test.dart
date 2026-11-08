import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/data/datasources/supabase_same_frequency_datasource.dart';
import 'package:vibra/domain/entities/direct_message_permission.dart';
import 'package:vibra/domain/entities/same_frequency.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/direct_message_permission_provider.dart';
import 'package:vibra/presentation/providers/same_frequency_providers.dart';
import 'package:vibra/presentation/screens/social/same_frequency_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseSameFrequencyDatasource {}

final _now = DateTime.utc(2026, 11, 9, 12);

FrequencyCandidate _person(
  String id,
  String name,
  int score, {
  bool saved = false,
}) => FrequencyCandidate.fromRow({
  'user_id': id,
  'username': name.toLowerCase(),
  'display_name': name,
  'compatibility': score,
  'details': {
    'shared_families': ['hip-hop'],
    'shared_subgenres': ['trap'],
    'shared_artists': ['Future', 'Metro Boomin'],
    'shared_artist_count': 2,
    'top_families': {
      id: ['hip-hop'],
    },
    'reasons': [
      {
        'code': 'shared_families',
        'families': ['hip-hop'],
      },
      {'code': 'diversity', 'pattern': 'both_focused'},
    ],
  },
  'shared_discoveries': ['Fred again..'],
  'rising_families': ['electronic'],
  'saved': saved,
})!;

void main() {
  if (!AppConstants.spotifyEnabled) return;
  late _Source source;

  setUp(() {
    source = _Source();
    when(() => source.candidates()).thenAnswer(
      (_) async => [_person('u1', 'Alex', 84), _person('u2', 'Sam', 30)],
    );
    when(() => source.recordViews(any())).thenAnswer((_) async {});
    when(
      () => source.setSaved(any(), saved: any(named: 'saved')),
    ).thenAnswer((_) async {});
    when(() => source.sharesEvents()).thenAnswer((_) async => false);
    when(() => source.setSharesEvents(any())).thenAnswer((_) async {});
    when(
      () => source.savedProfiles(),
    ).thenAnswer((_) async => [_person('u9', 'Robin', 72, saved: true)]);
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseSameFrequencyDatasourceProvider.overrideWithValue(source),
          sameFrequencyClockProvider.overrideWithValue(() => _now),
          directMessagePermissionProvider.overrideWith(
            (ref, id) async => id == 'u1'
                ? DirectMessagePermission.allowed
                : DirectMessagePermission.friendshipRequired,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SameFrequencyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows strong connections with signals, reasons and actions', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text("You're on the same frequency."), findsOneWidget);
    // Sam (30%) is not a strong connection, even with extra signals.
    expect(
      find.text(
        'You\'ve discovered 1 person with a strong musical connection.',
      ),
      findsOneWidget,
    );
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Sam'), findsNothing);
    expect(find.text('HIP-HOP · TRAP'), findsOneWidget);
    expect(find.text('Future · Metro Boomin'), findsOneWidget);
    expect(
      find.text('You both recently discovered Fred again...'),
      findsOneWidget,
    );
    expect(find.text("You're both moving toward Electronic."), findsOneWidget);
    expect(find.text('You both mostly listen to Hip-Hop.'), findsOneWidget);
    // Diversity notes are kept for profiles, not this short list.
    expect(find.text('You both stay close to your core sound.'), findsNothing);
    expect(find.text('Send Vibra'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    verify(() => source.recordViews(['u1'])).called(1);

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    verify(() => source.setSaved('u1', saved: true)).called(1);
    expect(find.byTooltip('Saved'), findsOneWidget);
  });

  testWidgets('shared artists open a sheet that leads to their events', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Discover shared artists'));
    await tester.pumpAndSettle();
    expect(find.text('Artists you and Alex share'), findsOneWidget);
    expect(find.text('Find events'), findsNWidgets(2));
  });

  testWidgets('saved tab lists saved people without Send Vibra', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Robin'), findsOneWidget);
    expect(find.text('Send Vibra'), findsNothing);
    await tester.tap(find.byTooltip('Saved'));
    await tester.pumpAndSettle();
    verify(() => source.setSaved('u9', saved: false)).called(1);
  });

  testWidgets('shared events are opt-in', (tester) async {
    await mount(tester);
    await tester.tap(find.text('Compare saved events'));
    await tester.pumpAndSettle();
    verify(() => source.setSharesEvents(true)).called(1);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.candidates(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failure, then Retry, shows the content', (tester) async {
      Future<List<FrequencyCandidate>> real() => source.candidates();
      final success = await real();
      when(real).thenThrow(Exception('temporary'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      when(real).thenAnswer((_) async => success);
      await tester.tap(find.byIcon(Icons.refresh_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(VibraErrorView), findsNothing);
      expect(find.text('Alex'), findsWidgets);
    });

    testWidgets('no data: the empty state, not a blank screen', (tester) async {
      when(() => source.candidates()).thenAnswer((_) async => []);

      await mount(tester);
      expect(find.byType(VibraEmptyView), findsWidgets);
      expect(find.byType(VibraErrorView), findsNothing);
    });
  });
}
