import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/vibra_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.backgroundPrimary, t.backgroundSecondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.92 + (_controller.value * 0.12),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.surfaceElevated,
                          border: Border.all(color: t.borderDefault),
                          boxShadow: [t.elevatedShadow],
                        ),
                        child: const Center(
                          child: VibraLogo(width: 80, height: 80),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  AppConstants.appName,
                  style: VibraTextStyles.displayMedium.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.appSlogan,
                  textAlign: TextAlign.center,
                  style: VibraTextStyles.bodyLarge.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                const SizedBox(height: 42),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    valueColor: AlwaysStoppedAnimation<Color>(t.accentPrimary),
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
