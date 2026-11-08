import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_safety_datasource.dart';
import 'package:vibra/domain/entities/safety.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/profile/safety_center_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseSafetyDatasource {}

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(() => source.overview()).thenAnswer(
      (_) async => const SafetyOverview(
        blockedCount: 2,
        locationProcessing: false,
        radarEnabled: true,
        radarVisible: false,
        hiddenStoryViewers: 1,
      ),
    );
    when(() => source.blocked()).thenAnswer(
      (_) async => [const BlockedUser(userId: 'b1', username: 'bo')],
    );
    when(() => source.unblock(any())).thenAnswer((_) async {});
    when(() => source.block(any())).thenAnswer((_) async {});
    when(() => source.reportUser(any(), any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseSafetyDatasourceProvider.overrideWithValue(source)],
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

  testWidgets('shows every control with its current state', (tester) async {
    await mount(tester, const SafetyCenterScreen());
    expect(find.text('Safety & privacy'), findsOneWidget);
    expect(find.text('2 people'), findsOneWidget);
    expect(find.text('On, hidden'), findsOneWidget);
    expect(find.textContaining('hidden from 1 person'), findsOneWidget);
    expect(find.text('Profile privacy'), findsOneWidget);
    expect(
      find.textContaining('Your exact position is never shown'),
      findsOneWidget,
    );
    expect(
      find.textContaining('You can report a person from their profile'),
      findsOneWidget,
    );
  });

  testWidgets('unblock asks first, then calls the server', (tester) async {
    await mount(tester, const BlockedUsersScreen());
    expect(find.text('bo'), findsOneWidget);
    await tester.tap(find.text('Unblock'));
    await tester.pumpAndSettle();
    expect(find.text('Unblock bo?'), findsOneWidget);
    await tester.tap(find.text('Unblock').last);
    await tester.pumpAndSettle();
    verify(() => source.unblock('b1')).called(1);
  });

  testWidgets('report and block a person; duplicates are explained', (
    tester,
  ) async {
    await mount(
      tester,
      Scaffold(
        body: Consumer(
          builder: (context, ref, _) => Column(
            children: [
              TextButton(
                onPressed: () => reportUserFlow(context, ref, 'u2'),
                child: const Text('report'),
              ),
              TextButton(
                onPressed: () => blockUserFlow(context, ref, 'u2', 'Cy'),
                child: const Text('block'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('report'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    verify(() => source.reportUser('u2', any())).called(1);
    expect(
      find.text('Thanks. Our team will review this report.'),
      findsOneWidget,
    );

    when(
      () => source.reportUser(any(), any()),
    ).thenThrow(Exception('duplicate_report'));
    await tester.tap(find.text('report'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    expect(find.text('You already reported this recently.'), findsOneWidget);

    await tester.tap(find.text('block'));
    await tester.pumpAndSettle();
    expect(find.text('Block Cy?'), findsOneWidget);
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();
    verify(() => source.block('u2')).called(1);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.overview(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester, const SafetyCenterScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
