import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/community.dart';
import '../../domain/entities/music_reaction.dart';
import '../../l10n/app_localizations.dart';
import '../providers/core_providers.dart';
import '../providers/usecase_providers.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_bottom_sheet.dart';
import 'common/vibra_editorial_event.dart';
import 'common/vibra_surface.dart';
import 'music_reactions.dart';
import '../../domain/usecases/community_recommendations.dart';
import '../localization/music_affinity_text.dart';
import '../providers/community_providers.dart';
import 'common/vibra_button.dart';

/// User-facing text for a server error code (never the raw message).
String communityErrorText(AppLocalizations l10n, Object error) {
  final text = '$error';
  if (text.contains('PT429') || text.contains('Rate limit')) {
    return l10n.communitiesErrorRate;
  }
  if (text.contains('duplicate_content') ||
      text.contains('too_many_links') ||
      text.contains('suspicious_link') ||
      text.contains('flood')) {
    return l10n.communitiesErrorSpam;
  }
  if (text.contains('community_banned')) return l10n.communitiesErrorBanned;
  if (text.contains('invalid_music_link')) return l10n.communitiesErrorLink;
  if (text.contains('artist_community_exists')) {
    return l10n.communitiesErrorExists;
  }
  if (text.contains('_limit')) return l10n.communitiesErrorLimit;
  return l10n.communitiesError;
}

void communitySnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

String _when(BuildContext context, DateTime t) {
  final locale = Localizations.localeOf(context).toString();
  final local = t.toLocal();
  final now = DateTime.now();
  return now.difference(local).inHours < 24 && now.day == local.day
      ? DateFormat.Hm(locale).format(local)
      : DateFormat.MMMd(locale).format(local);
}

/// Report sheet shared by posts and comments (same reasons as chat).
Future<void> showCommunityReport(
  BuildContext context,
  WidgetRef ref, {
  required String reportedId,
  String? postId,
  String? commentId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final reason = await VibraBottomSheet.show<String>(
    context,
    builder: (sheet) => VibraBottomSheet(
      title: l10n.socialReportAction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in [
            ('spam', l10n.socialReportSpam),
            ('harassment', l10n.socialReportHarassment),
            ('inappropriate', l10n.socialReportInappropriate),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              onTap: () => Navigator.of(sheet).pop(value),
            ),
        ],
      ),
    ),
  );
  if (reason == null || !context.mounted) return;
  try {
    await ref
        .read(supabaseCommunitiesDatasourceProvider)
        .report(
          reportedId: reportedId,
          reason: reason,
          postId: postId,
          commentId: commentId,
        );
    if (context.mounted) communitySnack(context, l10n.communitiesReported);
  } catch (_) {
    if (context.mounted) communitySnack(context, l10n.socialReportFailed);
  }
}

/// Blocks with the existing social flow; their content disappears via RLS.
Future<bool> blockCommunityAuthor(
  BuildContext context,
  WidgetRef ref,
  String userId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l10n.socialBlockUser),
      content: Text(l10n.socialBlockConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(d).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(d).pop(true),
          child: Text(l10n.socialBlockAction),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await ref.read(blockUserUseCaseProvider).call(userId);
    if (context.mounted) communitySnack(context, l10n.socialBlockSuccess);
    return true;
  } catch (_) {
    if (context.mounted) communitySnack(context, l10n.socialBlockFailed);
    return false;
  }
}

enum ContentAction { report, block, delete, remove, restore, ban }

/// Overflow menu for a post or comment, offering only what the caller may do.
class ContentMenu extends StatelessWidget {
  const ContentMenu({
    required this.isMine,
    required this.canModerate,
    required this.onSelected,
    this.isRemovedOrHeld = false,
    super.key,
  });

  final bool isMine;
  final bool canModerate;
  final bool isRemovedOrHeld;
  final ValueChanged<ContentAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<ContentAction>(
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: onSelected,
      itemBuilder: (_) => [
        if (isMine)
          PopupMenuItem(
            value: ContentAction.delete,
            child: Text(l10n.communitiesDelete),
          ),
        if (!isMine) ...[
          PopupMenuItem(
            value: ContentAction.report,
            child: Text(l10n.socialReportAction),
          ),
          PopupMenuItem(
            value: ContentAction.block,
            child: Text(l10n.socialBlockUser),
          ),
        ],
        if (canModerate && !isMine) ...[
          if (isRemovedOrHeld)
            PopupMenuItem(
              value: ContentAction.restore,
              child: Text(l10n.communitiesRestore),
            ),
          PopupMenuItem(
            value: ContentAction.remove,
            child: Text(l10n.communitiesRemove),
          ),
          PopupMenuItem(
            value: ContentAction.ban,
            child: Text(l10n.communitiesBan),
          ),
        ],
      ],
    );
  }
}

class CommunityAuthorLine extends StatelessWidget {
  const CommunityAuthorLine({
    required this.author,
    required this.createdAt,
    this.trailing,
    super.key,
  });

  final CommunityAuthor author;
  final DateTime createdAt;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push('/user-profile', extra: author.id),
          child: VibraAvatar(
            imageUrl: author.avatarUrl,
            name: author.name,
            radius: 16,
          ),
        ),
        const SizedBox(width: VibraSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: author.name, style: theme.textTheme.titleSmall),
                TextSpan(
                  text: '  ·  ${_when(context, createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textMuted,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    required this.post,
    required this.onReact,
    required this.onAction,
    required this.isMine,
    required this.canModerate,
    required this.canInteract,
    this.onOpen,
    this.expanded = false,
    super.key,
  });

  final CommunityPost post;
  final void Function(String reaction) onReact;
  final ValueChanged<ContentAction> onAction;
  final VoidCallback? onOpen;
  final bool isMine;
  final bool canModerate;

  /// Members only: reactions are disabled for non-members.
  final bool canInteract;

  /// Post screen: full text, no "open" tap.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final music = post.music;
    final song = post.kind == CommunityPostKind.music && isSongLink(music?.url);
    return VibraSurface(
      onTap: expanded ? null : onOpen,
      padding: const EdgeInsets.fromLTRB(
        VibraSpacing.lg,
        VibraSpacing.md,
        VibraSpacing.xs,
        VibraSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityAuthorLine(
            author: post.author,
            createdAt: post.createdAt,
            trailing: ContentMenu(
              isMine: isMine,
              canModerate: canModerate,
              isRemovedOrHeld: post.heldForReview,
              onSelected: onAction,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: VibraSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.heldForReview)
                  Padding(
                    padding: const EdgeInsets.only(top: VibraSpacing.sm),
                    child: Text(
                      l10n.communitiesHeld,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: t.warning,
                      ),
                    ),
                  ),
                if (post.title != null) ...[
                  const SizedBox(height: VibraSpacing.sm),
                  Text(post.title!, style: theme.textTheme.titleMedium),
                ],
                if (post.body.isNotEmpty) ...[
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    post.body,
                    style: theme.textTheme.bodyMedium,
                    maxLines: expanded ? null : 6,
                    overflow: expanded ? null : TextOverflow.ellipsis,
                  ),
                ],
                if (music != null) ...[
                  const SizedBox(height: VibraSpacing.md),
                  _MusicTile(music: music),
                ],
                if (post.event != null) ...[
                  const SizedBox(height: VibraSpacing.md),
                  VibraEventRow(
                    event: post.event!,
                    onTap: () =>
                        context.push('/event-detail', extra: post.event),
                  ),
                ],
                const SizedBox(height: VibraSpacing.md),
                Wrap(
                  spacing: VibraSpacing.xs,
                  runSpacing: VibraSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Song shares get musical reactions (docs/track-reactions.md).
                    ReactionChips(
                      options: MusicReactions.forContent(song: song),
                      counts: post.reactions,
                      mine: post.myReactions,
                      hideEmpty: !canInteract,
                      onToggle: canInteract ? onReact : null,
                    ),
                    if (song && canInteract && !isMine)
                      SaveSongButton(
                        source: DiscoverySource.community,
                        id: post.id,
                        externalUrl: post.music!.url,
                      ),
                    if (!expanded)
                      TextButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(
                          Icons.mode_comment_outlined,
                          size: VibraSpacing.iconSm,
                        ),
                        label: Text(
                          l10n.communitiesComments(post.commentCount),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: t.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicTile extends StatelessWidget {
  const _MusicTile({required this.music});

  final SharedMusic music;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final host = Uri.tryParse(music.url)?.host.replaceFirst('www.', '') ?? '';
    return Container(
      padding: const EdgeInsets.all(VibraSpacing.md),
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        children: [
          Icon(Icons.graphic_eq_rounded, color: t.accentPrimary),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.title ?? host,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  music.artist ?? host,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              final uri = Uri.tryParse(music.url);
              if (uri != null && uri.scheme == 'https') {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(l10n.communitiesOpenMusic),
          ),
        ],
      ),
    );
  }
}

String communityReasonText(AppLocalizations l10n, CommunityReason reason) =>
    switch (reason) {
      TopArtistReason(:final artist) => l10n.communitiesReasonArtist(artist),
      GenreShareReason(:final genreKey, :final percent) =>
        l10n.communitiesReasonGenre(genreLabel(l10n, genreKey), percent),
    };

String communityKindLabel(AppLocalizations l10n, CommunityKind kind) =>
    switch (kind) {
      CommunityKind.genre => l10n.communitiesKindGenre,
      CommunityKind.artist => l10n.communitiesKindArtist,
      CommunityKind.interest => l10n.communitiesKindInterest,
    };

class CommunityCard extends ConsumerStatefulWidget {
  const CommunityCard({
    required this.community,
    this.headline,
    this.reason,
    super.key,
  });

  final Community community;
  final String? headline;
  final String? reason;

  @override
  ConsumerState<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends ConsumerState<CommunityCard> {
  bool _busy = false;

  Future<void> _join() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref.read(communitiesProvider.notifier).join(widget.community);
    } catch (e) {
      if (mounted) communitySnack(context, communityErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.community;
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final icon = switch (c.kind) {
      CommunityKind.artist => Icons.mic_external_on_rounded,
      CommunityKind.genre => Icons.graphic_eq_rounded,
      CommunityKind.interest => Icons.forum_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.sm),
      child: VibraSurface(
        onTap: () => context.push('/community', extra: c.id),
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: VibraSpacing.borderSmall,
              ),
              child: Icon(icon, color: t.textPrimary),
            ),
            const SizedBox(width: VibraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.headline != null) ...[
                    Text(
                      widget.headline!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: t.accentPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(c.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    widget.reason ??
                        [
                          if (c.isOfficial) l10n.communitiesOfficial,
                          communityKindLabel(l10n, c.kind),
                          l10n.communitiesMembers(c.memberCount),
                        ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: VibraSpacing.sm),
            if (c.isMember)
              Icon(Icons.check_circle_rounded, color: t.accentPrimary)
            else
              VibraButton(
                label: l10n.communitiesJoin,
                size: VibraButtonSize.compact,
                tone: VibraButtonTone.outline,
                loading: _busy,
                onPressed: _busy ? null : _join,
              ),
          ],
        ),
      ),
    );
  }
}
