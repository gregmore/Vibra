import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/community_providers.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/community_widgets.dart';
import 'community_screen.dart';

/// Moderators' queue: content held after reports, or with pending reports.
class CommunityModerationScreen extends ConsumerWidget {
  const CommunityModerationScreen({required this.communityId, super.key});

  final String communityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.communitiesModeration)),
      child: ref
          .watch(moderationQueueProvider(communityId))
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.communitiesModeration,
              message: l10n.communitiesLoadError,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(moderationQueueProvider(communityId)),
            ),
            data: (items) => items.isEmpty
                ? VibraEmptyView(
                    title: l10n.communitiesModerationEmpty,
                    message: '',
                    icon: Icons.verified_user_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: VibraSpacing.md),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      Future<void> act(ContentAction a) => handleContentAction(
                        context,
                        ref,
                        a,
                        communityId: communityId,
                        authorId: item.authorId,
                        authorName: item.authorUsername,
                        postId: item.postId,
                        commentId: item.commentId,
                      );
                      return VibraSurface(
                        padding: const EdgeInsets.all(VibraSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${item.authorUsername} · ${l10n.communitiesReports(item.reportCount)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: t.textSecondary,
                              ),
                            ),
                            if (item.heldForReview)
                              Text(
                                l10n.communitiesHeld,
                                style: TextStyle(color: t.warning),
                              ),
                            if (item.title != null) ...[
                              const SizedBox(height: VibraSpacing.xs),
                              Text(
                                item.title!,
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                            const SizedBox(height: VibraSpacing.xs),
                            Text(item.body, maxLines: 6),
                            const SizedBox(height: VibraSpacing.md),
                            Wrap(
                              spacing: VibraSpacing.sm,
                              runSpacing: VibraSpacing.sm,
                              children: [
                                VibraButton(
                                  label: l10n.communitiesRestore,
                                  tone: VibraButtonTone.outline,
                                  size: VibraButtonSize.compact,
                                  onPressed: () => act(ContentAction.restore),
                                ),
                                VibraButton(
                                  label: l10n.communitiesRemove,
                                  tone: VibraButtonTone.danger,
                                  size: VibraButtonSize.compact,
                                  onPressed: () => act(ContentAction.remove),
                                ),
                                VibraButton(
                                  label: l10n.communitiesBan,
                                  tone: VibraButtonTone.text,
                                  size: VibraButtonSize.compact,
                                  onPressed: () => act(ContentAction.ban),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
    );
  }
}
