import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_event_social_datasource.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/event_social.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/widgets/whos_going_section.dart';

class _Source extends Mock implements SupabaseEventSocialDatasource {}

const _id = '11111111-1111-1111-1111-111111111111';
final _event = Event(
  id: _id,
  externalId: 'tm1',
  source: 'ticketmaster',
  name: 'Live',
  eventDate: DateTime(2026, 12, 1),
);

void main() {
  late _Source source;

  setUpAll(() => registerFallbackValue(AttendanceVisibility.private));

  setUp(() {
    source = _Source();
    when(() => source.social(_id)).thenAnswer(
      (_) async => EventSocial.fromJson({
        'counts': {'going': 2, 'maybe': 0, 'interested': 1},
        'people': [
          {
            'user_id': 'f',
            'username': 'fri',
            'display_name': 'Fran',
            'status': 'going',
            'is_friend': true,
            'connection': 'accepted',
          },
          {
            'user_id': 'c',
            'username': 'cam',
            'display_name': 'Cam',
            'status': 'going',
            'compatibility': 84,
          },
          {
            'user_id': 'o',
            'username': 'oli',
            'display_name': 'Oli',
            'status': 'interested',
          },
          {'user_id': 'x', 'username': 'xx', 'status': 'not_going'},
        ],
        'communities': [
          {'id': 'c1', 'name': 'Trap Nation', 'member_count': 120},
        ],
      }),
    );
    when(() => source.mine(_id)).thenAnswer(
      (_) async => MyAttendance.fromJson({
        'status': 'going',
        'visibility': null,
        'default_visibility': 'private',
      }),
    );
    when(
      () => source.setVisibility(
        any(),
        any(),
        makeDefault: any(named: 'makeDefault'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEventSocialDatasourceProvider.overrideWithValue(source),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SingleChildScrollView(child: WhosGoingSection(event: _event)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('groups friends, compatible people and others; drops not_going', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text("Who's going?"), findsOneWidget);
    expect(find.text('2 going · 1 interested'), findsOneWidget);
    expect(find.text('FRIENDS'), findsOneWidget);
    expect(find.text('COMPATIBLE PEOPLE'), findsOneWidget);
    expect(find.text('OTHERS'), findsOneWidget);
    expect(find.text('Going · 84% affinity'), findsOneWidget);
    expect(find.text('xx'), findsNothing);
    // Connected friend: no Send Vibra; Cam and Oli: one each.
    expect(find.text('Send Vibra'), findsNWidgets(2));
    expect(find.text('Trap Nation'), findsOneWidget);
    // My plans are private by default, and I can change that.
    expect(find.text('Only me'), findsOneWidget);
  });

  testWidgets('visibility can be set per event or as the default', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Who can see your plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Friends & matches'));
    await tester.tap(find.text('Use for all my events'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    verify(
      () => source.setVisibility(
        _id,
        AttendanceVisibility.matches,
        makeDefault: true,
      ),
    ).called(1);
  });

  testWidgets('an event nobody saved yet shows nothing', (tester) async {
    when(
      () => source.catalogueId(
        source: any(named: 'source'),
        externalId: any(named: 'externalId'),
      ),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseEventSocialDatasourceProvider.overrideWithValue(source),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WhosGoingSection(
              event: Event(
                id: 'bandsintown-42',
                externalId: '42',
                source: 'bandsintown',
                name: 'X',
                eventDate: DateTime(2026, 12, 1),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Who's going?"), findsNothing);
    verifyNever(() => source.social(any()));
  });
}
