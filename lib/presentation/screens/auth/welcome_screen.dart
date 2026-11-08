import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_motion.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_auth_backdrop.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  List<({IconData icon, String title, String body})> _getSlides(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return [
      (
        icon: Icons.graphic_eq_rounded,
        title: AppConstants.spotifyEnabled
            ? l10n.onboardingConnectTitle
            : l10n.launchSavedTitle,
        body: AppConstants.spotifyEnabled
            ? l10n.onboardingConnectBody
            : l10n.launchSavedBody,
      ),
      (
        icon: Icons.place_rounded,
        title: l10n.onboardingDiscoverTitle,
        body: AppConstants.spotifyEnabled
            ? l10n.onboardingDiscoverBody
            : l10n.launchExploreBody,
      ),
      (
        icon: Icons.people_alt_rounded,
        title: l10n.onboardingCommunityTitle,
        body: AppConstants.spotifyEnabled
            ? l10n.onboardingCommunityBody
            : l10n.launchCommunityBody,
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
    final t = context.vibraTokens;
    final slides = _getSlides(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: VibraAuthBackdrop(alignment: Alignment(0, -.35)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
                VibraSpacing.pagePadding,
                VibraSpacing.xl,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const VibraWordmark(markSize: 22),
                      const SizedBox(width: VibraSpacing.md),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/login'),
                            style: TextButton.styleFrom(
                              foregroundColor: t.textPrimary,
                            ),
                            child: Text(
                              l10n.onboardingGoToLogin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: VibraTextStyles.labelMedium.copyWith(
                                color: t.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemCount: slides.length,
                      itemBuilder: (context, index) {
                        final item = slides[index];
                        return _OnboardingSlide(
                          index: index,
                          total: slides.length,
                          icon: item.icon,
                          title: item.title,
                          body: item.body,
                        );
                      },
                    ),
                  ),
                  Semantics(
                    label: '${_page + 1} / ${slides.length}',
                    excludeSemantics: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (index) => AnimatedContainer(
                          duration: VibraMotion.durationFor(
                            context,
                            VibraMotion.medium,
                          ),
                          curve: VibraMotion.signalCurve,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _page == index ? 28 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _page == index
                                ? t.accentPrimary
                                : t.borderStrong,
                            borderRadius: VibraSpacing.borderFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.xxl),
                  VibraPrimaryButton(
                    onPressed: () => context.push('/login'),
                    label: _page == slides.length - 1
                        ? l10n.onboardingContinue
                        : l10n.onboardingGoToLogin,
                    trailingIcon: Icons.arrow_forward_rounded,
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

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.index,
    required this.total,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int index;
  final int total;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final hero = index == 0
        ? const VibraLogo(width: 132, height: 114, animate: true)
        : _EchoIcon(icon: icon);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: VibraSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(height: 180, child: Center(child: hero)),
                ),
                const SizedBox(height: VibraSpacing.huge),
                Text(
                  '${(index + 1).toString().padLeft(2, '0')} — ${total.toString().padLeft(2, '0')}',
                  style: VibraTextStyles.labelSmall.copyWith(
                    color: t.accentPrimary,
                  ),
                ),
                const SizedBox(height: VibraSpacing.md),
                Text(
                  title,
                  style: VibraTextStyles.displaySmall.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: VibraSpacing.md),
                Text(
                  body,
                  style: VibraTextStyles.bodyLarge.copyWith(
                    color: t.textSecondary,
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

/// Icon inside concentric hairline rings — the "vibration" motif.
class _EchoIcon extends StatelessWidget {
  const _EchoIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SizedBox.square(
      dimension: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final (size, alpha) in const [(168.0, .10), (128.0, .18)])
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.accentPrimary.withValues(alpha: alpha),
                ),
              ),
            ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.surfaceElevated,
              border: Border.all(color: t.borderDefault),
            ),
            child: Icon(icon, size: 36, color: t.accentPrimary),
          ),
        ],
      ),
    );
  }
}
