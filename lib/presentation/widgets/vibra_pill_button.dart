import 'package:flutter/material.dart';

import 'common/vibra_button.dart';

/// Legacy CTA API kept for existing call sites. Renders through [VibraButton]
/// so every CTA in the app shares one silhouette and one press behaviour.
class VibraPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isGhost;
  final bool isLoading;
  final bool isDisabled;

  const VibraPillButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isGhost = false,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) => VibraButton(
    label: text,
    onPressed: isDisabled ? null : onPressed,
    loading: isLoading,
    leadingIcon: icon,
    tone: isGhost
        ? VibraButtonTone.outline
        : isPrimary
        ? VibraButtonTone.signal
        : VibraButtonTone.secondary,
  );
}
