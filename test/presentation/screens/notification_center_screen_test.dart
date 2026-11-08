import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_notification_center_datasource.dart';
import 'package:vibra/domain/entities/inbox_notification.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/notifications/notification_center_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseNotificationCenterDatasource {}

class _Push extends StateNotifier<bool> implements PushEnabledController {
  _Push() : super(true);
  @override
  dynamic noSuchMethod(Invocation i) => null;
}

void main() {
  late _Source source;
  setUpAll(() => registerFallbackValue(NotificationCategory.updates));

  setUp(() {
    source = _Source();
    when(() => source.list(before: any(named: 'before'))).thenAnswer(
      (_) async => [
        InboxNotification(
          id: 'n1',
          type: 'feed_comment',
          category: NotificationCategory.social,
          title: 'Ana commented on your post',
          body: 'Great pick',
          groupCount: 3,
          actorName: 'Ana',
          createdAt: DateTime.now(),
        ),
        InboxNotification(
          id: 'n2',
          type: 'event_reminder',
          category: NotificationCategory.reminders,
          title: 'Tomorrow is the day!',
          body: 'Rap Night',
          read: true,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ],
    );
    when(() => source.unreadCount()).thenAnswer((_) async => 1);
    when(() => source.markRead(any())).thenAnswer((_) async {});
    when(() => source.markRead()).thenAnswer((_) async {});
    when(() => source.settings()).thenAnswer(
      (_) async => const NotificationSettings(
        categories: {NotificationCategory.recommendations: false},
      ),
    );
    when(() => source.setCategory(any(), any())).thenAnswer((_) async {});
    when(
      () => source.setSchedule(
        quietStart: any(named: 'quietStart'),
        quietEnd: any(named: 'quietEnd'),
        dailyCap: any(named: 'dailyCap'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(900, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseNotificationCenterDatasourceProvider.overrideWithValue(
            source,
          ),
          pushEnabledProvider.overrideWith((ref) => _Push()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('groups by day, shows grouped counts, marks all read', (
    tester,
  ) async {
    await mount(tester, const NotificationCenterScreen());
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('Ana commented on your post'), findsOneWidget);
    expect(find.textContaining('3 updates'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Unread, Ana commented')),
      findsOneWidget,
    );
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    verify(() => source.markRead()).called(1);
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('preferences: every category, quiet hours and a daily limit', (
    tester,
  ) async {
    await mount(tester, const NotificationSettingsScreen());
    for (final label in [
      'Vibra requests',
      'Messages',
      'Community activity',
      'Circles',
      'Concert announcements',
      'Event reminders',
      'Recommendations',
      'Daily Vibe, stories and posts',
      'Musical discoveries',
      'VIBRA updates',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.textContaining('At most one push a day.'), findsNWidgets(4));
    expect(find.text('Quiet hours'), findsOneWidget);
    expect(find.text('At most 20 pushes a day'), findsOneWidget);
    expect(find.textContaining("isn't set up on this device"), findsOneWidget);
    // Recommendations are off; turn them on.
    await tester.tap(find.text('Recommendations'));
    await tester.pumpAndSettle();
    verify(
      () => source.setCategory(NotificationCategory.recommendations, true),
    ).called(1);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.list(before: any(named: 'before')),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester, const NotificationCenterScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no data: the empty state, not a blank screen', (tester) async {
      when(
        () => source.list(before: any(named: 'before')),
      ).thenAnswer((_) async => []);

      await mount(tester, const NotificationCenterScreen());
      expect(find.byType(VibraEmptyView), findsWidgets);
      expect(find.byType(VibraErrorView), findsNothing);
    });
  });
}
