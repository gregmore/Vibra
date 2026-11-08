import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_circles_datasource.dart';
import 'package:vibra/data/datasources/supabase_event_social_datasource.dart';
import 'package:vibra/domain/entities/circle.dart';
import 'package:vibra/domain/entities/concert_match.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/explore/concert_match_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Social extends Mock implements SupabaseEventSocialDatasource {}

class _Circles extends Mock implements SupabaseCirclesDatasource {}

const _id = '22222222-2222-2222-2222-222222222222';
final _event = Event(
  id: _id,
  externalId: 'tm',
  source: 'ticketmaster',
  name: 'Utopia Tour',
  artistName: 'Travis Scott',
  eventDate: DateTime(2026, 12, 12, 21),
);

void main() {
  late _Social social;
  late _Circles circles;

  setUpAll(() => registerFallbackValue(CircleBasis.concert));

  setUp(() {
    social = _Social();
    circles = _Circles();
    when(() => social.concertMatches(_id)).thenAnswer(
      (_) async => ConcertMatch.fromJson({
        'my_status': 'going',
        'interested_count': 4,
        'people': [
          {
            'user_id': 'a',
            'username': 'ana',
            'status': 'going',
            'compatibility': 88,
            'can_invite': true,
          },
          {
            'user_id': 'b',
            'username': 'ben',
            'status': 'interested',
            'connection': 'accepted',
            'is_friend': true,
            'can_invite': true,
          },
          {
            'user_id': 'c',
            'username': 'cyd',
            'artist_fan': true,
            'compatibility': 71,
            'can_invite': true,
          },
          {'user_id': 'd', 'username': 'dee', 'status': 'maybe'},
        ],
      }),
    );
    when(
      () => circles.create(
        name: any(named: 'name'),
        description: any(named: 'description'),
        basis: any(named: 'basis'),
        genreKey: any(named: 'genreKey'),
        artistName: any(named: 'artistName'),
        eventId: any(named: 'eventId'),
        topic: any(named: 'topic'),
      ),
    ).thenAnswer((_) async => 'circle1');
    when(() => circles.invite(any(), any())).thenAnswer((_) async {});
    when(() => circles.myCircles()).thenAnswer((_) async => []);
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEventSocialDatasourceProvider.overrideWithValue(social),
          supabaseCirclesDatasourceProvider.overrideWithValue(circles),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ConcertMatchScreen(event: _event),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('headline, reasons, and connect only as allowed', (tester) async {
    await mount(tester);
    expect(
      find.text('You and 4 other people are interested in this concert.'),
      findsOneWidget,
    );
    expect(find.text('Going · 88% affinity'), findsOneWidget);
    // An artist fan: no attendance is shown for them.
    expect(find.text('Also loves Travis Scott · 71% affinity'), findsOneWidget);
    // Conversation only with an accepted connection.
    expect(find.byTooltip('Message'), findsOneWidget);
    expect(find.text('Send Vibra'), findsNWidgets(3));
    // Only invitable people get a checkbox (Dee is visible but not invitable).
    expect(find.byType(Checkbox), findsNWidgets(3));
  });

  testWidgets('an event group is a concert circle plus invitations', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create event group (2)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    verify(
      () => circles.create(
        name: 'Travis Scott · Dec 12',
        description: '',
        basis: CircleBasis.concert,
        eventId: _id,
      ),
    ).called(1);
    verify(() => circles.invite('circle1', 'a')).called(1);
    verify(() => circles.invite('circle1', 'c')).called(1);
    verifyNever(() => circles.invite('circle1', 'b'));
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => social.concertMatches(_id),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester);
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
