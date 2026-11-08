import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/usecases/events_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/event_detail/event_detail_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_openstreetmap_layer.dart';

import '../../helpers/test_http_overrides.dart';

class _Attendance implements GetMyEventAttendanceUseCase {
  @override
  Future<String?> call(Event event) async => null;
}

class _Matches extends StateNotifier<List<MatchedUserPreview>>
    implements MatchedUsersController {
  _Matches() : super([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => HttpOverrides.global = TestHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  const launcher = MethodChannel('plugins.flutter.io/url_launcher');
  final event = Event(
    id: 'test',
    externalId: 'test',
    source: 'test',
    name: 'Concerto',
    eventDate: DateTime(2026, 10, 20),
    ticketUrl: 'https://tickets.example/show',
  );

  Future<void> mount(WidgetTester tester, {Event? selectedEvent}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          featuredEventsProvider.overrideWithValue([]),
          matchedUsersProvider.overrideWith((ref) => _Matches()),
          getMyEventAttendanceUseCaseProvider.overrideWithValue(_Attendance()),
          openStreetMapTileProvider.overrideWith(
            (ref) => NetworkTileProvider(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: EventDetailScreen(event: selectedEvent ?? event),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Missing coordinates show an explanation instead of a false map',
    (tester) async {
      await mount(tester);
      expect(find.byType(FlutterMap), findsNothing);
      expect(
        find.text('La posizione esatta non è ancora disponibile.'),
        findsOneWidget,
      );
      expect(find.textContaining('null'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Failed ticket opening gives feedback and leaves the button usable',
    (tester) async {
      var launchCalls = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(launcher, (
        call,
      ) async {
        if (call.method == 'launch') {
          launchCalls++;
          return false;
        }
        return false;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          launcher,
          null,
        ),
      );
      await mount(tester);
      await tester.scrollUntilVisible(find.text('Acquista Biglietti'), 200);
      await tester.tap(find.text('Acquista Biglietti'));
      await tester.pumpAndSettle();
      expect(launchCalls, 1);
      expect(
        find.text('Impossibile aprire il link del biglietto.'),
        findsOneWidget,
      );
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('The event map opens directions and the visible attribution', (
    tester,
  ) async {
    final urls = <Uri>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(launcher, (
      call,
    ) async {
      if (call.method == 'launch') {
        urls.add(Uri.parse((call.arguments as Map)['url'] as String));
        return true;
      }
      return false;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        launcher,
        null,
      ),
    );
    await mount(
      tester,
      selectedEvent: Event(
        id: 'mapped',
        externalId: 'mapped',
        source: 'test',
        name: 'Concerto sulla mappa',
        eventDate: DateTime(2026, 10, 20),
        latitude: 41.9,
        longitude: 12.5,
      ),
    );
    await tester.scrollUntilVisible(find.byType(FlutterMap), 200);
    await tester.tap(find.byType(FlutterMap));
    await tester.pump(const Duration(milliseconds: 400));
    expect(urls.single.queryParameters['destination'], '41.9,12.5');
    expect(urls.single.host, 'www.google.com');
    await tester.tap(find.text('© OpenStreetMap'));
    await tester.pumpAndSettle();
    expect(urls.last, Uri.https('www.openstreetmap.org', '/copyright'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Copy sends clean details to the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await mount(tester);
    await tester.scrollUntilVisible(
      find.byTooltip('Copia i dettagli dell’evento'),
      200,
    );
    await tester.tap(find.byTooltip('Copia i dettagli dell’evento'));
    await tester.pumpAndSettle();
    expect(copied, contains('20 ott 2026'));
    expect(copied, contains('https://tickets.example/show'));
    expect(copied, isNot(contains('null')));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Unavailable events offer a route back to exploration', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/event-detail',
      routes: [
        GoRoute(
          path: '/event-detail',
          builder: (context, state) => const EventDetailScreen(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) =>
              const Scaffold(body: Text('Esplorazione')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          featuredEventsProvider.overrideWithValue([]),
          matchedUsersProvider.overrideWith((ref) => _Matches()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eventi'));
    await tester.pumpAndSettle();
    expect(find.text('Esplorazione'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
