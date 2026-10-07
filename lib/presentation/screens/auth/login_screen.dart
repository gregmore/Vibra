import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final size = MediaQuery.sizeOf(context);
    final t = context.vibraTokens;

    // Se l'utente si è autenticato con successo tramite OAuth, il router si accorge
    // del cambio di sessione di Supabase e lo reindirizza in automatico, ma
    // gestiamo un pop ed eventuale re-routing manuale sul successo per sicurezza.
    ref.listen(generalAuthProvider, (previous, next) {
      if (next.status == GeneralAuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == GeneralAuthStatus.error) {
        final isSuccessInfo =
            next.errorMessage?.contains('Registrazione completata') ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? l10n.authFailed),
            backgroundColor: isSuccessInfo ? t.success : t.error,
            duration: Duration(seconds: isSuccessInfo ? 6 : 4),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Sfondo gradiente ──────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [t.backgroundPrimary, t.backgroundSecondary],
              ),
            ),
            child: SizedBox.expand(),
          ),

          // ── Orbs decorativi ──────────────────────────────────
          _BackgroundOrbs(size: size),

          // ── Contenuto ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(VibraSpacing.pagePadding),
              child: Column(
                children: [
                  // ── Back button ──────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Torna alla schermata di benvenuto',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/welcome');
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const Spacer(flex: 2),

                  // ── Hero Logo ────────────────────────────────
                  _HeroLogo()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 28),

                  // ── Titolo con gradient shimmer ──────────────
                  ShaderMask(
                        shaderCallback: (bounds) =>
                            t.primaryGradient.createShader(bounds),
                        child: Text(
                          l10n.loginTitle,
                          textAlign: TextAlign.center,
                          style: VibraTextStyles.displayLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 200.ms,
                        duration: 500.ms,
                      ),

                  const SizedBox(height: VibraSpacing.sm),

                  // ── Sottotitolo ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: VibraTextStyles.bodyMedium.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                  const Spacer(flex: 2),

                  // ── Auth Buttons ─────────────────────────────
                  _AuthButtonGoogle(
                        label: l10n.loginWithGoogle,
                        onTap: () => ref
                            .read(generalAuthProvider.notifier)
                            .signInWithGoogle(),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 500.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: VibraSpacing.md),

                  // Apple Sign In — solo su iOS
                  if (Platform.isIOS) ...[
                    _AuthButtonApple(
                          label: l10n.loginWithApple,
                          onTap: () => ref
                              .read(generalAuthProvider.notifier)
                              .signInWithApple(),
                        )
                        .animate()
                        .fadeIn(delay: 620.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          delay: 620.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: VibraSpacing.md),
                  ],

                  // ── Divider "oppure" ─────────────────────────
                  _OrDivider().animate().fadeIn(
                    delay: 740.ms,
                    duration: 400.ms,
                  ),

                  const SizedBox(height: VibraSpacing.md),

                  // ── Email ────────────────────────────────────
                  _AuthButtonEmail(
                        label: l10n.loginWithEmail,
                        onTap: () => EmailAuthSheet.show(context),
                      )
                      .animate()
                      .fadeIn(delay: 860.ms, duration: 400.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 860.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const Spacer(),

                  // ── Consent ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: t.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.loginConsent,
                          textAlign: TextAlign.center,
                          style: VibraTextStyles.bodySmall.copyWith(
                            color: t.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),

                  const SizedBox(height: VibraSpacing.sm),
                ],
              ),
            ),
          ),

          // ── Loading overlay ──────────────────────────────────
          if (isLoading)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: t.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            VibraSpacing.radiusMedium,
                          ),
                          boxShadow: [t.elevatedShadow],
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            t.accentPrimary,
                          ),
                        ),
                      ),
                    ),
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
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                t.accentPrimary.withValues(alpha: 0.15),
                t.accentSecondary.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.surfaceElevated,
                border: Border.all(color: t.borderDefault),
                boxShadow: [t.elevatedShadow],
              ),
              child: const Center(
                child: VibraLogo(width: 58, height: 58, strokeWidth: 4.5),
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.03, 1.03),
          duration: 2500.ms,
          curve: Curves.easeInOut,
        );
  }
}

// ── Orbs decorativi di sfondo ────────────────────────────────────
class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.06,
          right: -50,
          child: _GlowOrb(
            size: 200,
            color: t.accentPrimary.withValues(alpha: 0.1),
          ),
        ),
        Positioned(
          bottom: size.height * 0.22,
          left: -70,
          child: _GlowOrb(
            size: 240,
            color: t.accentPrimary.withValues(alpha: 0.07),
          ),
        ),
        Positioned(
          top: size.height * 0.35,
          left: size.width * 0.6,
          child: _GlowOrb(
            size: 100,
            color: t.accentSecondary.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ── Divider "oppure" ─────────────────────────────────────────────
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
            'oppure',
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
      height: 56,
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
            Text(
              label,
              style: VibraTextStyles.labelLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
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
      height: 56,
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
            Text(
              label,
              style: VibraTextStyles.labelLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
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
      height: 56,
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
            Text(
              label,
              style: VibraTextStyles.labelLarge.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w600,
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
