import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../providers/usecase_providers.dart';
import 'vibra_badge.dart';
import 'vibra_event_meta.dart';
import 'vibra_image.dart';
import 'vibra_match_indicator.dart';

const _greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0,
]);

String _semantics(
  BuildContext context,
  Event event,
  VibraEventStatus status,
  int? score,
) {
  final l10n = AppLocalizations.of(context)!;
  final date = VibraEventDate(context, event.eventDate);
  final place = event.venueName ?? event.city ?? l10n.eventVenueTBA;
  return [
    l10n.eventOpenSemantics(event.name, date.medium, place),
    if (status != VibraEventStatus.upcoming) status.label(l10n),
    if (score != null) l10n.eventAffinitySemantics(score),
  ].join(', ');
}

void _logView(WidgetRef ref, Event event, int? score) {
  ref
      .read(logEventInteractionUseCaseProvider)
      .execute(
        event: event,
        interactionType: 'view',
        scoreAtTime: score?.toDouble(),
      );
}

/// Hero event poster: the dominant recommendation on Home and Explore.
///
/// Full-bleed artwork, a date stamp, the match score and a bottom panel with
/// name, venue, time, price and lifecycle status.
class VibraEventFeature extends ConsumerStatefulWidget {
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
  final double height;

  @override
  ConsumerState<VibraEventFeature> createState() => _VibraEventFeatureState();
}

class _VibraEventFeatureState extends ConsumerState<VibraEventFeature> {
  bool _pressed = false;

  int? get _score => AppConstants.spotifyEnabled ? widget.matchScore : null;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final event = widget.event;
    final status = vibraEventStatus(event);
    final date = VibraEventDate(context, event.eventDate);
    final place = [
      event.venueName,
      event.city,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final price = vibraEventPriceLabel(context, event);
    final radius = BorderRadius.circular(VibraSpacing.radiusXL);

    Widget artwork = VibraNetworkImage(url: event.imageUrl, cacheWidth: 420);
    if (status.isInactive) {
      artwork = ColorFiltered(colorFilter: _greyscale, child: artwork);
    }

    return Semantics(
      button: true,
      label: _semantics(context, event, status, _score),
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? VibraMotion.pressedScale : 1,
        duration: VibraMotion.durationFor(
          context,
          _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
        ),
        curve: VibraMotion.signalCurve,
        child: SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: radius,
            child: Material(
              color: t.surface,
              child: InkWell(
                onTap: () {
                  _logView(ref, event, _score);
                  widget.onTap();
                },
                onHighlightChanged: (v) => setState(() => _pressed = v),
                splashColor: t.accentPrimary.withValues(alpha: 0.16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    artwork,
                    VibraImageScrim(color: t.imageOverlay, start: .3),
                    Positioned(
                      top: VibraSpacing.md,
                      left: VibraSpacing.md,
                      child: _DateStamp(date: date),
                    ),
                    if (_score != null)
                      Positioned(
                        top: VibraSpacing.md + 4,
                        right: VibraSpacing.md,
                        child: VibraMatchBadge(
                          percentage: _score!,
                          onImage: true,
                        ),
                      ),
                    Positioned(
                      left: VibraSpacing.xl,
                      right: VibraSpacing.xl,
                      bottom: VibraSpacing.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status != VibraEventStatus.upcoming) ...[
                            VibraEventStatusBadge(status: status),
                            const SizedBox(height: VibraSpacing.sm),
                          ],
                          if (event.artistName != null &&
                              event.artistName!.isNotEmpty &&
                              event.artistName != event.name) ...[
                            Text(
                              event.artistName!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VibraTextStyles.labelSmall.copyWith(
                                color: t.onImageMuted,
                              ),
                            ),
                            const SizedBox(height: VibraSpacing.xs),
                          ],
                          Text(
                            event.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: VibraTextStyles.headlineMedium.copyWith(
                              color: t.onImage,
                              decoration: status == VibraEventStatus.cancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: t.onImage,
                            ),
                          ),
                          const SizedBox(height: VibraSpacing.sm),
                          _MetaLine(
                            icon: Icons.place_outlined,
                            text: place.isEmpty ? l10n.eventVenueTBA : place,
                            color: t.onImageMuted,
                          ),
                          const SizedBox(height: VibraSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                child: _MetaLine(
                                  icon: Icons.schedule_rounded,
                                  text: date.weekdayTime,
                                  color: t.onImageMuted,
                                ),
                              ),
                              if (price != null && !status.isInactive) ...[
                                const SizedBox(width: VibraSpacing.sm),
                                VibraBadge(
                                  label: price,
                                  tone: VibraBadgeTone.onImage,
                                  icon: Icons.confirmation_number_outlined,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// List row: thumbnail, name, venue, date/time, status and match.
class VibraEventRow extends ConsumerStatefulWidget {
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

  /// Kept for API compatibility; rows are now separated by spacing.
  final bool showDivider;

  @override
  ConsumerState<VibraEventRow> createState() => _VibraEventRowState();
}

class _VibraEventRowState extends ConsumerState<VibraEventRow> {
  bool _pressed = false;

  int? get _score => AppConstants.spotifyEnabled ? widget.matchScore : null;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final event = widget.event;
    final status = vibraEventStatus(event);
    final date = VibraEventDate(context, event.eventDate);
    final place = event.venueName ?? event.city ?? l10n.eventVenueTBA;
    final price = vibraEventPriceLabel(context, event);

    Widget thumb = VibraNetworkImage(url: event.imageUrl, cacheWidth: 80);
    if (status.isInactive) {
      thumb = ColorFiltered(colorFilter: _greyscale, child: thumb);
    }

    return Semantics(
      button: true,
      label: _semantics(context, event, status, _score),
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: VibraMotion.durationFor(
          context,
          _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
        ),
        curve: VibraMotion.signalCurve,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _logView(ref, event, _score);
              widget.onTap();
            },
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: VibraSpacing.borderMedium,
            splashColor: t.accentPrimary.withValues(alpha: 0.10),
            highlightColor: t.textPrimary.withValues(alpha: 0.03),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: VibraSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ClipRRect(
                      borderRadius: VibraSpacing.borderMedium,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          thumb,
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              color: t.imageOverlay,
                              child: Text(
                                '${date.day} ${date.month}',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: VibraTextStyles.labelSmall.copyWith(
                                  color: t.onImage,
                                  fontSize: 10,
                                  letterSpacing: .4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          style: VibraTextStyles.titleMedium.copyWith(
                            color: status.isInactive
                                ? t.textSecondary
                                : t.textPrimary,
                            decoration: status == VibraEventStatus.cancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: VibraTextStyles.bodySmall.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: VibraSpacing.sm,
                          runSpacing: VibraSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              date.weekdayTime,
                              style: VibraTextStyles.caption.copyWith(
                                color: t.textSecondary,
                              ),
                            ),
                            if (status != VibraEventStatus.upcoming)
                              VibraEventStatusBadge(status: status)
                            else if (price != null)
                              Text(
                                price,
                                style: VibraTextStyles.caption.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: VibraSpacing.sm),
                  if (_score != null)
                    VibraMatchBadge(percentage: _score!)
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: t.textMuted,
                      size: VibraSpacing.iconMd,
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

class _DateStamp extends StatelessWidget {
  const _DateStamp({required this.date});

  final VibraEventDate date;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: t.imageOverlay,
        borderRadius: VibraSpacing.borderSmall,
      ),
      child: Column(
        children: [
          Text(
            date.day,
            style: VibraTextStyles.headlineSmall.copyWith(
              color: t.onImage,
              height: 1,
            ),
            textScaler: TextScaler.noScaling,
          ),
          const SizedBox(height: 2),
          Text(
            date.month,
            style: VibraTextStyles.labelSmall.copyWith(
              color: t.onImageMuted,
              fontSize: 10,
            ),
            textScaler: TextScaler.noScaling,
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: VibraSpacing.iconSm, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: VibraTextStyles.bodySmall.copyWith(color: color),
        ),
      ),
    ],
  );
}
