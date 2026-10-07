import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/screens/profile/my_events_screen.dart';

class _TestEventsController
    extends StateNotifier<({List<Event> going, List<Event> saved})>
    implements UserEventsController {
  _TestEventsController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();
  Event event(String id, int days, {String? artist, String? venue}) => Event(
    id: id,
    externalId: id,
    source: 'test',
    name: id,
    artistName: artist,
    venueName: venue,
    city: 'Roma',
    eventDate: now.add(Duration(days: days)),
  );
  final concert = event('Concerto confermato', 2, artist: 'Calcutta');
  final saved = event('Festival salvato', 4, venue: 'Auditorium');
  final past = event('Concerto passato', -2);

  Future<void> mount(
    WidgetTester tester, {
    bool empty = false,
    Locale locale = const Locale('it'),
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myEventsProvider.overrideWith(
            (ref) => _TestEventsController((
              going: empty ? [] : [concert, past],
              saved: empty ? [] : [concert, saved],
            )),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const MyEventsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Agenda deduplicates events and separates saved and history', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('In arrivo (2)'), findsOneWidget);
    expect(find.text('Concerto confermato'), findsOneWidget);
    expect(find.text('Festival salvato'), findsOneWidget);
    expect(find.text('Concerto passato'), findsNothing);
    await tester.tap(find.text('Passati (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Concerto passato'), findsOneWidget);
    expect(find.text('Concerto confermato'), findsNothing);
    await tester.tap(find.text('Salvati (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Festival salvato'), findsOneWidget);
    expect(find.text('Concerto passato'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Search matches artists and venues and can recover from no results',
    (tester) async {
      await mount(tester);
      await tester.enterText(find.byType(TextField), '  CALCUTTA  ');
      await tester.pumpAndSettle();
      expect(find.text('Concerto confermato'), findsOneWidget);
      expect(find.text('Festival salvato'), findsNothing);
      await tester.enterText(find.byType(TextField), 'auditorium');
      await tester.pumpAndSettle();
      expect(find.text('Festival salvato'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'inesistente');
      await tester.pumpAndSettle();
      expect(
        find.text('Nessun evento corrisponde alla ricerca.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Cancella ricerca'));
      await tester.pumpAndSettle();
      expect(find.text('Concerto confermato'), findsOneWidget);
      expect(find.text('Festival salvato'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Empty state stays usable on a narrow screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(
      tester,
      empty: true,
      locale: const Locale('de'),
      textScale: 1.5,
    );
    expect(find.text('Events entdecken'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
