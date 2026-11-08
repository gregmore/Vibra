import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_theme_tokens.dart';

/// The original VIBRA mark, rendered from the supplied artwork.
///
/// `assets/branding/logo/vibra_mark.png` is derived pixel-for-pixel from
/// `assets/branding/source/vibra_logo_white_on_black_1024.jpg` by
/// `script/branding/generate_brand_assets_test.dart`: the geometry is never
/// redrawn. The asset is a white alpha mask, so the mark can be tinted to
/// follow the theme (white on dark, ink on light) without changing shape.
class VibraLogo extends StatelessWidget {
  const VibraLogo({
    super.key,
    this.width = 100,
    this.height = 100,
    @Deprecated('The original mark has fixed proportions; ignored.')
    this.strokeWidth = 0,
    this.color,
    this.gradient,
    this.animate = false,
    this.semanticLabel,
  });

  static const String assetPath = 'assets/branding/logo/vibra_mark.png';

  /// Intrinsic aspect ratio (width / height) of the original mark.
  static const double aspectRatio = 614 / 527;

  final double width;
  final double height;
  final double strokeWidth;

  /// Solid tint. Defaults to the theme's primary ink (white in dark mode).
  final Color? color;

  /// Optional gradient fill; takes precedence over [color].
  final Gradient? gradient;

  /// Plays the brand entrance (scale + fade) once when first built.
  final bool animate;

  /// When null the mark is decorative and excluded from semantics.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.vibraTokens.textPrimary;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 3;
    Widget mark = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      color: gradient == null ? tint : Colors.white,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      cacheWidth: (width * dpr).ceil().clamp(1, 614),
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    if (gradient != null) {
      mark = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: gradient!.createShader,
        child: mark,
      );
    }
    if (animate) mark = VibraLogoEntrance(child: mark);
    final sized = SizedBox(width: width, height: height, child: mark);
    if (semanticLabel == null) return ExcludeSemantics(child: sized);
    return Semantics(image: true, label: semanticLabel, child: sized);
  }
}

/// Brand entrance: the mark settles in from 86% scale while fading up.
/// Collapses to the final frame under reduced motion.
class VibraLogoEntrance extends StatelessWidget {
  const VibraLogoEntrance({
    required this.child,
    super.key,
    this.duration = VibraMotion.logo,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final effective = VibraMotion.durationFor(context, duration + delay);
    if (effective == Duration.zero) return child;
    final start = delay.inMilliseconds / effective.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: effective,
      builder: (context, value, child) {
        final t = Interval(
          start,
          1,
          curve: VibraMotion.signalCurve,
        ).transform(value);
        return Opacity(
          opacity: Interval(0, .6).transform(t),
          child: Transform.scale(scale: .86 + .14 * t, child: child),
        );
      },
      child: child,
    );
  }
}

/// Horizontal lockup: mark + "VIBRA" wordmark in Inter ExtraBold.
class VibraWordmark extends StatelessWidget {
  const VibraWordmark({super.key, this.markSize = 28, this.color});

  final double markSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.vibraTokens.textPrimary;
    return Semantics(
      label: AppConstants.appName.toUpperCase(),
      header: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VibraLogo(
            width: markSize * VibraLogo.aspectRatio,
            height: markSize,
            color: tint,
          ),
          SizedBox(width: markSize * .36),
          Text(
            AppConstants.appName.toUpperCase(),
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: markSize * .72,
              letterSpacing: markSize * .12,
              height: 1,
              color: tint,
            ),
          ),
        ],
      ),
    );
  }
}
