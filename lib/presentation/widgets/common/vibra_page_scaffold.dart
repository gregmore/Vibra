import 'package:flutter/material.dart';

import '../../../core/theme/vibra_theme_tokens.dart';

class VibraPageScaffold extends StatelessWidget {
  const VibraPageScaffold({
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.useGradient = true,
    super.key,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: useGradient
              ? [t.backgroundPrimary, t.backgroundSecondary]
              : [t.backgroundPrimary, t.backgroundPrimary],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: extendBody,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: SafeArea(bottom: false, child: child),
      ),
    );
  }
}
