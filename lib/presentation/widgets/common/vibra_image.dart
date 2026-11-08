import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import 'vibra_logo.dart';

/// Cached network image with a calm placeholder and a branded fallback.
///
/// Images are decoded at [cacheWidth] (logical px × device ratio) so long
/// lists never keep full-resolution posters in memory.
class VibraNetworkImage extends StatelessWidget {
  const VibraNetworkImage({
    required this.url,
    super.key,
    this.cacheWidth = 600,
    this.fit = BoxFit.cover,
    this.fallbackIcon,
  });

  final String? url;

  /// Target decode width in logical pixels.
  final int cacheWidth;
  final BoxFit fit;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final value = url?.trim() ?? '';
    final valid = value.startsWith('http://') || value.startsWith('https://');
    if (!valid) return VibraImageFallback(icon: fallbackIcon);
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    final t = context.vibraTokens;
    return CachedNetworkImage(
      imageUrl: value,
      fit: fit,
      memCacheWidth: (cacheWidth * dpr).round(),
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (_, _) => ColoredBox(color: t.surfaceMuted),
      errorWidget: (_, _, _) => VibraImageFallback(icon: fallbackIcon),
    );
  }
}

/// Branded empty artwork: the VIBRA mark, quiet, on an ink field.
class VibraImageFallback extends StatelessWidget {
  const VibraImageFallback({super.key, this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.surfaceElevated, t.surface],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide.isFinite
              ? constraints.biggest.shortestSide
              : 64.0;
          return Center(
            child: icon != null
                ? Icon(icon, size: side * .32, color: t.textMuted)
                : VibraLogo(
                    width: side * .36,
                    height: side * .36,
                    color: t.textPrimary.withValues(alpha: .14),
                  ),
          );
        },
      ),
    );
  }
}

/// Bottom-weighted scrim for copy over photography. Reaches [color] at the
/// bottom edge so white text there stays above 4.5:1 on any image.
class VibraImageScrim extends StatelessWidget {
  const VibraImageScrim({super.key, required this.color, this.start = .35});

  final Color color;

  /// Fraction of the height where the gradient begins.
  final double start;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [start, (start + 1) / 2, 1],
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: color.a * .72),
            color,
          ],
        ),
      ),
    ),
  );
}
