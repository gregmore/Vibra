import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.appearanceTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.appearanceBody,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
            border: Border.all(color: t.borderDefault),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [t.cardShadow]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                _ThemeOption(
                  preference: VibraThemePreference.dark,
                  icon: Icons.dark_mode_outlined,
                  label: AppLocalizations.of(context)!.appearanceDark,
                  subtitle: AppLocalizations.of(context)!.appearanceDarkBody,
                  value: value,
                  onChanged: onChanged,
                ),
                Divider(height: 1, color: t.borderDefault),
                _ThemeOption(
                  preference: VibraThemePreference.light,
                  icon: Icons.light_mode_outlined,
                  label: AppLocalizations.of(context)!.appearanceLight,
                  subtitle: AppLocalizations.of(context)!.appearanceLightBody,
                  value: value,
                  onChanged: onChanged,
                ),
                Divider(height: 1, color: t.borderDefault),
                _ThemeOption(
                  preference: VibraThemePreference.system,
                  icon: Icons.brightness_auto_outlined,
                  label: AppLocalizations.of(context)!.appearanceSystem,
                  subtitle: AppLocalizations.of(context)!.appearanceSystemBody,
                  value: value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.preference,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final VibraThemePreference preference;
  final IconData icon;
  final String label, subtitle;
  final VibraThemePreference value;
  final ValueChanged<VibraThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final selected = value == preference;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: label,
      child: ListTile(
        onTap: () => onChanged(preference),
        leading: Icon(
          icon,
          color: selected ? t.accentPrimary : t.textSecondary,
        ),
        title: Text(label, style: VibraTextStyles.bodyMedium),
        subtitle: Text(
          subtitle,
          style: VibraTextStyles.bodySmall.copyWith(color: t.textSecondary),
        ),
        trailing: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off_rounded,
          color: selected ? t.accentPrimary : t.textSecondary,
          semanticLabel: selected
              ? AppLocalizations.of(context)!.commonSelectedLabel(label)
              : AppLocalizations.of(context)!.commonNotSelectedLabel(label),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
