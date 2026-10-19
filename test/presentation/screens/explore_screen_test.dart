import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/location_provider.dart';
import 'package:vibra/presentation/providers/map_events_provider.dart';
import 'package:vibra/presentation/screens/explore/explore_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_openstreetmap_layer.dart';
import 'package:vibra/presentation/widgets/vibra_map_beacon.dart';

import '../../helpers/test_http_overrides.dart';

class MapEventsTestTracker {
  static double lastRadius = 0;
  static double lastLatitude = 0;
  static double lastLongitude = 0;
  static int fetchCallCount = 0;
  static int refreshCount = 0;
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
    MapEventsTestTracker.lastLatitude = lat;
    MapEventsTestTracker.lastLongitude = lng;
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
  Future<void> refresh() async {
    MapEventsTestTracker.refreshCount++;
  }

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
    MapEventsTestTracker.refreshCount = 0;
    MapEventsTestTracker.isLoading = true;
    MapEventsTestTracker.debounceTimer?.cancel();
  });

  Widget createTestWidget({
    Future<UserLocation>? location,
    Future<List<Location>> Function(String)? geocoder,
    String? initialQuery,
  }) {
    return ProviderScope(
      overrides: [
        userLocationProvider.overrideWith(
          (ref) => location ?? Future.value(UserLocation.milano),
        ),
        mapEventsProvider.overrideWith(() => MockMapEventsNotifier()),
        openStreetMapTileProvider.overrideWith((ref) => NetworkTileProvider()),
        if (geocoder != null)
          exploreGeocoderProvider.overrideWithValue(geocoder),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        home: ExploreScreen(initialQuery: initialQuery),
      ),
    );
  }

  Future<void> initializeMap(WidgetTester tester) async {
    // Map readiness schedules the first search after the initial frame. Run
    // that frame before advancing the request debounce, then flush row entry
    // animation timers created by the loaded events.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> showResults(WidgetTester tester) async {
    final scroll = tester.state<ScrollableState>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    // Dragging the viewport center pans its interactive map. Move the outer
    // scroll position directly when checking the results below the map.
    scroll.position.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
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

        final l10n = AppLocalizations.of(
          tester.element(find.byType(ExploreScreen)),
        )!;
        await tester.tap(find.text(l10n.exploreEventsInArea(1)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text(l10n.exploreGenreAll.toUpperCase()), findsOneWidget);
        expect(find.text('Bicep Live Set'), findsOneWidget);
        expect(find.byTooltip('Chiudi elenco eventi'), findsOneWidget);

        await unmount(tester);
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets('Zoom changes the search radius without a circle overlay', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await initializeMap(tester);
      final initial = MapEventsTestTracker.lastRadius;
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      final controller = map.mapController!;
      expect(find.byType(CircleLayer), findsNothing);
      expect(find.text('© OpenStreetMap'), findsOneWidget);

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
      await unmount(tester);
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

      await unmount(tester);
    });

    testWidgets('Late GPS positions recenter and search the visible map', (
      tester,
    ) async {
      final gps = Completer<UserLocation>();
      await tester.pumpWidget(createTestWidget(location: gps.future));
      await initializeMap(tester);
      gps.complete(const UserLocation(latitude: 41.9028, longitude: 12.4964));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final controller = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      expect(controller.camera.center.latitude, closeTo(41.9028, 0.0001));
      expect(MapEventsTestTracker.lastLatitude, closeTo(41.9028, 0.0001));
      expect(MapEventsTestTracker.lastLongitude, closeTo(12.4964, 0.0001));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('GPS cannot override a map the user has already moved', (
      tester,
    ) async {
      final gps = Completer<UserLocation>();
      await tester.pumpWidget(createTestWidget(location: gps.future));
      await initializeMap(tester);
      await tester.drag(find.byType(FlutterMap), const Offset(-100, 0));
      await tester.pump(const Duration(milliseconds: 400));
      final controller = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      final browsed = controller.camera.center;
      gps.complete(const UserLocation(latitude: 41.9028, longitude: 12.4964));
      await tester.pump();
      expect(controller.camera.center, browsed);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('Invalid GPS coordinates use the safe initial map area', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          location: Future.value(
            const UserLocation(latitude: 91, longitude: 181),
          ),
        ),
      );
      await initializeMap(tester);
      final controller = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      expect(controller.camera.center.latitude, closeTo(45.4642, 0.0001));
      expect(MapEventsTestTracker.lastLatitude, closeTo(45.4642, 0.0001));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('An initial artist search loads events if geocoding fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          initialQuery: 'Mock',
          geocoder: (_) => Future.error(Exception('Not a place')),
        ),
      );
      await initializeMap(tester);
      expect(MapEventsTestTracker.fetchCallCount, 1);
      expect(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ExploreScreen)),
          )!.exploreEventsInArea(1),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Mock',
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('Moving the map invalidates a pending place search', (
      tester,
    ) async {
      final rome = Completer<List<Location>>();
      await tester.pumpWidget(createTestWidget(geocoder: (_) => rome.future));
      await initializeMap(tester);
      await tester.enterText(find.byType(TextField), 'Roma');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.drag(find.byType(FlutterMap), const Offset(-100, 0));
      await tester.pump(const Duration(milliseconds: 400));
      final controller = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      final browsed = controller.camera.center;
      rome.complete([
        Location(
          latitude: 41.9028,
          longitude: 12.4964,
          timestamp: DateTime(2026),
        ),
      ]);
      await tester.pump();
      expect(controller.camera.center, browsed);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets(
      'The latest place search wins and clearing invalidates geocoding',
      (tester) async {
        final rome = Completer<List<Location>>();
        final paris = Completer<List<Location>>();
        final vienna = Completer<List<Location>>();
        await tester.pumpWidget(
          createTestWidget(
            geocoder: (query) => switch (query) {
              'Roma' => rome.future,
              'Parigi' => paris.future,
              _ => vienna.future,
            },
          ),
        );
        await initializeMap(tester);
        await tester.enterText(find.byType(TextField), 'Roma');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'Parigi');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        paris.complete([
          Location(
            latitude: 48.8566,
            longitude: 2.3522,
            timestamp: DateTime(2026),
          ),
        ]);
        await tester.pump();
        final controller = tester
            .widget<FlutterMap>(find.byType(FlutterMap))
            .mapController!;
        expect(controller.camera.center.latitude, closeTo(48.8566, 0.0001));
        await tester.enterText(find.byType(TextField), 'Vienna');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        await tester.tap(find.byTooltip('Cancella ricerca'));
        await tester.pump();
        vienna.complete([
          Location(
            latitude: 48.2082,
            longitude: 16.3738,
            timestamp: DateTime(2026),
          ),
        ]);
        await tester.pump(const Duration(milliseconds: 300));
        expect(controller.camera.center.latitude, closeTo(48.8566, 0.0001));
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
        rome.complete([
          Location(latitude: 41.9, longitude: 12.5, timestamp: DateTime(2026)),
        ]);
        await tester.pump();
        expect(controller.camera.center.latitude, closeTo(48.8566, 0.0001));
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );

    testWidgets(
      'Resetting an empty result expands the map around its current center',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await initializeMap(tester);
        final controller = tester
            .widget<FlutterMap>(find.byType(FlutterMap))
            .mapController!;
        controller.move(const LatLng(41.9, 12.5), 14);
        await tester.pump(const Duration(milliseconds: 600));
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreScreen)),
        );
        container.read(mapEventsProvider.notifier).state = const AsyncData([]);
        await tester.pump();
        await showResults(tester);
        await tester.tap(find.text('Mostra tutti gli eventi'));
        await tester.pump();
        expect(controller.camera.zoom, lessThan(14));
        expect(MapEventsTestTracker.lastLatitude, closeTo(41.9, 0.0001));
        expect(MapEventsTestTracker.lastRadius, greaterThan(90000));
        expect(MapEventsTestTracker.lastRadius, lessThanOrEqualTo(110000));
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );

    testWidgets(
      'Map load failures expose retry instead of an empty event result',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await initializeMap(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreScreen)),
        );
        container.read(mapEventsProvider.notifier).state = AsyncError(
          Exception('offline'),
          StackTrace.empty,
        );
        await tester.pump();
        await showResults(tester);
        expect(find.text('Gli eventi non si sono caricati.'), findsOneWidget);
        expect(find.text('Qui il segnale è ancora basso.'), findsNothing);
        await tester.tap(find.text('Riprova'));
        await tester.pump();
        expect(MapEventsTestTracker.refreshCount, 1);
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );

    testWidgets('A map marker opens the selected event through the router', (
      tester,
    ) async {
      MapEventsTestTracker.isLoading = false;
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const ExploreScreen()),
          GoRoute(
            path: '/event-detail',
            builder: (_, state) => Scaffold(
              body: Text('Dettaglio ${(state.extra as Event).name}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userLocationProvider.overrideWith((ref) => UserLocation.milano),
            mapEventsProvider.overrideWith(() => MockMapEventsNotifier()),
            openStreetMapTileProvider.overrideWith(
              (ref) => NetworkTileProvider(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byType(VibraMapBeacon));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Dettaglio Bicep Live Set'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  });
}
