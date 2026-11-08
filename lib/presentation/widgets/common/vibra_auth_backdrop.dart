import 'package:flutter/material.dart';

import '../../../core/theme/vibra_theme_tokens.dart';

/// Static backdrop for brand moments (welcome, auth): the canvas with one
/// faint violet halo high on the page. No blur, no animation — a single
/// gradient that costs one draw call.
class VibraAuthBackdrop extends StatelessWidget {
  const VibraAuthBackdrop({
    super.key,
    this.alignment = const Alignment(0, -.62),
  });

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.backgroundPrimary,
          gradient: RadialGradient(
            center: alignment,
            radius: .9,
            colors: [
              t.accentPrimary.withValues(alpha: isDark ? .16 : .08),
              t.accentSecondary.withValues(alpha: isDark ? .05 : .03),
              t.backgroundPrimary.withValues(alpha: 0),
            ],
            stops: const [0, .45, 1],
          ),
        ),
      ),
    );
  }
}
