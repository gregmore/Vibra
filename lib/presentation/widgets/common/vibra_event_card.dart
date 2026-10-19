import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
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

  int? get _visibleMatchScore =>
      AppConstants.spotifyEnabled ? matchScore : null;
  final VoidCallback? onTap;

  Color _getBadgeColor(BuildContext context, int score) {
    return context.vibraTokens.matchColor(score / 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final dateText = DateFormat.MMMd(
      Localizations.localeOf(context).toString(),
    ).format(event.eventDate.toLocal());

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
                scoreAtTime: _visibleMatchScore?.toDouble(),
              );
          onTap?.call();
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_visibleMatchScore != null) ...[
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VibraSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(
                            context,
                            _visibleMatchScore!,
                          ).withValues(alpha: 0.1),
                          border: Border.all(
                            color: _getBadgeColor(context, _visibleMatchScore!),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            VibraSpacing.radiusFull,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getBadgeColor(
                                context,
                                _visibleMatchScore!,
                              ).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          l10n.eventForYouScore(_visibleMatchScore!),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: t.onImage,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: VibraSpacing.animNormal)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: VibraSpacing.sm),
                ],
                Text(
                  event.name,
                  style: theme.textTheme.titleLarge?.copyWith(color: t.onImage),
                ),
                const SizedBox(height: 6),
                Text(
                  '${event.venueName ?? AppLocalizations.of(context)!.eventCardTBA} · ${event.city ?? AppLocalizations.of(context)!.eventCardCity}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.onImageMuted,
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
                            scoreAtTime: _visibleMatchScore?.toDouble(),
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
                  color: t.surfaceElevated,
                  borderRadius: BorderRadius.circular(
                    VibraSpacing.radiusMedium,
                  ),
                  border: Border.all(color: t.borderDefault),
                ),
                child: Text(
                  dateText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: t.textPrimary,
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
                scoreAtTime: _visibleMatchScore?.toDouble(),
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
                        memCacheWidth: 216,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: t.shimmerBase,
                          highlightColor: t.shimmerHighlight,
                          child: Container(color: t.surfaceElevated),
                        ),
                        errorWidget: (context, url, error) =>
                            _fallbackPoster(context),
                      )
                    : _fallbackPoster(context),
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
                if (_visibleMatchScore != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getBadgeColor(
                        context,
                        _visibleMatchScore!,
                      ).withValues(alpha: 0.1),
                      border: Border.all(
                        color: _getBadgeColor(context, _visibleMatchScore!),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        VibraSpacing.radiusSmall,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getBadgeColor(
                            context,
                            _visibleMatchScore!,
                          ).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '$_visibleMatchScore%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _getBadgeColor(context, _visibleMatchScore!),
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

    return Semantics(
      button: true,
      label: [
        l10n.eventOpenSemantics(
          event.name,
          dateText,
          event.city ?? l10n.eventVenueTBA,
        ),
        if (_visibleMatchScore != null)
          l10n.eventAffinitySemantics(_visibleMatchScore!),
      ].join(', '),
      child: card
          .animate(
            target: MediaQuery.maybeOf(context)?.disableAnimations ?? false
                ? 0
                : 1,
          )
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _fallbackPoster(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      decoration: BoxDecoration(gradient: t.primaryGradient),
      child: Icon(Icons.multitrack_audio_rounded, color: t.onAccent),
    );
  }
}
