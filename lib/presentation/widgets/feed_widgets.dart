import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/entities/music_reaction.dart';
import '../../l10n/app_localizations.dart';
import '../providers/core_providers.dart';
import '../providers/feed_providers.dart';
import 'daily_vibe_widgets.dart' show pickReportReason;
import 'common/vibra_avatar.dart';
import 'common/vibra_bottom_sheet.dart';
import 'common/vibra_image.dart';
import 'common/vibra_surface.dart';
import 'community_widgets.dart' show blockCommunityAuthor;
import 'music_reactions.dart';
import 'music_story_widgets.dart' show StoryPhoto, openStoryItem;

/// VIBRA Feed (docs/vibra-feed.md): the post card and its actions.

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

String feedKindLabel(AppLocalizations l10n, FeedKind kind) => switch (kind) {
  FeedKind.song => l10n.feedKindSong,
  FeedKind.album => l10n.feedKindAlbum,
  FeedKind.playlist => l10n.feedKindPlaylist,
  FeedKind.recommendation => l10n.feedKindRecommendation,
  FeedKind.discovery => l10n.feedKindDiscovery,
  FeedKind.review => l10n.feedKindReview,
  FeedKind.opinion => l10n.feedKindOpinion,
  FeedKind.concertPhoto => l10n.feedKindConcertPhoto,
  FeedKind.share => l10n.feedKindShare,
};

IconData feedKindIcon(FeedKind kind) => switch (kind) {
  FeedKind.song => Icons.music_note_rounded,
  FeedKind.album => Icons.album_rounded,
  FeedKind.playlist => Icons.queue_music_rounded,
  FeedKind.recommendation => Icons.recommend_rounded,
  FeedKind.discovery => Icons.explore_rounded,
  FeedKind.review => Icons.star_half_rounded,
  FeedKind.opinion => Icons.format_quote_rounded,
  FeedKind.concertPhoto => Icons.photo_camera_rounded,
  FeedKind.share => Icons.repeat_rounded,
};

String feedItemTypeLabel(AppLocalizations l10n, FeedItemType t) => switch (t) {
  FeedItemType.track => l10n.feedItemTrack,
  FeedItemType.album => l10n.feedItemAlbum,
  FeedItemType.artist => l10n.feedItemArtist,
  FeedItemType.playlist => l10n.feedItemPlaylist,
};

/// Why "For you" shows a post. Null when the reason adds nothing.
String? feedReasonLabel(AppLocalizations l10n, FeedReason r) => switch (r) {
  FeedReason.following => l10n.feedReasonFollowing,
  FeedReason.connection => l10n.feedReasonConnection,
  FeedReason.artists => l10n.feedReasonArtists,
  FeedReason.genres => l10n.feedReasonGenres,
  FeedReason.community => l10n.feedReasonCommunity,
  FeedReason.match => l10n.feedReasonMatch,
  FeedReason.interaction => l10n.feedReasonInteraction,
  FeedReason.newPost => l10n.feedReasonNew,
  _ => null,
};

String feedAge(AppLocalizations l10n, DateTime createdAt) {
  final d = DateTime.now().difference(createdAt);
  if (d.inMinutes < 1) return l10n.storyJustNow;
  if (d.inHours < 1) return l10n.storyMinutesAgo(d.inMinutes);
  if (d.inDays < 1) return l10n.storyHoursAgo(d.inHours);
  return l10n.feedDaysAgo(d.inDays);
}

/// Shared optimistic actions on a post, used by every screen showing one.
class FeedActions {
  const FeedActions(this.ref);
  final WidgetRef ref;

  void _apply(FeedPost post) {
    for (final mode in FeedMode.values) {
      if (ref.exists(feedProvider(mode))) {
        ref.read(feedProvider(mode).notifier).replace(post);
      }
    }
  }

  void _remove(String id) {
    for (final mode in FeedMode.values) {
      if (ref.exists(feedProvider(mode))) {
        ref.read(feedProvider(mode).notifier).remove(id);
      }
    }
  }

  Future<FeedPost?> react(FeedPost post, String reaction) async {
    HapticFeedback.selectionClick();
    final updated = post.withReaction(
      reaction,
      on: !post.myReactions.contains(reaction),
    );
    _apply(updated);
    try {
      await ref
          .read(supabaseFeedDatasourceProvider)
          .toggleReaction(post.id, reaction);
      return updated;
    } catch (_) {
      _apply(post);
      return null;
    }
  }

  Future<FeedPost?> bookmark(FeedPost post) async {
    final updated = post.copyWith(bookmarked: !post.bookmarked);
    _apply(updated);
    try {
      await ref
          .read(supabaseFeedDatasourceProvider)
          .setBookmark(post.id, updated.bookmarked);
      ref.invalidate(feedBookmarksProvider);
      return updated;
    } catch (_) {
      _apply(post);
      return null;
    }
  }

  Future<bool> notInterested(FeedPost post) async {
    _remove(post.id);
    try {
      await ref.read(supabaseFeedDatasourceProvider).notInterested(post.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleted(String postId) async {
    await ref.read(supabaseFeedDatasourceProvider).deleteMine(postId);
    _remove(postId);
    final me = ref.read(supabaseFeedDatasourceProvider).currentUserId;
    if (me != null) ref.invalidate(userFeedPostsProvider(me));
  }

  void changed(FeedPost post) => _apply(post);
  void removed(String postId) => _remove(postId);
}

class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.size = 18,
    this.onChanged,
    super.key,
  });
  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.feedRatingLabel(rating),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            onChanged == null
                ? Icon(
                    i <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: size,
                    color: VibraPalette.warning,
                  )
                : IconButton(
                    tooltip: l10n.feedRatingLabel(i),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onChanged!(i),
                    icon: Icon(
                      i <= rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: size,
                      color: VibraPalette.warning,
                    ),
                  ),
        ],
      ),
    );
  }
}

/// The music item of a post: artwork, title, subtitle, a link to the
/// provider and, for Spotify, the attribution it requires.
class FeedItemTile extends StatelessWidget {
  const FeedItemTile({required this.post, super.key});
  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final item = post.item!;
    final round = post.itemType == FeedItemType.artist;
    return Container(
      padding: const EdgeInsets.all(VibraSpacing.md),
      decoration: BoxDecoration(
        color: t.surfaceMuted,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  round ? 40 : VibraSpacing.radiusSmall,
                ),
                child: SizedBox.square(
                  dimension: 72,
                  child: VibraNetworkImage(
                    url: item.artworkUrl,
                    cacheWidth: 200,
                    fallbackIcon: feedKindIcon(post.kind),
                  ),
                ),
              ),
              const SizedBox(width: VibraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.itemType != null)
                      Text(
                        feedItemTypeLabel(l10n, post.itemType!).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.accentPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: VibraSpacing.xs),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: VibraSpacing.sm,
            children: [
              TextButton.icon(
                onPressed: () => openStoryItem(item),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: item.isSpotify
                      ? VibraPalette.spotifyGreen
                      : t.textPrimary,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(item.isSpotify ? l10n.vibeListen : l10n.vibeOpen),
              ),
              if (item.isSpotify)
                Text(
                  l10n.storyAttribution,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: t.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A post's content (item, photo, rating, text) without the action bar.
class FeedPostBody extends StatelessWidget {
  const FeedPostBody({required this.post, this.expanded = false, super.key});
  final FeedPost post;

  /// Full text (post screen) instead of a clamped preview.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (post.kind == FeedKind.review && post.rating != null) ...[
          RatingStars(rating: post.rating!),
          const SizedBox(height: VibraSpacing.xs),
        ],
        if (post.body != null) ...[
          Text(
            post.body!,
            maxLines: expanded ? null : 8,
            overflow: expanded ? null : TextOverflow.ellipsis,
            style: post.kind == FeedKind.opinion
                ? theme.textTheme.titleMedium?.copyWith(height: 1.35)
                : theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: VibraSpacing.sm),
        ],
        if (post.item != null) FeedItemTile(post: post),
        if (post.kind == FeedKind.concertPhoto) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: StoryPhoto(path: post.mediaPath, bucket: 'feed-media'),
            ),
          ),
          if (post.eventName != null)
            Padding(
              padding: const EdgeInsets.only(top: VibraSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.event_rounded, size: 16, color: t.textSecondary),
                  const SizedBox(width: VibraSpacing.xs),
                  Expanded(
                    child: Text(
                      post.eventName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class FeedPostCard extends ConsumerWidget {
  const FeedPostCard({
    required this.post,
    this.showReason = false,
    this.expanded = false,
    this.onChanged,
    super.key,
  });

  final FeedPost post;
  final bool showReason;
  final bool expanded;

  /// Called with the updated post (screens not backed by a feed list).
  final ValueChanged<FeedPost>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final actions = FeedActions(ref);
    final me = ref.read(supabaseFeedDatasourceProvider).currentUserId;
    final mine = post.userId == me;
    final content = post.content;
    final reason = showReason ? feedReasonLabel(l10n, post.reason) : null;
    // A song share gets musical reactions (docs/track-reactions.md).
    final song = content.itemType == FeedItemType.track;

    Future<void> react(String r) async {
      final on = !post.myReactions.contains(r);
      final updated = await actions.react(post, r);
      if (updated == null && context.mounted) {
        _snack(context, l10n.feedError);
      } else if (updated != null) {
        onChanged?.call(updated);
        if (song && !mine && content.item != null && context.mounted) {
          offerToSaveDiscovery(
            context,
            ref,
            reaction: r,
            turnedOn: on,
            source: DiscoverySource.post,
            id: post.id,
            externalUrl: content.item!.externalUrl,
          );
        }
      }
    }

    void openPost() => context.push('/feed-post', extra: post.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.md),
      child: VibraSurface(
        padding: const EdgeInsets.fromLTRB(
          VibraSpacing.lg,
          VibraSpacing.md,
          VibraSpacing.sm,
          VibraSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: t.accentPrimary,
                    ),
                    const SizedBox(width: VibraSpacing.xs),
                    Text(
                      reason,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () =>
                      context.push('/user-profile', extra: post.userId),
                  child: VibraAvatar(
                    imageUrl: post.avatarUrl,
                    name: post.name,
                    radius: 18,
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          feedKindLabel(l10n, post.kind),
                          feedAge(l10n, post.createdAt),
                          if (!post.everyone) l10n.storyAudienceConnections,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _PostMenu(post: post, mine: mine, onChanged: onChanged),
              ],
            ),
            if (post.heldForReview)
              Padding(
                padding: const EdgeInsets.only(top: VibraSpacing.sm),
                child: Text(
                  l10n.feedHeld,
                  style: theme.textTheme.bodySmall?.copyWith(color: t.warning),
                ),
              ),
            const SizedBox(height: VibraSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(right: VibraSpacing.sm),
              child: InkWell(
                onTap: expanded ? null : openPost,
                borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
                child: post.kind == FeedKind.share
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (post.body != null) ...[
                            Text(post.body!, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: VibraSpacing.sm),
                          ],
                          Container(
                            padding: const EdgeInsets.all(VibraSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: t.borderDefault),
                              borderRadius: BorderRadius.circular(
                                VibraSpacing.radiusMedium,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '${content.name} · ${feedKindLabel(l10n, content.kind)}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: t.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: VibraSpacing.xs),
                                FeedPostBody(post: content),
                              ],
                            ),
                          ),
                        ],
                      )
                    : FeedPostBody(post: post, expanded: expanded),
              ),
            ),
            const SizedBox(height: VibraSpacing.xs),
            Row(
              children: [
                _ActionButton(
                  icon: post.liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.liked ? VibraPalette.error : null,
                  label: post.likeCount > 0 ? '${post.likeCount}' : null,
                  tooltip: post.liked ? l10n.feedUnlike : l10n.feedLike,
                  onTap: () => react(feedLike),
                ),
                _ActionButton(
                  icon: Icons.add_reaction_outlined,
                  tooltip: l10n.feedReact,
                  label: post.reactions.isEmpty
                      ? null
                      : reactionSummary(post.reactions),
                  onTap: () async {
                    final r = await showReactionPicker(
                      context,
                      options: MusicReactions.forContent(song: song),
                      mine: post.myReactions,
                    );
                    if (r != null) await react(r);
                  },
                ),
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  tooltip: l10n.feedComments,
                  label: post.commentCount > 0 ? '${post.commentCount}' : null,
                  onTap: openPost,
                ),
                _ActionButton(
                  icon: Icons.repeat_rounded,
                  tooltip: l10n.feedShare,
                  label: post.shareCount > 0 ? '${post.shareCount}' : null,
                  onTap: () => showFeedShareSheet(context, ref, content),
                ),
                const Spacer(),
                if (song && !mine && content.item != null)
                  SaveSongButton(
                    source: DiscoverySource.post,
                    id: post.id,
                    externalUrl: content.item!.externalUrl,
                    compact: true,
                  ),
                _ActionButton(
                  icon: post.bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: post.bookmarked ? t.accentPrimary : null,
                  tooltip: post.bookmarked ? l10n.feedUnsave : l10n.feedSave,
                  onTap: () async {
                    final updated = await actions.bookmark(post);
                    if (!context.mounted) return;
                    if (updated == null) {
                      _snack(context, l10n.feedError);
                    } else {
                      onChanged?.call(updated);
                      _snack(
                        context,
                        updated.bookmarked ? l10n.feedSaved : l10n.feedUnsaved,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.label,
    this.color,
  });
  final IconData icon;
  final String tooltip;
  final String? label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VibraSpacing.sm,
            vertical: VibraSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color ?? t.textSecondary),
              if (label != null) ...[
                const SizedBox(width: VibraSpacing.xs),
                Text(
                  label!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: t.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PostMenu extends ConsumerWidget {
  const _PostMenu({required this.post, required this.mine, this.onChanged});
  final FeedPost post;
  final bool mine;
  final ValueChanged<FeedPost>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseFeedDatasourceProvider);
    final actions = FeedActions(ref);
    return PopupMenuButton<String>(
      tooltip: l10n.storyMore,
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (action) async {
        try {
          switch (action) {
            case 'visibility':
              await source.updateMine(post.id, everyone: !post.everyone);
              final p = post.copyWith(everyone: !post.everyone);
              actions.changed(p);
              onChanged?.call(p);
            case 'comments':
              await source.updateMine(post.id, comments: !post.commentsEnabled);
              final p = post.copyWith(commentsEnabled: !post.commentsEnabled);
              actions.changed(p);
              onChanged?.call(p);
            case 'delete':
              await actions.deleted(post.id);
              if (context.mounted) {
                _snack(context, l10n.feedDeleted);
                if (GoRouterState.of(context).uri.path == '/feed-post' &&
                    context.canPop()) {
                  context.pop();
                }
              }
            case 'not_interested':
              await actions.notInterested(post);
              if (context.mounted) _snack(context, l10n.feedNotInterestedDone);
            case 'report':
              final reason = await pickReportReason(context);
              if (reason == null) return;
              await source.report(
                reportedId: post.userId,
                reason: reason,
                postId: post.id,
              );
              if (context.mounted) _snack(context, l10n.communitiesReported);
            case 'block':
              if (await blockCommunityAuthor(context, ref, post.userId)) {
                for (final mode in FeedMode.values) {
                  ref.invalidate(feedProvider(mode));
                }
              }
          }
        } catch (_) {
          if (context.mounted) _snack(context, l10n.feedError);
        }
      },
      itemBuilder: (_) => [
        if (mine) ...[
          PopupMenuItem(
            value: 'visibility',
            child: Text(
              post.everyone
                  ? l10n.storyMakeConnectionsOnly
                  : l10n.storyMakeEveryone,
            ),
          ),
          PopupMenuItem(
            value: 'comments',
            child: Text(
              post.commentsEnabled
                  ? l10n.feedTurnCommentsOff
                  : l10n.feedTurnCommentsOn,
            ),
          ),
          PopupMenuItem(value: 'delete', child: Text(l10n.feedDelete)),
        ] else ...[
          PopupMenuItem(
            value: 'not_interested',
            child: Text(l10n.feedNotInterested),
          ),
          PopupMenuItem(value: 'report', child: Text(l10n.socialReportAction)),
          PopupMenuItem(value: 'block', child: Text(l10n.socialBlockUser)),
        ],
      ],
    );
  }
}

/// Share a post: to your own feed (with an optional comment), or copy the
/// link to the music on its provider.
Future<void> showFeedShareSheet(
  BuildContext context,
  WidgetRef ref,
  FeedPost original,
) async {
  final l10n = AppLocalizations.of(context)!;
  final me = ref.read(supabaseFeedDatasourceProvider).currentUserId;
  await VibraBottomSheet.show<void>(
    context,
    builder: (sheet) => _ShareSheet(
      original: original,
      canRepost: original.userId != me && original.everyone,
      title: l10n.feedShare,
    ),
  );
}

class _ShareSheet extends ConsumerStatefulWidget {
  const _ShareSheet({
    required this.original,
    required this.canRepost,
    required this.title,
  });
  final FeedPost original;
  final bool canRepost;
  final String title;

  @override
  ConsumerState<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<_ShareSheet> {
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _repost() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      await ref
          .read(supabaseFeedDatasourceProvider)
          .post(
            kind: FeedKind.share,
            sharedPostId: widget.original.id,
            body: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
      FeedActions(ref).changed(
        widget.original.copyWith(shareCount: widget.original.shareCount + 1),
      );
      for (final mode in [FeedMode.following, FeedMode.latest]) {
        ref.invalidate(feedProvider(mode));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack(context, l10n.feedShared);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _snack(
        context,
        '$e'.contains('duplicate_post')
            ? l10n.feedAlreadyShared
            : l10n.feedError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = widget.original.item;
    return VibraBottomSheet(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.canRepost) ...[
            TextField(
              controller: _comment,
              maxLength: 500,
              decoration: InputDecoration(hintText: l10n.feedShareCommentHint),
            ),
            FilledButton.icon(
              onPressed: _sending ? null : _repost,
              icon: const Icon(Icons.repeat_rounded),
              label: Text(l10n.feedShareToFeed),
            ),
          ] else
            Text(l10n.feedShareOnlyPublic),
          if (item != null) ...[
            const SizedBox(height: VibraSpacing.sm),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: item.externalUrl));
                if (!context.mounted) return;
                Navigator.of(context).pop();
                _snack(context, l10n.feedLinkCopied);
              },
              icon: const Icon(Icons.link_rounded),
              label: Text(l10n.feedCopyLink),
            ),
          ],
        ],
      ),
    );
  }
}

/// A person's latest posts on their profile, with a link to all of them.
class UserFeedPreview extends ConsumerWidget {
  const UserFeedPreview({
    required this.userId,
    this.displayName,
    this.limit = 2,
    super.key,
  });
  final String userId;
  final String? displayName;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final posts = ref.watch(userFeedPostsProvider(userId)).valueOrNull;
    if (posts == null || posts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.feedPostsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.push(
                '/user-posts',
                extra: {'userId': userId, 'displayName': displayName},
              ),
              child: Text(l10n.feedSeeAllPosts),
            ),
          ],
        ),
        for (final p in posts.take(limit))
          FeedPostCard(
            key: ValueKey(p.id),
            post: p,
            onChanged: (_) => ref.invalidate(userFeedPostsProvider(userId)),
          ),
      ],
    );
  }
}
