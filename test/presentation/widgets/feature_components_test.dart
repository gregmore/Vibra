import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/core/errors/offline.dart';
import 'package:vibra/domain/entities/circle.dart';
import 'package:vibra/domain/entities/inbox_notification.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/domain/entities/music_story.dart';
import 'package:vibra/domain/entities/same_frequency.dart';
import 'package:vibra/domain/entities/taste_evolution.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/widgets/common/vibra_page_scaffold.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';
import 'package:vibra/presentation/widgets/vibra_feature_components.dart';

/// Reusable feature components and screen states (docs/ui-architecture.md).
void main() {
  Widget app(Widget child, {Size? size}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  FrequencyCandidate person(String id, int score) => FrequencyCandidate(
    userId: id,
    username: id,
    displayName: 'Person $id',
    compatibility: score,
    affinity: AffinityDetails.empty,
  );

  group('offline detection', () {
    test('network failures are offline, server errors are not', () {
      expect(isOfflineError(const NetworkException(message: 'x')), isTrue);
      expect(isOfflineError(TimeoutException('slow')), isTrue);
      expect(
        isOfflineError(Exception('ClientException: Failed host lookup')),
        isTrue,
      );
      expect(isOfflineError(Exception('XMLHttpRequest error.')), isTrue);
      expect(isOfflineError(Exception('permission denied for table')), isFalse);
      expect(isOfflineError(null), isFalse);
    });

    testWidgets('the error view switches to the offline state', (tester) async {
      await tester.pumpWidget(
        app(
          VibraErrorView(
            error: const NetworkException(message: 'down'),
            title: 'Circles',
            message: 'Circles could not be loaded.',
            onRetry: () {},
          ),
        ),
      );
      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text('Circles'), findsNothing);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.pumpWidget(
        app(
          VibraErrorView(
            error: Exception('boom'),
            title: 'Circles',
            message: 'Circles could not be loaded.',
          ),
        ),
      );
      expect(find.text('Circles'), findsOneWidget);
      expect(find.text("You're offline"), findsNothing);
    });
  });

  group('MusicRadarMap', () {
    test('placement encodes affinity only, never location', () {
      final close = MusicRadarMap.placement('a', 95);
      final far = MusicRadarMap.placement('a', 20);
      expect(close.distance, lessThan(far.distance));
      // Same id, same angle; stable between runs.
      expect(
        math.atan2(close.dy, close.dx),
        closeTo(math.atan2(far.dy, far.dx), 1e-9),
      );
      expect(
        MusicRadarMap.placement('a', 95),
        MusicRadarMap.placement('a', 95),
      );
      for (final s in [0, 50, 100]) {
        expect(
          MusicRadarMap.placement('z$s', s).distance,
          lessThanOrEqualTo(1),
        );
      }
    });

    testWidgets('draws at most maxPeople, highest affinity first', (
      tester,
    ) async {
      FrequencyCandidate? tapped;
      await tester.pumpWidget(
        app(
          MusicRadarMap(
            people: [for (var i = 0; i < 5; i++) person('u$i', 50 + i * 10)],
            maxPeople: 3,
            onTapPerson: (p) => tapped = p,
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Affinity map with 3 people'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Person u4, 90% affinity'), findsOneWidget);
      expect(find.bySemanticsLabel('Person u0, 50% affinity'), findsNothing);
      expect(find.textContaining('never where anyone is'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Person u4, 90% affinity'));
      expect(tapped?.userId, 'u4');
      // Nobody hides anybody: every centre is at least one avatar apart.
      final shown = [for (var i = 4; i >= 2; i--) person('u$i', 50 + i * 10)];
      final centres = MusicRadarMap.layout(shown, 360, 18);
      for (var i = 0; i < centres.length; i++) {
        for (var j = i + 1; j < centres.length; j++) {
          expect((centres[i] - centres[j]).distance, greaterThanOrEqualTo(36));
        }
      }
    });
  });

  testWidgets('VibraCircleCard shows the circle and its muted state', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        VibraCircleCard(
          circle: const Circle(
            id: 'c1',
            name: 'Night drives',
            basis: CircleBasis.genre,
            memberCount: 4,
            muted: true,
          ),
          onTap: () => taps++,
        ),
      ),
    );
    expect(find.text('Night drives'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Notifications muted')),
      findsOneWidget,
    );
    await tester.tap(find.text('Night drives'));
    expect(taps, 1);
  });

  testWidgets('NotificationCard reads as one button with its text', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        NotificationCard(
          notification: InboxNotification(
            id: 'n1',
            type: 'follow',
            category: NotificationCategory.requests,
            title: 'New follower',
            body: 'Ada follows you',
            createdAt: DateTime(2026, 11, 8, 14, 5),
            groupCount: 3,
          ),
          time: '14:05',
          onTap: () => taps++,
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Unread, New follower, Ada follows you'),
      findsOneWidget,
    );
    expect(find.textContaining('14:05'), findsOneWidget);
    await tester.tap(find.text('New follower'));
    expect(taps, 1);
  });

  testWidgets('MusicStoryCard is a 9:16 thumbnail with its age', (
    tester,
  ) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      app(
        MusicStoryCard(
          story: MusicStory(
            id: 's1',
            userId: 'u1',
            username: 'ada',
            displayName: 'Ada',
            kind: StoryKind.artist,
            body: 'On repeat',
            createdAt: now.subtract(const Duration(hours: 3)),
            expiresAt: now.add(const Duration(hours: 21)),
          ),
          onTap: () {},
        ),
      ),
    );
    expect(find.text('3h'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Music story by Ada: .*, 3 h ago$')),
      findsOneWidget,
    );
    final size = tester.getSize(find.byType(MusicStoryCard));
    expect(size.height / size.width, closeTo(16 / 9, 0.01));
  });

  testWidgets('TasteEvolutionChart draws nothing without two snapshots', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const TasteEvolutionChart(
          evolution: TasteEvolution(tracking: true, days: 90, snapshotCount: 1),
        ),
      ),
    );
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('pages keep a readable width on tablets', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const key = Key('content');
    await tester.pumpWidget(
      MaterialApp(
        home: VibraPageScaffold(child: Container(key: key)),
      ),
    );
    expect(
      tester.getSize(find.byKey(key)).width,
      VibraPageScaffold.defaultMaxContentWidth,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: VibraPageScaffold(
          maxContentWidth: null,
          child: Container(key: key),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(key)).width, 1400);
  });
}
