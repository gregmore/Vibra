import 'package:vibra/core/constants/app_constants.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_profile.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/spotify_auth_provider.dart';
import 'package:vibra/presentation/screens/profile/music_stats_screen.dart';

MusicProfile profile({bool connected = true, bool withGenres = false}) =>
    MusicProfile(
      id: 'profile',
      userId: 'user',
      topArtists: const [
        MusicArtistPreference(id: 'artist', name: 'Artista', score: 100),
      ],
      topTracks: const [],
      topGenres: withGenres
          ? const [GenrePreference(genre: 'italian hip hop', weight: 1)]
          : const [],
      lastSyncedAt: connected ? DateTime(2026, 9, 7) : null,
    );

class FakeMusicProfileController extends StateNotifier<MusicProfile>
    implements MusicProfileController {
  FakeMusicProfileController(super.state);

  @override
  Future<void> refresh() async {}

  void update(MusicProfile value) => state = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSpotifyAuthNotifier extends SpotifyAuthNotifier {
  FakeSpotifyAuthNotifier(super.ref);

  int syncCalls = 0;
  Completer<void>? pending;
  void Function()? onSync;
  bool fail = false;
  String errorMessage = 'Connessione non disponibile';

  @override
  Future<void> syncSpotify() async {
    syncCalls++;
    state = const SpotifyAuthStatusState.syncingProfile();
    if (pending != null) await pending!.future;
    onSync?.call();
    state = fail
        ? SpotifyAuthStatusState.error(errorMessage)
        : const SpotifyAuthStatusState.success();
  }
}

void main() {
  // Exercise the retained integration with --dart-define=SPOTIFY_ENABLED=true.
  if (!AppConstants.spotifyEnabled) return;
  Future<FakeSpotifyAuthNotifier> mount(
    WidgetTester tester, {
    required FakeMusicProfileController music,
    Completer<void>? pending,
    bool fail = false,
  }) async {
    late FakeSpotifyAuthNotifier spotify;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myMusicProfileProvider.overrideWith((ref) => music),
          spotifyAuthProvider.overrideWith((ref) {
            spotify = FakeSpotifyAuthNotifier(ref)
              ..pending = pending
              ..fail = fail;
            return spotify;
          }),
        ],
        child: const MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MusicStatsScreen(),
        ),
      ),
    );
    await tester.pump();
    return spotify;
  }

  testWidgets('opening stats syncs once and disables refresh until completed', (
    tester,
  ) async {
    final pending = Completer<void>();
    final music = FakeMusicProfileController(profile());
    final spotify = await mount(tester, music: music, pending: pending);
    expect(spotify.syncCalls, 1);
    final refresh = find.byType(IconButton);
    expect(tester.widget<IconButton>(refresh).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.tap(refresh);
    expect(spotify.syncCalls, 1);
    spotify.onSync = () => music.update(profile(withGenres: true));
    pending.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<IconButton>(refresh).onPressed, isNotNull);
    expect(find.text('Artista'), findsOneWidget);
    expect(find.text('La tua grammatica musicale'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toolbar refreshes and shows success', (tester) async {
    final spotify = await mount(
      tester,
      music: FakeMusicProfileController(profile()),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.sync_rounded));
    await tester.pump();
    expect(spotify.syncCalls, 2);
    expect(find.text('Statistiche musicali aggiornate.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sync errors are visible and keep the existing stats', (
    tester,
  ) async {
    await mount(
      tester,
      music: FakeMusicProfileController(profile(withGenres: true)),
      fail: true,
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Connessione non disponibile'), findsOneWidget);
    expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    expect(find.text('Artista'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'missing connection offers reconnect without hiding saved stats',
    (tester) async {
      final pending = Completer<void>();
      final spotify = await mount(
        tester,
        music: FakeMusicProfileController(profile()),
        pending: pending,
        fail: true,
      );
      spotify.errorMessage = 'spotify_not_connected';
      pending.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Ricollega Spotify per aggiornare le statistiche musicali.'),
        findsOneWidget,
      );
      expect(find.text('Ricollega'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unconnected users are not synchronized', (tester) async {
    final spotify = await mount(
      tester,
      music: FakeMusicProfileController(profile(connected: false)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(spotify.syncCalls, 0);
    expect(find.text('Connetti Spotify'), findsOneWidget);
    expect(find.byIcon(Icons.sync_rounded), findsNothing);
  });
}
