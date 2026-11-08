import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_daily_vibe_datasource.dart';
import 'package:vibra/domain/entities/music_reaction.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/widgets/music_reactions.dart';

class _Source extends Mock implements SupabaseDailyVibeDatasource {}

void main() {
  late _Source source;

  setUpAll(() => registerFallbackValue(DiscoverySource.vibe));

  setUp(() {
    source = _Source();
    when(() => source.discoveries()).thenAnswer((_) async => const []);
    when(() => source.discoveredUrls()).thenAnswer((_) async => const {});
    when(() => source.saveTrack(any(), any())).thenAnswer((_) async {});
  });

  Widget app(Widget child) => ProviderScope(
    overrides: [supabaseDailyVibeDatasourceProvider.overrideWithValue(source)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  );

  testWidgets('track reactions show their names, counts and selection', (
    tester,
  ) async {
    String? tapped;
    await tester.pumpWidget(
      app(
        ReactionChips(
          options: MusicReactions.track,
          counts: const {'underrated': 2},
          mine: const {'on_repeat'},
          onToggle: (r) => tapped = r,
        ),
      ),
    );
    for (final label in [
      'Fire',
      'Obsessed',
      'Underrated',
      'Classic',
      'New discovery',
      'On repeat',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('2'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(ReactionChip).last),
      matchesSemantics(
        label: 'On repeat',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.text('Classic'));
    expect(tapped, 'classic');
  });

  testWidgets('general reactions stay emoji-only; read-only hides unused', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const ReactionChips(
          options: MusicReactions.general,
          counts: {'heart': 1},
          mine: {},
          hideEmpty: true,
        ),
      ),
    );
    expect(find.byType(ReactionChip), findsOneWidget);
    expect(find.text('Love'), findsNothing);
    expect(find.text('❤️'), findsOneWidget);
  });

  testWidgets('picker returns the chosen musical reaction', (tester) async {
    String? picked;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showReactionPicker(
              context,
              options: MusicReactions.track,
              mine: const {},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('React to this song'), findsOneWidget);
    await tester.tap(find.text('Underrated'));
    await tester.pumpAndSettle();
    expect(picked, 'underrated');
  });

  testWidgets('save a song to Discoveries; already saved shows saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const SaveSongButton(
          source: DiscoverySource.post,
          id: 'p1',
          externalUrl: 'https://open.spotify.com/track/x',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to discoveries'));
    await tester.pumpAndSettle();
    verify(() => source.saveTrack(DiscoverySource.post, 'p1')).called(1);
    expect(find.text('Added to your Discoveries'), findsOneWidget);
    expect(find.text('In your discoveries'), findsOneWidget);

    when(
      () => source.discoveredUrls(),
    ).thenAnswer((_) async => {'https://open.spotify.com/track/y'});
    await tester.pumpWidget(
      app(
        const SaveSongButton(
          source: DiscoverySource.story,
          id: 's1',
          externalUrl: 'https://open.spotify.com/track/y',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('In your discoveries'), findsOneWidget);
  });

  testWidgets('a "New discovery" reaction offers to save the song', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => offerToSaveDiscovery(
              context,
              ref,
              reaction: 'new_discovery',
              turnedOn: true,
              source: DiscoverySource.vibe,
              id: 'v1',
              externalUrl: 'https://open.spotify.com/track/z',
            ),
            child: const Text('react'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('react'));
    await tester.pumpAndSettle();
    expect(
      find.text('A new discovery? Keep it in your Discoveries.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Add to discoveries'));
    await tester.pump();
    verify(() => source.saveTrack(DiscoverySource.vibe, 'v1')).called(1);
  });
}
