import 'package:flutter/material.dart';

import '../../providers/app_state_providers.dart';
import '../vibra_glassmorphic_card.dart';
import '../vibra_neon_avatar.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';

class VibraUserMatchCard extends StatelessWidget {
  const VibraUserMatchCard({
    required this.user,
    this.onTap,
    this.trailing,
    super.key,
  });

  final MatchedUserPreview user;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchColor = VibraColors.getMatchColor(user.compatibility / 100.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: VibraSpacing.pagePadding, vertical: VibraSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: matchColor,
            width: 3.0,
          ),
        ),
        borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
      ),
      child: VibraGlassmorphicCard(
        onTap: onTap,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VibraNeonAvatar(
              imageUrl: user.user.avatarUrl ?? '',
              radius: 28,
              score: user.compatibility / 100.0,
              displayName: user.user.displayName ?? user.user.username,
            ),
            const SizedBox(width: VibraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.user.displayName ?? user.user.username,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: VibraSpacing.md, vertical: 4),
                        decoration: BoxDecoration(
                          color: matchColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
                        ),
                        child: Text(
                          '${user.compatibility}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: matchColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibraSpacing.xs),
                  Text(user.city, style: theme.textTheme.bodySmall),
                  const SizedBox(height: VibraSpacing.sm),
                  Wrap(
                    spacing: VibraSpacing.xs,
                    runSpacing: VibraSpacing.xs,
                    children: user.topArtists
                        .map(
                          (artist) => Chip(
                            avatar: const Icon(Icons.music_note_rounded, size: 14, color: VibraColors.primary),
                            label: Text(artist),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    '${user.attendingEvents} eventi in comune o salvati',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: VibraSpacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
