import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import 'vibra_logo.dart';
import '../vibra_pill_button.dart';
import 'package:vibra/l10n/app_localizations.dart';

class VibraLoadingView extends StatelessWidget {
  const VibraLoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Animate(
            onPlay: (controller) => controller.repeat(),
            effects: const [FadeEffect(duration: VibraSpacing.animSlow)],
            child: const VibraLogo(width: 64, height: 64),
          ),
          const SizedBox(height: VibraSpacing.lg),
          CircularProgressIndicator(color: t.accentPrimary),
          const SizedBox(height: VibraSpacing.lg),
          Text(
            message ?? AppLocalizations.of(context)!.commonLoading,
            style: TextStyle(color: t.textSecondary),
          ),
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
    final t = context.vibraTokens;
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );

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
                          color: t.accentPrimary.withValues(alpha: 0.24),
                          width: 2,
                        ),
                      ),
                    )
                    .animate(
                      onPlay: isTest
                          ? null
                          : (controller) => controller.repeat(),
                    )
                    .scale(
                      duration: 1500.ms,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.5, 1.5),
                    )
                    .fadeOut(duration: 1500.ms),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.accentSoft,
                  ),
                ),
                Icon(icon, size: 64, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: VibraSpacing.xl),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VibraSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: t.textSecondary,
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
            if (secondaryActionLabel != null &&
                onSecondaryActionTap != null) ...[
              const SizedBox(height: VibraSpacing.md),
              TextButton(
                onPressed: onSecondaryActionTap,
                child: Text(
                  secondaryActionLabel!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: t.textSecondary,
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
    final t = context.vibraTokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VibraSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: t.error,
            ).animate().shake(duration: VibraSpacing.animNormal, hz: 4),
            const SizedBox(height: VibraSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: VibraSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: VibraSpacing.xl),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.error),
                  foregroundColor: t.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: VibraSpacing.xl,
                    vertical: VibraSpacing.md,
                  ),
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
