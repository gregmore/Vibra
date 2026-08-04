import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../widgets/vibra_glassmorphic_card.dart';
import '../../widgets/vibra_pill_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  List<({IconData icon, String title, String body})> _getSlides(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      (
        icon: Icons.library_music_rounded,
        title: l10n.onboardingConnectTitle,
        body: l10n.onboardingConnectBody,
      ),
      (
        icon: Icons.place_rounded,
        title: l10n.onboardingDiscoverTitle,
        body: l10n.onboardingDiscoverBody,
      ),
      (
        icon: Icons.people_alt_rounded,
        title: l10n.onboardingCommunityTitle,
        body: l10n.onboardingCommunityBody,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: VibraColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: VibraTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text(
                        l10n.onboardingGoToLogin,
                        style: VibraTextStyles.labelMedium.copyWith(
                          color: VibraColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final item = slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: VibraColors.surfaceElevated,
                              border: Border.all(color: VibraColors.glassBorder),
                            ),
                            child: Icon(item.icon, size: 60, color: VibraColors.accent),
                          ),
                          const SizedBox(height: 28),
                          VibraGlassmorphicCard(
                            child: Column(
                              children: [
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: VibraTextStyles.displaySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.body,
                                  textAlign: TextAlign.center,
                                  style: VibraTextStyles.bodyLarge.copyWith(
                                    color: VibraColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: _page == index ? VibraColors.primaryGradient : null,
                        color: _page == index ? null : VibraColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: VibraPillButton(
                    onPressed: () => context.push('/login'),
                    text: _page == slides.length - 1 ? l10n.onboardingContinue : l10n.onboardingGoToLogin,
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
