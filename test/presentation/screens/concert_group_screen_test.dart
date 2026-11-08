import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_circles_datasource.dart';
import 'package:vibra/domain/entities/circle.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/circles/circle_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseCirclesDatasource {}

final _event = Event(
  id: 'e1',
  externalId: 'tm',
  source: 'ticketmaster',
  name: 'Utopia Tour',
  artistName: 'Travis Scott',
  eventDate: DateTime(2026, 12, 12, 21),
);

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(() => source.currentUserId).thenReturn('me');
    when(() => source.myCircles()).thenAnswer(
      (_) async => const [
        Circle(
          id: 'g1',
          name: 'Travis Scott · Dec 12',
          basis: CircleBasis.concert,
          eventId: 'e1',
          memberCount: 3,
        ),
      ],
    );
    when(() => source.events('g1')).thenAnswer((_) async => [_event]);
    when(() => source.members('g1')).thenAnswer(
      (_) async => const [
        CircleMember(
          CirclePerson(id: 'me', username: 'me'),
          eventStatus: 'maybe',
        ),
        CircleMember(
          CirclePerson(id: 'a', username: 'ana'),
          isAdmin: true,
          eventStatus: 'going',
        ),
      ],
    );
    when(() => source.messages('g1')).thenAnswer(
      (_) => Stream.value([
        CircleMessage(
          id: 'm1',
          senderId: 'a',
          body: 'See you there',
          createdAt: DateTime(2026, 11, 7),
        ),
      ]),
    );
    when(() => source.pendingInvites('g1')).thenAnswer((_) async => []);
    when(() => source.setEventStatus(any(), any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseCirclesDatasourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: CircleScreen(circleId: 'g1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('concert header: the event and my status for the group', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Your status'), findsOneWidget);
    expect(find.text('Only members of this group see it.'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Going'));
    await tester.pumpAndSettle();
    verify(() => source.setEventStatus('g1', 'going')).called(1);
  });

  testWidgets('members show status; non-admins can report or block', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('Admin · Going'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'ana'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Report member'), findsOneWidget);
    expect(find.text('Block user'), findsOneWidget);
    expect(find.text('Ban from group'), findsNothing);
  });

  testWidgets('long-press a message to report it (not an admin)', (
    tester,
  ) async {
    await mount(tester);
    await tester.longPress(find.text('See you there'));
    await tester.pumpAndSettle();
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Remove (admin)'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.myCircles(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
