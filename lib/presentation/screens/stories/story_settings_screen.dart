import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/music_story.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/music_story_providers.dart';
import '../../widgets/common/vibra_avatar.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Story privacy (docs/music-stories.md): default audience, replies, and
/// people your stories are hidden from. Nobody is told they are hidden.
class StorySettingsScreen extends ConsumerWidget {
  const StorySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final source = ref.read(supabaseMusicStoriesDatasourceProvider);

    Future<void> save(StorySettings s) async {
      try {
        await source.saveSettings(s);
        ref.invalidate(storySettingsProvider);
      } catch (_) {
        if (context.mounted) _snack(context, l10n.storyError);
      }
    }

    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.storySettingsTitle)),
      child: ref
          .watch(storySettingsProvider)
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.storySettingsTitle,
              message: l10n.storyError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(storySettingsProvider),
            ),
            data: (s) => ListView(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
                VibraSpacing.pagePadding,
                VibraSpacing.colossal,
              ),
              children: [
                Text(
                  l10n.storyDefaultAudience,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: VibraSpacing.sm),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.group_rounded),
                      label: Text(l10n.storyAudienceConnections),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.public_rounded),
                      label: Text(l10n.storyAudienceEveryone),
                    ),
                  ],
                  selected: {s.everyone},
                  onSelectionChanged: (v) => save(
                    StorySettings(
                      everyone: v.first,
                      allowReplies: s.allowReplies,
                    ),
                  ),
                ),
                const SizedBox(height: VibraSpacing.xs),
                Text(
                  s.everyone
                      ? l10n.storyAudienceEveryoneBody
                      : l10n.storyAudienceConnectionsBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.storyAllowReplies),
                  subtitle: Text(l10n.storyAllowRepliesBody),
                  value: s.allowReplies,
                  onChanged: (v) => save(
                    StorySettings(everyone: s.everyone, allowReplies: v),
                  ),
                ),
                const SizedBox(height: VibraSpacing.lg),
                Text(l10n.storyHideFrom, style: theme.textTheme.titleSmall),
                const SizedBox(height: VibraSpacing.xs),
                Text(
                  l10n.storyHideFromBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                const _Audience(),
              ],
            ),
          ),
    );
  }
}

class _Audience extends ConsumerWidget {
  const _Audience();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    return ref
        .watch(storyAudienceProvider)
        .when(
          loading: () => const VibraLoadingIndicator(),
          error: (_, _) => Text(l10n.storyError),
          data: (people) => people.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: VibraSpacing.lg,
                  ),
                  child: Text(
                    l10n.storyNoConnections,
                    style: TextStyle(color: t.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    for (final p in people)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: VibraAvatar(
                          imageUrl: p.avatarUrl,
                          name: p.name,
                          radius: 18,
                        ),
                        title: Text(p.name),
                        subtitle: p.flag ? Text(l10n.storyHidden) : null,
                        value: p.flag,
                        onChanged: (v) async {
                          try {
                            await ref
                                .read(supabaseMusicStoriesDatasourceProvider)
                                .setHiddenFrom(p.userId, v == true);
                            ref.invalidate(storyAudienceProvider);
                          } catch (_) {
                            if (context.mounted) {
                              _snack(context, l10n.storyError);
                            }
                          }
                        },
                      ),
                  ],
                ),
        );
  }
}
