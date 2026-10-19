import 'package:intl/intl.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../providers/usecase_providers.dart';
import '../vibra_signal_wave.dart';

/// Il contenuto editoriale dominante in Home: un poster, non una card CTA.
class VibraEventFeature extends ConsumerWidget {
  const VibraEventFeature({
    required this.event,
    required this.onTap,
    super.key,
    this.matchScore,
    this.height = 420,
  });

  final Event event;
  final VoidCallback onTap;
  final int? matchScore;

  int? get _visibleMatchScore =>
      AppConstants.spotifyEnabled ? matchScore : null;
  final double height;

  void _open(WidgetRef ref) {
    ref
        .read(logEventInteractionUseCaseProvider)
        .execute(
          event: event,
          interactionType: 'view',
          scoreAtTime: _visibleMatchScore?.toDouble(),
        );
    onTap();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMM(
      locale,
    ).format(event.eventDate.toLocal()).toUpperCase();
    final place = event.venueName ?? event.city ?? l10n.eventVenueTBA;

    return Semantics(
      button: true,
      label: [
        l10n.eventOpenSemantics(
          event.name,
          DateFormat.yMMMd(locale).format(event.eventDate.toLocal()),
          place,
        ),
        if (_visibleMatchScore != null)
          l10n.eventAffinitySemantics(_visibleMatchScore!),
      ].join(', '),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: VibraSpacing.borderMedium,
          child: Material(
            color: t.imageOverlay,
            child: InkWell(
              onTap: () => _open(ref),
              splashColor: t.accentPrimary.withValues(alpha: 0.22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: event.imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      errorWidget: (_, _, _) => _FallbackPoster(),
                    )
                  else
                    _FallbackPoster(),
                  // WCAG safeguard: 60% black remains >= 4.5:1 for white text
                  // even when the underlying poster is pure white.
                  ColoredBox(color: t.imageScrim),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceElevated,
                        borderRadius: VibraSpacing.borderSmall,
                        border: Border.all(color: t.borderDefault),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.eventDate.day.toString().padLeft(2, '0'),
                            style: VibraTextStyles.titleLarge.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            month,
                            style: VibraTextStyles.labelSmall.copyWith(
                              color: t.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_visibleMatchScore != null)
                    Positioned(
                      top: 16,
                      right: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.accentPrimary,
                          borderRadius: VibraSpacing.borderSmall,
                          border: Border.all(color: t.onAccent, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        child: Text(
                          l10n.eventForYouScore(_visibleMatchScore!),
                          style: VibraTextStyles.labelSmall.copyWith(
                            color: t.onAccent,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      color: t.imageOverlay,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 104,
                            child: VibraSignalWave(
                              height: 18,
                              color: t.accentPrimary,
                              secondaryColor: t.onImage,
                              amplitude: 4,
                              strokeWidth: 1.5,
                              animate: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: VibraTextStyles.headlineLarge.copyWith(
                              color: t.onImage,
                              fontSize: 23,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: VibraTextStyles.bodySmall.copyWith(
                              color: t.onImageMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VibraEventRow extends ConsumerWidget {
  const VibraEventRow({
    required this.event,
    required this.onTap,
    super.key,
    this.matchScore,
    this.showDivider = true,
  });

  final Event event;
  final VoidCallback onTap;
  final int? matchScore;

  int? get _visibleMatchScore =>
      AppConstants.spotifyEnabled ? matchScore : null;
  final bool showDivider;

  void _open(WidgetRef ref) {
    ref
        .read(logEventInteractionUseCaseProvider)
        .execute(
          event: event,
          interactionType: 'view',
          scoreAtTime: _visibleMatchScore?.toDouble(),
        );
    onTap();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMM(
      locale,
    ).format(event.eventDate.toLocal()).toUpperCase();
    final place = event.venueName ?? event.city ?? l10n.eventVenueTBA;
    return Semantics(
      button: true,
      label: [
        l10n.eventOpenSemantics(
          event.name,
          DateFormat.yMMMd(locale).format(event.eventDate.toLocal()),
          place,
        ),
        if (_visibleMatchScore != null)
          l10n.eventAffinitySemantics(_visibleMatchScore!),
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _open(ref),
          splashColor: t.accentPrimary.withValues(alpha: 0.18),
          hoverColor: t.accentPrimary.withValues(alpha: 0.08),
          focusColor: t.accentPrimary.withValues(alpha: 0.12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: t.borderDefault))
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 46,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventDate.day.toString().padLeft(2, '0'),
                        style: VibraTextStyles.displaySmall.copyWith(
                          color: t.textPrimary,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        month,
                        style: VibraTextStyles.labelSmall.copyWith(
                          color: t.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: VibraTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VibraTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_visibleMatchScore != null)
                      Text(
                        '$_visibleMatchScore%',
                        style: VibraTextStyles.labelLarge.copyWith(
                          color: t.matchColor(_visibleMatchScore! / 100),
                        ),
                      ),
                    const SizedBox(height: 7),
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: t.textPrimary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackPoster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return ColoredBox(
      color: t.imageOverlay,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.center,
          child: VibraSignalWave(
            height: 96,
            color: t.accentPrimary,
            secondaryColor: t.onImage,
            amplitude: 24,
            strokeWidth: 3,
            animate: true,
          ),
        ),
      ),
    );
  }
}
