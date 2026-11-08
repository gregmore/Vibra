import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/music_reaction.dart';
import '../../domain/entities/daily_vibe.dart';
import '../../l10n/app_localizations.dart';
import '../providers/core_providers.dart';
import '../providers/daily_vibe_providers.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_bottom_sheet.dart';
import 'common/vibra_image.dart';
import 'common/vibra_surface.dart';
import 'community_widgets.dart';
import 'music_reactions.dart';

/// Opens the song on its provider. Vibra never plays or hosts audio.
Future<void> openOnProvider(VibeTrack track) async {
  final uri = Uri.tryParse(track.externalUrl);
  if (uri != null && uri.scheme == 'https') {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class DailyVibeCard extends ConsumerWidget {
  const DailyVibeCard({required this.vibe, this.mine = false, super.key});

  final DailyVibe vibe;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final track = vibe.track;
    final feed = ref.read(dailyVibeFeedProvider.notifier);
    // Rounded up: "1h left" until the last minute, never "0h" early.
    final minutesLeft = vibe.expiresAt?.difference(DateTime.now()).inMinutes;
    final hoursLeft = minutesLeft == null ? null : (minutesLeft / 60).ceil();
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.lg),
      child: VibraSurface(
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      context.push('/user-profile', extra: vibe.userId),
                  child: VibraAvatar(
                    imageUrl: vibe.avatarUrl,
                    name: vibe.name,
                    radius: 16,
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                Expanded(
                  child: Text(
                    [
                      vibe.name,
                      DateFormat.Hm(
                        Localizations.localeOf(context).toString(),
                      ).format(vibe.createdAt.toLocal()),
                      if (hoursLeft != null)
                        l10n.vibeExpiresIn(hoursLeft.clamp(0, 24)),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ),
                _VibeMenu(vibe: vibe, mine: mine),
              ],
            ),
            const SizedBox(height: VibraSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
                  child: SizedBox.square(
                    dimension: 88,
                    child: VibraNetworkImage(
                      url: track.artworkUrl,
                      cacheWidth: 200,
                      fallbackIcon: Icons.music_note_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: VibraSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(track.artist, style: theme.textTheme.bodyMedium),
                      if (track.album != null)
                        Text(
                          track.album!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: t.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: VibraSpacing.xs),
                      // Attribution and a link back, as the provider requires.
                      TextButton.icon(
                        onPressed: () => openOnProvider(track),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: track.isSpotify
                              ? VibraPalette.spotifyGreen
                              : t.textPrimary,
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(
                          track.isSpotify ? l10n.vibeListen : l10n.vibeOpen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (vibe.caption != null) ...[
              const SizedBox(height: VibraSpacing.sm),
              Text(vibe.caption!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: VibraSpacing.sm),
            // Musical reactions (docs/track-reactions.md).
            ReactionChips(
              options: MusicReactions.track,
              counts: vibe.reactions,
              mine: vibe.myReactions,
              hideEmpty: mine,
              onToggle: mine
                  ? null
                  : (r) async {
                      final on = !vibe.myReactions.contains(r);
                      if (!await feed.react(vibe, r)) {
                        if (context.mounted) {
                          _snack(context, l10n.communitiesError);
                        }
                      } else if (context.mounted && !vibe.saved) {
                        offerToSaveDiscovery(
                          context,
                          ref,
                          reaction: r,
                          turnedOn: on,
                          source: DiscoverySource.vibe,
                          id: vibe.id,
                          externalUrl: track.externalUrl,
                        );
                      }
                    },
            ),
            Wrap(
              spacing: VibraSpacing.xs,
              runSpacing: VibraSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => showVibeComments(context, ref, vibe),
                  icon: const Icon(Icons.mode_comment_outlined, size: 18),
                  label: Text(l10n.vibeComments(vibe.commentCount)),
                ),
                if (!mine)
                  TextButton.icon(
                    onPressed: vibe.saved
                        ? null
                        : () async {
                            if (!await feed.save(vibe) && context.mounted) {
                              _snack(context, l10n.communitiesError);
                            }
                          },
                    icon: Icon(
                      vibe.saved
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_outlined,
                      size: 18,
                    ),
                    label: Text(vibe.saved ? l10n.vibeSaved : l10n.vibeSave),
                  ),
              ],
            ),
            if (track.isSpotify)
              Text(
                l10n.vibeAttribution,
                style: theme.textTheme.labelSmall?.copyWith(color: t.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _VibeMenu extends ConsumerWidget {
  const _VibeMenu({required this.vibe, required this.mine});
  final DailyVibe vibe;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final source = ref.read(supabaseDailyVibeDatasourceProvider);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded),
      onSelected: (action) async {
        switch (action) {
          case 'delete':
            await source.deleteMine(vibe.id);
            ref.invalidate(dailyVibeFeedProvider);
          case 'report':
            final reason = await pickReportReason(context);
            if (reason == null) return;
            try {
              await source.report(
                reportedId: vibe.userId,
                reason: reason,
                vibeId: vibe.id,
              );
              if (context.mounted) _snack(context, l10n.communitiesReported);
            } catch (_) {
              if (context.mounted) _snack(context, l10n.socialReportFailed);
            }
          case 'block':
            if (await blockCommunityAuthor(context, ref, vibe.userId)) {
              ref.invalidate(dailyVibeFeedProvider);
            }
        }
      },
      itemBuilder: (_) => [
        if (mine) PopupMenuItem(value: 'delete', child: Text(l10n.vibeDelete)),
        if (!mine) ...[
          PopupMenuItem(value: 'report', child: Text(l10n.socialReportAction)),
          PopupMenuItem(value: 'block', child: Text(l10n.socialBlockUser)),
        ],
      ],
    );
  }
}

/// Same reasons as every other report in Vibra.
Future<String?> pickReportReason(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return VibraBottomSheet.show<String>(
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
}

// ── Comments and replies ───────────────────────────────────────────────────
Future<void> showVibeComments(
  BuildContext context,
  WidgetRef ref,
  DailyVibe vibe,
) =>
    VibraBottomSheet.show<void>(context, builder: (_) => _Comments(vibe: vibe));

class _Comments extends ConsumerStatefulWidget {
  const _Comments({required this.vibe});
  final DailyVibe vibe;

  @override
  ConsumerState<_Comments> createState() => _CommentsState();
}

class _CommentsState extends ConsumerState<_Comments> {
  final _text = TextEditingController();
  VibeComment? _replyTo;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(supabaseDailyVibeDatasourceProvider)
          .comment(widget.vibe.id, body, parentId: _replyTo?.id);
      _text.clear();
      setState(() => _replyTo = null);
      ref.invalidate(vibeCommentsProvider(widget.vibe.id));
      ref.invalidate(dailyVibeFeedProvider);
    } catch (e) {
      if (mounted) _snack(context, communityErrorText(l10n, e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final source = ref.read(supabaseDailyVibeDatasourceProvider);
    final me = source.currentUserId;
    final comments =
        ref.watch(vibeCommentsProvider(widget.vibe.id)).valueOrNull ??
        const <VibeComment>[];
    final roots = comments.where((c) => c.parentId == null).toList();
    List<VibeComment> repliesOf(VibeComment c) =>
        comments.where((x) => x.parentId == c.id).toList();

    Widget tile(VibeComment c, {bool reply = false}) => Padding(
      padding: EdgeInsets.only(left: reply ? 40 : 0, bottom: VibraSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VibraAvatar(imageUrl: c.avatarUrl, name: c.name, radius: 14),
          const SizedBox(width: VibraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: Theme.of(context).textTheme.labelLarge),
                Text(c.body),
                Row(
                  children: [
                    if (!reply)
                      TextButton(
                        onPressed: () => setState(() => _replyTo = c),
                        child: Text(l10n.vibeReply),
                      ),
                    if (c.authorId == me || widget.vibe.userId == me)
                      TextButton(
                        onPressed: () async {
                          await source.deleteComment(c.id);
                          ref.invalidate(vibeCommentsProvider(widget.vibe.id));
                        },
                        child: Text(l10n.communitiesDelete),
                      )
                    else
                      TextButton(
                        onPressed: () async {
                          final reason = await pickReportReason(context);
                          if (reason == null) return;
                          try {
                            await source.report(
                              reportedId: c.authorId,
                              reason: reason,
                              commentId: c.id,
                            );
                            if (context.mounted) {
                              _snack(context, l10n.communitiesReported);
                            }
                          } catch (_) {
                            if (context.mounted) {
                              _snack(context, l10n.socialReportFailed);
                            }
                          }
                        },
                        child: Text(l10n.socialReportAction),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return VibraBottomSheet(
      title: l10n.vibeComments(comments.length),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in roots) ...[
                  tile(c),
                  for (final r in repliesOf(c)) tile(r, reply: true),
                ],
              ],
            ),
          ),
          if (_replyTo != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.vibeReplyingTo(_replyTo!.name),
                    style: TextStyle(color: t.textSecondary),
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonCancel,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => setState(() => _replyTo = null),
                ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: l10n.vibeCommentHint,
                    counterText: '',
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.vibeCommentHint,
                onPressed: _sending ? null : _send,
                icon: Icon(Icons.send_rounded, color: t.accentPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
