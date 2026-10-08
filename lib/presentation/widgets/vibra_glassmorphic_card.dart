import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/vibra_motion.dart';
import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import '../../core/constants/app_constants.dart';

/// Card con effetto glassmorphism — vetro smerigliato su sfondo scuro.
/// Utilizzata per card eventi, profili utente e pannelli informativi.
class VibraGlassmorphicCard extends StatefulWidget {
  final Widget child;
  final double? blur;
  final double? opacity;
  final double? borderRadius;
  final Color? borderColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxShadow? glow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const VibraGlassmorphicCard({
    super.key,
    required this.child,
    this.blur,
    this.opacity,
    this.borderRadius,
    this.borderColor,
    this.gradient,
    this.padding,
    this.margin,
    this.glow,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<VibraGlassmorphicCard> createState() => _VibraGlassmorphicCardState();
}

class _VibraGlassmorphicCardState extends State<VibraGlassmorphicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final effectiveRadius =
        widget.borderRadius ?? AppConstants.cardBorderRadius;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: VibraMotion.durationFor(context, VibraSpacing.animFast),
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: Border.all(color: widget.borderColor ?? t.borderDefault),
          boxShadow: [widget.glow ?? t.cardShadow],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Container(
            decoration: BoxDecoration(
              color: t.surfaceElevated,
              gradient: widget.gradient,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (h) => setState(() => _isPressed = h),
                splashColor: t.accentPrimary.withValues(alpha: 0.14),
                hoverColor: t.accentPrimary.withValues(alpha: 0.08),
                focusColor: t.accentPrimary.withValues(alpha: 0.12),
                highlightColor: t.accentPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(effectiveRadius),
                child: Padding(
                  padding:
                      widget.padding ?? const EdgeInsets.all(VibraSpacing.lg),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Variante del glassmorphic card con immagine di sfondo.
/// Ideale per card eventi con poster dell'artista.
class VibraGlassmorphicImageCard extends StatefulWidget {
  final Widget child;
  final String imageUrl;
  final double? height;
  final double? borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const VibraGlassmorphicImageCard({
    super.key,
    required this.child,
    required this.imageUrl,
    this.height,
    this.borderRadius,
    this.onTap,
    this.margin,
  });

  @override
  State<VibraGlassmorphicImageCard> createState() =>
      _VibraGlassmorphicImageCardState();
}

class _VibraGlassmorphicImageCardState
    extends State<VibraGlassmorphicImageCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final effectiveRadius =
        widget.borderRadius ?? AppConstants.cardBorderRadius;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: VibraMotion.durationFor(context, VibraSpacing.animFast),
      child: Container(
        height: widget.height,
        margin:
            widget.margin ??
            const EdgeInsets.symmetric(
              horizontal: VibraSpacing.lg,
              vertical: VibraSpacing.sm,
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Immagine di sfondo
              CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (context, url) {
                  return Container(
                    color: t.surfaceMuted,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorWidget: (context, url, error) => Container(
                  color: t.surfaceMuted,
                  child: Icon(
                    Icons.music_note_rounded,
                    size: 48,
                    color: t.textDisabled,
                  ),
                ),
              ),
              ColoredBox(color: t.imageScrim),
              // Overlay gradiente per leggibilità del testo
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      t.imageOverlay.withValues(alpha: 0.35),
                      t.imageOverlay,
                    ],
                  ),
                ),
              ),
              // Material e InkWell per l'interazione
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onHighlightChanged: (h) => setState(() => _isPressed = h),
                  splashColor: t.accentPrimary.withValues(alpha: 0.1),
                  hoverColor: t.onImage.withValues(alpha: 0.08),
                  focusColor: t.onImage.withValues(alpha: 0.12),
                  highlightColor: t.onImage.withValues(alpha: 0.10),
                  child: const SizedBox.expand(),
                ),
              ),
              // Effetto glassmorphism sul contenuto
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(VibraSpacing.lg),
                    decoration: BoxDecoration(
                      color: t.imageOverlay,
                      border: Border(
                        top: BorderSide(
                          color: t.onImage.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
