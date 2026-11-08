import 'package:vibra/presentation/localization/user_facing_error.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_auth_backdrop.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_logo.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/email_auth_sheet.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(generalAuthProvider);
    final isLoading = authState.status == GeneralAuthStatus.loading;
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;

    // Se l'utente si è autenticato con successo tramite OAuth, il router si accorge
    // del cambio di sessione di Supabase e lo reindirizza in automatico, ma
    // gestiamo un pop ed eventuale re-routing manuale sul successo per sicurezza.
    ref.listen(generalAuthProvider, (previous, next) {
      if (next.status == GeneralAuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == GeneralAuthStatus.error) {
        final isSuccessInfo = isRegistrationConfirmation(next.errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFacingError(l10n, next.errorMessage)),
            backgroundColor: isSuccessInfo ? t.success : t.error,
            duration: Duration(seconds: isSuccessInfo ? 6 : 4),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: VibraAuthBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: VibraSpacing.pagePadding,
                  vertical: VibraSpacing.sm,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - VibraSpacing.lg).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: l10n.loginBackToWelcome,
                              onPressed: () => context.canPop()
                                  ? context.pop()
                                  : context.go('/welcome'),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: t.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: VibraSpacing.xxl),
                          const Center(
                            child: VibraLogo(
                              width: 88,
                              height: 76,
                              animate: true,
                            ),
                          ),
                          const SizedBox(height: VibraSpacing.xxxl),
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.loginTitle,
                              textAlign: TextAlign.center,
                              style: VibraTextStyles.displaySmall.copyWith(
                                color: t.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: VibraSpacing.md),
                          Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: VibraTextStyles.bodyMedium.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                          const SizedBox(height: VibraSpacing.huge),
                          _ProviderButton(
                            label: l10n.loginWithGoogle,
                            leading: SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(painter: _GoogleLogoPainter()),
                            ),
                            onTap: () => ref
                                .read(generalAuthProvider.notifier)
                                .signInWithGoogle(),
                          ),
                          if (Platform.isIOS) ...[
                            const SizedBox(height: VibraSpacing.md),
                            _ProviderButton(
                              label: l10n.loginWithApple,
                              leading: const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 22,
                              ),
                              onTap: () => ref
                                  .read(generalAuthProvider.notifier)
                                  .signInWithApple(),
                            ),
                          ],
                          const SizedBox(height: VibraSpacing.lg),
                          _OrDivider(),
                          const SizedBox(height: VibraSpacing.lg),
                          VibraButton(
                            label: l10n.loginWithEmail,
                            onPressed: () => EmailAuthSheet.show(context),
                            tone: VibraButtonTone.outline,
                            leadingIcon: Icons.alternate_email_rounded,
                            expanded: true,
                          ),
                          const SizedBox(height: VibraSpacing.xxxl),
                          Text(
                            l10n.loginConsent,
                            textAlign: TextAlign.center,
                            style: VibraTextStyles.caption.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                          const SizedBox(height: VibraSpacing.xs),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: VibraSpacing.xs,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    context.push('/terms-of-service'),
                                child: Text(l10n.legalTermsTitle),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push('/privacy-policy'),
                                child: Text(l10n.legalPrivacyPolicyTitle),
                              ),
                            ],
                          ),
                          const SizedBox(height: VibraSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: t.backgroundPrimary.withValues(alpha: .88),
                  child: const Center(child: VibraLoadingIndicator(size: 56)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Divider "or" ──────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Row(
      children: [
        Expanded(child: Divider(color: t.borderDefault)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VibraSpacing.lg),
          child: Text(
            AppLocalizations.of(context)!.authOr.toUpperCase(),
            style: VibraTextStyles.labelSmall.copyWith(color: t.textMuted),
          ),
        ),
        Expanded(child: Divider(color: t.borderDefault)),
      ],
    );
  }
}

/// Identity-provider button: white surface with the provider's own mark,
/// as both Google and Apple guidelines require on dark backgrounds.
class _ProviderButton extends StatefulWidget {
  const _ProviderButton({
    required this.label,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final Widget leading;
  final VoidCallback onTap;

  @override
  State<_ProviderButton> createState() => _ProviderButtonState();
}

class _ProviderButtonState extends State<_ProviderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radius = BorderRadius.circular(VibraSpacing.radiusMedium);
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? VibraMotion.pressedScale : 1,
        duration: VibraMotion.durationFor(
          context,
          _pressed ? VibraMotion.tapIn : VibraMotion.tapOut,
        ),
        curve: VibraMotion.signalCurve,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(VibraSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: isLight
                    ? BorderSide(color: t.borderStrong)
                    : BorderSide.none,
              ),
              overlayColor: Colors.black.withValues(alpha: .06),
              elevation: 0,
            ),
            onPressed: widget.onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.leading,
                const SizedBox(width: VibraSpacing.md),
                Flexible(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: VibraTextStyles.labelLarge.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
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

// ── Google "G" logo painter (colori ufficiali) ───────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Usa un approccio semplificato con archi per la "G" colorata
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    const strokeWidth = 3.5;

    // Arco blu (in alto a destra)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -0.8, // start angle
      1.3, // sweep
      false,
      bluePaint,
    );

    // Arco verde (in basso a destra)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      0.5,
      1.2,
      false,
      greenPaint,
    );

    // Arco giallo (in basso a sinistra)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      1.7,
      1.0,
      false,
      yellowPaint,
    );

    // Arco rosso (in alto a sinistra)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      2.7,
      1.0,
      false,
      redPaint,
    );

    // Linea orizzontale della "G"
    canvas.drawLine(
      Offset(w * 0.5, h * 0.5),
      Offset(w * 0.95, h * 0.5),
      bluePaint..strokeWidth = strokeWidth - 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
