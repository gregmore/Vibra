import 'package:flutter/material.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';
import '../vibra_neon_avatar.dart';
import 'vibra_avatar.dart';
import 'vibra_match_indicator.dart';
import 'vibra_surface.dart';

/// Person card for discovery lists: avatar with score ring, name, city,
/// shared artists and the compatibility returned by the backend.
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
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final name = user.user.displayName ?? user.user.username;
    // Affinity only where a real match exists; people found by name search
    // (or without Spotify) show their username instead of a misleading 0%.
    final spotify =
        AppConstants.spotifyEnabled &&
        (user.compatibility > 0 || user.topArtists.isNotEmpty);

    return VibraSurface(
      onTap: onTap,
      semanticLabel: spotify
          ? '$name, ${l10n.eventAffinitySemantics(user.compatibility)}'
          : name,
      margin: const EdgeInsets.symmetric(
        horizontal: VibraSpacing.pagePadding,
        vertical: VibraSpacing.xs + 2,
      ),
      padding: const EdgeInsets.all(VibraSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (spotify)
            VibraNeonAvatar(
              imageUrl: user.user.avatarUrl ?? '',
              radius: 28,
              score: user.compatibility / 100.0,
              displayName: name,
            )
          else
            VibraAvatar(imageUrl: user.user.avatarUrl, radius: 28, name: name),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VibraTextStyles.titleMedium.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (user.city.isNotEmpty)
                  Text(
                    user.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VibraTextStyles.bodySmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                if (!spotify)
                  Text(
                    '@${user.user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VibraTextStyles.bodySmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                if (spotify && user.topArtists.isNotEmpty) ...[
                  const SizedBox(height: VibraSpacing.sm + 2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final artist in user.topArtists.take(3))
                        _ArtistTag(label: artist),
                    ],
                  ),
                ],
                if (spotify) ...[
                  const SizedBox(height: VibraSpacing.sm),
                  Text(
                    l10n.eventCommonSavedCount(user.attendingEvents),
                    style: VibraTextStyles.caption.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: VibraSpacing.sm),
          if (trailing != null)
            trailing!
          else if (spotify)
            VibraMatchIndicator(percentage: user.compatibility, size: 48),
        ],
      ),
    );
  }
}

/// Spec name for the component library.
typedef VibraUserCard = VibraUserMatchCard;

class _ArtistTag extends StatelessWidget {
  const _ArtistTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: t.surfaceMuted,
        borderRadius: VibraSpacing.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.graphic_eq_rounded, size: 12, color: t.accentPrimary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VibraTextStyles.caption.copyWith(color: t.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
