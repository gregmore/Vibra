import 'package:flutter/material.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../domain/entities/circle.dart';
import '../../l10n/app_localizations.dart';
import 'common/vibra_surface.dart';

String circleBasisLabel(AppLocalizations l10n, CircleBasis b) => switch (b) {
  CircleBasis.genre => l10n.circlesBasisGenre,
  CircleBasis.artist => l10n.circlesBasisArtist,
  CircleBasis.concert => l10n.circlesBasisConcert,
  CircleBasis.interest => l10n.circlesBasisInterest,
  CircleBasis.activity => l10n.circlesBasisActivity,
};

/// One of my VIBRA Circles: name, what it is about, members and capacity,
/// and whether I muted it.
class VibraCircleCard extends StatelessWidget {
  const VibraCircleCard({required this.circle, this.onTap, super.key});

  final Circle circle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    return VibraSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.bubble_chart_outlined, color: t.accentPrimary),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circle.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${circleBasisLabel(l10n, circle.basis)} · '
                  '${l10n.circlesMembers(circle.memberCount, circle.maxMembers)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (circle.muted)
            Semantics(
              label: l10n.circlesMuted,
              child: Icon(Icons.notifications_off_outlined, color: t.textMuted),
            ),
        ],
      ),
    );
  }
}
