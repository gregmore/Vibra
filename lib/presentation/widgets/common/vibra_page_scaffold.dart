import 'package:flutter/material.dart';

import '../../../core/theme/vibra_theme_tokens.dart';

/// The page frame every screen uses (docs/ui-architecture.md).
///
/// On wide screens (tablets, landscape, desktop) the content is centred and
/// capped at [maxContentWidth], so lists and cards keep a readable line
/// length instead of stretching edge to edge; the background still fills the
/// window. Full-bleed screens (the map) pass `maxContentWidth: null`.
class VibraPageScaffold extends StatelessWidget {
  const VibraPageScaffold({
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.useGradient = false,
    this.maxContentWidth = defaultMaxContentWidth,
    super.key,
  });

  /// A comfortable column on tablets; phones are narrower than this.
  static const double defaultMaxContentWidth = 720;

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool useGradient;

  /// Null: use the whole width.
  final double? maxContentWidth;

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
        body: SafeArea(
          bottom: false,
          child: maxContentWidth == null
              ? child
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth!),
                    child: child,
                  ),
                ),
        ),
      ),
    );
  }
}
