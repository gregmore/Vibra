import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_daily_vibe_datasource.dart';
import 'package:vibra/domain/entities/daily_vibe.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/vibes/daily_vibe_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseDailyVibeDatasource {}

const _track = VibeTrack(
  provider: 'spotify',
  trackId: '2xLMifQCjDGFmkHkpNLD9h',
  title: 'SICKO MODE',
  artist: 'Travis Scott, Drake',
  album: 'ASTROWORLD',
  externalUrl: 'https://open.spotify.com/track/2xLMifQCjDGFmkHkpNLD9h',
);

DailyVibe _vibe(String id, String user, {bool saved = false}) => DailyVibe(
  id: id,
  userId: user,
  username: user,
  track: _track,
  caption: 'Friday energy',
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(const Duration(hours: 20)),
  reactions: const {'fire': 3},
  saved: saved,
);

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(() => source.currentUserId).thenReturn('me');
    when(() => source.feed()).thenAnswer((_) async => [_vibe('v1', 'ana')]);
    when(() => source.search(any())).thenAnswer((_) async => [_track]);
    when(
      () => source.postSpotify(
        any(),
        caption: any(named: 'caption'),
        expires: any(named: 'expires'),
        everyone: any(named: 'everyone'),
      ),
    ).thenAnswer((_) async {});
    when(() => source.saveToDiscoveries(any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDailyVibeDatasourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: DailyVibeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a vibe shows song, caption, attribution and a link out', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text("What's your vibe today?"), findsOneWidget);
    expect(find.text('SICKO MODE'), findsOneWidget);
    expect(find.text('Travis Scott, Drake'), findsOneWidget);
    expect(find.text('Friday energy'), findsOneWidget);
    expect(find.text('Listen on Spotify'), findsOneWidget);
    expect(find.text('Song info and artwork from Spotify'), findsOneWidget);
    expect(find.textContaining('20h left'), findsOneWidget);
  });

  testWidgets('add to discoveries', (tester) async {
    await mount(tester);
    await tester.tap(find.text('Add to discoveries'));
    await tester.pumpAndSettle();
    verify(() => source.saveToDiscoveries('v1')).called(1);
    expect(find.text('In your discoveries'), findsOneWidget);
  });

  testWidgets('share: search Spotify, pick a song, post with expiry', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Share your vibe'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'sicko');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.text('SICKO MODE').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post vibe'));
    await tester.pumpAndSettle();
    verify(
      () => source.postSpotify(
        '2xLMifQCjDGFmkHkpNLD9h',
        caption: null,
        expires: true,
        everyone: false,
      ),
    ).called(1);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.feed(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no data: the empty state, not a blank screen', (tester) async {
      when(() => source.feed()).thenAnswer((_) async => []);

      await mount(tester);
      expect(find.byType(VibraEmptyView), findsWidgets);
      expect(find.byType(VibraErrorView), findsNothing);
    });
  });
}
