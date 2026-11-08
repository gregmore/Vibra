import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/community.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/community_recommendations.dart';
import 'core_providers.dart';
import 'musical_dna_providers.dart';

/// All communities with the caller's role (search is client-side over ~200).
class CommunitiesController extends AutoDisposeAsyncNotifier<List<Community>> {
  @override
  Future<List<Community>> build() =>
      ref.watch(supabaseCommunitiesDatasourceProvider).communities();

  void _patch(String id, Community Function(Community) f) {
    final list = state.valueOrNull;
    if (list == null) return;
    state = AsyncData([for (final c in list) c.id == id ? f(c) : c]);
  }

  Future<void> join(Community c) async {
    await ref.read(supabaseCommunitiesDatasourceProvider).join(c.id);
    _patch(
      c.id,
      (x) => x.copyWith(
        myRole: CommunityRole.member,
        memberCount: x.memberCount + 1,
      ),
    );
  }

  Future<void> leave(Community c) async {
    await ref.read(supabaseCommunitiesDatasourceProvider).leave(c.id);
    _patch(
      c.id,
      (x) => x.copyWith(
        clearRole: true,
        memberCount: (x.memberCount - 1).clamp(0, 1 << 30),
      ),
    );
  }
}

final communitiesProvider =
    AsyncNotifierProvider.autoDispose<CommunitiesController, List<Community>>(
      CommunitiesController.new,
    );

final communityByIdProvider = Provider.autoDispose.family<Community?, String>((
  ref,
  id,
) {
  final list = ref.watch(communitiesProvider).valueOrNull;
  if (list == null) return null;
  for (final c in list) {
    if (c.id == id) return c;
  }
  return null;
});

class CommunityRecommendations {
  const CommunityRecommendations(this.items, this.startArtists);
  final List<CommunityRecommendation> items;
  final List<String> startArtists;
}

/// "Based on your musical profile, you might enjoy…" from the Musical DNA.
final communityRecommendationsProvider =
    FutureProvider.autoDispose<CommunityRecommendations>((ref) async {
      final communities = await ref.watch(communitiesProvider.future);
      final history = await ref
          .watch(myMusicalDnaHistoryProvider.future)
          .catchError((_) => const <Never>[]);
      final dna = history.isEmpty ? null : history.first;
      return CommunityRecommendations(
        recommendCommunities(communities, dna),
        artistsWithoutCommunity(communities, dna),
      );
    });

/// Feed of one community; `kind` null = everything except discussions.
typedef FeedKey = ({String communityId, CommunityPostKind? kind});

class CommunityFeedController
    extends AutoDisposeFamilyAsyncNotifier<List<CommunityPost>, FeedKey> {
  @override
  Future<List<CommunityPost>> build(FeedKey key) => ref
      .watch(supabaseCommunitiesDatasourceProvider)
      .feed(key.communityId, kind: key.kind ?? CommunityPostKind.post);

  void replace(CommunityPost post) {
    final list = state.valueOrNull;
    if (list == null) return;
    state = AsyncData([for (final p in list) p.id == post.id ? post : p]);
  }

  void remove(String postId) {
    final list = state.valueOrNull;
    if (list == null) return;
    state = AsyncData([
      for (final p in list)
        if (p.id != postId) p,
    ]);
  }

  /// Optimistic reaction toggle; rolls back on failure.
  Future<bool> toggleReaction(CommunityPost post, String reaction) async {
    final on = !post.myReactions.contains(reaction);
    replace(post.withReaction(reaction, on: on));
    try {
      await ref
          .read(supabaseCommunitiesDatasourceProvider)
          .toggleReaction(post.id, reaction);
      return true;
    } catch (_) {
      replace(post);
      return false;
    }
  }
}

final communityFeedProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityFeedController, List<CommunityPost>, FeedKey>(
      CommunityFeedController.new,
    );

final communityCommentsProvider = FutureProvider.autoDispose
    .family<List<CommunityComment>, String>(
      (ref, postId) =>
          ref.watch(supabaseCommunitiesDatasourceProvider).comments(postId),
    );

final communityMembersProvider = FutureProvider.autoDispose
    .family<List<CommunityMember>, String>(
      (ref, id) => ref.watch(supabaseCommunitiesDatasourceProvider).members(id),
    );

final communityEventsProvider = FutureProvider.autoDispose
    .family<List<Event>, String>(
      (ref, id) => ref.watch(supabaseCommunitiesDatasourceProvider).events(id),
    );

final moderationQueueProvider = FutureProvider.autoDispose
    .family<List<ModerationItem>, String>(
      (ref, id) =>
          ref.watch(supabaseCommunitiesDatasourceProvider).moderationQueue(id),
    );
