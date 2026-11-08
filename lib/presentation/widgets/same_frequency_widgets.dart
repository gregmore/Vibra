import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/music_affinity.dart';
import '../../domain/entities/same_frequency.dart';
import '../../l10n/app_localizations.dart';
import '../localization/music_affinity_text.dart';
import '../providers/direct_message_permission_provider.dart';
import 'common/vibra_avatar.dart';
import 'common/vibra_bottom_sheet.dart';
import 'common/vibra_button.dart';
import 'common/vibra_match_indicator.dart';
import 'common/vibra_surface.dart';

/// Sentences explaining why this person was recommended, strongest and most
/// specific first. Every line comes from the server's signals.
List<String> frequencyReasons(
  BuildContext context,
  FrequencyCandidate person, {
  int max = 3,
}) {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toString();
  final lines = <String>[
    if (person.sharedDiscoveries.isNotEmpty)
      l10n.sameFrequencyReasonDiscoveries(
        joinGenres(l10n, person.sharedDiscoveries),
      ),
    if (person.risingFamilies.isNotEmpty)
      l10n.sameFrequencyReasonDirection(
        joinGenres(l10n, [
          for (final f in person.risingFamilies) genreFamilyLabel(l10n, f),
        ]),
      ),
    if (person.sharedEvent case final event?)
      l10n.sameFrequencyReasonEvent(
        event.artist?.isNotEmpty == true ? event.artist! : event.name,
        event.date == null ? '' : DateFormat.MMMd(locale).format(event.date!),
      )
    else if (person.sharedEvents > 0)
      l10n.sameFrequencyReasonEvents(person.sharedEvents),
    if (person.sharedCommunities.isNotEmpty)
      l10n.sameFrequencyReasonCommunities(
        joinGenres(l10n, person.sharedCommunities.take(2).toList()),
      ),
    for (final reason in person.affinity.reasons)
      if (reason is! DiversityReason &&
          reason is! DiscoveryReason &&
          // The artists are already listed by name on the card.
          (reason is! SharedArtistsReason ||
              person.affinity.sharedArtists.isEmpty))
        affinityReasonText(l10n, reason),
  ];
  return lines.take(max).toList(growable: false);
}

class SameFrequencyCard extends ConsumerWidget {
  const SameFrequencyCard({
    required this.person,
    required this.onToggleSaved,
    this.onSendVibra,
    super.key,
  });

  final FrequencyCandidate person;
  final VoidCallback onToggleSaved;

  /// Null on the Saved tab (the person may already be connected).
  final VoidCallback? onSendVibra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final affinity = person.affinity;
    final genres = <String>{
      for (final f in affinity.sharedFamilies) genreFamilyLabel(l10n, f),
      for (final s in affinity.sharedSubgenres) genreLabel(l10n, s),
    }.take(4).toList();
    final reasons = frequencyReasons(context, person);
    final canMessage =
        ref
            .watch(directMessagePermissionProvider(person.userId))
            .valueOrNull
            ?.canSend ??
        false;
    return VibraSurface(
      onTap: () => context.push('/user-profile', extra: person.userId),
      semanticLabel: l10n.sameFrequencyPersonSemantics(
        person.name,
        '${person.compatibility}',
      ),
      padding: const EdgeInsets.all(VibraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VibraAvatar(
                imageUrl: person.avatarUrl,
                name: person.name,
                radius: 28,
                signalRing: person.compatibility >= 80,
              ),
              const SizedBox(width: VibraSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${person.username}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (person.compatibility > 0)
                VibraMatchBadge(percentage: person.compatibility),
            ],
          ),
          if (genres.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.lg),
            _Label(l10n.affinitySharedGenres),
            const SizedBox(height: VibraSpacing.xs),
            Text(
              genres.join(' · ').toUpperCase(),
              style: VibraTextStyles.labelLarge.copyWith(
                color: t.accentPrimary,
                letterSpacing: .6,
              ),
            ),
          ],
          if (affinity.sharedArtists.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.md),
            _Label(l10n.affinityArtistsInCommon),
            const SizedBox(height: VibraSpacing.xs),
            Text(
              affinity.sharedArtists.take(3).join(' · '),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: VibraSpacing.lg),
            _Label(l10n.sameFrequencyWhy),
            const SizedBox(height: VibraSpacing.sm),
            for (final line in reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: VibraSpacing.xs + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: t.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: VibraSpacing.md),
                    Expanded(
                      child: Text(
                        line,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: t.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (affinity.sharedArtists.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showSharedArtists(context, person),
              icon: const Icon(Icons.album_outlined, size: VibraSpacing.iconMd),
              label: Text(l10n.sameFrequencyDiscoverArtists),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: t.textPrimary,
              ),
            ),
          const SizedBox(height: VibraSpacing.md),
          Row(
            children: [
              if (onSendVibra != null) ...[
                Expanded(
                  child: VibraButton(
                    label: l10n.socialMatchSendVibra,
                    tone: VibraButtonTone.signal,
                    size: VibraButtonSize.compact,
                    expanded: true,
                    onPressed: onSendVibra,
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
              ],
              if (canMessage) ...[
                Expanded(
                  child: VibraButton(
                    label: l10n.socialMessageAction,
                    tone: VibraButtonTone.outline,
                    size: VibraButtonSize.compact,
                    expanded: true,
                    leadingIcon: Icons.chat_bubble_outline_rounded,
                    onPressed: () => context.push(
                      '/chat',
                      extra: <String, dynamic>{
                        'otherUserId': person.userId,
                        'otherDisplayName': person.name,
                      },
                    ),
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
              ],
              IconButton.outlined(
                tooltip: person.saved
                    ? l10n.sameFrequencySaved
                    : l10n.sameFrequencySave,
                isSelected: person.saved,
                selectedIcon: Icon(
                  Icons.bookmark_rounded,
                  color: t.accentPrimary,
                ),
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: onToggleSaved,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: context.vibraTokens.textMuted,
      letterSpacing: 1.1,
    ),
  );
}

void _showSharedArtists(BuildContext context, FrequencyCandidate person) {
  final l10n = AppLocalizations.of(context)!;
  VibraBottomSheet.show<void>(
    context,
    builder: (sheetContext) => VibraBottomSheet(
      title: l10n.sameFrequencySharedArtistsTitle(person.name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final artist in person.affinity.sharedArtists)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.music_note_rounded),
              title: Text(artist),
              trailing: TextButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.go(
                    Uri(
                      path: '/explore',
                      queryParameters: {'q': artist},
                    ).toString(),
                  );
                },
                child: Text(l10n.sameFrequencyFindEvents),
              ),
            ),
        ],
      ),
    ),
  );
}
