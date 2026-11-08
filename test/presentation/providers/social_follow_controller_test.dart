import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/domain/repositories/social_repository.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';

class _Repository extends Mock implements SocialRepository {}

class _Datasource extends Mock implements SupabaseDatasource {}

void main() {
  late _Repository repo;
  late ProviderContainer container;
  late ProviderSubscription<FollowStats> subscription;
  const previous = FollowStats(
    followersCount: 10,
    followingCount: 3,
    isFollowing: false,
    isFollower: true,
  );

  setUp(() {
    repo = _Repository();
    when(
      () => repo.getFollowStats(userId: 'target'),
    ).thenAnswer((_) async => previous);
    final ds = _Datasource();
    when(() => ds.currentUser).thenReturn(null);
    container = ProviderContainer(
      overrides: [
        supabaseDatasourceProvider.overrideWithValue(ds),
        getFollowStatsUseCaseProvider.overrideWithValue(
          GetFollowStatsUseCase(repo),
        ),
        followUserUseCaseProvider.overrideWithValue(FollowUserUseCase(repo)),
        unfollowUserUseCaseProvider.overrideWithValue(
          UnfollowUserUseCase(repo),
        ),
      ],
    );
    subscription = container.listen(
      userFollowStatsProvider('target'),
      (_, _) {},
    );
  });
  tearDown(() {
    subscription.close();
    container.dispose();
  });

  testWidgets('Failed follow restores count and relation together', (
    tester,
  ) async {
    await tester.pump();
    final pending = Completer<void>();
    when(
      () => repo.followUser(userId: 'target'),
    ).thenAnswer((_) => pending.future);
    final operation = container
        .read(userFollowStatsProvider('target').notifier)
        .toggleFollow();
    final expectation = expectLater(operation, throwsStateError);
    expect(
      container.read(userFollowStatsProvider('target')).followersCount,
      11,
    );
    pending.completeError(StateError('offline'));
    await expectation;
    final stats = container.read(userFollowStatsProvider('target'));
    expect(stats.followersCount, previous.followersCount);
    expect(stats.isFollowing, previous.isFollowing);
    expect(stats.isFollower, previous.isFollower);
  });

  testWidgets(
    'Rapid repeated taps send one mutation and reconcile server count',
    (tester) async {
      await tester.pump();
      final pending = Completer<void>();
      when(
        () => repo.followUser(userId: 'target'),
      ).thenAnswer((_) => pending.future);
      final controller = container.read(
        userFollowStatsProvider('target').notifier,
      );
      final first = controller.toggleFollow();
      final second = controller.toggleFollow();
      when(() => repo.getFollowStats(userId: 'target')).thenAnswer(
        (_) async => previous.copyWith(isFollowing: true, followersCount: 12),
      );
      pending.complete();
      await Future.wait([first, second]);
      verify(() => repo.followUser(userId: 'target')).called(1);
      expect(
        container.read(userFollowStatsProvider('target')).followersCount,
        12,
      );
      expect(
        container.read(userFollowStatsProvider('target')).isFollowing,
        isTrue,
      );
    },
  );

  testWidgets(
    'Pending initial stats determine the correct unfollow operation',
    (tester) async {
      final stats = Completer<FollowStats>();
      when(
        () => repo.getFollowStats(userId: 'target'),
      ).thenAnswer((_) => stats.future);
      when(() => repo.unfollowUser(userId: 'target')).thenAnswer((_) async {});
      // The setUp subscription may already have completed its first fetch.
      // Rebuild after installing the pending response to exercise a real race.
      container.invalidate(userFollowStatsProvider('target'));
      await tester.pump(const Duration(milliseconds: 1));
      final toggle = container
          .read(userFollowStatsProvider('target').notifier)
          .toggleFollow();
      stats.complete(previous.copyWith(isFollowing: true));
      await toggle;
      await tester.pump(const Duration(milliseconds: 1));
      verify(() => repo.unfollowUser(userId: 'target')).called(1);
      verifyNever(() => repo.followUser(userId: 'target'));
    },
  );
}
