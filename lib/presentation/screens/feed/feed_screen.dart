import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../data/datasources/supabase_feed_datasource.dart'
    show feedListPageSize;
import '../../../domain/entities/feed_post.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/feed_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_paged_list.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/community_widgets.dart' show blockCommunityAuthor;
import '../../widgets/feed_widgets.dart';
import '../../widgets/daily_vibe_widgets.dart' show pickReportReason;

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// VIBRA FEED (docs/vibra-feed.md): "For you" ranks by relevance and says
/// why each post is there; "Following" and "Latest" are chronological.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({this.initialMode = FeedMode.forYou, super.key});
  final FeedMode initialMode;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late FeedMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(l10n.feedTitle),
        actions: [
          IconButton(
            tooltip: l10n.feedSavedTitle,
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => context.push('/feed-saved'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'feed-compose',
        onPressed: () async {
          final posted = await context.push<bool>('/feed-composer');
          if (posted == true) {
            for (final m in FeedMode.values) {
              ref.invalidate(feedProvider(m));
            }
          }
        },
        icon: const Icon(Icons.edit_rounded),
        label: Text(l10n.feedCompose),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xs,
              VibraSpacing.pagePadding,
              VibraSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<FeedMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: FeedMode.forYou,
                    label: Text(l10n.feedForYou),
                  ),
                  ButtonSegment(
                    value: FeedMode.following,
                    label: Text(l10n.feedFollowing),
                  ),
                  ButtonSegment(
                    value: FeedMode.latest,
                    label: Text(l10n.feedLatest),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VibraSpacing.pagePadding,
            ),
            child: Text(
              switch (_mode) {
                FeedMode.forYou => l10n.feedForYouBody,
                FeedMode.following => l10n.feedFollowingBody,
                FeedMode.latest => l10n.feedLatestBody,
              },
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.vibraTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: VibraSpacing.sm),
          Expanded(
            child: _FeedList(key: ValueKey(_mode), mode: _mode),
          ),
        ],
      ),
    );
  }
}

class _FeedList extends ConsumerWidget {
  const _FeedList({required this.mode, super.key});
  final FeedMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(feedProvider(mode));
    return async.when(
      loading: () => const VibraLoadingView(),
      error: (e, _) => VibraErrorView(
        error: e,
        title: l10n.feedTitle,
        message: l10n.feedLoadError,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(feedProvider(mode)),
      ),
      data: (state) {
        final controller = ref.read(feedProvider(mode).notifier);
        if (state.posts.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(feedProvider(mode)),
            child: ListView(
              children: [
                VibraEmptyView(
                  title: l10n.feedEmptyTitle,
                  message: mode == FeedMode.following
                      ? l10n.feedEmptyFollowing
                      : l10n.feedEmptyBody,
                  icon: Icons.dynamic_feed_rounded,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(feedProvider(mode));
            await ref.read(feedProvider(mode).future);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels > n.metrics.maxScrollExtent - 600) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                0,
                VibraSpacing.pagePadding,
                VibraSpacing.colossal * 2,
              ),
              itemCount: state.posts.length + 1,
              itemBuilder: (context, i) {
                if (i == state.posts.length) {
                  return state.loadingMore
                      ? const VibraLoadingIndicator()
                      : state.done
                      ? Padding(
                          padding: const EdgeInsets.all(VibraSpacing.lg),
                          child: Center(
                            child: Text(
                              l10n.feedEnd,
                              style: TextStyle(
                                color: context.vibraTokens.textMuted,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: VibraSpacing.xl);
                }
                final post = state.posts[i];
                controller.seen(post);
                return FeedPostCard(
                  key: ValueKey(post.id),
                  post: post,
                  showReason: mode == FeedMode.forYou,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// One post with its comments and replies.
class FeedPostScreen extends ConsumerStatefulWidget {
  const FeedPostScreen({required this.postId, super.key});
  final String postId;

  @override
  ConsumerState<FeedPostScreen> createState() => _FeedPostScreenState();
}

class _FeedPostScreenState extends ConsumerState<FeedPostScreen> {
  final _comment = TextEditingController();
  FeedComment? _replyTo;
  FeedPost? _local;
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send(FeedPost post) async {
    final l10n = AppLocalizations.of(context)!;
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(supabaseFeedDatasourceProvider)
          .comment(post.id, text, parentId: _replyTo?.parentId ?? _replyTo?.id);
      _comment.clear();
      final updated = post.copyWith(commentCount: post.commentCount + 1);
      FeedActions(ref).changed(updated);
      setState(() {
        _replyTo = null;
        _local = updated;
      });
      ref.invalidate(feedCommentsProvider(post.id));
    } catch (e) {
      if (mounted) {
        _snack(
          context,
          '$e'.contains('comments_off')
              ? l10n.feedCommentsOff
              : '$e'.contains('duplicate_comment')
              ? l10n.feedDuplicateComment
              : l10n.feedError,
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final me = ref.read(supabaseFeedDatasourceProvider).currentUserId;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.feedPostTitle)),
      child: ref
          .watch(feedPostProvider(widget.postId))
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.feedPostTitle,
              message: l10n.feedLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(feedPostProvider(widget.postId)),
            ),
            data: (loaded) {
              final post = _local ?? loaded;
              if (post == null) {
                return VibraEmptyView(
                  title: l10n.feedPostGone,
                  message: l10n.feedPostGoneBody,
                  icon: Icons.hide_source_rounded,
                );
              }
              final canComment = post.commentsEnabled || post.userId == me;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                      children: [
                        FeedPostCard(
                          post: post,
                          expanded: true,
                          onChanged: (p) => setState(() => _local = p),
                        ),
                        _Comments(
                          post: post,
                          onReply: (c) => setState(() => _replyTo = c),
                          onDeleted: () => setState(
                            () => _local = post.copyWith(
                              commentCount: (post.commentCount - 1).clamp(
                                0,
                                1 << 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        VibraSpacing.pagePadding,
                        VibraSpacing.xs,
                        VibraSpacing.sm,
                        VibraSpacing.sm,
                      ),
                      child: canComment
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_replyTo != null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.vibeReplyingTo(_replyTo!.name),
                                          style: TextStyle(
                                            color: t.textSecondary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: l10n.commonCancel,
                                        onPressed: () =>
                                            setState(() => _replyTo = null),
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                    ],
                                  ),
                                TextField(
                                  controller: _comment,
                                  maxLength: 1000,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: l10n.feedCommentHint,
                                    suffixIcon: IconButton(
                                      tooltip: l10n.storySendReply,
                                      onPressed: _sending
                                          ? null
                                          : () => _send(post),
                                      icon: const Icon(Icons.send_rounded),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              l10n.feedCommentsOff,
                              style: TextStyle(color: t.textSecondary),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _Comments extends ConsumerWidget {
  const _Comments({
    required this.post,
    required this.onReply,
    required this.onDeleted,
  });
  final FeedPost post;
  final ValueChanged<FeedComment> onReply;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final source = ref.read(supabaseFeedDatasourceProvider);
    final me = source.currentUserId;
    return ref
        .watch(feedCommentsProvider(post.id))
        .when(
          loading: () => const VibraLoadingIndicator(),
          error: (_, _) => Text(l10n.feedLoadError),
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(VibraSpacing.lg),
                child: Text(
                  l10n.feedNoComments,
                  style: TextStyle(color: t.textSecondary),
                ),
              );
            }
            final top = comments.where((c) => c.parentId == null);
            Widget tile(FeedComment c, {bool reply = false}) => Padding(
              padding: EdgeInsets.only(
                left: reply ? VibraSpacing.xxl : 0,
                bottom: VibraSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.push('/user-profile', extra: c.authorId),
                    child: VibraAvatar(
                      imageUrl: c.avatarUrl,
                      name: c.name,
                      radius: reply ? 12 : 15,
                    ),
                  ),
                  const SizedBox(width: VibraSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${c.name}  ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: feedAge(l10n, c.createdAt),
                                style: TextStyle(color: t.textMuted),
                              ),
                            ],
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(c.body, style: theme.textTheme.bodyMedium),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: () => onReply(c),
                          child: Text(l10n.vibeReply),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, size: 18),
                    onSelected: (a) async {
                      try {
                        if (a == 'delete') {
                          await source.deleteComment(c.id);
                          ref.invalidate(feedCommentsProvider(post.id));
                          onDeleted();
                        } else if (a == 'report') {
                          final reason = await pickReportReason(context);
                          if (reason == null) return;
                          await source.report(
                            reportedId: c.authorId,
                            reason: reason,
                            commentId: c.id,
                          );
                          if (context.mounted) {
                            _snack(context, l10n.communitiesReported);
                          }
                        } else if (a == 'block') {
                          if (await blockCommunityAuthor(
                            context,
                            ref,
                            c.authorId,
                          )) {
                            ref.invalidate(feedCommentsProvider(post.id));
                          }
                        }
                      } catch (_) {
                        if (context.mounted) _snack(context, l10n.feedError);
                      }
                    },
                    itemBuilder: (_) => [
                      if (c.authorId == me || post.userId == me)
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.feedDeleteComment),
                        ),
                      if (c.authorId != me) ...[
                        PopupMenuItem(
                          value: 'report',
                          child: Text(l10n.socialReportAction),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Text(l10n.socialBlockUser),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: VibraSpacing.sm,
                  ),
                  child: Text(
                    l10n.vibeComments(comments.length),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                for (final c in top) ...[
                  tile(c),
                  for (final r in comments.where((x) => x.parentId == c.id))
                    tile(r, reply: true),
                ],
              ],
            );
          },
        );
  }
}

/// A plain list of posts (saved posts, a person's posts).
class FeedPostListScreen extends ConsumerWidget {
  const FeedPostListScreen.saved({super.key})
    : userId = null,
      displayName = null;
  const FeedPostListScreen.user({
    required String this.userId,
    this.displayName,
    super.key,
  });

  final String? userId;
  final String? displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final provider = userId == null
        ? feedBookmarksProvider
        : userFeedPostsProvider(userId!);
    final title = userId == null
        ? l10n.feedSavedTitle
        : displayName == null
        ? l10n.feedPostsTitle
        : l10n.feedPostsOf(displayName!);
    return VibraPageScaffold(
      appBar: AppBar(title: Text(title)),
      child: ref
          .watch(provider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: title,
              message: l10n.feedLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(provider),
            ),
            data: (posts) => posts.isEmpty
                ? VibraEmptyView(
                    title: userId == null
                        ? l10n.feedSavedEmpty
                        : l10n.feedNoPosts,
                    message: userId == null
                        ? l10n.feedSavedEmptyBody
                        : l10n.feedNoPostsBody,
                    icon: userId == null
                        ? Icons.bookmark_border_rounded
                        : Icons.dynamic_feed_rounded,
                  )
                : VibraPagedList<FeedPost>(
                    first: posts,
                    pageSize: feedListPageSize,
                    itemKey: (p) => p.id,
                    loadMore: (last) {
                      final source = ref.read(supabaseFeedDatasourceProvider);
                      return userId == null
                          ? source.bookmarks(before: last.savedAt)
                          : source.userPosts(userId!, before: last.createdAt);
                    },
                    onRefresh: () async => ref.invalidate(provider),
                    itemBuilder: (context, p) => FeedPostCard(
                      post: p,
                      onChanged: (_) => ref.invalidate(provider),
                    ),
                  ),
          ),
    );
  }
}
