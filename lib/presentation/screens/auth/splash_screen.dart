import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../widgets/common/vibra_logo.dart';

/// Brand hand-off from the native launch screen.
///
/// Pixel-matches the native splash (pure ink canvas, white VIBRA mark at the
/// same size and position) so the switch from native to Flutter is
/// invisible. Routing starts on the first frame — there is no artificial
/// delay; the mark's entrance continues on the Welcome screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Logical size of the mark on the native launch screen
  /// (768 px artwork at 4x with the mark occupying 300 px → 75 dp).
  static const double nativeMarkWidth = 75;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VibraPalette.ink950,
      body: Center(
        child: VibraLogo(
          width: SplashScreen.nativeMarkWidth,
          height: SplashScreen.nativeMarkWidth / VibraLogo.aspectRatio,
          color: VibraPalette.white,
        ),
      ),
    );
  }
}
