import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_artist_discovery_datasource.dart';
import 'package:vibra/domain/entities/artist_recommendation.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/discovery/discover_artists_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseArtistDiscoveryDatasource {}

const _collab = ArtistRecommendation(
  artistId: 'A000000000000000000001',
  name: 'Don Toliver',
  bucket: DiscoveryBucket.collaboration,
  genres: ['rap', 'melodic rap'],
  seedArtist: 'Travis Scott',
);
const _underground = ArtistRecommendation(
  artistId: 'A000000000000000000002',
  name: 'Small Act',
  bucket: DiscoveryBucket.underground,
  sharedGenres: ['Trap'],
);
const _explore = ArtistRecommendation(
  artistId: 'A000000000000000000003',
  name: 'Soul Band',
  bucket: DiscoveryBucket.exploration,
  exploredGenre: 'R&B',
);

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(
      () => source.recommendations(refresh: any(named: 'refresh')),
    ).thenAnswer(
      (_) async => const ArtistDiscoveryResult(
        artists: [_collab, _underground, _explore],
      ),
    );
    when(() => source.markShown(any())).thenAnswer((_) async {});
    when(
      () => source.feedback(
        any(),
        reaction: any(named: 'reaction'),
        saved: any(named: 'saved'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseArtistDiscoveryDatasourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: DiscoverArtistsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows each kind of discovery with its reason', (tester) async {
    await mount(tester);
    expect(find.text('Don Toliver'), findsOneWidget);
    expect(find.text('Collaborated with Travis Scott'), findsOneWidget);
    expect(find.text('Shares your Trap'), findsOneWidget);
    expect(find.text('A step into R&B'), findsOneWidget);
    expect(find.text('UNDERGROUND'), findsOneWidget);
    verify(() => source.markShown(any())).called(1);
    // Filter by kind.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Underground'));
    await tester.pumpAndSettle();
    expect(find.text('Don Toliver'), findsNothing);
    expect(find.text('Small Act'), findsOneWidget);
  });

  testWidgets('not interested and already known remove the artist', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Not interested').first);
    await tester.pumpAndSettle();
    verify(
      () => source.feedback(
        _collab.artistId,
        reaction: ArtistReaction.notInterested,
        saved: null,
      ),
    ).called(1);
    expect(find.text('Don Toliver'), findsNothing);
    await tester.tap(find.text('Already know').first);
    await tester.pumpAndSettle();
    verify(
      () => source.feedback(
        _underground.artistId,
        reaction: ArtistReaction.known,
        saved: null,
      ),
    ).called(1);
    expect(find.text('Small Act'), findsNothing);
  });

  testWidgets('like and save for later keep the artist, marked', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Like').first);
    await tester.pumpAndSettle();
    verify(
      () => source.feedback(
        _collab.artistId,
        reaction: ArtistReaction.like,
        saved: null,
      ),
    ).called(1);
    expect(find.text('Got it: more like this'), findsOneWidget);
    await tester.tap(find.text('Save for later').first);
    await tester.pumpAndSettle();
    verify(
      () => source.feedback(
        _collab.artistId,
        reaction: ArtistReaction.like,
        saved: true,
      ),
    ).called(1);
    expect(find.text('Don Toliver'), findsOneWidget);
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    expect(chips.take(2).every((c) => c.selected), isTrue);
  });

  testWidgets('without a profile, suggests picking genres', (tester) async {
    when(
      () => source.recommendations(refresh: any(named: 'refresh')),
    ).thenAnswer(
      (_) async => const ArtistDiscoveryResult(emptyReason: 'no_profile'),
    );
    await mount(tester);
    expect(find.text('Pick genres'), findsOneWidget);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.recommendations(refresh: any(named: 'refresh')),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no data: the empty state, not a blank screen', (tester) async {
      when(
        () => source.recommendations(refresh: any(named: 'refresh')),
      ).thenAnswer((_) async => const ArtistDiscoveryResult(artists: []));

      await mount(tester);
      expect(find.byType(VibraEmptyView), findsWidgets);
      expect(find.byType(VibraErrorView), findsNothing);
    });
  });
}
