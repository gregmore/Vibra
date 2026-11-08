import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/data/datasources/supabase_music_radar_datasource.dart';
import 'package:vibra/domain/entities/direct_message_permission.dart';
import 'package:vibra/domain/entities/music_radar.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/direct_message_permission_provider.dart';
import 'package:vibra/presentation/providers/location_provider.dart';
import 'package:vibra/presentation/screens/social/music_radar_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseMusicRadarDatasource {}

MusicRadar _radar(Map<String, Object?> json) =>
    MusicRadar.fromJson(json, parseEvent: (_) => null);

final _ok = _radar({
  'status': 'ok',
  'settings': {
    'enabled': true,
    'visible': true,
    'distance_km': 25,
    'precision': 'area',
    'location_consent': true,
    'matching_consent': true,
  },
  'compatible_count': 3,
  'area_genres': [
    {'family': 'electronic', 'share': 0.5},
    {'family': 'hip-hop', 'share': 0.3},
  ],
  'profiles': [
    {
      'user_id': 'u1',
      'username': 'alex',
      'display_name': 'Alex',
      'compatibility': 81,
      'details': {
        'shared_families': ['electronic'],
      },
    },
    {
      'user_id': 'u2',
      'username': 'sam',
      'display_name': 'Sam',
      'compatibility': 66,
      'details': {},
      'connection': 'accepted',
    },
  ],
});

void main() {
  if (!AppConstants.spotifyEnabled) return;
  late _Source source;

  setUp(() {
    source = _Source();
    when(
      () => source.updateSettings(
        enabled: any(named: 'enabled'),
        visible: any(named: 'visible'),
        distanceKm: any(named: 'distanceKm'),
        precision: any(named: 'precision'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseMusicRadarDatasourceProvider.overrideWithValue(source),
          userLocationProvider.overrideWith((ref) async => UserLocation.milano),
          directMessagePermissionProvider.overrideWith(
            (ref, id) async => DirectMessagePermission.friendshipRequired,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: MusicRadarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('off by default: explains privacy, then turns on', (
    tester,
  ) async {
    var enabled = false;
    when(() => source.radar()).thenAnswer(
      (_) async => enabled
          ? _ok
          : _radar({
              'status': 'disabled',
              'settings': {'enabled': false},
            }),
    );
    when(
      () => source.updateSettings(
        enabled: true,
        visible: any(named: 'visible'),
        distanceKm: any(named: 'distanceKm'),
        precision: any(named: 'precision'),
      ),
    ).thenAnswer((_) async => enabled = true);
    await mount(tester);
    expect(
      find.text(
        "Nobody sees your location or your distance: only that you're within their radius.",
      ),
      findsOneWidget,
    );
    expect(find.text('Radar settings'), findsNothing);
    await tester.tap(find.text('Turn on Music Radar'));
    await tester.pumpAndSettle();
    expect(find.text('3 compatible people within 25 km.'), findsOneWidget);
  });

  testWidgets('results: count, area sound, people, never a distance', (
    tester,
  ) async {
    when(() => source.radar()).thenAnswer((_) async => _ok);
    await mount(tester);
    expect(
      find.text('People near you who share your musical taste.'),
      findsOneWidget,
    );
    expect(find.text('The sound of your area'), findsOneWidget);
    expect(find.text('63%'), findsOneWidget); // 0.5 / 0.8
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    // Already connected: no Send Vibra for Sam, one for Alex.
    expect(find.text('Send Vibra'), findsOneWidget);
    // Nothing on screen reads like a per-person distance.
    expect(
      find.textContaining(RegExp(r'\d+(\.\d+)? ?(km|m) away')),
      findsNothing,
    );
  });

  testWidgets('settings: hide, distance and precision are saved', (
    tester,
  ) async {
    when(() => source.radar()).thenAnswer((_) async => _ok);
    await mount(tester);
    await tester.tap(find.text('Show me on the radar'));
    await tester.pumpAndSettle();
    verify(() => source.updateSettings(visible: false)).called(1);
    await tester.tap(find.text('10 km'));
    await tester.pumpAndSettle();
    verify(() => source.updateSettings(distanceKm: 10)).called(1);
    await tester.tap(find.text('Region (~20 km)'));
    await tester.pumpAndSettle();
    verify(
      () => source.updateSettings(precision: RadarPrecision.region),
    ).called(1);
  });

  testWidgets('without location consent it points to privacy controls', (
    tester,
  ) async {
    when(() => source.radar()).thenAnswer(
      (_) async => _radar({
        'status': 'location_needed',
        'settings': {'enabled': true},
      }),
    );
    await mount(tester);
    expect(find.text('Location needed'), findsOneWidget);
    expect(find.text('Open privacy controls'), findsOneWidget);
  });

  test('settings parse defensively', () {
    final s = RadarSettings.fromJson({'distance_km': 7, 'precision': 'gps'});
    expect(s.distanceKm, 25);
    expect(s.precision, RadarPrecision.area);
    expect(s.enabled, isFalse);
    expect(_radar({'status': 'weird'}).status, RadarStatus.disabled);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.radar(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
