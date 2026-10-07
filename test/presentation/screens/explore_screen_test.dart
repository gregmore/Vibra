import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/location_provider.dart';
import 'package:vibra/presentation/providers/map_events_provider.dart';
import 'package:vibra/presentation/screens/explore/explore_screen.dart';

import '../../helpers/test_http_overrides.dart';

class MapEventsTestTracker {
  static double lastRadius = 0;
  static int fetchCallCount = 0;
  static bool isLoading = true;
  static Timer? debounceTimer;
}

class MockMapEventsNotifier extends AutoDisposeAsyncNotifier<List<Event>>
    implements MapEventsNotifier {
  @override
  FutureOr<List<Event>> build() {
    ref.onDispose(() => MapEventsTestTracker.debounceTimer?.cancel());
    if (MapEventsTestTracker.isLoading) {
      return Future.value(
        [],
      ); // Inizialmente array vuoto, useremo il return state = AsyncLoading() dal test
    }
    return [
      Event(
        id: 'test-event-1',
        externalId: 'ext-test',
        source: 'mock',
        name: 'Bicep Live Set',
        latitude: 45.4642,
        longitude: 9.1900,
        eventDate: DateTime.now(),
        imageUrl: '',
      ),
    ];
  }

  @override
  void updateLocation(double lat, double lng, double radiusInMeters) {
    MapEventsTestTracker.lastRadius = radiusInMeters;
    MapEventsTestTracker.debounceTimer?.cancel();
    MapEventsTestTracker.debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        MapEventsTestTracker.fetchCallCount++;
        state = AsyncData([
          Event(
            id: 'evt-1',
            externalId: 'ext-1',
            source: 'mock',
            name: 'Mock Concert',
            latitude: lat + 0.001,
            longitude: lng + 0.001,
            eventDate: DateTime.now(),
          ),
        ]);
      },
    );
  }

  @override
  Future<void> refresh() async {}

  // Metodo per forzare lo stato dall'esterno nei test.
  void forceLoading() {
    state = const AsyncLoading();
  }

  void forceData() {
    state = AsyncData([
      Event(
        id: 'test-event-1',
        externalId: 'ext-test',
        source: 'mock',
        name: 'Bicep Live Set',
        latitude: 45.4642,
        longitude: 9.1900,
        eventDate: DateTime.now(),
        imageUrl: '',
      ),
    ]);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
    MapEventsTestTracker.debounceTimer?.cancel();
  });

  setUp(() {
    MapEventsTestTracker.fetchCallCount = 0;
    MapEventsTestTracker.isLoading = true;
    MapEventsTestTracker.debounceTimer?.cancel();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        userLocationProvider.overrideWith((ref) => UserLocation.milano),
        mapEventsProvider.overrideWith(() => MockMapEventsNotifier()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('it'),
        home: ExploreScreen(),
      ),
    );
  }

  group('ExploreScreen Widget Tests & Performance', () {
    testWidgets(
      'Shows CircularProgressIndicator on initial load and renders Map with Markers',
      (WidgetTester tester) async {
        MapEventsTestTracker.isLoading = true;

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        MapEventsTestTracker.isLoading = false;
        // We need to rebuild or simulate state change. For now we use the element to get the container.
        final element = tester.element(find.byType(ExploreScreen));
        final container = ProviderScope.containerOf(element);
        container.read(mapEventsProvider.notifier).state = AsyncData([
          Event(
            id: 'test-event-1',
            externalId: 'ext-test',
            source: 'mock',
            name: 'Bicep Live Set',
            latitude: 45.4642,
            longitude: 9.1900,
            eventDate: DateTime.now(),
            imageUrl: '',
          ),
        ]);

        // The signal wave intentionally animates forever. Advance a bounded
        // number of frames instead of waiting for the widget tree to settle.
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.byType(MarkerClusterLayerWidget), findsOneWidget);

        await tester.tap(find.text('1 live in questa zona'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('TUTTI I GENERI'), findsOneWidget);
        expect(find.text('Bicep Live Set'), findsOneWidget);
        expect(find.byTooltip('Chiudi elenco eventi'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets('Zoom changes the search radius without a circle overlay', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 600));
      final initial = MapEventsTestTracker.lastRadius;
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      final controller = map.mapController!;
      expect(find.byType(CircleLayer), findsNothing);
      expect(find.text('© OpenStreetMap contributors'), findsNothing);

      controller.move(controller.camera.center, controller.camera.zoom - 1);
      await tester.pump(const Duration(milliseconds: 600));
      expect(MapEventsTestTracker.lastRadius, greaterThan(initial));
      final wide = MapEventsTestTracker.lastRadius;
      controller.move(controller.camera.center, controller.camera.zoom + 2);
      await tester.pump(const Duration(milliseconds: 600));
      expect(MapEventsTestTracker.lastRadius, lessThan(initial));
      expect(MapEventsTestTracker.lastRadius, lessThan(wide));
      expect(MapEventsTestTracker.fetchCallCount, 3);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('API Debouncing: Rapid map movements trigger only 1 API call', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final element = tester.element(find.byType(ExploreScreen));
      final container = ProviderScope.containerOf(element);
      final notifier = container.read(mapEventsProvider.notifier);

      MapEventsTestTracker.fetchCallCount = 0;

      // Movimento 1.
      notifier.updateLocation(45.4645, 9.1905, 10.5);
      await tester.pump(const Duration(milliseconds: 100));

      // Movimento 2.
      notifier.updateLocation(45.4650, 9.1910, 10.5);
      await tester.pump(const Duration(milliseconds: 100));

      // Movimento 3.
      notifier.updateLocation(45.4660, 9.1920, 10.5);
      await tester.pump(const Duration(milliseconds: 100));

      // Scade il timer di debounce (500ms).
      await tester.pump(const Duration(milliseconds: 600));

      expect(MapEventsTestTracker.fetchCallCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  });
}
