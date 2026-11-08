import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/feed_post.dart';
import 'core_providers.dart';

/// VIBRA Feed (docs/vibra-feed.md): one paged list per mode.
class FeedState {
  const FeedState({
    this.posts = const [],
    this.loadingMore = false,
    this.done = false,
  });
  final List<FeedPost> posts;
  final bool loadingMore;
  final bool done;

  FeedState copyWith({List<FeedPost>? posts, bool? loadingMore, bool? done}) =>
      FeedState(
        posts: posts ?? this.posts,
        loadingMore: loadingMore ?? this.loadingMore,
        done: done ?? this.done,
      );
}

const feedPageSize = 20;

class FeedController
    extends AutoDisposeFamilyAsyncNotifier<FeedState, FeedMode> {
  final _seen = <String>{};
  final _pendingSeen = <String>{};
  Timer? _flush;

  @override
  Future<FeedState> build(FeedMode mode) async {
    ref.onDispose(() {
      _flush?.cancel();
      _sendSeen();
    });
    final page = await ref.read(supabaseFeedDatasourceProvider).feed(mode);
    return FeedState(posts: page, done: page.length < feedPageSize);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || current.done) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final source = ref.read(supabaseFeedDatasourceProvider);
      final page = arg == FeedMode.forYou
          ? await source.feed(
              arg,
              exclude: [for (final p in current.posts) p.id],
            )
          : await source.feed(arg, before: current.posts.lastOrNull?.createdAt);
      final known = {for (final p in current.posts) p.id};
      state = AsyncData(
        current.copyWith(
          posts: [
            ...current.posts,
            ...page.where((p) => !known.contains(p.id)),
          ],
          loadingMore: false,
          done: page.length < feedPageSize,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  /// A card was built on screen: record it once (anti-repetition), batched.
  void seen(FeedPost post) {
    final me = ref.read(supabaseFeedDatasourceProvider).currentUserId;
    if (post.userId == me || !_seen.add(post.id)) return;
    _pendingSeen.add(post.id);
    _flush ??= Timer(const Duration(seconds: 3), () {
      _flush = null;
      _sendSeen();
    });
  }

  void _sendSeen() {
    if (_pendingSeen.isEmpty) return;
    final ids = _pendingSeen.toList();
    _pendingSeen.clear();
    ref.read(supabaseFeedDatasourceProvider).markSeen(ids).catchError((_) {});
  }

  void replace(FeedPost post) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        posts: [
          for (final p in current.posts)
            p.id == post.id ? post.copyWith(reason: p.reason) : p,
        ],
      ),
    );
  }

  void remove(String postId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        posts: [
          for (final p in current.posts)
            if (p.id != postId && p.shared?.id != postId) p,
        ],
      ),
    );
  }
}

final feedProvider = AsyncNotifierProvider.autoDispose
    .family<FeedController, FeedState, FeedMode>(FeedController.new);

final feedPostProvider = FutureProvider.autoDispose.family<FeedPost?, String>(
  (ref, id) => ref.watch(supabaseFeedDatasourceProvider).post1(id),
);

final feedCommentsProvider = FutureProvider.autoDispose
    .family<List<FeedComment>, String>(
      (ref, id) => ref.watch(supabaseFeedDatasourceProvider).comments(id),
    );

final userFeedPostsProvider = FutureProvider.autoDispose
    .family<List<FeedPost>, String>(
      (ref, userId) =>
          ref.watch(supabaseFeedDatasourceProvider).userPosts(userId),
    );

final feedBookmarksProvider = FutureProvider.autoDispose<List<FeedPost>>(
  (ref) => ref.watch(supabaseFeedDatasourceProvider).bookmarks(),
);
