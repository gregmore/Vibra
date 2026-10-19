import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/repositories/social_repository_impl.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/domain/entities/conversation_summary.dart';
import 'package:vibra/domain/entities/follow_stats.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/domain/usecases/usecase.dart';

class MockSupabaseSocialDatasource extends Mock
    implements SupabaseSocialDatasource {}

void main() {
  late MockSupabaseSocialDatasource mockDatasource;
  late SocialRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockSupabaseSocialDatasource();
    repository = SocialRepositoryImpl(mockDatasource);
  });

  group('Social Follow & Message System Tests', () {
    test('FollowStats copyWith and empty constructor work correctly', () {
      const empty = FollowStats.empty();
      expect(empty.followersCount, 0);
      expect(empty.followingCount, 0);
      expect(empty.isFollowing, isFalse);
      expect(empty.isFollower, isFalse);

      final updated = empty.copyWith(
        followersCount: 10,
        followingCount: 5,
        isFollowing: true,
      );
      expect(updated.followersCount, 10);
      expect(updated.followingCount, 5);
      expect(updated.isFollowing, isTrue);
      expect(updated.isFollower, isFalse);
    });

    test('ConversationSummary handles display name fallback', () {
      final convWithName = ConversationSummary(
        otherUserId: 'user-1',
        otherUsername: 'johndoe',
        otherDisplayName: 'John Doe',
        lastMessageContent: 'Ciao!',
        lastMessageCreatedAt: DateTime(2026, 8, 22),
        unreadCount: 2,
        isFriend: true,
        isMessageRequest: false,
      );
      expect(convWithName.effectiveDisplayName, 'John Doe');

      final convWithoutName = ConversationSummary(
        otherUserId: 'user-2',
        otherUsername: 'rocker99',
        otherDisplayName: '',
        lastMessageContent: 'Hey',
        lastMessageCreatedAt: DateTime(2026, 8, 22),
        unreadCount: 0,
        isFriend: false,
        isMessageRequest: true,
      );
      expect(convWithoutName.effectiveDisplayName, 'rocker99');
    });

    test('FollowUserUseCase calls repository followUser', () async {
      when(
        () => mockDatasource.followUser(userId: 'target-123'),
      ).thenAnswer((_) async {});

      final useCase = FollowUserUseCase(repository);
      await useCase.call('target-123');

      verify(() => mockDatasource.followUser(userId: 'target-123')).called(1);
    });

    test('UnfollowUserUseCase calls repository unfollowUser', () async {
      when(
        () => mockDatasource.unfollowUser(userId: 'target-123'),
      ).thenAnswer((_) async {});

      final useCase = UnfollowUserUseCase(repository);
      await useCase.call('target-123');

      verify(() => mockDatasource.unfollowUser(userId: 'target-123')).called(1);
    });

    test('GetFollowStatsUseCase returns follow stats correctly', () async {
      const stats = FollowStats(
        followersCount: 42,
        followingCount: 18,
        isFollowing: true,
        isFollower: false,
      );

      when(
        () => mockDatasource.getFollowStats(userId: 'target-123'),
      ).thenAnswer((_) async => stats);

      final useCase = GetFollowStatsUseCase(repository);
      final result = await useCase.call('target-123');

      expect(result.followersCount, 42);
      expect(result.followingCount, 18);
      expect(result.isFollowing, isTrue);
      expect(result.isFollower, isFalse);
    });

    test(
      'ListConversationsUseCase returns list of conversation summaries',
      () async {
        final summaries = [
          ConversationSummary(
            otherUserId: 'u1',
            otherUsername: 'alex',
            otherDisplayName: 'Alex',
            lastMessageContent: 'Vieni al concerto?',
            lastMessageCreatedAt: DateTime.now(),
            unreadCount: 1,
            isFriend: true,
            isMessageRequest: false,
          ),
          ConversationSummary(
            otherUserId: 'u2',
            otherUsername: 'unknown_fan',
            lastMessageContent: 'Ciao, che musica ascolti?',
            lastMessageCreatedAt: DateTime.now(),
            unreadCount: 1,
            isFriend: false,
            isMessageRequest: true,
          ),
        ];

        when(
          () => mockDatasource.listConversations(),
        ).thenAnswer((_) async => summaries);

        final useCase = ListConversationsUseCase(repository);
        final result = await useCase.call(const NoParams());

        expect(result.length, 2);
        expect(result[0].isFriend, isTrue);
        expect(result[0].isMessageRequest, isFalse);
        expect(result[1].isMessageRequest, isTrue);
      },
    );

    test(
      'MarkMessagesAsReadUseCase calls repository markMessagesAsRead',
      () async {
        when(
          () => mockDatasource.markMessagesAsRead(otherUserId: 'u-123'),
        ).thenAnswer((_) async {});

        final useCase = MarkMessagesAsReadUseCase(repository);
        await useCase.call('u-123');

        verify(
          () => mockDatasource.markMessagesAsRead(otherUserId: 'u-123'),
        ).called(1);
      },
    );

    test('DeleteFriendshipUseCase calls repository deleteFriendship', () async {
      when(
        () => mockDatasource.deleteFriendship(friendshipId: 'f-123'),
      ).thenAnswer((_) async {});

      final useCase = DeleteFriendshipUseCase(repository);
      await useCase.call('f-123');

      verify(
        () => mockDatasource.deleteFriendship(friendshipId: 'f-123'),
      ).called(1);
    });

    test(
      'CancelFriendRequestUseCase calls repository cancelFriendRequest',
      () async {
        when(
          () => mockDatasource.cancelFriendRequest(friendshipId: 'f-456'),
        ).thenAnswer((_) async {});

        final useCase = CancelFriendRequestUseCase(repository);
        await useCase.call('f-456');

        verify(
          () => mockDatasource.cancelFriendRequest(friendshipId: 'f-456'),
        ).called(1);
      },
    );
  });
}
