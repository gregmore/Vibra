import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import 'vibra_logo.dart';
import '../vibra_pill_button.dart';
import 'package:vibra/l10n/app_localizations.dart';

class VibraLoadingView extends StatelessWidget {
  const VibraLoadingView({
    this.message = 'Caricamento in corso...',
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Animate(
            onPlay: (controller) => controller.repeat(),
            effects: const [
              FadeEffect(duration: VibraSpacing.animSlow),
            ],
            child: const VibraLogo(width: 64, height: 64),
          ),
          const SizedBox(height: VibraSpacing.lg),
          const CircularProgressIndicator(color: VibraColors.accent),
          const SizedBox(height: VibraSpacing.lg),
          Text(message, style: const TextStyle(color: VibraColors.textSecondary)),
        ],
      ),
    );
  }
}

class VibraEmptyView extends StatelessWidget {
  const VibraEmptyView({
    required this.title,
    required this.message,
    this.icon = Icons.music_note_rounded,
    this.actionLabel,
    this.onActionTap,
    this.secondaryActionLabel,
    this.onSecondaryActionTap,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VibraSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VibraColors.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ).animate(onPlay: isTest ? null : (controller) => controller.repeat()).scale(
                      duration: 1500.ms,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.5, 1.5),
                    ).fadeOut(duration: 1500.ms),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VibraColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                Icon(icon, size: 64, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: VibraSpacing.xl),
            Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: VibraSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: VibraSpacing.xxl),
              VibraPillButton(
                text: actionLabel!,
                onPressed: onActionTap!,
                isPrimary: true,
              ),
            ],
            if (secondaryActionLabel != null && onSecondaryActionTap != null) ...[
              const SizedBox(height: VibraSpacing.md),
              TextButton(
                onPressed: onSecondaryActionTap,
                child: Text(
                  secondaryActionLabel!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: VibraColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VibraErrorView extends StatelessWidget {
  const VibraErrorView({
    required this.title,
    required this.message,
    this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VibraSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: VibraColors.error)
                .animate()
                .shake(duration: VibraSpacing.animNormal, hz: 4),
            const SizedBox(height: VibraSpacing.lg),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: VibraSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: VibraSpacing.xl),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: VibraColors.error.withValues(alpha: 0.5)),
                  foregroundColor: VibraColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: VibraSpacing.xl, vertical: VibraSpacing.md),
                ),
                child: Text(AppLocalizations.of(context)!.commonRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
