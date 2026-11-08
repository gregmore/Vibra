import 'package:flutter/material.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/errors/offline.dart';
import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import 'vibra_button.dart';
import 'vibra_logo.dart';

/// Branded progress: the VIBRA mark inside a thin violet orbit.
///
/// Contains exactly one [CircularProgressIndicator] so platform semantics
/// ("in progress") and existing tests keep working.
class VibraLoadingIndicator extends StatelessWidget {
  const VibraLoadingIndicator({
    super.key,
    this.size = 48,
    this.showMark = true,
  });

  final double size;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              strokeWidth: size >= 40 ? 2 : 1.6,
              strokeCap: StrokeCap.round,
              color: t.accentPrimary,
              backgroundColor: t.surfaceMuted,
            ),
          ),
          if (showMark)
            VibraLogo(
              width: size * .42,
              height: size * .42,
              color: t.textPrimary,
            ),
        ],
      ),
    );
  }
}

/// Full-area loading state with an optional caption.
class VibraLoadingView extends StatelessWidget {
  const VibraLoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: message ?? AppLocalizations.of(context)!.commonLoading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VibraLoadingIndicator(),
            const SizedBox(height: VibraSpacing.lg),
            Text(
              message ?? AppLocalizations.of(context)!.commonLoading,
              style: VibraTextStyles.bodySmall.copyWith(color: t.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Intentional empty state: icon tile, headline, guidance and up to two
/// actions. Enters once with a short fade/rise; never loops.
class VibraEmptyView extends StatelessWidget {
  const VibraEmptyView({
    required this.title,
    required this.message,
    this.icon = Icons.music_note_rounded,
    this.actionLabel,
    this.onActionTap,
    this.secondaryActionLabel,
    this.onSecondaryActionTap,
    this.compact = false,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionTap;

  /// Tighter variant for inline sections (no outer centring padding).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      compact: compact,
      icon: _StateIcon(icon: icon),
      title: title,
      message: message,
      actions: [
        if (actionLabel != null && onActionTap != null)
          VibraButton(
            label: actionLabel!,
            onPressed: onActionTap,
            tone: VibraButtonTone.signal,
          ),
        if (secondaryActionLabel != null && onSecondaryActionTap != null)
          VibraButton(
            label: secondaryActionLabel!,
            onPressed: onSecondaryActionTap,
            tone: VibraButtonTone.text,
            size: VibraButtonSize.compact,
          ),
      ],
    );
  }
}

enum VibraErrorKind { generic, network, spotify }

/// Error state with a clear cause and a recovery action.
class VibraErrorView extends StatelessWidget {
  const VibraErrorView({
    required this.title,
    required this.message,
    this.onRetry,
    this.kind = VibraErrorKind.generic,
    this.retryLabel,
    this.compact = false,
    this.error,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VibraErrorKind kind;
  final String? retryLabel;
  final bool compact;

  /// The failure being shown. When it means the device is offline
  /// (`isOfflineError`), the offline state replaces [title] and [message].
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final offline = isOfflineError(error);
    final shown = offline ? VibraErrorKind.network : kind;
    final icon = switch (shown) {
      VibraErrorKind.network => Icons.wifi_off_rounded,
      VibraErrorKind.spotify => Icons.sync_problem_rounded,
      VibraErrorKind.generic => Icons.error_outline_rounded,
    };
    return _StateLayout(
      compact: compact,
      icon: _StateIcon(icon: icon, color: offline ? t.textSecondary : t.error),
      title: offline ? l10n.offlineTitle : title,
      message: offline ? l10n.errorNetwork : message,
      actions: [
        if (onRetry != null)
          VibraButton(
            label: retryLabel ?? l10n.commonRetry,
            onPressed: onRetry,
            tone: VibraButtonTone.outline,
            leadingIcon: Icons.refresh_rounded,
          ),
      ],
    );
  }
}

/// Spec names for the component library.
typedef VibraEmptyState = VibraEmptyView;
typedef VibraErrorState = VibraErrorView;

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final tint = color ?? t.accentPrimary;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: VibraSpacing.borderXL,
        border: Border.all(color: t.borderDefault),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: .14),
            ),
          ),
          Icon(icon, size: 26, color: tint),
        ],
      ),
    );
  }
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
    required this.compact,
  });

  final Widget icon;
  final String title;
  final String message;
  final List<Widget> actions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: VibraSpacing.xl),
        Text(
          title,
          style: VibraTextStyles.headlineSmall.copyWith(color: t.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: VibraSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: VibraTextStyles.bodyMedium.copyWith(color: t.textSecondary),
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: VibraSpacing.xxl),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: VibraSpacing.xs),
            actions[i],
          ],
        ],
      ],
    );
    final entrance = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: VibraMotion.durationFor(context, VibraMotion.reveal),
      curve: VibraMotion.enter,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: body,
    );
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: VibraSpacing.xxl),
        child: Center(child: entrance),
      );
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VibraSpacing.xxl),
        child: entrance,
      ),
    );
  }
}
