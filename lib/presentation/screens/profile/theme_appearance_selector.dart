import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../providers/app_state_providers.dart';

/// Settings → Appearance, with an explicit accessible state for every mode.
class AppearanceSelector extends StatelessWidget {
  const AppearanceSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final VibraThemePreference value;
  final ValueChanged<VibraThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.xs,
            0,
            VibraSpacing.xs,
            VibraSpacing.sm + 2,
          ),
          child: Semantics(
            header: true,
            child: Text(
              l10n.appearanceTitle.toUpperCase(),
              style: VibraTextStyles.labelSmall.copyWith(
                color: t.textSecondary,
              ),
            ),
          ),
        ),
        Row(
          children: [
            for (final (preference, label) in [
              (VibraThemePreference.dark, l10n.appearanceDark),
              (VibraThemePreference.light, l10n.appearanceLight),
              (VibraThemePreference.system, l10n.appearanceAuto),
            ]) ...[
              if (preference != VibraThemePreference.dark)
                const SizedBox(width: VibraSpacing.sm),
              Expanded(
                child: _ThemeCard(
                  preference: preference,
                  label: label,
                  selected: value == preference,
                  onTap: () => onChanged(preference),
                ),
              ),
            ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            VibraSpacing.xs,
            VibraSpacing.sm,
            VibraSpacing.xs,
            0,
          ),
          child: Text(
            l10n.appearanceBody,
            style: VibraTextStyles.caption.copyWith(color: t.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Theme choice with a miniature preview of the canvas, a card and the
/// accent, so the options are recognisable at a glance.
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.preference,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final VibraThemePreference preference;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    const dark = VibraThemeTokens.dark, light = VibraThemeTokens.light;
    Widget preview(VibraThemeTokens p) => ColoredBox(
      color: p.backgroundPrimary,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 5,
              decoration: BoxDecoration(
                color: p.textPrimary,
                borderRadius: VibraSpacing.borderFull,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: p.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: p.borderDefault),
                ),
                padding: const EdgeInsets.all(6),
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 22,
                  height: 6,
                  decoration: BoxDecoration(
                    color: p.accentFill,
                    borderRadius: VibraSpacing.borderFull,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final art = switch (preference) {
      VibraThemePreference.dark => preview(dark),
      VibraThemePreference.light => preview(light),
      VibraThemePreference.system => Row(
        children: [
          Expanded(child: ClipRect(child: preview(dark))),
          Expanded(child: ClipRect(child: preview(light))),
        ],
      ),
    };
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: selected
          ? AppLocalizations.of(context)!.commonSelectedLabel(label)
          : AppLocalizations.of(context)!.commonNotSelectedLabel(label),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: VibraMotion.durationFor(context, VibraMotion.fast),
          padding: const EdgeInsets.all(VibraSpacing.sm),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: VibraSpacing.borderLarge,
            border: Border.all(
              color: selected ? t.accentPrimary : t.borderDefault,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 72,
                child: ClipRRect(
                  borderRadius: VibraSpacing.borderSmall,
                  child: art,
                ),
              ),
              const SizedBox(height: VibraSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: VibraSpacing.iconSm,
                    color: selected ? t.accentPrimary : t.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: VibraTextStyles.labelMedium.copyWith(
                        color: selected ? t.textPrimary : t.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
