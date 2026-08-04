import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../domain/entities/event.dart';
import '../vibra_glassmorphic_card.dart';
import '../vibra_pill_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../providers/usecase_providers.dart';

class VibraEventCard extends ConsumerWidget {
  const VibraEventCard({
    required this.event,
    this.compact = false,
    this.matchScore,
    this.onTap,
    super.key,
  });

  final Event event;
  final bool compact;
  final int? matchScore;
  final VoidCallback? onTap;

  Color _getBadgeColor(BuildContext context, int score) {
    return VibraColors.getMatchColor(score / 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateText =
        '${event.eventDate.day.toString().padLeft(2, '0')}/${event.eventDate.month.toString().padLeft(2, '0')}';

    Widget card;

    if (!compact) {
      card = VibraGlassmorphicImageCard(
        imageUrl: event.imageUrl ?? '',
        height: 280,
        onTap: () {
          ref
              .read(logEventInteractionUseCaseProvider)
              .execute(
                event: event,
                interactionType: 'view',
                scoreAtTime: matchScore?.toDouble(),
              );
          onTap?.call();
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (matchScore != null) ...[
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VibraSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(
                            context,
                            matchScore!,
                          ).withValues(alpha: 0.1),
                          border: Border.all(
                            color: _getBadgeColor(context, matchScore!),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            VibraSpacing.radiusFull,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getBadgeColor(
                                context,
                                matchScore!,
                              ).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          '$matchScore% MATCH',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getBadgeColor(context, matchScore!),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: VibraSpacing.animNormal)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: VibraSpacing.sm),
                ],
                Text(event.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '${event.venueName ?? AppLocalizations.of(context)!.eventCardTBA} · ${event.city ?? AppLocalizations.of(context)!.eventCardCity}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: VibraSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: VibraPillButton(
                    text: AppLocalizations.of(context)!.eventDetailBuyTickets,
                    onPressed: () {
                      ref
                          .read(logEventInteractionUseCaseProvider)
                          .execute(
                            event: event,
                            interactionType: 'click_ticket',
                            scoreAtTime: matchScore?.toDouble(),
                          );
                      onTap?.call();
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: VibraSpacing.md,
                  vertical: VibraSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: VibraColors.surfaceElevated.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  border: Border.all(color: VibraColors.glassBorder),
                ),
                child: Text(
                  dateText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      card = VibraGlassmorphicCard(
        onTap: () {
          ref
              .read(logEventInteractionUseCaseProvider)
              .execute(
                event: event,
                interactionType: 'view',
                scoreAtTime: matchScore?.toDouble(),
              );
          onTap?.call();
        },
        margin: const EdgeInsets.symmetric(
          horizontal: VibraSpacing.xl,
          vertical: VibraSpacing.sm,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(VibraSpacing.radiusSmall),
              child: SizedBox(
                width: 72,
                height: 72,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: event.imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 200,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: VibraColors.shimmerBase,
                          highlightColor: VibraColors.shimmerHighlight,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => _fallbackPoster(),
                      )
                    : _fallbackPoster(),
              ),
            ),
            const SizedBox(width: VibraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.city ??
                        AppLocalizations.of(context)!.eventCardLocation,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dateText, style: theme.textTheme.titleMedium),
                if (matchScore != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getBadgeColor(
                        context,
                        matchScore!,
                      ).withValues(alpha: 0.1),
                      border: Border.all(
                        color: _getBadgeColor(context, matchScore!),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusSmall,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getBadgeColor(
                            context,
                            matchScore!,
                          ).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '$matchScore%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _getBadgeColor(context, matchScore!),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).blurXY(begin: 4, end: 0),
              ],
            ),
          ],
        ),
      );
    }

    return card.animate().slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _fallbackPoster() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [VibraColors.primary, VibraColors.accent],
        ),
      ),
      child: const Icon(Icons.multitrack_audio_rounded, color: Colors.white),
    );
  }
}
