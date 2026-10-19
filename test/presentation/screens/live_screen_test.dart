import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/live_message.dart';
import 'package:vibra/domain/usecases/live_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/live_events_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/live/live_screen.dart';

class _Datasource extends Mock implements SupabaseDatasource {}

class _Stream implements StreamLiveMessagesUseCase {
  final requested = <String>[];
  bool fail = false;
  @override
  Stream<List<LiveMessage>> call(String eventId) {
    requested.add(eventId);
    if (fail) return Stream.error(StateError('offline'));
    return Stream.value([
      LiveMessage(
        id: 'new',
        eventId: eventId,
        userId: 'other',
        content: 'Newest $eventId',
        createdAt: DateTime(2026, 10, 13, 20),
      ),
      LiveMessage(
        id: 'old',
        eventId: eventId,
        userId: 'other',
        content: 'Oldest $eventId',
        createdAt: DateTime(2026, 10, 13, 19),
      ),
    ]);
  }
}

class _Send implements SendLiveMessageUseCase {
  final requested = <SendLiveMessageParams>[];
  Completer<LiveMessage>? _pending;
  // Construct the response where consumed, avoiding the setUp error-zone boundary.
  Completer<LiveMessage> get pending => _pending ??= Completer<LiveMessage>();
  @override
  Future<LiveMessage> call(SendLiveMessageParams params) {
    requested.add(params);
    return pending.future;
  }
}

void main() {
  final first = Event(
    id: 'first',
    externalId: 'first',
    source: 'ticketmaster',
    name: 'First concert',
    eventDate: DateTime(2026, 10, 13),
  );
  final target = Event(
    id: 'target',
    externalId: 'target',
    source: 'ticketmaster',
    name: 'Target concert',
    eventDate: DateTime(2026, 10, 13),
  );
  late _Stream stream;
  late _Send send;
  late _Datasource ds;

  setUp(() {
    stream = _Stream();
    send = _Send();
    ds = _Datasource();
    when(() => ds.currentUser).thenReturn(null);
  });

  Future<void> mount(
    WidgetTester tester, {
    List<Event>? events,
    String? eventId,
    String? attendance = 'going',
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDatasourceProvider.overrideWithValue(ds),
          liveEventsProvider.overrideWith(
            (ref) async => events ?? [first, target],
          ),
          liveAttendanceProvider.overrideWith(
            (ref, eventId) async => attendance,
          ),
          streamLiveMessagesUseCaseProvider.overrideWithValue(stream),
          sendLiveMessageUseCaseProvider.overrideWithValue(send),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: LiveScreen(initialEventId: eventId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Requested event scopes both the stream and sends; newest stays at bottom',
    (tester) async {
      await mount(tester, eventId: 'target');
      expect(stream.requested, ['target']);
      expect(find.text('Target concert'), findsOneWidget);
      expect(find.text('Newest target'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Newest target')).dy,
        greaterThan(tester.getTopLeft(find.text('Oldest target')).dy),
      );
      await tester.enterText(find.byType(TextField), 'Messaggio Live');
      await tester.pump();
      await tester.tap(
        find.byTooltip(
          lookupAppLocalizations(const Locale('it')).liveSendMessage,
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Nuova bozza');
      await tester.pump();
      expect(send.requested.single.eventId, 'target');
      expect(send.requested.single.content, 'Messaggio Live');
      send.pending.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Messaggio Live\n\nNuova bozza',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Unavailable requested event never falls back to a different chat',
    (tester) async {
      await mount(tester, events: [first], eventId: 'target');
      expect(stream.requested, isEmpty);
      expect(find.byType(TextField), findsNothing);
      expect(
        find.textContaining('questo evento non è disponibile'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Failed live stream exposes retry and reconnects same event', (
    tester,
  ) async {
    stream.fail = true;
    await mount(tester, eventId: 'target');
    expect(find.text('Connessione alla chat Live interrotta.'), findsOneWidget);
    stream.fail = false;
    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();
    expect(stream.requested, ['target', 'target']);
    expect(find.text('Newest target'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Unregistered attendee cannot send and sees explicit join action',
    (tester) async {
      await mount(tester, eventId: 'target', attendance: null);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton &&
                    widget.tooltip ==
                        lookupAppLocalizations(
                          const Locale('it'),
                        ).liveSendMessage,
              ),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Partecipa per scrivere nella chat'), findsOneWidget);
      expect(send.requested, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Live layout fits a narrow device with keyboard and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester, eventId: 'target');
    expect(tester.takeException(), isNull);
    expect(
      find.byTooltip(
        lookupAppLocalizations(const Locale('it')).liveSendMessage,
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
