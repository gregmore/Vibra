import 'package:flutter/material.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import 'vibra_surface.dart';

enum VibraSettingsTone { normal, danger }

/// A titled group of rows on one surface, separated by inset hairlines.
/// Used by Settings and the Profile overview so both read as one system.
class VibraSettingsSection extends StatelessWidget {
  const VibraSettingsSection({
    required this.children,
    super.key,
    this.label,
    this.footer,
  });

  final String? label;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, indent: 68, color: t.borderDefault));
      }
      rows.add(children[i]);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: VibraSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
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
                  label!.toUpperCase(),
                  style: VibraTextStyles.labelSmall.copyWith(
                    color: t.textSecondary,
                  ),
                ),
              ),
            ),
          VibraSurface(
            padding: EdgeInsets.zero,
            clip: true,
            child: Column(children: rows),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.xs,
                VibraSpacing.sm,
                VibraSpacing.xs,
                0,
              ),
              child: Text(
                footer!,
                style: VibraTextStyles.caption.copyWith(color: t.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icon tile used at the start of every settings row.
class VibraSettingsIcon extends StatelessWidget {
  const VibraSettingsIcon({
    required this.icon,
    super.key,
    this.color,
    this.background,
  });

  final IconData icon;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final tint = color ?? t.accentPrimary;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background ?? t.surfaceMuted,
        borderRadius: VibraSpacing.borderSmall,
      ),
      child: Icon(icon, size: VibraSpacing.iconMd, color: tint),
    );
  }
}

/// Navigation / action row: icon, title, optional subtitle and trailing.
class VibraSettingsTile extends StatelessWidget {
  const VibraSettingsTile({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.tone = VibraSettingsTone.normal,
    this.iconColor,
    this.iconBackground,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VibraSettingsTone tone;
  final Color? iconColor;
  final Color? iconBackground;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final danger = tone == VibraSettingsTone.danger;
    return Semantics(
      button: onTap != null,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: trailing == null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VibraSpacing.lg,
              vertical: VibraSpacing.md,
            ),
            child: Row(
              children: [
                VibraSettingsIcon(
                  icon: icon,
                  color: iconColor ?? (danger ? t.error : null),
                  background:
                      iconBackground ??
                      (danger ? t.error.withValues(alpha: .12) : null),
                ),
                const SizedBox(width: VibraSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: VibraTextStyles.titleSmall.copyWith(
                          color: danger ? t.error : t.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: VibraTextStyles.caption.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: VibraSpacing.md),
                  trailing!,
                ] else if (showChevron && onTap != null) ...[
                  const SizedBox(width: VibraSpacing.sm),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: VibraSpacing.iconMd,
                    color: t.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle row. The whole row toggles; the switch uses the theme's single
/// switch style so every toggle in the app looks the same.
class VibraSettingsSwitch extends StatelessWidget {
  const VibraSettingsSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
    this.icon,
    this.subtitle,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.lg,
              VibraSpacing.sm,
              VibraSpacing.md,
              VibraSpacing.sm,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  VibraSettingsIcon(icon: icon!),
                  const SizedBox(width: VibraSpacing.lg),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: VibraTextStyles.titleSmall.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: VibraTextStyles.caption.copyWith(
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: VibraSpacing.sm),
                AnimatedSwitcher(
                  duration: VibraMotion.durationFor(context, VibraMotion.fast),
                  child: Switch(
                    key: ValueKey(value),
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme-styled confirmation dialog. Returns true when confirmed.
Future<bool> confirmVibraAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final t = context.vibraTokens;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: t.textPrimary),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? t.error : t.accentPrimary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}
