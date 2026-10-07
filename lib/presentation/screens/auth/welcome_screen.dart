import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/vibra_pill_button.dart';
import '../../widgets/common/vibra_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _page = 0;

  late final AnimationController _orbController;

  List<({IconData icon, String title, String body, Color glowColor})>
  _getSlides(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    return [
      (
        icon: Icons.library_music_rounded,
        title: l10n.onboardingConnectTitle,
        body: l10n.onboardingConnectBody,
        glowColor: t.accentPrimary,
      ),
      (
        icon: Icons.place_rounded,
        title: l10n.onboardingDiscoverTitle,
        body: l10n.onboardingDiscoverBody,
        glowColor: t.accentSecondary,
      ),
      (
        icon: Icons.people_alt_rounded,
        title: l10n.onboardingCommunityTitle,
        body: l10n.onboardingCommunityBody,
        glowColor: t.success,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final slides = _getSlides(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Sfondo gradiente ──────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t.backgroundPrimary, t.backgroundSecondary],
              ),
            ),
            child: SizedBox.expand(),
          ),

          // ── Orbs decorativi ──────────────────────────────────
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, _) => Stack(
              children: [
                Positioned(
                  top: size.height * 0.08 + (_orbController.value * 20),
                  right: -40 + (_orbController.value * 15),
                  child: _GlowOrb(
                    size: 180,
                    color: t.accentPrimary.withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.18 - (_orbController.value * 25),
                  left: -60 + (_orbController.value * 10),
                  child: _GlowOrb(
                    size: 220,
                    color: t.accentSecondary.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  top: size.height * 0.45,
                  right: -30 - (_orbController.value * 12),
                  child: _GlowOrb(
                    size: 120,
                    color: t.success.withValues(alpha: 0.06),
                  ),
                ),
              ],
            ),
          ),

          // ── Contenuto principale ─────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // ── Header ─────────────────────────────────────
                  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const VibraLogo(
                                width: 28,
                                height: 28,
                                strokeWidth: 3,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppConstants.appName,
                                style: VibraTextStyles.headlineMedium.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            child: Text(
                              l10n.onboardingGoToLogin,
                              style: VibraTextStyles.labelMedium.copyWith(
                                color: t.accentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.3, end: 0, duration: 500.ms),

                  const SizedBox(height: 18),

                  // ── Slides ─────────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemCount: slides.length,
                      itemBuilder: (context, index) {
                        final item = slides[index];
                        return _OnboardingSlide(
                          icon: item.icon,
                          title: item.title,
                          body: item.body,
                          glowColor: item.glowColor,
                        );
                      },
                    ),
                  ),

                  // ── Dots indicator ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: _page == index ? t.primaryGradient : null,
                          color: _page == index ? null : t.borderStrong,
                          borderRadius: BorderRadius.circular(
                            VibraSpacing.radiusFull,
                          ),
                          border: Border.all(
                            color: _page == index
                                ? t.accentPrimary
                                : t.borderDefault,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // ── CTA Button ─────────────────────────────────
                  SizedBox(
                        width: double.infinity,
                        child: VibraPillButton(
                          onPressed: () => context.push('/login'),
                          text: _page == slides.length - 1
                              ? l10n.onboardingContinue
                              : l10n.onboardingGoToLogin,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 700.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide del singolo onboarding ─────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    required this.glowColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icona con cerchio gradient glow
        Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.surfaceElevated,
                border: Border.all(color: glowColor, width: 2),
                boxShadow: [t.elevatedShadow],
              ),
              child: Icon(icon, size: 56, color: glowColor),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 36),

        // Card con glassmorphism migliorato
        Container(
          padding: const EdgeInsets.all(VibraSpacing.xl),
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: VibraSpacing.borderMedium,
            border: Border.all(color: t.borderDefault),
            boxShadow: [t.cardShadow],
          ),
          child: Column(
            children: [
              Text(
                    title,
                    textAlign: TextAlign.center,
                    style: VibraTextStyles.displaySmall,
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 12),
              Text(
                    body,
                    textAlign: TextAlign.center,
                    style: VibraTextStyles.bodyLarge.copyWith(
                      color: t.textSecondary,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0, delay: 350.ms, duration: 400.ms),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Cerchio sfumato decorativo ────────────────────────────────────
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
