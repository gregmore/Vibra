import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import 'vibra_badge.dart';

/// One destination of [VibraBottomNavigation].
class VibraNavItem {
  const VibraNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
    this.selectedBuilder,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;

  /// Optional custom selected glyph (e.g. the animated Vibra signal).
  final WidgetBuilder? selectedBuilder;
}

/// VIBRA bottom navigation.
///
/// Anchored to the canvas (no floating glass), a hairline above, muted grey
/// glyphs, and a violet selection that grows a short indicator bar above the
/// active icon. Respects bottom safe areas on iOS and Android.
class VibraBottomNavigation extends StatelessWidget {
  const VibraBottomNavigation({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<VibraNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.backgroundPrimary,
        border: Border(top: BorderSide(color: t.borderDefault, width: .5)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: VibraSpacing.xs),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    index: i,
                    count: items.length,
                    onTap: () {
                      if (i != currentIndex) HapticFeedback.selectionClick();
                      onSelected(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.index,
    required this.count,
  });

  final VibraNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final duration = VibraMotion.durationFor(context, VibraMotion.medium);
    final color = selected ? t.accentPrimary : t.textMuted;
    final glyph = selected && item.selectedBuilder != null
        ? item.selectedBuilder!(context)
        : Icon(
            selected ? item.selectedIcon : item.icon,
            key: ValueKey(selected),
            size: VibraSpacing.iconLg,
            color: color,
          );

    return Semantics(
      selected: selected,
      button: true,
      label: item.badgeCount > 0
          ? '${item.label}, ${item.badgeCount}'
          : item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        highlightShape: BoxShape.circle,
        splashColor: t.accentPrimary.withValues(alpha: .12),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: VibraMotion.signalCurve,
              width: selected ? 18 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: t.accentPrimary,
                borderRadius: VibraSpacing.borderFull,
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: selected ? 1.06 : 1,
                  duration: duration,
                  curve: VibraMotion.signalCurve,
                  child: AnimatedSwitcher(
                    duration: VibraMotion.durationFor(
                      context,
                      VibraMotion.fast,
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: .8, end: 1.0).animate(animation),
                        child: child,
                      ),
                    ),
                    child: SizedBox(
                      key: ValueKey(selected),
                      width: 28,
                      height: 24,
                      child: Center(child: glyph),
                    ),
                  ),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: VibraCountBadge(count: item.badgeCount),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: duration,
              style: VibraTextStyles.labelSmall.copyWith(
                fontSize: 11,
                letterSpacing: .1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? t.textPrimary : t.textMuted,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: MediaQuery.textScalerOf(
                  context,
                ).clamp(maxScaleFactor: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
