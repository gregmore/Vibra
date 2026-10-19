import 'package:vibra/presentation/localization/user_facing_error.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_logo.dart';
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
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(VibraSpacing.pagePadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        (constraints.maxHeight - VibraSpacing.pagePadding * 2)
                            .clamp(0, double.infinity),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 480,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          const SizedBox(height: 20),
                          _HeroLogo(),
                          const SizedBox(height: 24),
                          Text(
                            l10n.loginTitle,
                            textAlign: TextAlign.center,
                            style: VibraTextStyles.displayMedium.copyWith(
                              color: t.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: VibraTextStyles.bodyMedium.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _AuthButtonGoogle(
                            label: l10n.loginWithGoogle,
                            onTap: () => ref
                                .read(generalAuthProvider.notifier)
                                .signInWithGoogle(),
                          ),
                          if (Platform.isIOS) ...[
                            const SizedBox(height: 12),
                            _AuthButtonApple(
                              label: l10n.loginWithApple,
                              onTap: () => ref
                                  .read(generalAuthProvider.notifier)
                                  .signInWithApple(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _OrDivider(),
                          const SizedBox(height: 12),
                          _AuthButtonEmail(
                            label: l10n.loginWithEmail,
                            onTap: () => EmailAuthSheet.show(context),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            l10n.loginConsent,
                            textAlign: TextAlign.center,
                            style: VibraTextStyles.bodySmall.copyWith(
                              color: t.textSecondary,
                            ),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
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
                          const SizedBox(height: 12),
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
                  color: t.backgroundPrimary.withValues(alpha: .85),
                  child: Center(
                    child: CircularProgressIndicator(color: t.accentPrimary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Hero Logo con glow pulsante ──────────────────────────────────
class _HeroLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: t.borderDefault),
      ),
      child: const Center(
        child: VibraLogo(width: 74, height: 74, strokeWidth: 5),
      ),
    );
  }
}

// ── Divider AppLocalizations.of(context)!.authOr ─────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, t.borderStrong],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.authOr,
            style: VibraTextStyles.labelSmall.copyWith(color: t.textSecondary),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t.borderStrong, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Auth Button: Google ──────────────────────────────────────────
class _AuthButtonGoogle extends StatelessWidget {
  const _AuthButtonGoogle({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icona Google con i colori brand
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: VibraTextStyles.labelLarge.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auth Button: Apple ───────────────────────────────────────────
class _AuthButtonApple extends StatelessWidget {
  const _AuthButtonApple({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, color: Colors.black87, size: 24),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: VibraTextStyles.labelLarge.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auth Button: Email ───────────────────────────────────────────
class _AuthButtonEmail extends StatelessWidget {
  const _AuthButtonEmail({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.alternate_email_rounded,
              color: t.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: VibraTextStyles.labelLarge.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
