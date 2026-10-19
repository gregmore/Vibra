import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';

import '../../providers/app_state_providers.dart';
import '../vibra_glassmorphic_card.dart';
import '../vibra_neon_avatar.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import 'vibra_avatar.dart';

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
    final t = context.vibraTokens;
    final matchColor = AppConstants.spotifyEnabled
        ? t.matchColor(user.compatibility / 100.0)
        : t.borderStrong;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.pagePadding,
        vertical: VibraSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: matchColor, width: 3.0)),
        borderRadius: VibraSpacing.borderMedium,
      ),
      child: VibraGlassmorphicCard(
        onTap: onTap,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(VibraSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppConstants.spotifyEnabled)
              VibraNeonAvatar(
                imageUrl: user.user.avatarUrl ?? '',
                radius: 28,
                score: user.compatibility / 100.0,
                displayName: user.user.displayName ?? user.user.username,
              )
            else
              VibraAvatar(
                imageUrl: user.user.avatarUrl,
                radius: 28,
                name: user.user.displayName ?? user.user.username,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (AppConstants.spotifyEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VibraSpacing.md,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: t.surfaceMuted,
                            borderRadius: VibraSpacing.borderFull,
                            border: Border.all(color: matchColor, width: 1.5),
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
                  if (AppConstants.spotifyEnabled)
                    Wrap(
                      spacing: VibraSpacing.xs,
                      runSpacing: VibraSpacing.xs,
                      children: user.topArtists
                          .map(
                            (artist) => Chip(
                              avatar: Icon(
                                Icons.music_note_rounded,
                                size: 14,
                                color: t.accentPrimary,
                              ),
                              label: Text(artist),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    AppConstants.spotifyEnabled
                        ? AppLocalizations.of(
                            context,
                          )!.eventCommonSavedCount(user.attendingEvents)
                        : '@${user.user.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: t.textSecondary,
                    ),
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
