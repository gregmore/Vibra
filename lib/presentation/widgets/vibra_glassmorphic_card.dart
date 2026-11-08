import 'package:flutter/material.dart';

import '../../core/theme/vibra_spacing.dart';
import '../../core/theme/vibra_theme_tokens.dart';
import 'common/vibra_image.dart';
import 'common/vibra_surface.dart';

/// Legacy card API. Despite the name there is no blur: VIBRA avoids
/// expensive backdrop filters and renders an opaque [VibraSurface].
class VibraGlassmorphicCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget inner = child;
    if (gradient != null) {
      inner = DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: child,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: VibraSurface(
        onTap: onTap,
        margin: margin,
        padding: padding,
        borderColor: borderColor,
        radius: borderRadius ?? VibraSpacing.radiusLarge,
        child: inner,
      ),
    );
  }
}

/// Media card: full-bleed image with a bottom gradient carrying the copy.
class VibraGlassmorphicImageCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      height: height,
      margin:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: VibraSpacing.lg,
            vertical: VibraSpacing.sm,
          ),
      child: VibraSurface(
        onTap: onTap,
        padding: EdgeInsets.zero,
        clip: true,
        radius: borderRadius ?? VibraSpacing.radiusLarge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VibraNetworkImage(url: imageUrl, cacheWidth: 720),
            VibraImageScrim(color: t.imageOverlay),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(VibraSpacing.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
